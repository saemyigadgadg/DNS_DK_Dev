/**
 * @component         : [DN_OrderCheckDownpaymnetBtn]
 * @test              : DN_OrderCheckDownpaymnetControllerTest
 * @description       : 주문에서 선수금 입금여부 확인하는 버튼 컨트롤러
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-01-03   yeongju.yun   Initial Version
**/
public with sharing class DN_OrderCheckDownpaymnetController {
    
    /**
    * @description 선수금 입금 여부 확인 I/F 호출 
    **/
    @AuraEnabled
    public static ResultWrapper callIFDownPayment(String recordId){
        ResultWrapper result = new ResultWrapper();
        try {

            Order order = [SELECT Id, ERPOrderNo__c FROM Order WHERE Id =: recordId];
            if(String.isBlank(order.ERPOrderNo__c)) {
                result.isSuccess = false;
                result.errorMsg  = System.Label.DNS_M_ERPFirst; // Please proceed with ERP transmission first.
                return result;
            }

            List<PaymentSchedule__c> psList = [SELECT Id, PlanNo__c FROM PaymentSchedule__c WHERE Order__c =: recordId];
            
            String erpOrderNo = order.ERPOrderNo__c;
            String planNo     = psList[0].PlanNo__c;

            IF_ERP_DELIV_Classes.IF_DELIV_003_Req param = new IF_ERP_DELIV_Classes.IF_DELIV_003_Req();
            param.I_INCOMING = planNo;
            param.I_VBELN    = erpOrderNo;

            IF_ERP_DELIV method = new IF_ERP_DELIV();
            IF_ERP_DELIV_Classes.IF_DELIV_003_Res response = method.IF_DELIV_003(param);
            if(response.O_RETURN.TYPE == 'E') {
                result.isSuccess = false;
                result.errorMsg  = response.O_RETURN.MESSAGE;
                return result;
            }

            List<PaymentScheduleItem__c> psItemList = [
                SELECT  Id, Type__c, ScheduledDate__c, ReceivedAmount__c, InstallmentPrincipal__c
                FROM    PaymentScheduleItem__c 
                WHERE   PaymentSchedule__c =: psList[0].Id
                ORDER BY Type__c, ScheduledDate__c
            ];

            if(!psItemList.isEmpty()) {

                Boolean isDownPaymentReceived = false;
                Decimal curruntReceived = 0;
                String baseType = '';
                Integer index   = 1;
                for(PaymentScheduleItem__c psItem : psItemList) {
                    if(baseType != psItem.Type__c) {
                        baseType = psItem.Type__c;
                        index    = 1;
                    } else {
                        index++;
                    }
    
                    String tempKey = baseType + '_' + String.valueOf(index).leftPad(2, '0');
                    for(IF_ERP_DELIV_Classes.IF_DELIV_003_Res_T_LIST row : response.T_LIST) {

                        String rowKey = row.INCOM_CODE + '_' + row.SERIAL_NO;

                        if(tempKey == rowKey) {
                            psItem.ReceivedAmount__c = Decimal.valueOf(row.CLRAMT);
                        }
                    }

                    if(psItem.Type__c == 'P01' && psItem.InstallmentPrincipal__c == psItem.ReceivedAmount__c) {
                        isDownPaymentReceived = true;
                    } 

                    if(psItem.Type__c == 'P01') {
                        curruntReceived = psItem.ReceivedAmount__c;
                    }

                }
                update psItemList;

                if(curruntReceived == 0) {
                    result.isSuccess = true;
                    result.errorMsg  = System.Label.DNS_M_NoDownpaymnetReceived; // No downpayment amount received.
                }
            }

            return result;
            
        } catch (Exception e) {
            System.debug('callIFDownPayment : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 결과 반환 Wrapper
    **/
    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public String  errorMsg  {get;set;}
        public ResultWrapper(){
            this.isSuccess = true;
            this.errorMsg  = '';
        }
    }
}