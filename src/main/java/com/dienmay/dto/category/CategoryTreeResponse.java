package com.dienmay.dto.category;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class CategoryTreeResponse {

    private Long id;

    private String name;

    private String slug;

    private String icon;

    private boolean active;

    private List<CategoryTreeResponse> children = new ArrayList<>();
}