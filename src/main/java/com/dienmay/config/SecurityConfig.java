package com.dienmay.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {
    @Bean
    public SecurityFilterChain securityFilterChain(
        HttpSecurity http
    ) throws Exception {
        http
        .csrf(csrf -> csrf.disable())
        .sessionManagement(session ->
            session.sessionCreationPolicy(
                SessionCreationPolicy.STATELESS
            )
        )

        .authorizeHttpRequests(auth -> auth
            .requestMatchers (
                "/api/auth/**"
            ).permitAll()

            .requestMatchers(
                HttpMethod.GET,
                "/api/products/**"
            ).permitAll()

            .requestMatchers(
                HttpMethod.GET,
                "/api/categories/**"
            ).permitAll()

            .requestMatchers(
                "/api/admin/**"
            ).hasRole("ADMIN")

            .requestMatchers(
                "/api/employee/**"
            ).hasAnyRole(
                "ADMIN",
                "EMPLOYEE"
            )

            .requestMatchers(
                "/api/orders/**"
            ).hasRole("CUSTOMER")

            .requestMatchers(
                "/api/cart/**"
            ).hasRole("CUSTOMER")

            .requestMatchers(
                "/api/account/**"
            )

            .authenticated()
        )

        .oauth2ResourceServer(oauth2 -> 
            oauth2.jwt(jwt ->{})
        );
        return http.build();
    }
    
}
