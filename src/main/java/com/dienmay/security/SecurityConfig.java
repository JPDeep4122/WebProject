package com.dienmay.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.Http403ForbiddenEntryPoint;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.csrf.CsrfTokenRequestAttributeHandler;

import com.dienmay.security.jwt.AuthTokenFilter;

@Configuration
public class SecurityConfig {

	@Autowired
	private UserDetailsService userDetailsService; // Dùng Interface chuẩn của Spring Security

	@Bean
	public AuthTokenFilter authenticationJwtTokenFilter() {
		return new AuthTokenFilter();
	}

	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}

	@Bean
	public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
		return authConfig.getAuthenticationManager();
	}

	@Bean
	public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

		CsrfTokenRequestAttributeHandler csrfHandler = new CsrfTokenRequestAttributeHandler();

		csrfHandler.setCsrfRequestAttributeName(null);
		http
				// Store the double-submit CSRF token in a browser cookie so POST requests
				// remain valid when Vercel routes them to a different container instance.
				.csrf(csrf -> csrf.csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
						.csrfTokenRequestHandler(csrfHandler))
				.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED))
				.logout(logout -> logout.logoutUrl("/api/auth/logout")
						.invalidateHttpSession(true).clearAuthentication(true)
						.deleteCookies("accessToken", "jwtToken", "JSESSIONID")
						.logoutSuccessHandler((request, response, authentication) -> {
							response.setContentType("application/json;charset=UTF-8");
							response.getWriter().write("{\"success\":true}");
						}))
				.authorizeHttpRequests(auth -> auth.requestMatchers(HttpMethod.POST, "/api/categories/**")
						.hasRole("ADMIN").requestMatchers(HttpMethod.PUT, "/api/categories/**").hasRole("ADMIN")
						.requestMatchers(HttpMethod.DELETE, "/api/categories/**").hasRole("ADMIN")
						.requestMatchers("/admin/categories/**").hasRole("ADMIN")
						.requestMatchers("/admin/products/**", "/admin/orders/**", "/admin/inventory/**",
								"/admin/returns/**", "/admin")
						.hasAnyRole("ADMIN", "STAFF").requestMatchers("/admin/**").hasRole("ADMIN")
						.requestMatchers("/shipper", "/shipper/**").hasRole("SHIPPER")
						.requestMatchers("/account", "/account/**").authenticated().requestMatchers("/api/account/**")
						.authenticated()
						.requestMatchers("/checkout", "/checkout/**", "/api/checkout/**", "/orders", "/orders/**",
								"/order-success/**", "/payment/vnpay-return").authenticated()
						.requestMatchers("/api/auth/**", "/api/test/**", "/", "/products/**", "/cart/**",
								"/login", "/register", "/css/**", "/js/**", "/images/**", "/static/**",
								"/favicon.ico")
						.permitAll().anyRequest().permitAll());

		http.exceptionHandling(exceptions -> exceptions.defaultAuthenticationEntryPointFor(
				new CustomerAuthenticationEntryPoint(), request -> {
					String path = request.getRequestURI().substring(request.getContextPath().length());
					return path.equals("/account") || path.startsWith("/account/") || path.startsWith("/api/account/")
							|| path.equals("/checkout") || path.startsWith("/checkout/") || path.startsWith("/api/checkout/")
							|| path.equals("/orders") || path.startsWith("/orders/") || path.startsWith("/order-success/")
							|| path.equals("/payment/vnpay-return");
				}).defaultAuthenticationEntryPointFor(new Http403ForbiddenEntryPoint(), request -> true));
		http.userDetailsService(userDetailsService);
		http.addFilterBefore(authenticationJwtTokenFilter(), UsernamePasswordAuthenticationFilter.class);

		return http.build();
	}
}
