package com.dienmay.dto.order;

import java.util.List;

import org.springframework.data.domain.Page;

import com.dienmay.entity.branch.Branch;
import com.dienmay.entity.order.OrderReturnRequest;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class ReturnRequestOverview {
    private final Page<OrderReturnRequest> requests;
    private final List<Branch> branches;
    private final Long selectedBranchId;
    private final boolean canChooseBranch;
    private final String warning;
}
