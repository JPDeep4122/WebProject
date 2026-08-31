package com.dienmay.controller;

import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.dienmay.service.EmailService;

@RestController
@RequestMapping("/api/test")
public class TestEmailController {

    @Autowired
    private EmailService emailService;

    @GetMapping("/send-otp")
    public String testSendOtp(@RequestParam(defaultValue = "temporary8386@gmail.com") String email) {
        // Sinh ngẫu nhiên mã OTP 6 chữ số
        String otp = String.valueOf(new Random().nextInt(900000) + 100000);

        // Gọi EmailService để gửi
        emailService.sendOtpEmail(email, otp);

        return " Đã gửi thành công mã OTP [" + otp + "] đến địa chỉ email: " + email + ". Hãy kiểm tra hộp thư đến (hoặc thư mục Spam)!";
    }
}