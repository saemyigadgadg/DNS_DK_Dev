/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 06-10-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public with sharing class DN_UpdateSchedEndTimeBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable  {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('DN_UpdateSchedEndTimeBatch Start');
        Date today = Date.today();
        Date tomorrow = today.addDays(1);
        DateTime tomorrowMidnight = DateTime.newInstance(tomorrow, Time.newInstance(14, 0, 0, 0));
        System.debug('today: ' + today + ', tomorrow: ' + tomorrow + ', tomorrowMidnight: ' + tomorrowMidnight);

        return Database.getQueryLocator([
            SELECT Id, SchedEndTime, Status 
            FROM ServiceAppointment 
            WHERE Status != 'Completed' 
            AND SchedEndTime != NULL 
            AND SchedEndTime >= :today 
            AND SchedEndTime < :tomorrowMidnight 
            AND RecordType.Name = 'Service Appointment (DNSA)'
        ]);
    }

    public void execute(Database.BatchableContext BC, List<ServiceAppointment> scope) {
        System.debug('DN_UpdateSchedEndTimeBatch Execute');
        Date tomorrow = Date.today().addDays(1);
        DateTime tomorrowMidnight = DateTime.newInstance(tomorrow, Time.newInstance(14, 0, 0, 0));

        for (ServiceAppointment sa : scope) {
            sa.SchedEndTime = tomorrowMidnight;
        }

        update scope;
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('DN_UpdateSchedEndTimeBatch Ficish');
    }

    public void execute(SchedulableContext SC) {
        Database.executeBatch(new DN_UpdateSchedEndTimeBatch(), 200);
    }
}