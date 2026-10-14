package com.dienmay.service.impl;

import com.dienmay.dto.category.*;
import com.dienmay.entity.product.Category;
import com.dienmay.repository.product.CategoryRepository;
import com.dienmay.service.CategoryService;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


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

        if(request.getParentId() != null) {
            Category parent = categoryRepository
                .findById(request.getParentId())
                .orElseThrow(() -> new RuntimeException(
                    "Không tìm thấy danh mục cha"
                ));
            category.setParent(parent);
        }
        Category saved = categoryRepository.save(category);

        return toResponse(saved);
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
