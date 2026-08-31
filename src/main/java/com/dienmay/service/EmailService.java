package com.dienmay.service;

public interface EmailService {
	 /**
     * Gửi mã OTP xác thực (đăng ký / quên mật khẩu)
     * @param toEmail Email người nhận
     * @param otpCode Mã OTP gồm 6 chữ số
     */
	void sendOtpEmail(String toEmail, String otpCode);
	
	/**
     * Gửi email định dạng HTML (dùng cho hóa đơn, thông báo đơn hàng)
     * @param toEmail Email người nhận
     * @param subject Tiêu đề email
     * @param htmlBody Nội dung HTML
     */
	void sendHtmlEmail(String toEmail, String subject, String htmlBody);
}
