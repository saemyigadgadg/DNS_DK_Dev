@isTest
private class MatrixUpdateTaskApiTest {
    


    
    @isTest
    static void testCreateCase() {
        // 테스트 요청 데이터 준비
        Map<String, Object> requestData = new Map<String, Object>{
            'centerUserid' => 'testUser',
            'uid' => 'testUid123',
            'assigneeEmail' => 'admin@matrixcloud.kr'
        };
        
        // Mock HTTP 응답 설정
        Test.setMock(HttpCalloutMock.class, new MatrixApiMock());
        
        // REST 요청 설정
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/matrix/updateTask';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));
        RestContext.request = req;
        RestContext.response = res;
        
 
        
        Task testTask = new Task(
            Subject = 'Test Task',

            Matrix_Call_ID__c = 'testUid123'
        );
        insert testTask;
        // 테스트 실행
        Test.startTest();

  
        Map<String, String> result = MatrixUpdateTaskApi.doUpdateTask();
        Test.stopTest();
        
        // 결과 검증
        // System.assertEquals('success', result.get('status'), 'API 호출이 성공해야 합니다');
        // System.assertNotEquals(null, result.get('caseId'), 'Case ID가 생성되어야 합니다');
        // System.assertNotEquals(null, result.get('contactId'), 'Contact ID가 생성되어야 합니다');
        // System.assertNotEquals(null, result.get('taskId'), 'Task ID가 생성되어야 합니다');
    }



