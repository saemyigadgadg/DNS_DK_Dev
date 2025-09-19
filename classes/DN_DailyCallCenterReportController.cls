/**
 * @author            : Hayeong Min
 * @description       : Daily Call Center Report용 DATA 추출
 * @last modified on  : 2025-04-14
 * @last modified by  : Hayeong Min
**/
public with sharing class DN_DailyCallCenterReportController {

    /**
     * @Description
     * 	- 조건에 맞는 Daily CallCenter 목록 출력
     * 
     * @author Hayeong Min | 01-06-2025
     * @Parameter
     *  - startDate     : 조회기간 Start 일자
     *  - endDate       : 조회기간 End 일자
    **/
    @AuraEnabled
    public static List<DailyCallCenter__c> getCallCenterData(Date startDate, Date endDate){
        List<DailyCallCenter__c> dailyList = [SELECT 
        RecordDate__c, InboundCallNum__c,
        ServiceReception__c, 
        TechnicalInquiry__c, FM_TechnicalInquiry__c, CallService__c, FM_CallService__c, NoCall__c, FM_NoCall__c, FailureReceipt__c, FM_FailureReceipt__c, NoAssign__c, FM_NoAssign__c, 
        WaitingForCustomerResponse__c, FM_WaitingForCustomerResponse__c, WarrantyDetermination__c, FM_WarrantyDetermination__c, 
        TechnicalReview__c, FM_TechnicalReview__c, AssignHolding__c,  FM_AssignHolding__c, CustomerAbsence__c, FM_CustomerAbsence__c, Exceeding20Min__c, FM_Exceeding20Min__c,
        AssignNumAll__c, FM_AssignNumAll__c, Branch__c, FM_Branch__c, FM_WorkCenter__c, WorkCenter__c, AssignExceeding20Min__c, FM_AssignExceeding20Min__c,
        ReceptionNum__c, FM_ReceptionNum__c, 
        Busan__c, Changwon__c, Cheonan__c, Daejeon__c, Deagu__c, Gwangju__c, Incheon__c, Suwon__c, Ulsan__c,
        FM_Busan__c, FM_Changwon__c, FM_Cheonan__c, FM_Daejeon__c, FM_Deagu__c, FM_Gwangju__c, FM_Incheon__c, FM_Suwon__c, FM_Ulsan__c, 
        AllDispatchNum__c, FM_AllDispatchNum__c, DispatchOntheDay__c, FM_DispatchOntheDay__c, DispatchTomorrow__c, FM_DispatchTomorrow__c,
        OnsiteManagement__c, FM_OnsiteManagement__c, ClosedToday__c, FM_ClosedToday__c, DailyMonitoringCheck__c, DailyMonitoringUnCheck__c, FM_DailyMonitoringCheck__c, FM_DailyMonitoringUnCheck__c            
        FROM DailyCallCenter__c 
        WHERE (RecordDate__c >= :startDate AND RecordDate__c <= :endDate.addDays(1))
        ORDER BY RecordDate__c ASC
        ];
        return dailyList;
    }
}