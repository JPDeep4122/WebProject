package com.dienmay.config;

import java.math.BigDecimal;
import java.util.Arrays;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.dienmay.entity.*;
import com.dienmay.repository.*;

@Component
public class DataSeeder implements CommandLineRunner {

    @Autowired private CategoryRepository categoryRepo;
    @Autowired private BrandRepository brandRepo;
    @Autowired private BranchRepository branchRepo;
    @Autowired private ProductRepository productRepo;

    @Override
    public void run(String... args) throws Exception {
        if (productRepo.count() > 0) {
            return; // Đã có dữ liệu, không nạp lại
        }

        System.out.println(">>> DANG KHOI TAO DU LIEU MAU CHO DIEN MAY SHOP...");

        // 1. Tạo Chi nhánh
        Branch b1 = branchRepo.save(Branch.builder().name("Chi nhánh Quận 1").address("123 Lê Lợi, Bến Nghé, Q1, TP.HCM").phone("02838221122").build());
        Branch b2 = branchRepo.save(Branch.builder().name("Chi nhánh Bình Thạnh").address("456 Điện Biên Phủ, P25, Bình Thạnh, TP.HCM").phone("02838992233").build());

        // 2. Tạo Danh mục
        Category catTivi = categoryRepo.save(Category.builder().name("Tivi").slug("tivi").icon("bi-tv").build());
        Category catTuLanh = categoryRepo.save(Category.builder().name("Tủ lạnh").slug("tu-lanh").icon("bi-snow2").build());
        Category catMayGiat = categoryRepo.save(Category.builder().name("Máy giặt").slug("may-giat").icon("bi-water").build());
        Category catMayLanh = categoryRepo.save(Category.builder().name("Máy lạnh").slug("may-lanh").icon("bi-wind").build());

        // 3. Tạo Thương hiệu
        Brand brandSony = brandRepo.save(Brand.builder().name("Sony").build());
        Brand brandSamsung = brandRepo.save(Brand.builder().name("Samsung").build());
        Brand brandLG = brandRepo.save(Brand.builder().name("LG").build());
        Brand brandPanasonic = brandRepo.save(Brand.builder().name("Panasonic").build());

        // 4. Tạo Sản phẩm mẫu
        productRepo.save(Product.builder()
                .name("Google Tivi Sony 4K 55 inch KD-55X77L")
                .slug("google-tivi-sony-4k-55-inch-kd-55x77l")
                .sku("TV-SONY-55X77L")
                .shortDescription("Độ phân giải 4K sắc nét, bộ xử lý X1 4K HDR, âm thanh vòm sống động.")
                .originalPrice(new BigDecimal("15900000"))
                .discountPrice(new BigDecimal("12490000"))
                .mainImageUrl("https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=600&q=80")
                .category(catTivi).brand(brandSony).featured(true).build());

        productRepo.save(Product.builder()
                .name("Smart Tivi Samsung Crystal UHD 4K 65 inch 65CU8000")
                .slug("smart-tivi-samsung-crystal-uhd-4k-65-inch-65cu8000")
                .sku("TV-SAM-65CU8000")
                .shortDescription("Thiết kế mỏng thanh lịch AirSlim, công nghệ Dynamic Crystal Color rực rỡ.")
                .originalPrice(new BigDecimal("18900000"))
                .discountPrice(new BigDecimal("13990000"))
                .mainImageUrl("https://images.unsplash.com/photo-1461151304267-38535e780c79?auto=format&fit=crop&w=600&q=80")
                .category(catTivi).brand(brandSamsung).featured(true).build());

        productRepo.save(Product.builder()
                .name("Tủ Lạnh Samsung Inverter 236 Lít RT22FARBDSA")
                .slug("tu-lanh-samsung-inverter-236-lit-rt22farbdsa")
                .sku("TL-SAM-236L")
                .shortDescription("Làm lạnh đa chiều, công nghệ Digital Inverter tiết kiệm điện tối đa.")
                .originalPrice(new BigDecimal("7900000"))
                .discountPrice(new BigDecimal("5890000"))
                .mainImageUrl("https://images.unsplash.com/photo-1584568694244-14fbdf83bd30?auto=format&fit=crop&w=600&q=80")
                .category(catTuLanh).brand(brandSamsung).featured(true).build());

        productRepo.save(Product.builder()
                .name("Tủ Lạnh LG Inverter 335 Lít GN-M332PS")
                .slug("tu-lanh-lg-inverter-335-lit-gn-m332ps")
                .sku("TL-LG-335L")
                .shortDescription("DoorCooling+ làm lạnh từ cánh cửa tủ, ngăn rau củ giữ ẩm tối ưu.")
                .originalPrice(new BigDecimal("10500000"))
                .discountPrice(new BigDecimal("8490000"))
                .mainImageUrl("https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=600&q=80")
                .category(catTuLanh).brand(brandLG).featured(true).build());

        productRepo.save(Product.builder()
                .name("Máy Giặt Cửa Trước LG AI DD Inverter 9 Kg FV1409S4W")
                .slug("may-giat-lg-ai-dd-inverter-9-kg-fv1409s4w")
                .sku("MG-LG-9KG")
                .shortDescription("Trí tuệ nhân tạo AI DD bảo vệ sợi vải, giặt hơi nước Steam diệt khuẩn 99.9%.")
                .originalPrice(new BigDecimal("11900000"))
                .discountPrice(new BigDecimal("7990000"))
                .mainImageUrl("https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=600&q=80")
                .category(catMayGiat).brand(brandLG).featured(true).build());

        productRepo.save(Product.builder()
                .name("Máy Giặt Cửa Trên Panasonic Inverter 10 Kg NA-FD10VR1BV")
                .slug("may-giat-panasonic-inverter-10-kg-na-fd10vr1bv")
                .sku("MG-PANA-10KG")
                .shortDescription("Xoáy nước Water Bazooka siêu mạnh, giặt nước nóng StainMaster+ đánh bay vết bẩn.")
                .originalPrice(new BigDecimal("12500000"))
                .discountPrice(new BigDecimal("9690000"))
                .mainImageUrl("https://images.unsplash.com/photo-1545173168-9f1947eebb7f?auto=format&fit=crop&w=600&q=80")
                .category(catMayGiat).brand(brandPanasonic).featured(true).build());

        productRepo.save(Product.builder()
                .name("Máy Lạnh Panasonic Inverter 1 HP CU/CS-PU9XKH-8M")
                .slug("may-lanh-panasonic-inverter-1-hp-cu-cs-pu9xkh-8m")
                .sku("ML-PANA-1HP")
                .shortDescription("Làm lạnh nhanh Powerful, công nghệ Nanoe-G lọc sạch bụi mịn PM2.5.")
                .originalPrice(new BigDecimal("11400000"))
                .discountPrice(new BigDecimal("9190000"))
                .mainImageUrl("https://images.unsplash.com/photo-1614633833026-07205c483a9d?auto=format&fit=crop&w=600&q=80")
                .category(catMayLanh).brand(brandPanasonic).featured(true).build());

        System.out.println(">>> DA KHOI TAO XONG DU LIEU DIEN MAY!");
    }
}