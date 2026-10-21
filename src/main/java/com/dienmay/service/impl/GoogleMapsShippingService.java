package com.dienmay.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.Normalizer;
import java.net.http.HttpClient;
import java.time.Duration;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import com.dienmay.dto.checkout.ShippingQuoteResponse;
import com.dienmay.entity.branch.Branch;
import com.dienmay.repository.branch.BranchRepository;
import com.dienmay.service.checkout.ShippingService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class GoogleMapsShippingService implements ShippingService {
    private static final String ROUTE_MATRIX_URL = "https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix";

    private final BranchRepository branchRepository;
    private final ObjectMapper objectMapper;
    private final TransactionTemplate transactionTemplate;
    private final RestClient restClient = createRestClient();

    private static RestClient createRestClient() {
        HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
        JdkClientHttpRequestFactory factory = new JdkClientHttpRequestFactory(client);
        factory.setReadTimeout(Duration.ofSeconds(10));
        return RestClient.builder().requestFactory(factory).build();
    }

    @Value("${google.maps.api-key:}")
    private String apiKey;

    @Override
    public ShippingQuoteResponse quote(String shippingAddress, String province) {
        if (shippingAddress == null || shippingAddress.isBlank() || province == null || province.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập địa chỉ và tỉnh/thành phố nhận hàng.");
        }
        List<Branch> branches = transactionTemplate.execute(status -> branchRepository.findByActiveTrue());
        if (branches.isEmpty()) throw new IllegalStateException("Hiện chưa có chi nhánh phục vụ giao hàng.");

        List<Branch> sameProvinceBranches = branches.stream()
                .filter(branch -> sameProvince(branch.getProvince(), province)).toList();
        if (!sameProvinceBranches.isEmpty()) {
            Branch branch = sameProvinceBranches.get(0);
            return ShippingQuoteResponse.builder().branchId(branch.getId()).shippingFee(BigDecimal.ZERO).distanceKm(0)
                    .branchName(branch.getName()).sameProvince(true).build();
        }

        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("Cửa hàng chưa cấu hình Google Maps API key để tính phí giao khác tỉnh.");
        }
        List<Branch> routable = branches.stream().filter(b -> b.getProvince() != null && !b.getProvince().isBlank()).toList();
        if (routable.isEmpty()) throw new IllegalStateException("Vui lòng cập nhật tỉnh/thành cho các chi nhánh trước khi tính phí.");

        try {
            List<Map<String, Object>> origins = routable.stream()
                    .map(b -> Map.<String, Object>of("waypoint", Map.of("address", b.getAddress())))
                    .toList();
            Map<String, Object> request = Map.of(
                    "origins", origins,
                    "destinations", List.of(Map.of("waypoint", Map.of("address", shippingAddress + ", " + province + ", Việt Nam"))),
                    "travelMode", "DRIVE",
                    "languageCode", "vi",
                    "regionCode", "VN");
            String response = restClient.post().uri(ROUTE_MATRIX_URL)
                    .header("X-Goog-Api-Key", apiKey)
                    .header("X-Goog-FieldMask", "originIndex,destinationIndex,distanceMeters,status,condition")
                    .header(HttpHeaders.CONTENT_TYPE, "application/json")
                    .body(request).retrieve().body(String.class);

            JsonNode routes = objectMapper.readTree(response);
            long nearestMeters = Long.MAX_VALUE;
            int nearestIndex = -1;
            for (JsonNode route : routes) {
                if (!"ROUTE_EXISTS".equals(route.path("condition").asText())) continue;
                long meters = route.path("distanceMeters").asLong(Long.MAX_VALUE);
                if (meters < nearestMeters) {
                    nearestMeters = meters;
                    nearestIndex = route.path("originIndex").asInt(-1);
                }
            }
            if (nearestIndex < 0 || nearestMeters == Long.MAX_VALUE) {
                throw new IllegalStateException("Google Maps không tìm được tuyến giao hàng đến địa chỉ này.");
            }
            double km = nearestMeters / 1000d;
            return ShippingQuoteResponse.builder().branchId(routable.get(nearestIndex).getId()).shippingFee(feeFor(km)).distanceKm(km)
                    .branchName(routable.get(nearestIndex).getName()).sameProvince(false).build();
        } catch (RestClientException | java.io.IOException ex) {
            throw new IllegalStateException("Không thể tính quãng đường với Google Maps. Vui lòng thử lại sau.", ex);
        }
    }

    private BigDecimal feeFor(double km) {
        if (km <= 50) return BigDecimal.valueOf(15000);
        if (km <= 100) return BigDecimal.valueOf(30000);
        if (km <= 200) return BigDecimal.valueOf(50000);
        long extraBlocks = (long) Math.ceil((km - 200) / 20d);
        return BigDecimal.valueOf(50000 + extraBlocks * 5000).setScale(0, RoundingMode.CEILING);
    }

    private boolean sameProvince(String first, String second) {
        return normalize(first).equals(normalize(second));
    }

    private String normalize(String value) {
        if (value == null) return "";
        String normalized = Normalizer.normalize(value.toLowerCase().replace("đ", "d"), Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "").replaceAll("[^a-z0-9 ]", " ").replaceAll("\\s+", " ").trim();
        normalized = normalized.replaceFirst("^(thanh pho|tp|tinh)\\s+", "").trim();
        if (normalized.equals("hcm") || normalized.equals("ho chi minh")) return "ho chi minh";
        if (normalized.equals("hn") || normalized.equals("ha noi")) return "ha noi";
        return normalized;
    }
}
