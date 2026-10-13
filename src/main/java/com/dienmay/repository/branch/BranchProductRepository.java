package com.dienmay.repository.branch;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.dienmay.entity.branch.BranchProduct;

@Repository
public interface BranchProductRepository extends JpaRepository<BranchProduct, Long> {

    // Lấy danh sách tồn kho của một sản phẩm tại tất cả các chi nhánh
    List<BranchProduct> findByProduct_Id(Long productId);
}