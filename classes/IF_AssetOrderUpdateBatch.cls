/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-17-2025
 * @last modified by  : deokjun.kim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-17-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_AssetOrderUpdateBatch implements Database.Batchable<Order> , 
Database.AllowsCallouts, 
Database.Stateful  {

    public Set<String> orderIds;
    public Integer size;
    public Integer success;
    public Integer fail;
    
    public IF_AssetOrderUpdateBatch(Set<String> orderIds) {
        this.orderIds = orderIds;
        System.debug('orderIds : '+orderIds);
    }

    public Iterable<Order> start(Database.BatchableContext BC){
        System.debug('orderIds : '+orderIds);
        System.debug('orderIds.size() : '+orderIds.size());
        
        return [
            SELECT Id, SerialNumber__c, RelatedDealer__r.Name,  
            ERPPSONo__c,        // 기준 
            ERPRSONo__c,         // 미국
            ERPOrderNo__c      // 한국
            FROM Order
            WHERE Id IN:orderIds and SerialNumber__c != null];
    }

    public void execute(Database.BatchableContext BC, List<Order> scope){
         
        Set<String>   serialNumbers = new Set<String>();
        Map<String,Order>  orderMap = new Map<String,Order>(); 
        List<Asset>     updateAsset = new List<Asset>();

        // SerialNumber Set
        for(Order order : scope){ 
            serialNumbers.add(order.SerialNumber__c);
        }

        // Get Asset map 
        Map<String,Asset>  assetMap      = findAsset(serialNumbers);
        Map<String,Order>  americanOrder = findAmericanOrder(serialNumbers);
        Map<String,Order>  koreanOrder   = findKoreanOrder(serialNumbers); 

        for(Asset asset : assetMap.values()){
            String serialNo  = asset.SerialNumber;
            Order  findOrder; 
            
        // Assign Order 
            if( americanOrder.containsKey(serialNo) ){
                findOrder = americanOrder.get(serialNo);
                System.debug(' Serial : '+serialNo+'is USA Order id : '+findOrder.Id);
                asset.Order__c   = findOrder.Id;                
            }
            else if( koreanOrder.containsKey(serialNo) ){
                findOrder = koreanOrder.get(serialNo);
                System.debug(' Serial : '+serialNo+' is KOREAN Order id : '+findOrder.Id);
                asset.Order__c   = findOrder.Id;                
            }
            else{
                continue;
            }            

            if(findOrder.RelatedDealer__r.Name != null){
                asset.SalesAgency__c = findOrder.RelatedDealer__r.Name;
            }
            updateAsset.add(asset);
        }
        
        size = updateAsset.size();

        List<Database.SaveResult> updateAssetResult = Database.update(updateAsset, false);
        for(Database.SaveResult ur: updateAssetResult){
            if(!ur.isSuccess()){
                System.debug('Asset Update fail : '+ur.getId()+' ERROR : '+ur.getErrors());
            }
            else{
                System.debug('Asset Update Success : '+ur.getId());
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        System.debug('UPDATE 완료 -- 총 사이즈 : '+size+' 성공 : '+success+' 실패 : '+fail);
    }

    public Map<String,Asset> findAsset(Set<String> serialNumbers){
        Map<String,Asset> assetMap = new Map<String,Asset>();

        for(Asset asset : [
            SELECT Id, Name, SerialNumber, SalesAgency__c, Order__c FROM Asset 
            WHERE SerialNumber IN:serialNumbers]){
                assetMap.put(asset.SerialNumber,asset);
            }
        return assetMap;
    }

    public Map<String,Order> findKoreanOrder(Set<String> serialNumbers){
        Map<String,Order> orderMap = new Map<String,Order>();
        
        for(Order order: [
            SELECT Id, SerialNumber__c, RelatedDealer__r.Name,  
            ERPPSONo__c,        // 기준 
            ERPRSONo__c,        // 미국
            ERPOrderNo__c      // 한국
            FROM Order
            WHERE 
            ERPPSONo__c != NULL 
            AND ERPOrderNo__c != NULL
            AND SerialNumber__c IN:serialNumbers
        ]){
            orderMap.put(order.SerialNumber__c,order);
        }
        return orderMap;
    }

    public Map<String,Order> findAmericanOrder(Set<String> serialNumbers){
        Map<String,Order> orderMap = new Map<String,Order>();
        
        for(Order order: [
            SELECT Id, SerialNumber__c, RelatedDealer__r.Name,  
            ERPPSONo__c,        // 기준 
            ERPRSONo__c,        // 미국
            ERPOrderNo__c       // 한국
            FROM Order
            WHERE 
            ERPPSONo__c != NULL 
            AND ERPOrderNo__c != NULL
            AND SerialNumber__c IN:serialNumbers
        ]){
            orderMap.put(order.SerialNumber__c,order);
        }
        return orderMap;
    }
}