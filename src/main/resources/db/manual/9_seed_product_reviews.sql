BEGIN;
SET LOCAL search_path = public;
SET LOCAL TIME ZONE 'Asia/Ho_Chi_Minh';
SELECT pg_advisory_xact_lock(742021, 10);

DO $preflight$
DECLARE missing_columns text;
BEGIN
    SELECT string_agg(t || '.' || c, ', ') INTO missing_columns
    FROM (VALUES
        ('users','email'), ('users','password'), ('users','full_name'),
        ('users','is_active'), ('users','is_blocked'),
        ('users','created_at'), ('users','updated_at'),
        ('products','id'), ('products','name'), ('products','active'),
        ('reviews','user_id'), ('reviews','product_id'), ('reviews','order_id'),
        ('reviews','rating'), ('reviews','comment'), ('reviews','active'),
        ('reviews','created_at'), ('reviews','updated_at'),
        ('roles','name'), ('user_roles','user_id'), ('user_roles','role_id')
    ) AS required(t,c)
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.columns i
        WHERE i.table_schema='public'
          AND i.table_name=required.t AND i.column_name=required.c
    );
    IF missing_columns IS NOT NULL THEN
        RAISE EXCEPTION 'Thiếu bảng/cột cho review: %. Kiểm tra schema trước.',
            missing_columns;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM products) THEN
        RAISE EXCEPTION 'Chưa có sản phẩm. Thêm sản phẩm trước khi tạo review demo.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='public' AND table_name='reviews'
          AND column_name='order_id' AND is_nullable='NO'
    ) THEN
        RAISE EXCEPTION 'reviews.order_id đang NOT NULL, khác entity Review hiện tại. Không tạo đơn giả để lách ràng buộc.';
    END IF;

    -- Không nhận nhầm tài khoản thật có email trùng namespace seed.
    IF EXISTS (
        SELECT 1 FROM users
        WHERE email LIKE 'demo.rev10.%@example.test'
          AND full_name NOT LIKE '[DEMO-REV10] %'
    ) THEN
        RAISE EXCEPTION 'Email demo.rev10.* đã thuộc tài khoản khác. Dừng để không ghi đè.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM users u
        JOIN user_roles ur ON ur.user_id=u.id
        JOIN roles r ON r.id=ur.role_id
        WHERE u.email LIKE 'demo.rev10.%@example.test'
          AND r.name <> 'ROLE_CUSTOMER'
    ) THEN
        RAISE EXCEPTION 'Tài khoản demo review đang có quyền ngoài CUSTOMER. Kiểm tra trước.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM reviews r JOIN users u ON u.id=r.user_id
        WHERE u.email LIKE 'demo.rev10.%@example.test'
          AND r.comment NOT LIKE '[DEMO-REV10] %'
    ) THEN
        RAISE EXCEPTION 'Tài khoản seed đang có bình luận không mang nhãn DEMO-REV10. Không ghi đè.';
    END IF;
END;
$preflight$;

-- Snapshot danh sách sản phẩm của lần chạy này.
-- Muốn chỉ active: đổi truy vấn thành FROM products WHERE active;
-- mặc định giữ tất cả để đáp ứng "mỗi sản phẩm".
CREATE TEMP TABLE _rev10_products ON COMMIT DROP AS
SELECT id,name,active,ROW_NUMBER() OVER (ORDER BY id)::integer AS product_no
FROM products;

-- Mốc tối thiểu có thể tăng ở đây (350, 500, 1000...).
CREATE TEMP TABLE _rev10_config ON COMMIT DROP AS
SELECT 350::integer AS minimum_total,
       COUNT(*)::integer AS product_count,
       GREATEST(5,CEIL(350.0/COUNT(*))::integer) AS base_per_product
FROM _rev10_products;

-- +0..3 review mỗi sản phẩm để tổng và rating giữa các sản phẩm không đồng loạt bằng nhau.
-- Slot 1..5 luôn đủ 5 mức sao; phần bổ sung có phân bố thiên 4/5 sao nhưng vẫn có sao thấp.
CREATE TEMP TABLE _rev10_plan ON COMMIT DROP AS
SELECT p.id AS product_id,p.name AS product_name,p.product_no,
       slot.no AS reviewer_no,
       CASE WHEN slot.no <= 5
            THEN 1 + ((slot.no-1 + p.product_no%5)%5)
            ELSE (ARRAY[5,4,5,3,2,4,5,1,5,4])[1+((slot.no+p.product_no)%10)]
       END::integer AS rating,
       LOCALTIMESTAMP - make_interval(
           days => 1 + ((p.product_no*7 + slot.no*13)%180),
           hours => (p.product_no+slot.no)%24,
           mins => (p.product_no*11+slot.no*17)%60
       ) AS review_time
FROM _rev10_products p CROSS JOIN _rev10_config cfg
CROSS JOIN LATERAL generate_series(
    1,cfg.base_per_product + p.product_no%4
) AS slot(no);

CREATE UNIQUE INDEX ON _rev10_plan(product_id,reviewer_no);

