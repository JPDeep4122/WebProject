package com.dienmay.service.order;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.dienmay.service.CloudinaryService;

@Service
public class DeliveryProofStorageService {

    private static final long MAX_FILE_SIZE_BYTES = 5L * 1024L * 1024L; // 5 MB
    private final Path localFallbackRoot = Paths.get(System.getProperty("user.dir"), "private-storage", "delivery-proofs");
    private final CloudinaryService cloudinaryService;

    @Autowired
    public DeliveryProofStorageService(@Autowired(required = false) CloudinaryService cloudinaryService) {
        this.cloudinaryService = cloudinaryService;
    }

    public void validateProofFile(MultipartFile file, boolean required) {
        if (file == null || file.isEmpty()) {
            if (required) {
                throw new IllegalArgumentException("Vui lòng chụp hoặc chọn ít nhất 1 ảnh minh chứng bàn giao hàng.");
            }
            return;
        }
        if (file.getSize() > MAX_FILE_SIZE_BYTES) {
            throw new IllegalArgumentException("Ảnh minh chứng không được vượt quá 5 MB.");
        }
        detectValidImageExtension(file);
    }

    public String storePrivateProof(MultipartFile file, Long assignmentId, int attemptNo) {
        validateProofFile(file, true);

        // 1. Nếu có Cloudinary, lưu lên Cloudinary ở chế độ authenticated
        if (cloudinaryService != null) {
            try {
                return cloudinaryService.uploadPrivateProof(file, "delivery-proofs/asg_" + assignmentId);
            } catch (Exception ignored) {
            }
        }

        // 2. Fallback lưu vào thư mục riêng tư nội bộ máy chủ
        String extension = detectValidImageExtension(file);
        String proofPublicId = "proof_asg" + assignmentId + "_att" + attemptNo + "_"
                + UUID.randomUUID().toString().replace("-", "") + extension;

        try {
            Files.createDirectories(localFallbackRoot);
            Path targetPath = localFallbackRoot.resolve(proofPublicId).normalize();
            if (!targetPath.startsWith(localFallbackRoot.normalize())) {
                throw new IllegalArgumentException("Định danh ảnh minh chứng không hợp lệ.");
            }
            try (InputStream in = file.getInputStream()) {
                Files.copy(in, targetPath, StandardCopyOption.REPLACE_EXISTING);
            }
            return proofPublicId;
        } catch (IOException ex) {
            throw new IllegalStateException("Không thể lưu ảnh minh chứng. Vui lòng thử lại.", ex);
        }
    }

    public void deleteProofQuietly(String proofPublicId) {
        if (proofPublicId == null || proofPublicId.isBlank()) {
            return;
        }
        if (cloudinaryService != null) {
            try {
                cloudinaryService.deleteFile(proofPublicId);
            } catch (Exception ignored) {
            }
        }
        try {
            Path target = localFallbackRoot.resolve(proofPublicId).normalize();
            if (target.startsWith(localFallbackRoot.normalize())) {
                Files.deleteIfExists(target);
            }
        } catch (Exception ignored) {
        }
    }

    public String resolveViewUrl(String proofPublicId, String contextPath) {
        if (proofPublicId == null || proofPublicId.isBlank()) {
            return null;
        }
        if (cloudinaryService != null) {
            try {
                String signed = cloudinaryService.generateSignedUrl(proofPublicId, 3600);
                if (signed != null && !signed.isBlank()) {
                    return signed;
                }
            } catch (Exception ignored) {
            }
        }
        return (contextPath == null ? "" : contextPath) + "/shipper/orders/proof/" + proofPublicId;
    }

    public byte[] loadLocalProofBytes(String proofPublicId) throws IOException {
        Path target = localFallbackRoot.resolve(proofPublicId).normalize();
        if (!target.startsWith(localFallbackRoot.normalize()) || !Files.exists(target)) {
            throw new IllegalArgumentException("Không tìm thấy file minh chứng.");
        }
        return Files.readAllBytes(target);
    }

    private String detectValidImageExtension(MultipartFile file) {
        try (InputStream in = file.getInputStream()) {
            byte[] header = in.readNBytes(8);
            if (header.length >= 3
                    && (header[0] & 0xFF) == 0xFF
                    && (header[1] & 0xFF) == 0xD8
                    && (header[2] & 0xFF) == 0xFF) {
                return ".jpg";
            }
            if (header.length >= 8
                    && (header[0] & 0xFF) == 0x89
                    && (header[1] & 0xFF) == 0x50
                    && (header[2] & 0xFF) == 0x4E
                    && (header[3] & 0xFF) == 0x47) {
                return ".png";
            }
        } catch (IOException ignored) {
        }
        throw new IllegalArgumentException("File tải lên không phải ảnh JPG hoặc PNG hợp lệ.");
    }
}