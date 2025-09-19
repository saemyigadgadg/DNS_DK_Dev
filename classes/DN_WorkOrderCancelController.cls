/**
 * @description       : Service Order 삭제/확정 취소
 * @author            : hayeong.min@dncompany.com
 * @group             : 
 * @last modified on  : 04-22-2025
 * @last modified by  : Hayeong Min
**/
public with sharing class DN_WorkOrderCancelController {


    /**
     * @Description
     * 	- 최근에 조회한 WorkOrder 목록 ListView ID 반환
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static String getListView() {
        ListView listview =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'WorkOrder' AND DeveloperName = 'My_RecentWorkOrders' LIMIT 1];

        return listview.Id;
    }

     /**
     * @Description
     * 	- 서비스오더 취소 I/F
     * 
     * @author Hayeong Min | 2025-02-19
     * @Parameter
     *  - recordId      : WorkOrder Id
    **/ 
    @AuraEnabled
    public static CommonWrapper cancelWorkOrder(String recordId){
        System.debug('recordID : '+recordId);
        CommonWrapper cw = new CommonWrapper();
        try {
            
            List<ProductRequest> prList = [SELECT Id FROM ProductRequest WHERE IsDealerPortalDelete__c = FALSE AND WorkOrderId = :recordId];
            if(prList.size() == 0){
                WorkOrder wo = [SELECT Id, ServiceOrderNumber__c, Status, CaseId, 
                            Worker__c, Worker__r.RelatedRecordId, Worker__r.RelatedRecord.LanguageLocaleKey,  Account.Name, Asset.Name, Asset.MachineName__c
                            FROM WorkOrder WHERE ID = :recordId];

                IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Req req = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Req();
                req.I_AUFNR     = wo.ServiceOrderNumber__c;

                IF_ERP_SalesOrder instance = new IF_ERP_SalesOrder();
                IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Res res = instance.IF_CSPLUS_038(req);

                List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Res_T_RETURN> t_returnList = res.T_RETURN;
                System.debug('t_returnList :: '+t_returnList);
                IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Res_T_RETURN t_return = t_returnList[0];

                System.debug('JSON.serialize(t_return) ::: '+JSON.serialize(t_return));
                
                if(t_return.TYPE!= 'S'){
                    cw.isSuccess = false;
                    cw.errMessage = 'ERP ERROR : '+t_return.MESSAGE;
                }else{
                    wo.Status = 'Canceled';
                    List<ServiceAppointment> saList = [SELECT Id, Status, ParentRecordId FROM ServiceAppointment WHERE ParentRecordId = :wo.Id];

                    if(saList.size() > 0){
                        for(ServiceAppointment sa : saList){
                            sa.Status = 'Order Canceled';
                        }
                        update saList;
                    }
                    update wo;

                    //service요원에게 오더 취소 알림 발송
                    List<UTIL_Alert.HistoryWrapper> hwlist = new List<UTIL_Alert.HistoryWrapper>();
                    UTIL_Alert.historyWrapper notihw = new UTIL_Alert.HistoryWrapper();
                    notihw.alertID = [SELECT Id FROM AlertManager__c WHERE Name = 'ServiceOrder Delete Notification' AND IsActive__c = TRUE].Id;
                    notihw.targetID = recordId;
                    notihw.alertType = 'Notification';
                    String element = 
                        (wo.ServiceOrderNumber__c != null ? wo.ServiceOrderNumber__c : '') + ' / ' +
                        (wo.Account != null ? wo.Account.Name : '') + ' / ' +
                        (wo.Asset != null ? wo.Asset.Name : '') + ' / ' +
                        (wo.Asset != null ? wo.Asset.MachineName__c : '');
                    notihw.elementList = new List<String>{ element };
                    // notihw.elementList = new List<String>{wo.ServiceOrderNumber__c};
                    notihw.receiverforID = new Set<Id>{wo.Worker__r.RelatedRecordId};
                    String lang = wo.Worker__r.RelatedRecord.LanguageLocaleKey == 'ko'? 'ko' : 'en';
                    notihw.alertLanguage = lang;
                    System.debug('notihw ::: '+notihw);
                    hwList.add(notihw);
                    UTIL_Alert.ResultWrapper rw = UTIL_Alert.runAlertEvent(hwList);
                    System.debug('Alert Result ::: '+rw);

                    if(String.isNotEmpty(wo.CaseId)) {
                        cw.returnValue = wo.CaseId;
                    }
                    
                }
            }else{
                cw.isSuccess = false;
                cw.errMessage = System.Label.DNS_E_CannotOrderDelete;
            }

        } catch (Exception e) {
            System.debug('e.getMessage() :: '+e.getLineNumber()+'__'+e.getMessage());
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }


     /**
     * @Description
     * 	- 서비스오더 확정 취소 I/F
     * 
     * @author Hayeong Min | 2025-02-19
     * @Parameter
     *  - recordId      : WorkOrder Id
    **/ 
    @AuraEnabled
    public static CommonWrapper cancelConfirmation(String recordId){
        CommonWrapper cw = new CommonWrapper();
        try {
            WorkOrder wo = [SELECT Id, ServiceOrderNumber__c, Status, ConfirmedDate__c,
                            Worker__c, Worker__r.RelatedRecordId, Worker__r.RelatedRecord.LanguageLocaleKey, Account.Name, Asset.Name, Asset.MachineName__c
                            FROM WorkOrder WHERE ID = :recordId];

            List<DealerFreeDispatch__c> orderItemList = [SELECT  OrderItem__c, Status__c, ConfirmDateTime__c, Delete__c 
                                                        FROM DealerFreeDispatch__c 
                                                        WHERE Delete__c != 'Y' AND Status__c IN ('4', '5')
                                                        AND OrderItem__r.WorkOrderId = :recordId];

            if(orderItemList.size()>0){
                cw.isSuccess = false;
                cw.errMessage = System.Label.DNS_E_OrderItemExist;
            }else{
                IF_ERP_Service_Report_Classes.IF_SERVICE_052_Req req = new IF_ERP_Service_Report_Classes.IF_SERVICE_052_Req();
                req.I_AUFNR     = wo.ServiceOrderNumber__c;
    
                IF_ERP_Service_Report instance = new IF_ERP_Service_Report();
                IF_ERP_Service_Report_Classes.IF_SERVICE_052_Res res = instance.IF_SERVICE_052(req);
    
                IF_ERP_Service_Report_Classes.IF_SERVICE_052_Res_O_RETURN o_return = res.O_RETURN;
    
    
                cw.returnValue = JSON.serialize(o_return);
                
                if(o_return.TYPE!= 'S'){
                    cw.isSuccess = false;
                    cw.errMessage = 'ERP ERROR : '+o_return.MESSAGE;
                }else{
                    wo.Status = 'Completed';
                    wo.ConfirmedDate__c = null;
                    update wo;
    
                    //service요원에게 오더 확정 취소 알림 발송
                    List<UTIL_Alert.HistoryWrapper> hwlist = new List<UTIL_Alert.HistoryWrapper>();
                    UTIL_Alert.historyWrapper notihw = new UTIL_Alert.HistoryWrapper();
                    notihw.alertID = [SELECT Id FROM AlertManager__c WHERE Name = 'ServiceOrder Confirmation Cancel Notification' AND IsActive__c = TRUE].Id;
                    notihw.targetID = recordId;
                    notihw.alertType = 'Notification';
                    String element = 
                        (wo.ServiceOrderNumber__c != null ? wo.ServiceOrderNumber__c : '') + ' / ' +
                        (wo.Account != null ? wo.Account.Name : '') + ' / ' +
                        (wo.Asset != null ? wo.Asset.Name : '') + ' / ' +
                        (wo.Asset != null ? wo.Asset.MachineName__c : '');
                    notihw.elementList = new List<String>{ element };
                    notihw.receiverforID = new Set<Id>{wo.Worker__r.RelatedRecordId};
                    String lang = wo.Worker__r.RelatedRecord.LanguageLocaleKey == 'ko'? 'ko' : 'en';
                    notihw.alertLanguage = lang;
                    System.debug('notihw ::: '+notihw);
                    hwList.add(notihw);
                    UTIL_Alert.ResultWrapper rw = UTIL_Alert.runAlertEvent(hwList);
                    System.debug('Alert Result ::: '+rw);
                }
            }
            
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /*
     * @Description 
     *  - CommonWrapper
     * 
     * @Variable 
     *  - isSuccess 		: 성공여부
     *  - errMessage 	    : 에러메시지
     *  - returnValue 	    : 반환 값
     */ 
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess		                {get; set;}
        @AuraEnabled
        public String errMessage		                {get; set;}
        @AuraEnabled
        public String returnValue		                {get; set;}
    
        public CommonWrapper(){
            this.isSuccess 		    = true;
            this.errMessage 	    = '';
            this.returnValue 	    = '';
        }
    }
}