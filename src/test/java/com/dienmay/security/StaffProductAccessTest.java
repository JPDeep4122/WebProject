package com.dienmay.security;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers.springSecurity;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import javax.sql.DataSource;
import java.lang.reflect.Proxy;
import java.util.Map;
import jakarta.persistence.EntityManagerFactory;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.MapPropertySource;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.mock.web.MockServletContext;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.support.AnnotationConfigWebApplicationContext;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import com.dienmay.security.jwt.JwtUtils;
import com.dienmay.service.impl.UserDetailsServiceImpl;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.controller.admin.AdminInventoryController;
import com.dienmay.service.branch.BranchInventoryManagementService;
import com.fasterxml.jackson.databind.ObjectMapper;

class StaffProductAccessTest {
    private AnnotationConfigWebApplicationContext context;
    private MockMvc mvc;

    @BeforeEach
    void setup() {
        context = new AnnotationConfigWebApplicationContext();
        context.setServletContext(new MockServletContext());
        context.getEnvironment().getPropertySources().addFirst(new MapPropertySource("test-jwt", Map.of(
                "dienmay.app.jwtSecret", "test-only-signing-key-for-isolated-security-tests-1234567890",
                "dienmay.app.jwtExpirationMs", "86400000")));
        context.register(TestConfig.class, SecurityConfig.class);
        context.refresh();
        mvc = MockMvcBuilders.webAppContextSetup(context).apply(springSecurity()).build();
    }

    @AfterEach
    void close() {
        if (context != null) context.close();
    }

    @ParameterizedTest
    @ValueSource(strings = {"STAFF", "BRANCH_MANAGER", "ADMIN"})
    void personnelCanCreateAndEditProducts(String role) throws Exception {
        mvc.perform(post("/admin/products").with(user("actor").roles(role)).with(csrf()))
                .andExpect(status().isNoContent());
        mvc.perform(get("/admin/products/1/edit").with(user("actor").roles(role)))
                .andExpect(status().isNoContent());
        mvc.perform(post("/admin/products/1/edit").with(user("actor").roles(role)).with(csrf()))
                .andExpect(status().isNoContent());
    }

    @ParameterizedTest
    @ValueSource(strings = {"CUSTOMER", "SHIPPER"})
    void otherRolesCannotWriteProducts(String role) throws Exception {
        mvc.perform(post("/admin/products").with(user("actor").roles(role)).with(csrf()))
                .andExpect(status().isForbidden());
        mvc.perform(post("/admin/products/1/edit").with(user("actor").roles(role)).with(csrf()))
                .andExpect(status().isForbidden());
    }

    @Test
    void writesStillRequireCsrf() throws Exception {
        mvc.perform(post("/admin/products").with(user("actor").roles("STAFF")))
                .andExpect(status().isForbidden());
    }

    @Test
    void staffCannotDeleteProductsOrManagePersonnel() throws Exception {
        mvc.perform(post("/admin/products/1/delete").with(user("actor").roles("STAFF")).with(csrf()))
                .andExpect(status().isForbidden());
        mvc.perform(get("/admin/users").with(user("actor").roles("STAFF")))
                .andExpect(status().isForbidden());
        mvc.perform(post("/admin/products/1/delete").with(user("actor").roles("ADMIN")).with(csrf()))
                .andExpect(status().isNoContent());
    }

    @ParameterizedTest
    @ValueSource(strings = {"STAFF", "BRANCH_MANAGER", "ADMIN"})
    void removedInventoryAdjustmentEndpointsAreNotAvailable(String role) throws Exception {
        mvc.perform(post("/admin/inventory/1/adjust")
                .with(user("actor").roles(role)).with(csrf()))
                .andExpect(status().isNotFound());
        mvc.perform(post("/admin/inventory/adjustments/1/review")
                .with(user("actor").roles(role)).with(csrf()))
                .andExpect(status().isNotFound());
    }

    @ParameterizedTest
    @ValueSource(strings = {"STAFF", "BRANCH_MANAGER", "ADMIN", "CUSTOMER", "SHIPPER"})
    void removedTransfersCannotBeAccessed(String role) throws Exception {
        mvc.perform(get("/admin/transfers").with(user("actor").roles(role)))
                .andExpect(status().isForbidden());
        mvc.perform(post("/admin/transfers/1/approve").with(user("actor").roles(role)).with(csrf()))
                .andExpect(status().isForbidden());
    }

    @ParameterizedTest
    @ValueSource(strings = {"STAFF", "BRANCH_MANAGER", "ADMIN"})
    void inventoryUpdateRequiresValidInputAndCsrf(String role) throws Exception {
        mvc.perform(post("/admin/inventory/1/stock").with(user("actor").roles(role)).with(csrf())
                .param("newStock", "-1").param("expectedStock", "10").param("reason", "Kiểm kê"))
                .andExpect(status().is3xxRedirection());
        mvc.perform(post("/admin/inventory/1/stock").with(user("actor").roles(role)))
                .andExpect(status().isForbidden());
    }

    @ParameterizedTest
    @ValueSource(strings = {"CUSTOMER", "SHIPPER"})
    void otherRolesCannotUpdateInventory(String role) throws Exception {
        mvc.perform(post("/admin/inventory/1/stock").with(user("actor").roles(role)).with(csrf()))
                .andExpect(status().isForbidden());
    }

    @Configuration
    @EnableWebSecurity
    @EnableWebMvc
    static class TestConfig {
        @Bean UserDetailsServiceImpl userDetailsService() { return new UserDetailsServiceImpl(); }
        @Bean UserRepository userRepository() { return unusedDependency(UserRepository.class); }
        @Bean JwtUtils jwtUtils() { return new JwtUtils(); }
        @Bean DataSource dataSource() { return new DriverManagerDataSource(); }
        @Bean EntityManagerFactory entityManagerFactory() { return unusedDependency(EntityManagerFactory.class); }
        @Bean ObjectMapper objectMapper() { return new ObjectMapper(); }
        @Bean Routes routes() { return new Routes(); }
        @Bean AdminInventoryController inventoryController() {
            return new AdminInventoryController(new BranchInventoryManagementService(null, null, null, null));
        }

        // Authentication is supplied by Spring Security Test; no database is contacted.
        private static <T> T unusedDependency(Class<T> type) {
            return type.cast(Proxy.newProxyInstance(type.getClassLoader(), new Class<?>[]{type},
                    (proxy, method, args) -> switch (method.getName()) {
                        case "toString" -> "Unused test dependency: " + type.getSimpleName();
                        case "hashCode" -> System.identityHashCode(proxy);
                        case "equals" -> proxy == args[0];
                        case "getProperties" -> Map.of();
                        case "close" -> null;
                        default -> throw new UnsupportedOperationException(method.getName());
                    }));
        }
    }

    @RestController
    static class Routes {
        @RequestMapping({"/admin/products", "/admin/products/{id}/edit",
                "/admin/products/{id}/delete", "/admin/users"})
        ResponseEntity<Void> endpoint() { return ResponseEntity.noContent().build(); }
    }
}
