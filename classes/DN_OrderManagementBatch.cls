/**
 * @description       : 
 * @author            : Sangil, Park@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-09-02
 * @last modified by  : Sangil, Park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   13-01-2025   Sangil, Park@sbtglobal.com   Initial Version
**/
public without sharing class DN_OrderManagementBatch implements Database.Batchable<Order>, Database.Stateful, Database.AllowsCallouts{
    public List<Order> start(Database.BatchableContext context){
        
        return new List<Order>{new Order(Name='test')};
    }
    
    public void execute(Database.BatchableContext context, List<Order> scope) {
        // System.debug(' =============== Batch Execute ================');
        // System.debug('scope.Size() : ' + scope.size());
        // System.debug('scope : ' + scope);
        
        // List<OrderManagement__c> orgList 	= new List<OrderManagement__c>();
        // SET<ID> dataExistCheck 				= new SET<ID>();
        // for(Order obj : scope){
        //     dataExistCheck.add(obj.ID);
        // }
        
        // List<OrderManagement__c> existList		= [SELECT ID, SalesOrder__c FROM OrderManagement__c WHERE SalesOrder__c IN : dataExistCheck];
        // MAP<ID, OrderManagement__c> existMap 	= new MAP<ID, OrderManagement__c>();
        // for(OrderManagement__c obj : existList){
        //     existMap.put(obj.SalesOrder__c, obj);
        // }

		// List<OrderItem> oiList					= [SELECT Product2.Name, Product2.Model__r.Code__c, OrderID, Product2.FM_MaterialDetails__c FROM OrderItem 
        //                                            WHERE ItemCategory__c = 'Product' AND OrderId IN : dataExistCheck];
        // MAP<ID, OrderItem> oiMap 				= new MAP<ID, OrderItem>();
        // SET<String>	basicCode					= new SET<String>();
        // for(OrderItem obj : oiList){
        //     oiMap.put(obj.OrderID, obj);
        //     basicCode.add(obj.Product2.Model__r.Code__c);
        // }
        
        // MAP<String, Boolean> basicFlagMap		= new Map<String, Boolean>();
        // List<ModelManager__c> basicList 		= [SELECT ID, BaseFlag__c, ModelCode__c FROM ModelManager__c WHERE ModelCode__c IN : basicCode];
        // for(ModelManager__c obj : basicList){
        //     basicFlagMap.put(obj.ModelCode__c, obj.BaseFlag__c);
        // }
        
        // // 데이터 삽입 및 수정
        // for(Order obj : scope){
        //     if(obj.OrderMappedDate__c != null){
        //         OrderManagement__c om 	= existMap.get(obj.ID) != null ? existMap.get(obj.ID) : new OrderManagement__c();
        //         om.BasicCheck__c 		= obj.ReqDeliveryDate__c != null ? obj.ReqDeliveryDate__c.AddDays(-40) : null;
		// 		om.SalesOrder__c 		= obj.ID;
        //         om.OrderSegmentation__c = obj.OrderSegmentation__c;
        //         om.SalesOffice__c		= obj.SalesOffice__c;
        //         OrderItem item			= oiMap.get(obj.ID);
        //         if(item != null){
        //             om.BaseFlag__c	 		= basicFlagMap.get(item.Product2.Model__r.Code__c);
        //             om.Model__c				= item.Product2.Model__r.Code__c;
        //         }
        //         orgList.add(om);
        //     }else{
		// 		OrderManagement__c om = new OrderManagement__c();               
        //         om.SalesOrder__c 		= obj.ID;
        //         om.OrderSegmentation__c = obj.OrderSegmentation__c;
        //         om.SalesOffice__c		= obj.SalesOffice__c;
        //         OrderItem item			= oiMap.get(obj.ID);
        //         if(item != null){
        //             om.BaseFlag__c	 		= basicFlagMap.get(item.Product2.Model__r.Code__c);
        //             om.Model__c				= item.Product2.FM_MaterialDetails__c;
        //         }
        //         orgList.add(om);
        //     }
        // }
        
        // Upsert orgList;
    }
    
    public void finish(Database.BatchableContext context){
        // System.debug('배치 실행 완료');
    }
}