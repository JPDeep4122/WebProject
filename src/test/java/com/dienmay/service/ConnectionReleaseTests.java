package com.dienmay.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.sql.Connection;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.aop.framework.ProxyFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.mail.MailSendException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.annotation.AnnotationTransactionAttributeSource;
import org.springframework.transaction.interceptor.TransactionInterceptor;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.transaction.support.TransactionTemplate;

import com.dienmay.dto.auth.ForgotPasswordRequest;
import com.dienmay.dto.auth.RegisterRequest;
import com.dienmay.entity.auth.OtpCode;
import com.dienmay.entity.auth.Role;
import com.dienmay.entity.auth.User;
import com.dienmay.repository.auth.OtpCodeRepository;
import com.dienmay.repository.auth.RoleRepository;
import com.dienmay.repository.auth.UserRepository;
import com.dienmay.service.auth.AuthService;
import com.dienmay.service.impl.AuthServiceImpl;
import com.dienmay.service.mail.EmailService;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

class ConnectionReleaseTests {
    private static final String EMAIL = "customer@example.test";
    private HikariDataSource pool;
    private JdbcTemplate jdbc;
    private UserRepository users;
    private OtpCodeRepository otps;
    private EmailService mail;
    private AuthService service;

    @BeforeEach
    void setUp() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:h2:mem:" + UUID.randomUUID() + ";DB_CLOSE_DELAY=-1");
        config.setMaximumPoolSize(1);
        config.setMinimumIdle(0);
        config.setConnectionTimeout(250);
        pool = new HikariDataSource(config);
        jdbc = new JdbcTemplate(pool);
        jdbc.execute("create table sent_otp (code varchar(6))");
        DataSourceTransactionManager manager = new DataSourceTransactionManager(pool);

        users = mock(UserRepository.class);
        otps = mock(OtpCodeRepository.class);
        mail = mock(EmailService.class);
        RoleRepository roles = mock(RoleRepository.class);
        PasswordEncoder encoder = mock(PasswordEncoder.class);
        when(roles.findByName("ROLE_CUSTOMER")).thenReturn(Optional.of(new Role()));
        when(encoder.encode(anyString())).thenReturn("encoded-password");
        when(otps.save(any(OtpCode.class))).thenAnswer(invocation -> {
            assertTrue(TransactionSynchronizationManager.isActualTransactionActive());
            OtpCode otp = invocation.getArgument(0);
            jdbc.update("insert into sent_otp (code) values (?)", otp.getOtpCode());
            return otp;
        });

        AuthServiceImpl target = new AuthServiceImpl();
        ReflectionTestUtils.setField(target, "userRepository", users);
        ReflectionTestUtils.setField(target, "roleRepository", roles);
        ReflectionTestUtils.setField(target, "otpCodeRepository", otps);
        ReflectionTestUtils.setField(target, "emailService", mail);
        ReflectionTestUtils.setField(target, "passwordEncoder", encoder);
        ReflectionTestUtils.setField(target, "transactionTemplate", new TransactionTemplate(manager));
        ProxyFactory factory = new ProxyFactory(target);
        factory.addAdvice(new TransactionInterceptor(manager, new AnnotationTransactionAttributeSource()));
        service = (AuthService) factory.getProxy();

        doAnswer(invocation -> {
            assertConnectionReleasedBeforeMail();
            return null;
        }).when(mail).sendOtpEmail(eq(EMAIL), anyString());
    }

    @AfterEach
    void tearDown() {
        pool.close();
    }

    @Test
    void registrationCommitsAndReleasesOnlyConnectionBeforeSendingMail() {
        RegisterRequest request = new RegisterRequest();
        request.setEmail(EMAIL);
        request.setFullname("Customer");
        request.setPassword("password");
        assertTrue(service.register(request).isSuccess());
        verify(mail).sendOtpEmail(eq(EMAIL), matches("[0-9]{6}"));
    }

    @Test
    void resendReleasesConnectionBeforeSendingMail() {
        when(users.findByEmail(EMAIL)).thenReturn(Optional.of(User.builder().active(false).build()));
        assertTrue(service.resendOtp(EMAIL).isSuccess());
        verify(mail).sendOtpEmail(eq(EMAIL), anyString());
    }

    @Test
    void passwordResetReleasesConnectionBeforeSendingMail() {
        when(users.findByEmail(EMAIL)).thenReturn(Optional.of(User.builder().active(true).build()));
        ForgotPasswordRequest request = new ForgotPasswordRequest();
        request.setEmail(EMAIL);
        assertTrue(service.forgotPassword(request).isSuccess());
        verify(mail).sendOtpEmail(eq(EMAIL), anyString());
    }

    @Test
    void smtpFailureReturnsFailureAndLeavesPoolUsable() {
        when(users.findByEmail(EMAIL)).thenReturn(Optional.of(User.builder().active(false).build()));
        doAnswer(invocation -> {
            assertConnectionReleasedBeforeMail();
            throw new MailSendException("SMTP unavailable");
        }).when(mail).sendOtpEmail(eq(EMAIL), anyString());
        assertFalse(service.resendOtp(EMAIL).isSuccess());
        assertEquals(1, jdbc.queryForObject("select count(*) from sent_otp", Integer.class));
        assertEquals(0, pool.getHikariPoolMXBean().getActiveConnections());
    }

    @Test
    void databaseFailureRollsBackOtpAndDoesNotSendMail() {
        when(users.findByEmail(EMAIL)).thenReturn(Optional.of(User.builder().active(false).build()));
        when(otps.save(any(OtpCode.class))).thenAnswer(invocation -> {
            jdbc.update("insert into sent_otp (code) values ('123456')");
            throw new IllegalStateException("Database failure");
        });
        assertThrows(IllegalStateException.class, () -> service.resendOtp(EMAIL));
        assertEquals(0, jdbc.queryForObject("select count(*) from sent_otp", Integer.class));
        verifyNoInteractions(mail);
    }

    @Test
    void rejectedRequestDoesNotCreateOrSendOtp() {
        when(users.findByEmail(EMAIL)).thenReturn(Optional.of(User.builder().active(true).build()));
        assertFalse(service.resendOtp(EMAIL).isSuccess());
        verifyNoInteractions(otps, mail);
    }

    private void assertConnectionReleasedBeforeMail() throws Exception {
        assertFalse(TransactionSynchronizationManager.isActualTransactionActive());
        assertEquals(0, pool.getHikariPoolMXBean().getActiveConnections());
        // A second borrower can use the only connection even while SMTP is running.
        try (Connection connection = pool.getConnection()) {
            assertTrue(connection.isValid(1));
        }
        assertEquals(1, jdbc.queryForObject("select count(*) from sent_otp", Integer.class));
    }
}
