package com.dienmay.controller;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

import com.dienmay.dto.auth.AccountProfile;
import com.dienmay.dto.auth.ChangePasswordRequest;
import com.dienmay.entity.auth.Role;
import com.dienmay.entity.auth.User;
import com.dienmay.repository.auth.RoleRepository;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.security.jwt.JwtUtils;
import com.dienmay.service.impl.UserDetailsImpl;
import com.fasterxml.jackson.databind.ObjectMapper;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT, properties = {
        "spring.datasource.url=jdbc:h2:mem:account-profile;MODE=PostgreSQL;DB_CLOSE_DELAY=-1",
        "spring.datasource.driver-class-name=org.h2.Driver",
        "spring.datasource.username=sa", "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "dienmay.app.jwtSecret=integration-test-secret-key-that-is-long-enough-for-hmac-sha",
        "dienmay.app.jwtExpirationMs=60000",
        "cloudinary.cloud-name=test-cloud", "cloudinary.api-key=test-key", "cloudinary.api-secret=test-secret",
        "vnpay.tmn-code=test-merchant", "vnpay.hash-secret=test-hash-secret",
        "app.warmup.enabled=false", "app.jsp.precompiled=false"
})
@AutoConfigureMockMvc
class AccountProfileIntegrationTests {
    private static final String OLD_PASSWORD = "OldPassword!42";
    private static final String NEW_PASSWORD = "NewPassword!73";

    @Autowired MockMvc mvc;
    @Autowired UserRepository users;
    @Autowired RoleRepository roles;
    @Autowired PasswordEncoder encoder;
    @Autowired ObjectMapper json;
    @Autowired JwtUtils jwtUtils;
    @Autowired com.dienmay.repository.product.ProductRepository products;
    @Autowired com.dienmay.repository.order.OrderRepository orders;
    @Autowired com.dienmay.service.order.OrderService orderService;
    @LocalServerPort int port;

    private User owner;
    private User other;

    @BeforeEach
    void createAccounts() {
        owner = createUser("ROLE_CUSTOMER");
        other = createUser("ROLE_CUSTOMER");
    }

