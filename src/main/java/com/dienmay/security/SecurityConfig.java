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
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.jdbc.datasource.DataSourceUtils;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.security.web.header.writers.ReferrerPolicyHeaderWriter.ReferrerPolicy;
import com.dienmay.security.jwt.AuthTokenFilter;
import com.dienmay.service.impl.UserDetailsImpl;

import jakarta.persistence.EntityManagerFactory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.stream.Collectors;
import javax.sql.DataSource;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

@Configuration
public class SecurityConfig {

	@Bean
	public PlatformTransactionManager transactionManager(EntityManagerFactory entityManagerFactory,
			DataSource dataSource) {
		JpaTransactionManager manager = new JpaTransactionManager(entityManagerFactory) {
			@Override
			protected void doBegin(Object transaction, TransactionDefinition definition) {
				super.doBegin(transaction, definition);
				applyRlsIdentity(dataSource);
			}
		};
		manager.setDataSource(dataSource);
		return manager;
	}

	private static void applyRlsIdentity(DataSource dataSource) {
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		String userId = "";
		String branchId = "";
		String roles = "";
		if (authentication != null && authentication.isAuthenticated()
				&& authentication.getPrincipal() instanceof UserDetailsImpl principal) {
			userId = principal.getId() == null ? "" : principal.getId().toString();
			branchId = principal.getBranchId() == null ? "" : principal.getBranchId().toString();
			roles = authentication.getAuthorities().stream().map(authority -> authority.getAuthority())
					.filter(role -> role.matches("ROLE_[A-Z_]+")).collect(Collectors.joining(","));
		}
		Connection connection = DataSourceUtils.getConnection(dataSource);
		try (PreparedStatement statement = connection.prepareStatement(
				"SELECT set_config('app.user_id', ?, true), set_config('app.branch_id', ?, true), set_config('app.roles', ?, true)")) {
			statement.setString(1, userId);
			statement.setString(2, branchId);
			statement.setString(3, roles);
			statement.execute();
		} catch (SQLException exception) {
			throw new IllegalStateException("Could not install PostgreSQL RLS identity for the transaction", exception);
		} finally {
			DataSourceUtils.releaseConnection(connection, dataSource);
		}
	}

	@Autowired
	private UserDetailsService userDetailsService;

	@Bean
	public AuthTokenFilter authenticationJwtTokenFilter() {
		return new AuthTokenFilter();
	}

	@Bean
	public ApiRateLimitFilter apiRateLimitFilter(com.fasterxml.jackson.databind.ObjectMapper objectMapper) {
		return new ApiRateLimitFilter(objectMapper);
	}

	@Bean
	public FilterRegistrationBean<ApiRateLimitFilter> disableContainerRegistration(ApiRateLimitFilter filter) {
		FilterRegistrationBean<ApiRateLimitFilter> registration = new FilterRegistrationBean<>(filter);
		registration.setEnabled(false);
		return registration;
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
	public SecurityFilterChain filterChain(HttpSecurity http, ApiRateLimitFilter apiRateLimitFilter) throws Exception {

		CsrfTokenRequestAttributeHandler csrfHandler = new CsrfTokenRequestAttributeHandler();

		csrfHandler.setCsrfRequestAttributeName(null);
		http.csrf(csrf -> csrf.csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
				.csrfTokenRequestHandler(csrfHandler))
				.headers(headers -> headers
						.referrerPolicy(referrer -> referrer.policy(ReferrerPolicy.ORIGIN_WHEN_CROSS_ORIGIN)))
				.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED))
				.logout(logout -> logout.logoutUrl("/api/auth/logout").invalidateHttpSession(true)
						.clearAuthentication(true).deleteCookies("accessToken", "jwtToken", "JSESSIONID")
						.logoutSuccessHandler((request, response, authentication) -> {
							response.setContentType("application/json;charset=UTF-8");
							response.getWriter().write("{\"success\":true}");
						}))
				.authorizeHttpRequests(auth -> auth.requestMatchers(HttpMethod.POST, "/api/categories/**")
						.hasRole("ADMIN").requestMatchers(HttpMethod.PUT, "/api/categories/**").hasRole("ADMIN")
						.requestMatchers(HttpMethod.DELETE, "/api/categories/**").hasRole("ADMIN")
						.requestMatchers("/admin/categories/**").hasRole("ADMIN")
						.requestMatchers("/admin/products/*/delete").hasRole("ADMIN")
						.requestMatchers("/admin/users/**", "/admin/invoices/**").hasAnyRole("ADMIN", "BRANCH_MANAGER")
						.requestMatchers("/admin/transfers", "/admin/transfers/**").denyAll()
						.requestMatchers("/admin/products/**", "/admin/orders/**", "/admin/inventory/**",
								"/admin/returns/**", "/admin")
						.hasAnyRole("ADMIN", "BRANCH_MANAGER", "STAFF").requestMatchers("/admin/**").hasRole("ADMIN")
						.requestMatchers("/shipper", "/shipper/**").hasRole("SHIPPER")
						.requestMatchers("/account", "/account/**").authenticated().requestMatchers("/api/account/**")
						.authenticated()
						.requestMatchers("/checkout", "/checkout/**", "/api/checkout/**", "/orders", "/orders/**",
								"/order-success/**", "/payment/vnpay-return", "/notifications", "/api/notifications/**")
						.authenticated()
						.requestMatchers("/api/auth/**", "/api/test/**", "/", "/products/**", "/cart/**", "/login",
								"/register", "/css/**", "/js/**", "/images/**", "/static/**", "/favicon.ico")
						.permitAll().anyRequest().permitAll());

		http.exceptionHandling(exceptions -> exceptions
				.defaultAuthenticationEntryPointFor(new CustomerAuthenticationEntryPoint(), request -> {
					String path = request.getRequestURI().substring(request.getContextPath().length());
					return path.equals("/account") || path.startsWith("/account/") || path.startsWith("/api/account/")
							|| path.equals("/checkout") || path.startsWith("/checkout/")
							|| path.startsWith("/api/checkout/") || path.equals("/orders")
							|| path.startsWith("/orders/") || path.startsWith("/order-success/")
							|| path.equals("/notifications") || path.startsWith("/api/notifications/")
							|| path.equals("/payment/vnpay-return");
				}).defaultAuthenticationEntryPointFor(new Http403ForbiddenEntryPoint(), request -> true));
		http.userDetailsService(userDetailsService);

		http.addFilterBefore(authenticationJwtTokenFilter(), UsernamePasswordAuthenticationFilter.class);

		http.addFilterBefore(apiRateLimitFilter, AuthTokenFilter.class);

		return http.build();
	}
}
