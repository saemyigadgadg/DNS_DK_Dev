// button
import DNS_B_Save from '@salesforce/label/c.DNS_B_Save';
import DNS_B_SyncPrice from '@salesforce/label/c.DNS_B_SyncPrice';


// title
import DNS_T_DefaultEquipmentSelection from '@salesforce/label/c.DNS_T_DefaultEquipmentSelection';
import DNS_T_StandardDiscount from '@salesforce/label/c.DNS_T_StandardDiscount';
import DNS_T_AdditionalDiscount from '@salesforce/label/c.DNS_T_AdditionalDiscount';
import DNS_T_FinalOrderAmount from '@salesforce/label/c.DNS_T_FinalOrderAmount';

import DNS_F_ProductTotalBasedOnContract from '@salesforce/label/c.DNS_F_ProductTotalBasedOnContract';
import DNS_F_OptionTotalBasedOnContract from '@salesforce/label/c.DNS_F_OptionTotalBasedOnContract';

// column
import DNS_C_Category from '@salesforce/label/c.DNS_C_Category'; 
import DNS_C_Details from '@salesforce/label/c.DNS_C_Details'; 
import DNS_C_Amount from '@salesforce/label/c.DNS_C_Amount'; 
import DNS_C_Currency from '@salesforce/label/c.DNS_C_Currency'; 
import DNS_C_DiscountRate from '@salesforce/label/c.DNS_C_DiscountRate'; 

// field
import DNS_F_Product from '@salesforce/label/c.DNS_F_Product'; 
import DNS_F_Option from '@salesforce/label/c.DNS_F_Option'; 
import DNS_F_StandardPrice from '@salesforce/label/c.DNS_F_StandardPrice'; 
import DNS_F_Total from '@salesforce/label/c.DNS_F_Total'; 
import DNS_F_GrandTotal from '@salesforce/label/c.DNS_F_GrandTotal'; 
import DNS_F_ConsignmentSupplyPrice from '@salesforce/label/c.DNS_F_ConsignmentSupplyPrice'; 
import DNS_F_CVOption from '@salesforce/label/c.DNS_F_CVOption'; 
import DNS_F_SQOption from '@salesforce/label/c.DNS_F_SQOption'; 
import DNS_F_ACCOption from '@salesforce/label/c.DNS_F_ACCOption'; 
import DNS_F_CVOptionDiscount from '@salesforce/label/c.DNS_F_CVOptionDiscount'; 
import DNS_F_SQOptionDiscount from '@salesforce/label/c.DNS_F_SQOptionDiscount'; 
import DNS_F_ACCOptionDiscount from '@salesforce/label/c.DNS_F_ACCOptionDiscount'; 
import DNS_F_WholesaleSupplyPrice from '@salesforce/label/c.DNS_F_WholesaleSupplyPrice'; 
import DNS_F_FinalConsignmentContractPrice from '@salesforce/label/c.DNS_F_FinalConsignmentContractPrice'; 
import DNS_F_FinalWholesaleContractPrice from '@salesforce/label/c.DNS_F_FinalWholesaleContractPrice'; 
import DNS_F_LongTermSales from '@salesforce/label/c.DNS_F_LongTermSales'; 
import DNS_F_StandardDiscount from '@salesforce/label/c.DNS_F_StandardDiscount'; 
import DNS_F_SpecialDiscount from '@salesforce/label/c.DNS_F_SpecialDiscount'; 
import DNS_F_SpecialSupply from '@salesforce/label/c.DNS_F_SpecialSupply'; 
import DNS_F_TotalDiscountAmount from '@salesforce/label/c.DNS_F_TotalDiscountAmount'; 
import DNS_F_Discount from '@salesforce/label/c.DNS_F_Discount'; 

// message
import DNS_M_Success from '@salesforce/label/c.DNS_M_Success'; 
import DNS_M_GeneralError from '@salesforce/label/c.DNS_M_GeneralError'; 
import DNS_M_EnterRightValue from '@salesforce/label/c.DNS_M_EnterRightValue'; 
import DNS_M_OrderPricingSaved from '@salesforce/label/c.DNS_M_OrderPricingSaved'; 
import DNS_M_DataActivateInstruction  from '@salesforce/label/c.DNS_M_DataActivateInstruction'; 
import DNS_M_PromotionStandardDCRate  from '@salesforce/label/c.DNS_M_PromotionStandardDCRate'; 
import DNS_M_PromotionDefaultRate  from '@salesforce/label/c.DNS_M_PromotionDefaultRate'; 
import DNS_M_IncentiveStandardDCRate  from '@salesforce/label/c.DNS_M_IncentiveStandardDCRate'; 
import DNS_M_IncentiveDetails  from '@salesforce/label/c.DNS_M_IncentiveDetails'; 
import DNS_M_ProductDiscountZero  from '@salesforce/label/c.DNS_M_ProductDiscountZero'; 

