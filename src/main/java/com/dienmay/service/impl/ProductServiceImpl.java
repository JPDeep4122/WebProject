package com.dienmay.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.dienmay.entity.Category;
import com.dienmay.entity.Product;
import com.dienmay.repository.CategoryRepository;
import com.dienmay.repository.ProductRepository;
import com.dienmay.service.ProductService;

@Service
public class ProductServiceImpl implements ProductService {

    @Autowired private CategoryRepository categoryRepo;
    @Autowired private ProductRepository productRepo;

    @Override
    @Transactional(readOnly = true)
    public List<Category> getAllCategories() {
        return categoryRepo.findByActiveTrue();
    }

    @Override
    @Transactional(readOnly = true)
    public List<Product> getFeaturedProducts() {
        return productRepo.findTop8ByActiveTrueAndFeaturedTrueOrderByCreatedAtDesc();
    }

    @Override
    @Transactional(readOnly = true)
    public List<Product> getLatestProducts() {
        return productRepo.findTop8ByActiveTrueOrderByCreatedAtDesc();
    }
}