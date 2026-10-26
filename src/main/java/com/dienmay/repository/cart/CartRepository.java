package com.dienmay.repository.cart;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.dienmay.entity.cart.Cart;

@Repository
public interface CartRepository extends JpaRepository<Cart, Long> {
    Optional<Cart> findByUser_Email(String email);
    Optional<Cart> findBySessionId(String sessionId);
}