/**
 * @author            : Yu-Hyun Park
 * @description       : 
 *  - 직전년도 Order의 Amount의 합산을 Account/Contact의 LastYearSalesAmount에 Update하는 Batch
 *  - Update 대상이 되는 Order Amount 기준 : Status ('Confirmed', 'OrderMapped', 'Delivery'), OrderConfirmedDate__c
 *  - DNS Korea, DNS Global
 * @last modified on  : 2025-05-13
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-10-16   yuhyun.park@sbtglobal.com   Initial Version
**/
public class DN_LastYearSalesAmountBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    
    private static final Id   dnsOrderRT  = SObjectType.Order.getRecordTypeInfosByDeveloperName().get('DNS').getRecordTypeId();
    private static final Id   dealerRT   = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();

    private Map<Id, Decimal> accAmountMap = new Map<Id, Decimal>();
    private Map<Id, Decimal> conAmountMap = new Map<Id, Decimal>();
    private List<Account> accToUpdate = new List<Account>();
    private List<Contact> conToUpdate = new List<Contact>();


    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('QueryLocator Executing');
        return Database.getQueryLocator([
            SELECT  Id, 
                    FinalOrderAmount__c, 
                    Owner.UserRole.PortalRole, 
                    Owner__r.ContactId, 
                    Owner__r.Contact.AccountId,
                    Owner__r.AccountId,
                    Owner__r.Account.Name
            FROM    Order  
            WHERE   OrderConfirmedDate__c = LAST_YEAR
                AND RecordTypeId =: dnsOrderRT
                AND Status IN ('Confirmed', 'OrderMapped', 'Delivery')
                AND FinalOrderAmount__c > 0
                AND Owner.UserRole.PortalRole != null
            ORDER BY Id
            ]); 
    }

 
    public void execute(Database.BatchableContext bc, List<Order> scope) {
        System.debug('Order Scope :: ' + scope);

        for (Order order : scope){
            Decimal amt = order.FinalOrderAmount__c != null ? order.FinalOrderAmount__c : 0;

            if(order.Owner__r.ContactId != null){
                // Contact
                conAmountMap.put(order.Owner__r.ContactId,  // Key
                (conAmountMap.get(order.Owner__r.ContactId) == null ? 0 : conAmountMap.get(order.Owner__r.ContactId)) + amt // Value
                );

                // Account
                accAmountMap.put(order.Owner__r.AccountId,  // Key
                (accAmountMap.get(order.Owner__r.AccountId) == null ? 0 : accAmountMap.get(order.Owner__r.AccountId)) + amt // Value
                );
            }
        }
    }

 
    public void finish(Database.BatchableContext bc){

        // Update Contacts
        if (!conAmountMap.isEmpty()) {
            for (Id conId : conAmountMap.keySet()) {
                Contact con = new Contact(Id = conId);
                con.LastYearSalesAmount__c = conAmountMap.get(conId);
                conToUpdate.add(con);
            }
        }

        // Update Accounts
        if (!accAmountMap.isEmpty()) {
            for (Id accId : accAmountMap.keySet()) {
                Account acc = new Account(Id = accId);
                acc.LastYearSalesAmount__c = accAmountMap.get(accId);
                accToUpdate.add(acc);
            }
        }

        // Perform updates
        if (!conToUpdate.isEmpty()) {
            TriggerHandler.bypass('ContactTriggerHandler');
            System.debug('<< ContactTriggerHandler.bypass On >>');

            System.debug('conToUpdate :: ' + conToUpdate);
            update conToUpdate;

            TriggerHandler.clearBypass('ContactTriggerHandler');
            System.debug('<< ContactTriggerHandler.bypass Off >>');
        }

        if (!accToUpdate.isEmpty()) {
            TriggerHandler.bypass('AccountTriggerHandler');
            System.debug('<< AccountTriggerHandler.bypass On >>');

            System.debug('accToUpdate :: ' + accToUpdate);
            update accToUpdate;

            TriggerHandler.clearBypass('AccountTriggerHandler');
            System.debug('<< AccountTriggerHandler.bypass Off >>');
        }

        System.debug('LastYearSalesAmountBatch completed :: ' + System.now());
    }

    public void execute(SchedulableContext sc) {
        // 배치 클래스 실행
        DN_LastYearSalesAmountBatch batch = new DN_LastYearSalesAmountBatch();
        Database.executeBatch(batch);
    }
}