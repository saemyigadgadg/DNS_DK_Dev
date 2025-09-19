/**
 * @component         : DN_CarriageInfo
 * @test              : DN_CarriageInfoControllerTest
 * @description       : 운송현황 정보
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-17
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-12-16   yeongju.yun   Initial Version
**/
public with sharing class DN_CarriageInfoController {

    /**
    * @description 운송 현황 실시간 데이터 호출
    **/
    @AuraEnabled
    public static IF_ERP_DELIV_Classes.IF_DELIV_004_Res fetchInit(String recordId){
        try {
            
            DeliveryOrder__c dOrder = [SELECT Id, Order__r.ERPOrderNo__c, Order__r.ERPPSONo__c, ERPDONo__c FROM DeliveryOrder__c WHERE Id =: recordId];
            if(String.isBlank(dOrder.Order__r.ERPPSONo__c) || String.isBlank(dOrder.ERPDONo__c)) { return null; }

            IF_ERP_DELIV_Classes.IF_DELIV_004_Req parameters = new IF_ERP_DELIV_Classes.IF_DELIV_004_Req();
            parameters.I_VBELN = dOrder.Order__r.ERPPSONo__c;
            
            IF_ERP_DELIV method = new IF_ERP_DELIV();
            IF_ERP_DELIV_Classes.IF_DELIV_004_Res response = method.IF_DELIV_004(parameters);

            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}