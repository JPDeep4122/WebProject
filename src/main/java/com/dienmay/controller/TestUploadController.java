package com.dienmay.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.dienmay.service.CloudinaryService;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/test")
public class TestUploadController {

    @Autowired
    private CloudinaryService cloudinaryService;

    @PostMapping("/upload")
    public ResponseEntity<?> testUpload(@RequestParam("file") MultipartFile file) {
        try {
            String url = cloudinaryService.uploadFile(file, "test_uploads");
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("url", url);
            return ResponseEntity.ok(response);
        } catch (IOException e) {
            return ResponseEntity.badRequest().body("Lỗi upload: " + e.getMessage());
        }
    }
}