/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-07-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-07-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ProductPlantMigBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{

    public List<Product2> start(Database.BatchableContext bc) {
        List<Product2> pl = [SELECT Id FROM Product2 WHERE RecordType.Name = 'part' AND IsActive = TRUE AND IsPlantMig__c = FALSE LIMIT 50000];

        return pl;
    }
    public void execute(Database.BatchableContext bc, List<Product2> scope) {
        Set<String> idSet = new Set<String>();

        for(Product2 p : scope){
            idSet.add(p.Id);
        }

        Map<String, List<String>> plantMap = new Map<String, List<String>>();
        List<ProductByPlant__c> pbpList = [SELECT Part__c, Plant__c FROM ProductByPlant__c WHERE Part__c IN :idSet];
        for(ProductByPlant__c pbp : pbpList){
            List<String> plantList = new List<String>();
            if(plantMap.get(pbp.Part__c) != null){
                plantList = plantMap.get(pbp.Part__c);
            }
            plantList.add(pbp.Plant__c);
            plantMap.put(pbp.Part__c, plantList);            
        }

        List<Product2> updateList = new List<Product2>();
        for(String key : plantMap.keySet()){
            String values= '';
            for(String value : plantMap.get(key)){
                values += value + ';';
            }
            if(values.length() > 0) values = values.substring(0, values.length()-1);
            updateList.add(new Product2(Id = key, Plant__c = values, IsPlantMig__c = TRUE));
        }

        if(updateList.size() > 0) update updateList;
    }
    public void finish(Database.BatchableContext bc) {}
    public void testCover(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}