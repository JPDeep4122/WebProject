package com.dienmay.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {
	
	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();			//Mã hóa mật khẩu chuẩn bảo mật cao
	}

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // Tắt CSRF để tiện test API
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**", "/api/test/**", "/**").permitAll() // Mở toàn quyền cho các đường dẫn test
                .anyRequest().authenticated()
            );
        return http.build();
    }
}