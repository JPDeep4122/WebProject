package com.dienmay.dto.auth;


import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class JwtResponse {
	
	private String token;
	@Builder.Default
	private String type = "Bearer";
	private Long id;
	private String email;
	private String fullName;
	private List<String> roles;
}