    @Test
    void anonymousVisitorMustLogin() throws Exception {
        mvc.perform(get("/account/profile"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/login-required?redirect=%2Faccount%2Fprofile"));
        mvc.perform(post("/account/profile").with(csrf()).param("fullName", "Intruder"))
                .andExpect(status().isUnauthorized());
        assertEquals("Original Name", reload(owner).getFullName());
    }

    @Test
    void accountLoginRedirectDoesNotChangeAdminAccessRules() throws Exception {
        mvc.perform(get("/admin/users")).andExpect(status().isForbidden());
        mvc.perform(get("/admin/users").with(user(owner.getEmail()).roles("CUSTOMER")))
                .andExpect(status().isForbidden());
    }

    @ParameterizedTest
    @ValueSource(strings = {"/checkout", "/orders", "/orders/tracking", "/orders/ORD-PRIVATE",
            "/order-success/ORD-PRIVATE", "/account/profile", "/payment/vnpay-return"})
    void anonymousCustomerPagesRequireLogin(String path) throws Exception {
        mvc.perform(get(path)).andExpect(status().is3xxRedirection())
                .andExpect(header().string("Location", org.hamcrest.Matchers.startsWith("/login-required?redirect=")));
    }

    @Test
    void anonymousMutationAndCheckoutApisCannotCreateOrders() throws Exception {
        long before = orders.count();
        mvc.perform(post("/checkout/place-order").with(csrf()).param("paymentMethod", "COD"))
                .andExpect(status().isUnauthorized()).andExpect(jsonPath("$.success").value(false));
        mvc.perform(post("/checkout/orders/ORD-PRIVATE/pay").with(csrf()))
                .andExpect(status().isUnauthorized());
        mvc.perform(post("/orders/ORD-PRIVATE/cancel").with(csrf()))
                .andExpect(status().isUnauthorized());
        mvc.perform(post("/orders/tracking").with(csrf()).param("orderCode", "ORD-PRIVATE").param("phone", "0901234567"))
                .andExpect(status().isUnauthorized());
        mvc.perform(post("/api/checkout/apply-voucher").with(csrf()).param("code", "SALE10").param("subtotal", "100000"))
                .andExpect(status().isUnauthorized());
        mvc.perform(post("/api/checkout/shipping-quote").with(csrf()).contentType(MediaType.APPLICATION_JSON)
                .content("{\"shippingAddress\":\"Test address\",\"province\":\"Test\"}"))
                .andExpect(status().isUnauthorized());
        mvc.perform(get("/orders/status-snapshot"))
                .andExpect(status().isUnauthorized()).andExpect(jsonPath("$.success").value(false));
        assertEquals(before, orders.count());
    }

    @Test
    void paymentIpnStillAcceptsAnonymousProviderRequestsAndValidatesSignature() throws Exception {
        mvc.perform(get("/payment/vnpay-ipn"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.RspCode").value("97"));
    }

    @ParameterizedTest
    @ValueSource(strings = {"https://outside.example", "//outside.example", "/\\outside.example", "/admin/users"})
    void loginPromptDoesNotRedirectOutsideCustomerPages(String redirect) throws Exception {
        mvc.perform(get("/login-required").param("redirect", redirect))
                .andExpect(status().isOk()).andExpect(view().name("client/login-required"))
                .andExpect(model().attribute("loginUrl", "/login?redirect=%2Forders"));
    }

    @Test
    void trackingRequiresOwnershipEvenWhenCodeAndRecipientPhoneMatch() throws Exception {
        String code = "ORD-TRACK-" + UUID.randomUUID().toString().replace("-", "");
        var order = orders.saveAndFlush(com.dienmay.entity.order.Order.builder().orderCode(code).user(owner)
                .totalAmount(java.math.BigDecimal.TEN).shippingFee(java.math.BigDecimal.ZERO)
                .discountAmount(java.math.BigDecimal.ZERO).finalAmount(java.math.BigDecimal.TEN)
                .status(com.dienmay.entity.order.OrderStatus.PENDING).recipientName("Test recipient")
                .recipientPhone("0901234567").shippingAddress("Test address").build());
        assertEquals(order.getId(), orderService.trackOrder(code, "0901234567", owner.getEmail()).getId());
        assertNull(orderService.trackOrder(code, "0901234567", other.getEmail()));
        assertNull(orderService.trackOrder(code, "0900000000", owner.getEmail()));
        assertThrows(org.springframework.web.server.ResponseStatusException.class,
                () -> orderService.trackOrder(code, "0901234567", null));
    }

    @Test
    // MockMvc csrf() replaces the shared repository with a session-backed test repository.
    // A real HTTP/browser cookie round trip must exercise the original application configuration.
    @org.springframework.test.annotation.DirtiesContext(methodMode = org.springframework.test.annotation.DirtiesContext.MethodMode.BEFORE_METHOD)
    void renderedGuestCartOffersLoginAndGuestCanStillAddProducts() throws Exception {
        var cookies = new java.net.CookieManager();
        var client = HttpClient.newBuilder().cookieHandler(cookies).connectTimeout(Duration.ofSeconds(10)).build();
        String base = "http://localhost:" + port;
        var prompt = client.send(HttpRequest.newBuilder(URI.create(base + "/login-required?redirect=%2Fcheckout"))
                .timeout(Duration.ofSeconds(20)).GET().build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(200, prompt.statusCode());
        assertTrue(prompt.body().contains("Đăng nhập để tiếp tục"));
        var matcher = java.util.regex.Pattern.compile("<meta\\s+name=\"_csrf\"\\s+content=\"([^\"]+)\"")
                .matcher(prompt.body());
        assertTrue(matcher.find());
        String csrfToken = matcher.group(1);
        assertTrue(cookies.getCookieStore().getCookies().stream()
                .anyMatch(cookie -> cookie.getName().equals("XSRF-TOKEN") && cookie.getValue().equals(csrfToken)));
        cookies.getCookieStore().getCookies().forEach(cookie -> cookie.setVersion(0));
        var product = products.findAll().stream().filter(com.dienmay.entity.product.Product::isActive).findFirst().orElseThrow();
        var add = client.send(HttpRequest.newBuilder(URI.create(base + "/api/cart/add"))
                .timeout(Duration.ofSeconds(20)).header("Content-Type", "application/json")
                .header("X-XSRF-TOKEN", csrfToken).POST(HttpRequest.BodyPublishers.ofString(
                        "{\"productId\":" + product.getId() + ",\"quantity\":1}")).build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(200, add.statusCode());
        var cart = client.send(HttpRequest.newBuilder(URI.create(base + "/cart"))
                .timeout(Duration.ofSeconds(20)).GET().build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(200, cart.statusCode());
        assertTrue(cart.body().contains("id=\"loginToCheckout\""));
        assertTrue(cart.body().contains("Đăng nhập để mua hàng"));
        var checkout = client.send(HttpRequest.newBuilder(URI.create(base + "/checkout"))
                .timeout(Duration.ofSeconds(20)).GET().build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(302, checkout.statusCode());
        assertTrue(checkout.headers().firstValue("Location").orElseThrow().contains("/login-required?redirect="));
        var login = client.send(HttpRequest.newBuilder(URI.create(base + "/api/auth/login"))
                .timeout(Duration.ofSeconds(20)).header("Content-Type", "application/json")
                .header("X-XSRF-TOKEN", csrfToken).POST(HttpRequest.BodyPublishers.ofString(
                        json.writeValueAsString(Map.of("email", owner.getEmail(), "password", OLD_PASSWORD))))
                .build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(200, login.statusCode());
        String token = json.readTree(login.body()).path("data").path("token").asText();
        assertFalse(token.isBlank());
        var accessCookie = new java.net.HttpCookie("accessToken", token);
        accessCookie.setPath("/");
        accessCookie.setVersion(0);
        cookies.getCookieStore().add(URI.create(base), accessCookie);
        var signedInCheckout = client.send(HttpRequest.newBuilder(URI.create(base + "/checkout"))
                .timeout(Duration.ofSeconds(20)).GET().build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(200, signedInCheckout.statusCode());
        assertTrue(signedInCheckout.body().contains("id=\"checkoutForm\""));
        var cartCount = client.send(HttpRequest.newBuilder(URI.create(base + "/api/cart/count"))
                .timeout(Duration.ofSeconds(20)).GET().build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(1, json.readTree(cartCount.body()).path("data").asInt());
        matcher = java.util.regex.Pattern.compile("<meta\\s+name=\"_csrf\"\\s+content=\"([^\"]+)\"")
                .matcher(signedInCheckout.body());
        assertTrue(matcher.find());
        cookies.getCookieStore().getCookies().forEach(cookie -> cookie.setVersion(0));
        var logout = client.send(HttpRequest.newBuilder(URI.create(base + "/api/auth/logout"))
                .timeout(Duration.ofSeconds(20)).header("X-XSRF-TOKEN", matcher.group(1))
                .POST(HttpRequest.BodyPublishers.noBody()).build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(200, logout.statusCode());
        // The page also explicitly removes its JavaScript-created JWT cookies after server logout.
        for (var cookie : java.util.List.copyOf(cookies.getCookieStore().getCookies())) {
            if (cookie.getName().equals("accessToken") || cookie.getName().equals("jwtToken")) {
                cookies.getCookieStore().remove(URI.create(base), cookie);
            }
        }
        var afterLogout = client.send(HttpRequest.newBuilder(URI.create(base + "/account/profile"))
                .timeout(Duration.ofSeconds(20)).GET().build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(302, afterLogout.statusCode());
        var guestCount = client.send(HttpRequest.newBuilder(URI.create(base + "/api/cart/count"))
                .timeout(Duration.ofSeconds(20)).GET().build(), HttpResponse.BodyHandlers.ofString());
        assertEquals(0, json.readTree(guestCount.body()).path("data").asInt());
    }

    @Test
    void profileJspRendersEscapedInformationAndBothFormsOverHttp() throws Exception {
        String unsafeName = "<img src=x onerror=alert(1)>";
        owner.setFullName(unsafeName);
        users.save(owner);
        var details = UserDetailsImpl.build(owner);
        String token = jwtUtils.generateJwtToken(new UsernamePasswordAuthenticationToken(
                details, null, details.getAuthorities()));
        try (var client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build()) {
            var request = HttpRequest.newBuilder(URI.create("http://localhost:" + port + "/account/profile"))
                    .timeout(Duration.ofSeconds(15)).header("Cookie", "accessToken=" + token).GET().build();
            var response = client.send(request, HttpResponse.BodyHandlers.ofString());
            assertEquals(200, response.statusCode());
            assertEquals("no-store", response.headers().firstValue("Cache-Control").orElseThrow());
            String html = response.body();
            assertTrue(html.contains("Hồ sơ của tôi"));
            assertTrue(html.contains("action=\"/account/profile\""));
            assertTrue(html.contains("action=\"/account/password\""));
            assertTrue(html.contains("name=\"_csrf\""));
            assertTrue(html.contains("&lt;img src=x onerror=alert(1)&gt;"));
            assertFalse(html.contains(unsafeName));
            assertFalse(html.contains(owner.getPassword()));
            assertFalse(html.contains(OLD_PASSWORD));
        }
    }

    @ParameterizedTest
    @ValueSource(strings = {"ADMIN", "CUSTOMER", "STAFF", "SHIPPER"})
    void allSignedInRolesCanViewTheirOwnProfile(String role) throws Exception {
        User account = createUser("ROLE_" + role);
        var result = mvc.perform(get("/account/profile").with(user(account.getEmail()).roles(role)))
                .andExpect(status().isOk()).andExpect(view().name("client/profile"))
                .andExpect(header().string("Cache-Control", "no-store"))
                .andReturn();
        AccountProfile profile = (AccountProfile) result.getModelAndView().getModel().get("accountProfile");
        assertEquals(account.getEmail(), profile.getEmail());
        assertEquals("Original Name", profile.getFullName());
    }

    @Test
    void bothUpdatesRequireCsrf() throws Exception {
        mvc.perform(post("/account/profile").with(user(owner.getEmail()))
                .param("fullName", "Changed")).andExpect(status().isForbidden());
        mvc.perform(post("/account/password").with(user(owner.getEmail()))
                .param("currentPassword", OLD_PASSWORD).param("newPassword", NEW_PASSWORD)
                .param("confirmPassword", NEW_PASSWORD)).andExpect(status().isForbidden());
        assertEquals("Original Name", reload(owner).getFullName());
        assertTrue(encoder.matches(OLD_PASSWORD, reload(owner).getPassword()));
    }

    @Test
    void profileUpdateIgnoresOtherUserIdsEmailsRolesAndPasswords() throws Exception {
        mvc.perform(post("/account/profile").with(user(owner.getEmail())).with(csrf())
                .param("fullName", "  Updated Name  ").param("phoneNumber", "+84912345678")
                .param("id", other.getId().toString()).param("userId", other.getId().toString())
                .param("email", other.getEmail()).param("roles", "ROLE_ADMIN")
                .param("active", "false").param("password", NEW_PASSWORD).param("branchId", "999"))
                .andExpect(status().is3xxRedirection()).andExpect(redirectedUrl("/account/profile"))
                .andExpect(flash().attributeExists("profileSuccess"));
        User updated = reload(owner);
        assertEquals("Updated Name", updated.getFullName());
        assertEquals("+84912345678", updated.getPhoneNumber());
        assertEquals(owner.getEmail(), updated.getEmail());
        assertTrue(updated.isActive());
        assertNull(updated.getBranch());
        assertEquals(Set.of("ROLE_CUSTOMER"), updated.getRoles().stream().map(Role::getName).collect(java.util.stream.Collectors.toSet()));
        assertTrue(encoder.matches(OLD_PASSWORD, updated.getPassword()));
        assertEquals("Original Name", reload(other).getFullName());
    }

    @ParameterizedTest
    @ValueSource(strings = {"", "   "})
    void blankNamesAreRejected(String name) throws Exception {
        mvc.perform(post("/account/profile").with(user(owner.getEmail())).with(csrf())
                .param("fullName", name)).andExpect(status().isOk())
                .andExpect(view().name("client/profile")).andExpect(model().attributeExists("profileError"));
        assertEquals("Original Name", reload(owner).getFullName());
    }

    @Test
    void oversizedNameAndInvalidPhoneAreRejected() throws Exception {
        mvc.perform(post("/account/profile").with(user(owner.getEmail())).with(csrf())
                .param("fullName", "a".repeat(101))).andExpect(status().isOk())
                .andExpect(model().attributeExists("profileError"));
        mvc.perform(post("/account/profile").with(user(owner.getEmail())).with(csrf())
                .param("fullName", "Valid Name").param("phoneNumber", "not-a-phone"))
                .andExpect(status().isOk()).andExpect(model().attributeExists("profileError"));
        assertEquals("Original Name", reload(owner).getFullName());
    }

    @Test
    void optionalPhoneCanBeCleared() throws Exception {
        mvc.perform(post("/account/profile").with(user(owner.getEmail())).with(csrf())
                .param("fullName", "Updated Name").param("phoneNumber", ""))
                .andExpect(status().is3xxRedirection());
        assertNull(reload(owner).getPhoneNumber());
    }

    @Test
    void wrongCurrentPasswordIsRejected() throws Exception {
        mvc.perform(passwordChange("WrongPassword!", NEW_PASSWORD, NEW_PASSWORD))
                .andExpect(status().isOk()).andExpect(model().attribute("passwordError", "Mật khẩu hiện tại không chính xác."));
        assertTrue(encoder.matches(OLD_PASSWORD, reload(owner).getPassword()));
    }

    @Test
    void confirmationMustMatch() throws Exception {
        mvc.perform(passwordChange(OLD_PASSWORD, NEW_PASSWORD, "DifferentPassword!"))
                .andExpect(status().isOk()).andExpect(model().attribute("passwordError", "Xác nhận mật khẩu mới chưa khớp."));
        assertTrue(encoder.matches(OLD_PASSWORD, reload(owner).getPassword()));
    }

    @ParameterizedTest
    @ValueSource(strings = {"", "short", "        "})
    void invalidNewPasswordsAreRejected(String password) throws Exception {
        mvc.perform(passwordChange(OLD_PASSWORD, password, password))
                .andExpect(status().isOk()).andExpect(model().attributeExists("passwordError"));
        assertTrue(encoder.matches(OLD_PASSWORD, reload(owner).getPassword()));
    }

    @Test
    void bcryptByteLimitIsCheckedForUnicodePasswords() throws Exception {
        String password = "ắ".repeat(30);
        mvc.perform(passwordChange(OLD_PASSWORD, password, password))
                .andExpect(status().isOk()).andExpect(model().attributeExists("passwordError"));
        assertTrue(encoder.matches(OLD_PASSWORD, reload(owner).getPassword()));
    }

    @Test
    void newPasswordMustDifferFromCurrentPassword() throws Exception {
        mvc.perform(passwordChange(OLD_PASSWORD, OLD_PASSWORD, OLD_PASSWORD))
                .andExpect(status().isOk()).andExpect(model().attributeExists("passwordError"));
        assertTrue(encoder.matches(OLD_PASSWORD, reload(owner).getPassword()));
    }

    @Test
    void passwordChangeOnlyUpdatesTheCurrentUserAndClearsPasswordForm() throws Exception {
        mvc.perform(passwordChange(OLD_PASSWORD, NEW_PASSWORD, NEW_PASSWORD)
                .param("id", other.getId().toString()).param("email", other.getEmail())
                .param("roles", "ROLE_ADMIN"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/account/profile#change-password"))
                .andExpect(flash().attributeExists("passwordSuccess"));
        assertTrue(encoder.matches(NEW_PASSWORD, reload(owner).getPassword()));
        assertFalse(encoder.matches(OLD_PASSWORD, reload(owner).getPassword()));
        assertTrue(encoder.matches(OLD_PASSWORD, reload(other).getPassword()));
        assertNotEquals(NEW_PASSWORD, reload(owner).getPassword());

        var failed = mvc.perform(passwordChange("WrongPassword!", "SecretNewPassword!", "Mismatch!"))
                .andExpect(status().isOk()).andReturn();
        ChangePasswordRequest form = (ChangePasswordRequest) failed.getModelAndView().getModel().get("passwordForm");
        assertNull(form.getCurrentPassword());
        assertNull(form.getNewPassword());
        assertNull(form.getConfirmPassword());
    }

    @Test
    void newPasswordWorksForLoginWithoutTrimmingItsSpaces() throws Exception {
        String password = " NewPassword!73 ";
        mvc.perform(passwordChange(OLD_PASSWORD, password, password)).andExpect(status().is3xxRedirection());
        mvc.perform(post("/api/auth/login").with(csrf()).contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("email", owner.getEmail(), "password", password))))
                .andExpect(status().isOk()).andExpect(jsonPath("$.success").value(true));
        mvc.perform(post("/api/auth/login").with(csrf()).contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("email", owner.getEmail(), "password", OLD_PASSWORD))))
                .andExpect(status().isOk()).andExpect(jsonPath("$.success").value(false));
    }

    @Test
    void inactiveAccountsCannotReadOrUpdateProfiles() throws Exception {
        owner.setActive(false);
        users.save(owner);
        mvc.perform(get("/account/profile").with(user(owner.getEmail())))
                .andExpect(status().isForbidden());
        mvc.perform(passwordChange(OLD_PASSWORD, NEW_PASSWORD, NEW_PASSWORD))
                .andExpect(status().isForbidden());
        assertTrue(encoder.matches(OLD_PASSWORD, reload(owner).getPassword()));
    }

    private MockHttpServletRequestBuilder passwordChange(String current, String password, String confirm) {
        return post("/account/password").with(user(owner.getEmail())).with(csrf())
                .param("currentPassword", current).param("newPassword", password).param("confirmPassword", confirm);
    }

    private User createUser(String roleName) {
        Role role = roles.findByName(roleName).orElseGet(() -> roles.save(Role.builder().name(roleName).build()));
        return users.save(User.builder().email("profile-" + UUID.randomUUID() + "@example.test")
                .fullName("Original Name").phoneNumber("0912345678").active(true)
                .password(encoder.encode(OLD_PASSWORD)).roles(Set.of(role)).build());
    }

    private User reload(User account) {
        return users.findById(account.getId()).orElseThrow();
    }
}
