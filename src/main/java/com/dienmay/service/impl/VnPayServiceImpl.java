package com.dienmay.service.impl;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dienmay.config.vnpay.VnPayConfig;
import com.dienmay.entity.order.Order;
import com.dienmay.entity.order.OrderStatus;
import com.dienmay.entity.payment.Payment;
import com.dienmay.entity.payment.PaymentStatus;
import com.dienmay.repository.order.OrderRepository;
import com.dienmay.repository.payment.PaymentRepository;
import com.dienmay.service.payment.VnPayService;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class VnPayServiceImpl implements VnPayService {

    private final VnPayConfig vnPayConfig;
    private final OrderRepository orderRepository;
    private final PaymentRepository paymentRepository;

    @Override
    public String createPaymentUrl(Order order, HttpServletRequest request) {
        String vnp_Version = "2.1.0";
        String vnp_Command = "pay";
        // Chuẩn hóa vnp_TxnRef: Chỉ gồm chữ và số (loại bỏ dấu gạch ngang nếu có)
        String vnp_TxnRef = order.getOrderCode().replace("-", "");
        String vnp_IpAddr = VnPayConfig.getIpAddress(request);
        String vnp_TmnCode = vnPayConfig.getVnpTmnCode();

        // Số tiền theo quy định VNPAY phải nhân với 100
        long amount = order.getFinalAmount().longValue() * 100;

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

        System.out.println("====== [VNPAY DEBUG] ======");
        System.out.println("TmnCode: " + vnp_TmnCode);
        System.out.println("HashData: " + hashData.toString());
        System.out.println("SecureHash: " + vnp_SecureHash);
        System.out.println("Payment URL: " + paymentUrl);
        System.out.println("===========================");

        return paymentUrl;
    }
    @Override
    @Transactional
    public boolean processPaymentCallback(Map<String, String> params) {
        Map<String, String> fields = new HashMap<>();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            String fieldName = entry.getKey();
            String fieldValue = entry.getValue();
            if (fieldValue != null && !fieldValue.isEmpty()) {
                fields.put(fieldName, fieldValue);
            }
        }

        String vnp_SecureHash = params.get("vnp_SecureHash");
        fields.remove("vnp_SecureHashType");
        fields.remove("vnp_SecureHash");

        // Băm lại toàn bộ fields trả về để so khớp chữ ký
        String signValue = VnPayConfig.hashAllFields(fields, vnPayConfig.getVnpHashSecret());
        boolean isValidSignature = signValue.equalsIgnoreCase(vnp_SecureHash);

        String orderCode = params.get("vnp_TxnRef");
        String responseCode = params.get("vnp_ResponseCode");
        String transactionNo = params.get("vnp_TransactionNo");

        Order order = orderRepository.findByOrderCode(orderCode)
                .orElseGet(() -> orderRepository.findAll().stream()
                        .filter(o -> o.getOrderCode() != null && o.getOrderCode().replace("-", "").equals(orderCode))
                        .findFirst().orElse(null));        if (order == null) {
            return false;
        }

        Payment payment = paymentRepository.findByOrderId(order.getId()).orElse(null);

        // Thành công khi: Mã phản hồi "00" VÀ Chữ ký xác thực hợp lệ
        if ("00".equals(responseCode) && isValidSignature) {
            if (payment != null) {
                payment.setPaymentStatus(PaymentStatus.SUCCESS);
                payment.setTransactionNo(transactionNo);
                payment.setPaymentTime(LocalDateTime.now());
                paymentRepository.save(payment);
            }
            order.setStatus(OrderStatus.CONFIRMED);
            orderRepository.save(order);
            return true;
        } else {
            if (payment != null) {
                payment.setPaymentStatus(PaymentStatus.FAILED);
                payment.setTransactionNo(transactionNo);
                paymentRepository.save(payment);
            }
            return false;
        }
    }
}