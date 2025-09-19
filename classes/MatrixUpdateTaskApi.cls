@RestResource(urlMapping='/matrix/updatetask')
global with sharing class MatrixUpdateTaskApi {
    
    @HttpPost
    global static Map<String, String> doUpdateTask(){  // contact 용
        try {
            RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
            List<Contact> contactList = new List<Contact>();
            List<Account> accountList = new List<Account>();
            List<Case> caseList = new List<Case>();

            Id selectedContactId = null;
            Id selectedAccountId = null;
            Id personContactId = null;
            Id selectedCaseId = null;
            Id recordTypeId = null;
            Map<String, String> response = new Map<String, String>();

            Map<String, Object> params = new Map<String, Object>();
            params = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
            
            String centerUserId = (String)params.get('centerUserid');
            String uid = (String)params.get('uid');
            String email = (String)params.get('assigneeEmail');
            String phone = '';

            // Matrix API 호출
            String matrixEndpoint = 'https://mtu01.matrixcloud.kr/ext/getCallInfo';
            matrixEndpoint += '?centerUserid=' + centerUserId;
            matrixEndpoint += '&uid=' + uid;

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(matrixEndpoint);
            request.setMethod('GET');
            request.setTimeout(5000); // 2분 타임아웃 설정
            
            HttpResponse matrixResponse = null;
            Integer maxRetries = 3;
            Integer currentRetry = 0;
            Boolean isSuccess = false;

            while (!isSuccess && currentRetry < maxRetries) {
                try {
                    matrixResponse = http.send(request);
                    
                    if (matrixResponse.getStatusCode() == 200) {
                        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(matrixResponse.getBody());
                        if (responseMap.get('status') == true && responseMap.get('statusCode') == 200) {
                            List<Object> dataList = (List<Object>)responseMap.get('data');
                            if (dataList != null && !dataList.isEmpty()) {
                                params = (Map<String, Object>)dataList[0];
                                isSuccess = true;
                            }
                        }
                    }
                    
                    if (!isSuccess) {
                        currentRetry++;
                        if (currentRetry < maxRetries) {
                            // 재시도 전 1초 대기
                            Long startTime = System.currentTimeMillis();
                            while (System.currentTimeMillis() - startTime < 2000) {
                                // 대기
                            }
                        }
                    }
                } catch (Exception e) {
                    currentRetry++;
                    if (currentRetry < maxRetries) {
                        // 재시도 전 1초 대기
                        Long startTime = System.currentTimeMillis();
                        while (System.currentTimeMillis() - startTime < 1000) {
                            // 대기
                        }
                    }
                }
            }

            if (!isSuccess) {
                throw new MatrixException('Matrix API 호출 실패: ' + (matrixResponse != null ? matrixResponse.getBody() : '응답 없음'));
            }

            Map<String,Id> taskInfo = findTaskByUid((String)params.get('uid'));
            if(taskInfo.get('taskId') != null){
                updateTask(taskInfo.get('taskId'), params);

                response.put('taskId', taskInfo.get('taskId'));
                response.put('status', 'success');


            }else {
                response.put('taskId', null);
                response.put('status', 'success');

            }
            
            return response;
            
        } catch(Exception e) {
            Map<String, String> errorResponse = new Map<String, String>();
            errorResponse.put('status', 'error');
            errorResponse.put('message', e.getMessage() + ' at line ' + e.getLineNumber());
            return errorResponse;
        }
    }

    public static Integer timeStringToSeconds(String timeString) {
        // "시:분:초" 형식의 문자열을 콜론(:)을 기준으로 분리합니다.
        List<String> parts = timeString.split(':');

        // 시, 분, 초 부분을 숫자로 변환합니다.
        Integer hours = Integer.valueOf(parts[0]);
        Integer minutes = Integer.valueOf(parts[1]); 
        Integer seconds = Integer.valueOf(parts[2]);

        // 시를 초로 변환 (1시간 = 3600초)
        // 분을 초로 변환 (1분 = 60초)
        // 시, 분, 초를 모두 합산하여 총 초를 계산합니다.
        Integer totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

        return totalSeconds;
    }    

    public static Map<String,Id> findTaskByUid(String uid) {
        Map<String,Id> returnValue = new Map<String,Id>();
        List<Task> matchedTasks = [
            SELECT Id, WhatId, WhoId
            FROM Task 
            WHERE Matrix_Call_ID__c = :uid Limit 1
        ];
        System.debug('The number of task records matched: ' + matchedTasks.size());
        System.debug('matchedTasks'+ matchedTasks);
        if(matchedTasks.size() > 0){
            returnValue.put('taskId', matchedTasks[0].Id);
            return returnValue;
        }

        returnValue.put('taskId', null);
        return returnValue;
    }

    public static ID updateTask(ID taskId, Map<String, Object> params) {

        Task newTask = new Task();

        newTask = [SELECT Id FROM Task WHERE Id = :taskId];

        if(params.containsKey('tm_conn') && params.get('tm_conn') != null  && (String)(params.get('tm_conn')) != '') {
            newTask.Matrix_TM_Connect__c = timeStringToSeconds((String)(params.get('tm_conn')));
        }else{
            newTask.Matrix_TM_Connect__c = 0;
        }
        if(params.containsKey('tm_que') && params.get('tm_que') != null  && (String)(params.get('tm_que')) != '') {
            newTask.Matrix_TM_Queue__c = timeStringToSeconds((String)(params.get('tm_que')));
        }else{
            newTask.Matrix_TM_Queue__c = 0;
        }
        if(params.containsKey('tm_ring') && params.get('tm_ring') != null  && (String)(params.get('tm_ring')) != '') {
            newTask.Matrix_TM_Ring__c = timeStringToSeconds((String)(params.get('tm_ring')));
        }else{
            newTask.Matrix_TM_Ring__c = 0;
        }
        
        if(params.containsKey('updated_at') && params.get('updated_at') != null && (String)(params.get('updated_at')) != '') {
            newTask.Matrix_Updated_At__c = DateTime.valueOf((String)(params.get('updated_at')));
        }

 
        update newTask;
        return newTask.ID;

    }



    public class MatrixException extends Exception {}
}