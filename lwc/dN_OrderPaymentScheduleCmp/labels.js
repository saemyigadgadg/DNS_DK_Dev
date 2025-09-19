// button
import DNS_B_Save from '@salesforce/label/c.DNS_B_Save'; 
import DNS_B_SplitAmt from '@salesforce/label/c.DNS_B_SplitAmt'; 
import DNS_B_AddRow from '@salesforce/label/c.DNS_B_AddRow'; 
import DNS_B_DeleteRow from '@salesforce/label/c.DNS_B_DeleteRow'; 
import DNS_FSL_Check from '@salesforce/label/c.DNS_FSL_Check'; 
import DNS_B_SendToERP from '@salesforce/label/c.DNS_B_SendToERP'; 
import DNS_B_SaveAsDraft from '@salesforce/label/c.DNS_B_SaveAsDraft'; 

// field
import DNS_F_Currency from '@salesforce/label/c.DNS_F_Currency'; 
import DNS_F_InputAmount from '@salesforce/label/c.DNS_F_InputAmount'; 
import DNS_F_Balance from '@salesforce/label/c.DNS_F_Balance'; 
import DNS_C_Number from '@salesforce/label/c.DNS_C_Number'; 
import DNS_C_InstallmentPrincipal from '@salesforce/label/c.DNS_C_InstallmentPrincipal'; 

// message
import DNS_M_Success from '@salesforce/label/c.DNS_M_Success'; 
import DNS_M_GeneralError from '@salesforce/label/c.DNS_M_GeneralError'; 
import DNS_M_EarlierDocDate from '@salesforce/label/c.DNS_M_EarlierDocDate'; 
import DNS_M_ExceedTotal from '@salesforce/label/c.DNS_M_ExceedTotal'; 
import DNS_M_SelectOne from '@salesforce/label/c.DNS_M_SelectOne'; 
import DNS_M_EnterAmt from '@salesforce/label/c.DNS_M_EnterAmt'; 
import DNS_M_EnterScheduleDate from '@salesforce/label/c.DNS_M_EnterScheduleDate'; 
import DNS_M_DownPaymentOnlyPast from '@salesforce/label/c.DNS_M_DownPaymentOnlyPast'; 
import DNS_M_RemainAmt from '@salesforce/label/c.DNS_M_RemainAmt'; 
import DNS_M_SetDocumentDate from '@salesforce/label/c.DNS_M_SetDocumentDate'; 
import DNS_M_PaymentScheduleSaved from '@salesforce/label/c.DNS_M_PaymentScheduleSaved'; 
import DNS_M_NoDraftNo from '@salesforce/label/c.DNS_M_NoDraftNo'; 
import DNS_M_PaymentSchedultTransmitted from '@salesforce/label/c.DNS_M_PaymentSchedultTransmitted'; 
import DNS_M_NotAllowedSplit from '@salesforce/label/c.DNS_M_NotAllowedSplit'; 
import DNS_M_DownpaymentExist from '@salesforce/label/c.DNS_M_DownpaymentExist'; 
import DNS_M_CompleteDraftAndConfirm from '@salesforce/label/c.DNS_M_CompleteDraftAndConfirm'; 
import DNS_M_EnterPlannedDate from '@salesforce/label/c.DNS_M_EnterPlannedDate'; 
import DNS_M_Over1000 from '@salesforce/label/c.DNS_M_Over1000'; 

const customLabels = {
    DNS_B_Save // Save, 저장
    , DNS_B_SplitAmt // Split Amt, Split Amt
    , DNS_B_AddRow // Add Row, 행 추가
    , DNS_B_DeleteRow // Delete Row, 행 삭제
    , DNS_FSL_Check // Check, 확인
    , DNS_B_SendToERP // Payment Schedule Confirmation, 수금 계획 확정
    , DNS_B_SaveAsDraft // Save as Draft, 임시 저장

    , DNS_F_Currency // Currency, 통화
    , DNS_F_InputAmount // Input Amount, 입력 금액
    , DNS_F_Balance // Balance, 잔액
    , DNS_C_Number // No., 번호
    , DNS_C_InstallmentPrincipal // Installment Principal, 할부 원금
    
    , DNS_M_Success // Success, 성공
    , DNS_M_GeneralError // Error Occurred, 오류가 발생했습니다
    , DNS_M_EarlierDocDate // The Schedule Date cannot be earlier than the Document Date., 계획일은 증빙일보다 이전일 수 없습니다.
    , DNS_M_ExceedTotal // The total Pri. Amount exceeds the Total Amount., 할부 원금 합계가 제품 금액을 초과합니다.
    , DNS_M_SelectOne // Please select only one item., 하나만 선택해 주세요.
    , DNS_M_EnterAmt // Please enter the amount first., 금액을 먼저 입력해 주세요.
    , DNS_M_EnterScheduleDate // Please enter the scheduled date., 예정일을 입력해 주세요.
    , DNS_M_DownPaymentOnlyPast // For down payment, only the document date or a prior date can be selected., 선수금일 경우 증빙일 또는 그 이전 날짜만 선택 가능합니다.
    , DNS_M_RemainAmt // There are amounts with unspecified payment methods., 지불 방법이 정해지지 않은 금액이 존재합니다.
    , DNS_M_SetDocumentDate // The document date is mandatory., 증빙일은 필수입니다.
    , DNS_M_PaymentScheduleSaved // The payment schedule has been successfully saved., 수금 계획이 성공적으로 저장되었습니다.
    , DNS_M_NoDraftNo // Draft No has not been entered., Draft No가 입력되지 않았습니다.
    , DNS_M_PaymentSchedultTransmitted // The payment schedule has been successfully transmitted to the ERP., 수금 계획이 성공적으로 전송되었습니다.
    , DNS_M_NotAllowedSplit // Splitting is not allowed for down payments., 선수금일 경우 분할할 수 없습니다.
    , DNS_M_DownpaymentExist // The down payment already exists., 선수금이 이미 존재합니다.
    , DNS_M_CompleteDraftAndConfirm // Please make sure to complete 'Save as Draft' before proceeding with confirmation., 임시 저장을 반드시 완료한 후, 확정을 진행해 주세요.
    , DNS_M_EnterPlannedDate // Please enter the planned date., 계획일을 작성해 주세요.
    , DNS_M_Over1000 // Payment schedules with a gap of more than 1000 days cannot be registered.
};

export default customLabels;