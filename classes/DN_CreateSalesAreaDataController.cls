/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 09-01-2025
 * @last modified by  : Hanyeong Choi
**/
public with sharing class DN_CreateSalesAreaDataController {
    private static final String SALES_ORG_1800  = '1800';
    private static final String SALES_ORG_4140  = '4140';
    private static final String SALES_ORG_1846  = '1846';
    private static final String SALES_ORG_4146  = '4146';
    private static final String DIST_CHANNEL    = '10';
    private static final String DIVISION        = '40';
    private static final String CUST_PRIC_PROC  = '1';
    private static final String PRICE_LIST      = '10';
    private static final String SALES_OFFICE_414A   = '414A';
    private static final String SUCCESS_TYPE    = 'S';
    private static final String SUCCESS_FLAG    = 'success';
    private static final String FAIL_FLAG       = 'fail';
    private static final String EMPTY_FLAG      = 'empty';
    private static final String OFFICE_FLAG     = 'office';
    private static final String ERROR_FLAG      = 'error';

    @AuraEnabled
    // 주어진 Account ID에 대해 SalesOrganization이 1800 또는 4140인 SalesAreaData__c 레코드가 존재하는지 확인
    public static Boolean initSalesAreaData(String recordId) {
        try {
            List<SalesAreaData__c> salesAreaRecords = [
                SELECT Id 
                FROM SalesAreaData__c 
                WHERE Account__c = :recordId 
                AND SalesOrganization__c IN (:SALES_ORG_1800, :SALES_ORG_4140)
            ];
            return !salesAreaRecords.isEmpty();
        } catch (Exception e) {
            logError(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    // SalesAreaData 레코드를 ERP 시스템과 연동하여 새로 생성하는 메인 메서드
    public static Map<String, Object> insertSalesAreaData(String recordId) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            Account account = queryAccount(recordId);
            List<SalesAreaData__c> salesAreaRecords = querySalesAreaData(recordId);
            
            // 관련 SalesAreaData가 없을 경우 빈 상태로 응답
            if (salesAreaRecords.isEmpty()) {
                return createResponse(EMPTY_FLAG, 'Sales Area Data is Empty!');
            }

            SalesAreaData__c sourceRecord = salesAreaRecords[0];

            // Sales Office가 비어 있으면 실패 응답 반환
            if (sourceRecord.SalesOffice__c == null) {
                return createResponse(OFFICE_FLAG, 'Fill in the Sales Office field in Sales Area Data.');
            }

            // ERP 시스템에 호출 후 결과 처리
            IF_ERP_Account_Classes.IF_ACCOUNT_018_Res erpResult = callOutAccount018(account, sourceRecord);
            return processErpResult(erpResult, sourceRecord);
        } catch (Exception e) {
            logError(e);
            return createResponse(ERROR_FLAG, e.getLineNumber() + ' / ' + e.getMessage());
        }
    }

    // 주어진 Account ID에 해당하는 Account 레코드를 쿼리
    private static Account queryAccount(String recordId) {
        return [
            SELECT Id, CustomerCode__c, CurrencyIsoCode 
            FROM Account 
            WHERE Id = :recordId 
            LIMIT 1
        ];
    }

    // 주어진 Account ID에 대해 SalesOrganization이 1846 또는 4146인 SalesAreaData__c 레코드를 쿼리
    private static List<SalesAreaData__c> querySalesAreaData(String recordId) {
        return [
            SELECT  Id
                    , SalesOrganization__c
                    , DistributionChannel__c
                    , Division__c
                    , SalesDistrict__c
                    , SalesOffice__c
                    , CustomerGroup__c
                    , Incoterms__c
                    , AcctAssgmtGroup__c
                    , ShippingConditions__c
                    , TaxClassification__c
                    , CustomerGrp5__c
                    , DeliveringPlant__c
                    , TermsOfPayment__c
                    , PriceList__c
                    , Country__c
                    , Currency__c
                    , SoldToParty__c
                    , BillToParty__c
                    , ShipToParty__c
                    , Payer__c
                    , Account__c
            FROM SalesAreaData__c
            WHERE Account__c = :recordId
            AND SalesOrganization__c IN (:SALES_ORG_1846, :SALES_ORG_4146)
            LIMIT 1
        ];
    }

    // ERP 응답을 바탕으로 성공 여부 판단 후 새로운 SalesAreaData__c 레코드를 생성하거나 실패 메시지 반환
    private static Map<String, Object> processErpResult(IF_ERP_Account_Classes.IF_ACCOUNT_018_Res erpResult, SalesAreaData__c sourceRecord) {
        Integer returnIndex = (erpResult.OT_RETURN.size() == 1) ? 0 : 1;
        if (erpResult.OT_RETURN[returnIndex].TYPE == SUCCESS_TYPE) {
            SalesAreaData__c newRecord = createNewSalesAreaRecord(sourceRecord);
            insert newRecord;
            return createResponse(SUCCESS_FLAG, 'Create Sales Area Data Success!');
        }
        String errorMessage = erpResult.OT_RETURN[returnIndex].MESSAGE != null 
            ? 'ERP : ' + erpResult.OT_RETURN[returnIndex].MESSAGE 
            : 'Create Sales Area Data Fail';
        return createResponse(FAIL_FLAG, errorMessage);
    }

    // 기존 SalesAreaData__c 레코드를 클론하고 일부 필드를 수정하여 새 레코드 생성
    private static SalesAreaData__c createNewSalesAreaRecord(SalesAreaData__c sourceRecord) {
        SalesAreaData__c newRecord = sourceRecord.clone(false, false, false);
        newRecord.Id = null;
        newRecord.SalesOrganization__c = determineSalesOrg(sourceRecord.SalesOrganization__c);
        newRecord.DistributionChannel__c = DIST_CHANNEL;
        newRecord.Division__c = DIVISION;
        newRecord.CustPricProc__c = CUST_PRIC_PROC;
        newRecord.PriceList__c = PRICE_LIST;
        return newRecord;
    }

    // 현재 SalesOrganization 값을 기반으로 새로운 SalesOrganization 값 결정
    private static String determineSalesOrg(String currentSalesOrg) {
        return (currentSalesOrg != SALES_ORG_4146 && currentSalesOrg != SALES_ORG_4140) 
            ? SALES_ORG_1800 
            : SALES_ORG_4140;
    }

    // ERP 시스템에 Account 정보를 전달하고 응답을 받는 외부 호출 처리
    private static IF_ERP_Account_Classes.IF_ACCOUNT_018_Res callOutAccount018(Account account, SalesAreaData__c record) {
        IF_ERP_Account_Classes.IF_ACCOUNT_018_Req params = new IF_ERP_Account_Classes.IF_ACCOUNT_018_Req();
        params.I_KUNNR = account.CustomerCode__c;
        params.I_PLTYP = PRICE_LIST;
        params.I_KALKS = CUST_PRIC_PROC;
        params.I_VKORG = determineSalesOrg(record.SalesOrganization__c);
        params.I_VTWEG = DIST_CHANNEL;
        params.I_SPART = DIVISION;
        params.I_BZIRK = record.SalesDistrict__c;
        params.I_VKBUR = (record.SalesOrganization__c != SALES_ORG_4146 && record.SalesOrganization__c != SALES_ORG_4140) 
            ? record.SalesOffice__c 
            : SALES_OFFICE_414A;
        params.I_KDGRP = record.CustomerGroup__c;
        params.I_WAERS = account.CurrencyIsoCode;
        params.I_INCO1 = record.Incoterms__c;
        params.I_ZTERM = record.TermsOfPayment__c;
        params.I_KTGRD = record.AcctAssgmtGroup__c;
        params.I_VSBED = record.ShippingConditions__c;
        params.I_KVGR5 = record.CustomerGrp5__c;

        IF_ERP_Account method = new IF_ERP_Account();
        return method.IF_ACCOUNT_018(params);
    }

    // 응답 결과를 Map 형태로 생성하여 Aura 컴포넌트에 반환
    private static Map<String, Object> createResponse(String flag, String message) {
        return new Map<String, Object>{
            'flag' => flag,
            'message' => message
        };
    }

    // 에러 메시지 및 발생 라인 로그 출력
    private static void logError(Exception e) {
        System.debug('Error: ' + e.getMessage());
        System.debug('Line Number: ' + e.getLineNumber());
    }
}