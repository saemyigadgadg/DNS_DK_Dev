public with sharing class DN_WCAddressPopUpController {
    /**
     * @Description
     * 	- 주소 검색
     * @author Hanyeong Choi | 06-20-2024
     * @Parameter
     *  - searchText	    : 검색어
     *  - pageNumber	    : 페이징 넘버
    **/ 
    @AuraEnabled
    public static Map<String, Object> getAddress(String searchText, Integer pagingNumber) {
        Map<String, Object> resMap      = new Map<String, Object>();
        IF_MOIS_Address     moisAddress = new IF_MOIS_Address();
        
        try {
            String              resultIF    = moisAddress.getAddressInfo(searchText, String.valueOf(pagingNumber));
            Map<String, Object> resultIFMap = (Map<String, Object>) JSON.deserializeUntyped(resultIF);
            Map<String, object> resultsMap  = (Map<String, object>) resultIFMap.get('results');
            Map<String, object> commonMap   = (Map<String, object>) resultsMap.get('common');
            List<Object>        jusoList    = (List<Object>) resultsMap.get('juso');
    
            resMap.put('totalResultCount',  commonMap.get('totalCount'));
            resMap.put('jusoList',          jusoList);
            resMap.put('flag', 'success');
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            resMap.put('flag', 'fail');
        }
        return resMap;
    }


    /**
     * @Description
     * 	- 주소 선택 후, ServiceTerritory Address 업데이트
     * @author Hanyeong Choi | 06-25-2024
     * @Parameter
     *  - recordId	        : ServiceTerritory Record Id
     *  - address	        : 선택한 address 정보
    **/ 
    @AuraEnabled
    public static Map<String, String> setAddress(String recordId, Map<String, Object> address, Object detailInfo) {
        Map<String, String> resMap = new Map<String, String>();
        try {
            ServiceTerritory st = [
                SELECT Id
                        , Street
                        , PostalCode
                        , sggNm__c
                        , City
                        , Country
                        , State
                        , DetailAddress__c
                FROM ServiceTerritory 
                WHERE Id = :recordId 
                LIMIT 1
            ];

            st.Street      = (String) address.get('roadAddr') + '\n' + detailInfo;
            st.PostalCode  = (String) address.get('zipNo');
            st.sggNm__c    = (String) address.get('siNm') + ' ' + (String) address.get('sggNm');
            st.City        = (String) address.get('siNm');
            st.Country     = 'Korea, Republic of';
            st.State       = '';
            st.DetailAddress__c    = detailInfo + '';

            update st;
            
            resMap.put('flag', 'success');
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            resMap.put('flag', 'fail');
        }
        return resMap;
    }
}