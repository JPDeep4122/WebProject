BEGIN;
SET LOCAL lock_timeout = '10s';
SET LOCAL statement_timeout = '90s';
SET LOCAL search_path = public, pg_catalog;
SELECT pg_advisory_xact_lock(742020, 20261027);

DO $preflight$
DECLARE missing_tables TEXT;
BEGIN
    SELECT string_agg(required.name, ', ' ORDER BY required.name) INTO missing_tables
    FROM unnest(ARRAY['categories','brands','products','product_imagines','branches','branch_inventory']) required(name)
    WHERE to_regclass('public.' || required.name) IS NULL;
    IF missing_tables IS NOT NULL THEN
        RAISE EXCEPTION 'Thieu bang: %. Chon dung database va chuan bi schema truoc.', missing_tables;
    END IF;
END;
$preflight$;

CREATE TEMP TABLE _catalog05_categories (
    slug TEXT PRIMARY KEY, name TEXT NOT NULL UNIQUE, icon TEXT NOT NULL, image_url TEXT NOT NULL
) ON COMMIT DROP;
INSERT INTO pg_temp._catalog05_categories (slug, name, icon, image_url) VALUES
    ('tivi', 'Tivi', 'bi-tv', '/images/categories/tivi.png'),
    ('tu-lanh', 'Tủ lạnh', 'bi-snow2', '/images/categories/tu-lanh.png'),
    ('may-giat', 'Máy giặt', 'bi-water', '/images/categories/may-giat.png'),
    ('may-lanh', 'Máy lạnh', 'bi-wind', '/images/categories/may-lanh.png'),
    ('may-say-quan-ao', 'Máy sấy quần áo', 'bi-brightness-high', '/images/categories/may-say-quan-ao.png'),
    ('tu-dong', 'Tủ đông', 'bi-snow', '/images/categories/tu-dong.png'),
    ('noi-com-dien', 'Nồi cơm điện', 'bi-plug', '/images/categories/noi-com-dien.png'),
    ('lo-vi-song', 'Lò vi sóng', 'bi-lightning-charge', '/images/categories/lo-vi-song.png'),
    ('noi-chien-khong-dau', 'Nồi chiên không dầu', 'bi-fire', '/images/categories/noi-chien-khong-dau.png'),
    ('binh-dun-sieu-toc', 'Bình đun siêu tốc', 'bi-cup-hot', '/images/categories/binh-dun-sieu-toc.png'),
    ('bep-tu', 'Bếp từ', 'bi-lightning', '/images/categories/bep-tu.png'),
    ('ban-ui', 'Bàn ủi', 'bi-steam', '/images/categories/ban-ui.png'),
    ('chao-chong-dinh', 'Chảo chống dính', 'bi-circle', '/images/categories/chao.png'),
    ('bo-noi', 'Bộ nồi', 'bi-circle-square', '/images/categories/bo-noi.png'),
    ('dao-keo-nha-bep', 'Dao kéo nhà bếp', 'bi-scissors', '/images/categories/dao.png'),
    ('hop-thuc-pham', 'Hộp thực phẩm', 'bi-box-seam', '/images/categories/hop-thuc-pham.png'),
    ('tai-nghe', 'Tai nghe', 'bi-headphones', '/images/categories/tai-nghe.png'),
    ('pin-sac-du-phong', 'Pin sạc dự phòng', 'bi-battery-charging', '/images/categories/pin-sac.png'),
    ('cap-sac', 'Cáp sạc', 'bi-usb-c', '/images/categories/cap-sac.png'),
    ('may-loc-nuoc', 'Máy lọc nước', 'bi-droplet', '/images/categories/may-loc-nuoc.png'),
    ('cay-nuoc-nong-lanh', 'Cây nước nóng lạnh', 'bi-droplet-half', '/images/categories/cay-nuoc-nong-lanh.png'),
    ('quat-dien', 'Quạt điện', 'bi-fan', '/images/categories/quat-dung.png'),
    ('quat-dieu-hoa', 'Quạt điều hòa', 'bi-wind', '/images/categories/quat-dieu-hoa.png'),
    ('quat-tran', 'Quạt trần', 'bi-fan', '/images/categories/quat-tran.png'),
    ('may-hut-bui', 'Máy hút bụi', 'bi-house-check', '/images/categories/may-hut-bui.png'),
    ('robot-hut-bui', 'Robot hút bụi', 'bi-robot', '/images/categories/robot-hut-bui.png'),
    ('may-loc-khong-khi', 'Máy lọc không khí', 'bi-cloud-haze', '/images/categories/may-loc-khong-khi.png'),
    ('may-hut-am', 'Máy hút ẩm', 'bi-moisture', '/images/categories/may-hut-am.png'),
    ('may-xay-sinh-to', 'Máy xay sinh tố', 'bi-cup-straw', '/images/categories/may-xay-sinh-to.png'),
    ('may-ep-trai-cay', 'Máy ép trái cây', 'bi-cup-straw', '/images/categories/may-ep-trai-cay.png'),
    ('may-say-toc', 'Máy sấy tóc', 'bi-wind', '/images/categories/may-say-toc.png'),
    ('loa', 'Loa', 'bi-speaker', '/images/categories/loa.png');