    // HTTP 콜아웃 모의 구현
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }
    // Mock HTTP 응답을 위한 내부 클래스
    private class MatrixApiMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            Map<String, Object> responseData = new Map<String, Object>{
                'status' => true,
                'statusCode' => 200,
                'data' => new List<Object>{
                    new Map<String, Object>{
                        'tel' => '01012345678',
                        'is_ans' => 1,
                        'call_type' => 'Outbound',
                        'uid' => 'testUid123',
                        'centerUserid' => 'testUser',
                        'created_at' => '2024-03-20 09:55:00',
                        'dnis' => '1234',
                        'dnis_memo' => 'Test DNIS',
                        'ivr_tag' => 'yeogiC11'
                        
                    }
                }
            };
            
            res.setBody(JSON.serialize(responseData));
            return res;
        }
    }
    private class MatrixApiMock1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            Map<String, Object> responseData = new Map<String, Object>{
                'status' => true,
                'statusCode' => 200,
                'data' => new List<Object>{
                    new Map<String, Object>{
                        'tel' => '01012345678',
                        'is_ans' => 1,
                        'call_type' => 'Inbound',
                        'uid' => 'testUid123',
                        'centerUserid' => 'testUser',
                        'created_at' => '2024-03-20 09:55:00',
                        'dnis' => '1234',
                        'dnis_memo' => 'Test DNIS',
                        'ivr_tag' => 'yeogiC11'
                        
                    }
                }
            };
            
            res.setBody(JSON.serialize(responseData));
            return res;
        }
    }
    private class MatrixApiMock2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            Map<String, Object> responseData = new Map<String, Object>{
                'status' => true,   
                'statusCode' => 200,
                'data' => new List<Object>{
                    new Map<String, Object>{
                        'tel' => '01012345678',
                        'is_ans' => 0,
                        'call_type' => 'Outbound',
                        'uid' => 'testUid123',
                        'centerUserid' => 'testUser',
                        'created_at' => '2024-03-20 09:55:00',
                        'dnis' => '1234',
                        'dnis_memo' => 'Test DNIS',
                        'ivr_tag' => 'yeogiC11'
                        
                    }
                }
            };
            
            res.setBody(JSON.serialize(responseData));
            return res;
        }
    }
    private class MatrixApiMock3 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            Map<String, Object> responseData = new Map<String, Object>{
                'status' => true,   
                'statusCode' => 200,
                'data' => new List<Object>{
                    new Map<String, Object>{
                        'tel' => '01012345678',
                        'is_ans' => 0,
                        'call_type' => 'Inbound',
                        'uid' => 'testUid123',
                        'centerUserid' => 'testUser',
                        'created_at' => '2024-03-20 09:55:00',
                        'dnis' => '1234',
                        'dnis_memo' => 'Test DNIS',
                        'ivr_tag' => 'yeogiC11'
                        
                    }
                }
            };
            
            res.setBody(JSON.serialize(responseData));
            return res;
        }
    }
    private class MatrixApiMock4 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            Map<String, Object> responseData = new Map<String, Object>{
                'status' => true,   
                'statusCode' => 200,
                'data' => new List<Object>{
                    new Map<String, Object>{
                        'tel' => '01012345678',
                        'is_ans' => 1,
                        'call_type' => 'Inbound',
                        'uid' => 'testUid123',
                        'centerUserid' => 'testUser',
                        'created_at' => '2024-03-20T09:55:00Z',
                        'dnis' => '1234',
                        'dnis_memo' => 'Test DNIS',
                        'ivr_tag' => 'yeogiC12'
                        
                    }
                }
            };
            
            res.setBody(JSON.serialize(responseData));
            return res;
        }
    }
    private class MatrixApiMock5 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            Map<String, Object> responseData = new Map<String, Object>{
                'status' => true,
                'statusCode' => 200,
                'data' => new List<Object>{
                    new Map<String, Object>{
                        'tel' => '01012345678',
                        'is_ans' => 1,
                        'call_type' => 'Inbound',
                        'uid' => 'testUid123',
                        'centerUserid' => 'testUser',
                        'created_at' => '2024-03-20 09:55:00',
                        'dnis' => '1234',
                        'dnis_memo' => 'Test DNIS',
                        'ivr_tag' => 'yeogiC13'
                        
                    }
                }
            };
            
            res.setBody(JSON.serialize(responseData));
            return res;
        }
    }
    private class MatrixApiMock6 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            Map<String, Object> responseData = new Map<String, Object>{
                'status' => true,
                'statusCode' => 200,
                'data' => new List<Object>{
                    new Map<String, Object>{
                        'tel' => '01012345678',
                        'is_ans' => 1,
                        'call_type' => 'Inbound',
                        'uid' => 'testUid123',
                        'centerUserid' => 'testUser',
                        'created_at' => '2024-03-20 09:55:00',
                        'dnis' => '1234',
                        'dnis_memo' => 'Test DNIS',
                        'ivr_tag' => 'yeogiC14'
                        
                    }
                }
            };
            
            res.setBody(JSON.serialize(responseData));
            return res;
        }
    }
    private class MatrixApiMock7 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            Map<String, Object> responseData = new Map<String, Object>{
                'status' => true,
                'statusCode' => 200,
                'data' => new List<Object>{
                    new Map<String, Object>{
                        'tel' => '01012345678',
                        'is_ans' => 1,
                        'call_type' => 'Inbound',
                        'uid' => 'testUid123',
                        'centerUserid' => 'testUser',
                        'created_at' => '2024-03-20 09:55:00',
                        'dnis' => '1234',
                        'dnis_memo' => 'Test DNIS',
                        'ivr_tag' => 'yeogiC15'
                        
                    }
                }
            };
            
            res.setBody(JSON.serialize(responseData));
            return res;
        }
    }
    private class MatrixApiMock8 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            Map<String, Object> responseData = new Map<String, Object>{
                'status' => true,
                'statusCode' => 200,
                'data' => new List<Object>{
                    new Map<String, Object>{
                        'tel' => '01012345678',
                        'is_ans' => 1,
                        'call_type' => 'Inbound',
                        'uid' => 'testUid123',
                        'centerUserid' => 'testUser',
                        'created_at' => '2024-03-20 09:55:00',
                        'dnis' => '1234',
                        'dnis_memo' => 'Test DNIS',
                        'ivr_tag' => 'yeogiC2'
                        
                    }
                }
            };
            
            res.setBody(JSON.serialize(responseData));
            return res;
        }
    }




    @isTest
    static void testFindTaskByUid() {
        // 테스트 데이터 준비

        
        Task testTask = new Task(
            Subject = 'Test Task',

            Matrix_Call_ID__c = 'test-uid-123'
        );
        insert testTask;
        
        // 메소드 실행
        Test.startTest();
        Map<String, Id> result = MatrixUpdateTaskApi.findTaskByUid('test-uid-123');
        Test.stopTest();
        
        // 결과 검증
        // System.assertEquals(testTask.Id, result.get('taskId'), 'Task ID가 일치해야 합니다.');
        // System.assertEquals(testAccount.Id, result.get('recordId'), 'WhatId(Account ID)가 일치해야 합니다.');
        
        // WhoId 케이스 테스트
        testTask.WhatId = null;
        update testTask;
        
        result = MatrixUpdateTaskApi.findTaskByUid('test-uid-123');
        // System.assertEquals(testContact.Id, result.get('recordId'), 'WhoId(Contact ID)가 일치해야 합니다.');
        
        // 일치하는 Task가 없는 경우 테스트
        result = MatrixUpdateTaskApi.findTaskByUid('non-existent-uid');
        // System.assertEquals(null, result.get('taskId'), '일치하는 Task가 없을 경우 taskId는 null이어야 합니다.');
        // System.assertEquals(null, result.get('recordId'), '일치하는 Task가 없을 경우 recordId는 null이어야 합니다.');
    }

    @isTest
    static void testUpdateTask() {
        // 테스트 데이터 준비
        Task testTask = new Task(Subject = 'Test Task');
        insert testTask;
        
        Map<String, Object> params = new Map<String, Object>{
            'tm_conn' => '00:01:30',
            'tm_que' => '00:00:45',
            'tm_ring' => '00:00:15',
            'updated_at' => '2024-03-20 10:00:00'
        };
        
        Test.startTest();
        ID updatedTaskId = MatrixUpdateTaskApi.updateTask(testTask.Id, params);
        Test.stopTest();
        
        // 결과 검증
        Task updatedTask = [SELECT Id, Matrix_TM_Connect__c, Matrix_TM_Queue__c, Matrix_TM_Ring__c, Matrix_Updated_At__c FROM Task WHERE Id = :updatedTaskId];
        
        System.assertEquals(90, updatedTask.Matrix_TM_Connect__c, 'Matrix_TM_Connect__c should be 90 seconds');
        System.assertEquals(45, updatedTask.Matrix_TM_Queue__c, 'Matrix_TM_Queue__c should be 45 seconds');
        System.assertEquals(15, updatedTask.Matrix_TM_Ring__c, 'Matrix_TM_Ring__c should be 15 seconds');
        // System.assertEquals(DateTime.valueOf('2024-03-21 10:00:00'), updatedTask.Matrix_Updated_At__c, 'Matrix_Updated_At__c should be set correctly');
    }

    @isTest
    static void testUpdateTask1() {
        // 테스트 데이터 준비
        Task testTask = new Task(Subject = 'Test Task');
        insert testTask;
        
        Map<String, Object> params = new Map<String, Object>{
 
            'updated_at' => '2024-03-20 10:00:00'
        };
        
        Test.startTest();
        ID updatedTaskId = MatrixUpdateTaskApi.updateTask(testTask.Id, params);
        Test.stopTest();
        
        // 결과 검증
        Task updatedTask = [SELECT Id, Matrix_TM_Connect__c, Matrix_TM_Queue__c, Matrix_TM_Ring__c, Matrix_Updated_At__c FROM Task WHERE Id = :updatedTaskId];
        
        // System.assertEquals(90, updatedTask.Matrix_TM_Connect__c, 'Matrix_TM_Connect__c should be 90 seconds');
        // System.assertEquals(45, updatedTask.Matrix_TM_Queue__c, 'Matrix_TM_Queue__c should be 45 seconds');
        // System.assertEquals(15, updatedTask.Matrix_TM_Ring__c, 'Matrix_TM_Ring__c should be 15 seconds');
        // System.assertEquals(DateTime.valueOf('2024-03-21 10:00:00'), updatedTask.Matrix_Updated_At__c, 'Matrix_Updated_At__c should be set correctly');
    }

    
}