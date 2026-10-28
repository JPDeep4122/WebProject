package com.dienmay.controller.client;

import java.security.Principal;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.server.ResponseStatusException;

import com.dienmay.entity.order.Order;
import com.dienmay.entity.payment.PaymentStatus;
import com.dienmay.service.checkout.CheckoutService;
import com.dienmay.service.payment.VnPayService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.net.URI;
import java.time.format.DateTimeFormatter;

import org.springframework.beans.factory.annotation.Value;

import com.dienmay.entity.payment.PaymentMethod;

@Slf4j
@Controller
@RequestMapping("/payment")
@RequiredArgsConstructor
public class PaymentController {

	private final VnPayService vnPayService;
	private final CheckoutService checkoutService;

	@Value("${vnpay.pay-url:}")
	private String vnpayPayUrl;

	@GetMapping("/vnpay-return")
	public String vnpayReturn(@RequestParam Map<String, String> allParams, Principal principal, HttpSession session,
			Model model) {

		if (!vnPayService.isValidSignature(allParams)) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Thông tin thanh toán không hợp lệ.");
		}

		// Xử lý đồng bộ kết quả thanh toán (an toàn & chống lặp nhờ khóa bi quan trong
		// processIpn)
		// Giúp môi trường localhost (không có public IPN) vẫn cập nhật trạng thái
		// SUCCESS ngay lập tức.
		try {
			vnPayService.processIpn(allParams);
		} catch (Exception ex) {
			log.warn("Không thể cập nhật trạng thái thanh toán tại vnpay-return", ex);
		}

		String email = principal != null ? principal.getName() : null;

		Order order = checkoutService.getOrderByCode(allParams.get("vnp_TxnRef"), email, session);

		if (order.getPayment() == null) {
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy thông tin thanh toán.");
		}

		PaymentStatus status = order.getPayment().getPaymentStatus();

		var payment = order.getPayment();

		// paymentTime hiện được lưu từ vnp_PayDate theo giờ Việt Nam.
		// Không chuyển múi giờ thêm lần nữa.
		String paymentTimeText = payment.getPaymentTime() == null ? "Chưa có thông tin"
				: payment.getPaymentTime().format(DateTimeFormatter.ofPattern("dd/MM/uuuu HH:mm:ss"));

		// Xác định môi trường từ URL cấu hình phía server.
		boolean sandbox = false;

		try {
			sandbox = "sandbox.vnpayment.vn".equalsIgnoreCase(URI.create(vnpayPayUrl).getHost());
		} catch (IllegalArgumentException ex) {
			log.warn("Không xác định được môi trường VNPay từ cấu hình URL.");
		}

		// Thông báo phải phản ánh trạng thái hiện tại của đơn.
		// Không luôn ghi “chờ xác nhận” khi khách mở lại giao dịch cũ.
		String orderNextStep;

		if (order.getStatus() == null) {
			orderNextStep = "Vui lòng xem chi tiết đơn để kiểm tra tiến độ.";
		} else {
			orderNextStep = switch (order.getStatus()) {
			case PENDING -> "Đơn hàng đang chờ chi nhánh xác nhận.";

			case CONFIRMED -> "Chi nhánh đã xác nhận đơn hàng.";

			case PROCESSING -> "Chi nhánh đang chuẩn bị hàng cho bạn.";

			case SHIPPING -> "Đơn hàng đang được vận chuyển.";

			case DELIVERED -> "Đơn hàng đã được giao thành công.";

			case CANCELLED ->
				"Đơn hàng đã bị hủy. Nếu đã thanh toán, " + "vui lòng theo dõi thông tin đối soát và hoàn tiền.";

			case RETURN_REQUESTED -> "Đơn hàng đang có yêu cầu trả hàng hoặc hoàn tiền.";

			case RETURNED -> "Đơn hàng đã được trả lại. " + "Vui lòng xem chi tiết để theo dõi việc hoàn tiền.";
			};
		}

		boolean activeOrder = order.getStatus() != null && switch (order.getStatus()) {
		case PENDING, CONFIRMED, PROCESSING, SHIPPING, DELIVERED -> true;
		default -> false;
		};

		boolean fullyPrepaid = status == PaymentStatus.SUCCESS && payment.getPaymentMethod() == PaymentMethod.VNPAY
				&& payment.getAmount() != null && order.getFinalAmount() != null
				&& payment.getAmount().compareTo(order.getFinalAmount()) == 0 && activeOrder;

		model.addAttribute("paymentTimeText", paymentTimeText);
		model.addAttribute("isSandbox", sandbox);
		model.addAttribute("isRefunded", status == PaymentStatus.REFUNDED);
		model.addAttribute("orderNextStep", orderNextStep);
		model.addAttribute("fullyPrepaid", fullyPrepaid);

		model.addAttribute("order", order);
		model.addAttribute("isSuccess", status == PaymentStatus.SUCCESS);
		model.addAttribute("isPending", status == PaymentStatus.PENDING);
		model.addAttribute("transactionNo", order.getPayment().getTransactionNo());
		model.addAttribute("bankCode", allParams.get("vnp_BankCode"));
		model.addAttribute("cardType", allParams.get("vnp_CardType"));
		model.addAttribute("responseCode", allParams.get("vnp_ResponseCode"));

		return "client/payment-result";
	}

	@GetMapping("/vnpay-ipn")
	@ResponseBody
	public Map<String, String> vnpayIpn(@RequestParam Map<String, String> params) {

		try {
			return vnPayService.processIpn(params);
		} catch (Exception ex) {
			log.error("Không xử lý được IPN VNPay", ex);
			return Map.of("RspCode", "99", "Message", "Processing error");
		}
	}
}