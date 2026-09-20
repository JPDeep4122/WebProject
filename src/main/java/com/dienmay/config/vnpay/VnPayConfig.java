package com.dienmay.config.vnpay;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import jakarta.servlet.http.HttpServletRequest;
import lombok.Getter;

@Configuration
@Getter
public class VnPayConfig {

	@Value("${vnpay.tmn-code}")
	private String vnpTmnCode;

	@Value("${vnpay.hash-secret}")
	private String vnpHashSecret;

	@Value("${vnpay.pay-url}")
	private String vnpPayUrl;

	@Value("${vnpay.return-url}")
	private String vnpReturnUrl;

	// Thuật toán mã hóa HMAC-SHA512 theo chuẩn yêu cầu của VNPAY
	public static String hmacSHA512(final String key, final String data) {
		try {
			if (key == null || data == null) {
				throw new NullPointerException();
			}
			final Mac hmac512 = Mac.getInstance("HmacSHA512");
			byte[] hmacKeyBytes = key.getBytes(StandardCharsets.UTF_8);
			final SecretKeySpec secretKey = new SecretKeySpec(hmacKeyBytes, "HmacSHA512");
			hmac512.init(secretKey);
			byte[] dataBytes = data.getBytes(StandardCharsets.UTF_8);
			byte[] result = hmac512.doFinal(dataBytes);
			StringBuilder sb = new StringBuilder(2 * result.length);
			for (byte b : result) {
				sb.append(String.format("%02x", b & 0xff));
			}
			return sb.toString();
		} catch (Exception ex) {
			return "";
		}
	}

	// Lấy địa chỉ IP của khách hàng
	public static String getIpAddress(HttpServletRequest request) {
		String ipAddress = request.getHeader("X-FORWARDED-FOR");
		if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
			ipAddress = request.getRemoteAddr();
		}
		if (ipAddress == null || ipAddress.equals("0:0:0:0:0:0:0:1")) {
			ipAddress = "127.0.0.1";
		}
		return ipAddress;
	}

	// Sắp xếp các tham số A-Z và mã hóa chuẩn URL theo VNPAY.NET
	public static String hashAllFields(Map<String, String> fields, String secretKey) {
		List<String> fieldNames = new ArrayList<>(fields.keySet());
		Collections.sort(fieldNames);
		StringBuilder sb = new StringBuilder();
		for (String fieldName : fieldNames) {
			String fieldValue = fields.get(fieldName);
			if ((fieldValue != null) && (!fieldValue.isEmpty())) {
				try {
					sb.append(java.net.URLEncoder.encode(fieldName,
							java.nio.charset.StandardCharsets.US_ASCII.toString())).append('=')
							.append(java.net.URLEncoder.encode(fieldValue,
									java.nio.charset.StandardCharsets.US_ASCII.toString()))
							.append('&');
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
		if (sb.length() > 0) {
			sb.setLength(sb.length() - 1);
		}
		return hmacSHA512(secretKey, sb.toString());
	}
}