/**
 * @author            : Yeong-Deok Seo
 * @Description       : 알림톡접수분석 Report 화면
 * @last modified on  : 2025-09-02
 * @last modified by  : yeongdeok.seo@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-31   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_AlarmTalkRequestAnalysisController {

    //조건에 부합하는 알림톡접수분석 DATA 반환
    @AuraEnabled
    public static List<AlarmTalkRequestWrapper> getData(datetime dateTo, datetime dateFrom){
        List<AlarmTalkRequestWrapper> res = new List<AlarmTalkRequestWrapper>();

        //접수일자 기준으로 데이터 출력 by Hayeong Min 250422 
        Datetime fromDate = Datetime.newInstance(dateFrom.year(), dateFrom.month(), dateFrom.day(), 0, 0, 0);
        Datetime toDate = Datetime.newInstance(dateTo.year(), dateTo.month(), dateTo.day(), 23, 59, 59);
        System.debug('fromDate ::: '+ fromDate);
        System.debug('toDate ::: '+ toDate);
        List<WorkOrder> woList = [SELECT Id, ServiceTerritory.ControlWorkcenter__c, ServiceTerritory.ControlWorkcenter__r.Name, 
                                        ServiceTerritory.Name, Case.ReceptionPath__c, Case.ApplicationDateTime__c
                                  FROM WorkOrder
                                  WHERE FM_ApplicationDateTime__c <=: toDate AND FM_ApplicationDateTime__c >=: fromDate AND FM_ApplicationDateTime__c != null
                                  AND ServiceTerritoryId != ''
                                  AND Case.ReceptionPath__c IN ('Call Center(VOC)', 'Call Center(Representative)', 'Alarm Talk')
                                  ORDER BY ServiceTerritory.ControlWorkcenter__r.Name, ServiceTerritory.Name];
        System.debug('woList ::: '+ woList);
        Map<String, AlarmTalkRequestWrapper> wcMap = new Map<String, AlarmTalkRequestWrapper>();
        Time targetTime = Time.newInstance(17, 30, 0, 0); // 17:30
        for(WorkOrder w : woList){
            String workCenterId = w.ServiceTerritoryId;
            if(!wcMap.containsKey(workCenterId)){
                AlarmTalkRequestWrapper at = new AlarmTalkRequestWrapper(); 
                at.Id = w.Id;
                at.ServiceCenterId = w.ServiceTerritoryId;
                at.Branch = w.ServiceTerritory.ControlWorkcenter__r?.Name;
                at.ServiceCenter = w.ServiceTerritory.Name;
                at.OrderCount = 1;
                if(w.Case.ReceptionPath__c == 'Alarm Talk'){
                    at.AlarmTalkOrders = 1;
                } else {
                    at.CallCenterOrders = 1;
                }

                if(w.Case.ApplicationDateTime__c.time() > targetTime) {
                    at.NightAlarmTalk = 1;
                }
                wcMap.put(workCenterId, at);
            } else {
                AlarmTalkRequestWrapper existingWrapper = wcMap.get(workCenterId);
                existingWrapper.OrderCount = existingWrapper.OrderCount + 1;
                if(w.Case.ReceptionPath__c=='Alarm Talk'){
                    existingWrapper.AlarmTalkOrders += 1;
                } else {
                    existingWrapper.CallCenterOrders += 1;
                }
                if(w.Case.ApplicationDateTime__c.time() > targetTime) {
                    existingWrapper.NightAlarmTalk += 1;
                }
            }
        }

        Integer totalOrderCount = 0;
        Integer totalCallCenterOrders = 0;
        Integer totalAlarmTalkOrders = 0;
        Integer totalNightAlarmTalk = 0;
        
        for(AlarmTalkRequestWrapper wrapper : wcMap.values()){
            if(wrapper.OrderCount > 0) {
                Decimal responseRate = (wrapper.AlarmTalkOrders / (Decimal)wrapper.OrderCount) * 100;
                wrapper.AlarmTalkResponseRate = responseRate.setScale(1, RoundingMode.HALF_UP);  // 소수 첫째자리로 반올림
            }

            //합계 계산
            totalOrderCount += wrapper.OrderCount;
            totalCallCenterOrders += wrapper.CallCenterOrders;
            totalAlarmTalkOrders += wrapper.AlarmTalkOrders;
            totalNightAlarmTalk += wrapper.NightAlarmTalk;
        }

        AlarmTalkRequestWrapper totalWrapper = new AlarmTalkRequestWrapper();
        totalWrapper.Id = '합계';
        totalWrapper.ServiceCenterId = '합계';
        totalWrapper.Branch = '합계';
        totalWrapper.ServiceCenter = '합계';
        totalWrapper.OrderCount = totalOrderCount;
        totalWrapper.CallCenterOrders = totalCallCenterOrders;
        totalWrapper.AlarmTalkOrders = totalAlarmTalkOrders;
        totalWrapper.NightAlarmTalk = totalNightAlarmTalk;
        if(totalOrderCount > 0) {
            totalWrapper.AlarmTalkResponseRate = (totalAlarmTalkOrders / (Decimal)totalOrderCount) * 100;
            totalWrapper.AlarmTalkResponseRate = totalWrapper.AlarmTalkResponseRate.setScale(1, RoundingMode.HALF_UP);  // 소수 첫째자리로 반올림
        }

        res.add(totalWrapper); //합계 ROW가 1번
        res.addAll(wcMap.values());
        return res;
    }

    //조건에 부합하는 알림톡접수분석 상세 DATA 반환
    @AuraEnabled
    public static List<AlarmTalkDetailtWrapper> getDetailData(String type, String serviceCenterId, datetime dateTo, datetime dateFrom){
        List<AlarmTalkDetailtWrapper> res = new List<AlarmTalkDetailtWrapper>();

        Datetime fromDate = Datetime.newInstance(dateFrom.year(), dateFrom.month(), dateFrom.day(), 0, 0, 0);
        Datetime toDate = Datetime.newInstance(dateTo.year(), dateTo.month(), dateTo.day(), 23, 59, 59);

        List<String> receiptPath = new List<String>();
        switch on type {
            when 'OrderCount' {
                receiptPath.add('Call Center(VOC)');
                receiptPath.add('Call Center(Representative)');
                receiptPath.add('Alarm Talk');
            }
            when 'CallCenterOrders' {
                receiptPath.add('Call Center(VOC)');
                receiptPath.add('Call Center(Representative)');
            }
            when 'AlarmTalkOrders' {
                receiptPath.add('Alarm Talk');
            }
        }

        List<WorkOrder> woList = new List<WorkOrder>();
        if(serviceCenterId == '합계'){
            woList = [SELECT Id, ServiceTerritory.ControlWorkcenter__r.Name, ServiceTerritory.Name, Case.CaseNumber, Case.ApplicationDateTime__c,
                            Case.Account.Name, Case.Requester__r.Name, Case.ReceptionDetails__c, Case.FileCount__c,  Case.Owner.Name,
                            FM_MachineName__c, Asset.Name, ServiceOrderNumber__c, Worker__r.name, Worker__r.PhoneNumber__c, Worker__r.AD_ID__c
                     FROM WorkOrder
                     WHERE ServiceTerritoryId != ''
                     AND Case.ReceptionPath__c IN: receiptPath
                     AND FM_ApplicationDateTime__c <=: toDate AND FM_ApplicationDateTime__c >=: fromDate
                     AND case.ApplicationDateTime__c != null
                     ORDER BY ServiceOrderNumber__c];
        } else {
            woList = [SELECT Id, ServiceTerritory.ControlWorkcenter__r.Name, ServiceTerritory.Name, Case.CaseNumber, Case.ApplicationDateTime__c,
                             Case.Account.Name, Case.Requester__r.Name, Case.ReceptionDetails__c, Case.FileCount__c,  Case.Owner.Name,
                             FM_MachineName__c, Asset.Name, ServiceOrderNumber__c, Worker__r.name, Worker__r.PhoneNumber__c, Worker__r.AD_ID__c
                      FROM WorkOrder
                      WHERE ServiceTerritoryId =: serviceCenterId
                      AND Case.ReceptionPath__c IN: receiptPath
                      AND FM_ApplicationDateTime__c <=: toDate AND FM_ApplicationDateTime__c >=: fromDate
                      AND case.ApplicationDateTime__c != null
                      ORDER BY ServiceOrderNumber__c];
        }

        Time targetTime = Time.newInstance(17, 30, 0, 0); // 17:30
        for(WorkOrder w : woList){
            AlarmTalkDetailtWrapper a = new AlarmTalkDetailtWrapper();
            a.Id = w.Id;
            a.Branch = w.ServiceTerritory.ControlWorkcenter__r.Name;
            a.CaseNumber = w.Case.CaseNumber;
            a.OrderNumber = w.ServiceOrderNumber__c;
            a.Model = w.FM_MachineName__c;
            a.SerialNumber = w.Asset.Name;
            a.ReceivedDate = w.case.ApplicationDateTime__c.date();
            a.ReceivedTime = formatTime(w.case.ApplicationDateTime__c);//w.case.ApplicationDateTime__c.Time();
            a.NightShift = w.Case.ApplicationDateTime__c.time() > targetTime?'Y':'';
            a.Agent = w.case.Owner.Name;
            String serviceUserADID = w.Worker__r.AD_ID__c==null?'':w.Worker__r.AD_ID__c;
            a.ServiceTechnician = serviceUserADID +' '+ w.Worker__r.name;
            a.PhoneNumber = w.Worker__r.PhoneNumber__c;
            a.RepairCenter = w.ServiceTerritory.Name;
            a.RequestingCompany = w.case.Account.Name;
            a.Requester = w.case.Requester__r.Name;
            a.RequestDetails = w.case.ReceptionDetails__c;
            a.FileAvailable = w.case.FileCount__c!=0?'Y':'';
            res.add(a);    
        }
        
        return res;
    }

    //DateTime의 DATA String 형태로 Formatting
    public static String formatTime(DateTime inputDateTime) {
        if (inputDateTime == null) {
            return '';
        }
        
        Integer hours = inputDateTime.hour();
        Integer minutes = inputDateTime.minute();
        Integer seconds = inputDateTime.second();

        // 두 자릿수로 맞추기
        String formattedHours = (hours < 10) ? '0' + String.valueOf(hours) : String.valueOf(hours);
        String formattedMinutes = (minutes < 10) ? '0' + String.valueOf(minutes) : String.valueOf(minutes);
        String formattedSeconds = (seconds < 10) ? '0' + String.valueOf(seconds) : String.valueOf(seconds);

        return formattedHours + ':' + formattedMinutes + ':' + formattedSeconds;
    }

    //알림톡접수분석 DATA Mapping Wrapper
    public class AlarmTalkRequestWrapper{
        @AuraEnabled public String Id                     { get; set; } 
        @AuraEnabled public String ServiceCenterId        { get; set; } // 정비센터 ID (상세보기)
        @AuraEnabled public String Branch                 { get; set; } // 관할지사
        @AuraEnabled public String ServiceCenter          { get; set; } // 정비센터
        @AuraEnabled public Integer OrderCount            { get; set; } // 오더건수
        @AuraEnabled public Integer CallCenterOrders      { get; set; } // 콜센터오더
        @AuraEnabled public Integer AlarmTalkOrders       { get; set; } // 알림톡오더
        @AuraEnabled public Integer NightAlarmTalk        { get; set; } // 야간알림톡(17:30이후)
        @AuraEnabled public Decimal AlarmTalkResponseRate { get; set; } // 알림톡접수율(%)

        public AlarmTalkRequestWrapper(){
            Id = '';
            ServiceCenterId = '';
            Branch = '';
            ServiceCenter = '';
            OrderCount = 0;
            CallCenterOrders = 0;
            AlarmTalkOrders = 0;
            NightAlarmTalk = 0;
            AlarmTalkResponseRate = 0;
        }
    }
    
    //알림톡접수분석 상세 DATA Mapping Wrapper
    public class AlarmTalkDetailtWrapper{
        @AuraEnabled public String Id                { get; set; } 
        @AuraEnabled public String Branch            { get; set; } // 관할지사
        @AuraEnabled public String CaseNumber        { get; set; } // 접수번호
        @AuraEnabled public String OrderNumber       { get; set; } // 오더번호
        @AuraEnabled public String Model             { get; set; } // 기종
        @AuraEnabled public String SerialNumber      { get; set; } // 제조번호
        @AuraEnabled public Date ReceivedDate        { get; set; } // 접수일
        @AuraEnabled public String ReceivedTime      { get; set; } // 시간
        @AuraEnabled public String NightShift        { get; set; } // 야간
        @AuraEnabled public String Agent             { get; set; } // 상담원
        @AuraEnabled public String ServiceTechnician { get; set; } // 서비스맨
        @AuraEnabled public String PhoneNumber       { get; set; } // 전화번호
        @AuraEnabled public String RepairCenter      { get; set; } // 정비센터
        @AuraEnabled public String RequestingCompany { get; set; } // 요청업체
        @AuraEnabled public String Requester         { get; set; } // 요청자
        @AuraEnabled public String IntakeChannel     { get; set; } // 접수채널
        @AuraEnabled public String RequestDetails    { get; set; } // 요청내용
        @AuraEnabled public String FileAvailable     { get; set; } // 파일여부
    }
}