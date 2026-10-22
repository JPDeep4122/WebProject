package com.dienmay.controller.client;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.server.ResponseStatusException;

import com.dienmay.repository.branch.BranchRepository;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/info")
@RequiredArgsConstructor
public class InformationController {

    private final BranchRepository branchRepository;

    @GetMapping("/{page}")
    public String information(
            @PathVariable String page,
            Model model) {

        switch (page) {
            case "about" -> {
                model.addAttribute("pageTitle", "Giới thiệu TECHSEVEN");
                model.addAttribute("pageParagraphs", List.of(
                        "TECHSEVEN giúp bạn tìm kiếm và đặt mua tivi, "
                                + "tủ lạnh, máy giặt và các thiết bị gia dụng.",
                        "Bạn có thể xem thông tin sản phẩm, "
                                + "kiểm tra tồn kho theo chi nhánh "
                                + "và theo dõi đơn hàng trên website."
                ));
            }

            case "branches" -> {
                model.addAttribute("pageTitle", "Hệ thống chi nhánh");
                model.addAttribute("showBranches", true);
                model.addAttribute(
                        "branches",
                        branchRepository.findByActiveTrue());
            }

            case "warranty" -> {
                model.addAttribute("pageTitle", "Thông tin bảo hành");
                model.addAttribute("pageParagraphs", List.of(
                        "Vui lòng kiểm tra thông tin bảo hành "
                                + "trên trang chi tiết sản phẩm.",
                        "Khi cần hỗ trợ, hãy chuẩn bị mã đơn hàng, "
                                + "tên sản phẩm và mô tả sự cố "
                                + "để cửa hàng kiểm tra."
                ));
            }

            case "shopping-guide" -> {
                model.addAttribute("pageTitle", "Hướng dẫn mua hàng");
                model.addAttribute("pageParagraphs", List.of(
                        "1. Tìm sản phẩm bằng thanh tìm kiếm "
                                + "hoặc chọn danh mục.",
                        "2. Mở chi tiết sản phẩm, chọn số lượng "
                                + "và bấm Thêm vào giỏ hàng hoặc Mua ngay.",
                        "3. Kiểm tra sản phẩm, nhập thông tin giao hàng "
                                + "và xem phí vận chuyển.",
                        "4. Chọn phương thức thanh toán "
                                + "và xác nhận đặt hàng.",
                        "5. Lưu mã đơn để theo dõi "
                                + "trong mục Đơn hàng hoặc Tra cứu đơn hàng."
                ));
            }

            case "returns" -> {
                model.addAttribute("pageTitle", "Hướng dẫn yêu cầu trả hàng");
                model.addAttribute("pageParagraphs", List.of(
                        "Đăng nhập, mở mục Đơn hàng "
                                + "và chọn đơn hàng cần hỗ trợ.",
                        "Với đơn đủ điều kiện, sử dụng chức năng "
                                + "Yêu cầu trả hàng trong chi tiết đơn "
                                + "và nhập lý do.",
                        "Theo dõi trạng thái yêu cầu "
                                + "trong trang chi tiết đơn hàng."
                ));
            }

            default -> throw new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "Không tìm thấy trang thông tin.");
        }

        return "client/information";
    }
}