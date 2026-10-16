package com.dienmay.repository.auth;

import java.util.Optional;
import java.util.List;
import org.springframework.data.domain.Sort;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.dienmay.entity.auth.User;

@Repository
public interface UserRepository extends JpaRepository<User, Long>{
	boolean existsByEmail(String email);
	Optional<User> findByEmail(String email);
	List<User> findByRoles_Name(String roleName, Sort sort);
}
