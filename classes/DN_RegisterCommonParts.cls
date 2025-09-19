/**
 * @description       : 공통부품 모달창
 * @author            : junyeong.choi@sbtglobal.com
 * @group             : 
 * @last modified on  : 2024-11-19
 * @last modified by  : junyeong.choi@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   11-19-2024   junyeong.choi@sbtglobal.com   Initial Version
**/
public with sharing class DN_RegisterCommonParts {

    /* 
    @ description : 공통부품(Product) 검색
    */ 
    @AuraEnabled
    public static List<CommonPartsWrapper> searchCommonParts(String productName, String productNo){
        List<CommonPartsWrapper> resultData = new List<CommonPartsWrapper>();

        List<Product2> productList = new List<Product2>();
    
        try {
            String sQuery = 'SELECT Id, Name, ProductCode FROM Product2';
            List<String> wQuery = new List<String>();
    
            if (String.isNotEmpty(productName)) {
                List<String> splitProductName = productName.split(',');
                List<String> nameConditions = new List<String>();
                for (String prodName : splitProductName) {
                    nameConditions.add('Name LIKE \'%' + String.escapeSingleQuotes(prodName.trim()) + '%\'');
                }
                if (!nameConditions.isEmpty()) {
                    wQuery.add('(' + String.join(nameConditions, ' OR ') + ')');
                }
            }
    
            if (String.isNotEmpty(productNo)) {
                List<String> splitProductNo = productNo.split(',');
                List<String> noConditions = new List<String>();
                for (String prodNo : splitProductNo) {
                    noConditions.add('ProductCode LIKE \'%' + String.escapeSingleQuotes(prodNo.trim()) + '%\'');
                }
                if (!noConditions.isEmpty()) {
                    wQuery.add('(' + String.join(noConditions, ' OR ') + ')');
                }
            }
    
            // 조건 추가
            if (!wQuery.isEmpty()) {
                sQuery += ' WHERE ' + String.join(wQuery, ' AND ');
            }
            System.debug('sQuery: ' + sQuery);
            productList = Database.query(sQuery);
            System.debug('productList : ' + productList);

            for (Product2 prod : productList) {
                CommonPartsWrapper wrapper = new CommonPartsWrapper();
                wrapper.ProductName = prod.Name;
                wrapper.ProductNo = prod.ProductCode;
                resultData.add(wrapper);
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    
        return resultData;
    }

    /* 
    @ description : 조회한공통부품(Product) 선택
    */ 
    @AuraEnabled
    public static List<CommonPartsWrapper> selectCommonParts(String pdData){
        List<CommonPartsWrapper> resultData = new List<CommonPartsWrapper>();
        try {
            if(String.isNotEmpty(pdData)){
                Map<String, Object> productInfo = (Map<String, Object>) JSON.deserializeUntyped(pdData);
                System.debug('pdData :: '+productInfo.get('prodId'));

                String productId = String.valueOf(productInfo.get('prodId'));

                if (productInfo.get('prodId') != null) {
                    List<Product2> productQueryList = [
                        SELECT Id, Name, ProductCode, FM_MaterialDetails__c
                        FROM Product2 
                        WHERE Id = :productId
                    ];
                    System.debug('productQueryList: ' + productQueryList);

                    for(Product2 product : productQueryList) {
                        CommonPartsWrapper cpw = new CommonPartsWrapper();
                        cpw.ProductName   = product.FM_MaterialDetails__c;
                        cpw.ProductNo     = product.ProductCode;
                        cpw.ProductId     = product.Id;
                        // cpw.prodQuantity  = 1;
                        resultData.add(cpw);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    
        return resultData;
    }

    /* 
    @ description : 공통부품 저장 Method
    */ 
    @AuraEnabled
    public static ResultWrapper saveCommonParts(Id recordId, List<Map<String, Object>> registerData){
        ResultWrapper resultData = new ResultWrapper();
        try {
            List<CommonPart__c> insertToParts = new List<CommonPart__c>();
            Set<Id> existingPartIds = new Set<Id>();
            for (CommonPart__c part : [SELECT Product__c FROM CommonPart__c WHERE Campaign__c = :recordId]) {
                if (part.Product__c != null) {
                    existingPartIds.add(part.Product__c);
                }
            }    
            for (Map<String, Object> data : registerData) {
                Id prodId = (Id)data.get('prodId');
                System.debug('prodId : ' + prodId);
                if (existingPartIds.contains(prodId)) {
                    resultData.isSuccess = false;
                    return resultData;
                }
    
                // 새 레코드 생성
                CommonPart__c prod = new CommonPart__c();
                prod.Campaign__c = recordId;
                prod.Product__c = prodId;
                prod.PartsNo__c = (String)data.get('prodNumber');
                prod.Quantity__c = Integer.valueOf(data.get('prodQuantity'));
                prod.Note__c = (String)data.get('prodNote');
                insertToParts.add(prod);
            }
    
            System.debug('insertToParts : ' + insertToParts);
            insert insertToParts;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            resultData.isSuccess = false;
            resultData.errMessage = e.getMessage();
        }
        return resultData;
    }
    
    /*
     * @Description 
     *  - Common Parts Wrapper
     * 
     * @Variable 
     *  - AssetId	        :   제조번호
     *  - Name	            :   제조번호
     *  - AccountName	    :   고객사명
     *  - BusinessNumber    :   사업자번호
     *  - Representative    :   대표자
     *  - Phone	            :   전화
     */ 
    public class CommonPartsWrapper {
        @AuraEnabled public String ProductId             {get; set;}
        @AuraEnabled public String ProductName           {get; set;}
        @AuraEnabled public String ProductNo             {get; set;}
        @AuraEnabled public Integer prodQuantity         {get; set;}
        @AuraEnabled public String prodNote              {get; set;}

        public CommonPartsWrapper() {
            this.ProductId      =  '';
            this.ProductName    =  '';
            this.ProductNo      =  '';
            this.prodQuantity   =  1;
            this.prodNote   =  '';
        }
    }

    /*
     * @Description 
     *  - Apex Callout 실행 결과용 Wrapper
     * 
     * @Variable 
     *  - isSuccess 	: 성공 여부
     *  - errMessage 	: 실패 시 에러메세지 
     */ 
    public class ResultWrapper{
        @AuraEnabled public Boolean isSuccess  { get; set;}
        @AuraEnabled public String  errMessage { get; set;}
        
        public ResultWrapper(){
            this.isSuccess = true;
        }
    }
}