package com.dienmay.service.impl;

import com.dienmay.dto.category.*;
import com.dienmay.entity.product.Category;
import com.dienmay.repository.product.CategoryRepository;
import com.dienmay.service.CategoryService;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.text.Normalizer;
import java.util.Locale;


@Service 
@Transactional 
public class CategoryServiceImpl implements CategoryService {
    private final CategoryRepository categoryRepository;

    public CategoryServiceImpl(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    @Override
    public CategoryResponse create(CategoryCreateRequest request) {
        if(categoryRepository.existsBySlug(request.getSlug().trim())) {
            throw new RuntimeException("Slug đã tồn tại");
        }

        Category category = new Category();
        category.setName(request.getName().trim());
        category.setSlug(request.getSlug().trim());
        category.setIcon(request.getIcon());

        String parentSelection = request.getParentId();
        if ("OTHER".equals(parentSelection)) {
            String parentName = request.getNewParentName() == null
                    ? "" : request.getNewParentName().trim();
            if (parentName.isBlank()) {
                throw new IllegalArgumentException("Vui lòng nhập tên danh mục cha mới.");
            }
            Category newParent = new Category();
            newParent.setName(parentName);
            newParent.setSlug(uniqueSlug(parentName));
            newParent.setActive(true);
            category.setParent(categoryRepository.save(newParent));
        } else if (parentSelection != null && !parentSelection.isBlank()) {
            Long parentId;
            try {
                parentId = Long.valueOf(parentSelection);
            } catch (NumberFormatException ex) {
                throw new IllegalArgumentException("Danh mục cha không hợp lệ.");
            }
            Category parent = categoryRepository.findById(parentId)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy danh mục cha"));
            category.setParent(parent);
        }
        Category saved = categoryRepository.save(category);

        return toResponse(saved);
    }

    private String uniqueSlug(String name) {
        String normalized = Normalizer.normalize(name.toLowerCase(Locale.ROOT).replace('đ', 'd'),
                Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-|-$", "");
        if (normalized.isBlank()) normalized = "danh-muc";
        String candidate = normalized;
        int suffix = 2;
        while (categoryRepository.existsBySlug(candidate)) {
            String tail = "-" + suffix++;
            candidate = normalized.substring(0, Math.min(normalized.length(), 100 - tail.length())) + tail;
        }
        return candidate;
    }


    @Override
    public CategoryResponse update(
        Long id,
        CategoryUpdateRequest request
    ) {
        Category category = categoryRepository
            .findById(id)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy danh mục"));
        categoryRepository.findBySlug(request.getSlug().trim()).ifPresent(existing -> {
            if (!existing.getId().equals(id)) throw new RuntimeException("Slug đã tồn tại");
        });
        if (request.getParentId() != null && request.getParentId().equals(id)) {
            throw new RuntimeException (
                "Danh mục không thể làm cha của chính nó"
            );
        }

        category.setName(request.getName().trim());
        category.setSlug(request.getSlug().trim());
        category.setIcon(request.getIcon());

        if(request.getActive() != null) {
            category.setActive(request.getActive());
        }

        if(request.getParentId() == null) {
            category.setParent(null);
        } else {

            Category parent = categoryRepository
                .findById(request.getParentId())
                .orElseThrow(() -> new RuntimeException(
                     "Không tìm thấy danh mục cha"
                ));

                if (isDescendant(parent, category)) {
                    throw new RuntimeException (
                          "Không thể chọn danh mục con làm danh mục cha"
                    );
                }
                category.setParent(parent);
        }
        return toResponse(
                categoryRepository.save(category)
        );
    }
        @Override
    @Transactional(readOnly = true)
    public CategoryResponse getById(Long id) {

        Category category = categoryRepository
                .findById(id)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Không tìm thấy danh mục"));

        return toResponse(category);
    }

    @Override
    @Transactional(readOnly = true)
    public List<CategoryResponse> getAll() {

        return categoryRepository
                .findAll()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<CategoryTreeResponse> getTree() {

        List<Category> roots =
                categoryRepository.findByParentIsNull();

        return roots
                .stream()
                .map(this::buildTree)
                .toList();
    }

    @Override
    public void delete(Long id) {

        Category category = categoryRepository
                .findById(id)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Không tìm thấy danh mục"));

        if (!category.getChildren().isEmpty()) {

            throw new RuntimeException(
                    "Không thể xóa danh mục đang có danh mục con");
        }

        categoryRepository.delete(category);
    }

    private CategoryResponse toResponse(Category category) {

        CategoryResponse response = new CategoryResponse();

        response.setId(category.getId());
        response.setName(category.getName());
        response.setSlug(category.getSlug());
        response.setIcon(category.getIcon());
        response.setActive(category.isActive());

        if (category.getParent() != null) {

            response.setParentId(
                    category.getParent().getId());

            response.setParentName(
                    category.getParent().getName());
        }

        return response;
    }

    private CategoryTreeResponse buildTree(Category category) {

        CategoryTreeResponse response =
                new CategoryTreeResponse();

        response.setId(category.getId());
        response.setName(category.getName());
        response.setSlug(category.getSlug());
        response.setIcon(category.getIcon());
        response.setActive(category.isActive());

        response.setChildren(
                category.getChildren()
                        .stream()
                        .map(this::buildTree)
                        .toList()
        );

        return response;
    }

    private boolean isDescendant(
            Category possibleParent,
            Category category) {

        Category current = possibleParent;

        while (current != null) {

            if (current.getId().equals(category.getId())) {
                return true;
            }

            current = current.getParent();
        }

        return false;
    }
}
