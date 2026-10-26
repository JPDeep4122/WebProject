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
                .andExpect(redirectedUrl("/login?redirect=/account/profile"));
        mvc.perform(post("/account/profile").with(csrf()).param("fullName", "Intruder"))
                .andExpect(status().is3xxRedirection());
        assertEquals("Original Name", reload(owner).getFullName());
    }

    @Test
    void accountLoginRedirectDoesNotChangeAdminAccessRules() throws Exception {
        mvc.perform(get("/admin/users")).andExpect(status().isForbidden());
        mvc.perform(get("/admin/users").with(user(owner.getEmail()).roles("CUSTOMER")))
                .andExpect(status().isForbidden());
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
