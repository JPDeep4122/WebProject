BEGIN;
SET LOCAL search_path = public;
SET LOCAL TIME ZONE 'Asia/Ho_Chi_Minh';
SELECT pg_advisory_xact_lock(742021, 8);

DO $preflight$
DECLARE missing_columns text;
BEGIN
    SELECT string_agg(t || '.' || c, ', ') INTO missing_columns
    FROM (VALUES
        ('promotions','discount_type'), ('promotions','discount_amount'),
        ('promotions','max_discount_amount'), ('promotions','min_order_amount'),
        ('promotions','required_payment_method'), ('promotions','new_customer_only'),
        ('promotions','per_user_limit'), ('orders','voucher_code'),
        ('payments','payment_expires_at'), ('payments','payment_url'),
        ('users','is_blocked')
    ) AS required(t,c)
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.columns i
        WHERE i.table_schema = 'public'
          AND i.table_name = required.t AND i.column_name = required.c
    );
    IF missing_columns IS NOT NULL
        OR to_regclass('public.promotion_categories') IS NULL
        OR to_regclass('public.voucher_usages') IS NULL THEN
        RAISE EXCEPTION 'Thiếu migration 07 hoặc cột schema: %. Chạy migration trước.',
            COALESCE(missing_columns, 'promotion_categories/voucher_usages');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM branches WHERE active) THEN
        RAISE EXCEPTION 'Cần ít nhất một chi nhánh active trước khi tạo TV08.';
    END IF;
    -- Không nhận nhầm tài khoản/sản phẩm/voucher trùng namespace.
    IF EXISTS (
        SELECT 1 FROM users WHERE email LIKE 'tv08.%@example.test'
        AND full_name NOT LIKE '[TV08] %'
    ) OR EXISTS (
        SELECT 1 FROM promotions WHERE code LIKE 'TV08-%'
        AND name NOT LIKE '[TV08] %'
    ) OR EXISTS (
        SELECT 1 FROM products WHERE sku LIKE 'TV08-%'
        AND name NOT LIKE '[TV08] %'
    ) OR EXISTS (
        SELECT 1 FROM categories WHERE slug LIKE 'tv08-%'
        AND name NOT LIKE '[TV08] %'
    ) OR EXISTS (
        SELECT 1 FROM orders WHERE order_code LIKE 'TV08-O-%'
        AND COALESCE(note, '') NOT LIKE '[TV08] %'
    ) OR EXISTS (
        SELECT 1 FROM brands WHERE name = 'TV08 TEST'
        AND logo_url IS DISTINCT FROM '/images/categories/noi-com-dien.png'
    ) THEN
        RAISE EXCEPTION 'Namespace TV08 đã bị đối tượng khác sử dụng; không ghi đè.';
    END IF;
    IF EXISTS (
        SELECT 1 FROM users u JOIN user_roles ur ON ur.user_id=u.id
        JOIN roles r ON r.id=ur.role_id
        WHERE u.email LIKE 'tv08.%@example.test'
          AND r.name <> 'ROLE_CUSTOMER'
    ) THEN
        RAISE EXCEPTION 'Khách TV08 đang có quyền ngoài CUSTOMER; kiểm tra trước khi seed.';
    END IF;
END;
$preflight$;

-- Tất cả temp table tự xóa lúc COMMIT, không tạo bảng test lâu dài.
CREATE TEMP TABLE _tv08_categories (
    key text PRIMARY KEY, parent_key text, label text
) ON COMMIT DROP;
INSERT INTO _tv08_categories VALUES
    ('root', NULL, 'Nhóm gốc'),
    ('kitchen', 'root', 'Nhóm bếp'),
    ('cooker', 'kitchen', 'Nồi thử nghiệm'),
    ('kettle', 'kitchen', 'Ấm thử nghiệm'),
    ('electronics', 'root', 'Điện tử thử nghiệm'),
    ('audio', NULL, 'Âm thanh ngoài nhóm gốc'),
    ('empty', NULL, 'Danh mục chưa có sản phẩm');

INSERT INTO categories(name,slug,active)
SELECT '[TV08] ' || label, 'tv08-' || key, TRUE
FROM _tv08_categories
WHERE parent_key IS NULL
ON CONFLICT (slug) DO NOTHING;

