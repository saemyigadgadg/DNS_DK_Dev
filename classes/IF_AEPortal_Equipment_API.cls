/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-01-16
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-18-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
@RestResource(urlMapping='/AEPortal/equipmentUpdate')
global with sharing class IF_AEPortal_Equipment_API {    
    global static InterfaceCommonLog InterfaceCommonLog = new InterfaceCommonLog();
    global static String  apexClassName = 'IF_AEPortal_Equipment_API';
    global static String  interfaceId = 'IF-CSPLUS-035';

    global IF_AEPortal_Equipment_API() {}
    global class ResponseDto{
        public String O_RESULT;
        public String O_MESSAGE;

        public ResponseDto(){}
    }

    global class RequestInfo{
        global String PJT_CODE;             // 프로젝트 코드
        global String MTRL_CODE_SN;         // 호기번호
        global String SHIPPING_DATE;        // 출하일
        global String CONTRACT_SCOPE;       // 계약범위
        global String CUSTOMER_CONTRACT;    // 고객사급품
        global String CONTRACT_UNIT_TYPE;   // 도급Unit
        global String CONTRACT_UNIT_DESC;   // 도급Unit정보
    }

    @HTTPPost
    global static ResponseDto postHttp(){
        RestRequest  restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        ResponseDto responseDto = new ResponseDto();
        System.debug(restReq.requestBody.toString());        
        try{
            InterfaceCommonLog.interfaceLog interfaceLog = new InterfaceCommonLog.interfaceLog(interfaceId, apexClassName);
            interfaceLog.requestTime = System.now();
            interfaceLog.requestBody = restReq.requestBody.toString();
            InterfaceCommonLog.insertLog(new List<InterfaceCommonLog.interfaceLog>{interfaceLog});

            List<RequestInfo> reqList = (List<RequestInfo>) JSON.deserialize(restReq.requestBody.toString(), List<RequestInfo>.class);
            List<IF_AEPortal__c> aeList = new List<IF_AEPortal__c>();
            List<AEProject__c> aepList = new List<AEProject__c>();

            Set<String> serialNumbers = new Set<String>();

            for(RequestInfo req : reqList){
                IF_AEPortal__c ae = new IF_AEPortal__c();
                ae.Interface_ID__c          = interfaceId;
                ae.PJT_CODE__c              = req.PJT_CODE;
                ae.MTRL_CODE_SN__c          = req.MTRL_CODE_SN;
                ae.SHIPPING_DATE__c         = req.SHIPPING_DATE;
                ae.CONTRACT_SCOPE__c        = req.CONTRACT_SCOPE;
                ae.CUSTOMER_CONTRACT__c	    = req.CUSTOMER_CONTRACT;
                ae.CONTRACT_UNIT_TYPE__c    = req.CONTRACT_UNIT_TYPE;
                ae.CONTRACT_UNIT_DESC__c    = req.CONTRACT_UNIT_DESC;
                aeList.add(ae);

                serialNumbers.add(req.MTRL_CODE_SN);
            }

            List<Asset> assetList = [SELECT Id, SerialNumber FROM Asset WHERE SerialNumber IN :serialNumbers];

            Map<String, String> assetMap = new Map<String, String>();
            for (Asset asset : assetList) {
                assetMap.put(asset.SerialNumber, asset.Id);
            }

            for(RequestInfo req : reqList){
                AEProject__c aep = new AEProject__c();
                aep.MTRLCode__c         = assetMap.get(req.MTRL_CODE_SN);
                aep.Name                = req.PJT_CODE;
                aep.SHIPPING__c         = req.SHIPPING_DATE;
                aep.ContractScope__c    = req.CONTRACT_SCOPE;
                aep.ContractItem__c     = req.CUSTOMER_CONTRACT;
                aep.ContractUnitType__c = req.CONTRACT_UNIT_TYPE;
                aep.ContractUnit__c     = req.CONTRACT_UNIT_DESC;
                aep.UpdateDate__c       = System.today();
                aepList.add(aep);
            }

            if(aeList.size() > 0) insert aeList;
            if(aepList.size() > 0) insert aepList;

            responseDto.O_RESULT = 'S';
            responseDto.O_MESSAGE = 'Success';            
        }
        catch(Exception e){
            responseDto.O_RESULT = 'E';
            responseDto.O_MESSAGE = e.getMessage();
        }     

        return responseDto;
    }
}