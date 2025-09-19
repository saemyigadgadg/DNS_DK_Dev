public with sharing class MatrixChatController {





  @AuraEnabled
  public static String updateOwnerId(Case matrixChatToUpdate) {
    try {
      System.debug('Matrix Chat 업데이트 중: ' + matrixChatToUpdate);
      update matrixChatToUpdate;
      System.debug('Matrix Chat 업데이트 성공');
      return 'Matrix updated successfully.';
    } catch (Exception e) {
      System.debug('Matrix Chat 업데이트 오류: ' + e.getMessage());
      // Handle exceptions
      return 'Error updating Case: ' + e.getMessage();
    }
  }    

  @AuraEnabled(cacheable=true)
  public static Case findCase(String roomId) {
    System.debug('Case 데이터 검색 중: ' + roomId);
    Integer key = Integer.valueOf(roomId);
    return [
      SELECT Id , CaseNumber , OwnerId
      FROM Case
      WHERE MatrixChat_Room_Id__c = :key
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
  }

  @AuraEnabled(cacheable=true)
  public static Case getMatrixChatData(String Id) {

    List<Case> matrixChat = [
      SELECT Id,  MatrixChat_Room_Id__c, MatrixChat_Session_Id__c,MatrixChat_Center_Id__c
      FROM Case
      WHERE Id = :Id
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    if (!matrixChat.isEmpty()) {
        return matrixChat[0];
    } else {
        return null;
    }
  }
  @AuraEnabled
  public static String saveMessageWithOutSavingFile(String caseId, List<String> messages) {
    try {
      System.debug('Matrix chat message 업데이트 중: ' + caseId + messages );
      Case findCase = [
        SELECT Id
        FROM Case
        WHERE Id = :caseId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      String resultText = '';
      
      for (String message : messages) {
          // Split the message by the first occurrence of a space to extract timestamp and the rest
        // Split the string into two parts using the delimiter ': '
        List<String> parts = message.split(': ', 2);
        String timestampAndCustomer = ''; // "2024-11-17 10:38 고객:"
        String content = ''; 


        // Check if the splitting was successful
        if (parts.size() == 2) {
            timestampAndCustomer = parts[0]; // "2024-11-17 10:38 고객:"
            content = parts[1];             // "하이"

            // Output results to debug log
            System.debug('Timestamp and Customer: ' + timestampAndCustomer);
            System.debug('Message: ' + content);
        } else {
            System.debug('String could not be split properly.');
        }

        System.debug('content : ' + content);

        resultText += '<p><b>' + timestampAndCustomer + ':</b> ' + content + '</p>';
      }

      findCase.MatrixChat_Contents__c = resultText;

      update findCase;
      System.debug('Matrix Chat message 업데이트 성공');
      return 'save chat messages sucessfully';
    }catch(Exception e){
      System.debug('Matrix Chat 업데이트 오류: ' + e.getMessage());
      // Handle exceptions
      return 'Error save chat messages : ' + e.getMessage();
    }
  }
  @AuraEnabled
  public static String saveMessage(String caseId, List<String> messages) {
    try {
      System.debug('Matrix chat message 업데이트 중: ' + caseId + messages );
      Case findCase = [
        SELECT Id
        FROM Case
        WHERE Id = :caseId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];

      findCase.MatrixChat_Contents__c = String.join(messages, '\n');


      update findCase;
      System.debug('Matrix Chat message 업데이트 성공');
      return 'save chat messages sucessfully';
    }catch(Exception e){
      System.debug('Matrix Chat 업데이트 오류: ' + e.getMessage());
      // Handle exceptions
      return 'Error save chat messages : ' + e.getMessage();
    }
  }

  @AuraEnabled
  public static String saveAISummary(Case matrixChatToUpdate) {
    try {
      System.debug('Matrix saveAISummary 업데이트 중: ' + matrixChatToUpdate);
      Case findCase = [
        SELECT Id, Matrix_Call_Category__c , Matrix_Call_Emotion__c , Matrix_Call_Summary__c, ConsultationContents__c ,Matrix_Chat_Summary_Done__c
        FROM Case
        WHERE Id = :matrixChatToUpdate.Id
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      if (!findCase.Matrix_Chat_Summary_Done__c) {
      Datetime currentTime = Datetime.now();
      String userName = UserInfo.getName();

      // 원하는 형식으로 변환하기 (예: yyyy-MM-dd HH:mm:ss)
      String formattedDate = currentTime.format('yyyy-MM-dd HH:mm:ss');

      if (findCase.Matrix_Call_Category__c != null) {
        findCase.Matrix_Call_Category__c += '\n' +  '\n'+ formattedDate + ' ' + '상담톡' + ' ' + userName;  
        findCase.Matrix_Call_Category__c += '\n' + matrixChatToUpdate.Matrix_Call_Category__c;  
      } else {
        findCase.Matrix_Call_Category__c = formattedDate + ' ' + '상담톡' + ' ' + userName;  
        findCase.Matrix_Call_Category__c += '\n' + matrixChatToUpdate.Matrix_Call_Category__c;  
      }

      if (findCase.Matrix_Call_Emotion__c != null) {
        findCase.Matrix_Call_Emotion__c += '\n' + '\n'+formattedDate + ' ' + '상담톡' + ' ' + userName;  
        findCase.Matrix_Call_Emotion__c += '\n' + matrixChatToUpdate.Matrix_Call_Emotion__c;  
      } else {
        findCase.Matrix_Call_Emotion__c = formattedDate + ' ' + '상담톡' + ' ' + userName;  
        findCase.Matrix_Call_Emotion__c += '\n' + matrixChatToUpdate.Matrix_Call_Emotion__c;  
      }

      if (findCase.Matrix_Call_Summary__c != null) {
        findCase.Matrix_Call_Summary__c += '\n' + '\n'+formattedDate + ' ' + '상담톡' + ' ' + userName;  
        findCase.Matrix_Call_Summary__c += '\n' + matrixChatToUpdate.Matrix_Call_Summary__c;  
      } else {
        findCase.Matrix_Call_Summary__c = formattedDate + ' ' + '상담톡' + ' ' + userName;  
        findCase.Matrix_Call_Summary__c += '\n' + matrixChatToUpdate.Matrix_Call_Summary__c;  
      }

      if (findCase.ConsultationContents__c != null) {
        findCase.ConsultationContents__c += '\n' + '\n'+formattedDate + ' ' + '상담톡' + ' ' + userName;  
        findCase.ConsultationContents__c += '\n' + matrixChatToUpdate.Matrix_Call_Summary__c;  
      } else {
        findCase.ConsultationContents__c = formattedDate + ' ' + '상담톡' + ' ' + userName;  
        findCase.ConsultationContents__c += '\n' + matrixChatToUpdate.Matrix_Call_Summary__c;  
      }

      
      findCase.Matrix_Chat_Summary_Done__c = true;


        update findCase;
        System.debug('Matrix saveAISummary 업데이트 성공');
        return 'updated';
      } else {
        System.debug('Matrix saveAISummary 이미 업데이트됨');
        return 'skipped';
      }
    } catch(Exception e) {
      System.debug('Matrix Chat 업데이트 오류: ' + e.getMessage());
      return 'Error save chat messages : ' + e.getMessage();
    }
  }  



  @AuraEnabled
  public static String getUserEmail() {
      try{
          System.debug('email');
          User user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
          street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
          FROM User
          WHERE id = :UserInfo.getUserId()];
          System.debug(user);
          System.debug('email'+user.email);
          return user.email;
      }catch(Exception e){
          return 'Error updating task: ' + e.getMessage();
      }

  }
  @AuraEnabled(cacheable=true)
  public static User getUserInfo() {
      return [SELECT Id, Name, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
  }





@future(callout=true)
    public static void callApiWithOwnerEmail(Map<Id, Id> caseOwnerMap) {
        try {
            // Owner 정보를 조회
            List<User> owners = [SELECT Id, Email FROM User WHERE Id IN :caseOwnerMap.values()];
            Map<Id, String> ownerEmailMap = new Map<Id, String>();
            for (User u : owners) {
                ownerEmailMap.put(u.Id, u.Email);
            }
            System.debug('ownerEmailMap : ' + ownerEmailMap);
            System.debug('caseOwnerMap : ' + caseOwnerMap);

            for (Id caseId : caseOwnerMap.keySet()) {
                String ownerId = caseOwnerMap.get(caseId);
                String ownerEmail = ownerEmailMap.get(ownerId);

                // 이메일이 없는 경우 처리 스킵
                if (String.isBlank(ownerEmail)) {
                    continue;
                }

                // API 호출을 위한 HTTP Request 생성
                Http http = new Http();
                HttpRequest request = new HttpRequest();

                request.setEndpoint('https://torderchat.matrixcloud.kr/room/salesforce/operator'); // API 엔드포인트 URL
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('centerid', 'dns');
                request.setHeader('serverGroup', 'G002');

                // 요청 본문 생성
                Map<String, Object> payload = new Map<String, Object>();
                payload.put('ticketId', caseId);
                payload.put('assigneeEmail', ownerEmail);

                String requestBody = JSON.serialize(payload);
                request.setBody(requestBody);

                // HTTP Callout 실행
                HttpResponse response = http.send(request);

                // 응답 상태 코드 확인
                if (response.getStatusCode() != 200) {
                    System.debug('Error: ' + response.getBody());
                }
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }  

    // @AuraEnabled
    // public static String saveFileFromURL(String fileURL, String fileName, String parentId) {
    //     // 파일 다운로드 로직
    //     // HTTP 요청을 사용하여 파일 내용을 가져옴
    //             // HTTP 요청 생성
    //     HttpRequest request = new HttpRequest();
    //     request.setEndpoint(fileURL);
    //     request.setMethod('GET');

    //     // HTTP 요청 전송 및 응답 받기
    //     Http http = new Http();
    //     HttpResponse response = http.send(request);

    //     // 응답에서 Blob 데이터 얻기
    //     Blob fileContent = response.getBodyAsBlob();

    //     // ContentVersion 객체 생성 및 파일 저장
 

    //     ContentVersion contentVersion = new ContentVersion();
    //     contentVersion.VersionData = fileContent; // 파일 데이터
    //     contentVersion.Title = fileName;
    //     contentVersion.PathOnClient = fileName;

    //     insert contentVersion;

    //     // ContentDocumentLink 객체 생성 및 Salesforce 객체에 연결
    //     ContentDocumentLink cdl = new ContentDocumentLink();
    //     cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
    //     cdl.LinkedEntityId = parentId; // Salesforce 객체 ID
    //     cdl.ShareType = 'V';
    //     insert cdl;

    //     return contentVersion.Id;
    // }  



}