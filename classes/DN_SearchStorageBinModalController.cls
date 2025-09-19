/** 
 * @Class : DN_SearchStorageBinModalController
 * 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 01. 08. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-08 | Iltae seo      | 최초작성 
 */ 
public with sharing class DN_SearchStorageBinModalController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /**
     * @Description
     * 	- 재고 위치 목록
    **/ 
    @AuraEnabled
    public static List<DealerLocation__c> getLocationList(String search){
        try {
            System.debug(search + ' ::: search');
            System.debug('getLocationList ++ getLocationList');
            String strQ = 'select Id, Name, FM_Loc__c from DealerLocation__c WHERE Id !=null ';
            String agencyId = currentUser.getAgencyId();
            strQ += Network.getNetworkId() != null ? ' AND Dealer__c=\''+agencyId+'\'' : '';
            if(String.isNotBlank(search)) {
                strQ += ' AND FM_Loc__c =\''+search+'\'';
            }
            System.debug(strQ + ' <===strQ');
            List<DealerLocation__c> locationList = Database.query(strQ+ ' LIMIT 500');
               
            return locationList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}