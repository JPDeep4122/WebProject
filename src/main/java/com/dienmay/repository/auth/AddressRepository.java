package com.dienmay.repository.auth;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.dienmay.entity.auth.Address;

@Repository
public interface AddressRepository extends JpaRepository<Address, Long> {
    List<Address> findByUser_Id(Long userId);
    Optional<Address> findByUser_IdAndIsDefaultTrue(Long userId);
}