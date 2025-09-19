/**
* @Class : DN_CustomerReceivedHistoryController
*
* @Author : Sangil, Park
* @Date : 2025. 01. 09.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2025-01-09 | Sangil, Park   | 최초작성
*
*/
public without sharing class DN_CustomerReceivedHistoryController {

    // 고객 접수 이력 조회 메서드
    @AuraEnabled
    public static List<OrderHistoryWrapper> getFailureList(ID recordId, String operationType){
        System.debug('recordId :' + recordId);
        List<OrderHistoryWrapper> ohList = new List<OrderHistoryWrapper>();
        try{
            WorkOrder wo = [SELECT ID, AccountID, AssetID 
                            FROM WorkOrder 
                            WHERE ID =: recordId];

            List<WorkOrder> searchList = new List<WorkOrder>();
            if(operationType == 'Account'){
                searchList = [SELECT ID, WorkOrderNumber, ToLabel(Case.InternalTicketType__c), Asset.MachineName__c, Asset.Name, ServiceOrderNumber__c,
                            Case.ApplicationDateTime__c, Case.RepairRequestDateTime__c, Case.ReceptionDetails__c, InspectionDetails__c
                            FROM WorkOrder
                            WHERE AccountId =: wo.AccountID
                            AND ID !=: recordId];
                System.debug('searchList1 : ' + searchList);
            }else{
                searchList = [SELECT ID, WorkOrderNumber, ToLabel(Case.InternalTicketType__c), Asset.MachineName__c, Asset.Name, ServiceOrderNumber__c,
                            Case.ApplicationDateTime__c, Case.RepairRequestDateTime__c, Case.ReceptionDetails__c, InspectionDetails__c
                            FROM WorkOrder
                            WHERE AssetId =: wo.AssetID
                            AND ID !=: recordId];
                System.debug('searchList2 : ' + searchList);
            }
            
            for (WorkOrder obj : searchList) {
                OrderHistoryWrapper res = new OrderHistoryWrapper();
                res.orderNumber = obj.ServiceOrderNumber__c != null ? obj.ServiceOrderNumber__c : '';
                res.ticketType_M = (obj.Case != null && obj.Case.InternalTicketType__c != null) ? obj.Case.InternalTicketType__c : '';
                res.model = (obj.Asset != null && obj.Asset.MachineName__c != null) ? obj.Asset.MachineName__c : '';
                res.equipment = (obj.Asset != null && obj.Asset.Name != null) ? obj.Asset.Name : '';
                res.receptionDate = (obj.Case != null && obj.Case.ApplicationDateTime__c != null) ? obj.Case.ApplicationDateTime__c.date() : null;
                res.requiredDate = (obj.Case != null && obj.Case.RepairRequestDateTime__c != null) ? obj.Case.RepairRequestDateTime__c.date() : null;
                res.receptionDetail = (obj.Case != null && obj.Case.ReceptionDetails__c != null) ? obj.Case.ReceptionDetails__c : '';
                res.repairDetail = obj.InspectionDetails__c != null ? obj.InspectionDetails__c : '';
                ohList.add(res);
            }
        }catch(Exception e){
            System.debug('Exception :: ' + e.getmessage());
        }
        return ohList;
    }

    public class OrderHistoryWrapper {
        @AuraEnabled public String orderNumber      {get;set;}      // 오더번호
        @AuraEnabled public String ticketType_M     {get;set;}      // 서비스유형 (Ticket 유형 중)
        @AuraEnabled public String model            {get;set;}      // 기종
        @AuraEnabled public String equipment        {get;set;}      // 호기
        @AuraEnabled public Date   receptionDate    {get;set;}      // 접수일자
        @AuraEnabled public Date   requiredDate     {get;set;}      // 요청일자
        @AuraEnabled public String receptionDetail  {get;set;}      // 접수내역
        @AuraEnabled public String repairDetail     {get;set;}      // 조치내역

        // public OrderHistoryWrapper() {
        //     this.orderNumber = '';
        //     this.ticketType_M = '';
        //     this.model = '';
        //     this.equipment = '';
        //     this.receptionDate = null;
        //     this.requiredDate = null;
        //     this.receptionDetail = '';
        //     this.repairDetail = '';
        // }
    }
}