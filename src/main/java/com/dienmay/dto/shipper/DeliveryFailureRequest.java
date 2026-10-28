package com.dienmay.dto.shipper;

import com.dienmay.entity.order.DeliveryFailureCode;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeliveryFailureRequest {
    private DeliveryFailureCode failureCode; 
    private String failureReason;            
}