package com.dienmay.service.impl;

import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.ResolverStyle;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.config.vnpay.VnPayConfig;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.payment.Payment;
import com.dienmay.entity.payment.PaymentMethod;
import com.dienmay.entity.payment.PaymentStatus;
import com.dienmay.repository.payment.PaymentRepository;
import com.dienmay.service.payment.VnPayService;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import tools.jackson.databind.ext.javatime.DateTimeParseException;

@Service
@RequiredArgsConstructor
public class VnPayServiceImpl implements VnPayService {

    private final VnPayConfig vnPayConfig;
    private final PaymentRepository paymentRepository;

    @Override
    public String createPaymentUrl(Order order, HttpServletRequest request) {
        if (vnPayConfig.getVnpTmnCode() == null || vnPayConfig.getVnpTmnCode().isBlank()
                || vnPayConfig.getVnpHashSecret() == null || vnPayConfig.getVnpHashSecret().isBlank()) {
            throw new IllegalStateException(
                    "VNPay chưa được cấu hình. Hãy đặt VNPAY_TMN_CODE và VNPAY_HASH_SECRET.");
        }
        String vnp_Version = "2.1.0";
        String vnp_Command = "pay";
        // Chuẩn hóa vnp_TxnRef: Chỉ gồm chữ và số (loại bỏ dấu gạch ngang nếu có)
        String vnp_TxnRef = order.getOrderCode().replace("-", "");
        String vnp_IpAddr = VnPayConfig.getIpAddress(request);
        String vnp_TmnCode = vnPayConfig.getVnpTmnCode();

        // Số tiền theo quy định VNPAY phải nhân với 100
        long amount = order.getFinalAmount()
                .movePointRight(2)
                .longValueExact();

        Map<String, String> vnp_Params = new HashMap<>();
        vnp_Params.put("vnp_Version", vnp_Version);
        vnp_Params.put("vnp_Command", vnp_Command);
        vnp_Params.put("vnp_TmnCode", vnp_TmnCode);
        vnp_Params.put("vnp_Amount", String.valueOf(amount));
        vnp_Params.put("vnp_CurrCode", "VND");
        vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
        vnp_Params.put("vnp_OrderInfo", "Thanh toan don hang " + vnp_TxnRef);
        vnp_Params.put("vnp_OrderType", "other");
        vnp_Params.put("vnp_Locale", "vn");
        vnp_Params.put("vnp_ReturnUrl", vnPayConfig.getVnpReturnUrl());
        vnp_Params.put("vnp_IpAddr", vnp_IpAddr);

        // Múi giờ chuẩn Việt Nam GMT+7
        TimeZone vnTimeZone = TimeZone.getTimeZone("Asia/Ho_Chi_Minh");
        Calendar cld = Calendar.getInstance(vnTimeZone);
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        formatter.setTimeZone(vnTimeZone);

        String vnp_CreateDate = formatter.format(cld.getTime());
        vnp_Params.put("vnp_CreateDate", vnp_CreateDate);

        cld.add(Calendar.MINUTE, 15);
        String vnp_ExpireDate = formatter.format(cld.getTime());
        vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);

        // 1. Sắp xếp danh sách tham số theo A-Z
        List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
        Collections.sort(fieldNames);

