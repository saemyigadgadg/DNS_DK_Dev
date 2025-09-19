/**
*
* @Author : iltae, Seo
* @Date : 2025. 03. 26.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2025-03-26 | iltae, Seo     | 최초작성
*
*/
public with sharing class DN_WarrantyHistorySearchController {
    
    /**
     * @Description
     * 	- 무상 이력 조회
    **/
    @AuraEnabled
    public static List<WarrantyHistory> getWarrantyHistory(SearchOption search){
        try {
            Boolean isVal = true;

            System.debug(search + ' ::::search');
            List<WarrantyHistory> wHistoryList = new List<WarrantyHistory>();
            String sQuery = 'select Id,CreatedDate,Product__r.ProductCode,';
                    sQuery += 'WorkOrder.Asset.SerialNumber,';
                    sQuery += 'Product__c,';
                    sQuery += 'ProductCode__c,';
                    sQuery += 'WorkOrder.Account.Name,';
                    sQuery += 'Product__r.FM_MaterialDetails__c';
                    sQuery += ' from ProductRequest ';
            String wQuery = ' where WorkOrder.OrderType__c =\'201\'';
                    wQuery +=' AND WorkOrder.PMActivityType__c =\'CS02\'';
                    wQuery +=' AND Product__c !=null';
                    wQuery +=' AND WorkOrder.Asset.SerialNumber  !=null ';
                    wQuery +=' AND Product__r.RecordType.Name =\'Part\'';
                    
            //기종
            if(String.isNotBlank(search.Type)) {
                wQuery += ' AND WorkOrder.Asset.MachineName__c =\''+search.Type+'\'';
                isVal = false;
            }
            //장비번호
            if(String.isNotBlank(search.SerialNumber)) {
                wQuery += ' AND WorkOrder.Asset.SerialNumber =\''+search.SerialNumber+'\'';
                isVal = false;
            }
            if(isVal) {
                throw new DN_WarrantyHistorySearchControllerException('기종 또는 장비번호는 필수로 입력해주세요');
                
            }
            // 날짜
            // 날짜 부분 추출
            Date dateEnd = search.historyEnd.date(); 
            // 시간 변경: 23시 23분 59초로 설정
            DateTime updatedHistoryEnd = DateTime.newInstance(
                dateEnd.year(),
                dateEnd.month(),
                dateEnd.day(),
                23, // 시
                23, // 분
                59  // 초
            );
            // 날짜
            DateTime start = search.historyStart;
            
            wQuery += ' AND (CreatedDate >=:start AND CreatedDate <=:updatedHistoryEnd )';

            System.debug(sQuery + wQuery + search.orderByField +' '+search.orderBy + ' ::::');
            List<ProductRequest> productList = Database.query(sQuery + wQuery +' '+search.orderByField +' '+search.orderBy);
            System.debug(productList + ' : productList');
            for(ProductRequest req : productList) {
                wHistoryList.add(new WarrantyHistory(req));
            }
            /**
             * 1. 무상 서비스 오더 : WorkOrder의 OrderType__c = '201'
                2. Service Order Type 'CS02' : WorkOrder.PMActivityType__c = 'CS02'
                3. Plant '184S' 만 조회 > WorkOrder 자체가 Plant '184S' 라 조회조건에 필요없음
                4. 부품이 포함된 서비스 오더만 해당 : ProductRequest.Part__c != null
             */
            return wHistoryList;
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + ' :::e.getStackTraceString()');
            System.debug(e.getMessage() + ' ::: message');
            throw new DN_WarrantyHistorySearchControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 무상 이력 히스토리 클래스
    **/
    public class WarrantyHistory {
        @AuraEnabled public String serialNumber {get;set;} // 장비번호
        @AuraEnabled public String accountName {get;set;} // 고객명
        @AuraEnabled public String createdDate {get;set;} // 서비스 생성일자
        @AuraEnabled public String partName {get;set;} // 부품번호
        @AuraEnabled public String partNumber {get;set;} // 부품명
        public WarrantyHistory() {}
        public WarrantyHistory(ProductRequest req) {
            this.serialNumber     = req.WorkOrder.Asset.SerialNumber;                      
            this.accountName      = req.WorkOrder.Account.Name;                    
            this.createdDate      = req.CreatedDate.format('YYYY.MM.dd');                    
            this.partName         = req.Product__r.ProductCode;               
            this.partNumber       = req.Product__r.FM_MaterialDetails__c;
        } 
    }

    /**
     * @Description
     * 	- 검색 조건 클래스
    **/
    public class SearchOption {
        @AuraEnabled public String Type {get;set;} // 기종 
        @AuraEnabled public String SerialNumber {get;set;} //장비번호
        @AuraEnabled public DateTime historyStart {get;set;} // 조회 기간 - 시작
        @AuraEnabled public DateTime historyEnd {get;set;} // 조회 기간 - 종료
        @AuraEnabled public String orderByField {get;set;} // 정렬기준 필드
        @AuraEnabled public String orderBy {get;set;} // 정렬 : ASC, DESC
    }

    public class DN_WarrantyHistorySearchControllerException extends Exception {}
    
}