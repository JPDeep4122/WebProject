package com.dienmay.repository.auth;

import java.util.Optional;
import java.util.List;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.EntityGraph;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.repository.query.Param;
import jakarta.persistence.LockModeType;

import com.dienmay.entity.auth.User;

@Repository
public interface UserRepository extends JpaRepository<User, Long>{
	boolean existsByEmail(String email);
	Optional<User> findByEmail(String email);
	List<User> findByRoles_Name(String roleName, Sort sort);

	@EntityGraph(attributePaths = {"branch", "roles"})
	List<User> findDistinctByRoles_NameAndActiveTrueOrderByFullNameAsc(String roleName);

	@Query("select count(distinct u.id) from User u join u.roles r where upper(r.name) = 'CUSTOMER'")
	long countCustomers();
	
	Optional<User> findByGoogleSub(String googleSub);

	boolean existsByEmailIgnoreCase(String email);
	
	Optional<User> findByEmailIgnoreCase(String email);
	
	Optional<User> findByFirebasePhoneUid(String firebasePhoneUid);

	boolean existsByVerifiedPhoneNumberOrFirebasePhoneUid(
	        String verifiedPhoneNumber,
	        String firebasePhoneUid);

	@Lock(LockModeType.PESSIMISTIC_WRITE)
	@Query("select u from User u where u.email = :email")
	Optional<User> findForPhoneLink(@Param("email") String email);
	
	@Lock(LockModeType.PESSIMISTIC_WRITE)
	@Query("select u from User u where u.email = :email")
	Optional<User> findForOtp(@Param("email") String email);

	@Lock(LockModeType.PESSIMISTIC_WRITE)
	@Query("select u from User u where u.email = :email")
	Optional<User> findForCart(@Param("email") String email);
}