-- Khong sua category co san. Tu choi xung dot name/slug de tranh gan nham danh muc.
DO $category_conflicts$
BEGIN
    IF EXISTS (
        SELECT 1 FROM public.categories category
        JOIN pg_temp._catalog05_categories seed ON category.slug = seed.slug OR category.name = seed.name
        WHERE category.slug <> seed.slug OR category.name <> seed.name
    ) THEN
        RAISE EXCEPTION 'Category name/slug trung voi du lieu khac. Kiem tra categories; seed khong doi ten/slug hien co.';
    END IF;
END;
$category_conflicts$;

INSERT INTO public.categories (name, slug, icon, active, parent_id)
SELECT name, slug, icon, TRUE, NULL FROM pg_temp._catalog05_categories
ON CONFLICT DO NOTHING;

INSERT INTO public.brands (name, active) VALUES
    ('Alaska', TRUE),
    ('Anker', TRUE),
    ('Aqua', TRUE),
    ('Asia', TRUE),
    ('Baseus', TRUE),
    ('Beko', TRUE),
    ('Belkin', TRUE),
    ('Casper', TRUE),
    ('Daikin', TRUE),
    ('Daikiosan', TRUE),
    ('Dreame', TRUE),
    ('Ecovacs', TRUE),
    ('Electrolux', TRUE),
    ('Elmich', TRUE),
    ('Glasslock', TRUE),
    ('JBL', TRUE),
    ('KDK', TRUE),
    ('Kangaroo', TRUE),
    ('Karofi', TRUE),
    ('Kosmen', TRUE),
    ('Kuvings', TRUE),
    ('LG', TRUE),
    ('Lock&Lock', TRUE),
    ('Mitsubishi Electric', TRUE),
    ('Panasonic', TRUE),
    ('Philips', TRUE),
    ('Samsung', TRUE),
    ('Sanaky', TRUE),
    ('Senko', TRUE),
    ('Sharp', TRUE),
    ('Sony', TRUE),
    ('Sunhouse', TRUE),
    ('Tefal', TRUE),
    ('Toshiba', TRUE),
    ('Xiaomi', TRUE)
ON CONFLICT (name) DO NOTHING;

CREATE TEMP TABLE _catalog05_products (
    category_slug TEXT NOT NULL, variant INTEGER NOT NULL, brand_name TEXT NOT NULL,
    name TEXT NOT NULL, original_price NUMERIC(18,2) NOT NULL, selling_price NUMERIC(18,2) NOT NULL,
    specs JSONB NOT NULL, initial_stock INTEGER NOT NULL,
    PRIMARY KEY (category_slug, variant),
    CHECK (original_price >= selling_price AND selling_price > 0),
    CHECK (initial_stock > 0)
) ON COMMIT DROP;
INSERT INTO pg_temp._catalog05_products
    (category_slug, variant, brand_name, name, original_price, selling_price, specs, initial_stock)