-- Hai tầng con, không sửa lại parent/active của danh mục đã có.
INSERT INTO categories(name,slug,parent_id,active)
SELECT '[TV08] ' || c.label, 'tv08-' || c.key, p.id, TRUE
FROM _tv08_categories c JOIN categories p ON p.slug='tv08-' || c.parent_key
WHERE c.parent_key='root'
ON CONFLICT (slug) DO NOTHING;
INSERT INTO categories(name,slug,parent_id,active)
SELECT '[TV08] ' || c.label, 'tv08-' || c.key, p.id, TRUE
FROM _tv08_categories c JOIN categories p ON p.slug='tv08-' || c.parent_key
WHERE c.parent_key='kitchen'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO brands(name,logo_url,active)
VALUES ('TV08 TEST','/images/categories/noi-com-dien.png',TRUE)
ON CONFLICT (name) DO NOTHING;

CREATE TEMP TABLE _tv08_products (
    suffix text PRIMARY KEY, label text, category_key text,
    price numeric, original_price numeric, discount_price numeric,
    active boolean, initial_stock integer
) ON COMMIT DROP;
INSERT INTO _tv08_products VALUES
    ('P01','Nồi biên dưới 500K','cooker',499999,499999,NULL,TRUE,500),
    ('P02','Nồi đúng 500K','cooker',500000,500000,NULL,TRUE,500),
    ('P03','Ấm biên dưới 2 triệu','kettle',1999999,1999999,NULL,TRUE,500),
    ('P04','Loa đúng 2 triệu','audio',2000000,2000000,NULL,TRUE,500),
    ('P05','Nồi giá 3 triệu','cooker',3000000,3000000,NULL,TRUE,500),
    ('P06','Nồi 400K để trộn giỏ','cooker',400000,400000,NULL,TRUE,500),
    ('P07','Ấm 100K','kettle',100000,100000,NULL,TRUE,500),
    ('P08','Loa giá lẻ 99.99 đồng','audio',99.99,99.99,NULL,TRUE,500),
    ('P09','Ấm giảm từ 600K còn 450K','kettle',600000,600000,450000,TRUE,500),
    ('P10','Điện tử 100K ngoài nhóm bếp','electronics',100000,100000,NULL,TRUE,500),
    ('P11','Nồi giá 0 đồng','cooker',0,0,NULL,TRUE,500),
    ('P12','Nồi đã ngừng bán','cooker',500000,500000,NULL,FALSE,500),
    ('P13','Nồi hết hàng','cooker',500000,500000,NULL,TRUE,0),
    ('P14','Nồi chỉ còn 1 chiếc','cooker',500000,500000,NULL,TRUE,1);

INSERT INTO products (
    name,slug,sku,short_description,description,
    original_price,price,discount_price,main_image_url,
    category_id,brand_id,active,featured,favorite_count,created_at
)
SELECT '[TV08] ' || t.label, 'tv08-' || LOWER(t.suffix),
    'TV08-' || t.suffix,
    '[TV08] Sản phẩm mô phỏng để test voucher; không phải hàng thương mại.',
    '[TV08] Dữ liệu test. Giá/stock được giữ nguyên khi chạy lại seed.',
    t.original_price,t.price,t.discount_price,
    CASE WHEN t.category_key='audio' THEN '/images/categories/loa.png'
         WHEN t.category_key='kettle' THEN '/images/categories/binh-dun-sieu-toc.png'
         ELSE '/images/categories/noi-com-dien.png' END,
    c.id,b.id,t.active,FALSE,0,LOCALTIMESTAMP
FROM _tv08_products t JOIN categories c ON c.slug='tv08-' || t.category_key
CROSS JOIN brands b WHERE b.name='TV08 TEST'
ON CONFLICT (sku) DO NOTHING;

INSERT INTO product_imagines(product_id,image_url)
SELECT p.id,p.main_image_url FROM products p
JOIN _tv08_products t ON p.sku='TV08-' || t.suffix
WHERE NOT EXISTS (
    SELECT 1 FROM product_imagines i WHERE i.product_id=p.id
);

