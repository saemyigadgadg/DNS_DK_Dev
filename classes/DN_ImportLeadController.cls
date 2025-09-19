/**
 * @author            : Yu-Hyun Park
 * @description       : Lead 엑셀 임포트 컨트롤러
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-11-08   yuhyun.park@sbtglobal.com   Initial Version
**/
public with sharing class DN_ImportLeadController {

    /**
     * @Description
     * 	- 로그인 유저의 소속 확인 DNS - DNSA 
     * @author Yuhyun Park | 2025-01-08
     * @Parameter
    **/     
    @AuraEnabled
    public static String getSalesOrg(){
        try {

            User currentUser = [SELECT Id, SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            System.debug('currentUser Info :: ' + currentUser);

            return currentUser.SalesOrganization__c;
            
        } catch (Exception e) {
            System.debug('Error in getUserInfo: ' + e.getMessage());
            System.debug('Line Number: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }


    // Lead 메타데이터 조회
    @AuraEnabled
    public static List<String> getImportLeadMetadata(String templateType, Boolean isDNSA) {

        try {

            System.debug('templateType :: ' + templateType);
            System.debug('getImportLeadMetadata 호출');
    
            // 메타데이터 유형 설정
            String metaData;
            if (isDNSA) {
                metaData = 'ImportLead_DNSA__mdt';
            } else {
                metaData = 'ImportLead__mdt';
            }
    
            // 쿼리 작성
            String query = 'SELECT Type__c, DeveloperName, MappingFieldAPI__c, ColumnName__c, Order__c FROM ' + metaData;
            if (templateType != null && templateType != '') {
                query += ' WHERE Type__c = \'' + String.escapeSingleQuotes(templateType) + '\'';
            }
            query += ' ORDER BY Order__c ASC';
    
            System.debug('query: ' + query);
    
            // 동적 쿼리 실행
            List<SObject> allMeta = Database.query(query);
            System.debug('allMeta: ' + allMeta);
    
            // 결과 처리
            List<String> expectedHeaders = new List<String>();
            for (SObject record : allMeta) {
                // SObject에서 ColumnName__c 필드를 가져옴
                String columnName = (String)record.get('ColumnName__c');
                System.debug('meta: ' + columnName);
                expectedHeaders.add(columnName);
            }
    
            System.debug('expectedHeaders: ' + expectedHeaders);
            return expectedHeaders;
            
        } catch (Exception e) {
            System.debug('Error in getImportLeadMetadata: ' + e.getMessage());
            System.debug('Line Number: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }

    }



    // 레코드 업서트
    @AuraEnabled
    public static String upsertRecords(String records, String templateType, String selectedType, Boolean isDNSA) {

        try {

            System.debug('upsertRecords Controller 진입 ::  ' );
            System.debug('records :: ' + records);
            System.debug('templateType :: ' + templateType);
            // JSON 문자열을 Map 형태로 역직렬화
            List<Object> recordObjects = (List<Object>) JSON.deserializeUntyped(records);
            List<Map<String, Object>> recordMaps = new List<Map<String, Object>>();
    
            System.debug('recordObjects :: ' + recordObjects);
    
            for (Object obj : recordObjects) {
                recordMaps.add((Map<String, Object>) obj);
            }
    
            System.debug('recordMaps :: ' + recordMaps);
    
            List<Lead> finalUpsertList = new List<Lead>();
            List<LeadEvent__c> insertToLeadEvent = new List<LeadEvent__c>();
            List<Task> insertToTask = new List<Task>();  // 업데이트 레코드 : Task로 생성
            Set<String> leadKeySet = new Set<String>();  // 기존 레코드 쿼리를 위한 Set
            Set<String> eventCodeSet = new Set<String>();
            Map<String, Integer> eventCodeRowMap = new Map<String, Integer>();
            Map<String, Map<String, Object>> leadDataMap = new Map<String, Map<String, Object>>();  // leadKey에 대한 필드 값을 저장할 Map
            Set<String> existingLeadEventSet = new Set<String>(); // Lead와 EventManagement 조합으로 이미 생성된 LeadEvent 레코드를 확인
    
            Integer rowNumber = 3; // 행 번호 추적
    
            for (Map<String, Object> recordMap : recordMaps) {
                rowNumber++; // 현재 행 번호 증가
                System.debug('rowNumber :: ' + rowNumber);
    
                // 회사 + 이름 + 휴대폰 (Commpany + Name + Phone)
                String leadKey = '';
                String eventCode = '';
                if(templateType == 'Catalog Downloader'){
                    leadKey = String.valueOf(recordMap.get('Column_3')) + String.valueOf(recordMap.get('Column_2')) + String.valueOf(recordMap.get('Column_5'));
                }else if(templateType == 'Event Visitor'){
                    leadKey = String.valueOf(recordMap.get('Column_3')) + String.valueOf(recordMap.get('Column_4')) + String.valueOf(recordMap.get('Column_7'));
                    eventCode = String.valueOf(recordMap.get('Column_0'));
                }
                System.debug('leadKey ::' + leadKey);
                System.debug('eventCode ::' + eventCode);
    
                leadKeySet.add(leadKey);
                System.debug('leadKeySet ::' + leadKeySet);
    
    
                 // eventCode가 값이 있을 때만 Set에 추가
                if (eventCode != null && eventCode.trim() != '') {
                    eventCodeSet.add(eventCode);
                    eventCodeRowMap.put(eventCode, rowNumber); // 이벤트 코드와 해당 행 번호 매핑
                }
               
            }
    
            Map<String, Event_Management__c> emMap = new Map<String, Event_Management__c>();
            List<Event_Management__c> emList = [SELECT Id, Name FROM Event_Management__c WHERE Name IN :eventCodeSet];
    
            for(Event_Management__c em : emList){
                emMap.put(em.Name, em );
            }
    
            for(String eventCode : eventCodeSet){
                if(!emMap.containsKey(eventCode)){
                    String recordDetails = 'File contains undefined [Event Code] in Row ' + eventCodeRowMap.get(eventCode);
                    return recordDetails;
                }
            }
    
             // 기존 레코드 쿼리
             Map<String, Lead> existingRecordsMap = new Map<String, Lead>();
             List<Lead> existingRecords = new List<Lead>();
    
            // 타입별 분기처리
            if(templateType == 'Catalog Downloader'){
                existingRecords = [
                    SELECT  Id, 
                            FM_LeadKey__c,
                            LeadSource__c,
                            FileName__c,
                            Name,
                            Company,
                            Address1__c,
                            MobilePhone,
                            Email,
                            IsDNSolutionsAvailable__c,
                            IsMarketingConsentPhone__c,
                            IsMarketingConsentSMS__c,
                            IsMarketingConsentEmail__c,
                            IsMarketingConsentPost__c,
                            MarketingConsentDate__c,
                            LeadSourceCatalog__c,
                            DownloadDate__c
                    FROM    Lead
                    WHERE   FM_LeadKey__c IN: leadKeySet
                ];
    
            }else if(templateType == 'Event Visitor'){
                existingRecords = [
                    SELECT  Id,
                            FM_LeadKey__c,
                            LeadSource__c,
                            EventName__c,
                            VisitTime__c,
                            Company,
                            Name,
                            Title,
                            Phone,
                            MobilePhone,
                            Email,
                            Industry_EventVisitor__c,
                            InterestedItem__c,
                            Country__c,
                            Region__c,
                            PostalCode,
                            Address1__c,
                            Address2__c,
                            IsDNSolutionsAvailable__c,
                            Rating,
                            RequestQuote__c,
                            RequestQuoteDate__c,
                            Description,
                            ExcludeLead__c
                    FROM    Lead
                    WHERE   FM_LeadKey__c IN: leadKeySet 
                ];
                
            }
    
            System.debug('existingRecords 전체 조회 !! :: ' + existingRecords);
    
    
            // Update 대상
            if(!existingRecords.isEmpty()){
                for (Lead record : existingRecords) {
                    existingRecordsMap.put(record.FM_LeadKey__c, record);
    
                    System.debug('existingRecords :: ' + record);
                }
                
            }
    
            // 다시 행 번호 초기화(for requiredFields)
            rowNumber = 3; 
    
            // 레코드를 업데이트 또는 생성
            Map<String, Lead> upsertMap = new Map<String, Lead>();
            for (Map<String, Object> recordMap : recordMaps) {
                try{
                    rowNumber++;
    
                    // 필수 필드 설정
                    List<String> requiredFields;
                    List<String> leadKeyFields;
        
                    if (templateType == 'Catalog Downloader') {
                        requiredFields = new List<String>{'Column_3', 'Column_2', 'Column_5'};
                        leadKeyFields = new List<String>{'Column_3', 'Column_2', 'Column_5'};
                    } else if (templateType == 'Event Visitor') {
                        requiredFields = new List<String>{'Column_0', 'Column_3', 'Column_4', 'Column_7'};
                        leadKeyFields = new List<String>{'Column_3', 'Column_4', 'Column_7'};
                    }
        
                    // 필수 필드 검사
                    for (String field : requiredFields) {
                        Object fieldValue = recordMap.get(field);
        
                        // null 또는 빈 값 체크
                        if (fieldValue == null || String.valueOf(fieldValue).trim() == '') {
    
                            String recordDetails = 'Required value is null or empty in Row ' + rowNumber;
                            return recordDetails;
    
    
                        }
                    }
        
                    // leadKey 생성 (필요한 필드만 추가)
                    String leadKey = '';
                    for (String field : leadKeyFields) {
                        leadKey += String.valueOf(recordMap.get(field));
                    }
                    String eventCode = '';
                    Lead recordToUpsert;
    
                    if(existingRecordsMap.containsKey(leadKey)){
                        
                        System.debug('<< update >>');
    
                        // 기존 레코드 업데이트 로직
                        Lead existingRecord = existingRecordsMap.get(leadKey);
    
                        if(templateType == 'Catalog Downloader'){
                            existingRecord.LeadSource__c                    = selectedType;
                            existingRecord.FileName__c                      = String.valueOf(recordMap.values()[1]);
                            existingRecord.LastName                         = String.valueOf(recordMap.values()[2]);
                            existingRecord.Company                          = String.valueOf(recordMap.values()[3]);
                            existingRecord.Address1__c                      = String.valueOf(recordMap.values()[4]);
                            existingRecord.MobilePhone                      = String.valueOf(recordMap.values()[5]);
                            existingRecord.Email                            = String.valueOf(recordMap.values()[6]);
                            existingRecord.IsDNSolutionsAvailable__c        = (recordMap.values()[7] == 'Y');
                            existingRecord.IsMarketingConsentPhone__c       = (recordMap.values()[8] == '동의' || recordMap.values()[8] == 'Y');
                            existingRecord.IsMarketingConsentSMS__c         = (recordMap.values()[9] == '동의' || recordMap.values()[9] == 'Y');
                            existingRecord.IsMarketingConsentEmail__c       = (recordMap.values()[10] == '동의' || recordMap.values()[10] == 'Y');
                            existingRecord.IsMarketingConsentPost__c        = (recordMap.values()[11] == '동의' || recordMap.values()[11] == 'Y');
                            existingRecord.MarketingConsentDate__c          = (String.valueOf(recordMap.values()[12]) != null && String.valueOf(recordMap.values()[12]).trim() != '') ? Date.valueOf(String.valueOf(recordMap.values()[12])): null;
                            existingRecord.LeadSourceCatalog__c             = String.valueOf(recordMap.values()[13]);
                            existingRecord.DownloadDate__c                  = (String.valueOf(recordMap.values()[14]) != null && String.valueOf(recordMap.values()[14]).trim() != '') ? Date.valueOf(String.valueOf(recordMap.values()[14])): null;
        
                        }else if(templateType == 'Event Visitor'){
                            existingRecord.LeadSource__c                = selectedType;
                            eventCode                                   = String.valueOf(recordMap.values()[0]);
                            existingRecord.EventName__c                 = String.valueOf(recordMap.values()[1]);
                            existingRecord.VisitTime__c                 = (String.valueOf(recordMap.values()[2]) != null && String.valueOf(recordMap.values()[2]).trim() != '') ? DateTime.valueOf(String.valueOf(recordMap.values()[2])): null;
                            existingRecord.Company                      = String.valueOf(recordMap.values()[3]);
                            existingRecord.LastName                     = String.valueOf(recordMap.values()[4]);
                            existingRecord.Title                        = String.valueOf(recordMap.values()[5]);
                            existingRecord.Phone                        = String.valueOf(recordMap.values()[6]);
                            existingRecord.MobilePhone                  = String.valueOf(recordMap.values()[7]);
                            existingRecord.Email                        = String.valueOf(recordMap.values()[8]);
                            existingRecord.Industry_EventVisitor__c     = String.valueOf(recordMap.values()[9]); // Industry -> Industry_EventVisitor__c 변경
                            existingRecord.InterestedItem__c            = String.valueOf(recordMap.values()[10]);
                            existingRecord.Country__c                   = String.valueOf(recordMap.values()[11]);
    
                            if(isDNSA){
                                existingRecord.PostalCode                   = String.valueOf(recordMap.values()[12]);
                                existingRecord.Address1__c                  = String.valueOf(recordMap.values()[13]);
                                existingRecord.Address2__c                  = String.valueOf(recordMap.values()[14]);
                                existingRecord.IsDNSolutionsAvailable__c    = (recordMap.values()[15] == 'Y');
                                existingRecord.Rating                       = String.valueOf(recordMap.values()[16]);
                                existingRecord.RequestQuote__c              = (recordMap.values()[17] == 'Y');
                                existingRecord.RequestQuoteDate__c          = (String.valueOf(recordMap.values()[18]) != null && String.valueOf(recordMap.values()[18]).trim() != '') ? Date.valueOf(String.valueOf(recordMap.values()[18])): null;
                                existingRecord.Description                  = String.valueOf(recordMap.values()[19]);
                                existingRecord.ExcludeLead__c               = (recordMap.values()[20] == 'Y');
    
                            } else{
                                existingRecord.Region__c                    = String.valueOf(recordMap.values()[12]);
                                existingRecord.PostalCode                   = String.valueOf(recordMap.values()[13]);
                                existingRecord.Address1__c                  = String.valueOf(recordMap.values()[14]);
                                existingRecord.Address2__c                  = String.valueOf(recordMap.values()[15]);
                                existingRecord.IsDNSolutionsAvailable__c    = (recordMap.values()[16] == 'Y');
                                existingRecord.Rating                       = String.valueOf(recordMap.values()[17]);
                                existingRecord.RequestQuote__c              = (recordMap.values()[18] == 'Y');
                                existingRecord.RequestQuoteDate__c          = (String.valueOf(recordMap.values()[19]) != null && String.valueOf(recordMap.values()[19]).trim() != '') ? Date.valueOf(String.valueOf(recordMap.values()[19])): null;
                                existingRecord.Description                  = String.valueOf(recordMap.values()[20]);
                                existingRecord.ExcludeLead__c               = (recordMap.values()[21] == 'Y');
                            }
    
                             // leadKey로 필드 값들을 저장할 서브 Map 생성
                            Map<String, Object> fieldValues = new Map<String, Object>();
                            
                            if(eventCode != null){
                                fieldValues.put('eventCode', eventCode);
                            }
                            fieldValues.put('subject', existingRecord.EventName__c + (isDNSA ? ' Memo' : ' 메모'));
                            fieldValues.put('activityDate', existingRecord.VisitTime__c.date());
                            fieldValues.put('description', existingRecord.Description );
    
                            // leadDataMap에 leadKey와 fieldValues 추가
                            leadDataMap.put(leadKey, fieldValues);
    
                        }
        
                        finalUpsertList.add(existingRecord);
        
                    }else {
        
                        System.debug('<< insert >>');
                        // 새로운 레코드 생성
                        Lead newRecord = new Lead();
        
                        if(templateType == 'Catalog Downloader'){
                            newRecord.LeadSource__c                    = selectedType;
                            newRecord.FileName__c                      = String.valueOf(recordMap.values()[1]);
                            newRecord.LastName                         = String.valueOf(recordMap.values()[2]);
                            newRecord.Company                          = String.valueOf(recordMap.values()[3]);
                            newRecord.Address1__c                      = String.valueOf(recordMap.values()[4]);
                            newRecord.MobilePhone                      = String.valueOf(recordMap.values()[5]);
                            newRecord.Email                            = String.valueOf(recordMap.values()[6]);
                            newRecord.IsDNSolutionsAvailable__c        = (recordMap.values()[7] == 'Y');
                            newRecord.IsMarketingConsentPhone__c       = (recordMap.values()[8] == '동의' || recordMap.values()[8] == 'Y');
                            newRecord.IsMarketingConsentSMS__c         = (recordMap.values()[9] == '동의' || recordMap.values()[9] == 'Y');
                            newRecord.IsMarketingConsentEmail__c       = (recordMap.values()[10] == '동의' || recordMap.values()[10] == 'Y');
                            newRecord.IsMarketingConsentPost__c        = (recordMap.values()[11] == '동의' || recordMap.values()[11] == 'Y');
                            newRecord.MarketingConsentDate__c          = (String.valueOf(recordMap.values()[12]) != null && String.valueOf(recordMap.values()[12]).trim() != '') ? Date.valueOf(String.valueOf(recordMap.values()[12])): null;
                            newRecord.LeadSourceCatalog__c             = String.valueOf(recordMap.values()[13]);
                            newRecord.DownloadDate__c                  = (String.valueOf(recordMap.values()[14]) != null && String.valueOf(recordMap.values()[14]).trim() != '') ? Date.valueOf(String.valueOf(recordMap.values()[14])): null;
    
        
                        }else if(templateType == 'Event Visitor'){
                            newRecord.LeadSource__c                = selectedType;
                            eventCode                              = String.valueOf(recordMap.values()[0]);
                            newRecord.EventName__c                 = String.valueOf(recordMap.values()[1]);
                            newRecord.VisitTime__c                 = (String.valueOf(recordMap.values()[2]) != null && String.valueOf(recordMap.values()[2]).trim() != '') ? DateTime.valueOf(String.valueOf(recordMap.values()[2])): null;
                            newRecord.Company                      = String.valueOf(recordMap.values()[3]);
                            newRecord.LastName                     = String.valueOf(recordMap.values()[4]);
                            newRecord.Title                        = String.valueOf(recordMap.values()[5]);
                            newRecord.Phone                        = String.valueOf(recordMap.values()[6]);
                            newRecord.MobilePhone                  = String.valueOf(recordMap.values()[7]);
                            newRecord.Email                        = String.valueOf(recordMap.values()[8]);
                            newRecord.Industry_EventVisitor__c     = String.valueOf(recordMap.values()[9]); // Industry -> Industry_EventVisitor__c 변경
                            newRecord.InterestedItem__c            = String.valueOf(recordMap.values()[10]);
                            newRecord.Country__c                   = String.valueOf(recordMap.values()[11]);
    
                            if(isDNSA){
                                newRecord.PostalCode                   = String.valueOf(recordMap.values()[12]);
                                newRecord.Address1__c                  = String.valueOf(recordMap.values()[13]);
                                newRecord.Address2__c                  = String.valueOf(recordMap.values()[14]);
                                newRecord.IsDNSolutionsAvailable__c    = (recordMap.values()[15] == 'Y');
                                newRecord.Rating                       = String.valueOf(recordMap.values()[16]);
                                newRecord.RequestQuote__c              = (recordMap.values()[17] == 'Y');
                                newRecord.RequestQuoteDate__c          = (String.valueOf(recordMap.values()[18]) != null && String.valueOf(recordMap.values()[18]).trim() != '') ? Date.valueOf(String.valueOf(recordMap.values()[18])): null;
                                newRecord.Description                  = String.valueOf(recordMap.values()[19]);
                                newRecord.ExcludeLead__c               = (recordMap.values()[20] == 'Y');
    
                            }else{
                                newRecord.Region__c                    = String.valueOf(recordMap.values()[12]);
                                newRecord.PostalCode                   = String.valueOf(recordMap.values()[13]);
                                newRecord.Address1__c                  = String.valueOf(recordMap.values()[14]);
                                newRecord.Address2__c                  = String.valueOf(recordMap.values()[15]);
                                newRecord.IsDNSolutionsAvailable__c    = (recordMap.values()[16] == 'Y');
                                newRecord.Rating                       = String.valueOf(recordMap.values()[17]);
                                newRecord.RequestQuote__c              = (recordMap.values()[18] == 'Y');
                                newRecord.RequestQuoteDate__c          = (String.valueOf(recordMap.values()[19]) != null && String.valueOf(recordMap.values()[19]).trim() != '') ? Date.valueOf(String.valueOf(recordMap.values()[19])): null;
                                newRecord.Description                  = String.valueOf(recordMap.values()[20]);
                                newRecord.ExcludeLead__c               = (recordMap.values()[21] == 'Y');
                            }
    
    
                            // leadKey로 필드 값들을 저장할 서브 Map 생성
                            Map<String, Object> fieldValues = new Map<String, Object>();
                            if(eventCode != null){
                                fieldValues.put('eventCode', eventCode);
                            }
                            fieldValues.put('subject', newRecord.EventName__c + (isDNSA ? ' Memo' : ' 메모'));
                            fieldValues.put('activityDate', newRecord.VisitTime__c.date());
                            fieldValues.put('description', newRecord.Description );
    
                            // leadDataMap에 leadKey와 fieldValues 추가
                            leadDataMap.put(leadKey, fieldValues);
    
                        }
    
                        finalUpsertList.add(newRecord);
                        System.debug('newRecord :: ' + newRecord);
                        System.debug('finalUpsertList :: ' + finalUpsertList);
                    }
                    
                } catch (Exception e) {
                    
                    System.debug('Error occurred while processing record: ' + e.getMessage());
                    System.debug('Exception Line Number: ' + e.getLineNumber());
                    System.debug('Exception Stack Trace: ' + e.getStackTraceString());
                    throw new AuraHandledException('Failed to upsert records: ' + e.getMessage());
    
                }
            }
    
    
            if (!finalUpsertList.isEmpty()) {
                try {
                    upsert finalUpsertList;
    
                    List<LeadEvent__c> leadEventList = [
                        SELECT Lead__c, EventManagement__c 
                        FROM LeadEvent__c 
                        WHERE Lead__c IN :finalUpsertList 
                        AND EventManagement__c IN :emMap.values()
                    ];
    
                    for (LeadEvent__c existingLeadEvent : leadEventList) {
                        String leadEventKey = existingLeadEvent.Lead__c + '-' + existingLeadEvent.EventManagement__c;
                        existingLeadEventSet.add(leadEventKey);
                    }
    
                    System.debug('finalUpsertList :: ' + finalUpsertList);
                    for(Lead lead : finalUpsertList){
                        System.debug('lead Id :: ' + lead.Id);
    
                        // 회사 + 이름 + 휴대폰 (Commpany + Name + Phone)
                        String leadKey = lead.Company + lead.LastName + lead.MobilePhone;
                        System.debug('leadKey :: ' + leadKey);
    
    
                        if (templateType == 'Event Visitor' && leadKey != null && leadDataMap.containsKey(leadKey)) {    
    
                            Map<String, Object> leadFields = leadDataMap.get(leadKey);
    
                            // Task 레코드 생성 및 필드 할당
                            Task taskRecord = new Task();
                            taskRecord.WhoId = lead.Id;
                            taskRecord.Subject = String.valueOf(leadFields.get('subject'));
                            taskRecord.ActivityDate = (Date) leadFields.get('activityDate');
                            taskRecord.Status = 'Completed';
                            taskRecord.Description = String.valueOf(leadFields.get('description'));
    
                            // 추가할 작업 리스트에 추가
                            insertToTask.add(taskRecord);
    
    
                            // LeadEvent 레코드 생성
                            String eventCode = (String)leadFields.get('eventCode');
                            if (eventCode != null && emMap.containsKey(eventCode)) {
    
                                String eventManagementId = emMap.get(eventCode).Id;
                                String leadEventKey = lead.Id + '-' + eventManagementId;
    
    
                                // 이미 존재하지 않을 때만 LeadEvent 추가
                                if (!existingLeadEventSet.contains(leadEventKey)) {
                                    LeadEvent__c leadEvent = new LeadEvent__c();
                                    leadEvent.EventManagement__c = eventManagementId;
                                    leadEvent.Lead__c = lead.Id;
                                    insertToLeadEvent.add(leadEvent);
    
                                    // 새로운 LeadEvent 조합 추가
                                    existingLeadEventSet.add(leadEventKey);
                                }
    
                            }
    
                        }
                    }
    
                    if(!insertToLeadEvent.isEmpty()){
                        insert insertToLeadEvent;
                        System.debug('insertToLeadEvent :: ' + insertToLeadEvent);
                    }
    
                    if(!insertToTask.isEmpty()){
                        insert insertToTask;
                        System.debug('insertToTask :: ' + insertToTask);
                    }
    
                } catch (Exception e) {
                    System.debug('Error during upsert: ' + e.getMessage());
                    System.debug('Exception Line Number: ' + e.getLineNumber());
                    System.debug('Exception Stack Trace: ' + e.getStackTraceString());
                    throw new AuraHandledException('Failed to upsert records: ' + e.getMessage());
                }
            }
    
            return 'Success';
            
        } catch (Exception e) {
            System.debug('Error in upsertRecords: ' + e.getMessage());
            System.debug('Line Number: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }

    }



}