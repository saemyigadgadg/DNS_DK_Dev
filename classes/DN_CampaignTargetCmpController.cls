/**
* @Class : DN_CampaignTargetCmpController
*
* @Author : Junyeong, Choi
* @Date : 2024. 10. 08.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-10-08 | Junyeong, Choi | ver. 1
*
*/
public without sharing class DN_CampaignTargetCmpController {

    /*
     * @Description 
     *  - 해당 Record 의 Object Type 조회 Method
     */ 
    @AuraEnabled
    public static ObjectTypeWrapper getObjectType(Id recordId) {
        ObjectTypeWrapper otw = new ObjectTypeWrapper();
        Campaign cm = [
            SELECT Id, Type__c
            FROM Campaign
            WHERE Id = :recordId
        ];
        otw.objType       = recordId.getSObjectType().getDescribe().getName();
        otw.happyCallType = cm.Type__c;
        return otw;
    }

    /*
     * @Description 
     *  - Search 했을 때 Campaign Target 과 설문결과값 GET
     *  -> Migration Data / Migration 아닌 Data 구분
     *  -> 타입 설문 / 일반 구분
     */ 
    @AuraEnabled
    public static List<CampaignTargetWrapper> getTargetList(Id recordId, Date startDate, Date endDate) {
        List<CampaignTargetWrapper> ctWrappers = new List<CampaignTargetWrapper>();
        List<CampaignTarget__c> targetList = new List<CampaignTarget__c>();

        String sQuery = 'SELECT Id, Name, RegisterDate__c, Ticket__c, Ticket__r.CaseNumber, Manager__r.Name, AlamTalkSend__c, FM_SurveyURL__c, SurveyURL__c, AccountName__c, Memo__c, ListSequence__c, ' + 
        'Status__c, SurveyResult__c, AlamSendCount__c, Ticket__r.Id, Manager__r.Id, Ticket__r.AccountId, Ticket__r.FM_PhoneNumber__c, SurveyInvitation__c, Ticket__r.Account.FM_Address__c, ' +
        'CreatedDate, Address__c, Ticket__r.Requester__r.Name, Ticket__r.Requester__r.MobilePhone, Score__c, AdjustScore__c, Ticket__r.FM_EquipmentWarranty__c, Ticket__r.ClosedDate, ' +
        'AlarmTalkFirstSend__c, FirstSendTime__c, FM_Equipment__c, Ticket__r.Asset.InstallationFinish__c, Ticket__r.Asset.EquipmentWarranty__c, Ticket__r.Asset.MachineName__c FROM CampaignTarget__c';
        List<String> wQuery = new List<String>();
        
        // Datetime fromDate = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);
        // Datetime toDate = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), 23, 59, 59);
        wQuery.add('RegisterDate__c >= :startDate AND RegisterDate__c <= :endDate');

        if(recordId != null){
            wQuery.add('Campaign__c = \'' + recordId + '\'');
        }
        if(!wQuery.isEmpty()) {
            sQuery += ' WHERE ' + String.join(wQuery, ' AND ');
        }
        System.debug('sQuery => ' + sQuery);
        String oQuery = ' ORDER BY RegisterDate__c DESC';
        targetList = Database.query(sQuery + oQuery);
        System.debug('targetList => ' + targetList);

        // Campaign Target 의 List Sequence 를 담을 Set<Id>
        Set<String> ctIds = new Set<String>();
        for(CampaignTarget__c ctObj : targetList) {
            if(ctObj.ListSequence__c != null) {
                ctIds.add(ctObj.ListSequence__c);
            }
        }
        
        Map<String, List<String>> sequenceMap = new Map<String, List<String>>();
        List<HappyCallResponse__c> hcrList = 
        [
            SELECT ListSequence__c, SurveyNo__c, SurveyQuestionNo__c, SurveyResponse__c, SurveyResponseDate__c 
            FROM HappyCallResponse__c
            WHERE ListSequence__c =: ctIds
            ORDER BY SurveyQuestionNo__c ASC
        ];
        for(HappyCallResponse__c hcrObj : hcrList) {
            if(!sequenceMap.containsKey(hcrObj.ListSequence__c)) {
                sequenceMap.put(hcrObj.ListSequence__c, new List<String>());
            }
            if (hcrObj.SurveyResponse__c == null || hcrObj.SurveyResponse__c == '') hcrObj.SurveyResponse__c = '';
            sequenceMap.get(hcrObj.ListSequence__c).add(hcrObj.SurveyResponse__c);
        }

        Campaign cp = [SELECT Id, HappyCallType__c, IsMigration__c FROM Campaign WHERE Id =: recordId];
        String hcType = cp.HappyCallType__c;

        if(cp.IsMigration__c) { // Migration Data 조회
            for(CampaignTarget__c target : targetList) {
                CampaignTargetWrapper ctw = new CampaignTargetWrapper();
                ctw.registerDate          = target.RegisterDate__c;
                ctw.AccountId             = target.Ticket__r.AccountId;
                ctw.AccountName           = target.AccountName__c;
                ctw.CustomerName          = target.Ticket__r.Requester__r.Name;
                ctw.PhoneNumber           = target.Ticket__r.Requester__r.MobilePhone;
                ctw.Address               = target.Ticket__r.Account.FM_Address__c;
                ctw.TicketId              = target.Ticket__r.Id;
                
                ctw.SerialNumber          = target.FM_Equipment__c;
                ctw.Ticket                = target.Ticket__r.CaseNumber;
                ctw.InstallDate           = target.Ticket__r.Asset.InstallationFinish__c;
                ctw.Guarantee             = target.Ticket__r.FM_EquipmentWarranty__c;
                ctw.Model                 = target.Ticket__r.Asset.MachineName__c;
                ctw.ManagerId             = target.Manager__r.Id;
                ctw.Manager               = target.Manager__r.Name;
                ctw.Score                 = target.Score__c;
                ctw.AdjustScore           = target.AdjustScore__c;
                // ctw.FirstSend             = ct.AlarmTalkFirstSend__c;
                ctw.FirstSendTime         = target.FirstSendTime__c;
                ctw.AlamTalkSendCount     = target.AlamSendCount__c;
                ctw.Id                    = target.Id;
                // ctw.SurveyStatus          = ct.Status__c;
                // ctw.SurveyCompletedDate   = formatSqrCreatedDate;
                ctw.Memo                  = target.Memo__c;
                ctw.IsMigration           = True;
                ctw.ListSequence = target.ListSequence__c;
                ctw.responseList = sequenceMap.get(target.ListSequence__c);
                System.debug('ctw.responseList =>' + ctw.responseList);
                ctWrappers.add(ctw);
            }
            System.debug('ctWrappers =>' + ctWrappers);
        } else {
            List<Id> ticketIds = new List<Id>();
            for (CampaignTarget__c ct : targetList) {
                if (ct.Ticket__c != null && ct.Ticket__r.Id != null) {
                    ticketIds.add(ct.Ticket__r.Id);
                }
            }

            Map<Id, List<WorkOrder>> ticketToWorkOrders = new Map<Id, List<WorkOrder>>();
            List<WorkOrder> workOrders = [
                SELECT Id, CaseId, Status, CreatedDate, ServiceTerritoryId, ServiceTerritory.Name, Worker__r.Name, FM_WorkCompletionTime__c, RepairAction__c,
                InspectionDetails__c, ServiceOrderNumber__c
                FROM WorkOrder
                WHERE CaseId IN :ticketIds
                ORDER BY CreatedDate ASC
            ];

            for (WorkOrder wo : workOrders) {
                if (!ticketToWorkOrders.containsKey(wo.CaseId)) {
                    ticketToWorkOrders.put(wo.CaseId, new List<WorkOrder>());
                }
                ticketToWorkOrders.get(wo.CaseId).add(wo);
            }

            Map<Id, WorkOrder> firstWorkOrder = new Map<Id, WorkOrder>();
            for (Id ticketId : ticketToWorkOrders.keySet()) {
                List<WorkOrder> woList = ticketToWorkOrders.get(ticketId);
                if (!woList.isEmpty()) {
                    firstWorkOrder.put(ticketId, woList[0]);
                }
            }            

            List<String> SurveyInvitations = new List<String>();
            for(CampaignTarget__c si : targetList){
                SurveyInvitations.add(si.SurveyInvitation__c);
            }

            List<SurveyQuestionResponse> sqrList = [
                SELECT Id, InvitationId, QuestionId, Question.Name, QuestionChoiceId, ResponseValue, CreatedDate, Question.QuestionOrder
                FROM SurveyQuestionResponse
                WHERE InvitationId IN :SurveyInvitations
            ];
            
            List<SurveyQuestionResponse> sortedList = new List<SurveyQuestionResponse>();
            for (SurveyQuestionResponse sqr : sqrList) {
                Integer insertIndex = -1;
                for (Integer i = 0; i < sortedList.size(); i++) {
                    if (sortedList[i].Question.QuestionOrder > sqr.Question.QuestionOrder) {
                        insertIndex = i;
                        break;
                    }
                }
                if (insertIndex == -1) {
                    sortedList.add(sqr);  
                } else {
                    sortedList.add(insertIndex, sqr);
                }
            }
            Map<String, List<SurveyQuestionResponse>> sqrMap = new Map<String, List<SurveyQuestionResponse>>();

            for (SurveyQuestionResponse sqr : sortedList) {
                if (!sqrMap.containsKey(sqr.InvitationId)) {
                    sqrMap.put(sqr.InvitationId, new List<SurveyQuestionResponse>());
                }
                sqrMap.get(sqr.InvitationId).add(sqr);
            }

            if(hcType == 'Survey' || hcType == '설문') {
                List<SurveyQuestion> sqList = getSurveyQuestion(recordId);
                List<CampaignTarget__c> updateList = new List<CampaignTarget__c>();
                for(CampaignTarget__c ct : targetList) {
                    System.debug('targetList ::' + targetList);
                    Datetime registerHappyCall = Datetime.valueOf(ct.CreatedDate);
                    String formatRegisterHappyCall = registerHappyCall.format('yyyy-MM-dd HH:mm:ss');
                    List<SurveyQuestionResponse> sqrs = sqrMap.get(ct.SurveyInvitation__c);
    
                    String formatSqrCreatedDate = '';
                    if(sqrs != null) {
                        Datetime sqrCreatedDate = Datetime.valueOf(sqrs[0].CreatedDate);
                        formatSqrCreatedDate = sqrCreatedDate.format('yyyy-MM-dd HH:mm:ss');
                    } else {
                        formatSqrCreatedDate = '';
                    }
    
                    // Score 
                    Decimal scoreIndex = 0;
                    List<String> responseValue = new List<String>();
                    if (sqrs != null) {
                        for (SurveyQuestionResponse sqr : sqrs) {
                            if (String.isBlank(sqr.QuestionChoiceId)) {
                                continue;
                            }
                            System.debug('score =>');
                            if (sqr.ResponseValue == '매우만족') {
                                scoreIndex += 100;
                            } else if (sqr.ResponseValue == '만족') {
                                scoreIndex += 80;
                            } else if (sqr.ResponseValue == '보통') {
                                scoreIndex += 60;
                            } else if (sqr.ResponseValue == '불만족') {
                                scoreIndex += 40;
                            } else {
                                System.debug('No Score');
                            }
                        }
                    } else {
                        scoreIndex = null;
                    }
                    
                    System.debug('scoreIndex =>' + scoreIndex);
                    CampaignTargetWrapper ctw = new CampaignTargetWrapper();
                    ctw.CreateDate            = formatRegisterHappyCall;
                    ctw.AccountId             = ct.Ticket__r.AccountId;
                    ctw.AccountName           = ct.AccountName__c;
                    ctw.CustomerName          = ct.Ticket__r.Requester__r.Name;
                    ctw.PhoneNumber           = ct.Ticket__r.Requester__r.MobilePhone;
                    ctw.Address               = ct.Ticket__r.Account.FM_Address__c;
                    ctw.TicketId              = ct.Ticket__r.Id;
                    ctw.SerialNumber          = ct.FM_Equipment__c;
                    ctw.Ticket                = ct.Ticket__r.CaseNumber;
                    ctw.InstallDate           = ct.Ticket__r.Asset.InstallationFinish__c;
                    ctw.Guarantee             = ct.Ticket__r.FM_EquipmentWarranty__c;
                    ctw.Model                 = ct.Ticket__r.Asset.MachineName__c;
                    ctw.IsMigration           = False;
                    ctw.CompletedDate         = (ct.Ticket__r.ClosedDate != null) ? ct.Ticket__r.ClosedDate.format('yyyy-MM-dd HH:mm:ss') : '';
                    
                    if (firstWorkOrder.containsKey(ct.Ticket__r.Id)) {
                        WorkOrder wo = firstWorkOrder.get(ct.Ticket__r.Id);
                        ctw.WorkCenter    = (wo.ServiceTerritory != null && wo.ServiceTerritory.Name != null) ? wo.ServiceTerritory.Name : '';
                        ctw.ServiceMan    = (wo.Worker__r != null && wo.Worker__r.Name != null) ? wo.Worker__r.Name : '';
                        ctw.InspectionDetails = (wo.RepairAction__c != null) ? wo.RepairAction__c : '';           
                        ctw.ServiceOrderId        = (wo.Id != null) ? wo.Id : '';
                        ctw.ServiceOrderNo        = (wo.ServiceOrderNumber__c != null) ? wo.ServiceOrderNumber__c : '';         
                    } else {
                        ctw.WorkCenter    = '';
                        ctw.ServiceMan    = '';
                        ctw.InspectionDetails = '';
                    }
                    
                    ctw.ManagerId             = ct.Manager__r.Id;
                    ctw.Manager               = ct.Manager__r.Name;
                    ctw.Score                 = ct.Score__c; // A : 100, B : 80, C : 60, D : 40
                    ctw.AdjustScore           = ct.AdjustScore__c; // A : 100, B : 80, C : 60, D : 40
                    ctw.FirstSend             = ct.AlarmTalkFirstSend__c;
                    ctw.FirstSendTime         = ct.FirstSendTime__c;
                    ctw.AlamTalkSendCount     = ct.AlamSendCount__c;
                    ctw.SurveyStatus          = ct.Status__c;
                    ctw.SurveyCompletedDate   = formatSqrCreatedDate;
                    ctw.Memo                  = ct.Memo__c;
                    ctw.Id                    = ct.Id;
                    ctw.Name                  = ct.Name;
                    ctw.SurveyURL             = ct.SurveyURL__c;
                    ctw.SurveyResult          = ct.SurveyResult__c;
                    ctw.ResultValue           = new List<String>();
                    if (sqrs != null) {
                        for (SurveyQuestionResponse sqr : sqrs) {
                            ctw.ResultValue.add(sqr.ResponseValue);
                        }
                    } else {
                        for(SurveyQuestion sq : sqList) {
                            ctw.ResultValue.add('');
                        }
                    }
    
                    ct.SurveyCompletedDate__c = sqrs != null ? sqrs[0].CreatedDate : null;
                    ct.Score__c           = scoreIndex;
                    updateList.add(ct);
                    ctWrappers.add(ctw);
                    System.debug('ctwResultValue'+ctw.ResultValue);
                }
                System.debug('ctWrappers'+ctWrappers);
                System.debug('updateList =>' + updateList);
                if(updateList.size() > 0) update updateList;

            } else {
                List<CampaignTarget__c> updateList = new List<CampaignTarget__c>();
                for(CampaignTarget__c ct : targetList) {
                    Datetime registerHappyCall = Datetime.valueOf(ct.CreatedDate);
                    String formatRegisterHappyCall = registerHappyCall.format('yyyy-MM-dd HH:mm:ss');
            
                    CampaignTargetWrapper ctw = new CampaignTargetWrapper();
                    ctw.CreateDate            = formatRegisterHappyCall;
                    ctw.AccountId             = ct.Ticket__r.AccountId;
                    ctw.AccountName           = ct.AccountName__c;
                    ctw.CustomerName          = ct.Ticket__r.Requester__r.Name;
                    ctw.PhoneNumber           = ct.Ticket__r.Requester__r.MobilePhone;
                    ctw.Address               = ct.Ticket__r.Account.FM_Address__c;
                    ctw.TicketId              = ct.Ticket__r.Id;
                    ctw.Ticket                = ct.Ticket__r.CaseNumber;
                    ctw.SerialNumber          = ct.FM_Equipment__c;
                    ctw.InstallDate           = ct.Ticket__r.Asset.InstallationFinish__c;
                    ctw.Guarantee             = ct.Ticket__r.FM_EquipmentWarranty__c;
                    ctw.Model                 = ct.Ticket__r.Asset.MachineName__c;
                    ctw.IsMigration           = False;
                    ctw.CompletedDate         = (ct.Ticket__r.ClosedDate != null) ? ct.Ticket__r.ClosedDate.format('yyyy-MM-dd HH:mm:ss') : '';

                    if (firstWorkOrder.containsKey(ct.Ticket__r.Id)) {
                        WorkOrder wo = firstWorkOrder.get(ct.Ticket__r.Id);
                        ctw.WorkCenter    = (wo.ServiceTerritory != null && wo.ServiceTerritory.Name != null) ? wo.ServiceTerritory.Name : '';
                        ctw.ServiceMan    = (wo.Worker__r != null && wo.Worker__r.Name != null) ? wo.Worker__r.Name : '';
                        ctw.InspectionDetails = (wo.RepairAction__c != null) ? wo.RepairAction__c : '';           
                        ctw.ServiceOrderId        = (wo.Id != null) ? wo.Id : '';
                        ctw.ServiceOrderNo        = (wo.ServiceOrderNumber__c != null) ? wo.ServiceOrderNumber__c : '';           
                    } else {
                        ctw.WorkCenter    = '';
                        ctw.ServiceMan    = '';
                        ctw.InspectionDetails = '';
                    }
                    
                    ctw.ManagerId             = ct.Manager__r.Id;
                    ctw.Manager               = ct.Manager__r.Name;
                    ctw.Memo                  = ct.Memo__c;
                    ctw.Id                    = ct.Id;
                    ctw.Name                  = ct.Name;
                    ctw.SurveyResult          = ct.SurveyResult__c;
                    ctWrappers.add(ctw);
                }
                System.debug('ctWrappers'+ctWrappers);
            }
        }

        // List<CampaignTargetWrapper> ctWrapper   = getCampaignTarget(recordId, hcType);
        // MergeWrapper mergeWrapper = new MergeWrapper();
        // mergeWrapper.campaignTargetWrapper   = ctWrapper;

        return ctWrappers;
    }

    /*
     * @Description 
     * - Happy Call Campaign Target 반환 Wrapper
     */ 
    @AuraEnabled
    public static List<MergeWrapper> getHappyCallResult(Id recordId){
        List<MergeWrapper> mergeWrappers = new List<MergeWrapper>();
        Campaign cp = [SELECT Id, Name, HappyCallType__c, IsMigration__c FROM Campaign WHERE Id =: recordId];
        List<CampaignTarget__c> campaignT = [SELECT Id, Campaign__c, RegisterDate__c FROM CampaignTarget__c WHERE Campaign__c =: recordId];
        String hcType = cp.HappyCallType__c;
        try {
            MergeWrapper mergeWrapper = new MergeWrapper();
            if(cp.HappyCallType__c == 'Survey' || cp.HappyCallType__c == '설문') {
                List<HeaderWrapper> hwWrapper   = getHeaderWrapper(recordId);
                String surveyName               = getSurveyName(recordId);
                mergeWrapper.headerWrapper      = hwWrapper;
                mergeWrapper.surveyName         = surveyName;
                mergeWrapper.campaignName       = cp.Name;

                if(campaignT.size() < 1) {
                    mergeWrapper.noExist    = true;
                }

            }
            mergeWrappers.add(mergeWrapper);
            return mergeWrappers;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
     * @Description 
     * - 질문지 헤더 반환 Wrapper
     */ 
    @AuraEnabled
    public static List<HeaderWrapper> getHeaderWrapper(Id recordId){
        List<HeaderWrapper> hWrappers = new List<HeaderWrapper>();
        List<SurveyQuestion> sqList = getSurveyQuestion(recordId);
        List<String> sqName = new List<String>();
        for(SurveyQuestion sq : sqList) {
            sqName.add(sq.QuestionName);
        }
        System.debug('sqName' + sqName);
        for(String Name : sqName) {
            HeaderWrapper hw = new HeaderWrapper();
            hw.label = Name;
            hWrappers.add(hw);
        }
        return hWrappers;
    }

    /*
     * @Description
     * 	- 해피콜 Campaign 내 Campaign Target Data 출력
     * 
     */
    @AuraEnabled
    public static void updateSurveyResult(List<CampaignTarget__c> resultUpdate){
        System.debug('resultUpdate'+resultUpdate);
        try {
            update resultUpdate;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    /*
     * @Description
     * 	- 해피콜 Alarm Talk 발송
     */
    @AuraEnabled
    public static ResultWrapper sendAlarmTalk(List<CampaignTargetWrapper> selectedCampaignTarget, String recordId){
        System.debug('selectedCampaignTarget'+selectedCampaignTarget);
        ResultWrapper rw = new ResultWrapper();
        List<UTIL_Alert.historyWrapper> wrappers   = new List<UTIL_Alert.historyWrapper>();
        try {
            String alertManagerID = getAlertID(recordId);
            for(CampaignTargetWrapper ctw : selectedCampaignTarget) {
                UTIL_Alert.historyWrapper wrapper   = new UTIL_Alert.historyWrapper();
                wrapper.alertID            = alertManagerID;
                wrapper.targetID           = ctw.TicketId;
                wrapper.alertType          = 'AlarmTalk';
                wrapper.receiverforPhone   = new Set<String>{ctw.PhoneNumber};
                wrapper.alertLanguage      = 'ko';
                wrappers.add(wrapper);
            }
            UTIL_Alert.runAlertEvent(wrappers);
            rw = updateSendStatus(selectedCampaignTarget);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return rw;
    }

    /*
     * @Description
     * 	- 해피콜 재전송 클릭
     * 
     */
    @AuraEnabled
    public static ResultWrapper reSendAlarmTalk(String ticketId, String phone, String recordId, String ctId, String requester, String surveyURL, Boolean firstSend){
        System.debug('phone'+phone);
        System.debug('recordId'+recordId);
        System.debug('ctId'+ctId);
        System.debug('requester'+requester);
        System.debug('surveyURL'+surveyURL);
        System.debug('firstSend'+firstSend);
        ResultWrapper rw = new ResultWrapper();
        List<UTIL_Alert.historyWrapper> wrappers   = new List<UTIL_Alert.historyWrapper>();
        try {
            String subUrl = surveyURL.replace('https://', '');
            Map<String, String> alarmMap = new Map<String, String>();
            alarmMap.put('clnt_nm', requester);
            alarmMap.put('url', subUrl);
            String alertManagerID = getAlertID(recordId);

            UTIL_Alert.historyWrapper wrapper   = new UTIL_Alert.historyWrapper();
            wrapper.alertID            = alertManagerID;
            wrapper.targetID           = ticketId;
            wrapper.alertType          = 'AlarmTalk';
            wrapper.receiverforPhone   = new Set<String>{phone};
            wrapper.alertLanguage      = 'ko';
            wrapper.elementMap         = alarmMap;
            System.debug('wrapper'+ wrapper);
            wrappers.add(wrapper);
            UTIL_Alert.runAlertEvent(wrappers);

            CampaignTarget__c ct = 
            [
                SELECT Id, AlarmTalkFirstSend__c, AlamSendCount__c, FirstSendTime__c
                FROM CampaignTarget__c
                WHERE Id =: ctId
                LIMIT 1
            ];

            if (ct != null) {
                if(firstSend == false){
                    Datetime firstSendTime       = Datetime.valueOf(System.now());
                    String formatFirstSendTime   = firstSendTime.format('yyyy-MM-dd HH:mm:ss');
                    ct.AlarmTalkFirstSend__c = true;
                    ct.FirstSendTime__c = formatFirstSendTime;
                } else {
                    ct.AlamSendCount__c = (ct.AlamSendCount__c == null) ? 1 : ct.AlamSendCount__c + 1;
                }
            }
             
            update ct;

        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return rw;
    }

    /*
     * @Description
     * 	- get CampaignMaster_AlertManager
     * 
     * @Parameter
     *  - recordId	    : Campaign ID
     * 
     * @Author
     *  - Junyeong, Choi, 2024-11-05
     */
    @AuraEnabled
    public static String getAlertID(String recordId){
        Campaign cp = [
            SELECT Id, CampaignMaster__c
            FROM Campaign
            WHERE Id =: recordId
        ];

        String alertID = [
            SELECT Id, AlertManager__c
            FROM CampaignMaster__c
            WHERE Id =: cp.CampaignMaster__c
        ].AlertManager__c;
        
        return alertID;
    }

    /*
     * @Description
     * 	- 알람톡 수동 전송 후 CampaignTarget Data Update
     */
    @AuraEnabled
    public static ResultWrapper updateSendStatus(List<CampaignTargetWrapper> selectedCampaignTarget){
        ResultWrapper rw = new ResultWrapper();
        List<CampaignTarget__c> ctwList = new List<CampaignTarget__c>();
        try {
            for (CampaignTargetWrapper ctw : selectedCampaignTarget) {                
                System.debug('updateSendStatus'+selectedCampaignTarget);
                CampaignTarget__c targetRecord = new CampaignTarget__c(
                    Id = ctw.Id,
                    AlamTalkSend__c = true,
                    AlamSendCount__c = ctw.AlamTalkSendCount + 1
                );
                ctwList.add(targetRecord);
            }
            System.debug('ctwList'+ctwList);
            if (!ctwList.isEmpty()) {
                update ctwList;
            }

        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return rw;
    }

    /*
     * @Description
     * 	- CampaignTarget Memo Update
     */
    @AuraEnabled
    public static ResultWrapper updateMemo(String memo, Id ctId){
        ResultWrapper rw = new ResultWrapper();
        CampaignTarget__c ct = [
            SELECT Memo__c, Id
            FROM CampaignTarget__c
            WHERE Id =: ctId
        ];
        try {
            if (ct != null) {
                ct.Memo__c = memo;
                update ct;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return rw;
    }

    /*
     * @Description
     * 	- 설문 질문 Data 조회
     */
    @AuraEnabled
    public static List<SurveyQuestion> getSurveyQuestion(Id recordId){
        Campaign cp = 
        [
            SELECT Id, CampaignMaster__c 
            FROM Campaign 
            WHERE Id = :recordId
        ];
        CampaignMaster__c cm = 
            [
                SELECT Id, Survey__c 
                FROM CampaignMaster__c 
                WHERE Id = :cp.CampaignMaster__c
            ];
        
        List<SurveyQuestion> sqList = new List<SurveyQuestion>();
        if(!Test.isRunningTest()) {
            Survey sv = 
            [
                SELECT Id, Name, ActiveVersionId, LatestVersionId 
                FROM Survey 
                WHERE Id = :cm.Survey__c
            ];
            SurveyVersion version = 
            [
                SELECT Id, SurveyStatus, SurveyId
                FROM SurveyVersion 
                WHERE SurveyStatus = : 'Active'
                AND SurveyId = :sv.Id
                LIMIT 1
            ];
            sqList = [
                    SELECT Id, QuestionName, QuestionOrder, PageName, Name
                    FROM SurveyQuestion
                    WHERE SurveyVersionId = :version.Id
                    ORDER BY QuestionOrder ASC
                ];
            System.debug('sqList' + sqList);
            return sqList;
        } else {
            return sqList;
        }
    }

    /*
     * @Description
     * 	- 설문지 이름 조회
     */
    @AuraEnabled
    public static string getSurveyName(String recordId){
        try {
            Campaign cp = 
            [
                SELECT Id, CampaignMaster__c 
                FROM Campaign 
                WHERE Id = :recordId
                LIMIT 1
            ];

            CampaignMaster__c cm = 
            [
                SELECT Id, Survey__r.Name
                FROM CampaignMaster__c 
                WHERE Id = :cp.CampaignMaster__c
                LIMIT 1
            ];

            return cm.Survey__r.Name;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
     * @Description
     * 	- 일반 설문 점수 저장
     */
    @AuraEnabled
    public static ResultWrapper saveSurveyScore(Id recordId, Decimal score){
        ResultWrapper rw = new ResultWrapper();
        CampaignTarget__c ct = [
            SELECT AdjustScore__c, Id
            FROM CampaignTarget__c
            WHERE Id =: recordId
        ];
        if (ct != null) {
            ct.AdjustScore__c = score;
            update ct;
        }
        return rw;
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
        @AuraEnabled public Boolean isSuccess  { get; set;}
        @AuraEnabled public String  errMessage { get; set;}
        
        public ResultWrapper(){
            this.isSuccess = true;
        }
    }

    /*
     * @Description 
     *  - CampaignTarget List Wrapper
     * 
     * @Variable 
     *  - isSuccess 	: 성공 여부
     *  - errMessage 	: 실패 시 에러메세지 
     */ 
    public class CampaignTargetWrapper{
        @AuraEnabled public String Id                       { get; set;}    // Id
        @AuraEnabled public String Name                     { get; set;}    // 이름
        @AuraEnabled public String CreateDate               { get; set;}    // 해피콜등록일시
        @AuraEnabled public String AccountName              { get; set;}    // 업체명
        @AuraEnabled public String CustomerName             { get; set;}    // 고객명
        @AuraEnabled public String PhoneNumber              { get; set;}    // 연락처
        @AuraEnabled public String PhoneCall                { get; set;}    // 전화걸기
        @AuraEnabled public String Address                  { get; set;}    // 주소
        @AuraEnabled public String Ticket                   { get; set;}    // 오더번호(티켓)
        @AuraEnabled public String EquipmentNumber          { get; set;}    // 제조번호
        @AuraEnabled public Date InstallDate                { get; set;}    // 설치완료일자
        @AuraEnabled public String Guarantee                { get; set;}    // 장비보증
        @AuraEnabled public String Model                    { get; set;}    // 기종

        @AuraEnabled public String WorkCenter               { get; set;}    // 소속
        @AuraEnabled public String ServiceMan               { get; set;}    // 서비스요원
        @AuraEnabled public String CompletedDate            { get; set;}    // 서비스완료일시
        @AuraEnabled public String Manager                  { get; set;}    // 상담원
        @AuraEnabled public String InspectionDetails        { get; set;}    // 조치내역
        @AuraEnabled public Decimal Score                   { get; set;}    // 점수
        @AuraEnabled public Decimal AdjustScore             { get; set;}    // 점수
        @AuraEnabled public Boolean FirstSend               { get; set;}    // 1차전송
        @AuraEnabled public String FirstSendTime            { get; set;}    // 1차전송일시
        @AuraEnabled public Boolean SecondSend              { get; set;}    // 2차전송
        @AuraEnabled public Datetime SecondSendTime         { get; set;}    // 2차전송일시
        @AuraEnabled public Decimal AlamTalkSendCount       { get; set;}    // 전송횟수
        @AuraEnabled public String SurveyStatus             { get; set;}    // 설문상태
        @AuraEnabled public String SurveyCompletedDate      { get; set;}    // 설문완료일시
        @AuraEnabled public String Memo                     { get; set;}    // 메모
        @AuraEnabled public List<String> ResultValue        { get; set;}    // type 1
        @AuraEnabled public String ListSequence             { get; set;}    // ListSequence
        // @AuraEnabled public Map<String, List<String>> ctMap { get; set;}    // type 2
        @AuraEnabled public List<String> responseList       { get; set;}    // List
        @AuraEnabled public Date registerDate               { get; set;}
        @AuraEnabled public String TicketId                 { get; set;}
        @AuraEnabled public Boolean IsMigration             { get; set;}

        @AuraEnabled public String EquipmentId              { get; set;}
        @AuraEnabled public String SerialNumber             { get; set;}
        @AuraEnabled public String AccountId                { get; set;}
        @AuraEnabled public String ManagerId                { get; set;}
        @AuraEnabled public String SurveyURL                { get; set;}    // SurveyURL
        @AuraEnabled public String SurveyResult             { get; set;}    // SurveyResult
        @AuraEnabled public String ServiceOrderId           { get; set;}    // ServiceOrder Id
        @AuraEnabled public String ServiceOrderNo           { get; set;}    // ServiceOrder Number


        public CampaignTargetWrapper(){
            this.IsMigration           = False;
            this.Id                    = '';
            this.Name                  = '';
            this.CreateDate            = '';
            this.AccountName           = '';
            this.CustomerName          = '';
            this.PhoneNumber           = '';
            this.PhoneCall             = '';
            this.Address               = '';
            this.Ticket                = '';
            this.EquipmentNumber       = '';
            this.InstallDate           = null;
            this.Guarantee             = '';
            this.Model                 = '';
            this.WorkCenter            = '';
            this.ServiceMan            = '';
            this.CompletedDate         = '';
            this.Manager               = '';
            this.InspectionDetails     = '';
            this.Score                 = null;
            this.AdjustScore           = null;
            this.FirstSend             = null;
            this.FirstSendTime         = '';
            this.SecondSend            = null;
            this.SecondSendTime        = null;
            this.AlamTalkSendCount     = 0;
            this.SurveyStatus          = '';
            this.SurveyCompletedDate   = '';
            this.Memo                  = '';
            this.TicketId              = '';
            this.EquipmentId           = '';
            this.SerialNumber          = '';
            this.AccountId             = '';
            this.SurveyURL             = '';
            this.SurveyResult          = '';
            this.ResultValue           = null;
            // this.ctMap                 = null;
            this.ListSequence          = '';
            this.responseList          = null;
            this.registerDate          = null;
            this.ServiceOrderId        = '';
            this.ServiceOrderNo        = '';
        }
    }

    /*
     * @Description 
     *  - Survey Question Header
     */ 
    public class HeaderWrapper{
        @AuraEnabled public String label { get; set;}
        @AuraEnabled public String value { get; set;}

        public HeaderWrapper(){
            this.label = null;
            this.value = '';
        }
    }

    public class MergeWrapper{
        @AuraEnabled public List<Object> headerWrapper         { get; set;}
        @AuraEnabled public List<Object> campaignTargetWrapper { get; set;}
        @AuraEnabled public String surveyName                  { get; set;}
        @AuraEnabled public List<String> surveyResultValues    { get; set;}
        @AuraEnabled public Boolean noExist                    { get; set;}
        @AuraEnabled public String CampaignName                { get; set;}

        public MergeWrapper(){
            this.headerWrapper           = null;
            this.campaignTargetWrapper   = null;
            this.surveyName              = '';
            this.surveyResultValues      = null;
            this.surveyResultValues      = null;
            this.noExist                 = false;
            this.CampaignName            = '';
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
        @AuraEnabled public Boolean IsMigration    { get; set;}

        public ObjectTypeWrapper(){
            this.objType       = '';
            this.happyCallType = '';
            this.IsMigration = False;
        }
    }
}