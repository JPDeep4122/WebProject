package com.dienmay.entity.product;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import org.hibernate.annotations.CreationTimestamp;

import com.dienmay.entity.branch.BranchProduct;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(nullable = false, length = 255)
	private String name;

	@Column(nullable = false, unique = true, length = 255)
	private String slug;

	@Column(nullable = false, unique = true, length = 50)
	private String sku;				 	// Mã sản phẩm: TV-SONY-55X80L

	@Column(columnDefinition = "NVARCHAR(MAX)")
	private String shortDescription;

	@Column(columnDefinition = "NVARCHAR(MAX)")
	private String description;

	@Column(nullable = false, precision = 18, scale = 2)
	private BigDecimal originalPrice; 	// Giá gốc niêm yết

	@Column(precision = 18, scale = 2)
	private BigDecimal discountPrice; 	// Giá khuyến mãi bán ra

	@Column(length = 500)
	private String mainImageUrl; 		// Link ảnh đại diện (Cloudinary / Web)

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "category_id")
	private Category category;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "brand_id")
	private Brand brand;

	@Builder.Default
	private boolean active = true;
	@Builder.Default
	private boolean featured = false; 	// Sản phẩm nổi bật trang chủ

	@OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
	@Builder.Default
	private List<ProductImage> images = new ArrayList<>();

	@OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
	@Builder.Default
	private List<BranchProduct> branchProducts = new ArrayList<>();
	
	@Column(name = "price", precision = 18, scale = 2)
    private BigDecimal price; 			// Giá bán hiện tại
	
	 @Column(name = "sold_quantity")
	 @Builder.Default
	 private Integer soldQuantity = 0; 	// Số lượng đã bán (Tab Bán chạy)

	 @Column(name = "rating")
	 @Builder.Default
	 private Double rating = 0.0;		// Điểm đánh giá trung bình từ 1 - 5
	 
	 @Column(name = "favorite_count")
	 @Builder.Default
	 private Integer favoriteCount = 0; // Lượt yêu thích (Tab Yêu thích)
	 
	 @CreationTimestamp
	 @Column(name = "created_at", updatable = false)
	 private LocalDateTime createdAt; // Ngày tạo (Tab Mới nhất)
}
