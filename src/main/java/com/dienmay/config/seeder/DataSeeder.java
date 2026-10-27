package com.dienmay.config.seeder;

import java.math.BigDecimal;
import java.util.List;
import java.text.Normalizer;
import java.util.Locale;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.core.annotation.Order;

import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.branch.BranchInventory;
import com.dienmay.entity.product.Brand;
import com.dienmay.entity.product.Category;
import com.dienmay.entity.product.Product;
import com.dienmay.repository.branch.BranchInventoryRepository;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.repository.product.BrandRepository;
import com.dienmay.repository.product.CategoryRepository;
import com.dienmay.repository.product.ProductRepository;

@Component
@Order(0)
public class DataSeeder implements CommandLineRunner {

	@Autowired
	private CategoryRepository categoryRepo;
	@Autowired
	private BrandRepository brandRepo;
	@Autowired
	private BranchRepository branchRepo;
	@Autowired
	private ProductRepository productRepo;
	@Autowired
	private BranchInventoryRepository branchInventoryRepo;

	@Override
	public void run(String... args) throws Exception {
		if (productRepo.count() > 0) {
			branchRepo.findAll().stream().filter(branch -> branch.getProvince() == null && branch.getAddress() != null
					&& branch.getAddress().toLowerCase().contains("tp.hcm")).forEach(branch -> {
						branch.setProvince("Thành phố Hồ Chí Minh");
						branchRepo.save(branch);
					});
			// Nếu đã có sản phẩm nhưng chưa nạp tồn kho chi nhánh thì tự động nạp bổ sung
			if (branchInventoryRepo.count() == 0) {
				seedBranchStock();
			}
			return;
		}

		System.out.println(">>> DANG KHOI TAO DU LIEU MAU CHO DIEN MAY SHOP...");

		// 1. Tạo Chi nhánh
		Branch b1 = findOrCreateBranch("Chi nhánh Quận 1", "123 Lê Lợi, Bến Nghé, Q1, TP.HCM", "02838221122");
		Branch b2 = findOrCreateBranch("Chi nhánh Bình Thạnh", "456 Điện Biên Phủ, P25, Bình Thạnh, TP.HCM", "02838992233");

		// 2. Tạo Danh mục
		Category catTivi = categoryRepo.save(Category.builder().name("Tivi").slug("tivi").icon("bi-tv").build());
		Category catTuLanh = categoryRepo
				.save(Category.builder().name("Tủ lạnh").slug("tu-lanh").icon("bi-snow2").build());
		Category catMayGiat = categoryRepo
				.save(Category.builder().name("Máy giặt").slug("may-giat").icon("bi-water").build());
		Category catMayLanh = categoryRepo
				.save(Category.builder().name("Máy lạnh").slug("may-lanh").icon("bi-wind").build());

		// 3. Tạo Thương hiệu
		Brand brandSony = brandRepo.save(Brand.builder().name("Sony").build());
		Brand brandSamsung = brandRepo.save(Brand.builder().name("Samsung").build());
		Brand brandLG = brandRepo.save(Brand.builder().name("LG").build());
		Brand brandPanasonic = brandRepo.save(Brand.builder().name("Panasonic").build());

		// 4. Tạo Sản phẩm
		productRepo.save(Product.builder().name("Google Tivi Sony 4K 55 inch KD-55X77L")
				.slug("google-tivi-sony-4k-55-inch-kd-55x77l").sku("TV-SONY-55X77L")
				.shortDescription("Độ phân giải 4K sắc nét, bộ xử lý X1 4K HDR, âm thanh vòm sống động.")
				.description(
						"Google Tivi Sony 4K 55 inch KD-55X77L sở hữu thiết kế viền mỏng thanh lịch, màn hình 55 inch rộng rãi. Bộ xử lý 4K X1 tái tạo hình ảnh chi tiết, màu sắc chân thực. Âm thanh vòm Dolby Audio mang đến trải nghiệm sống động như ở rạp chiếu phim.")
				.originalPrice(new BigDecimal("15900000")).discountPrice(new BigDecimal("12490000"))
				.mainImageUrl(
						"https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=600&q=80")
				.category(catTivi).brand(brandSony).featured(true).build());

		productRepo.save(Product.builder().name("Smart Tivi Samsung Crystal UHD 4K 65 inch 65CU8000")
				.slug("smart-tivi-samsung-crystal-uhd-4k-65-inch-65cu8000").sku("TV-SAM-65CU8000")
				.shortDescription("Thiết kế mỏng thanh lịch AirSlim, công nghệ Dynamic Crystal Color rực rỡ.")
				.description(
						"Smart Tivi Samsung 65 inch sở hữu độ phân giải chuẩn 4K, công nghệ màu sắc Dynamic Crystal Color với hơn 1 tỷ sắc màu, âm thanh OTS Lite chuyển động theo hình ảnh cuốn hút.")
				.originalPrice(new BigDecimal("18900000")).discountPrice(new BigDecimal("13990000"))
				.mainImageUrl(
						"https://images.unsplash.com/photo-1461151304267-38535e780c79?auto=format&fit=crop&w=600&q=80")
				.category(catTivi).brand(brandSamsung).featured(true).build());

		productRepo.save(Product.builder().name("Tủ Lạnh Samsung Inverter 236 Lít RT22FARBDSA")
				.slug("tu-lanh-samsung-inverter-236-lit-rt22farbdsa").sku("TL-SAM-236L")
				.shortDescription("Làm lạnh đa chiều, công nghệ Digital Inverter tiết kiệm điện tối đa.")
				.description(
						"Tủ lạnh 2 cánh Samsung Inverter 236 lít nhỏ gọn, ngăn đông mềm lưu trữ thực phẩm tươi ngon không cần rã đông, luồng khí lạnh đa chiều All Around Cooling giữ ẩm tối ưu.")
				.originalPrice(new BigDecimal("7900000")).discountPrice(new BigDecimal("5890000"))
				.mainImageUrl(
						"https://images.unsplash.com/photo-1584568694244-14fbdf83bd30?auto=format&fit=crop&w=600&q=80")
				.category(catTuLanh).brand(brandSamsung).featured(true).build());

		productRepo.save(Product.builder().name("Tủ Lạnh LG Inverter 335 Lít GN-M332PS")
				.slug("tu-lanh-lg-inverter-335-lit-gn-m332ps").sku("TL-LG-335L")
				.shortDescription("DoorCooling+ làm lạnh từ cánh cửa tủ, ngăn rau củ giữ ẩm tối ưu.")
				.description(
						"Công nghệ Linear Inverter bền bỉ, tiết kiệm điện năng. Hệ thống làm lạnh từ cửa tủ DoorCooling+ giúp đồ uống để ở cánh cửa luôn mát lạnh nhanh hơn.")
				.originalPrice(new BigDecimal("10500000")).discountPrice(new BigDecimal("8490000"))
				.mainImageUrl(
						"https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=600&q=80")
				.category(catTuLanh).brand(brandLG).featured(true).build());

		productRepo.save(Product.builder().name("Máy Giặt Cửa Trước LG AI DD Inverter 9 Kg FV1409S4W")
				.slug("may-giat-lg-ai-dd-inverter-9-kg-fv1409s4w").sku("MG-LG-9KG")
				.shortDescription("Trí tuệ nhân tạo AI DD bảo vệ sợi vải, giặt hơi nước Steam diệt khuẩn 99.9%.")
				.description(
						"Máy giặt cửa trước hiện đại, động cơ truyền động trực tiếp êm ái, công nghệ AI tự nhận diện độ mềm của vải để tối ưu chuyển động giặt giúp quần áo luôn bền đẹp.")
				.originalPrice(new BigDecimal("11900000")).discountPrice(new BigDecimal("7990000"))
				.mainImageUrl(
						"https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=600&q=80")
				.category(catMayGiat).brand(brandLG).featured(true).build());

		productRepo.save(Product.builder().name("Máy Giặt Cửa Trên Panasonic Inverter 10 Kg NA-FD10VR1BV")
				.slug("may-giat-panasonic-inverter-10-kg-na-fd10vr1bv").sku("MG-PANA-10KG")
				.shortDescription("Xoáy nước Water Bazooka siêu mạnh, giặt nước nóng StainMaster+.")
				.description(
						"Máy giặt cửa trên công suất lớn 10kg phù hợp cho gia đình đông người, tính năng giặt nước nóng diệt khuẩn và công nghệ bọt mịn Active Foam đánh tan mọi vết bẩn cứng đầu.")
				.originalPrice(new BigDecimal("12500000")).discountPrice(new BigDecimal("9690000"))
				.mainImageUrl(
						"https://images.unsplash.com/photo-1545173168-9f1947eebb7f?auto=format&fit=crop&w=600&q=80")
				.category(catMayGiat).brand(brandPanasonic).featured(true).build());

		productRepo.save(Product.builder().name("Máy Lạnh Panasonic Inverter 1 HP CU/CS-PU9XKH-8M")
				.slug("may-lanh-panasonic-inverter-1-hp-cu-cs-pu9xkh-8m").sku("ML-PANA-1HP")
				.shortDescription("Làm lạnh nhanh Powerful, công nghệ Nanoe-G lọc sạch bụi mịn PM2.5.")
				.description(
						"Máy lạnh 1 chiều công suất 1 ngựa tiết kiệm điện, công nghệ lọc không khí độc quyền Nanoe-G kháng khuẩn, khử mùi hiệu quả bảo vệ sức khỏe cả gia đình.")
				.originalPrice(new BigDecimal("11400000")).discountPrice(new BigDecimal("9190000"))
				.mainImageUrl(
						"https://images.unsplash.com/photo-1614633833026-07205c483a9d?auto=format&fit=crop&w=600&q=80")
				.category(catMayLanh).brand(brandPanasonic).featured(true).build());

		// 5. Nạp tồn kho chi nhánh
		seedBranchStock();

		System.out.println(">>> DA KHOI TAO XONG DU LIEU MAU KEM TON KHO CHI NHANH!");
	}

