package com.dienmay.repository.auth;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.dienmay.entity.auth.OtpCode;

import jakarta.persistence.LockModeType;

@Repository
public interface OtpCodeRepository extends JpaRepository<OtpCode, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<OtpCode> findTopByEmailAndTypeOrderByIdDesc(
            String email,
            String type);

    long countByEmailAndCreatedAtAfter(
            String email,
            LocalDateTime threshold);

    @Modifying
    @Query("""
            update OtpCode o
            set o.used = true
            where o.email = :email
              and o.type = :type
              and o.used = false
            """)
    int invalidateUnused(
            @Param("email") String email,
            @Param("type") String type);
}