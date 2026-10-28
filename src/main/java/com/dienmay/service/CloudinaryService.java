package com.dienmay.service;

import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;

public interface CloudinaryService {

    String uploadFile(MultipartFile file, String folder) throws IOException;

    String uploadPrivateProof(MultipartFile file, String folder) throws IOException;

    void deleteFile(String publicId);

    String generateSignedUrl(String publicId, int expirationSeconds);
}