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
@isTest
public with sharing class IF_ProductPlantMigBatchTest {
    public IF_ProductPlantMigBatchTest() {

    }
    
    @IsTest 
    static void test1(){
        IF_ProductPlantMigBatch batch = new IF_ProductPlantMigBatch();
        
        batch.testCover();
        Database.executeBatch(batch);
    }
}