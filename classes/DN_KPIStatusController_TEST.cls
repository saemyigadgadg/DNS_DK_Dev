/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-28
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-28   yeongdeok.seo@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_KPIStatusController_TEST {
    public DN_KPIStatusController_TEST() {}

    @isTest(SeeAllData=true)
    static void testGetPicklistLabelValue() {
        DN_KPIStatusController.InitWrapper result = DN_KPIStatusController.getPicklistLabelValue();
    }

    @isTest(SeeAllData=true)
    static void testGetTicketList() {
        List<Case> result = DN_KPIStatusController.getTicketList('2025-05-01', '2025-05-31');
    }

    @isTest(SeeAllData=true)
    static void testGetDataAll() {

        Datetime start = Datetime.newInstance(2025, 5, 1);
        Datetime last = Datetime.newInstance(2025, 5, Date.daysInMonth(2025, 5), 23, 59, 59);

        List<Case> ticketList = [   SELECT  Id, ApplicationDateTime__c, ClosedDate, GeneralCallDatetime__c, TechnicalCallDatetime__c, ReceptionPath__c, Status, InternalTicketType__c
                                    FROM Case
                                    WHERE ApplicationDateTime__c >= :start AND ApplicationDateTime__c <= :last AND ApplicationDateTime__c != null
                                    LIMIT 100
        ]; 

        List<DN_KPIStatusController.KPIWrapper> result1 = DN_KPIStatusController.getData(ticketList, '2025-05-01', '2025-05-31', '', 'all', 'monthly');
        List<DN_KPIStatusController.KPIWrapper> result2 = DN_KPIStatusController.getData(ticketList, '2025-05-01', '2025-05-31', '', 'all', 'weekly');

    }

    @isTest(SeeAllData=true)
    static void testGetDataTopWorkCenter() {

        Datetime start = Datetime.newInstance(2025, 5, 1);
        Datetime last = Datetime.newInstance(2025, 5, Date.daysInMonth(2025, 5), 23, 59, 59);

        List<Case> ticketList = [   SELECT  Id, ApplicationDateTime__c, ClosedDate, GeneralCallDatetime__c, TechnicalCallDatetime__c, ReceptionPath__c, Status, InternalTicketType__c
                                    FROM Case
                                    WHERE ApplicationDateTime__c >= :start AND ApplicationDateTime__c <= :last AND ApplicationDateTime__c != null
                                    LIMIT 100
        ]; 

        ServiceTerritory st = [SELECT Id FROM ServiceTerritory WHERE classify__c = '지사' LIMIT 1];

        List<DN_KPIStatusController.KPIWrapper> result1 = DN_KPIStatusController.getData(ticketList, '2025-05-01', '2025-05-31', st.Id, 'TopWC', 'monthly');
        List<DN_KPIStatusController.KPIWrapper> result2 = DN_KPIStatusController.getData(ticketList, '2025-05-01', '2025-05-31', st.Id, 'TopWC', 'weekly');

    }
}