-- Có kho ở mọi chi nhánh active vì ShippingService tự chọn chi nhánh.
-- Không tạo thêm chi nhánh và không reset kho của lần test trước.
INSERT INTO branch_inventory (
    branch_id,product_id,stock_quantity,reserved_quantity,available_quantity,updated_at
)
SELECT b.id,p.id,t.initial_stock,0,t.initial_stock,LOCALTIMESTAMP
FROM branches b CROSS JOIN _tv08_products t
JOIN products p ON p.sku='TV08-' || t.suffix
WHERE b.active
ON CONFLICT (branch_id,product_id) DO NOTHING;

CREATE TEMP TABLE _tv08_rules (
    suffix text PRIMARY KEY, label text, discount_type text,
    discount_percent numeric, discount_amount numeric, max_discount_amount numeric,
    min_order_amount numeric, required_payment_method text,
    new_customer_only boolean, per_user_limit integer, max_uses integer,
    active boolean, time_window text, category_keys text[]
) ON COMMIT DROP;
INSERT INTO _tv08_rules VALUES
    -- 500.000đ → giảm 50.000đ.
    ('P10', 'Giảm 10%', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- 3.000.000đ → giảm 200.000đ.
    ('P10CAP', '10% tối đa 200K', 'PERCENT', 10, NULL, 200000, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- 500.000đ → giảm 62.500đ.
    ('P125', 'Giảm 12,5%', 'PERCENT', 12.5, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- 500.000đ → giảm 50đ.
    ('P001', 'Giảm 0,01%', 'PERCENT', 0.01, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- Không giảm phần phí ship; VNPay không chấp nhận số tiền 0.
    ('P100', 'Giảm 100% tiền hàng', 'PERCENT', 100, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- 500.000đ → giảm 50.000đ.
    ('FIX50', 'Giảm cố định 50K', 'FIXED', NULL, 50000, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- 500.000đ → giảm 30.000đ.
    ('FIXCAP', '50K nhưng trần 30K', 'FIXED', NULL, 50000, 30000, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- 500.000đ → chỉ giảm 500.000đ; không âm.
    ('FIXHUGE', 'Giảm lớn hơn tiền hàng', 'FIXED', NULL, 9999999, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- 499.999đ bị chặn; 500.000đ được giảm 50K.
    ('MIN500', 'Đơn từ 500K', 'FIXED', NULL, 50000, NULL, 500000, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- 1.999.999đ bị chặn; 2.000.000đ được áp dụng.
    ('MIN2M', 'Đơn từ 2 triệu', 'FIXED', NULL, 50000, NULL, 2000000, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- Ship 0 bị từ chối; ship 50K giảm 50K.
    ('SHIP', 'Giảm toàn bộ phí ship', 'SHIPPING', NULL, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- Ship 15K giảm 15K; ship 50K giảm 30K.
    ('SHIP30', 'Giảm ship tối đa 30K', 'SHIPPING', NULL, NULL, 30000, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- Thiếu 500K tiền hàng hoặc ship 0 bị chặn.
    ('SHIPMIN', 'Giảm ship đơn từ 500K', 'SHIPPING', NULL, NULL, NULL, 500000, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- COD được; VNPay bị chặn.
    ('COD', 'Chỉ thanh toán COD', 'FIXED', NULL, 50000, NULL, 0, 'COD', FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- VNPay được; COD bị chặn.
    ('VNPAY100', 'Chỉ VNPay giảm 100K', 'FIXED', NULL, 100000, NULL, 100000, 'VNPAY', FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- Không hiện trong kho; nhập trực tiếp bị từ chối.
    ('OFF', 'Voucher đã tắt', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, NULL, FALSE, 'active', ARRAY[]::text[]),
    -- Không hiện trong kho; nhập trực tiếp bị từ chối.
    ('EXPIRED', 'Voucher đã hết hạn', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'expired', ARRAY[]::text[]),
    -- Không hiện trong kho; nhập trực tiếp bị từ chối.
    ('FUTURE', 'Voucher chưa bắt đầu', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'future', ARRAY[]::text[]),
    -- Có thể áp dụng; ends_at NULL.
    ('NOEND', 'Không có ngày kết thúc', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'noend', ARRAY[]::text[]),
    -- Có thể áp dụng; starts_at NULL.
    ('NOSTART', 'Không có ngày bắt đầu', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'nostart', ARRAY[]::text[]),
    -- Có thể áp dụng; cả hai mốc NULL.
    ('NODATES', 'Không giới hạn thời gian', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'nodates', ARRAY[]::text[]),
    -- max_uses và per_user_limit NULL.
    ('UNLIMITED', 'Không giới hạn lượt', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- Hết lượt ngay từ đầu.
    ('MAX0', 'Giới hạn tổng bằng 0', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, 0, TRUE, 'active', ARRAY[]::text[]),
    -- Đã có 1/2 lượt; hai khách tranh lượt cuối.
    ('LAST', 'Chỉ còn một lượt', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, 2, TRUE, 'active', ARRAY[]::text[]),
    -- Đã có 2/2 lượt, phải từ chối.
    ('USED', 'Đã dùng hết lượt', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, 2, TRUE, 'active', ARRAY[]::text[]),
    -- tv08.limit đã dùng 1 lần, phải từ chối; khách khác dùng được.
    ('U1', 'Mỗi khách một lượt', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, 1, 100, TRUE, 'active', ARRAY[]::text[]),
    -- tv08.limit đã dùng 1 lần, còn được dùng 1 lần.
    ('U2', 'Mỗi khách hai lượt', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, 2, 100, TRUE, 'active', ARRAY[]::text[]),
    -- new1/new2 được; old/pending bị chặn; cancelled/failed/released được lúc đầu.
    ('NEW', 'Chỉ khách mới', 'PERCENT', 10, NULL, NULL, 0, NULL, TRUE, 1, 100, TRUE, 'active', ARRAY[]::text[]),
    -- Khách mới + COD được; sai một điều kiện bị chặn.
    ('NEWCOD', 'Khách mới và COD', 'FIXED', NULL, 50000, NULL, 0, 'COD', TRUE, 1, 100, TRUE, 'active', ARRAY[]::text[]),
    -- Áp dụng cho con/cháu của root; audio ngoài root không được.
    ('ROOT', 'Danh mục cha TV08', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY['root']::text[]),
    -- Nồi/ấm được; điện tử/audio không được.
    ('KITCHEN', 'Nhóm bếp và danh mục con', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY['kitchen']::text[]),
    -- Nồi được; ấm cùng cha không được.
    ('COOKER', 'Chỉ danh mục nồi', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY['cooker']::text[]),
    -- Nồi + audio được; ấm không được.
    ('TWO', 'Hai danh mục riêng', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY['cooker','audio']::text[]),
    -- Chỉ giảm trên tiền hàng audio.
    ('AUDIO', 'Chỉ âm thanh', 'FIXED', NULL, 50000, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY['audio']::text[]),
    -- Có voucher nhưng giỏ không có hàng đủ điều kiện, phải chặn.
    ('EMPTY', 'Danh mục không có hàng', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY['empty']::text[]),
    -- Giỏ mixed: bếp 400K + audio 2M vẫn bị chặn.
    ('CATMIN', 'Tiền hàng bếp từ 500K', 'PERCENT', 10, NULL, NULL, 500000, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY['kitchen']::text[]),
    -- Đủ mọi điều kiện mới được giảm; tối đa 200K.
    ('COMBO', 'Bếp + khách mới + VNPay', 'PERCENT', 10, NULL, 200000, 500000, 'VNPAY', TRUE, 1, 100, TRUE, 'active', ARRAY['kitchen']::text[]),
    -- Đơn cancelled đã hoàn; tv08.released dùng lại được.
    ('RELEASE', 'Đã hoàn lượt sau hủy', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, 1, 1, TRUE, 'active', ARRAY[]::text[]),
    -- Có đơn TV08-O-CANCEL PENDING; hủy trên UI phải giảm used_count đúng 1.
    ('CANCEL', 'Test hủy đơn hoàn lượt', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, NULL, 5, TRUE, 'active', ARRAY[]::text[]),
    -- Có đơn TV08-O-EXPIRE chờ VNPay đã hết hạn; chạy nút xử lý hết hạn.
    ('EXPIRE', 'Test giải phóng đơn hết hạn', 'PERCENT', 10, NULL, NULL, 0, 'VNPAY', FALSE, NULL, 5, TRUE, 'active', ARRAY[]::text[]),
    -- Đơn FAILED đã có released_at; không hoàn lần hai.
    ('FAILED', 'Lịch sử VNPay thất bại', 'PERCENT', 10, NULL, NULL, 0, 'VNPAY', FALSE, 1, 5, TRUE, 'active', ARRAY[]::text[]),
    -- Hai tab cùng khách chỉ được một đơn; hai khách riêng được mỗi người một đơn.
    ('RACEUSER', 'Giới hạn theo khách đồng thời', 'PERCENT', 10, NULL, NULL, 0, NULL, FALSE, 1, 100, TRUE, 'active', ARRAY[]::text[]),
    -- P08 giá 99,99, qty 1 bị chặn; qty 2 được giảm 1đ.
    ('MINCENT', 'Biên 99,99 và 100 đồng', 'FIXED', NULL, 1, NULL, 100, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]),
    -- Phí ship dương giảm đúng 1đ.
    ('SHIP1', 'Trần ship một đồng', 'SHIPPING', NULL, NULL, 1, 0, NULL, FALSE, NULL, NULL, TRUE, 'active', ARRAY[]::text[]);

CREATE TEMP TABLE _tv08_new_promotions ON COMMIT DROP AS
WITH inserted AS (
    INSERT INTO promotions (
        name,code,discount_type,discount_percent,discount_amount,
        max_discount_amount,min_order_amount,required_payment_method,
        new_customer_only,per_user_limit,max_uses,used_count,active,
        starts_at,ends_at,created_at
    )
    SELECT '[TV08] ' || r.label, 'TV08-' || r.suffix,
        r.discount_type,r.discount_percent,r.discount_amount,
        r.max_discount_amount,r.min_order_amount,r.required_payment_method,
        r.new_customer_only,r.per_user_limit,r.max_uses,0,r.active,
        CASE r.time_window
            WHEN 'expired' THEN LOCALTIMESTAMP - INTERVAL '30 days'
            WHEN 'future' THEN LOCALTIMESTAMP + INTERVAL '7 days'
            WHEN 'nostart' THEN NULL
            WHEN 'nodates' THEN NULL
            ELSE LOCALTIMESTAMP - INTERVAL '1 day' END,
        CASE r.time_window
            WHEN 'expired' THEN LOCALTIMESTAMP - INTERVAL '1 day'
            WHEN 'noend' THEN NULL
            WHEN 'nodates' THEN NULL
            ELSE LOCALTIMESTAMP + INTERVAL '90 days' END,
        LOCALTIMESTAMP
    FROM _tv08_rules r
    ON CONFLICT (code) DO NOTHING
    RETURNING id,code
)
SELECT * FROM inserted;

INSERT INTO promotion_categories(promotion_id,category_id)
SELECT p.id,c.id FROM _tv08_new_promotions p
JOIN _tv08_rules r ON p.code='TV08-' || r.suffix
CROSS JOIN LATERAL UNNEST(r.category_keys) AS key(category_key)
JOIN categories c ON c.slug='tv08-' || key.category_key
ON CONFLICT DO NOTHING;

CREATE TEMP TABLE _tv08_customers (
    key text PRIMARY KEY, label text, cart_product text
) ON COMMIT DROP;
INSERT INTO _tv08_customers VALUES
    ('new1','Khách mới A','P02'),
    ('new2','Khách mới B biên 499999','P01'),
    ('old','Khách đã có đơn','P02'),
    ('pending','Khách có đơn chờ VNPay','P02'),
    ('cancelled','Khách chỉ có đơn đã hủy','P02'),
    ('failed','Khách chỉ có đơn thanh toán thất bại','P02'),
    ('limit','Khách đã dùng U1 và U2 mỗi mã 1 lần','P02'),
    ('released','Khách đã được hoàn lượt','P02'),
    ('expire','Khách có đơn chờ đã hết hạn','P02'),
    ('racea','Khách tranh lượt cuối A','P02'),
    ('raceb','Khách tranh lượt cuối B','P02'),
    ('mixed','Khách giỏ bếp 400K và audio 2M','P06');

INSERT INTO roles(name) VALUES ('ROLE_CUSTOMER') ON CONFLICT (name) DO NOTHING;

CREATE TEMP TABLE _tv08_new_users ON COMMIT DROP AS
WITH inserted AS (
    INSERT INTO users (
        email,password,full_name,phone_number,is_active,is_blocked,created_at,updated_at
    )
    SELECT 'tv08.' || c.key || '@example.test',
        '$2a$10$HlmJuFDa8AERvHvifDaATOxCaLqbUO3C8Eiu3.mNfPmbP/2ooJBDK',
        '[TV08] ' || c.label,'0900000000',TRUE,FALSE,LOCALTIMESTAMP,LOCALTIMESTAMP
    FROM _tv08_customers c
    ON CONFLICT (email) DO NOTHING RETURNING id,email
)
SELECT * FROM inserted;

INSERT INTO user_roles(user_id,role_id)
SELECT u.id,r.id FROM _tv08_new_users u
CROSS JOIN roles r WHERE r.name='ROLE_CUSTOMER'
ON CONFLICT DO NOTHING;

-- Không đụng vào giỏ đã tồn tại, kể cả giỏ đã được người test xóa hết món.
CREATE TEMP TABLE _tv08_new_carts ON COMMIT DROP AS
WITH inserted AS (
    INSERT INTO carts(user_id,created_at,updated_at)
    SELECT u.id,LOCALTIMESTAMP,LOCALTIMESTAMP
    FROM _tv08_customers c
    JOIN users u ON u.email='tv08.' || c.key || '@example.test'
    ON CONFLICT (user_id) DO NOTHING
    RETURNING id,user_id
)
SELECT * FROM inserted;

INSERT INTO cart_items(cart_id,product_id,quantity,is_selected,created_at,updated_at)
SELECT cart.id,p.id,1,TRUE,LOCALTIMESTAMP,LOCALTIMESTAMP
FROM _tv08_new_carts cart JOIN users u ON u.id=cart.user_id
JOIN _tv08_customers c ON u.email='tv08.' || c.key || '@example.test'
JOIN products p ON p.sku='TV08-' || c.cart_product;

INSERT INTO cart_items(cart_id,product_id,quantity,is_selected,created_at,updated_at)
SELECT cart.id,p.id,1,TRUE,LOCALTIMESTAMP,LOCALTIMESTAMP
FROM _tv08_new_carts cart JOIN users u ON u.id=cart.user_id
CROSS JOIN products p
WHERE u.email='tv08.mixed@example.test' AND p.sku='TV08-P04';

-- Đơn fixture có tiền hàng 500K, một TV08-P02, không trừ kho vì đều
-- đang PENDING hoặc CANCELLED. Không giả tạo shipper/ảnh/giao hàng.
CREATE TEMP TABLE _tv08_order_specs (
    key text PRIMARY KEY, customer_key text, status text,
    method text, payment_status text, voucher_suffix text,
    discount numeric, released boolean, expiry_minutes integer
) ON COMMIT DROP;
INSERT INTO _tv08_order_specs VALUES
    ('OLD','old','PENDING','COD','PENDING',NULL,0,FALSE,NULL),
    ('PENDING','pending','PENDING','VNPAY','PENDING',NULL,0,FALSE,10080),
    ('CANCELLED','cancelled','CANCELLED','COD','PENDING',NULL,0,FALSE,NULL),
    ('FAILED','failed','PENDING','VNPAY','FAILED','FAILED',50000,TRUE,-10),
    ('U1','limit','PENDING','COD','PENDING','U1',50000,FALSE,NULL),
    ('U2','limit','PENDING','COD','PENDING','U2',50000,FALSE,NULL),
    ('RELEASE','released','CANCELLED','COD','PENDING','RELEASE',50000,TRUE,NULL),
    ('EXPIRE','expire','PENDING','VNPAY','PENDING','EXPIRE',50000,FALSE,-10),
    ('CANCEL','old','PENDING','COD','PENDING','CANCEL',50000,FALSE,NULL),
    ('LAST','old','PENDING','COD','PENDING','LAST',50000,FALSE,NULL),
    ('USED1','old','PENDING','COD','PENDING','USED',50000,FALSE,NULL),
    ('USED2','old','PENDING','COD','PENDING','USED',50000,FALSE,NULL);

CREATE TEMP TABLE _tv08_new_orders ON COMMIT DROP AS
WITH inserted AS (
    INSERT INTO orders (
        order_code,user_id,recipient_email,branch_id,
        total_amount,shipping_fee,discount_amount,final_amount,status,
        recipient_name,recipient_phone,shipping_address,note,
        created_at,updated_at,voucher_code
    )
    SELECT 'TV08-O-' || s.key,u.id,u.email,b.id,
        500000,0,s.discount,500000-s.discount,s.status,
        u.full_name,'0900000000',b.address,
        '[TV08] FIXTURE ' || s.key
            || '. Dữ liệu mô phỏng, không phải thanh toán hay giao hàng thực.',
        LOCALTIMESTAMP - INTERVAL '1 hour',LOCALTIMESTAMP,
        CASE WHEN s.voucher_suffix IS NULL THEN NULL
             ELSE 'TV08-' || s.voucher_suffix END
    FROM _tv08_order_specs s
    JOIN users u ON u.email='tv08.' || s.customer_key || '@example.test'
    CROSS JOIN LATERAL (
        SELECT id,address FROM branches WHERE active ORDER BY id LIMIT 1
    ) b
    ON CONFLICT (order_code) DO NOTHING
    RETURNING id,order_code,user_id
)
SELECT * FROM inserted;

INSERT INTO order_items(order_id,product_id,quantity,price,subtotal)
SELECT o.id,p.id,1,500000,500000 FROM _tv08_new_orders o
CROSS JOIN products p WHERE p.sku='TV08-P02';

INSERT INTO payments(
    order_id,payment_method,payment_status,amount,created_at,
    payment_url,payment_expires_at
)
SELECT o.id,s.method,s.payment_status,500000-s.discount,
    LOCALTIMESTAMP - INTERVAL '1 hour',NULL,
    CASE WHEN s.expiry_minutes IS NOT NULL
         THEN CURRENT_TIMESTAMP + make_interval(mins => s.expiry_minutes)
         ELSE NULL END
FROM _tv08_new_orders o
JOIN _tv08_order_specs s ON o.order_code='TV08-O-' || s.key;

-- Chỉ tăng counter cho usage đang hoạt động VỪA được insert.
-- Chạy lại không tăng thêm; usage đã hoàn không bị hồi sinh.
WITH inserted AS (
    INSERT INTO voucher_usages(
        order_id,promotion_id,user_id,discount_amount,created_at,released_at,release_reason
    )
    SELECT o.id,p.id,o.user_id,s.discount,
        CURRENT_TIMESTAMP - INTERVAL '1 hour',
        CASE WHEN s.released THEN CURRENT_TIMESTAMP - INTERVAL '30 minutes' ELSE NULL END,
        CASE WHEN s.released THEN
            CASE WHEN s.payment_status='FAILED' THEN 'VNPAY_FAILED'
                 ELSE 'ORDER_CANCELLED' END ELSE NULL END
    FROM _tv08_new_orders o
    JOIN _tv08_order_specs s ON o.order_code='TV08-O-' || s.key
    JOIN promotions p ON p.code='TV08-' || s.voucher_suffix
    WHERE s.voucher_suffix IS NOT NULL
    ON CONFLICT (order_id) DO NOTHING
    RETURNING promotion_id,released_at
), increments AS (
    SELECT promotion_id,COUNT(*)::integer AS delta
    FROM inserted WHERE released_at IS NULL GROUP BY promotion_id
)
UPDATE promotions p SET used_count=p.used_count+i.delta
FROM increments i WHERE p.id=i.promotion_id;

-- Báo cáo seed: CHỈ tài khoản tạo mới nhận mật khẩu demo nêu ở đầu file.
SELECT 'tv08.' || c.key || '@example.test' AS email,c.label AS scenario,
    CASE WHEN n.id IS NOT NULL THEN 'TAO_MOI: Voucher@12345'
         ELSE 'DA_CO: GIU_NGUYEN_MAT_KHAU_VA_TRANG_THAI' END AS account_result
FROM _tv08_customers c
LEFT JOIN _tv08_new_users n ON n.email='tv08.' || c.key || '@example.test'
ORDER BY c.key;

SELECT p.code,p.discount_type,p.used_count,p.max_uses,
    p.per_user_limit,p.active,p.starts_at,p.ends_at
FROM promotions p JOIN _tv08_rules r ON p.code='TV08-' || r.suffix
ORDER BY p.id;

SELECT b.name AS branch,b.province,b.address,
    COUNT(i.id) AS tv08_inventory_rows
FROM branches b JOIN branch_inventory i ON i.branch_id=b.id
JOIN products p ON p.id=i.product_id
WHERE p.sku LIKE 'TV08-%'
GROUP BY b.id,b.name,b.province,b.address ORDER BY b.id;

COMMIT;

