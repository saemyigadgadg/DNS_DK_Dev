import DNS_S_NewPrepararionChecklist  from '@salesforce/label/c.DNS_S_NewPrepararionChecklist'; 
import DNS_S_EditPreparationChecklist from '@salesforce/label/c.DNS_S_EditPreparationChecklist'; 
import DNS_M_GeneralError from '@salesforce/label/c.DNS_M_GeneralError'; 
import DNS_M_PreparationCreationError from '@salesforce/label/c.DNS_M_PreparationCreationError'; 
import DNS_S_PrepararionChecklistInformation from '@salesforce/label/c.DNS_S_PrepararionChecklistInformation'; 
import DNS_F_ContactPerson from '@salesforce/label/c.DNS_F_ContactPerson'; 
import DNS_F_SalesRep from '@salesforce/label/c.DNS_F_SalesRep'; 
import DNS_F_PreparationInspector from '@salesforce/label/c.DNS_F_PreparationInspector'; 
import DNS_S_Description from '@salesforce/label/c.DNS_S_Description'; 
import DNS_B_Cancel from '@salesforce/label/c.DNS_B_Cancel';
import DNS_B_Save from '@salesforce/label/c.DNS_B_Save';
import DNS_M_RequiredMissing from '@salesforce/label/c.DNS_M_RequiredMissing';

const customLabels = {
    DNS_S_NewPrepararionChecklist : DNS_S_NewPrepararionChecklist // New Prepararion Checklist, 새 사전설치 점검표
    , DNS_S_EditPreparationChecklist : DNS_S_EditPreparationChecklist // Edit Preparation Checklist, 사전설치 점검표 편집
    , DNS_M_GeneralError : DNS_M_GeneralError // Error Occurred, 오류가 발생했습니다
    , DNS_M_PreparationCreationError : DNS_M_PreparationCreationError // Preparation Checklist creation is only allowed when the order status is 'Order Mapped'.
    , DNS_S_PrepararionChecklistInformation : DNS_S_PrepararionChecklistInformation // Prepararion Checklist Information, 사전설치 점검표 정보
    , DNS_F_ContactPerson : DNS_F_ContactPerson // Contact Person, 고객사 담당자
    , DNS_F_SalesRep : DNS_F_SalesRep // Sales Rep., 영업 담당자
    , DNS_F_PreparationInspector : DNS_F_PreparationInspector // Preparation Inspector, 준비사항 확인자
    , DNS_S_Description : DNS_S_Description // Description, 비고
    , DNS_B_Cancel : DNS_B_Cancel // Cancel, 취소
    , DNS_B_Save : DNS_B_Save // Save, 저장
    , DNS_M_RequiredMissing : DNS_M_RequiredMissing // Required field(s) is missing., 필수 필드가 누락되었습니다.
}

export default customLabels;