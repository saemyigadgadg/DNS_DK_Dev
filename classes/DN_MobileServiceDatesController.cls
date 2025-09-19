/*
* @Class    : DN_MobileServiceDatesController
* @Author   : SungHeum, Yeon
* @Date     : 2025. 03. 27.
* @Version  : 1.0
* @Modified :
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description
*  ----------------------------------------------
*  1. | 2025-03-27 | SungHeum, Yeon | DNSA FSL APP 전용 기능 포탈 DN_serviceReportEntry 참고해서 만듦, LWC dN_MobileServiceDatesAndTimes, dN_MobilePartsUsed
*/
public without sharing class DN_MobileServiceDatesController {

    /*
     * description : Service Order => Service Dates and Times 버튼 클릭 시 'WH'에 대한 WorkOrderResult__c 반환
     * author      : SungHeum, Yeon
     * return      : Map<String, Object>
     * parameter
     *   	- serviceOrderId    : Service Order Id
     */
    @AuraEnabled
    public static Map<String, Object> getWorkOrderResults(String serviceOrderId) {
        Map<String, Object> response = new Map<String, Object>();
        Datetime applicationDateTime;

        try {
            List<workOrderServiceDateTimesWrapper> resultList = new List<workOrderServiceDateTimesWrapper>();
            List<WorkOrderResult__c> workOrderResultList = new List<WorkOrderResult__c>();
            if (serviceOrderId != null) {
                // WorkOrderResult__c 조회
                workOrderResultList = [SELECT Id,
                    WorkDate__c, WorkStartTime__c, WorkEndTime__c, WorkTime__c, WorkOrder__c, WorkOrder__r.FM_ApplicationDateTime__c,
                    TravelHour__c, AirTrip__c
                    FROM WorkOrderResult__c
                    WHERE WorkOrder__c = :serviceOrderId AND ResultType__c = 'WH'
                    ORDER BY CreatedDate DESC
                ];

                if (!workOrderResultList.isEmpty() && workOrderResultList[0].WorkOrder__r != null) {
                    applicationDateTime = workOrderResultList[0].WorkOrder__r.FM_ApplicationDateTime__c;
                    System.debug('test ::: ' + applicationDateTime);
                } else {
                    WorkOrder workOrder = [SELECT FM_ApplicationDateTime__c FROM WorkOrder WHERE Id = :serviceOrderId LIMIT 1];
                    applicationDateTime = workOrder.FM_ApplicationDateTime__c;
                }
            }

            if(!workOrderResultList.isEmpty()) {
                for (WorkOrderResult__c wor : workOrderResultList) {
                    workOrderServiceDateTimesWrapper wrapper = new workOrderServiceDateTimesWrapper();
                    wrapper.resultId             = wor.Id;
                    wrapper.WorkDate             = Date.valueOf(wor.WorkDate__c);
                    wrapper.WorkStartTime        = wor.WorkStartTime__c;
                    wrapper.WorkEndTime          = wor.WorkEndTime__c;
                    wrapper.WorkTime             = String.valueOf(wor.WorkTime__c);
                    wrapper.TravelHour           = String.valueOf(wor.TravelHour__c);
                    wrapper.AirTrip              = String.valueOf(wor.AirTrip__c);
                    resultList.add(wrapper);
                }
            }

            response.put('status', 'success');
            response.put('applicationDateTime', applicationDateTime);

            if (!resultList.isEmpty()) {
                response.put('workOrderResults', resultList);
            } else {
                response.put('message', 'result is Empty');
            }
        } catch (Exception e) {
            response.put('status', 'error');
            response.put('message', e.getMessage());
            response.put('lineNumber', e.getLineNumber());
            response.put('stackTrace', e.getStackTraceString());
        }
        return response;
    }

    /*
     * description : Service Order => Parts Used (Reference ONLY) 버튼 클릭 시 'PT'에 대한 WorkOrderResult__c 반환
     * author      : SungHeum, Yeon
     * return      : Map<String, Object>
     * parameter
     *   	- serviceOrderId    : Service Order Id
     */
    @AuraEnabled
    public static Map<String, Object> getWorkOrderResultParts(String serviceOrderId) {
        Map<String, Object> response = new Map<String, Object>();

        try {
            List<workOrderPartsUsedWrapper> resultList = new List<workOrderPartsUsedWrapper>();

            List<WorkOrderResult__c> workOrderResultList = [SELECT Id,
                Note__c, ProductNumber__c, ProductName__c, IsCause__c, Quantity__c
                FROM WorkOrderResult__c
                WHERE WorkOrder__c = :serviceOrderId AND ResultType__c = 'PT'
                ORDER BY CreatedDate DESC
            ];

            for (WorkOrderResult__c wor : workOrderResultList) {
                workOrderPartsUsedWrapper wrapper = new workOrderPartsUsedWrapper();
                wrapper.resultId         = wor.Id;
                wrapper.Note             = String.valueOf(wor.Note__c);
                wrapper.ProductNumber    = String.valueOf(wor.ProductNumber__c);
                wrapper.ProductName      = String.valueOf(wor.ProductName__c);
                wrapper.IsCause          = Boolean.valueOf(wor.IsCause__c);
                wrapper.Quantity         = Integer.valueOf(wor.Quantity__c);
                resultList.add(wrapper);
            }

            response.put('status', 'success');
            response.put('workOrderResults', resultList);
        } catch (Exception e) {
            response.put('status', 'error');
            response.put('message', e.getMessage());
            response.put('lineNumber', e.getLineNumber());
            response.put('stackTrace', e.getStackTraceString());
        }
        return response;
    }

    /*
     * description : Service Order => Service Dates and Times 버튼 클릭 시 'WH'에 대한 WorkOrderResult__c 저장 기능
     * author      : SungHeum, Yeon
     * return      : saveResultWrapper
     * parameter
     *   	- workOrderId    : Work Order Id
     *    	- saveResults    : workOrderResults, ResultType__c=WH에 대한 INPUT 값
     *    	- deleteResults  : 삭제 해야 할 workOrderResults ID List 값
     */
    @AuraEnabled
    public static saveResultWrapper saveWorkOrderResults(Id workOrderId, String saveResults, List<String> deleteResults) {
        saveResultWrapper resultWrapper = new saveResultWrapper();
        Savepoint sp = Database.setSavepoint();

        try {
            System.debug('saveResults:::'+ saveResults);
            System.debug('deleteResults:::'+ deleteResults);

            // JSON 문자열을 List<Map<String, Object>> 형태로 변환
            List<Object> workOrderResults = (List<Object>) JSON.deserializeUntyped(saveResults);

            List<WorkOrderResult__c> recordsToInsert = new List<WorkOrderResult__c>();
            List<WorkOrderResult__c> recordsToUpdate = new List<WorkOrderResult__c>();

            for (Object obj : workOrderResults) {
                Map<String, Object> recordMap = (Map<String, Object>) obj;
                WorkOrderResult__c record = new WorkOrderResult__c();

                if (recordMap.containsKey('resultId')) {
                    String resultId = (String) recordMap.get('resultId');
                    if (resultId.startsWith('temp-')) {
                        record.Id = null;
                    } else {
                        record.Id = resultId;
                    }
                }
                if (recordMap.containsKey('WorkDate')) {
                    record.WorkDate__c = Date.valueOf((String) recordMap.get('WorkDate'));
                }
                if (recordMap.containsKey('WorkStartTime')) {
                    String startTimeStr = (String) recordMap.get('WorkStartTime');
                    record.WorkStartTime__c = parseTime(startTimeStr);
                }
                if (recordMap.containsKey('WorkEndTime')) {
                    String endTimeStr = (String) recordMap.get('WorkEndTime');
                    record.WorkEndTime__c = parseTime(endTimeStr);
                }
                if (recordMap.containsKey('WorkTime')) {
                    record.WorkTime__c = (String) recordMap.get('WorkTime');
                }
                if (recordMap.containsKey('TravelHour')) {
                    record.TravelHour__c = (String) recordMap.get('TravelHour');
                }
                if (recordMap.containsKey('AirTrip')) {
                    record.AirTrip__c = (String) recordMap.get('AirTrip');
                }

                if (record.Id == null) {
                    record.WorkOrder__c  = workOrderId;
                    record.ResultType__c = 'WH';
                    recordsToInsert.add(record);
                } else {
                    recordsToUpdate.add(record);
                }
            }

            // Insert 수행
            if (!recordsToInsert.isEmpty()) {
                System.debug('recordsToInsert:::' + recordsToInsert);
                insert recordsToInsert;
            }

            // Update 수행
            if (!recordsToUpdate.isEmpty()) {
                System.debug('recordsToUpdate:::' + recordsToUpdate);
                update recordsToUpdate;
            }

            // 삭제할 데이터 처리
            if (!deleteResults.isEmpty()) {
                List<WorkOrderResult__c> deleteWorkResults = [SELECT Id FROM WorkOrderResult__c WHERE Id IN :deleteResults];
                if (!deleteWorkResults.isEmpty()) {
                    System.debug('deleteResults:::' + deleteResults);
                    delete deleteWorkResults;
                }
            }

            resultWrapper.isSuccess = true;
            resultWrapper.message   = 'Successfully saved.';
            return resultWrapper;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            Database.rollback(sp);
            resultWrapper.isSuccess = false;
            resultWrapper.message   = 'Error: ' + e.getMessage();
            return resultWrapper;
        }
    }

    /*
     * description : Service Order => Parts Used (Reference ONLY) 버튼 클릭 시 'PT'에 대한 WorkOrderResult__c 저장 기능
     * author      : SungHeum, Yeon
     * return      : saveResultWrapper
     * parameter
     *   	- workOrderId    : Work Order Id
     *    	- saveResults    : workOrderResults, ResultType__c=PT에 대한 INPUT 값
     *    	- deleteResults  : 삭제 해야 할 workOrderResults ID List 값
     */
    @AuraEnabled
    public static saveResultWrapper saveWorkOrderResultsParts(Id workOrderId, String saveResults, List<String> deleteResults) {
        saveResultWrapper resultWrapper = new saveResultWrapper();
        Savepoint sp = Database.setSavepoint();

        try {
            System.debug('saveResults:::'+ saveResults);
            System.debug('deleteResults:::'+ deleteResults);

            // JSON 문자열을 List<Map<String, Object>> 형태로 변환
            List<Object> workOrderResults = (List<Object>) JSON.deserializeUntyped(saveResults);

            List<WorkOrderResult__c> recordsToInsert = new List<WorkOrderResult__c>();
            List<WorkOrderResult__c> recordsToUpdate = new List<WorkOrderResult__c>();

            for (Object obj : workOrderResults) {
                Map<String, Object> recordMap = (Map<String, Object>) obj;
                WorkOrderResult__c record = new WorkOrderResult__c();

                if (recordMap.containsKey('resultId')) {
                    String resultId = (String) recordMap.get('resultId');
                    if (resultId.startsWith('temp-')) {
                        record.Id = null;
                    } else {
                        record.Id = resultId;
                    }
                }
                if (recordMap.containsKey('ProductNumber')) {
                    record.ProductNumber__c = (String) recordMap.get('ProductNumber');
                }
                if (recordMap.containsKey('ProductName')) {
                    record.ProductName__c = (String) recordMap.get('ProductName');
                }
                if (recordMap.containsKey('IsCause')) {
                    record.IsCause__c = (Boolean) recordMap.get('IsCause');
                }
                if (recordMap.containsKey('Quantity')) {
                    record.Quantity__c = (Integer) recordMap.get('Quantity');
                }
                if (recordMap.containsKey('Note')) {
                    record.Note__c = (String) recordMap.get('Note');
                }

                if (record.Id == null) {
                    record.WorkOrder__c  = workOrderId;
                    record.ResultType__c = 'PT';
                    recordsToInsert.add(record);
                } else {
                    recordsToUpdate.add(record);
                }
            }

            // Insert 수행
            if (!recordsToInsert.isEmpty()) {
                System.debug('recordsToInsert:::' + recordsToInsert);
                insert recordsToInsert;
            }

            // Update 수행
            if (!recordsToUpdate.isEmpty()) {
                System.debug('recordsToUpdate:::' + recordsToUpdate);
                update recordsToUpdate;
            }

            // 삭제할 데이터 처리
            if (!deleteResults.isEmpty()) {
                List<WorkOrderResult__c> deleteWorkResults = [SELECT Id FROM WorkOrderResult__c WHERE Id IN :deleteResults];
                if (!deleteWorkResults.isEmpty()) {
                    System.debug('deleteResults:::' + deleteResults);
                    delete deleteWorkResults;
                }
            }

            resultWrapper.isSuccess = true;
            resultWrapper.message   = 'Successfully saved.';
            return resultWrapper;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            Database.rollback(sp);
            resultWrapper.isSuccess = false;
            resultWrapper.message   = 'Error: ' + e.getMessage();
            return resultWrapper;
        }
    }

    private static Time parseTime(String timeStr) {
        if (String.isEmpty(timeStr)) {
            return null;
        }

        List<String> timeParts = timeStr.split(':');
        if (timeParts.size() < 2) {
            return null;
        }

        Integer hour = Integer.valueOf(timeParts[0]);
        Integer minute = Integer.valueOf(timeParts[1]);
        Integer second = timeParts.size() > 2 ? Integer.valueOf(timeParts[2]) : 0;

        return Time.newInstance(hour, minute, second, 0);
    }


    /*
     * @Description
     * 		- Service Order Result 오브젝트의 ResultType__c = 'WH'에 대한 Wrapper
     *
     * @Variable
     *   	- resultId    	        : ID
     *  	- WorkDate           	: 작업일
     *  	- ApplicationDateTime	: Service Order의 접수일시
     *   	- WorkStartTime	    	: 시작시간
     *    	- WorkEndTime   	    : 종료시간
     *     	- WorkTime          	: 작업 시간
     *     	- TravelHour         	: Travel Hour
     *   	- AirTrip           	: Air Trip
     */
    public class workOrderServiceDateTimesWrapper {
        @AuraEnabled public String     resultId             { get; set; }
        @AuraEnabled public Date       WorkDate             { get; set; }
        @AuraEnabled public Datetime   ApplicationDateTime  { get; set; }
        @AuraEnabled public Time       WorkStartTime        { get; set; }
        @AuraEnabled public Time       WorkEndTime          { get; set; }
        @AuraEnabled public String     WorkTime             { get; set; }
        @AuraEnabled public String     TravelHour           { get; set; }
        @AuraEnabled public String     AirTrip              { get; set; }
    }

    /*
     * @Description
     * 		- Service Order Result 오브젝트의 ResultType__c = 'PT'에 대한 Wrapper
     *
     * @Variable
     *   	- resultId    	        : ID
     *  	- Note              	: 비고
     *  	- ProductNumber	        : 품번
     *   	- ProductName	    	: 품명
     *    	- IsCause   	        : 원인부품
     *     	- Quantity          	: 수량
     */
    public class workOrderPartsUsedWrapper {
        @AuraEnabled public String resultId      { get; set; }
        @AuraEnabled public String Note          { get; set; }
        @AuraEnabled public String ProductNumber { get; set; }
        @AuraEnabled public String ProductName   { get; set; }
        @AuraEnabled public Boolean IsCause      { get; set; }
        @AuraEnabled public Integer Quantity     { get; set; }
    }

    /*
     * @Description
     * 		- Save Result Wrapper
     *
     * @Variable
     *   	- isSuccess    	        : Boolean
     *  	- message              	: Text
     */
    public class saveResultWrapper {
        @AuraEnabled public Boolean isSuccess    { get; set; }
        @AuraEnabled public String  message      { get; set; }
    }
}