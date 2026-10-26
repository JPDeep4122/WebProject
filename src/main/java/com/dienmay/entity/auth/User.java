package com.dienmay.entity.auth;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import com.dienmay.entity.branch.Branch;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name= "users")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(nullable = false, unique = true, length = 100)
	private String email;

	@Column(name = "google_sub", unique = true, length = 255)
	private String googleSub;
	
	@Column(nullable = false)
	private String password;

	@Column(name = "full_name", nullable = false, length = 100)
	private String fullName;

	@Column(name = "phone_number", length = 20)
	private String phoneNumber;
	
	@Column(name = "verified_phone_number", unique = true, length = 20)
	private String verifiedPhoneNumber;

	@Column(name = "firebase_phone_uid", unique = true, length = 128)
	private String firebasePhoneUid;

	@Column(name = "phone_verified_at")
	private LocalDateTime phoneVerifiedAt;

	@Column(name = "is_active", nullable = false)
	@Builder.Default
	private boolean active = false; // Mặc định luôn false, nhập đúng OTP thành true

	@ManyToMany(fetch = FetchType.EAGER)
	@JoinTable(
			name = "user_roles", 
			joinColumns = @JoinColumn(name = "user_id"), 
			inverseJoinColumns = @JoinColumn(name = "role_id")
		)

	@Builder.Default
	private Set<Role> roles = new HashSet<>();

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "branch_id")
	private Branch branch;

	@Column(name = "created_at", updatable = false)
	private LocalDateTime createdAt;

	@Column(name = "updated_at")
	private LocalDateTime updatedAt;

	@PrePersist
	protected void onCreate() {
		this.createdAt = LocalDateTime.now();
		this.updatedAt = LocalDateTime.now();
	}
	
	@PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
