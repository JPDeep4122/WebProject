package com.dienmay.service;

import java.util.List;
import com.dienmay.entity.Category;
import com.dienmay.entity.Product;

public interface ProductService {
    List<Category> getAllCategories();
    List<Product> getFeaturedProducts();
    List<Product> getLatestProducts();
}