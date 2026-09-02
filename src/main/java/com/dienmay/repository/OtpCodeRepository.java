package com.dienmay.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.dienmay.entity.OtpCode;

@Repository
public interface OtpCodeRepository extends JpaRepository<OtpCode, Long> {
    // Lấy mã OTP mới nhất chưa sử dụng của email theo loại (REGISTER)
    Optional<OtpCode> findTopByEmailAndTypeAndUsedFalseOrderByCreatedAtDesc(String email, String type);
}