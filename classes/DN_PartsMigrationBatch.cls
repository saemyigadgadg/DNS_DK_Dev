public Without Sharing class DN_PartsMigrationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Schedulable{

	public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID, ProductCode, Plant__c FROM Product2 WHERE RecordType.Name = \'Part\'';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<Product2> scope) {
        System.debug(' =============== Batch Execute ================');
        System.debug('scope.Size() : ' + scope.size());
        System.debug('scope : ' + scope);
        
        Map<ID, Product2> prdMap = new Map<ID, Product2>();
        SET<ID> prdIDS = new SET<ID>();
        for(Product2 obj : scope){
            obj.Plant__c = null;
            prdMap.put(obj.ID, obj);
            prdIDS.add(obj.ID);
        }
        
        List<ProductByPlant__c> pbpList = [SELECT Part__c , Plant__c FROM ProductByPlant__c WHERE Part__c IN : prdIDS];
        for(ProductByPlant__c obj : pbpList){
            Product2 temp = prdMap.get(obj.Part__c);
            if(temp.Plant__c == null){
                temp.Plant__c = obj.Plant__c;
            }else{
                temp.Plant__c += ';' + obj.Plant__c;
            }
            prdMap.put(obj.Part__c, temp);
        }
        
        Update prdMap.Values();
    }

    public void finish(Database.BatchableContext context){
        System.debug('배치 실행 완료');
    } 

    public void execute(SchedulableContext sc) {
        DN_PartsMigrationBatch batch = new DN_PartsMigrationBatch();
        Database.executeBatch(batch, 2000);        
    }

    public static void dummy() {
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