	private Branch findOrCreateBranch(String name, String address, String phone) {
		String normalizedName = normalizeBranchName(name);
		return branchRepo.findAll().stream()
				.filter(branch -> normalizeBranchName(branch.getName()).equals(normalizedName))
				.findFirst()
				.orElseGet(() -> branchRepo.save(Branch.builder().name(name).address(address)
						.province("Thành phố Hồ Chí Minh").phone(phone).build()));
	}

	private String normalizeBranchName(String value) {
		String decomposed = Normalizer.normalize(value == null ? "" : value, Normalizer.Form.NFD)
				.replaceAll("\\p{M}", "").replace('đ', 'd').replace('Đ', 'd');
		return decomposed.trim().replaceAll("\\s+", " ").toLowerCase(Locale.ROOT);
	}

	private void seedBranchStock() {
	    List<Branch> branches = branchRepo.findAll();
	    List<Product> products = productRepo.findAll();

	    for (int index = 0; index < Math.min(2, branches.size()); index++) {
	        Branch branch = branches.get(index);
	        int quantity = index == 0 ? 5 : 3;

	        for (Product product : products) {
	            boolean exists = branchInventoryRepo
	                    .findByBranchIdAndProductId(
	                            branch.getId(), product.getId())
	                    .isPresent();

	            if (!exists) {
	                branchInventoryRepo.save(
	                        BranchInventory.builder()
	                                .branch(branch)
	                                .product(product)
	                                .stockQuantity(quantity)
	                                .reservedQuantity(0)
	                                .availableQuantity(quantity)
	                                .build());
	            }
	        }
	    }
	}
}
