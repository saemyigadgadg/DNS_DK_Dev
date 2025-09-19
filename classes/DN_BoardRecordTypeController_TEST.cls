@isTest
public class DN_BoardRecordTypeController_TEST {
    

    @isTest
    static void testGetDefaultValue() {
        // 클래스 인스턴스 생성
        DN_BoardRecordTypeController controller = new DN_BoardRecordTypeController();

        // getDefaultValue() 호출 및 검증
        VisualEditor.DataRow defaultValue = controller.getDefaultValue();
    }

    @isTest
    static void testGetValues() {
        // 클래스 인스턴스 생성
        DN_BoardRecordTypeController controller = new DN_BoardRecordTypeController();

        // getValues() 호출
        VisualEditor.DynamicPickListRows result = controller.getValues();

        
        
        
        // // 데이터가 올바르게 추가되었는지 확인
        // List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE IsActive = true AND SObjectType = 'Board__c'];
        // // RecordType 데이터가 포함되어 있는지 확인
        // Boolean found = false;
        // for (VisualEditor.DataRow row : result.rows) {DN_BoardRecordTypeController_TEST
        //     if (row.Name == 'Type A' || row.Name == 'Type B') {
        //         found = true;
        //         break;
        //     }
        // }
    }
}