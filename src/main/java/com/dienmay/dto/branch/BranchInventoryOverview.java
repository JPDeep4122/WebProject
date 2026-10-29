package com.dienmay.dto.branch;

import java.util.List;

import org.springframework.data.domain.Page;

import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.branch.BranchInventory;


import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class BranchInventoryOverview {
    private final Page<BranchInventory> inventories;
    private final List<Branch> branches;

    private final Long selectedBranchId;
    private final boolean canChooseBranch;
    private final boolean canEditInventory;
    private final String warning;
}
