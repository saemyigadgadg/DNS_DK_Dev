/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 02. 04. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-04 | Iltae seo      | 최초작성 
 */ 
public without sharing class DN_ROPFactorController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }
    
    /**
     * @Description
     * 	- 데이터 조회
    **/ 
    @AuraEnabled
    public static Map<String,List<ROPAndStockFactorConfig__c>> getDataList(Map<String,Object> whereCondition){
        try {
            Map<String,List<ROPAndStockFactorConfig__c>> returnMap = new Map<String,List<ROPAndStockFactorConfig__c>>();
            
            RecordType rec = [select Id,DeveloperName from RecordType where DeveloperName ='AreaROPCalculationFactorConfiguration' AND SobjectType = 'ROPAndStockFactorConfig__c'];
            RecordType rec2 = [select Id,DeveloperName from RecordType where DeveloperName ='AreaMaxStockWeightingFactor' AND SobjectType = 'ROPAndStockFactorConfig__c'];
            String strQuery = 'select Id,Name,';
            String whereQ ='';
            String recTypeQ ='';
            String recTypeQ2 ='';
            strQuery += ' Dealer__c, Area__c, Plant__c, ';
            strQuery += ' ABCIndicator__c, TargetServiceLevel__c,';
            strQuery += ' SVCFactor__c, PriceFrom__c, PriceTo__c, ';
            strQuery += ' Weight__c, AMDType__c, DemandPeriod__c';
            strQuery += ' from ROPAndStockFactorConfig__c ';
            whereQ += ' where Dealer__c =\''+currentUser.getAgencyId()+'\'';
            
            String abcIn = (String) whereCondition.get('ABCIndicator__c');
            if(String.isNotBlank(abcIn)) {
                if(abcIn !='All') {
                    whereQ += ' AND ABCIndicator__c=\''+abcIn+'\'';
                }
            }
            
            recTypeQ += ' AND RecordTypeId =\''+rec.Id+'\'';
            recTypeQ2 += ' AND RecordTypeId =\''+rec2.Id+'\'';
            System.debug(strQuery + whereQ + recTypeQ + ' :: strQuery + whereQ + recTypeQ');
            List<ROPAndStockFactorConfig__c> returnROPList = DataBase.query(strQuery + whereQ + recTypeQ);
            List<ROPAndStockFactorConfig__c> returnStockWeightingList = DataBase.query(strQuery + whereQ + recTypeQ2);
            System.debug(returnROPList+ ' ::: returnROPList');
            System.debug(returnStockWeightingList+ ' ::: returnStockWeightingList');
            
            returnMap.put('AreaROPCalculationFactorConfiguration', returnROPList);
            returnMap.put('AreaMaxStockWeightingFactor', returnStockWeightingList);
            return returnMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- Save
    **/ 
    @AuraEnabled
    public static Map<String,List<ROPAndStockFactorConfig__c>> ropFactorSave(Map<String,List<ROPAndStockFactorConfig__c>> saveMap){
        try {
            System.debug(saveMap + ' ::: saveMap');
            List<ROPAndStockFactorConfig__c> returnROPList = saveMap.get('AreaROPCalculationFactorConfiguration');
            List<ROPAndStockFactorConfig__c> returnStockWeightingList = saveMap.get('AreaMaxStockWeightingFactor');
            update returnROPList;
            update returnStockWeightingList;
            return saveMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- IF DealerStock-007 Service factor by target service level 조회
    **/ 
    @AuraEnabled
    public static List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res_ET_SFT> getTslList(){
        try {
            IF_ERP_DealerStock ifs = new IF_ERP_DealerStock();
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res returnIF = ifs.IF_DEALERSTOCK_007();
            List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res_ET_SFT> tslList = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res_ET_SFT>();
            System.debug(returnIF.ET_SFT+ ' ::: returnIF.ET_SFT;');
            tslList = returnIF.ET_SFT;
            return tslList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}