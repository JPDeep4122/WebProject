package com.dienmay.controller.client;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.dienmay.entity.branch.Branch;
import com.dienmay.repository.branch.BranchRepository;

import lombok.RequiredArgsConstructor;

@ControllerAdvice(basePackages = "com.dienmay.controller.client")
@RequiredArgsConstructor
public class StorefrontBranchAdvice {

    private static final String HCM = "TP. Hồ Chí Minh";
    private static final String HN = "Hà Nội";

    private final BranchRepository branchRepository;

    @ModelAttribute
    public void addHeaderBranches(Model model,
            @CookieValue(name = "selectedBranchId", required = false) String selectedBranchId) {

        Map<String, List<Branch>> groups = new LinkedHashMap<>();
        groups.put(HCM, new ArrayList<>());
        groups.put(HN, new ArrayList<>());

        branchRepository.findByActiveTrue().stream()
                .sorted(Comparator.comparing(Branch::getName, String.CASE_INSENSITIVE_ORDER))
                .forEach(branch -> {
                    String region = regionOf(branch.getProvince());
                    if (region != null) groups.get(region).add(branch);
                });
        groups.values().removeIf(List::isEmpty);

        Long selectedId = parseId(selectedBranchId);
        Branch selected = groups.values().stream().flatMap(List::stream)
                .filter(branch -> branch.getId().equals(selectedId))
                .findFirst()
                .orElseGet(() -> groups.values().stream().flatMap(List::stream).findFirst().orElse(null));

        model.addAttribute("headerBranchGroups", groups);
        model.addAttribute("headerSelectedBranch", selected);
    }

    private String regionOf(String province) {
        if (province == null) return null;
        String value = Normalizer.normalize(province.toLowerCase().replace("đ", "d"), Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "").replaceAll("[^a-z0-9 ]", " ")
                .replaceAll("\\s+", " ").trim()
                .replaceFirst("^(thanh pho|tp|tinh)\\s+", "");
        if (value.equals("hcm") || value.equals("ho chi minh") || value.equals("sai gon")) return HCM;
        if (value.equals("hn") || value.equals("ha noi")) return HN;
        return null;
    }

    private Long parseId(String raw) {
        try {
            return raw == null || raw.isBlank() ? null : Long.valueOf(raw.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}