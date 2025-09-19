/**
 * @description       : Launching Excellence 
 * @author            : Hayeong Min
 * @group             : 
 * @last modified on  : 12-04-2024
 * @last modified by  : Hayeong Min
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   12-04-2024   Hayeong Min   Initial Version
**/
public without sharing class DN_LaunchingExcellenceBtnController {
    public String recordId { get; set; }
    
    public DN_LaunchingExcellenceBtnController(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
    }

    /**
     * @Description
     * 	- Field Service Mobile App에서 해당 Service Order가 설치시운전 오더인지 확인
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static Boolean getPMActivityType(String recordId){
        Boolean isInstallOrder = FALSE;
        try {
            String pmType = [SELECT OrderType__c FROM WorkOrder WHERE Id = :recordId].OrderType__c;
            if(pmType == '104'){
                isInstallOrder = TRUE;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return isInstallOrder;
    }
        

    /**
     * @Description
     * 	- 문서 자료 가져오기
     * 
     * @author Hayeong Min | 01-06-2025
     * @Parameter
     *  - paramData     : url에 맵핑된 정보들 (선택한 docName, workorderId, userId, device정보)
    **/
    @AuraEnabled
    @RemoteAction
    public static CommonWrapper getHtmlContent(String paramData) {       
        CommonWrapper cw = new CommonWrapper();     
        try {
            String isEditable = 'true';
            ParamWrapper paramMap = (ParamWrapper) JSON.deserialize(paramData, ParamWrapper.class);
            String chName = (String) paramMap.chName;
            String woId = (String) paramMap.woId;
            String userId = (String) paramMap.userId;
            String device = (String) paramMap.device;
            
            WorkOrder wo = [SELECT Status, Asset.Name, FM_MachineName__c, OrderType__c FROM WorkOrder WHERE Id = :woId];
            
            //Work Order의 Status가 Confirm일 때는 자료 수정 못함
            if(wo.Status == 'Confirm'){
                isEditable = 'false';
            }

            //Work Order의 장비의 기종으로 기종관련 체크시트 조회
            String checkSheet = String.isNotEmpty(wo.FM_MachineName__c) ? getCheckSheet(wo.Asset.Name.split('-')[0], chName, userId) : '';
            
            if(String.isEmpty(checkSheet)){
                cw.isSuccess = false;
                cw.errMessage = '해당 기종에는 선택한 문서정보가 없습니다.';
            }

            String params = '{"Report1":true,"Report2":true,"PDFPage1":true,"Report3":true';
            if(cw.isSuccess){
                //기존에 저장된 정보가 있는지 확인
                List<LaunchingExcellence__c> leList = new List<LaunchingExcellence__c>();
                leList = [SELECT Id, FORMID__c, Name, Value__c, WorkOrder__c FROM LaunchingExcellence__c WHERE WorkOrder__c = : woId AND DocName__c = :checkSheet];
                
                if(!leList.isEmpty()){
                    for(LaunchingExcellence__c le : leList){
                        params += String.isNotEmpty(le.FORMID__c) ? ',"' + le.FORMID__c + '":"' + le.Value__c + '"': '';
                    }
                }
                params += '}';

                Http http = new Http();
                HttpRequest request = new HttpRequest();

                request.setMethod('POST');

                request.setEndpoint('https://crmoz.dn-solutions.com/SpringOZ80/mes/Oz80DefaultPost');

                request.setHeader('Content-Type', 'application/text');

                String requestBody = '{"editable": '+isEditable+',"data": [{"CHECKSHEET" : "'+checkSheet+'","PARAMS": '+params+'}]}';
                System.debug('requestBody ' + requestBody);
                cw.requestBody = requestBody;

                request.setBody(requestBody);

                HttpResponse response = http.send(request);

                if (response.getStatusCode() == 200) {
                    System.debug('응답 성공: ' + response.getBody());
                    cw.returnValue = response.getBody();
                } else {
                    System.debug('응답 실패: ' + response.getStatusCode() + ' - ' + response.getStatus());
                }
            }

        } catch (Exception e) {
            // 예외 처리
            cw.isSuccess = false;
            cw.errMessage = e.getLineNumber() +'_'+e.getMessage();
            System.debug('HTTP 요청 중 오류 발생: ' + e.getMessage());
        }
        return cw;
    }

    /**
     * @Description
     * 	- 문서 자료 저장하기
     * 
     * @author Hayeong Min | 01-06-2025
     * @Parameter
     *  - jsonStr       : 문서에 기입한 정보
     *  - paramData     : url에 맵핑된 정보들 (선택한 docName, workorderId, userId, device정보)
    **/
    @AuraEnabled
    @RemoteAction
    public static CommonWrapper saveDocContent(String jsonStr, String paramData) {
        System.debug('jsonStr : '+jsonStr);
        CommonWrapper cw = new CommonWrapper();
        try {

            ParamWrapper paramMap = (ParamWrapper) JSON.deserialize(paramData, ParamWrapper.class);
            String chName = (String) paramMap.chName;
            String woId = (String) paramMap.woId;
            String userId = (String) paramMap.userId;
            String device = (String) paramMap.device;

            WorkOrder wo = [SELECT Status, FM_MachineName__c, Asset.Name FROM WorkOrder WHERE Id = :woId];

            String checkSheet = getCheckSheet(wo.Asset.Name.split('-')[0], chName, userId);
            List<LaunchingExcellence__c> existList = new List<LaunchingExcellence__c>();
            existList = [SELECT Id, FORMID__c , Name, Value__c, WorkOrder__c FROM LaunchingExcellence__c WHERE WorkOrder__c = : woId  AND DocName__c = :checkSheet];
            System.debug('existList : '+existList);
            if(!existList.isEmpty()){
                delete existList;
            }

            List<Object> parsedData = (List<Object>) JSON.deserializeUntyped(jsonStr);
            
            // 데이터 처리
            List<LaunchingExcellence__c> leList = new List<LaunchingExcellence__c>();
            for (Object itemObj : parsedData) {
                Map<String, Object> item = (Map<String, Object>) itemObj;
                System.debug('FORMID: ' + item.get('FORMID'));
                System.debug('NAME: ' + item.get('NAME'));
                System.debug('VALUE: ' + item.get('VALUE'));
                
                LaunchingExcellence__c le = new LaunchingExcellence__c();
                le.FORMID__c = String.valueOf(item.get('FORMID'));
                le.Name = String.valueOf(item.get('NAME'));
                // System.debug('맬류 :: ' + String.valueOf(item.get('VALUE')));
                le.Value__c = item.get('VALUE') != '' ? String.valueOf(item.get('VALUE')) : '';
                if(le.Value__c.contains('data:image')){
                    String escapedDecodedPart = le.Value__c.replaceAll('\\\"', '\\\\\"');
                    le.Value__c = escapedDecodedPart;
                }
                le.WorkOrder__c = woId;
                le.DocName__c = checkSheet;
                
                if(!(String.isEmpty(le.Value__c) || le.Value__c == 'null')){
                    leList.add(le);
                }
            }

            cw.returnList = leList;
            insert leList;

        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
        
    }

    /**
     * @Description
     * 	- 사용자가 선택한 문서 조회
     *  - 사용자의 언어로 등록된 해당 장비의 문서 조회
     * @author Hayeong Min 
    **/
    public static String getCheckSheet(String model, String sheetName, String userId){
        List<ModelManager__c> modelManager = [SELECT Id, Name, ModelCode__c, 
        UserTraining_EN__c, UserTraining_KR__c, 
        Install_EN__c, Install_KR__c,
        InstallationInspection_KR__c, InstallationInspection_EN__c
        FROM ModelManager__c WHERE ModelCode__c = :model LIMIT 1];
        String checkSheet = '';
        if(!modelManager.isEmpty()){
            ModelManager__c chList = modelManager[0];
            //유저 정보를 기반으로 체크시트 국문/영문 선택
            User u = [SELECT Id, LanguageLocaleKey FROM User WHERE Id = :userId];
            String lang = u.LanguageLocaleKey.contains('ko') ? 'KR' : 'EN';
            System.debug(lang);
            switch on sheetName {
                
                when 'UserTraining'{
                    checkSheet = lang == 'KR' ? chList.UserTraining_KR__c : chList.UserTraining_EN__c;
                }
                when 'Install' {
                    checkSheet = lang == 'KR' ? chList.Install_KR__c : chList.Install_EN__c;
                }
                when 'InstallationInspection' {
                    checkSheet = lang == 'KR' ? chList.InstallationInspection_KR__c : chList.InstallationInspection_EN__c;
                }
            }
        }
        System.debug('sheetName : '+sheetName);
        return checkSheet;
    }

    /**
     * @Description
     *  - 사용자의 언어로 등록된 문서 조회 및 해당 다운로드 URL 반환
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static CommonWrapper checkDocId(String recordId, String sheetName){
        CommonWrapper cw = new CommonWrapper();
        try {
            WorkOrder wo = [SELECT AssetId, Asset.Name FROM WorkOrder WHERE ID = :recordId];

            String modelName = wo.Asset.Name;
            String model = modelName.split('-')[0];
            List<ModelManager__c> modelManager = [SELECT Id, ModelCode__c, InstallManual_KR__c, InstallManual_EN__c, InstallSchedule_KR__c, InstallSchedule_EN__c FROM ModelManager__c WHERE ModelCode__c = :model LIMIT 1];
            if(!modelManager.isEmpty()){
                ModelManager__c chList = modelManager[0];

                User u = [SELECT Id, LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()];
                String lang = u.LanguageLocaleKey.contains('ko') ? 'KR' : 'EN';
                
                String checkSheet = '';
                switch on sheetName {
                    when 'InstallManual'{
                        checkSheet = lang == 'KR' ? chList.InstallManual_KR__c : chList.InstallManual_EN__c;
                    }
                    when 'InstallSchedule' {
                        checkSheet = lang == 'KR' ? chList.InstallSchedule_KR__c : chList.InstallSchedule_EN__c;
                    }
                }
                
                //경로찾기
                List<LaunchingExcellenceDoc__c> leDocList = [SELECT Id FROM LaunchingExcellenceDoc__c WHERE Name = :checkSheet LIMIT 1];
                if(leDocList.size()>0){
                    Id leDocId = leDocList[0].Id;
                    ContentDocumentLink cdl = [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :leDocId LIMIT 1];
                    ContentDistribution docDistribute = [SELECT Id, ContentVersionId, ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId = :cdl.ContentDocumentId];

                    cw.returnValue = cdl.ContentDocumentId;
                    cw.contentTitle = cdl.ContentDocument.Title;

                    //파일 다운로드 url 가공공
                    String fullRecordURL = URL.getOrgDomainURL().toExternalForm();
                    String publicURL = docDistribute.DistributionPublicUrl;
                    Integer index = publicURL.indexOf('/a/');
                    publicURL = publicURL.substring(index);
                    String fileDownURL = fullRecordURL.replace('.my.salesforce.com', '.file.force.com');
                    fileDownURL += '/sfc/dist/version/download';
                    fileDownURL += '/?oid='+UserInfo.getOrganizationId();
                    fileDownURL += '&ids='+docDistribute.ContentVersionId;
                    fileDownURL += '&d='+publicURL;
                    System.debug(fileDownURL);
                    cw.downloadURL = fileDownURL;
                }else{
                    cw.isSuccess = false;
                    cw.errMessage = 'Launching Excellence Document에 해당 기종과 관련된 문서가 등록되지 않았습니다.';
                }

            }else{
                cw.isSuccess = false;
                cw.errMessage = '해당 기종관리에 문서정보가 등록되지 않았습니다.';
            }
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getLineNumber()+'_'+e.getMessage();
        }
        return cw;
    }


    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess 		                    {get; set;}
        @AuraEnabled
        public String errMessage		                    {get; set;} 
        @AuraEnabled
        public String returnValue		                    {get; set;} 
        @AuraEnabled
        public String contentTitle		                    {get; set;} 
        @AuraEnabled
        public String downloadURL		                    {get; set;} 
        @AuraEnabled
        public String requestBody		                    {get; set;} 
        @AuraEnabled
        public List<LaunchingExcellence__c> returnList		{get; set;} 
        
        public CommonWrapper(){
            this.isSuccess 		= true;
            this.errMessage 	= '';
            this.returnValue 	= '';
            this.contentTitle 	= '';
            this.downloadURL 	= '';
            this.requestBody 	= '';
            this.returnList 	= new List<LaunchingExcellence__c>();
        }
    }

    public class ParamWrapper {
        @AuraEnabled
        public String chName { get; set; }
        @AuraEnabled
        public String woId { get; set; }
        @AuraEnabled
        public String userId { get; set; }
        @AuraEnabled
        public String device { get; set; }

        public ParamWrapper() {
            this.chName = '';
            this.woId = '';
            this.userId = '';
            this.device = '';
        }
    }
}