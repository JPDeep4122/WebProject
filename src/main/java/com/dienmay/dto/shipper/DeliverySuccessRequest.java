package com.dienmay.dto.shipper;

import java.math.BigDecimal;
import com.dienmay.entity.order.DeliveryCollectionMethod;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeliverySuccessRequest {
    private String receivedBy;                  
    private DeliveryCollectionMethod collectionMethod; 
    private BigDecimal collectedAmount;          
    private boolean codConfirmed;               
    private String completionNote;               
}