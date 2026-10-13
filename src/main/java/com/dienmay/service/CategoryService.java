package com.dienmay.service;

import com.dienmay.dto.category.CategoryCreateRequest;
import com.dienmay.dto.category.CategoryResponse;
import com.dienmay.dto.category.CategoryTreeResponse;
import com.dienmay.dto.category.CategoryUpdateRequest;

import java.util.List;

public interface CategoryService {

    CategoryResponse create(CategoryCreateRequest request);

    CategoryResponse update(Long id, CategoryUpdateRequest request);

    CategoryResponse getById(Long id);

    List<CategoryResponse> getAll();

    List<CategoryTreeResponse> getTree();

    void delete(Long id);
}