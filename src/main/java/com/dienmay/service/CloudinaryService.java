package com.dienmay.service;

import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;

public interface CloudinaryService {

    /**
     * Upload file (ảnh/video) lên Cloudinary
     * @param file file nhận từ request
     * @param folder tên thư mục trên Cloudinary (vd: "products", "reviews", "avatars")
     * @return đường dẫn secure_url của file đã upload
     * @throws IOException khi đọc dữ liệu file bị lỗi
     */
    String uploadFile(MultipartFile file, String folder) throws IOException;

}