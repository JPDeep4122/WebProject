package com.dienmay.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.MailSendException;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import com.dienmay.service.mail.EmailService;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

@Service
public class EmailServiceImpl implements EmailService {

    @Autowired
    private JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    @Override
    public void sendOtpEmail(String toEmail, String otpCode) {
        String subject = "Mã xác thực OTP — Chuỗi Cửa Hàng Điện Máy";
        String htmlContent = "<div style='font-family: Arial, sans-serif; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px; max-width: 500px; margin: auto;'>"
                + "<h2 style='color: #0d6efd; text-align: center;'>XÁC THỰC TÀI KHOẢN</h2>"
                + "<p>Xin chào,</p>"
                + "<p>Bạn vừa thực hiện yêu cầu xác thực trên hệ thống <b>Chuỗi Cửa Hàng Điện Máy</b>.</p>"
                + "<p>Mã OTP của bạn là:</p>"
                + "<div style='text-align: center; margin: 20px 0;'>"
                + "<span style='font-size: 28px; font-weight: bold; color: #dc3545; letter-spacing: 5px; background: #f8f9fa; padding: 10px 20px; border-radius: 6px; border: 1px dashed #dc3545;'>"
                + otpCode + "</span>"
                + "</div>"
                + "<p style='color: #6c757d; font-size: 13px;'>Mã này có hiệu lực trong vòng <b>5 phút</b>. Vui lòng không chia sẻ mã này cho bất kỳ ai.</p>"
                + "<hr style='border: none; border-top: 1px solid #eee; margin: 20px 0;'/>"
                + "<p style='font-size: 12px; color: #999; text-align: center;'>Đây là email tự động, vui lòng không phản hồi lại email này.</p>"
                + "</div>";

        sendHtmlEmail(toEmail, subject, htmlContent);
    }

    @Override
    public void sendHtmlEmail(String toEmail, String subject, String htmlBody) {
        if (fromEmail == null || fromEmail.isBlank()) {
            throw new MailSendException("Chưa cấu hình MAIL_USERNAME để gửi email.");
        }
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject(subject);
            helper.setText(htmlBody, true); // true = nội dung dạng HTML

            mailSender.send(message);
        } catch (MessagingException e) {
            throw new MailSendException("Không thể tạo email.", e);
        }
    }
}
