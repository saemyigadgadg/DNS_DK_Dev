/**
 * @description       : DN_GIHistorySearchController
 * @author            : Kyongyun Jung
 * @group             : 
 * @last modified on  : 01-15-2025
 * @last modified by  : kyjung@yangwoodatapotion.com
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0  01-15-2025   Kyongyun Jung    Initial Version

**/

public without sharing class DN_GIHistorySearchController {
 // 출하이력 조회
 
    // 판매처
    // Order.SoldTo__c
    // Account.RecordType : dearler
    // Account 판매조직정보 ( 1800 / 10 / 40) / SalesDistrict  => KOREA(A1KR)
     
    // 장비 정보
    // 기종 - Asset.MachineName__c
    // 호기 - Asset.SerialNumber
    // Type - Asset.Material__c
    // NC Type - Asset.NCType__c
     
    // 배송정보
    // Delivery__c.ActualGIDate__c //실제 출하일
    // Delivery__c.DeliveryDate__c //요청 도착일
    // Delviery__c.Order__c (Order SObject)


    // 출하처 / 출하일자 / 기종 / 호기/  타입/ NCType
    @AuraEnabled
    public static Map<String, Object> getHistoryData(String distributor, Date searchDateStart, Date searchDateEnd) {
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            DateTime startDateTime = DateTime.newInstance(searchDateStart, Time.newInstance(0, 0, 0 , 0));
            DateTime endDateTime = DateTime.newInstance(searchDateEnd, Time.newInstance(23, 59, 59 ,999));
            set<String> customerCode = new set<String>();
            List<Account> accList = [SELECT Id, CustomerCode__c FROM Account WHERE Id =:distributor];
            for(Account acc : accList) {
                customerCode.add(acc.CustomerCode__c);
            }
            
            System.debug('startDateTime >>> '+startDateTime);
            System.debug('endDateTime >>> '+endDateTime);
            System.debug('distributor >>>' + distributor);
           ////출하이력조회+오더
            List<DeliveryOrder__c> orderList = [
                SELECT  Id, ActualGIDate__c, DeliveryDate__c, Order__c, Order__r.SoldTo__r.Name 
                        ,Order__r.ShipTo__r.Name, Order__r.ShipTo__c
                FROM    DeliveryOrder__c
                WHERE Order__r.SoldTo__r.CustomerCode__c IN :customerCode//WHERE   Order__r.SoldTo__c =:distributor
                AND     (ActualGIDate__c >= :startDateTime AND ActualGIDate__c <= :endDateTime)
                //AND     (PlannedGI__c >= :startDateTime AND PlannedGI__c <= :endDateTime)
              
            ];

            List<SoldToInfo> historyList = new List<SoldToInfo>();
            Map<Id, DeliveryOrder__c> orderMap = new Map<Id, DeliveryOrder__c>();
            for (DeliveryOrder__c dor : orderList){
                SoldToInfo newOr = new SoldToInfo();
                orderMap.put(dor.Order__c, dor);
                newOr.orderId       = dor.Order__c;    
                newOr.deliverOId    = dor.Id; 
                newOr.soldToName    = dor.Order__r.SoldTo__r.Name;
                newOr.soloToDate    = dor.ActualGIDate__c.date();
                newOr.actualGIDate  = dor.ActualGIDate__c;
                newOr.shipToName    = dor.Order__r.ShipTo__r.Name;
                newOr.shipToId      = dor.Order__r.ShipTo__c;
                historyList.add(newOr);
            }
            
            List<Asset> assetList = [
                SELECT  Id ,Order__c ,MachineName__c ,SerialNumber ,Material__c ,NCType__c ,FM_EquipmentNo__c
                FROM    Asset
                WHERE   Order__c IN :orderMap.keySet()
            ];
           
            Map<String, Asset> assetMap = new Map<String, Asset>();

            for (Asset asset : assetList) {
                assetMap.put(asset.Order__c, asset);
            }

            for (SoldToInfo si : historyList) {
                Asset assets     = assetMap.get(si.orderId);
                if (assets != null) {
                    si.assetId      = assets.Id;
                    si.mashinName   = assets.MachineName__c;
                    si.serialNumber = assets.FM_EquipmentNo__c; //assets.SerialNumber;
                    si.materialName = assets.Material__c;
                    si.ncType       = assets.NCType__c;
                }
            }

            historyList.sort();
            result.put('history',  historyList);
                
        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            resultStatus.setError(errorMessage, null);
        }

        result.put('status', resultStatus);
        return result;
    }   
  
    public class SoldToInfo implements Comparable  {
        @AuraEnabled public String orderId      {get; set;}
        @AuraEnabled public String assetId      {get; set;}
        @AuraEnabled public String deliverOId   {get; set;}
        @AuraEnabled public String soldToName   {get; set;}
        @AuraEnabled public String shipToName   {get; set;}
        @AuraEnabled public String shipToId     {get; set;}
        @AuraEnabled public Date   soloToDate   {get; set;}
        @AuraEnabled public String mashinName   {get; set;}
        @AuraEnabled public String serialNumber {get; set;}
        @AuraEnabled public String materialName {get; set;}
        @AuraEnabled public String ncType       {get; set;}
        @AuraEnabled public DateTime actualGIDate {get; set;}

        public SoldToInfo(){} 

        public Integer compareTo(Object cObj) {
            SoldToInfo compareRow = (SoldToInfo)cObj;
            
            if (actualGIDate < compareRow.actualGIDate) return 1;
            if (actualGIDate > compareRow.actualGIDate) return -1;

            // 모든 값이 같다면 0 반환
            return 0;
        }
    }

    public enum StatusCode { SUCCESS, ERROR }
    public class StatusInfo {
        @AuraEnabled public Integer code      {get; set;}
        @AuraEnabled public String msg        {get; set;}
        @AuraEnabled public StatusCode status {get; set;}

        public StatusInfo() {
            code = 200;
            status = StatusCode.SUCCESS;
        }

        public void setCode(Integer code) {
            this.code = code;
        }

        public void setMessage(String msg) {
            this.msg = msg;
        }

        public void setError(String msg, Integer code) {
            this.status = StatusCode.ERROR;
            this.code = (code == null) ? 400 : code;
            setMessage(msg);
        }

    }
  
}