-- Một tài khoản có thể đánh giá nhiều sản phẩm, nhưng mỗi sản phẩm chỉ một lần.
-- Không có mật khẩu đăng nhập; active=false và blocked=true.
-- Mật khẩu bắt đầu bằng ! là giá trị vô hiệu hóa, không phải BCrypt hợp lệ.
INSERT INTO roles(name) VALUES ('ROLE_CUSTOMER')
ON CONFLICT (name) DO NOTHING;

CREATE TEMP TABLE _rev10_new_users ON COMMIT DROP AS
WITH inserted AS (
    INSERT INTO users(
        email,password,full_name,is_active,is_blocked,created_at,updated_at
    )
    SELECT 'demo.rev10.' || LPAD(n::text,4,'0') || '@example.test',
           '!DEMO_REVIEW_ACCOUNT_NO_LOGIN!',
           '[DEMO-REV10] ' ||
           (ARRAY[
                'Minh Anh','Hoàng Nam','Ngọc Linh','Thanh Tùng','Bảo Ngọc',
                'Quốc Huy','Thu Hà','Đức Minh','Hải Yến','Gia Bảo',
                'Mai Phương','Tuấn Kiệt','Khánh Vy','Đình Phúc','Lan Anh',
                'Trọng Nghĩa','Phương Thảo','Anh Khoa','Diệu Linh','Hữu Đạt'
           ])[1+((n-1)%20)] || ' ' || LPAD(n::text,4,'0'),
           FALSE,TRUE,
           LOCALTIMESTAMP - INTERVAL '365 days',
           LOCALTIMESTAMP - INTERVAL '365 days'
    FROM generate_series(1,(SELECT MAX(reviewer_no) FROM _rev10_plan)) AS ids(n)
    ON CONFLICT (email) DO NOTHING
    RETURNING id,email
)
SELECT * FROM inserted;

INSERT INTO user_roles(user_id,role_id)
SELECT u.id,r.id FROM _rev10_new_users u
CROSS JOIN roles r WHERE r.name='ROLE_CUSTOMER'
ON CONFLICT DO NOTHING;

-- Nội dung luôn có nhãn demo, >=50 ký tự, không tuyên bố đây là trải nghiệm thật.
-- Dùng câu chung cho mọi loại sản phẩm để không gán tính năng sai cho từng model.
CREATE TEMP TABLE _rev10_comments (
    rating integer PRIMARY KEY, body text
) ON COMMIT DROP;
INSERT INTO _rev10_comments VALUES
(1,'Mô phỏng mức rất không hài lòng: kết quả kiểm thử thấp hơn mong đợi, cần kiểm tra lại chất lượng và hướng dẫn hỗ trợ.'),
(2,'Mô phỏng mức chưa hài lòng: có một số điểm phù hợp nhưng vẫn còn nhiều hạn chế cần được cải thiện trước khi đánh giá cao hơn.'),
(3,'Mô phỏng mức trung bình: đáp ứng nhu cầu cơ bản trong kịch bản kiểm thử, ưu điểm và nhược điểm vẫn còn tương đối cân bằng.'),
(4,'Mô phỏng mức hài lòng: đáp ứng phần lớn các tiêu chí kiểm thử, thông tin rõ ràng và chỉ còn vài chi tiết nhỏ cần cải thiện.'),
(5,'Mô phỏng mức rất hài lòng: đáp ứng tốt các tiêu chí trong bộ dữ liệu thử nghiệm, nội dung hiển thị và điểm số đúng như mong đợi.');

CREATE TEMP TABLE _rev10_inserted ON COMMIT DROP AS
WITH inserted AS (
    INSERT INTO reviews(
        user_id,product_id,order_id,rating,comment,active,created_at,updated_at
    )
    SELECT u.id,p.product_id,NULL,p.rating,
           '[DEMO-REV10] Dữ liệu mô phỏng để kiểm thử, không phải nhận xét khách hàng thực. '
           || 'Sản phẩm: «' || p.product_name || '». '
           || c.body || ' '
           || (ARRAY[
                'Mục đích là kiểm tra bộ lọc sao và điểm trung bình.',
                'Mục đích là kiểm tra danh sách bình luận trên màn hình nhỏ.',
                'Mục đích là kiểm tra số lượng đánh giá và cách sắp xếp.',
                'Mục đích là kiểm tra hiển thị tiếng Việt và ngày đánh giá.',
                'Mục đích là kiểm tra thanh tỷ lệ đánh giá từ một đến năm sao.',
                'Mục đích là kiểm tra việc tải dữ liệu sau khi làm mới trang.',
                'Mục đích là kiểm tra nội dung dài và bố cục thẻ đánh giá.',
                'Mục đích là kiểm tra tên người viết và email được che bớt.'
           ])[1+((p.product_no+p.reviewer_no)%8)]
           || ' Mã mẫu: P' || p.product_id || '-R' || p.reviewer_no || '.',
           TRUE,p.review_time,p.review_time
    FROM _rev10_plan p JOIN users u
      ON u.email='demo.rev10.' || LPAD(p.reviewer_no::text,4,'0') || '@example.test'
    JOIN _rev10_comments c ON c.rating=p.rating
    WHERE NOT EXISTS (
        SELECT 1 FROM reviews existing
        WHERE existing.user_id=u.id AND existing.product_id=p.product_id
    )
    RETURNING id,product_id,user_id,rating
)
SELECT * FROM inserted;

