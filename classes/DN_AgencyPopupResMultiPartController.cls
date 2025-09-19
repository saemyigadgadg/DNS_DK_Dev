/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 01. 13. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-13 | Iltae seo      | 최초작성 
 */ 
public with sharing class DN_AgencyPopupResMultiPartController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /**
     * @Description
     * 	- 멀티부품 검색
    **/
    @AuraEnabled
    public static List<Map<String,String>> getParts(List<String> partSearch){
        try {
            List<Map<String, String>> mapList = new List<Map<String, String>>();
            RecordType recType = [select Id, Name, DeveloperName from RecordType where SobjectType ='Product2' AND DeveloperName ='Part'];
            List<Product2> partsList = [select Id, ProductCode, Name from Product2 where ProductCode IN : partSearch AND RecordType.DeveloperName =:recType.DeveloperName];
            for(Product2 prod : partsList) {
                mapList.add(new Map<String, String>{
                    'label' => prod.ProductCode,
                    'value' => prod.Id
                });
            }
            return mapList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 저장위치 멀티 검색
    **/
    @AuraEnabled
    public static List<Map<String,String>> getStorege(List<String> binSearch){
        try {
            List<Map<String, String>> mapList = new List<Map<String, String>>();
            List<DealerLocation__c> locationList = [select Id, Name, Dealer__c, FM_Loc__c from DealerLocation__c where Dealer__c =:currentUser.getAgencyId() AND FM_Loc__c IN : binSearch];
            for(DealerLocation__c loc : locationList) {
                mapList.add(new Map<String, String>{
                    'label' => loc.FM_Loc__c,
                    'value' => loc.Id
                });
            }
            return mapList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 장비번호 검색
    **/
    @AuraEnabled
    public static List<Map<String,String>> equipmentInfo(List<String> mn){
        try {
            List<Map<String, String>> mapList = new List<Map<String, String>>();
            String baseQuery = 'SELECT Id, MachineName__c, Name FROM Asset WHERE MachineName__c != null';
            if (mn.size() > 0) {
                baseQuery += ' AND Name  IN:mn';
            }
            baseQuery += ' LIMIT 1';
            System.debug('query ' +baseQuery);
            List<Asset> unitNumber = Database.query(baseQuery);
            System.debug(unitNumber + ' ::: unitNumber');
            for(Asset asset : unitNumber) {
                mapList.add(new Map<String, String>{
                    'label' => asset.Name,
                    'value' => asset.Name
                });
            }
            return mapList;
        } catch (Exception e) {
            System.debug('error message :: ' + e.getMessage());
            System.debug('error line :: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 기종 검색
    **/
    @AuraEnabled
    public static List<Map<String,String>> machineInfo(List<String> machineName){
        try {
            List<Map<String, String>> mapList = new List<Map<String, String>>();
            List<ModelManager__c> machineList = [SELECT Id, Name, ModelCode__c FROM ModelManager__c WHERE Name IN:machineName LIMIT 1];
            System.debug('machineList : ' +machineList);
            for(ModelManager__c machine : machineList) {
                mapList.add(new Map<String, String>{
                    'label' => machine.Name,
                    'value' => machine.Name
                });
            }
            return mapList;
        } catch (Exception e) {
            System.debug('error message :: ' + e.getMessage());
            System.debug('error line :: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

}