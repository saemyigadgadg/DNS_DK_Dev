/**
 * @description       : 
 * @author            : Chungwoo Lee
 * @last modified on  : 05-23-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-01-2024   Chungwoo Lee   Initial Version
**/
public without sharing class DN_PortalManageServiceController {
    
    /**
    * @description 로그인된 사용자 확인  
    * @author Chungwoo Lee | 11-12-2024 
    **/
    @AuraEnabled
    public static Map<String, Object> getLoginUserInfo() {
        Map<String, Object> resMap = new Map<String, Object>();
        String workCenter = '';
        Boolean isBranch = false;
        Boolean isRepresentative = false;
        ServiceResource workerInfo = new ServiceResource(); 
        try {
            User currentUser = [SELECT Id, IsPortalRepresentative__c FROM User WHERE Id=:userInfo.getUserId() LIMIT 1];

            if (String.isBlank(currentUser.Id)) {
                workCenter = '';
                resMap.put('flag','warning');
                resMap.put('Message', 'Please check your login status.');
                return resMap;
            } else {
                workerInfo  = [SELECT Id , Name 
                                , Service_Territory__c, Service_Territory__r.Name, Service_Territory__r.WCCode__c, Service_Territory__r.ControlWorkcenter__c 
                                , Service_Territory__r.classify__c, AccountId, Account.Name, RelatedRecordId, RelatedRecord.Name, RelatedRecord.Plant__c,
                                RelatedRecord.Account.CustomerCode__c, RelatedRecord.UserCode__c
                                FROM ServiceResource 
                                WHERE RelatedRecordId =: userInfo.getUserId()
                                LIMIT 1];
            }
            
            if(workerInfo == null) {
                resMap.put('workerInfo', '');
                resMap.put('flag','warning');
                resMap.put('Message', 'This user is not registered as a worker.');
                return resMap;
            }
            if (workerInfo.Service_Territory__r.classify__c == '지사') {
                isBranch = true;
            }
            
            if (currentUser.IsPortalRepresentative__c) {
                isRepresentative = true;
            }

            resMap.put('isRepresentative', isRepresentative);
            resMap.put('isBranch', isBranch);
            resMap.put('workerInfo', workerInfo);
            resMap.put('flag', 'success');
        } catch (Exception e) {
            System.debug('Error in getLoginUserInfo: ' + e.getMessage());
            resMap.put('flag', 'error');
            resMap.put('Message', 'catch Exception ::: ' + e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 비용정산 조회
    * @author Chungwoo Lee | 11-29-2024 
    **/
    @AuraEnabled
    public static Map<String, Object> serviceCostAdjustment(Map<String, Object> fieldMap) {
        Map<String, Object> resMap = new Map<String, Object>();
        List<WorkOrder> serviceHistoryList = new List<WorkOrder>();
        
        try {
            System.debug('IF_SERVICE_043_Req ::: ' + fieldMap);
            
            IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res erpResponse = interfaceCostAdjustment043(fieldMap);

            System.debug('test Response ::: ' + erpResponse);

            if (erpResponse.O_RETURN.TYPE == 'S') { 
                resMap.put('erpResponse', erpResponse);
                resMap.put('flag', 'success');
            } else if (erpResponse.O_RETURN.TYPE == 'E' && erpResponse.O_RETURN.MESSAGE.contains('No Data Found')) {
                resMap.put('erpResponse', erpResponse);
                resMap.put('flag', 'success');
            } else {
                resMap.put('flag'   , 'error');
                resMap.put('errorString', 'ERP validation failed: ' + (erpResponse.O_RETURN.MESSAGE != null ? erpResponse.O_RETURN.MESSAGE : 'Unknown error'));
                return resMap;
            }
            
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            resMap.put('flag', 'error');
            resMap.put('errorMessage', e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 비용정산 조회 (IF-SERVICE-043) Callout
    **/
    private static IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res interfaceCostAdjustment043(Map<String, Object> fieldMap) {
        IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Req erpParameters = new IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Req();
        User loginUser = [SELECT Id, Plant__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Req_I_USERINFO i_USERINFO = new IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Req_I_USERINFO();
        i_USERINFO.ARBPL  =   (String) fieldMap.get('workCenterCode');
        i_USERINFO.BNAME  =   loginUser.Id; 
        i_USERINFO.WERKS  =   loginUser.Plant__c;
        erpParameters.I_USERINFO = i_USERINFO;

        String orderNumber = (String) fieldMap.get('orderNumber');

        if (orderNumber != null && orderNumber.startsWith('000')) {
            orderNumber = orderNumber.replaceFirst('^0+', '');
        }
        
        erpParameters.I_AUFNR       = orderNumber;
        erpParameters.I_DATE_FR     = (String) fieldMap.get('dateFrom');
        erpParameters.I_DATE_TO     = (String) fieldMap.get('dateTo');
        erpParameters.I_TYPE        = (String) fieldMap.get('orderType');
        
        IF_ERP_Service_CostAdjustment erpService = new IF_ERP_Service_CostAdjustment();
        return erpService.IF_SERVICE_043(erpParameters);
    }

    /**
    * @description 비용정산 저장(Order 번호를 기준으로 테이블 업데이트)
    * @author iltae seo | 12-20-2024 
    * @param fieldMap 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> serviceCostAdjustmentSend(List<CostAdjustmentSend> saveList){
        Map<String,Object> resMap = new Map<String,Object>();
        try {
            System.debug(saveList + ' < ==saveList');
            IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Res erpResponse = interfaceCostAdjustment044(saveList);
            System.debug(erpResponse + ' < ===erpResponse');
            if (erpResponse.O_RETURN.TYPE == 'S') { 
                resMap.put('erpResponse', erpResponse);
                resMap.put('flag', 'success');
            } else {
                resMap.put('flag'   , 'error');
                resMap.put('errorString', 'ERP validation failed: ' + (erpResponse.O_RETURN.MESSAGE != null ? erpResponse.O_RETURN.MESSAGE : 'Unknown error'));
            }            
        } catch (Exception e) {
            resMap.put('flag', 'error');
            resMap.put('errorMessage', e.getMessage());
        }
        return resMap;
    }
    
    /**
    * @description 비용정산 저장 (IF-SERVICE-044) Callout
    **/
    private static IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Res interfaceCostAdjustment044(List<CostAdjustmentSend> req) {
        IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Req erpParameters = new IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Req();
        erpParameters.IT_ITEM = new List<IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Req_IT_ITEM>();
        // 인터페이스에 필요한 필드 매핑
        System.debug(req + ' >< ==req');
        for(CostAdjustmentSend cost : req) {
            IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Req_IT_ITEM reqItem = new IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Req_IT_ITEM();
            reqItem.AUFNR       = cost.AUFNR;
            reqItem.SEQNO       = cost.SEQNO;
            reqItem.WEB_CHK     = cost.WEB_CHK;
            erpParameters.IT_ITEM.add(reqItem);
        }
        IF_ERP_Service_CostAdjustment erpService = new IF_ERP_Service_CostAdjustment();
        // 인터페이스 호출 후 리턴정보
        return erpService.IF_SERVICE_044(erpParameters);
    }

    /**
    * @description 비용정산 저장 (IF-SERVICE-044) Wrapper
    **/
    public class CostAdjustmentSend {
        @AuraEnabled public String AUFNR   {get;set;} //  Order Number
        @AuraEnabled public String SEQNO   {get;set;} //  Sequential no
        @AuraEnabled public String WEB_CHK {get;set;} //  General Flag
    }

    /**
    * @description 전표 발행 (IF-SERVICE-048) Wrapper
    **/
    public String MATNR { get; set; }
    public String AUFNR { get; set; }

    public class OutputWrapper {
        public IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Res_T_OUTPUT data { get; set; }
        public String isLast { get; set; }
        public Boolean isEven { get; set; }
    }
    
    public List<OutputWrapper> wrapList { get; set; }

    public DN_PortalManageServiceController() {
        // URL 파라미터 읽기
        System.debug(ApexPages.currentPage().getParameters().get('MATNR') + ' <== matnr');
        System.debug(ApexPages.currentPage().getParameters().get('AUFNR') + ' <== aufnr');
        try {
            MATNR = '';
            AUFNR = '';
            MATNR = ApexPages.currentPage().getParameters().get('MATNR');
            AUFNR = ApexPages.currentPage().getParameters().get('AUFNR');
            System.debug(AUFNR + ' < ==AUFNR');
            System.debug(MATNR + ' < ==MATNR');
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    /**
    * @description VF Page 전표 발행 (IF-SERVICE-048) Callout
    **/
    public void getAction() {
        try {
            System.debug('action!!!!');
            List<String> matnrList = MATNR.split(',');
            List<String> aufnrList = AUFNR.split(',');
            IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Req  req = new IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Req();  
            req.T_INPUT = new List<IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Req_T_INPUT>(); 
            for(Integer i=0; i<matnrList.size(); i++) {
                IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Req_T_INPUT reqInput = new IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Req_T_INPUT();
                reqInput.MATNR = matnrList[i];
                reqInput.AUFNR = '000'+aufnrList[i];
                req.T_INPUT.add(reqInput);
            }

            IF_ERP_Service_Scrap erpService= new IF_ERP_Service_Scrap();
            IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Res res = erpService.IF_SERVICE_048(req);

            wrapList = new List<OutputWrapper>();
            if (res.T_OUTPUT != null) {
                for (Integer i = 0; i < res.T_OUTPUT.size(); i++) {
                    OutputWrapper wrap = new OutputWrapper();
                    wrap.data = res.T_OUTPUT[i];
                    
                    if (wrap.data != null && String.isNotBlank(wrap.data.MATXT)) {
                        wrap.data.MATXT = wrap.data.MATXT.trim();
                        // MATXT(조치사항 상세입력 내용) 200자 넘는 경우 자르고 ... 추가 2025-05-22
                        if (wrap.data.MATXT.length() > 200) {
                            wrap.data.MATXT = wrap.data.MATXT.substring(0, 200) + '...';
                        }
                    }
                    wrap.isEven = (Math.mod(i, 2) == 1);
                    wrap.isLast = (i == res.T_OUTPUT.size() - 1) ? 'Last' : ''; 
                    wrapList.add(wrap);
                }
            }
        } catch (Exception e) {
            
        } 
    }

    /**
    * @description 페품 반납 리스트 조회 (IF-SERVICE-047) 
    **/
    @AuraEnabled
    public static IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Res getNonReturnedList(NonReturnedScrap search) {
        try {
            // 필드 매핑
           IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Req  req = new IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Req();
           User loginUser = [SELECT Id, Plant__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

           req.I_USERINFO.BNAME = loginUser.Id; 
           req.I_USERINFO.WERKS = String.isBlank(search.WERKS)? '184S' : search.WERKS;
           req.I_USERINFO.ARBPL = search.I_ARBPL;
           req.I_LANGU = 'KO'; // 별도의 설정없으면 KO 기본값
           req.I_DATUM_FROM = search.I_DATUM_FROM;
           req.I_DATUM_TO = search.I_DATUM_TO;
           req.I_ARBPL = search.I_ARBPL;
           req.I_RETURN_TYPE = search.I_RETURN_TYPE == 'All' ? '' : search.I_RETURN_TYPE;
           req.I_RETURN_YN = search.I_RETURN_YN;
           req.I_AUFNR = search.I_AUFNR;
           req.I_MATNR = search.I_MATNR;
           // 인터페이스 호출
           IF_ERP_Service_Scrap erpService= new IF_ERP_Service_Scrap();
           IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Res res = erpService.IF_SERVICE_047(req);     
           return res;
       } catch (Exception e) {
           System.debug(e.getMessage() + ' < == message');
           System.debug(e.getLineNumber() + ' < == getLineNumber');
           throw new AuraHandledException(e.getMessage());
       } 
    }
    
    /**
    * @description 폐품반납 목록 조회 (IF-SERVICE-047) Wrapper
    **/ 
    public class NonReturnedScrap {
        @AuraEnabled public String I_DATUM_TO {get;set;}  // 접수일 종료
        @AuraEnabled public String I_DATUM_FROM {get;set;} // 접수일 시작
        @AuraEnabled public String I_ARBPL {get;set;} // 딜러러
        @AuraEnabled public String I_RETURN_TYPE {get;set;} // 반납 구분 => 신품:1, 페품:2,소모성:3,망실:4,인수증:5,해외부품:6,미반납 대상:7
        @AuraEnabled public String I_RETURN_YN {get;set;} // 반납여부부
        @AuraEnabled public String I_LANGU {get;set;} // KO
        @AuraEnabled public String I_AUFNR {get;set;} // 오더번호
        @AuraEnabled public String I_MATNR {get;set;} // 품번
        @AuraEnabled public String WERKS {get;set;} // Plant
    }

    /**
    * @description 전표발행 (IF-SERVICE-048) Wrapper
    **/ 
    public class NonReturnedScrapPrint {
        @AuraEnabled public String MATNR {get;set;}  
        @AuraEnabled public String AUFNR {get;set;} 
    }

    /**
    * @description 전표발행 (IF-SERVICE-048) Wrapper
    **/ 
    public class T_OUTPUT {
        @AuraEnabled public String AUFNR { get; set; }
        @AuraEnabled public String ENAME { get; set; }
        @AuraEnabled public String KTEXT { get; set; }
        @AuraEnabled public String MAKTX { get; set; }
        @AuraEnabled public String MATNR { get; set; }
        @AuraEnabled public String MATXT { get; set; }
        @AuraEnabled public String MEINS { get; set; }
        @AuraEnabled public String MENGE { get; set; }
        @AuraEnabled public String MZEIT { get; set; }
        @AuraEnabled public String NAME1 { get; set; }
        @AuraEnabled public String NAME2 { get; set; }
        @AuraEnabled public String PRT_DATE { get; set; }
        @AuraEnabled public String PRT_TIME { get; set; }
        @AuraEnabled public String QMDAT { get; set; }
        @AuraEnabled public String QMNUM { get; set; }
        @AuraEnabled public String RETURN_DT { get; set; }
        @AuraEnabled public String RETURN_TEXT { get; set; }
        @AuraEnabled public String RETURN_TYPE { get; set; }
        @AuraEnabled public String SEQNO { get; set; }
        @AuraEnabled public String SERNR { get; set; }
        @AuraEnabled public String SUPPLY_TYPE { get; set; }
        @AuraEnabled public String TYPBZ { get; set; }
        @AuraEnabled public String WADAT_IST { get; set; }
    }

    /**
    * @description 청구부품 불출 현황 조회 (IF-SERVICE-035)
    **/
    @AuraEnabled
    public static IF_ERP_Service_PartStat_Classes.IF_SERVICE_035_Res getPartsIssuanceStatus(PartsIssuanceSearch search){
        try {
            System.debug(search + ' < ===search');

            IF_ERP_Service_PartStat_Classes.IF_SERVICE_035_Req req = new IF_ERP_Service_PartStat_Classes.IF_SERVICE_035_Req();

            if(String.isNotBlank(search.I_AUART)) req.I_AUART       = search.I_AUART;
            // if(String.isNotBlank(search.I_EQUNR)) req.I_EQUNR       = search.I_EQUNR; // I_EQUNR 값 추가하면 장비번호로 조회 오류 발생함
            if(String.isNotBlank(search.I_EQUNR)) req.I_TYPBZ       = search.I_EQUNR;
            if(String.isNotBlank(search.I_SERNR)) req.I_SERNR       = search.I_SERNR;
            if(String.isNotBlank(search.I_RPDAT_F)) req.I_RPDAT_F   = search.I_RPDAT_F.subString(0,10);
            if(String.isNotBlank(search.I_RPDAT_T)) req.I_RPDAT_T   = search.I_RPDAT_T.subString(0,10);
            if(String.isNotBlank(search.I_AUFNR_F)) req.I_AUFNR_F   = search.I_AUFNR_F;
            if(String.isNotBlank(search.I_AUFNR_T)) req.I_AUFNR_F   = search.I_AUFNR_T;
            if(String.isNotBlank(search.I_ARBPL_T)) req.I_ARBPL_T   = search.I_ARBPL_T;
            if(String.isNotBlank(search.I_ARBPL_F)) req.I_ARBPL_F   = search.I_ARBPL_F; 
            if(String.isNotBlank(search.I_VBELN_F)) req.I_VBELN_F   = search.I_VBELN_F;
            if(String.isNotBlank(search.I_VBELN_T)) req.I_VBELN_T   = search.I_VBELN_T;

            req.I_USERINFO.WERKS = String.isBlank(search.WERKS) ? '184S': search.WERKS; 
            req.I_USERINFO.ARBPL = search.I_ARBPL_F;
            
            IF_ERP_Service_PartStat erpIF = new IF_ERP_Service_PartStat();
            
            // 인터페이스 리턴정보
            IF_ERP_Service_PartStat_Classes.IF_SERVICE_035_Res res = erpIF.IF_SERVICE_035(req);

            return res;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' < ===e.getMessage()');
            System.debug(e.getLineNumber() + ' < ===e.getLineNumber()');
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 청구부품 불출 현황 조회 (IF-SERVICE-035) Wrapper
    **/ 
    public class PartsIssuanceSearch{
        @AuraEnabled public String I_AUART   {get;set;} // 	CS02 < = 고정 주문유형
        @AuraEnabled public String I_EQUNR   {get;set;} // 장비번호
        @AuraEnabled public String I_TYPBZ   {get;set;} // 기종 : ACE F30 
        @AuraEnabled public String I_SERNR   {get;set;} // 호기
        @AuraEnabled public String WERKS     {get;set;} // Plant
        @AuraEnabled public String I_RPDAT_F {get;set;} // 조회일자
        @AuraEnabled public String I_RPDAT_T {get;set;} // 조회 일자
        @AuraEnabled public String I_AUFNR_F {get;set;} // 서비스 오더
        @AuraEnabled public String I_AUFNR_T {get;set;} // 서비스 오더
        @AuraEnabled public String I_VBELN_F {get;set;} // 영업 오더

        @AuraEnabled public String I_VBELN_T {get;set;} // 영업오더
        @AuraEnabled public String I_ARBPL_F {get;set;} // 딜러(워크센터) 
        @AuraEnabled public String I_ARBPL_T {get;set;} // 딜러(워크센터) 
        @AuraEnabled public String I_EQFNR_F {get;set;} // ? Ref. No.
        @AuraEnabled public String I_EQFNR_T {get;set;} // ? Ref. No.
    }
}