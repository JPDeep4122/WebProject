package com.dienmay.repository.promotion;
import com.dienmay.entity.promotion.Promotion;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
public interface PromotionRepository extends JpaRepository<Promotion,Long> {
    Optional<Promotion> findByCodeIgnoreCase(String code);
    boolean existsByCodeIgnoreCase(String code);
}