const customLabels = {
    DNS_B_Save // Save, 저장
    , DNS_B_SyncPrice // Sync Price, 가격 정보 동기화

    , DNS_T_DefaultEquipmentSelection // Default Equipment Selection, 장비 기본 선택사항
    , DNS_T_StandardDiscount // Standard Discount, 정상 할인
    , DNS_F_ProductTotalBasedOnContract // Product Total (based on contract price), (계약가 기준) 본체 합
    , DNS_F_OptionTotalBasedOnContract // Option Total (based on contract price), (계약가 기준) 옵션 합
    , DNS_T_AdditionalDiscount // Additional Discount, 추가 할인
    , DNS_T_FinalOrderAmount // Final Order Amount, 최종 주문 금액

    , DNS_C_Category // Category, 구분
    , DNS_C_Details // Details, 내용
    , DNS_C_Amount // Amount, 금액
    , DNS_C_Currency // Currency, 통화
    , DNS_C_DiscountRate // Discount Rate, 할인율

    , DNS_F_Product // Main Unit, 본체
    , DNS_F_Option // DNS_F_Option, 옵션
    , DNS_F_StandardPrice // Standard Price, 표준가
    , DNS_F_Total // Total, 합계
    , DNS_F_GrandTotal // Grand Total, 총 합
    , DNS_F_ConsignmentSupplyPrice // Consignment Supply Price, 위탁공급가
    , DNS_F_CVOption // CV Option, CV 옵션
    , DNS_F_SQOption // SQ Option, SQ 옵션
    , DNS_F_ACCOption // ACC Option, ACC 옵션
    , DNS_F_CVOptionDiscount // CV Option Discount, CV 옵션할인
    , DNS_F_SQOptionDiscount // SQ Option Discount, SQ 옵션할인
    , DNS_F_ACCOptionDiscount // ACC Option Discount, ACC 옵션할인
    , DNS_F_WholesaleSupplyPrice // Wholesale Supply Price (30 Days)
    , DNS_F_FinalConsignmentContractPrice // Final Consignment Contract Price, 최종 위탁계약가
    , DNS_F_FinalWholesaleContractPrice // Final Wholesale Contract Price, 최종 도매계약가
    , DNS_F_LongTermSales // Long Term/Purpose/Proto/NC Special Sales, 장기/목적/Proto/NC특판
    , DNS_F_StandardDiscount // Standard Discount, 정상 할인
    , DNS_F_SpecialDiscount // Special Discount, 특별 할인
    , DNS_F_SpecialSupply // Special Supply, 특별 공급
    , DNS_F_TotalDiscountAmount // Total Discount Amount, 총 할인 금액
    , DNS_F_Discount // Discount, 할인

    , DNS_M_Success // Success, 성공
    , DNS_M_GeneralError // Error Occurred, 오류가 발생했습니다
    , DNS_M_EnterRightValue // Please enter right value., 알맞은 금액을 입력해 주세요.
    , DNS_M_OrderPricingSaved // The order process pricing has been successfully saved., 가격 정보가 성공적으로 저장되었습니다.
    , DNS_M_DataActivateInstruction // Click the button on the right to activate the data., 우측 버튼을 클릭하여 데이터를 활성화하세요.
    , DNS_M_PromotionStandardDCRate // The promotion rate based on the price after applying the standard discount., 딜러 공급가 기준 프로모션 할인율
    , DNS_M_PromotionDefaultRate // The promotion rate based on the standard supplier price., 표준가 기준 프로모션 할인율
    , DNS_M_IncentiveStandardDCRate // The incentive rate based on the price after applying the standard discount., 딜러 공급가 기준 인센티브 할인율
    , DNS_M_IncentiveDetails // Enter the sum of the consignment fee and the promotion fee., 위탁수수료 + 프로모션 수수료 합산값 입력할 것
    , DNS_M_ProductDiscountZero // There is no discount amount applicable to the payment terms.,결제조건에 해당하는 할인 금액이 존재하지 않습니다.
};

export default customLabels;