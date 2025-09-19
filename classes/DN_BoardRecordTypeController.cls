global class DN_BoardRecordTypeController extends VisualEditor.DynamicPickList {
    /**
     * @description       : 게시판 레코드 타입 기본값(All)
     * @author            : iltae.seo
     * @group             : 
     * @last modified on  : 05-13-2025
     * @last modified by  : iltae.seo
    **/
    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('All', 'All');
        return defaultValue;
    }

    /**
     * @description       : 게시판 레코드 타입 목록 
     * @author            : iltae.seo
     * @group             : 
     * @last modified on  : 05-13-2025
     * @last modified by  : iltae.seo
    **/
    global override VisualEditor.DynamicPickListRows getValues() {
        List<RecordType> recordTypeList = [select Id, Name, DeveloperName, SobjectType,IsActive from RecordType where IsActive =true AND SobjectType ='Board__c'];
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues.addRow(new VisualEditor.DataRow('All', 'All'));
        for(RecordType rec : recordTypeList) {
            VisualEditor.DataRow value = new VisualEditor.DataRow(rec.Name, String.valueOf(rec.Id));
            myValues.addRow(value);
        }
        return myValues;
    }
}