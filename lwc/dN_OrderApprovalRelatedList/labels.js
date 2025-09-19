// button
import DNS_B_RequestInternalApproval from '@salesforce/label/c.DNS_B_RequestInternalApproval'; 
import DNS_B_RequestConfirm from '@salesforce/label/c.DNS_B_RequestConfirm'; 
import DNS_B_Approve from '@salesforce/label/c.DNS_B_Approve'; 
import DNS_B_REJECT from '@salesforce/label/c.DNS_B_REJECT'; 

// message
import DNS_M_Success from '@salesforce/label/c.DNS_M_Success'; 
import DNS_M_GeneralError from '@salesforce/label/c.DNS_M_GeneralError'; 
import DNS_M_ApprovalSubmitted from '@salesforce/label/c.DNS_M_ApprovalSubmitted'; 
import DNS_M_ApprovalRejected from '@salesforce/label/c.DNS_M_ApprovalRejected'; 
import DNS_M_DontNavigateAway from '@salesforce/label/c.DNS_M_DontNavigateAway'; 
import DNS_M_OrderStatusUpdated from '@salesforce/label/c.DNS_M_OrderStatusUpdated'; 
import DNS_M_OrderConfirmRequested from '@salesforce/label/c.DNS_M_OrderConfirmRequested'; 

// field
import DNS_F_OpportunityStage from '@salesforce/label/c.DNS_F_OpportunityStage'; 



const customLabels = {
    DNS_B_RequestInternalApproval // Request Internal Approval, 내부 승인 요청
    , DNS_B_RequestConfirm // Request Confirm, Sales Order 승인 요청
    , DNS_B_Approve // Approve, 승인
    , DNS_B_REJECT // Reject, 반려

    , DNS_M_Success // Success, 성공
    , DNS_M_GeneralError // Error Occurred, 오류가 발생했습니다
    , DNS_M_ApprovalSubmitted // Approval request has been submitted., 승인 요청이 완료되었습니다.
    , DNS_M_ApprovalRejected // The approval request has been rejected., 승인 요청이 반려되었습니다.
    , DNS_M_DontNavigateAway // Do not navigate away until the process is complete., 처리가 완료될 때까지 화면을 이동하지 마세요.
    , DNS_M_OrderStatusUpdated // The order status has been updated., 주문 상태가 변경되었습니다.
    , DNS_M_OrderConfirmRequested // Order Confirm Requested, 주문 승인 요청됨

    , DNS_F_OpportunityStage // Opportunity Stage, 영업 기회 단계
    
}

export default customLabels;