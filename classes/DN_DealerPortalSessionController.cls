/**
 * @author            : iltae.seo
 * @last modified on  : 2024-12-09
 * @last modified by  : iltae.seo
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-12-09   iltae.seo     Initial Version
**/
public with sharing class DN_DealerPortalSessionController {
    
    /**
     * @Description
     * 	- 딜러포탈에서 화면에 세션 확인
     * @author iltae.seo | 12-09-2024
    **/ 
    @AuraEnabled(cacheable=false)
    public static string getSession(){
        try {
            
            return UserInfo.getUserId();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 딜러포탈에서 대리점 고객은 수정이 불가능함
     * @author iltae.seo | 12-09-2024
    **/     
    public static Boolean getDealerCustomer(String recordId){
        List<DealerCustomer__c> agencyList = [select Id,Name from DealerCustomer__c where Id =:recordId AND SourceAccount__c !=null];
        if(agencyList.size() > 0) {
            return true;
        } else {
            return false;
        }
    }
}