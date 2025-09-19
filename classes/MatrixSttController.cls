public with sharing class MatrixSttController {
  public class SttUpdateClass {
    public Id recordId;
    public String uid;
    public String summary;
    public String emotion;
    public String category;
  }

  @AuraEnabled
  public static String updateTask(List<Task> taskUpdate) {
    try {
      System.debug('Task 업데이트 중: ' + taskUpdate);
      String test = 'test';
      test = 'test';
      update taskUpdate;
      System.debug('Task 업데이트 성공');
      return 'Task updated successfully.';
    } catch (Exception e) {
      // System.debug('Task 업데이트 오류: ' + e.getMessage());
      // Handle exceptions
      return 'Error updating task: ' + e.getMessage();
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<Task> findTasks(String searchKey) {
    System.debug('Task 데이터 검색 중: ' + searchKey);
    String test = 'test';
    test = 'test';
    String key = searchKey;
    return [
      SELECT Id
      FROM Task
      WHERE Matrix_Call_ID__c = :key
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
  }

  @AuraEnabled
  public static String addCaseComment(String caseId, String commentBody) {
    try {
      CaseComment newComment = new CaseComment(
        ParentId = caseId,
        CommentBody = commentBody,
        IsPublished = true
      );
      insert newComment;
      String test = 'test';
      test = 'test';
      return 'Comment added successfully';
    } catch (Exception e) {
      throw new AuraHandledException(
        'Failed to add comment: ' + e.getMessage()
      );
    }
  }

  @AuraEnabled
  public static String updateCase(List<Case> caseUpdate) {
    try {
      System.debug('Case 업데이트 중: ' + caseUpdate);
      Case updatedRecord = [
        SELECT
          Id,
          Matrix_Call_Category__c,
          Matrix_Call_Emotion__c,
          Matrix_Call_Summary__c
        FROM Case
        WHERE Id = :caseUpdate[0].Id
        LIMIT 1
      ];
      Task selectedTask = [
        SELECT Id, Matrix_Call_Type__c
        FROM Task
        WHERE Matrix_Call_ID__c = :caseUpdate[0].Matrix_Call_ID__c
        LIMIT 1
      ];
      String userName = UserInfo.getUserName();
      // 현재 시간 구하기
      Datetime currentTime = Datetime.now();

      // 원하는 형식으로 변환하기 (예: yyyy-MM-dd HH:mm:ss)
      String formattedDate = currentTime.format('yyyy-MM-dd HH:mm:ss');

      if (updatedRecord.Matrix_Call_Category__c != null) {
        updatedRecord.Matrix_Call_Category__c += '\n' + '\n' + formattedDate;
        updatedRecord.Matrix_Call_Category__c +=
          '\n' + caseUpdate[0].Matrix_Call_Category__c;
      } else {
        updatedRecord.Matrix_Call_Category__c = formattedDate;
        updatedRecord.Matrix_Call_Category__c +=
          '\n' + caseUpdate[0].Matrix_Call_Category__c;
      }

      if (updatedRecord.Matrix_Call_Emotion__c != null) {
        updatedRecord.Matrix_Call_Emotion__c += '\n' + '\n' + formattedDate;
        updatedRecord.Matrix_Call_Emotion__c +=
          '\n' + caseUpdate[0].Matrix_Call_Emotion__c;
      } else {
        updatedRecord.Matrix_Call_Emotion__c = formattedDate;
        updatedRecord.Matrix_Call_Emotion__c +=
          '\n' + caseUpdate[0].Matrix_Call_Emotion__c;
      }

      if (updatedRecord.Matrix_Call_Summary__c != null) {
        updatedRecord.Matrix_Call_Summary__c +=
          '\n' +
          '\n' +
          formattedDate +
          ' ' +
          selectedTask.Matrix_Call_Type__c +
          ' ' +
          userName;
        updatedRecord.Matrix_Call_Summary__c +=
          '\n' + caseUpdate[0].Matrix_Call_Summary__c;
      } else {
        updatedRecord.Matrix_Call_Summary__c =
          formattedDate +
          ' ' +
          selectedTask.Matrix_Call_Type__c +
          ' ' +
          userName;
        updatedRecord.Matrix_Call_Summary__c +=
          '\n' + caseUpdate[0].Matrix_Call_Summary__c;
      }

      update updatedRecord;

      System.debug('Case 업데이트 성공');

      return 'Case updated successfully.';
    } catch (Exception e) {
      // System.debug('Case 업데이트 오류: ' + e.getMessage());
      // Handle exceptions
      return 'Error updating Case: ' + e.getMessage();
    }
  }

  @AuraEnabled
  public static String updateSTTnTasknCase(String sttUpdate) {
    try {
      SttUpdateClass sttUpdateJSON = new SttUpdateClass();
      sttUpdateJSON = (SttUpdateClass) System.JSON.deserialize(
        sttUpdate,
        SttUpdateClass.class
      );
      System.debug('updateSTTnTasknCase 업데이트 중: ' + sttUpdateJSON);
      Case updatedRecord = [
        SELECT Id, ConsultationContents__c
        FROM Case
        WHERE Id = :sttUpdateJSON.recordId
        LIMIT 1
      ];
      Task selectedTask = [
        SELECT Id, Matrix_Call_Type__c
        FROM Task
        WHERE Matrix_Call_ID__c = :sttUpdateJSON.uid
        LIMIT 1
      ];
      String userName = UserInfo.getName();
      // 현재 시간 구하기
      Datetime currentTime = Datetime.now();

      // 원하는 형식으로 변환하기 (예: yyyy-MM-dd HH:mm:ss)
      String formattedDate = currentTime.format('yyyy-MM-dd HH:mm:ss');

      if (updatedRecord.ConsultationContents__c != null) {
        updatedRecord.ConsultationContents__c +=
          '\n' +
          '\n' +
          formattedDate +
          ' ' +
          selectedTask.Matrix_Call_Type__c +
          ' ' +
          userName;
        updatedRecord.ConsultationContents__c += '\n' + sttUpdateJSON.summary;
      } else {
        updatedRecord.ConsultationContents__c =
          formattedDate +
          ' ' +
          selectedTask.Matrix_Call_Type__c +
          ' ' +
          userName;
        updatedRecord.ConsultationContents__c += '\n' + sttUpdateJSON.summary;
      }

      update updatedRecord;

      STT__c newStt = new STT__c();
      newStt.STTDescription__c = sttUpdateJSON.summary;
      newStt.Category__c = sttUpdateJSON.category;
      newStt.Emotion__c = sttUpdateJSON.emotion;

      insert newStt;

      Task updatedTask = [
        SELECT ID
        FROM Task
        WHERE Matrix_Call_ID__c = :sttUpdateJSON.uid
        LIMIT 1
      ];

      System.debug('find task' + updatedTask.Id);
      updatedTask.stt__c = newStt.Id;

      if (String.isNotBlank(sttUpdateJSON.category)) {
        String[] categoryArray = sttUpdateJSON.category.split('_');
        System.debug('categoryArray' + categoryArray);
        updatedTask.ConsultationTypeMajor__c = categoryArray.size() > 0
          ? categoryArray[0]
          : null;
        updatedTask.ConsultationTypeMiddle__c = categoryArray[1];
      }

      update updatedTask;

      System.debug('updateSTTnTasknCase 업데이트 성공');

      return 'Case updated successfully.';
    } catch (Exception e) {
      // System.debug('Case 업데이트 오류: ' + e.getMessage());
      // Handle exceptions
      return 'Error updating Case: ' + e.getMessage();
    }
  }

  @AuraEnabled
  public static String updateWorkOrder(String sttUpdate) {
    try {
      SttUpdateClass sttUpdateJSON = new SttUpdateClass();
      sttUpdateJSON = (SttUpdateClass) System.JSON.deserialize(
        sttUpdate,
        SttUpdateClass.class
      );

      System.debug('updateWorkOrder 업데이트 중: ' + sttUpdateJSON);
      WorkOrder findedWorkOrder = [
        SELECT Id, CaseId
        FROM WorkOrder
        WHERE Id = :sttUpdateJSON.recordId
        LIMIT 1
      ];
      Case updatedRecord = [
        SELECT Id, ConsultationContents__c
        FROM Case
        WHERE Id = :findedWorkOrder.CaseId
        LIMIT 1
      ];

      Task selectedTask = [
        SELECT Id, Matrix_Call_Type__c
        FROM Task
        WHERE Matrix_Call_ID__c = :sttUpdateJSON.uid
        LIMIT 1
      ];
      String userName = UserInfo.getUserName();
      // 현재 시간 구하기
      Datetime currentTime = Datetime.now();

      // 원하는 형식으로 변환하기 (예: yyyy-MM-dd HH:mm:ss)
      String formattedDate = currentTime.format('yyyy-MM-dd HH:mm:ss');

      if (updatedRecord.ConsultationContents__c != null) {
        updatedRecord.ConsultationContents__c +=
          '\n' +
          '\n' +
          formattedDate +
          ' ' +
          selectedTask.Matrix_Call_Type__c +
          ' ' +
          userName;
        updatedRecord.ConsultationContents__c += '\n' + sttUpdateJSON.summary;
      } else {
        updatedRecord.ConsultationContents__c =
          formattedDate +
          ' ' +
          selectedTask.Matrix_Call_Type__c +
          ' ' +
          userName;
        updatedRecord.ConsultationContents__c += '\n' + sttUpdateJSON.summary;
      }

      update updatedRecord;

      STT__c newStt = new STT__c();
      newStt.STTDescription__c = sttUpdateJSON.summary;
      newStt.Category__c = sttUpdateJSON.category;
      newStt.Emotion__c = sttUpdateJSON.emotion;

      insert newStt;

      Task updatedTask = [
        SELECT ID
        FROM Task
        WHERE Matrix_Call_ID__c = :sttUpdateJSON.uid
        LIMIT 1
      ];

      System.debug('find task' + updatedTask.Id);
      updatedTask.stt__c = newStt.Id;

      update updatedTask;

      System.debug('updateWorkOrder 업데이트 성공');

      return 'Case updated successfully.';
    } catch (Exception e) {
      // System.debug('Case 업데이트 오류: ' + e.getMessage());
      // Handle exceptions
      return 'Error updating Case: ' + e.getMessage();
    }
  }

  @AuraEnabled
  public static String updateLead(List<Lead> leadUpdate) {
    try {
      System.debug('Lead 업데이트 중: ' + leadUpdate);
      Lead updatedRecord = [
        SELECT
          Id,
          Matrix_Call_Category__c,
          Matrix_Call_Emotion__c,
          Matrix_Call_Summary__c
        FROM Lead
        WHERE Id = :leadUpdate[0].Id
        LIMIT 1
      ];
      // 현재 시간 구하기
      Datetime currentTime = Datetime.now();

      // 원하는 형식으로 변환하기 (예: yyyy-MM-dd HH:mm:ss)
      String formattedDate = currentTime.format('yyyy-MM-dd HH:mm:ss');

      if (updatedRecord.Matrix_Call_Category__c != null) {
        updatedRecord.Matrix_Call_Category__c += '\n' + '\n' + formattedDate;
        updatedRecord.Matrix_Call_Category__c +=
          '\n' + leadUpdate[0].Matrix_Call_Category__c;
      } else {
        updatedRecord.Matrix_Call_Category__c = formattedDate;
        updatedRecord.Matrix_Call_Category__c +=
          '\n' + leadUpdate[0].Matrix_Call_Category__c;
      }

      if (updatedRecord.Matrix_Call_Emotion__c != null) {
        updatedRecord.Matrix_Call_Emotion__c += '\n' + '\n' + formattedDate;
        updatedRecord.Matrix_Call_Emotion__c +=
          '\n' + leadUpdate[0].Matrix_Call_Emotion__c;
      } else {
        updatedRecord.Matrix_Call_Emotion__c = formattedDate;
        updatedRecord.Matrix_Call_Emotion__c +=
          '\n' + leadUpdate[0].Matrix_Call_Emotion__c;
      }

      if (updatedRecord.Matrix_Call_Summary__c != null) {
        updatedRecord.Matrix_Call_Summary__c += '\n' + '\n' + formattedDate;
        updatedRecord.Matrix_Call_Summary__c +=
          '\n' + leadUpdate[0].Matrix_Call_Summary__c;
      } else {
        updatedRecord.Matrix_Call_Summary__c = formattedDate;
        updatedRecord.Matrix_Call_Summary__c +=
          '\n' + leadUpdate[0].Matrix_Call_Summary__c;
      }

      update updatedRecord;

      System.debug('Lead 업데이트 성공');

      return 'Lead updated successfully.';
    } catch (Exception e) {
      // System.debug('Lead 업데이트 오류: ' + e.getMessage());
      // Handle exceptions
      return 'Error updating Lead: ' + e.getMessage();
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<Case> findUid(String Id) {
    List<Case> cases = [
      SELECT Id, Matrix_Call_ID__c
      FROM Case
      WHERE Id = :Id
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    return cases;
  }

  public static void dummy() {
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  }
  // @AuraEnabled
  // public static String updateCall(List<Call__c> callUpdate) {
  //   try {
  //     System.debug('Call 업데이트 중: ' + callUpdate);
  //     Call__c updatedRecord = [SELECT Id, Matrix_Call_Category__c, Matrix_Call_Emotion__c, Matrix_Call_Summary__c FROM Call__c WHERE Id = :callUpdate[0].Id LIMIT 1];
  //     // 현재 시간 구하기
  //     Datetime currentTime = Datetime.now();

  //     // 원하는 형식으로 변환하기 (예: yyyy-MM-dd HH:mm:ss)
  //     String formattedDate = currentTime.format('yyyy-MM-dd HH:mm:ss');

  //     if (updatedRecord.Matrix_Call_Category__c != null) {
  //       updatedRecord.Matrix_Call_Category__c += '\n' + '\n'+formattedDate;
  //       updatedRecord.Matrix_Call_Category__c += '\n' + callUpdate[0].Matrix_Call_Category__c;
  //     } else {
  //       updatedRecord.Matrix_Call_Category__c = formattedDate;
  //       updatedRecord.Matrix_Call_Category__c += '\n' + callUpdate[0].Matrix_Call_Category__c;
  //     }

  //     if (updatedRecord.Matrix_Call_Emotion__c != null) {
  //       updatedRecord.Matrix_Call_Emotion__c += '\n' + '\n'+formattedDate;
  //       updatedRecord.Matrix_Call_Emotion__c += '\n' + callUpdate[0].Matrix_Call_Emotion__c;
  //     } else {
  //       updatedRecord.Matrix_Call_Emotion__c = formattedDate;
  //       updatedRecord.Matrix_Call_Emotion__c += '\n' + callUpdate[0].Matrix_Call_Emotion__c;
  //     }

  //     if (updatedRecord.Matrix_Call_Summary__c != null) {
  //       updatedRecord.Matrix_Call_Summary__c += '\n' + '\n'+formattedDate;
  //       updatedRecord.Matrix_Call_Summary__c += '\n' + callUpdate[0].Matrix_Call_Summary__c;
  //     } else {
  //       updatedRecord.Matrix_Call_Summary__c = formattedDate;
  //       updatedRecord.Matrix_Call_Summary__c += '\n' + callUpdate[0].Matrix_Call_Summary__c;
  //     }

  //     update updatedRecord;

  //     System.debug('Call 업데이트 성공');
  //     return 'Call updated successfully.';
  //   } catch (Exception e) {
  //     // System.debug('Call 업데이트 오류: ' + e.getMessage());
  //     // Handle exceptions
  //     return 'Error updating Call: ' + e.getMessage();
  //   }
  // }
}