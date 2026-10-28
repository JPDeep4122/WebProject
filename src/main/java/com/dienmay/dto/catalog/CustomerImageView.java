package com.dienmay.dto.catalog;

import java.io.Serial;
import java.io.Serializable;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CustomerImageView implements Serializable {
	@Serial private static final long serialVersionUID = 1L;
	private Long id;
	private String imageUrl;
}
