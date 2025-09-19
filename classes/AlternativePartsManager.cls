/** 
 * @Class :  AlternativePartsManager
 * 
 * @Test: AlternativePartsManager_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 02. 26. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-26 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class AlternativePartsManager {
    
    private Set<String> partCodes {
        get {
            if(partCodes == null) partCodes = new Set<String>();
            return partCodes;
        }
        set;
    }

    private Boolean isLastParts { //partCodes 가 LastParts인 경우
        get {
            if(isLastParts == null) isLastParts = false;
            return isLastParts;
        }
        set;
    }

    private String plantCode {
        get {
            if(String.isBlank(plantCode)) plantCode = '1846';
            return plantCode;
        }
        set;
    }

    private Map<String, String> replacingItemMap {
        get {
            if(replacingItemMap == null) replacingItemMap = new Map<String, String>();
            return replacingItemMap;
        }
        set;
    }

    private Map<String, String> replacingItemTypeMap {
        get {
            if(replacingItemTypeMap == null) replacingItemTypeMap = new Map<String, String>();
            return replacingItemTypeMap;
        }
        set; 
    }

    private Map<String, ProductByPlant__c> replacingInfoMap {
        get {
            if(replacingInfoMap == null) replacingInfoMap = new Map<String, ProductByPlant__c>();
            return replacingInfoMap;
        }
        set;
    }   
    
    /*
    * @ 생성자 : AlternativePartsManager
    * @ Description : partCodes 설정
    */
    public AlternativePartsManager(Set<String> partCodes) {
        this.partCodes = partCodes;
    }

    /*
    * @ 생성자 : AlternativePartsManager
    * @ Description : partCodes,isLastParts 설정
    */
    public AlternativePartsManager(Set<String> partCodes, Boolean isLastParts) {
        this.partCodes = partCodes;
        this.isLastParts = isLastParts;
    }

    /*
    * @ 생성자 : AlternativePartsManager
    * @ Description : plantCode,partCodes 설정
    */
    public AlternativePartsManager(String plantCode, Set<String> partCodes) {
        this.plantCode = plantCode;
        this.partCodes = partCodes;
    }

    /*
    * @ 생성자 : AlternativePartsManager
    * @ Description : plantCode,partCodes,isLastParts 설정
    */
    public AlternativePartsManager(String plantCode, Set<String> partCodes, Boolean isLastParts) {
        this.plantCode = plantCode;
        this.partCodes = partCodes;
        this.isLastParts = isLastParts;
    }

    /*
    * @ Method : setReplacementPartsForProduct
    * @ Description : 조건식에 따른 replacingItemMap에 담아둔다.
    */
    public void setReplacementPartsForProduct() {
        replacingItemMap.clear();
        Set<String> lastPartCodes = new Set<String>();

        if(isLastParts) {
            lastPartCodes = partCodes;
        }else {
            for(ProductByPlant__c plantByProduct : [
                SELECT
                    Id, Plant__c, Part__r.ProductCode, ReplacingPart__r.ProductCode, StartPart__r.ProductCode, LastPart__r.ProductCode, LastPart__c, InterchangeabilityCode__c
                FROM ProductByPlant__c where Part__r.ProductCode IN :partCodes  and Plant__c = :plantCode
            ]) {
                if(String.isNotBlank(plantByProduct.LastPart__r.ProductCode)) lastPartCodes.add(plantByProduct.LastPart__r.ProductCode);
            }
        }

        List<ProductByPlant__c> replacingInfoList = [
            SELECT
                Id, Plant__c, Part__r.ProductCode, ReplacingPart__r.ProductCode, StartPart__r.ProductCode, LastPart__r.ProductCode, InterchangeabilityCode__c
            FROM ProductByPlant__c where LastPart__r.ProductCode IN :lastPartCodes  and Plant__c = :plantCode
            ORDER BY  ReplacingPart__c  NULLS  LAST, InterchangeabilityCode__c asc
        ];

       
        for(Integer i=0; i < replacingInfoList.size(); i++) {
            ProductByPlant__c plantByProduct = replacingInfoList.get(i);
            replacingInfoMap.put(plantByProduct.Part__r.ProductCode , plantByProduct);
            replacingItemTypeMap.put(plantByProduct.Part__r.ProductCode, plantByProduct.InterchangeabilityCode__c);
        }

        for(Integer i=0; i < replacingInfoList.size(); i++) {
            ProductByPlant__c plantByProduct = replacingInfoList.get(i);
            String startPartCode = plantByProduct.StartPart__r.ProductCode;
            if(String.isBlank(startPartCode)) continue;

            String replacingInfos = recursionPlant(replacingInfoMap, plantByProduct);
            System.debug(replacingInfos);

            if(replacingItemMap.containsKey(startPartCode)) continue;
            else replacingItemMap.put(startPartCode, replacingInfos);
        }

    }

    /*
    * @ Method : recursionPlant
    * @ Description : 조건식에 따른 currentPartCode 반환
    */
    private String recursionPlant(Map<String, ProductByPlant__c> replacingInfoMap, ProductByPlant__c currentInfo) {
        String currentPartCode = currentInfo.Part__r.ProductCode;
        String replacingPartCode = currentInfo.ReplacingPart__r.ProductCode;
        
        if(String.isNotBlank(replacingPartCode) && replacingInfoMap.containsKey(replacingPartCode)) {
            return currentPartCode + '_' + recursionPlant(replacingInfoMap, replacingInfoMap.get(replacingPartCode));
        }else {
            return currentPartCode;
        }
    }

    /*
    * @ Method : recursionPlant
    * @ Description : 조건식에 따른 currentPartCode 반환
    */
    public Map<String, String> getReplacementParts() {
        return replacingItemMap;
    }

    /*
    * @ Method : getReplacingItemTypeMap
    * @ Description : replacingItemTypeMap 반환
    */
    public Map<String, String> getReplacingItemTypeMap() {
        return replacingItemTypeMap;
    }
 
    /*
    * @ Method : getReplacingPartInfo
    * @ Description : replacingInfoMap 반환
    */
    public Map<String, ProductByPlant__c> getReplacingPartInfo() {
        return replacingInfoMap;
    }
}