        // 2. Xây dựng đồng thời hashData và query theo chuẩn mẫu VNPAY Java
        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();
        for (String fieldName : fieldNames) {
            String fieldValue = vnp_Params.get(fieldName);
            if (fieldValue != null && !fieldValue.isEmpty()) {
                try {
                    // hashData
                    hashData.append(fieldName).append('=')
                            .append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString())).append('&');
                    // query
                    query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString())).append('=')
                            .append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString())).append('&');
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        // Xóa dấu '&' cuối cùng
        if (hashData.length() > 0) hashData.setLength(hashData.length() - 1);
        if (query.length() > 0) query.setLength(query.length() - 1);

        // 3. Ký số trên chuỗi hashData
        String vnp_SecureHash = VnPayConfig.hmacSHA512(vnPayConfig.getVnpHashSecret(), hashData.toString());
        String paymentUrl = vnPayConfig.getVnpPayUrl() + "?" + query.toString() + "&vnp_SecureHash=" + vnp_SecureHash;

        return paymentUrl;
    }
    @Override
    public boolean isValidSignature(Map<String, String> params) {
        if (params == null) {
            return false;
        }

        String receivedHash = params.get("vnp_SecureHash");
        String merchantCode = vnPayConfig.getVnpTmnCode();

        if (receivedHash == null
                || !receivedHash.matches("(?i)[0-9a-f]{128}")
                || merchantCode == null
                || merchantCode.isBlank()
                || !merchantCode.equals(params.get("vnp_TmnCode"))) {
            return false;
        }

        Map<String, String> fields = new HashMap<>();

        params.forEach((key, value) -> {
            if (key != null
                    && key.startsWith("vnp_")
                    && !"vnp_SecureHash".equals(key)
                    && !"vnp_SecureHashType".equals(key)
                    && value != null
                    && !value.isEmpty()) {
                fields.put(key, value);
            }
        });

        String expectedHash = VnPayConfig.hashAllFields(
                fields, vnPayConfig.getVnpHashSecret());

        if (expectedHash == null || expectedHash.length() != 128) {
            return false;
        }

        return MessageDigest.isEqual(
                expectedHash.toLowerCase(Locale.ROOT)
                        .getBytes(StandardCharsets.US_ASCII),
                receivedHash.toLowerCase(Locale.ROOT)
                        .getBytes(StandardCharsets.US_ASCII));
    }

    @Override
    @Transactional
    public Map<String, String> processIpn(Map<String, String> params) {
        // Chữ ký sai: kết thúc trước khi truy cập hoặc sửa thanh toán.
        if (!isValidSignature(params)) {
            return ipnResult("97", "Invalid signature");
        }

        String reference = params.get("vnp_TxnRef");
        String amountText = params.get("vnp_Amount");
        String responseCode = params.get("vnp_ResponseCode");
        String transactionStatus = params.get("vnp_TransactionStatus");

        if (reference == null || reference.isBlank()
                || responseCode == null || responseCode.isBlank()
                || transactionStatus == null || transactionStatus.isBlank()) {
            return ipnResult("99", "Invalid request");
        }

        if (amountText == null || !amountText.matches("\\d+")) {
            return ipnResult("04", "Invalid amount");
        }

        String normalizedReference = reference.replace("-", "")
                .toUpperCase(Locale.ROOT);

        Payment payment = paymentRepository
                .findByReferenceForUpdate(normalizedReference)
                .orElse(null);

        if (payment == null
                || payment.getPaymentMethod() != PaymentMethod.VNPAY) {
            return ipnResult("01", "Order not found");
        }

        BigDecimal receivedAmount = new BigDecimal(amountText);

        if (payment.getAmount() == null
                || receivedAmount.compareTo(
                        payment.getAmount().movePointRight(2)) != 0) {
            return ipnResult("04", "Invalid amount");
        }

        // Chỉ tiếp nhận kết quả cho thanh toán đang chờ.
        if (payment.getPaymentStatus() != PaymentStatus.PENDING) {
            return ipnResult("02", "Order already confirmed");
        }

        boolean success = "00".equals(responseCode)
                && "00".equals(transactionStatus);

        String transactionNo = params.get("vnp_TransactionNo");
        LocalDateTime paidAt = null;

        if (success) {
            if (transactionNo == null || transactionNo.isBlank()
                    || "0".equals(transactionNo)) {
                return ipnResult("99", "Invalid transaction");
            }

            String payDate = params.get("vnp_PayDate");
            if (payDate == null || payDate.isBlank()) {
                return ipnResult("99", "Invalid payment date");
            }

            try {
                paidAt = LocalDateTime.parse(
                        payDate,
                        DateTimeFormatter.ofPattern("uuuuMMddHHmmss")
                                .withResolverStyle(ResolverStyle.STRICT));
            } catch (DateTimeParseException ex) {
                return ipnResult("99", "Invalid payment date");
            }
        }

        payment.setPaymentStatus(
                success ? PaymentStatus.SUCCESS : PaymentStatus.FAILED);

        if (transactionNo != null && !transactionNo.isBlank()
                && !"0".equals(transactionNo)) {
            payment.setTransactionNo(transactionNo);
        }

        payment.setPaymentTime(paidAt);
        paymentRepository.save(payment);

        // Trạng thái xử lý đơn hàng vẫn do chi nhánh xác nhận.
        return ipnResult("00", "Confirm Success");
    }

    private Map<String, String> ipnResult(String code, String message) {
        return Map.of("RspCode", code, "Message", message);
    }
}
