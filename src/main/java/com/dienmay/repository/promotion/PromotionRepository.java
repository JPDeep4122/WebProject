package com.dienmay.repository.promotion;
import com.dienmay.entity.promotion.Promotion;
import org.springframework.data.jpa.repository.JpaRepository;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.Optional;

public interface PromotionRepository extends JpaRepository<Promotion,Long> {
    Optional<Promotion> findByCodeIgnoreCase(String code);
    boolean existsByCodeIgnoreCase(String code);
    
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from Promotion p where lower(p.code) = lower(:code)")
    Optional<Promotion> findByCodeForUpdate(@Param("code") String code);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from Promotion p where p.id = :id")
    Optional<Promotion> findByIdForUpdate(@Param("id") Long id);
}
