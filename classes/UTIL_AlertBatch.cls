/**
 * @author            : Se Jin Kwon
 * @description       : 
 * @last modified on  : 2024-12-10
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-10   Se Jin Kwon               Initial Version
**/
global class UTIL_AlertBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    List<UTIL_Alert.HistoryWrapper> historyWrappers;

    // Constructor
    public UTIL_AlertBatch(List<UTIL_Alert.HistoryWrapper> wrappers) {
        this.historyWrappers = wrappers;
        System.debug('wrapper test : ' + wrappers.size());
        System.debug('wrapper : ' + wrappers);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([SELECT Id FROM Account LIMIT 1]); // Dummy query
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        if (!historyWrappers.isEmpty()) {
            UTIL_Alert.runAlertEvent(historyWrappers);
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch completed.');
    }
    // public static void dummy() {
    //     Integer i = 0;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
       
    // }
}