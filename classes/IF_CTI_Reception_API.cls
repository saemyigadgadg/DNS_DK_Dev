/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-06-17
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-28-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
@RestResource(urlMapping='/CTI/getReception')
global with sharing class IF_CTI_Reception_API {

    @HttpGet
    global static  Map<String, Integer> getReception(){

        Integer ReceptionTotCnt = 0;
        Integer Reception1stCnt = 0;
        Integer ReceptionNconsultedCnt = 0;
        Integer Reception40Cnt = 0;
        
        List<Case> totCaseList = [SELECT ID FROM Case
                                  WHERE TicketType__c = 'Technical inquiry'
                                  AND ApplicationDateTime__c = Today];
        
        List<Case> totNewCaseList = [SELECT ID FROM Case
                                     WHERE TicketType__c = 'Technical inquiry'
                                     AND ApplicationDateTime__c = Today
                                     AND Status = 'New'];
        
        List<Case> totNoCaseList = [SELECT ID,ApplicationDateTime__c FROM Case
                                    WHERE TicketType__c = 'Technical inquiry'
                                    AND ApplicationDateTime__c = Today
                                    AND Status = 'New'
                                    AND TechnicalCallDatetime__c = null];
        
        Integer ago40MCnt = 0;
        for(Case obj : totNoCaseList){
        	DateTime ago40M	= obj.ApplicationDateTime__c.addMinutes(40);
            if(DateTime.Now() >= ago40M) ago40MCnt++;
        }
        

        return new  Map<String, Integer> {
            'ReceptionTotCnt' => totcaseList.Size(),
            'Reception1stCnt' => totNewCaseList.Size(),
            'ReceptionNconsultedCnt' => totNoCaseList.Size(),
            'Reception40Cnt' => ago40MCnt
        };
    }

}