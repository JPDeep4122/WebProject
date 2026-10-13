package com.dienmay.dto.category;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CategoryUpdateRequest {

    @NotBlank(message = "Tên danh mục không được để trống")
    @Size(max = 100, message = "Tên danh mục tối đa 100 ký tự")
    private String name;

    @NotBlank(message = "Slug không được để trống")
    @Size(max = 100, message = "Slug tối đa 100 ký tự")
    private String slug;

    @Size(max = 255, message = "Icon tối đa 255 ký tự")
    private String icon;

    private Boolean active;

    private Long parentId;
}