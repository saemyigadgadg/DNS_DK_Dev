/**
 * @author : SUNG SEOUK
 * @since  : 2024-06-18
 * ** 행정안전부에서 제공하는 주소 검색 API 사용 
 */
public with sharing class IF_MOIS_Address {

    public IF_MOIS_Address() {}
    public static final String apexClassName = 'IF_MOIS_Address'; 
    public class MoisApiException extends Exception{}
    
    private InterfaceCommonUtil utils = new InterfaceCommonUtil();  


    private static List<String> injectionMap = new List<String>{
          '\'+or+\'1\'=\'1'
        , '\' and \'f\'=\'f'
        , '%27+and+'
        , 'UNION+SELECT'
        , '%27+and+%27x%27%3D'
        , 'or,'
        , 'select'
        , 'insert'
        , 'update'
        , 'create'
        , 'drop'  
        , 'exec'  
        , 'union' 
        , 'fetch' 
        , 'declare'
        , '<'   
        , '>'   
        , '='   
        , '%'   
    };

    

    /**
     *
     * @author : SUNG SEOUK
     * @since  : 2024-06-18
     * @param  : String loadInfo ? 검색 정보 ex) 대왕판교로, 스타벅스
     * @param  : String pageNo   ? 검색 페이지 정보 ex) 1, 2 ...
     * @reference : 팝업 API - U01TX0FVVEgyMDI0MDYxODEzMzAwODExNDg0OTQ= 
     * <h3> Debug Log Code </h3>

        IF_MOIS_Address mois = new IF_MOIS_Address();
        mois.getAddressInfo('대왕판교로','1');


        <h3> Debug Log Code for SQL InjectionTedst</h3>

        IF_MOIS_Address mois = new IF_MOIS_Address();
        mois.getAddressInfo('UNION+SELECT','1');


        <h3> Page No Numeric Exception TEST </h3>
        
        IF_MOIS_Address mois = new IF_MOIS_Address();
        mois.getAddressInfo('대왕판교로','s');
     */
    public String getAddressInfo(String loadInfo,String pageNo){

        // 0. Sql Injection Detecting
        Boolean isInjectionDetecting = False;

        // for(String injectionCode : injectionMap ){
        //     if( loadInfo.contains(injectionCode) ) {
        //         isInjectionDetecting = True;
        //         break;
        //     }
        // }

        // // ** SQL Injection 위험이 있는 코드 발견시 예외 발생 
        if(isInjectionDetecting){
            String exceptionMsg = 'SQL Injection Detected. Search Keyword :' + loadInfo;
            System.debug(exceptionMsg);
            throw new IF_MOIS_Address.MoisApiException(exceptionMsg);        }

        // 1. 
        if( !pageNo.isNumeric() ) {
            String exceptionMsg = 'PageNo Have to Integer Type :' + pageNo;
            System.debug(exceptionMsg);
            throw new IF_MOIS_Address.MoisApiException(exceptionMsg);
        }


        // 2. Interface Id 
        String             interfaceId = 'MOIS_ADDRESS';

        // 2. Page Default Set 
        if(pageNo == null || pageNo == '') { pageNo = '1'; }

        // 3. 

        

        IF_Authentication__mdt ifAuthMdt = [
                                            SELECT  Id, SecretKey__c
                                            FROM    IF_Authentication__mdt
                                            WHERE   System__c = '행정안전부'
                                            LIMIT   1 ];
        
        loadInfo = EncodingUtil.urlEncode(loadInfo, 'UTF-8');
        utils.queryStringParam = 'currentPage='+pageNo+'&countPerPage=15&keyword='+loadInfo+'&confmKey='+ifAuthMdt.SecretKey__c+'&hstryYn=Y&resultType=json';

        System.debug('utils.queryStringParam >>' + utils.queryStringParam);

        // SQL Injection TEST 시 하위 코드 반드시 주석 처리 
        String result = utils.sendHttp('', interfaceId, apexClassName, false );
        System.debug('[ MIOS Interface Callout Result ] ' + result);

        return result;
    }
}