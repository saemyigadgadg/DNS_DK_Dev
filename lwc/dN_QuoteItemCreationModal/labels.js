import DNS_B_Save from '@salesforce/label/c.DNS_B_Save'; 
import DNS_B_Cancel from '@salesforce/label/c.DNS_B_Cancel'; 
import DNS_B_ViewAll from '@salesforce/label/c.DNS_B_ViewAll'; 
import DNS_B_ShowSelected from '@salesforce/label/c.DNS_B_ShowSelected'; 
import DNS_B_BackToResult from '@salesforce/label/c.DNS_B_BackToResult'; 

import DNS_M_Success from '@salesforce/label/c.DNS_M_Success'; 
import DNS_M_GeneralError from '@salesforce/label/c.DNS_M_GeneralError'; 
import DNS_M_QuantityGreater0 from '@salesforce/label/c.DNS_M_QuantityGreater0'; 
import DNS_M_NoSelectItem from '@salesforce/label/c.DNS_M_NoSelectItem'; 
import DNS_M_ProductSaved from '@salesforce/label/c.DNS_M_ProductSaved'; 

import DNS_H_AddProducts from '@salesforce/label/c.DNS_H_AddProducts'; 
import DNS_H_StandardPriceBook from '@salesforce/label/c.DNS_H_StandardPriceBook'; 

import DNS_C_ProductName from '@salesforce/label/c.DNS_C_ProductName'; 
import DNS_F_Product from '@salesforce/label/c.DNS_F_Product'; 
import DNS_C_ProductCode from '@salesforce/label/c.DNS_C_ProductCode'; 
import DNS_C_Quantity from '@salesforce/label/c.DNS_C_Quantity'; 
import DNS_C_IsStrategicMaterial from '@salesforce/label/c.DNS_C_IsStrategicMaterial'; 
import DNS_C_NC from '@salesforce/label/c.DNS_C_NC'; 
import DNS_C_MaxMainSpindleSpeed from '@salesforce/label/c.DNS_C_MaxMainSpindleSpeed'; 
import DNS_C_MaxSpindleSpeed from '@salesforce/label/c.DNS_C_MaxSpindleSpeed'; 
import DNS_C_ToolStorageCapacity from '@salesforce/label/c.DNS_C_ToolStorageCapacity'; 
import DNS_C_MonitorSize from '@salesforce/label/c.DNS_C_MonitorSize'; 
import DNS_C_Region from '@salesforce/label/c.DNS_C_Region'; 
import DNS_C_ProductModel from '@salesforce/label/c.DNS_C_ProductModel'; 
import DNS_C_MOTOR from '@salesforce/label/c.DNS_C_MOTOR'; 
import DNS_B_Spindle from '@salesforce/label/c.DNS_B_Spindle'; 
import DNS_C_TOOL from '@salesforce/label/c.DNS_C_TOOL'; 
import DNS_C_CRTSize from '@salesforce/label/c.DNS_C_CRTSize'; 
import DNS_C_ETC from '@salesforce/label/c.DNS_C_ETC'; 

import DNS_C_ProdDescription from '@salesforce/label/c.DNS_C_ProdDescription'; 

import DNS_MSG_NoProductContactHeadquarters from '@salesforce/label/c.DNS_MSG_NoProductContactHeadquarters'; 


const customLabels = {
    DNS_B_Save // Save, 저장
    , DNS_B_Cancel // Cancel, 취소
    , DNS_B_ViewAll // View All, 모두 보기
    , DNS_B_ShowSelected // Show Selected, 선택 항목 보기
    , DNS_B_BackToResult // Back to Result, 결과로 돌아가기
    
    , DNS_M_Success // Success, 성공
    , DNS_M_GeneralError // Error Occurred, 오류가 발생했습니다
    , DNS_M_QuantityGreater0 // Quantity must be greater than 0., 수량은 0보다 커야 합니다.
    , DNS_M_NoSelectItem // No items selected. Please select an item first., 선택된 아이템이 없습니다. 아이템을 먼저 선택해주세요.
    , DNS_M_ProductSaved // The product has been saved., 제품이 저장되었습니다.

    , DNS_H_AddProducts // Add Products, 제품 추가
    , DNS_H_StandardPriceBook // Price Book : Standard Price Book, 가격 책자: 표준 가격 책자

    , DNS_C_ProductName // Product Name, 제품명
    , DNS_F_Product // Product, 제품
    , DNS_C_ProductCode // Product Code, 제품 코드
    , DNS_C_Quantity // Quantity, 수량
    , DNS_C_IsStrategicMaterial // Is Strategic Material, 전략 물자 여부
    , DNS_C_NC // NC, NC
    , DNS_C_MaxMainSpindleSpeed // Max. Main Spindle Speed, 최대 메인 스핀들 속도
    , DNS_C_MaxSpindleSpeed // Max. Spindle Speed, 최대 스핀들 속도
    , DNS_C_ToolStorageCapacity // Tool Storage Capacity, 툴 보관 용량
    , DNS_C_MonitorSize // Monitor Size, 모니터 크기
    , DNS_C_Region // Region, 지역
    , DNS_C_ProductModel // Model, 모델
    , DNS_C_MOTOR // MOTOR, 모터
    , DNS_B_Spindle // Spindle, 스핀들
    , DNS_C_TOOL // TOOL, TOOL
    , DNS_C_CRTSize // CRT Size, 모니터
    , DNS_C_ETC // ETC, 기타 사양

    , DNS_C_ProdDescription // Description, 상세 설명

    , DNS_MSG_NoProductContactHeadquarters // If the desired product is unavailable, please contact the headquarters., 찾는 제품이 없는 경우 본사에 연락하세요.
};


export default customLabels;