VALUES
    ('tivi', 1, 'Sony', 'Google Tivi Sony 4K 43 inch TS43',
     10990000, 8990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Màn hình: 43 inch","Độ phân giải: 4K","Kết nối: Wi-Fi, HDMI"]}'::jsonb, 24),
    ('tivi', 2, 'Samsung', 'Smart Tivi Samsung 4K 55 inch TS55',
     15990000, 12490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Màn hình: 55 inch","Độ phân giải: 4K","Kết nối: Wi-Fi, Bluetooth"]}'::jsonb, 9),
    ('tivi', 3, 'LG', 'Smart Tivi LG OLED 65 inch TS65',
     29990000, 24990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Màn hình: 65 inch","Tấm nền: OLED","Độ phân giải: 4K"]}'::jsonb, 6),
    ('tu-lanh', 1, 'Samsung', 'Tủ lạnh Samsung Inverter 236 lít TS236',
     7990000, 5990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 236 lít","Kiểu tủ: 2 cửa","Công nghệ: Inverter"]}'::jsonb, 24),
    ('tu-lanh', 2, 'LG', 'Tủ lạnh LG Inverter 335 lít TS335',
     11990000, 9490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 335 lít","Kiểu tủ: Ngăn đá trên","Công nghệ: Inverter"]}'::jsonb, 21),
    ('tu-lanh', 3, 'Panasonic', 'Tủ lạnh Panasonic Inverter 417 lít TS417',
     18990000, 15490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 417 lít","Kiểu tủ: Ngăn đá dưới","Công nghệ: Inverter"]}'::jsonb, 6),
    ('may-giat', 1, 'LG', 'Máy giặt LG Inverter cửa trước 9 kg TS9',
     11990000, 8490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Khối lượng giặt: 9 kg","Kiểu cửa: Cửa trước","Động cơ: Inverter"]}'::jsonb, 24),
    ('may-giat', 2, 'Samsung', 'Máy giặt Samsung Inverter cửa trên 10 kg TS10',
     9990000, 7490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Khối lượng giặt: 10 kg","Kiểu cửa: Cửa trên","Động cơ: Inverter"]}'::jsonb, 21),
    ('may-giat', 3, 'Electrolux', 'Máy giặt Electrolux cửa trước 11 kg TS11',
     17990000, 13990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Khối lượng giặt: 11 kg","Kiểu cửa: Cửa trước","Tốc độ vắt: 1400 vòng/phút"]}'::jsonb, 6),
    ('may-lanh', 1, 'Daikin', 'Máy lạnh Daikin Inverter 1 HP TS1',
     11990000, 9490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất: 1 HP","Diện tích: Dưới 15 m²","Công nghệ: Inverter"]}'::jsonb, 24),
    ('may-lanh', 2, 'Panasonic', 'Máy lạnh Panasonic Inverter 1.5 HP TS15',
     15990000, 12990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất: 1.5 HP","Diện tích: 15–20 m²","Công nghệ: Inverter"]}'::jsonb, 9),
    ('may-lanh', 3, 'Casper', 'Máy lạnh Casper Inverter 2 HP TS2',
     13990000, 10990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất: 2 HP","Diện tích: 20–30 m²","Công nghệ: Inverter"]}'::jsonb, 6),
    ('may-say-quan-ao', 1, 'Electrolux', 'Máy sấy quần áo Electrolux thông hơi 8 kg TS8',
     10990000, 8490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Khối lượng sấy: 8 kg","Công nghệ: Thông hơi","Bảng điều khiển: Điện tử"]}'::jsonb, 24),
    ('may-say-quan-ao', 2, 'LG', 'Máy sấy quần áo LG bơm nhiệt 9 kg TS9',
     21990000, 17990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Khối lượng sấy: 9 kg","Công nghệ: Bơm nhiệt","Cảm biến: Độ ẩm"]}'::jsonb, 9),
    ('may-say-quan-ao', 3, 'Beko', 'Máy sấy quần áo Beko ngưng tụ 10 kg TS10',
     15990000, 12490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Khối lượng sấy: 10 kg","Công nghệ: Ngưng tụ","Chức năng: Hẹn giờ"]}'::jsonb, 6),
    ('tu-dong', 1, 'Sanaky', 'Tủ đông Sanaky 1 ngăn 100 lít TS100',
     4990000, 3990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 100 lít","Kiểu tủ: 1 ngăn","Nhiệt độ: Đông lạnh"]}'::jsonb, 24),
    ('tu-dong', 2, 'Alaska', 'Tủ đông Alaska 2 ngăn 250 lít TS250',
     8990000, 6990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 250 lít","Kiểu tủ: 2 ngăn","Điều khiển: Cơ"]}'::jsonb, 21),
    ('tu-dong', 3, 'Aqua', 'Tủ đông Aqua Inverter 400 lít TS400',
     13990000, 10990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 400 lít","Kiểu tủ: Nắp mở trên","Công nghệ: Inverter"]}'::jsonb, 6),
    ('noi-com-dien', 1, 'Sharp', 'Nồi cơm điện Sharp nắp gài 1.8 lít TS18',
     1090000, 790000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 1.8 lít","Loại: Nắp gài","Lòng nồi: Chống dính"]}'::jsonb, 50),
    ('noi-com-dien', 2, 'Toshiba', 'Nồi cơm điện Toshiba điện tử 1.8 lít TS18E',
     2490000, 1890000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 1.8 lít","Loại: Điện tử","Chức năng: Hẹn giờ"]}'::jsonb, 47),
    ('noi-com-dien', 3, 'Sunhouse', 'Nồi cơm điện Sunhouse cao tần 1.5 lít TS15',
     3290000, 2490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 1.5 lít","Công nghệ: Cao tần","Bảng điều khiển: Điện tử"]}'::jsonb, 44),
    ('lo-vi-song', 1, 'Sharp', 'Lò vi sóng Sharp cơ 20 lít TS20',
     1990000, 1490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 20 lít","Điều khiển: Cơ","Công suất: 700 W"]}'::jsonb, 50),
    ('lo-vi-song', 2, 'Electrolux', 'Lò vi sóng Electrolux có nướng 23 lít TS23',
     3290000, 2490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 23 lít","Chức năng: Vi sóng và nướng","Điều khiển: Điện tử"]}'::jsonb, 47),
    ('lo-vi-song', 3, 'Panasonic', 'Lò vi sóng Panasonic Inverter 25 lít TS25',
     5290000, 4190000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 25 lít","Công nghệ: Inverter","Chức năng: Rã đông"]}'::jsonb, 18),
    ('noi-chien-khong-dau', 1, 'Philips', 'Nồi chiên không dầu Philips 4.1 lít TS41',
     2990000, 2190000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 4.1 lít","Công suất: 1400 W","Điều khiển: Cơ"]}'::jsonb, 50),
    ('noi-chien-khong-dau', 2, 'Lock&Lock', 'Nồi chiên không dầu Lock&Lock 5.5 lít TS55',
     3490000, 2490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 5.5 lít","Công suất: 1700 W","Điều khiển: Cảm ứng"]}'::jsonb, 47),
    ('noi-chien-khong-dau', 3, 'Sunhouse', 'Nồi chiên không dầu Sunhouse 9 lít TS9',
     4290000, 3190000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 9 lít","Công suất: 1800 W","Chức năng: Hẹn giờ"]}'::jsonb, 18),
    ('binh-dun-sieu-toc', 1, 'Philips', 'Bình đun siêu tốc Philips 1.7 lít TS17',
     990000, 749000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 1.7 lít","Công suất: 1800 W","Chức năng: Tự ngắt"]}'::jsonb, 50),
    ('binh-dun-sieu-toc', 2, 'Sunhouse', 'Bình đun siêu tốc Sunhouse inox 1.8 lít TS18',
     490000, 329000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 1.8 lít","Chất liệu: Inox","Công suất: 1500 W"]}'::jsonb, 47),
    ('binh-dun-sieu-toc', 3, 'Kangaroo', 'Bình đun siêu tốc Kangaroo thủy tinh 2 lít TS2',
     790000, 549000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 2 lít","Chất liệu: Thủy tinh","Chức năng: Tự ngắt"]}'::jsonb, 44),
    ('bep-tu', 1, 'Sunhouse', 'Bếp từ Sunhouse đơn 2000 W TS20',
     1490000, 1090000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số vùng nấu: 1","Công suất: 2000 W","Mặt bếp: Kính"]}'::jsonb, 50),
    ('bep-tu', 2, 'Kangaroo', 'Bếp từ Kangaroo đôi 3500 W TS35',
     6490000, 4990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số vùng nấu: 2","Công suất: 3500 W","Chức năng: Khóa trẻ em"]}'::jsonb, 21),
    ('bep-tu', 3, 'Electrolux', 'Bếp từ Electrolux đôi âm 4000 W TS40',
     11990000, 9490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số vùng nấu: 2","Công suất: 4000 W","Kiểu lắp: Âm"]}'::jsonb, 18),
    ('ban-ui', 1, 'Philips', 'Bàn ủi hơi nước Philips 2000 W TS20',
     1190000, 849000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất: 2000 W","Loại: Hơi nước","Mặt đế: Chống dính"]}'::jsonb, 50),
    ('ban-ui', 2, 'Panasonic', 'Bàn ủi Panasonic khô 1000 W TS10',
     590000, 399000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất: 1000 W","Loại: Khô","Điều chỉnh: Nhiệt độ"]}'::jsonb, 47),
    ('ban-ui', 3, 'Tefal', 'Bàn ủi hơi nước đứng Tefal 1800 W TS18',
     2490000, 1890000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất: 1800 W","Loại: Hơi nước đứng","Bình nước: Tháo rời"]}'::jsonb, 44),
    ('chao-chong-dinh', 1, 'Sunhouse', 'Chảo chống dính Sunhouse 24 cm TS24',
     399000, 269000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Đường kính: 24 cm","Bề mặt: Chống dính","Tay cầm: Cách nhiệt"]}'::jsonb, 50),
    ('chao-chong-dinh', 2, 'Tefal', 'Chảo chống dính Tefal 28 cm TS28',
     899000, 649000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Đường kính: 28 cm","Bề mặt: Chống dính","Đáy: Dùng bếp từ"]}'::jsonb, 47),
    ('chao-chong-dinh', 3, 'Elmich', 'Chảo chống dính Elmich sâu lòng 30 cm TS30',
     1090000, 799000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Đường kính: 30 cm","Kiểu: Sâu lòng","Đáy: Dùng bếp từ"]}'::jsonb, 44),
    ('bo-noi', 1, 'Elmich', 'Bộ nồi inox Elmich 3 món TS3',
     1890000, 1390000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số món: 3","Chất liệu: Inox","Loại bếp: Bếp từ và gas"]}'::jsonb, 50),
    ('bo-noi', 2, 'Sunhouse', 'Bộ nồi inox Sunhouse 5 món TS5',
     2490000, 1790000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số món: 5","Chất liệu: Inox","Nắp: Kính"]}'::jsonb, 47),
    ('bo-noi', 3, 'Lock&Lock', 'Bộ nồi Lock&Lock chống dính 4 món TS4',
     3290000, 2490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số món: 4","Lớp phủ: Chống dính","Tay cầm: Cách nhiệt"]}'::jsonb, 44),
    ('dao-keo-nha-bep', 1, 'Elmich', 'Bộ dao kéo nhà bếp Elmich 5 món TS5',
     990000, 699000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số món: 5","Chất liệu: Thép không gỉ","Phụ kiện: Giá đỡ"]}'::jsonb, 50),
    ('dao-keo-nha-bep', 2, 'Sunhouse', 'Bộ dao kéo nhà bếp Sunhouse 3 món TS3',
     499000, 349000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số món: 3","Chất liệu: Thép không gỉ","Tay cầm: Nhựa"]}'::jsonb, 47),
    ('dao-keo-nha-bep', 3, 'Lock&Lock', 'Bộ dao kéo nhà bếp Lock&Lock 7 món TS7',
     1490000, 1090000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số món: 7","Chất liệu: Thép không gỉ","Phụ kiện: Hộp đựng"]}'::jsonb, 44),
    ('hop-thuc-pham', 1, 'Lock&Lock', 'Bộ hộp thực phẩm Lock&Lock thủy tinh 3 hộp TS3',
     790000, 549000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số hộp: 3","Chất liệu: Thủy tinh","Nắp: Khóa kín"]}'::jsonb, 50),
    ('hop-thuc-pham', 2, 'Elmich', 'Bộ hộp thực phẩm Elmich nhựa 5 hộp TS5',
     590000, 399000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số hộp: 5","Chất liệu: Nhựa dùng cho thực phẩm","Kiểu: Xếp chồng"]}'::jsonb, 47),
    ('hop-thuc-pham', 3, 'Glasslock', 'Bộ hộp thực phẩm Glasslock thủy tinh 4 hộp TS4',
     1190000, 849000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số hộp: 4","Chất liệu: Thủy tinh","Nắp: Gioăng kín"]}'::jsonb, 44),
    ('tai-nghe', 1, 'Sony', 'Tai nghe Bluetooth Sony chụp tai TS1',
     2490000, 1890000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Kiểu: Chụp tai","Kết nối: Bluetooth","Micro: Có"]}'::jsonb, 50),
    ('tai-nghe', 2, 'Samsung', 'Tai nghe Bluetooth Samsung True Wireless TS2',
     3290000, 2490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Kiểu: True Wireless","Hộp sạc: Có","Điều khiển: Cảm ứng"]}'::jsonb, 47),
    ('tai-nghe', 3, 'JBL', 'Tai nghe Bluetooth JBL chống ồn TS3',
     1990000, 1490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Kiểu: Nhét tai","Chức năng: Chống ồn","Kết nối: Bluetooth"]}'::jsonb, 44),
    ('pin-sac-du-phong', 1, 'Anker', 'Pin sạc dự phòng Anker 10000 mAh TS10',
     990000, 749000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung lượng: 10000 mAh","Công suất ra: 20 W","Cổng: USB-C"]}'::jsonb, 50),
    ('pin-sac-du-phong', 2, 'Xiaomi', 'Pin sạc dự phòng Xiaomi 20000 mAh TS20',
     890000, 649000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung lượng: 20000 mAh","Công suất ra: 22.5 W","Cổng: USB-A, USB-C"]}'::jsonb, 47),
    ('pin-sac-du-phong', 3, 'Baseus', 'Pin sạc dự phòng Baseus 30000 mAh TS30',
     1290000, 949000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung lượng: 30000 mAh","Công suất ra: 30 W","Hiển thị: Mức pin"]}'::jsonb, 44),
    ('cap-sac', 1, 'Anker', 'Cáp sạc Anker USB-C sang USB-C 1 m TS1',
     399000, 279000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Chiều dài: 1 m","Đầu nối: USB-C / USB-C","Công suất: 60 W"]}'::jsonb, 50),
    ('cap-sac', 2, 'Baseus', 'Cáp sạc Baseus USB-C sang Lightning 2 m TS2',
     349000, 249000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Chiều dài: 2 m","Đầu nối: USB-C / Lightning","Vỏ: Bện sợi"]}'::jsonb, 47),
    ('cap-sac', 3, 'Belkin', 'Cáp sạc Belkin USB-C 100 W 2 m TS3',
     599000, 449000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Chiều dài: 2 m","Đầu nối: USB-C / USB-C","Công suất: 100 W"]}'::jsonb, 44),
    ('may-loc-nuoc', 1, 'Karofi', 'Máy lọc nước Karofi RO 10 lõi TS10',
     6990000, 4990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công nghệ: RO","Số lõi: 10","Kiểu: Tủ đứng"]}'::jsonb, 24),
    ('may-loc-nuoc', 2, 'Kangaroo', 'Máy lọc nước Kangaroo RO nóng lạnh TS11',
     9990000, 7490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công nghệ: RO","Chức năng: Nóng lạnh","Số lõi: 11"]}'::jsonb, 21),
    ('may-loc-nuoc', 3, 'Sunhouse', 'Máy lọc nước Sunhouse RO 9 lõi TS9',
     5990000, 4490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công nghệ: RO","Số lõi: 9","Kiểu: Tủ đứng"]}'::jsonb, 18),
    ('cay-nuoc-nong-lanh', 1, 'Kangaroo', 'Cây nước nóng lạnh Kangaroo bình trên TS1',
     2990000, 2190000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Kiểu bình: Bình trên","Chế độ: Nóng lạnh","Khóa nước nóng: Có"]}'::jsonb, 50),
    ('cay-nuoc-nong-lanh', 2, 'Sunhouse', 'Cây nước nóng lạnh Sunhouse bình dưới TS2',
     4990000, 3690000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Kiểu bình: Bình dưới","Chế độ: Nóng lạnh","Điều khiển: Nút nhấn"]}'::jsonb, 21),
    ('cay-nuoc-nong-lanh', 3, 'Toshiba', 'Cây nước nóng lạnh Toshiba 3 vòi TS3',
     5990000, 4490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số vòi: 3","Chế độ: Nóng, lạnh, thường","Làm lạnh: Máy nén"]}'::jsonb, 18),
    ('quat-dien', 1, 'Senko', 'Quạt điện đứng Senko 5 cánh TS5',
     790000, 549000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Loại: Quạt đứng","Số cánh: 5","Tốc độ: 3 mức"]}'::jsonb, 50),
    ('quat-dien', 2, 'Asia', 'Quạt điện lửng Asia điều khiển từ xa TS2',
     1090000, 799000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Loại: Quạt lửng","Điều khiển: Từ xa","Chức năng: Hẹn giờ"]}'::jsonb, 47),
    ('quat-dien', 3, 'Panasonic', 'Quạt điện đứng Panasonic êm ái TS3',
     2290000, 1790000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Loại: Quạt đứng","Số cánh: 3","Chức năng: Đảo gió"]}'::jsonb, 44),
    ('quat-dieu-hoa', 1, 'Sunhouse', 'Quạt điều hòa Sunhouse bình nước 20 lít TS20',
     3490000, 2490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Bình nước: 20 lít","Làm mát: Hơi nước","Điều khiển: Cơ"]}'::jsonb, 50),
    ('quat-dieu-hoa', 2, 'Kangaroo', 'Quạt điều hoà Kangaroo bình nước 40 lít TS40',
     4990000, 3690000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Bình nước: 40 lít","Làm mát: Hơi nước","Điều khiển: Từ xa"]}'::jsonb, 21),
    ('quat-dieu-hoa', 3, 'Daikiosan', 'Quạt điều hòa Daikiosan bình nước 60 lít TS60',
     6490000, 4990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Bình nước: 60 lít","Chức năng: Đảo gió","Điều khiển: Điện tử"]}'::jsonb, 18),
    ('quat-tran', 1, 'Panasonic', 'Quạt trần Panasonic 3 cánh TS3',
     2290000, 1790000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số cánh: 3","Điều khiển: Hộp số","Tốc độ: Nhiều mức"]}'::jsonb, 50),
    ('quat-tran', 2, 'KDK', 'Quạt trần KDK 5 cánh điều khiển từ xa TS5',
     4490000, 3490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số cánh: 5","Điều khiển: Từ xa","Chức năng: Hẹn giờ"]}'::jsonb, 21),
    ('quat-tran', 3, 'Mitsubishi Electric', 'Quạt trần Mitsubishi Electric 4 cánh TS4',
     3290000, 2490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Số cánh: 4","Động cơ: Tiết kiệm điện","Chức năng: Đảo chiều"]}'::jsonb, 44),
    ('may-hut-bui', 1, 'Electrolux', 'Máy hút bụi Electrolux dạng hộp 1800 W TS18',
     2490000, 1890000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất: 1800 W","Loại: Dạng hộp","Hộp bụi: Tháo rời"]}'::jsonb, 50),
    ('may-hut-bui', 2, 'Panasonic', 'Máy hút bụi Panasonic có dây 2000 W TS20',
     3490000, 2690000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất: 2000 W","Kết nối: Có dây","Đầu hút: Đa năng"]}'::jsonb, 47),
    ('may-hut-bui', 3, 'Samsung', 'Máy hút bụi Samsung không dây TS3',
     6990000, 5490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Loại: Không dây","Pin: Sạc lại","Bộ lọc: Nhiều lớp"]}'::jsonb, 18),
    ('robot-hut-bui', 1, 'Xiaomi', 'Robot hút bụi Xiaomi lau nhà TS1',
     5990000, 4490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Chức năng: Hút bụi và lau","Điều hướng: Cảm biến","Ứng dụng: Có"]}'::jsonb, 24),
    ('robot-hut-bui', 2, 'Dreame', 'Robot hút bụi Dreame điều hướng laser TS2',
     9990000, 7490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Điều hướng: Laser","Bản đồ: Nhiều tầng","Chức năng: Hẹn giờ"]}'::jsonb, 21),
    ('robot-hut-bui', 3, 'Ecovacs', 'Robot hút bụi Ecovacs trạm tự làm sạch TS3',
     15990000, 12490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Trạm sạc: Tự làm sạch","Chức năng: Hút lau","Điều khiển: Ứng dụng"]}'::jsonb, 6),
    ('may-loc-khong-khi', 1, 'Sharp', 'Máy lọc không khí Sharp phòng 23 m² TS23',
     2990000, 2190000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Diện tích: 23 m²","Bộ lọc: HEPA","Chế độ: Ngủ"]}'::jsonb, 50),
    ('may-loc-khong-khi', 2, 'Xiaomi', 'Máy lọc không khí Xiaomi phòng 40 m² TS40',
     4490000, 3290000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Diện tích: 40 m²","Bộ lọc: Nhiều lớp","Điều khiển: Ứng dụng"]}'::jsonb, 21),
    ('may-loc-khong-khi', 3, 'Daikin', 'Máy lọc không khí Daikin phòng 50 m² TS50',
     6990000, 5490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Diện tích: 50 m²","Cảm biến: Bụi","Chế độ: Tự động"]}'::jsonb, 18),
    ('may-hut-am', 1, 'Sharp', 'Máy hút ẩm Sharp 12 lít mỗi ngày TS12',
     5990000, 4490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất hút ẩm: 12 lít/ngày","Bình nước: Tháo rời","Chức năng: Hẹn giờ"]}'::jsonb, 24),
    ('may-hut-am', 2, 'Electrolux', 'Máy hút ẩm Electrolux 20 lít mỗi ngày TS20',
     7990000, 5990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất hút ẩm: 20 lít/ngày","Chế độ: Tự động","Xả nước: Liên tục"]}'::jsonb, 21),
    ('may-hut-am', 3, 'Kosmen', 'Máy hút ẩm Kosmen 30 lít mỗi ngày TS30',
     9990000, 7490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất hút ẩm: 30 lít/ngày","Điều khiển: Điện tử","Chức năng: Sấy đồ"]}'::jsonb, 18),
    ('may-xay-sinh-to', 1, 'Philips', 'Máy xay sinh tố Philips 1.5 lít TS15',
     1490000, 1090000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 1.5 lít","Công suất: 600 W","Cối: Nhựa"]}'::jsonb, 50),
    ('may-xay-sinh-to', 2, 'Panasonic', 'Máy xay sinh tố Panasonic đa năng TS2',
     2290000, 1690000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất: 800 W","Số cối: 3","Chức năng: Xay khô và ướt"]}'::jsonb, 47),
    ('may-xay-sinh-to', 3, 'Sunhouse', 'Máy xay sinh tố Sunhouse cối thủy tinh TS3',
     1190000, 849000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Dung tích: 1.5 lít","Cối: Thủy tinh","Lưỡi dao: Inox"]}'::jsonb, 44),
    ('may-ep-trai-cay', 1, 'Philips', 'Máy ép trái cây Philips ly tâm TS1',
     2490000, 1890000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công nghệ: Ly tâm","Công suất: 500 W","Hộp bã: Tháo rời"]}'::jsonb, 50),
    ('may-ep-trai-cay', 2, 'Panasonic', 'Máy ép trái cây Panasonic ép chậm TS2',
     4490000, 3290000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công nghệ: Ép chậm","Chức năng: Tách bã","Động cơ: Êm"]}'::jsonb, 21),
    ('may-ep-trai-cay', 3, 'Kuvings', 'Máy ép trái cây Kuvings miệng rộng TS3',
     7990000, 5990000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công nghệ: Ép chậm","Miệng tiếp nguyên liệu: Rộng","Chức năng: Chống nhỏ giọt"]}'::jsonb, 18),
    ('may-say-toc', 1, 'Panasonic', 'Máy sấy tóc Panasonic 1200 W TS12',
     590000, 399000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất: 1200 W","Tay cầm: Gấp gọn","Chế độ: 2 mức"]}'::jsonb, 50),
    ('may-say-toc', 2, 'Philips', 'Máy sấy tóc Philips 1800 W TS18',
     990000, 749000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất: 1800 W","Chức năng: Sấy mát","Đầu sấy: Tập trung"]}'::jsonb, 47),
    ('may-say-toc', 3, 'Xiaomi', 'Máy sấy tóc Xiaomi ion âm 1600 W TS16',
     1490000, 1090000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Công suất: 1600 W","Chức năng: Ion âm","Điều khiển: Nhiệt độ"]}'::jsonb, 44),
    ('loa', 1, 'JBL', 'Loa Bluetooth JBL di động TS1',
     2990000, 2190000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Kết nối: Bluetooth","Pin: Sạc lại","Thiết kế: Di động"]}'::jsonb, 50),
    ('loa', 2, 'Sony', 'Loa Bluetooth Sony chống nước TS2',
     4490000, 3290000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Kết nối: Bluetooth","Tính năng: Chống nước","Micro: Có"]}'::jsonb, 21),
    ('loa', 3, 'LG', 'Loa Bluetooth LG karaoke TS3',
     6990000, 5490000, '{"note":"Thông số mô phỏng cho dữ liệu mẫu, không phải thông số cam kết của nhà sản xuất.","details":["Kết nối: Bluetooth","Tính năng: Karaoke","Đèn: LED"]}'::jsonb, 18);

CREATE TEMP TABLE _catalog05_product_keys ON COMMIT DROP AS
SELECT seed.*,
       'CAT05-' || upper(replace(seed.category_slug, '-', '')) || '-' || lpad(seed.variant::text, 3, '0') AS sku,
       'catalog05-' || seed.category_slug || '-' || lpad(seed.variant::text, 2, '0') AS slug
FROM pg_temp._catalog05_products seed;

DO $product_conflicts$
BEGIN
    IF EXISTS (
        SELECT 1 FROM public.products product
        JOIN pg_temp._catalog05_product_keys seed ON product.sku = seed.sku OR product.slug = seed.slug
        WHERE product.sku <> seed.sku OR product.slug <> seed.slug
    ) THEN
        RAISE EXCEPTION 'SKU/slug CAT05 trung voi san pham khac. Khong ghi de du lieu hien co.';
    END IF;
END;
$product_conflicts$;

CREATE TEMP TABLE _catalog05_created_products (id BIGINT PRIMARY KEY) ON COMMIT DROP;
WITH inserted AS (
    INSERT INTO public.products
        (name, slug, sku, short_description, description, specifications,
         original_price, price, discount_price, main_image_url, category_id, brand_id,
         active, featured, favorite_count, created_at)
    SELECT seed.name, seed.slug, seed.sku,
           seed.name || '. Sản phẩm mẫu để trải nghiệm website TECHSEVEN.',
           'Dữ liệu minh họa thuộc danh mục ' || category.name ||
             '. Giá, mã TS và thông số được mô phỏng để kiểm thử tìm kiếm, lọc giá, giỏ hàng và checkout. ' ||
             'Ảnh là minh họa chung của danh mục, không phải ảnh cam kết của từng model.',
           jsonb_pretty(seed.specs), seed.original_price, seed.selling_price,
           CASE WHEN seed.selling_price < seed.original_price THEN seed.selling_price ELSE NULL END,
           seed_category.image_url, category.id, brand.id, TRUE, seed.variant = 1, 0,
           CURRENT_TIMESTAMP - (seed.variant - 1) * INTERVAL '1 day'
    FROM pg_temp._catalog05_product_keys seed
    JOIN pg_temp._catalog05_categories seed_category ON seed_category.slug = seed.category_slug
    JOIN public.categories category ON category.slug = seed.category_slug
    JOIN public.brands brand ON brand.name = seed.brand_name
    ON CONFLICT DO NOTHING
    RETURNING id
)
INSERT INTO pg_temp._catalog05_created_products (id) SELECT id FROM inserted;

-- Gallery chi them cho san pham vua tao; khong chen lai anh da bi admin xoa.
INSERT INTO public.product_imagines (product_id, image_url)
SELECT product.id, product.main_image_url
FROM public.products product
JOIN pg_temp._catalog05_created_products created ON created.id = product.id;

-- Neu chua co branch active, tao 2 branch mau de catalog co the checkout.
-- Giu nguyen cac branch dang inactive; khong tu mo lai branch cu.
INSERT INTO public.branches (name, address, province, phone, active)
SELECT seed.name, seed.address, 'Thành phố Hồ Chí Minh', seed.phone, TRUE
FROM (VALUES
    ('CAT05 - Chi nhánh Quận 1', '123 Lê Lợi, Quận 1, TP.HCM', '02800000501'),
    ('CAT05 - Chi nhánh Bình Thạnh', '456 Điện Biên Phủ, Bình Thạnh, TP.HCM', '02800000502')
) seed(name, address, phone)
WHERE NOT EXISTS (SELECT 1 FROM public.branches WHERE active = TRUE)
  AND NOT EXISTS (SELECT 1 FROM public.branches branch WHERE branch.name = seed.name);

DO $active_branches$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.branches WHERE active = TRUE) THEN
        RAISE EXCEPTION 'Khong co branch active. Kiem tra branch CAT05 da co nhung dang inactive.';
    END IF;
END;
$active_branches$;

INSERT INTO public.branch_inventory
    (branch_id, product_id, stock_quantity, reserved_quantity, available_quantity, updated_at)
SELECT branch.id, product.id, seed.initial_stock, 0, seed.initial_stock, CURRENT_TIMESTAMP
FROM public.branches branch
CROSS JOIN pg_temp._catalog05_product_keys seed
JOIN public.products product ON product.sku = seed.sku
WHERE branch.active = TRUE
ON CONFLICT (branch_id, product_id) DO NOTHING;

-- Bang tong ket theo category. Cot tao_moi = 0 khi chay lai hoac da co du lieu.
SELECT category.name AS category, category.slug, category.active,
       count(DISTINCT product.id) AS catalog05_products,
       count(DISTINCT created.id) AS created_this_run,
       min(coalesce(product.discount_price, product.price, product.original_price)) AS min_price,
       max(coalesce(product.discount_price, product.price, product.original_price)) AS max_price
FROM pg_temp._catalog05_categories seed_category
JOIN public.categories category ON category.slug = seed_category.slug
JOIN public.products product ON product.category_id = category.id
JOIN pg_temp._catalog05_product_keys seed ON seed.sku = product.sku
LEFT JOIN pg_temp._catalog05_created_products created ON created.id = product.id
GROUP BY category.id, category.name, category.slug, category.active
ORDER BY category.name;

SELECT (SELECT count(*) FROM pg_temp._catalog05_categories) AS expected_categories,
       (SELECT count(*) FROM pg_temp._catalog05_product_keys) AS expected_products,
       (SELECT count(*) FROM pg_temp._catalog05_created_products) AS created_this_run,
       (SELECT count(*) FROM public.branches WHERE active = TRUE) AS active_branches;

COMMIT;
