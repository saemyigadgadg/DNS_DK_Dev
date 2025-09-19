/** 
 * @Class : DN_BinManagementController
 * 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 01. 09. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-09 | Iltae seo      | 최초작성 
 */ 
public with sharing class DN_BinManagementController {
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
    public static PageReturn getDataListQuery(PageReturn page, Integer nextPage){
        try {
            // limit 2000건
            PageReturn returnPages = page;
            System.debug(returnPages + ' ::::returnPages');
            returnPages.recordList = new List<sObject>();
            
            // Stage Idx, Last Idx - 인덱스 설정
            Integer startIdx = 0;
            Integer endIdx = 0;
            //페이지 클릭한 경우 처리로직 - 같은 경우 뒤로가기 또는 현재 페이지 클릭
            if(returnPages.currentPage == nextPage) {
                startIdx = (returnPages.currentPage * returnPages.itemsPerPage);
                startIdx = (startIdx - returnPages.itemsPerPage) + 1;
                endIdx = (nextPage*returnPages.itemsPerPage);    
            } else {
                startIdx = (nextPage*returnPages.itemsPerPage -returnPages.itemsPerPage) +1;//(returnPages.currentPage * returnPages.itemsPerPage)+1;
                endIdx = (nextPage*returnPages.itemsPerPage);       
            }
            Integer limitSet = startIdx + endIdx + returnPages.itemsPerPage;
            String strQuery ='';
            String whereQ ='';
            String countQ = 'select count() from DealerLocation__c';
            strQuery +=' select Id,Name,FM_Loc__c,Description__c,Dealer__r.Name from DealerLocation__c ';
            whereQ += ' WHERE Dealer__c =\''+currentUser.getAgencyId()+'\'';
            // whereQ += ' AND SalesOrganization__c =\''+user.SalesOrganization__c+'\''; 
            // whereQ += ' AND DistributionChannel__c =\''+user.DistributionChannel__c+'\''; 
            // whereQ += ' AND Division__c =\''+user.Division__c+'\''; 
            // location
            if( (String) page.strQuery.get('location') !=null) {
                String location =(String) page.strQuery.get('location');
                whereQ += ' AND Id=\''+location+'\'';
            }
            System.debug(strQuery +whereQ+' '+returnPages.orderByField+' '+returnPages.orderBy +' limit ' + limitSet);
            //데이터 조회 래퍼클래스로 설정
            List<DealerLocation__c> dataList = Database.query(strQuery +whereQ+' '+returnPages.orderByField+' '+returnPages.orderBy +' limit ' + limitSet);
            returnPages.recordList = dataList;
            //total size
            returnPages.totalRecordSize = Database.countQuery(countQ + whereQ +' limit 50000');
            List<sObject> recordListSet = new List<sObject>();
            // 시작 데이터 Indx 부터 End Indx까지
            for(Integer i=startIdx-1; i<returnPages.recordList.size(); i++) {
                if(i < endIdx) {
                    recordListSet.add(returnPages.recordList[i]);
                } else {
                    break;
                }
            }
            //리스트 정리 후 재할당
            returnPages.recordList = recordListSet;
            returnPages.startIdx = startIdx;
            returnPages.endIdx = endIdx;
            returnPages.currentPage = nextPage;
            
            return returnPages;
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + ' :::e.getStackTraceString()');
            System.debug(e.getMessage() + ' ::: message');
            throw new DN_BinManagementControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 엑셀 데이터 조회
    **/ 
    @AuraEnabled
    public static PageReturn setExcelData(PageReturn page, Integer nextPage){
        try {
            // limit 2000건
            PageReturn returnPages = page;
            System.debug(returnPages + ' ::::returnPages');
            returnPages.recordList = new List<sObject>();
            
            // Stage Idx, Last Idx - 인덱스 설정
            Integer startIdx = 0;
            Integer endIdx = 0;
            //페이지 클릭한 경우 처리로직 - 같은 경우 뒤로가기 또는 현재 페이지 클릭
            if(returnPages.currentPage == nextPage) {
                startIdx = (returnPages.currentPage * returnPages.itemsPerPage);
                startIdx = (startIdx - returnPages.itemsPerPage) + 1;
                endIdx = (nextPage*returnPages.itemsPerPage);    
            } else {
                startIdx = (nextPage*returnPages.itemsPerPage -returnPages.itemsPerPage) +1;//(returnPages.currentPage * returnPages.itemsPerPage)+1;
                endIdx = (nextPage*returnPages.itemsPerPage);       
            }
            Integer limitSet = startIdx + endIdx + returnPages.itemsPerPage;
            String strQuery ='';
            String whereQ ='';
            String countQ = 'select count() from DealerLocation__c';
            strQuery +=' select Id,Name,FM_Loc__c,Description__c,Dealer__r.Name from DealerLocation__c ';
            whereQ += ' WHERE Dealer__c =\''+currentUser.getAgencyId()+'\'';
            // location
            if( (String) page.strQuery.get('location') !=null) {
                String location =(String) page.strQuery.get('location');
                whereQ += ' AND Id=\''+location+'\'';
            }
            List<DealerLocation__c> dataList = Database.query(strQuery +whereQ+' '+returnPages.orderByField+' '+returnPages.orderBy +' limit ' + limitSet);
            returnPages.allData = dataList;
            //total size
            //returnPages.totalRecordSize = Database.countQuery(countQ + whereQ +' limit 50000');
            List<sObject> recordListSet = new List<sObject>();
            // 시작 데이터 Indx 부터 End Indx까지
            for(Integer i=startIdx-1; i<returnPages.allData.size(); i++) {
                if(i < endIdx) {
                    recordListSet.add(returnPages.allData[i]);
                } else {
                    break;
                }
            }
            //리스트 정리 후 재할당
            returnPages.allData = recordListSet;
            
            return returnPages;
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + ' :::e.getStackTraceString()');
            System.debug(e.getMessage() + ' ::: message');
            throw new DN_BinManagementControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 저장소 삭제
    **/ 
    @AuraEnabled
    public static void locationDelete(List<String> recordIds){
        System.debug(recordIds +' :::: recordIds');
        try { 
            List<DealerLocation__c> deleteList = [select Id from DealerLocation__c where Id IN:recordIds FOR UPDATE];
            delete deleteList;
        } catch (Exception e) {
            throw new DN_BinManagementControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 데이터 리턴 페이징 처리까지
    **/ 
    public class PageReturn {
        @AuraEnabled public Map<String,Object> strQuery { get; set; } // 전체 데이터 쿼리
        @AuraEnabled public Integer totalRecordSize { get; set; } // 전체 레코드 사이즈
        @AuraEnabled public List<sObject> recordList { get; set; } // 현재 페이지 데이터
        @AuraEnabled public List<sObject> allData { get; set; } // 전체데이터
        @AuraEnabled public Integer itemsPerPage { get; set; } // 한 페이지당 표시할 데이터 수
        @AuraEnabled public Integer currentPage { get; set; } // 현재 페이지
        @AuraEnabled public Integer pagesPerGroup {get;set;} // 현재 화면에 표시할 페이지 갯수
        @AuraEnabled public Integer startIdx {get;set;} // 시작인덱스
        @AuraEnabled public Integer endIdx {get;set;} // 마지막인덱스
        @AuraEnabled public String orderByField {get;set;} // 정렬 필드,
        @AuraEnabled public String orderBy {get;set;} // 정렬 필드,
        public PageReturn() {} 
    }
    public class DN_BinManagementControllerException extends Exception {}
}