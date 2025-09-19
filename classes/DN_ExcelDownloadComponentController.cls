/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-09-01
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-11-05   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_ExcelDownloadComponentController {
    public DN_ExcelDownloadComponentController() {}

    // Init에 필요한 정보를 담아서 Component에 전달하는 메서드
    @AuraEnabled
    public static Map<String, Object> getInit(String objectType, String filterId) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            
            result.put('getData',  getData(objectType, filterId));

            return result;

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // 엑셀 생성을 위한 리스트뷰의 정보를 쿼리해오는 메서드
    private static Map<String, Object> getData(String objectType, String filterId) {

        String jsonString = getListColumns(objectType, filterId);

        List<String> columnsApiNameList = new List<String>();
        List<String> columnsLabelList = new List<String>();

        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        String query = (String) jsonMap.get('query');
        List<Object> columnsObjList = (List<Object>) jsonMap.get('columns');

        for (Object columnsObj : columnsObjList) {
            Map<String, Object> objMap = (Map<String, Object>) columnsObj;
            String apiName = String.valueOf(objMap.get('fieldNameOrPath'));
            String queryName = String.valueOf(objMap.get('selectListItem'));
            String label = String.valueOf(objMap.get('label'));
            if (apiName == 'Id') break;
            columnsApiNameList.add(apiName);
            columnsLabelList.add(label);
        }
        query += ' LIMIT 50000';
        List<SObject> queryList = Database.query(query);

        // System.debug('columnsLabelList ::: ' + columnsLabelList);
        // System.debug('columnsApiNameList ::: ' + columnsApiNameList);
        // System.debug('queryList ::: ' + queryList);


        Map<String, Object> resultMap = new Map<String, Object>();

        resultMap.put('columnsLabelList', columnsLabelList);
        resultMap.put('columnsApiNameList', columnsApiNameList);
        resultMap.put('resultList', queryList);

        return resultMap;

    }

    // 엑셀 생성을 위한 리스트뷰의 정보를 메타서비스 API호출하는 메서드
    private static String getListColumns(String objName, String filterId) {
        HttpRequest req = new HttpRequest();
    
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm()
        + '/services/data/v53.0/sobjects/'
        + objName + '/listviews/'
        + filterId + '/describe');

        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        if (!Test.isRunningTest()) {
            res = http.send(req);
        } else {
            String bodyString = '{"columns":[{"ascendingLabel":"Z-A","descendingLabel":"A-Z","fieldNameOrPath":"CaseNumber","hidden":false,"label":"Ticket 번호","searchable":true,"selectListItem":"CaseNumber","sortDirection":"descending","sortIndex":0,"sortable":true,"type":"string"},{"ascendingLabel":"Z-A","descendingLabel":"A-Z","fieldNameOrPath":"FM_TicketName__c","hidden":false,"label":"Ticket name","searchable":false,"selectListItem":"FM_TicketName__c","sortDirection":null,"sortIndex":null,"sortable":true,"type":"string"},{"ascendingLabel":"오름차순","descendingLabel":"내림차순","fieldNameOrPath":"Requester__r.Name","hidden":false,"label":"요청자","searchable":false,"selectListItem":"Requester__r.Name","sortDirection":null,"sortIndex":null,"sortable":true,"type":"reference"},{"ascendingLabel":"낮음-높음","descendingLabel":"높음-낮음","fieldNameOrPath":"Status","hidden":false,"label":"상태","searchable":true,"selectListItem":"toLabel(Status)","sortDirection":null,"sortIndex":null,"sortable":true,"type":"picklist"},{"ascendingLabel":"최신-이전","descendingLabel":"이전-최신","fieldNameOrPath":"ApplicationDateTime__c","hidden":false,"label":"접수일시","searchable":false,"selectListItem":"ApplicationDateTime__c","sortDirection":null,"sortIndex":null,"sortable":true,"type":"datetime"},{"ascendingLabel":"Z-A","descendingLabel":"A-Z","fieldNameOrPath":"Owner.NameOrAlias","hidden":false,"label":"Ticket 소유자 별칭","searchable":false,"selectListItem":"Owner.NameOrAlias","sortDirection":null,"sortIndex":null,"sortable":true,"type":"string"},{"ascendingLabel":"낮음-높음","descendingLabel":"높음-낮음","fieldNameOrPath":"TicketType__c","hidden":false,"label":"Ticket유형(대)","searchable":true,"selectListItem":"toLabel(TicketType__c)","sortDirection":null,"sortIndex":null,"sortable":true,"type":"picklist"},{"ascendingLabel":"낮음-높음","descendingLabel":"높음-낮음","fieldNameOrPath":"InternalTicketType__c","hidden":false,"label":"Ticket 유형(중)","searchable":true,"selectListItem":"toLabel(InternalTicketType__c)","sortDirection":null,"sortIndex":null,"sortable":true,"type":"picklist"},{"ascendingLabel":null,"descendingLabel":null,"fieldNameOrPath":"Id","hidden":true,"label":"Ticket id","searchable":false,"selectListItem":"Id","sortDirection":null,"sortIndex":null,"sortable":false,"type":"id"},{"ascendingLabel":null,"descendingLabel":null,"fieldNameOrPath":"RecordTypeId","hidden":true,"label":"Ticket 레코드 유형","searchable":false,"selectListItem":"RecordTypeId","sortDirection":null,"sortIndex":null,"sortable":false,"type":"reference"},{"ascendingLabel":null,"descendingLabel":null,"fieldNameOrPath":"CurrencyIsoCode","hidden":true,"label":"Ticket 통화","searchable":false,"selectListItem":"CurrencyIsoCode","sortDirection":null,"sortIndex":null,"sortable":false,"type":"picklist"},{"ascendingLabel":null,"descendingLabel":null,"fieldNameOrPath":"CreatedDate","hidden":true,"label":"작성 일자","searchable":false,"selectListItem":"CreatedDate","sortDirection":null,"sortIndex":null,"sortable":false,"type":"datetime"},{"ascendingLabel":null,"descendingLabel":null,"fieldNameOrPath":"LastModifiedDate","hidden":true,"label":"최종 수정 일자","searchable":false,"selectListItem":"LastModifiedDate","sortDirection":null,"sortIndex":null,"sortable":false,"type":"datetime"},{"ascendingLabel":null,"descendingLabel":null,"fieldNameOrPath":"SystemModstamp","hidden":true,"label":"시스템 모드 스탬프","searchable":false,"selectListItem":"SystemModstamp","sortDirection":null,"sortIndex":null,"sortable":false,"type":"datetime"},{"ascendingLabel":null,"descendingLabel":null,"fieldNameOrPath":"Requester__c","hidden":true,"label":"요청자","searchable":false,"selectListItem":"Requester__c","sortDirection":null,"sortIndex":null,"sortable":false,"type":"reference"},{"ascendingLabel":null,"descendingLabel":null,"fieldNameOrPath":"Owner.Id","hidden":true,"label":"소유자 ID","searchable":false,"selectListItem":"Owner.Id","sortDirection":null,"sortIndex":null,"sortable":false,"type":"id"},{"ascendingLabel":null,"descendingLabel":null,"fieldNameOrPath":"OwnerId","hidden":true,"label":"Ticket 소유자","searchable":false,"selectListItem":"OwnerId","sortDirection":null,"sortIndex":null,"sortable":false,"type":"reference"}],"id":"00BGB00000KBsje","orderBy":[{"fieldNameOrPath":"CaseNumber","nullsPosition":"last","sortDirection":"descending"},{"fieldNameOrPath":"Id","nullsPosition":"last","sortDirection":"descending"}],"query":"SELECT CaseNumber, FM_TicketName__c, Requester__r.Name, toLabel(Status), ApplicationDateTime__c, Owner.NameOrAlias, toLabel(TicketType__c), toLabel(InternalTicketType__c), Id, RecordTypeId, CurrencyIsoCode, CreatedDate, LastModifiedDate, SystemModstamp, Requester__c, Owner.Id, OwnerId FROM Case WHERE CreatedDate = LAST_N_DAYS:30 AND IsClosed = false AND (RecordTypeId = \'012F7000000KVpQ\' OR RecordTypeId = \'012F7000000KVpL\') ORDER BY CaseNumber DESC NULLS LAST, Id DESC NULLS LAST","relatedEntityId":null,"scope":"everything","scopeEntityId":null,"sobjectType":"Case","whereCondition":{"conditions":[{"field":"CreatedDate","operator":"equals","values":["LAST_N_DAYS:30"]},{"field":"IsClosed","operator":"equals","values":["false"]},{"conditions":[{"field":"RecordTypeId","operator":"equals","values":["\'012F7000000KVpQ\'"]},{"field":"RecordTypeId","operator":"equals","values":["\'012F7000000KVpL\'"]}],"conjunction":"or"}],"conjunction":"and"}}';

            res.setBody(bodyString);
            res.setStatusCode(200);
        }

        System.debug('body ::: ' + res.getBody());
        
        return res.getBody();
    }
}