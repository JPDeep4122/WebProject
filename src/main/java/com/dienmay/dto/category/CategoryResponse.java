package com.dienmay.dto.category;

import lombok.Data;

@Data
public class CategoryResponse {

    private Long id;

    private String name;

    private String slug;

    private String icon;

    private boolean active;

    private Long parentId;

    private String parentName;
}