-- Kiểm tra tính đầy đủ của slot, độ dài và số sao trước khi commit.
-- Tính cả review demo đã tắt để chạy lại KHÔNG tự bật các review bạn đã ẩn.
DO $verify$
BEGIN
    IF (SELECT COUNT(*) FROM _rev10_plan) < 350 THEN
        RAISE EXCEPTION 'Lỗi kế hoạch seed: tổng review dưới 350.';
    END IF;

    IF EXISTS (
        SELECT p.product_id
        FROM _rev10_plan p
        JOIN users u ON u.email=
            'demo.rev10.' || LPAD(p.reviewer_no::text,4,'0') || '@example.test'
        LEFT JOIN reviews r ON r.user_id=u.id AND r.product_id=p.product_id
        GROUP BY p.product_id
        HAVING COUNT(r.id) < 5 OR COUNT(DISTINCT r.rating) < 5
    ) THEN
        RAISE EXCEPTION 'Có sản phẩm thiếu review hoặc thiếu một mức sao. Kiểm tra dữ liệu demo đã sửa trước đó.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM reviews r JOIN users u ON u.id=r.user_id
        JOIN _rev10_products p ON p.id=r.product_id
        WHERE u.email LIKE 'demo.rev10.%@example.test'
          AND (r.rating NOT BETWEEN 1 AND 5
               OR CHAR_LENGTH(BTRIM(r.comment)) NOT BETWEEN 50 AND 5000)
    ) THEN
        RAISE EXCEPTION 'Review demo có số sao/độ dài không hợp lệ.';
    END IF;
END;
$verify$;

-- Kết quả 1: số hàng mới được tạo và tổng demo trong phạm vi sản phẩm hiện tại.
SELECT
    (SELECT COUNT(*) FROM _rev10_products) AS products_in_scope,
    (SELECT COUNT(*) FROM _rev10_inserted) AS reviews_created_this_run,
    (SELECT COUNT(*) FROM _rev10_new_users) AS demo_users_created_this_run,
    COUNT(r.id) AS total_demo_reviews,
    COUNT(r.id) FILTER (WHERE r.active) AS visible_demo_reviews,
    COUNT(r.id) FILTER (WHERE NOT r.active) AS hidden_demo_reviews
FROM reviews r JOIN users u ON u.id=r.user_id
JOIN _rev10_products p ON p.id=r.product_id
WHERE u.email LIKE 'demo.rev10.%@example.test';

-- Kết quả 2: tổng review demo theo từng mức sao.
SELECT r.rating,COUNT(*) AS demo_reviews,
       COUNT(*) FILTER (WHERE r.active) AS visible_demo_reviews
FROM reviews r JOIN users u ON u.id=r.user_id
WHERE u.email LIKE 'demo.rev10.%@example.test'
GROUP BY r.rating ORDER BY r.rating;

-- Kết quả 3: từng sản phẩm, mỗi mức sao và điểm trung bình của demo đang hiển thị.
SELECT p.id,p.name,p.active AS product_active,
       COUNT(r.id) AS demo_reviews,
       COUNT(r.id) FILTER (WHERE r.active) AS visible_demo_reviews,
       COUNT(r.id) FILTER (WHERE r.active AND r.rating=1) AS star_1,
       COUNT(r.id) FILTER (WHERE r.active AND r.rating=2) AS star_2,
       COUNT(r.id) FILTER (WHERE r.active AND r.rating=3) AS star_3,
       COUNT(r.id) FILTER (WHERE r.active AND r.rating=4) AS star_4,
       COUNT(r.id) FILTER (WHERE r.active AND r.rating=5) AS star_5,
       ROUND(AVG(r.rating) FILTER (WHERE r.active),1) AS demo_average_rating
FROM _rev10_products p
LEFT JOIN (
    reviews r JOIN users u ON u.id=r.user_id
        AND u.email LIKE 'demo.rev10.%@example.test'
) ON r.product_id=p.id
GROUP BY p.id,p.name,p.active ORDER BY p.id;

-- Kết quả 4: phải rỗng ngay sau lần seed đầu tiên.
-- Nếu có dòng ở lần sau, có thể bạn đã chủ động sửa/ẩn review demo.
SELECT p.id,p.name,COUNT(r.id) AS visible_demo_reviews,
       COUNT(DISTINCT r.rating) AS visible_star_levels
FROM _rev10_products p
LEFT JOIN (
    reviews r JOIN users u ON u.id=r.user_id
        AND u.email LIKE 'demo.rev10.%@example.test'
) ON r.product_id=p.id AND r.active
GROUP BY p.id,p.name
HAVING COUNT(r.id) < 3 OR COUNT(DISTINCT r.rating) < 5
ORDER BY p.id;

COMMIT;

