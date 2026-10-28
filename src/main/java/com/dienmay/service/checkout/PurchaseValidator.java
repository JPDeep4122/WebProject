package com.dienmay.service.checkout;

import org.springframework.stereotype.Component;

import com.dienmay.entity.product.Product;
import com.dienmay.repository.branch.BranchInventoryRepository;
import com.dienmay.repository.product.ProductRepository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class PurchaseValidator {

    private final ProductRepository products;
    private final BranchInventoryRepository inventories;

    @PersistenceContext
    private EntityManager entityManager;

    public void requireQuantity(Integer quantity) {
        if (quantity == null || quantity < 1) {
            throw new IllegalArgumentException(
                    "Số lượng phải lớn hơn hoặc bằng 1.");
        }
    }

    public Product requireProduct(Long productId, Integer quantity) {
        requireQuantity(quantity);

        if (productId == null || productId <= 0) {
            throw new IllegalArgumentException(
                    "Sản phẩm không hợp lệ.");
        }

        Product product = products.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Không tìm thấy sản phẩm."));

        entityManager.refresh(product);

        if (!product.isActive()) {
            throw new IllegalArgumentException(
                    "Sản phẩm đã ngừng kinh doanh.");
        }

        if (product.getSellingPrice() == null
                || product.getSellingPrice().signum() < 0) {
            throw new IllegalArgumentException(
                    "Sản phẩm chưa có giá bán hợp lệ.");
        }

        return product;
    }

    public void requireTotalStock(Long productId, int quantity) {
        requireQuantity(quantity);

        if (quantity > inventories.totalAvailable(productId)) {
            throw new IllegalArgumentException(
                    "Số lượng yêu cầu vượt quá tồn kho hiện tại.");
        }
    }

    public void requireBranchStock(
            Long branchId, Long productId, int quantity) {

        requireQuantity(quantity);

        var inventory = inventories.findForUpdate(branchId, productId)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Chi nhánh giao hàng chưa có sản phẩm này."));

        entityManager.refresh(inventory);

        long available =
                (long) inventory.getStockQuantity()
                - inventory.getReservedQuantity();

        if (quantity > Math.max(0L, available)) {
            throw new IllegalArgumentException(
                    "Chi nhánh giao hàng không đủ số lượng sản phẩm.");
        }

        int newReserved = Math.addExact(inventory.getReservedQuantity(), quantity);
        inventory.setReservedQuantity(newReserved);
        inventory.setAvailableQuantity(inventory.getStockQuantity() - newReserved);
    }
}