/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 03-26-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-20-2024   daewook.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_APController {
    //IF-PARTS-020 외상매입금 리스트 조회
    @AuraEnabled
    public static IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res getInvoiceList(InvoiceSearch search){
        try {
            // 파람값
            IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Req  req = new IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Req();
            req.I_KUNNR = search.I_KUNNR;
            req.I_SPART = search.I_SPART;
            req.I_VKORG = search.I_VKORG;
            req.I_VTWEG = search.I_VTWEG;
            req.I_F_VBELN = search.I_F_VBELN;
            req.I_T_VBELN = search.I_T_VBELN;
            req.I_F_BLDAT = search.I_F_BLDAT;
            req.I_T_BLDAT = search.I_T_BLDAT;
            // 인터페이스 실행
            IF_ERP_Parts_receivable erpService = new IF_ERP_Parts_receivable();
            IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res res =erpService.IF_PARTS_020(req);

            //public IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res IF_PARTS_020(IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Req parameters){
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //IF-PARTS-023 외상매입금 상세 조회
    @AuraEnabled
    public static IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Res getDetail(String vbeln){
        try {
            // Param
            IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Req req = new IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Req();
            req.I_VBELN = vbeln;
            // 인터페이스 호출
            IF_ERP_Parts_receivable erpService = new IF_ERP_Parts_receivable();
            IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Res res = erpService.IF_PARTS_023(req);
            
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
    * @description 로그인된 사용자 확인 
    * @author Chungwoo Lee | 11-12-2024 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> getLoginUserInfo() {
        Map<String, Object> resMap = new Map<String, Object>();
        String workCenter = '';
        Boolean isBranch = false;
        ServiceResource workerInfo = new ServiceResource(); 
        try {
            User user = [select Id, Name, Account.Name, Account.CustomerCode__c,DistributionChannel__c,SalesOrganization__c,Division__c from User where Id=:UserInfo.getUserId()];
            resMap.put('workerInfo', user);
        } catch (Exception e) {
            System.debug('Error in getLoginUserInfo: ' + e.getMessage());
            resMap.put('flag', 'error');
            resMap.put('Message', 'catch Exception ::: ' + e.getMessage());
        }
        return resMap;
    }


    public class InvoiceSearch {
        @AuraEnabled public String I_KUNNR      {get;set;} // 딜러코드 1244220
        @AuraEnabled public String I_VKORG      {get;set;} // 일단 1846 고정
        @AuraEnabled public String I_VTWEG      {get;set;} // 일단 10 고정
        @AuraEnabled public String I_SPART      {get;set;} // 일단 40 고정

        @AuraEnabled public String I_F_VBELN    {get;set;} // 문서번호 시작
        @AuraEnabled public String I_T_VBELN    {get;set;} // 문서번호 종료
        // @AuraEnabled public String I_F_ZFCIVNO  {get;set;}
        // @AuraEnabled public String I_T_ZFCIVNO  {get;set;}
        
        @AuraEnabled public String I_F_BLDAT    {get;set;} // 판매일자 시작
        @AuraEnabled public String I_T_BLDAT    {get;set;} // 판매일자 종료
        // @AuraEnabled public String I_SPRAS      {get;set;}
        // @AuraEnabled public String I_AUART      {get;set;}
    } 
}