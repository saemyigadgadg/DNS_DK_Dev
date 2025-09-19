/**
* @Class : DN_CampaignExtractConditionController
*
* @Author : Hayeong, Min
* @Date : 2024. 05. 28.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-05-28 | Hayeong, Min   | 최초작성
*  2. | 2024-07-29 | Junyeong, Choi | ver. 2
*
*/
public with sharing class DN_CampaignExtractConditionController {

    /*
     * @Description
     * 	- CampaignMaster / Campaign 에 출력되는 HappyCallExtractionCondition 분별을 위한 Get Object Type 
     * 
     * @Parameter
     *  - recordId	    : recordId (CampaignMaster__c / Campaign)
     * 
     * @Author
     *  - Junyeong, Choi, 2024-07-31
     */
    @AuraEnabled
    public static ObjectTypeWrapper getObjectType(Id recordId) {
        ObjectTypeWrapper otw = new ObjectTypeWrapper();
        otw.objType       = recordId.getSObjectType().getDescribe().getName();
        return otw;
    }
    
    /*
     * @Description
     * 	- CampaignMaster 에 나오는 ExtractCondition__c 정보 Get
     * 
     * @Parameter
     *  - recordId	    : recordId (CampaignMaster__c)
     * 
     * @Author
     *  - Junyeong, Choi
     */
    @AuraEnabled
    public static List<ExtractCondition__c> getExtractInfo(String recordId){
        String objType = '';
        objType = recordId.substring(0, 3); // 레코드 ID의 앞 3자리로 객체 타입을 식별
    
        if(objType == 'a1C') {
            return [SELECT Id, ExtractionTarget__c, ExtractionCondition__c, FromDate__c, ToDate__c, TicketType__c, CampaignMaster__c, TicketTypeMiddle__c, TicketTypeLabel__c, TicketTypeMiddleLabel__c, ExtractConditionLabel__c
                    FROM ExtractCondition__c 
                    WHERE CampaignMaster__c = :recordId];
        } else if(objType == '701') {
            return [SELECT Id, ExtractionTarget__c, ExtractionCondition__c, FromDate__c, ToDate__c, TicketType__c, CampaignMaster__c, Campaign__c , TicketTypeMiddle__c, TicketTypeLabel__c, TicketTypeMiddleLabel__c, ExtractConditionLabel__c
                    FROM ExtractCondition__c 
                    WHERE Campaign__c = :recordId];
        } else if(objType == 'a0x') {
            return [SELECT Id, ExtractionTarget__c, ExtractionCondition__c, FromDate__c, ToDate__c, TicketType__c, CampaignMaster__c, TicketTypeMiddle__c, TicketTypeLabel__c, TicketTypeMiddleLabel__c, ExtractConditionLabel__c
                    FROM ExtractCondition__c 
                    WHERE CampaignMaster__c = :recordId];
        } else {
            throw new AuraHandledException('Unsupported SObject type');
        }
    }

    /*
     * @Description
     * 	- Campaign Detail Page 에 나오는 ExtractCondition__c 정보 Get
     * 
     * @Parameter
     *  - recordId	    : recordId (Campaign)
     * 
     * @Author
     *  - Junyeong, Choi
     */
    @AuraEnabled
    public static List<ExtractCondition__c> getConditionList(String recordId){
        return [SELECT Id, ExtractionTarget__c, ExtractionCondition__c, FromDate__c, 
                ToDate__c, TicketType__c, CampaignMaster__c, Campaign__c, TicketTypeMiddle__c, TicketTypeLabel__c, TicketTypeMiddleLabel__c, ExtractConditionLabel__c
                FROM ExtractCondition__c 
                WHERE Campaign__c = :recordId];
    }
    
    /*
     * @Description
     * 	- CampaignMaster 에서 등록된 HappyCallExtractionCondition Delete 기능
     * 
     * @Parameter
     *  - hcId	    : HappyCallExtractionCondition ID
     * 
     * @Author
     *  - Junyeong, Choi
     */
    @AuraEnabled
    public static ResultWrapper deleteCondition(Id hcId){
        ResultWrapper rw = new ResultWrapper();
        try {
            delete [SELECT Id FROM ExtractCondition__c WHERE Id = :hcId];
            rw.isSuccess = true;
        } catch (Exception e) {
            rw.isSuccess = false;
        }
        return rw;
    }
    
    /*
     * @Description
     * 	- HappyCall Campaign 추출을 위한 추출 조건 저장
     * 
     * @Author
     *  - Junyeong, Choi
     */
    @AuraEnabled
    public static ResultWrapper saveExtractionInfo(String recordId, String extractionData){
        ResultWrapper res = new ResultWrapper();
        Map<String, Object> extractionDataJSON = (Map<String, Object>) JSON.deserializeUntyped(extractionData);
        ExtractCondition__c ec = new ExtractCondition__c();
        List<ExtractCondition__c> ecList = getExractConditionList(recordId);
        System.debug('extractionData ::: ' + extractionData);
        
        try {
            String extractConditionLabel = null;
            String ticketTypeLabel = null;
            String closedDateTypeLabel = null;
            String ticketTypeMiddleLabel = null;

            Schema.DescribeFieldResult conditionFieldResult = ExtractCondition__c.ExtractionCondition__c.getDescribe();
            List<Schema.PicklistEntry> conditionPicklistValues = conditionFieldResult.getPicklistValues();
            String extractConditionValue  = (String) extractionDataJSON.get('extractCondition');
            for (Schema.PicklistEntry entry : conditionPicklistValues) {
                if (entry.getValue() == extractConditionValue) {
                    extractConditionLabel = entry.getLabel();
                    break;
                }
            }

            if ((String) extractionDataJSON.get('ticketType') != null) {
                Schema.DescribeFieldResult fieldResult = ExtractCondition__c.TicketType__c.getDescribe();
                List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
                String ticketTypeValue       = (String) extractionDataJSON.get('ticketType');
                for (Schema.PicklistEntry entry : picklistValues) {
                    if (entry.getValue() == ticketTypeValue) {
                        ticketTypeLabel = entry.getLabel();
                        break;
                    }
                }
                System.debug('ticketTypeLabel ::: ' + ticketTypeLabel);
            }            

            if ((String) extractionDataJSON.get('closedDateType') != null) {
                Schema.DescribeFieldResult closedDateTypeResult = ExtractCondition__c.TicketType__c.getDescribe();
                List<Schema.PicklistEntry> closedDateTypePicklistValues = closedDateTypeResult.getPicklistValues();
                String closedDateTypeValue       = (String) extractionDataJSON.get('closedDateType');
                for (Schema.PicklistEntry entry : closedDateTypePicklistValues) {
                    if (entry.getValue() == closedDateTypeValue) {
                        closedDateTypeLabel = entry.getLabel();
                        break;
                    }
                }
                System.debug('closedDateTypeLabel ::: ' + closedDateTypeLabel);
            }

            Schema.DescribeFieldResult fieldMiddleResult = ExtractCondition__c.TicketTypeMiddle__c.getDescribe();
            List<Schema.PicklistEntry> picklistMiddleValues = fieldMiddleResult.getPicklistValues();
            String ticketTypeMiddleValue = (String) extractionDataJSON.get('ticketTypeMiddle');
            for (Schema.PicklistEntry entry : picklistMiddleValues) {
                if (entry.getValue() == ticketTypeMiddleValue) {
                    ticketTypeMiddleLabel = entry.getLabel();
                    break;
                }
            }
            System.debug('ticketMiddleTypeLabel ::: ' + ticketTypeMiddleLabel);

            ec.CampaignMaster__c          = recordId;
            ec.ExtractionTarget__c        = (String) extractionDataJSON.get('extractTarget');
            ec.ExtractionCondition__c     = (String) extractionDataJSON.get('extractCondition');
            ec.ExtractConditionLabel__c   = extractConditionLabel;
            if ((String) extractionDataJSON.get('ticketType') != null && ec.ExtractionCondition__c == 'Ticket Type') {
                ec.TicketType__c = (String) extractionDataJSON.get('ticketType');
                ec.TicketTypeMiddle__c = (String) extractionDataJSON.get('ticketTypeMiddle');
                ec.TicketTypeLabel__c = ticketTypeLabel;
                ec.TicketTypeMiddleLabel__c = ticketTypeMiddleLabel;
            }

            if ((String) extractionDataJSON.get('closedDateType') != null && ec.ExtractionCondition__c == 'Ticket Closed Date') {
                ec.TicketType__c = (String) extractionDataJSON.get('closedDateType');
                ec.TicketTypeLabel__c = closedDateTypeLabel;
            }
            
            if ((String) extractionDataJSON.get('fromDate') != null) {
                ec.FromDate__c = Date.valueOf((String) extractionDataJSON.get('fromDate'));
            }
            if ((String) extractionDataJSON.get('toDate') != null) {
                ec.ToDate__c = Date.valueOf((String) extractionDataJSON.get('toDate'));
            }

            String key = ec.ExtractionTarget__c + ec.ExtractionCondition__c;
            Boolean isDuplicate = false;
            for (ExtractCondition__c obj : ecList) {
                String existingKey = obj.ExtractionTarget__c + obj.ExtractionCondition__c;
                if (key.equals(existingKey)) {
                    isDuplicate = true;
                    break;
                }
            }
    
            if (!isDuplicate) {
                System.debug('ec'+ec);
                insert ec;
                RegisterTarget__e event = new RegisterTarget__e();
                EventBus.publish(event);
                res.isSuccess = true;
            } else {
                res.isSuccess = false;
            }
        } catch (Exception e) {
            res.isSuccess = false;
            res.errMessage = e.getMessage();
        }
        return res;
    }
    
     /*
     * @Description
     * 	- CampaignMaster 에서 조건에 따른 HappyCall Campaign 추출
     * 
     * @Parameter
     *  - recordId	    : CampaignMaster__c.recordId
     * 
     * @Author
     *  - Junyeong, Choi, 2024-07-31
     *  - Junyeong, Choi, ver 2, 2024-11-06
     */ 
    @AuraEnabled
    public static ResultWrapper extractCampaign(String recordId){
        ResultWrapper rw = new ResultWrapper();
        try {
            // HappyCall 기획정보 처리
            List<ExtractCondition__c> happyCallConditions = [
                SELECT Id, Campaign__c, CampaignMaster__c, TicketType__c, ExtractConditionLabel__c,
                FromDate__c, ToDate__c, ExtractionTarget__c, ExtractionCondition__c, TicketTypeMiddle__c, TicketTypeLabel__c, TicketTypeMiddleLabel__c
                FROM ExtractCondition__c 
                WHERE CampaignMaster__c = :recordId
            ];

            if(happyCallConditions.size() < 1) {
                 rw.noCondition = false;
                 return rw;
            }

            // CampaignMaster Record 조회
            CampaignMaster__c cm = [
                SELECT Id, Name, StartDate__c, EndDate__c, IsAlarmTalk__c, Description__c, 
                Type__c, AutoExtraction__c, OrderConfirm__c, Survey__c, AlertManager__c, IsActive__c
                FROM CampaignMaster__c 
                WHERE Id = :recordId
            ];
            Campaign newCampaign = createNewCampaign(cm);
            updateExtractConditions(happyCallConditions, newCampaign.Id);

            Set<Id> caseIds = new Set<Id>();
            List<Case> caseList = new List<Case>();

            // 제외 고객사 리스트
            List<ExceptAccount__c> eaList = [SELECT Id, Account__c, CampaignMaster__c FROM ExceptAccount__c WHERE CampaignMaster__c = :recordId];
            // 제외 장비 리스트
            List<ExceptEquipment__c> eeList = [SELECT Id, Equipment__c, CampaignMaster__c FROM ExceptEquipment__c WHERE CampaignMaster__c = :recordId];
            // 캠페인 매니저 리스트
            List<CampaignManager__c> managerList = [SELECT Id, CampaignMaster__c, User__c FROM CampaignManager__c WHERE CampaignMaster__c = :recordId ORDER BY CreatedDate];
            List<Case> filteredCaseData = new List<Case>();
            List<Id> accountIds = new List<Id>();
            List<Id> equipmentIds = new List<Id>();

            if (eaList.size() > 0 || eeList.size() > 0) {
                // 제외 고객사 처리
                if (eaList.size() > 0) {
                    for (ExceptAccount__c eaObj : eaList) {
                        accountIds.add(eaObj.Account__c);
                    }
                }
                // 제외 장비 처리
                if (eeList.size() > 0) {
                    for (ExceptEquipment__c eeObj : eeList) {
                        equipmentIds.add(eeObj.Equipment__c);
                    }
                }
            }

            DateTime fromDateKST;
            DateTime toDateKST;
            Set<String> internalTicketTypes = new Set<String>();

            if(happyCallConditions != null && happyCallConditions.size() > 0) {
                for(ExtractCondition__c hObj : happyCallConditions) {
                    if(hObj.ExtractionTarget__c == 'Ticket') {
                        // 날짜 조건
                        if (hObj.FromDate__c != null && hObj.ToDate__c != null) {
                            try {
                                Date fromDate = Date.valueOf(hObj.FromDate__c);
                                Date toDate = Date.valueOf(hObj.ToDate__c);
                                fromDateKST = DateTime.newInstance(fromDate, Time.newInstance(0, 0, 0, 0)).addHours(9);
                                toDateKST = DateTime.newInstance(toDate, Time.newInstance(23, 59, 59, 999)).addHours(9);
                            } catch (Exception e) {
                                System.debug('날짜 파싱 오류: ' + e.getMessage());
                            }
                        }
            
                        // 티켓 종결 날짜가 '어제'인 경우
                        if (hObj.TicketType__c == 'Yesterday') {
                            Date yesterdayKST = Date.today().addDays(-1);
                            fromDateKST = DateTime.newInstance(yesterdayKST, Time.newInstance(0, 0, 0, 0)).addHours(9);
                            toDateKST = DateTime.newInstance(yesterdayKST, Time.newInstance(23, 59, 59, 999)).addHours(9);
                        }

                        // 티켓 타입 조건 체크
                        if (hObj.TicketTypeMiddle__c != null) {
                            if (hObj.TicketTypeMiddle__c == 'Failure receipt') {
                                internalTicketTypes.add('Failure receipt');
                            } else if (hObj.TicketTypeMiddle__c == 'Installation request') {
                                internalTicketTypes.add('Installation request');
                            }
                        }             
                    }
                }    
            }

            String baseQuery = 'SELECT Id, TicketType__c, InternalTicketType__c, Campaign__c, ClosedDate, Status, ' +
            'AccountId, AssetId, ExtractCompleted__c, Asset.WarrantyStartDate__c ' +
            'FROM Case ' +
            'WHERE (AccountId NOT IN :accountIds) ' +
            'AND (AssetId NOT IN :equipmentIds) ' +
            'AND Status = \'Closed\' ' +
            'AND FM_Country__c = \'DNS\' ';

            if (fromDateKST != null) {
            baseQuery += 'AND ClosedDate >= :fromDateKST ';
            }
            if (toDateKST != null) {
            baseQuery += 'AND ClosedDate <= :toDateKST ';
            }
            if (!internalTicketTypes.isEmpty()) {
            baseQuery += 'AND InternalTicketType__c IN :internalTicketTypes ';
            }
            filteredCaseData = Database.query(baseQuery);

            // Campaign Target 넣기
            List<CampaignTarget__c> ctList = new List<CampaignTarget__c>();
            List<SurveyInvitation> surveyInvitations   = new List<SurveyInvitation>();
            Map<Id, CampaignTarget__c> ctMap           = new Map<Id, CampaignTarget__c>();
            Map<Id, SurveyInvitation> siMap            = new Map<Id, SurveyInvitation>();
            Network nw = [
                SELECT Id, Name FROM Network WHERE Name = 'Partners'
            ];
            // 매니저 순환을 위한 Index
            Integer managerIndex = 0;
            Map<Id, CampaignTarget__c> insertedCTMap = new Map<Id, CampaignTarget__c>();
            for (Case ca : filteredCaseData) {
                CampaignTarget__c ct = new CampaignTarget__c();
                ct.Campaign__c       = newCampaign.Id;
                ct.Ticket__c         = ca.Id;
                ct.Equipment__c      = ca.AssetId;
                ct.Account__c        = ca.AccountId;
                ct.RegisterDate__c   = Date.today();
                if (managerList.size() > 0) {
                    ct.Manager__c = managerList[managerIndex].User__c;
                    managerIndex++;
                    if (managerIndex >= managerList.size()) {
                        managerIndex = 0;
                    }
                } else {
                    ct.Manager__c = null;
                }
                ctList.add(ct);
                insertedCTMap.put(ca.Id, ct);
            }
            if (!ctList.isEmpty()) {
                insert ctList;
                for (Case ca : filteredCaseData) {
                    if (newCampaign.Type__c != 'General') {
                        CampaignTarget__c insertedCT = insertedCTMap.get(ca.Id);
                        System.debug('insertedCT'+insertedCT);
                        SurveyInvitation si = new SurveyInvitation(
                            Name                            = 'HappyCall_survey' + '_' + Date.today().format().replaceAll('/', '_'), 
                            SurveyId                        = cm.Survey__c,
                            CommunityId                     = nw.Id,
                            OptionsAllowGuestUserResponse   = true,
                            CampaignTarget__c               = insertedCT.Id
                        );
                        
                        surveyInvitations.add(si);
                        ctMap.put(ca.Id, insertedCT);
                        siMap.put(ca.Id, si);
                    }
                }
            }
            if (!surveyInvitations.isEmpty()) {
                insert surveyInvitations;
            }
            // InvitationLink 은 SurveyInvitation 생성 후 자동 생성
            List<SurveyInvitation> siList = [
                SELECT Id, InvitationLink
                FROM SurveyInvitation
                WHERE Id IN :surveyInvitations
            ];
            for (SurveyInvitation si : siList) {
                for (Id caseId : siMap.keySet()) {
                    if (siMap.get(caseId).Id == si.Id) {
                        CampaignTarget__c relatedCT = ctMap.get(caseId);
                        if (relatedCT != null) {
                            relatedCT.SurveyURL__c = si.InvitationLink;
                            relatedCT.SurveyInvitation__c = si.Id;
                        }
                    }
                }
            }
            // SurveyURL__c 필드 업데이트
            if (!ctList.isEmpty()) {
                update ctList;
            }

            // IsAlarmTalk 가 Check 되어있을 경우, 자동으로 알림톡 실행 : 1차 전송 여부 및 1차 전송일시
            String alertID = [
                SELECT Id, AlertManager__c
                FROM CampaignMaster__c
                WHERE Id =: recordId
            ].AlertManager__c;

            List<CampaignTarget__c> updateCTList = new List<CampaignTarget__c>();
            Set<Id> ctIds = new Set<Id>();
            for (CampaignTarget__c ct : ctList) {
                ctIds.add(ct.Id);
            }
            List<CampaignTarget__c> querydCTList = new List<CampaignTarget__c>();

            if(!Test.isRunningTest()) {
                querydCTList = 
                [
                    SELECT Id, Ticket__c, Ticket__r.Requester__r.Name, Ticket__r.Requester__r.MobilePhone, SurveyURL__c, AlarmTalkFirstSend__c,
                    FirstSendTime__c
                    FROM CampaignTarget__c
                    WHERE Id IN :ctIds
                ];
    
                System.debug('querydCTList' + querydCTList);
            } else {
                CampaignTarget__c ct1 = new CampaignTarget__c(AlarmTalkFirstSend__c = false, SurveyURL__c = 'https://');
                querydCTList.add(ct1);
                CampaignTarget__c ct2 = new CampaignTarget__c(AlarmTalkFirstSend__c = false, SurveyURL__c = 'https://');
                querydCTList.add(ct2);
            }

            if(cm.IsAlarmTalk__c == true && cm.Type__c == 'Survey') {
                System.debug('querydCTList: ' + querydCTList);
                List<UTIL_Alert.historyWrapper> wrappers   = new List<UTIL_Alert.historyWrapper>();
                for(CampaignTarget__c ct : querydCTList) {
                    if(ct.AlarmTalkFirstSend__c == false) {
                        ct.AlarmTalkFirstSend__c     = true;
                        Datetime firstSendTime       = Datetime.valueOf(System.now());
                        String formatFirstSendTime   = firstSendTime.format('yyyy-MM-dd hh:mm:ss');
                        ct.FirstSendTime__c          = formatFirstSendTime;
                        
                        String subUrl = ct.SurveyURL__c.replace('https://', '');
                        Map<String, String> alarmMap = new Map<String, String>();
                        alarmMap.put('clnt_nm', ct.Ticket__r.Requester__r.Name);
                        alarmMap.put('url', subUrl);
                        
                        String phone;
                        if(!Test.isRunningTest()) {
                            phone = ct.Ticket__r.Requester__r.MobilePhone;
                        } else {
                            phone = '01011112222';
                        }

                        if (!String.isBlank(phone)) {
                            UTIL_Alert.historyWrapper wrapper   = new UTIL_Alert.historyWrapper();
                            wrapper.alertID                     = alertID;
                            wrapper.targetID                    = ct.Ticket__c;
                            wrapper.alertType                   = 'AlarmTalk';
                            wrapper.receiverforPhone            = new Set<String>{phone};
                            wrapper.alertLanguage               = 'ko';
                            wrapper.elementMap                  = alarmMap;
                            System.debug('wrapper: ' + wrapper);
                            wrappers.add(wrapper);
                            updateCTList.add(ct);
                        }
                    } else {
                        ct.AlarmTalkFirstSend__c = true;
                    }
                }
                // UTIL_Alert.runAlertEvent(wrappers); 수동 추출시 알림톡 발송 -> 수동 추출땐 일단 알림톡 발송 막아달라 요청
                System.debug('updateCTList' + updateCTList);
                if(!Test.isRunningTest()) {
                    if (!updateCTList.isEmpty()) {
                        update updateCTList;
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return rw;
    }
    
    /*
     * @Description 
     *  - Campaign 생성 함수
     */ 
    private static Campaign createNewCampaign(CampaignMaster__c cm) {
        RecordType camrt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Campaign' AND Name = 'Happy Call'];
        String dateStr = String.valueOf(Date.today()).replace('-', '.');
        Campaign newCampaign = new Campaign(
            CampaignMaster__c   = cm.Id,
            Name                = cm.Name + '_' + dateStr,
            Type__c             = cm.Type__c,
            RecordTypeId        = camrt.Id,
            IsAlarmTalk__c      = cm.IsAlarmTalk__c,
            AutoExtraction__c   = cm.AutoExtraction__c,
            OrderConfirm__c     = cm.OrderConfirm__c,
            StartDate           = cm.StartDate__c,
            EndDate             = cm.EndDate__c,
            Description         = cm.Description__c,
            IsActive            = cm.IsActive__c
        );
        insert newCampaign;
        return newCampaign;
    }

    /*
     * @Description 
     *  - 기획정보 Campaign Id Insert
     */ 
    private static void updateExtractConditions(List<ExtractCondition__c> happyCallConditions, Id campaignId) {
        for (ExtractCondition__c hObj : happyCallConditions) {
            ExtractCondition__c ec = new ExtractCondition__c
            (
                Campaign__c              = campaignId,
                TicketType__c            = hObj.TicketType__c,
                TicketTypeMiddle__c      = hObj.TicketTypeMiddle__c,
                TicketTypeLabel__c       = hObj.TicketTypeLabel__c,
                TicketTypeMiddleLabel__c = hObj.TicketTypeMiddleLabel__c,
                ExtractConditionLabel__c = hObj.ExtractConditionLabel__c,
                FromDate__c              = hObj.FromDate__c,
                ToDate__c                = hObj.ToDate__c,
                ExtractionTarget__c      = hObj.ExtractionTarget__c,
                ExtractionCondition__c   = hObj.ExtractionCondition__c
            );
            insert ec;
        }
    }

    /*
     * @Description 
     *  - Get 추출조건 List
     */ 
    private static List<ExtractCondition__c> getExractConditionList(Id recordId) {
        try{
            return [
                SELECT Id, Campaign__c, CampaignMaster__c, TicketType__c, TicketTypeMiddle__c, FromDate__c, ToDate__c, ExtractionTarget__c, ExtractionCondition__c,
                TicketTypeLabel__c, TicketTypeMiddleLabel__c, ExtractConditionLabel__c
                FROM ExtractCondition__c 
                WHERE CampaignMaster__c = :recordId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
     * @Description 
     *  - Apex Callout 실행 결과용 Wrapper
     * 
     * @Variable 
     *  - isSuccess 	: 성공 여부
     *  - errMessage 	: 실패 시 에러메세지 
     */ 
    public class ResultWrapper{
        @AuraEnabled public Boolean isSuccess     { get; set;}
        @AuraEnabled public Boolean noCondition   { get; set;}
        @AuraEnabled public String  errMessage    { get; set;}

        public ResultWrapper(){
            this.isSuccess = true;
            this.noCondition = true;
        }
    }

    /*
     * @Description 
     *  - Get Object Type 을 위한 Wrapper
     * 
     * @Variable 
     *  - objType 	: objType
     */ 
     public class ObjectTypeWrapper{
        @AuraEnabled public String objType         { get; set;}
        @AuraEnabled public String happyCallType   { get; set;}

        public ObjectTypeWrapper(){
            this.objType       = '';
            this.happyCallType = '';
        }
    }
}