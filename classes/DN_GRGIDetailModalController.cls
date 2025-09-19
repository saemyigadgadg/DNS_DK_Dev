/**
 * @description       : DN_GRGIDetailModalController | 입출고내역 모달
 * @author            : Kyongyun Jung
 * @group             : 
 * @last modified on  : 01-16-2025
 * @last modified by  : kyjung@yangwoodatapotion.com
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0  01-16-2025   Kyongyun Jung    Initial Version

**/
public without sharing class DN_GRGIDetailModalController {
    @AuraEnabled
    public static Map<String,Object> getGRGIInformation (String docNo){
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            List<GRGIInfo> returnInfo = new List<GRGIInfo>();
            if (docNo.startsWith('C7') || docNo.startsWith('7')) { 
                List<DealerReturnOrderItem__c> rList = [
                    SELECT   Id
                            ,ReturnOrderNumber__c
                            ,FM_ReturnDate__c
                            ,FM_Part__c
                            ,OrderItem__r.Order__c
                            ,OrderItem__r.Part__r.FM_MaterialDetails__c
                            ,OrderItem__r.DiscountPrice__c 
                            ,ReturnQuantity__c
                            ,CurrencyIsoCode
                            ,Note__c
                    FROM    DealerReturnOrderItem__c
                    WHERE   ReturnOrderNumber__c =:docNo
                ];

                if (!rList.isEmpty()) {
                    for (DealerReturnOrderItem__c roi : rList) {
                        GRGIInfo oInfo = new GRGIInfo();
                        oInfo.Id          = roi.Id;
                        oInfo.docNo       = roi.ReturnOrderNumber__c;
                        oInfo.createDate  = roi.FM_ReturnDate__c;
                        oInfo.partsNum    = roi.FM_Part__c;
                        oInfo.partsName   = roi.OrderItem__r.Part__r.FM_MaterialDetails__c;
                        oInfo.qty         = roi.ReturnQuantity__c;
                        oInfo.price       = roi.OrderItem__r.DiscountPrice__c * roi.ReturnQuantity__c;
                        oInfo.currencyVal = roi.CurrencyIsoCode;
                        oInfo.comment     = roi.Note__c;
                        returnInfo.add(oInfo);
                    }
                }
            } else {
                // 출고지시번호 ShipmentOrder__c 필요
                List<DealerInventoryMovements__c> dimList = [
                    SELECT   Id
                            ,InventoryNumber__c
                            ,FM_CreatedDate__c
                            ,Part__r.ProductCode
                            ,Part__r.FM_MaterialDetails__c
                            ,Quantity__c
                            ,DiscountAmount__c
                            ,CurrencyIsoCode
                            ,Comment__c
                            ,DealerOrderItem__c
                    FROM    DealerInventoryMovements__c
                    WHERE   InventoryNumber__c =:docNo
                ];

                Set<Id> orderItem = new Set<Id>();

                if (!dimList.isEmpty()) {
                    for (DealerInventoryMovements__c dim : dimList) {
                        GRGIInfo gInfo = new GRGIInfo();
                        orderItem.add(dim.DealerOrderItem__c);
                        gInfo.Id          = dim.Id;
                        gInfo.docNo       = dim.InventoryNumber__c;
                        gInfo.createDate  = dim.FM_CreatedDate__c;
                        gInfo.partsNum    = dim.Part__r.ProductCode;
                        gInfo.partsName   = dim.Part__r.FM_MaterialDetails__c;
                        gInfo.qty         = dim.Quantity__c;
                        gInfo.price       = dim.DiscountAmount__c;
                        gInfo.currencyVal = dim.CurrencyIsoCode;
                        gInfo.comment     = dim.Comment__c;
                        gInfo.doItemId    = dim.DealerOrderItem__c;
                        returnInfo.add(gInfo);
                    }

                    List<ShipmentOrder__c> shipOrder = [SELECT Id, DealerOrderItem__c ,Name, DeliveryOrder__c FROM ShipmentOrder__c WHERE DealerOrderItem__c=:orderItem];
                    
                    if(!shipOrder.isEmpty()) {
                        Map<String, ShipmentOrder__c> shipMap = new Map<String, ShipmentOrder__c>();

                        for (ShipmentOrder__c so : shipOrder) {
                            shipMap.put(so.DealerOrderItem__c, so);
                        }

                        for (GRGIInfo grgi : returnInfo) {
                            ShipmentOrder__c ship = shipMap.get(grgi.doItemId);
                            if (ship != null) {
                                grgi.doNo = ship.DeliveryOrder__c;
                            }
                        }
                    }
                }
            }
           
            System.debug(returnInfo.size());
            result.put('resultList', returnInfo);
        } catch (Exception e) {
            System.debug(e.getMessage() + ' < ==e.getMessage()');
            System.debug(e.getLineNumber() + ' < ==e.getLineNumber()');
            System.debug(e.getStackTraceString() + ' < ==e.getStackTraceString()');
            throw new DN_GRGIDetailModalControllerException(e.getMessage());
        }
        //System.debug('Map as JSON: ' + JSON.serialize(result));
        return result;
    }

    public class GRGIInfo {
        @AuraEnabled public String  Id          {get;set;}
        @AuraEnabled public String  docNo       {get;set;} //문서번호
        @AuraEnabled public Date    createDate  {get;set;}
        @AuraEnabled public String  partsNum    {get;set;}
        @AuraEnabled public String  partsName   {get;set;}
        @AuraEnabled public Decimal qty         {get;set;}
        @AuraEnabled public Decimal price       {get;set;}
        @AuraEnabled public String  currencyVal {get;set;}
        @AuraEnabled public String  comment     {get;set;}
        @AuraEnabled public String  doNo        {get;set;} //출고지시번호
        @AuraEnabled public String  doItemId    {get;set;}
        // public GRGIInfo(){} 
        // public GRGIInfo(DealerInventoryMovements__c sObj) {
        //     this.Id          = sObj.Id;
        //     this.docNo       = sObj.InventoryNumber__c;
        //     this.createDate  = sObj.FM_CreatedDate__c;
        //     this.partsNum    = sObj.Part__r.ProductCode;
        //     this.partsName   = sObj.Part__r.FM_MaterialDetails__c;
        //     this.qty         = sObj.Quantity__c;
        //     this.price       = sObj.DiscountAmount__c;
        //     this.currencyVal = sObj.CurrencyIsoCode;
        //     this.comment     = sObj.Comment__c;
        //     this.doItemId    = sObj.DealerOrderItem__c;
        // }
    }

    public class DN_GRGIDetailModalControllerException extends Exception {}
}