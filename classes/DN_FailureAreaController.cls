/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 06-02-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public with sharing class DN_FailureAreaController {

    // 고장부위(대)
    // @AuraEnabled
    // public static List<CustomSelectOption> getFailureAreaMajor(String objectType) {
    //     List<CustomSelectOption> result = new List<CustomSelectOption>();
        
    //     if (String.isBlank(objectType)) {
    //         return result;
    //     }
 
    //     List<FailureArea_Major__c> majorList = [
    //         SELECT Id, FailureAreaMajor_Value__c, FailureAreaMajor_Label__c, FM_FailureAreaMajor_Label__c
    //         FROM FailureArea_Major__c
    //         WHERE ModelCategory__c = :objectType
    //     ];
 
    //     for (FailureArea_Major__c major : majorList) {
    //         result.add(new CustomSelectOption(major.FM_FailureAreaMajor_Label__c, major.FailureAreaMajor_Value__c));
    //     }
    //     return result;
    // }
    // 고장부위(대)
    @AuraEnabled
    public static List<CustomSelectOption> getFailureAreaMajor(String objectType) {
        List<CustomSelectOption> result = new List<CustomSelectOption>();

        if (String.isBlank(objectType)) {
            return result;
        }

        String profileId = UserInfo.getProfileId();
        String profileName = [SELECT Name FROM Profile WHERE ID = :profileId].Name;

        List<FailureArea_Major__c> majorList = new List<FailureArea_Major__c>();
        if(profileName.contains('DNSA')){
            majorList = [
                SELECT Id, FailureAreaMajor_Value__c, FailureAreaMajor_Label__c, FM_FailureAreaMajor_Label__c, Branch__c
                FROM FailureArea_Major__c
                WHERE ModelCategory__c = :objectType AND Branch__c IN ('ALL', 'DNSA')
            ];
        }else{
            majorList = [
                SELECT Id, FailureAreaMajor_Value__c, FailureAreaMajor_Label__c, FM_FailureAreaMajor_Label__c, Branch__c
                FROM FailureArea_Major__c
                WHERE ModelCategory__c = :objectType AND Branch__c IN ('ALL', 'DNS')
            ];
        }

        if(majorList.size()>0){
            for (FailureArea_Major__c major : majorList) {
                result.add(new CustomSelectOption(major.FM_FailureAreaMajor_Label__c, major.FailureAreaMajor_Value__c));
            }
        }
        
        return result;
    }

    // 고장부위(중)
    @AuraEnabled
    public static List<CustomSelectOption> getFailureAreaMiddle(String majorValue) {
        List<CustomSelectOption> result = new List<CustomSelectOption>();

        if (String.isBlank(majorValue)) {
            return result;
        }

        List<FailureAreaMiddle__c> middleList = [
            SELECT Id, CodeGroup__c, FailureAreaMiddle_Value__c, FailureAreaMiddle_Label__c, ERPCodeGroup__c, FM_FailureAreaMiddle_Label__c
            FROM FailureAreaMiddle__c
            WHERE CodeGroup__c = :majorValue
        ];

        for (FailureAreaMiddle__c middle : middleList) {
            result.add(new CustomSelectOption(middle.FM_FailureAreaMiddle_Label__c, middle.FailureAreaMiddle_Value__c));
        }
        return result;
    }

    // 고장현상
    @AuraEnabled
    public static List<CustomSelectOption> getFailurePhenomenon(String middleValue) {
        List<CustomSelectOption> result = new List<CustomSelectOption>();

        if (String.isBlank(middleValue)) {
            return result;
        }

        List<FailurePhenomenon__c> phenomenonList = [
            SELECT Id, CodeGroup__c, FailurePhenomenon_Value__c , FailurePhenomenon_Label__c, FM_FailurePhenomenon_Label__c
            FROM FailurePhenomenon__c
            WHERE CodeGroup__c = :middleValue
        ];

        for (FailurePhenomenon__c phenomenon : phenomenonList) {
            result.add(new CustomSelectOption(phenomenon.FM_FailurePhenomenon_Label__c, phenomenon.FailurePhenomenon_Value__c));
        }
        return result;
    }

    // 고장원인
    @AuraEnabled
    public static List<CustomSelectOption> getFailureCause(String phenomenonValue) {
        List<CustomSelectOption> result = new List<CustomSelectOption>();

        if (String.isBlank(phenomenonValue)) {
            return result;         
        }

        List<FailureCause__c> causeList = [
            SELECT Id, CodeGroup__c, FailureCause_Code__c, FailureCause_Label__c, FM_FailureCause_Label__c
            FROM FailureCause__c
            WHERE CodeGroup__c = :phenomenonValue
        ];
            
        for (FailureCause__c cause : causeList) {
            result.add(new CustomSelectOption(cause.FM_FailureCause_Label__c, cause.FailureCause_Code__c));
        }   
        return result;
    }

    // 조치내역
    @AuraEnabled
    public static List<CustomSelectOption> getRepairAction(String objectType) {
        List<CustomSelectOption> result = new List<CustomSelectOption>();

        if (String.isBlank(objectType)) {
            return result;
        }

        List<RepairAction__c> repairList = [
            SELECT Id, ModelCategory__c, RepairAction_Label__c, RepairAction_Value__c, FM_Repaire_Action_Label__c
            FROM RepairAction__c
            WHERE ModelCategory__c = :objectType
        ];

        for (RepairAction__c repair : repairList) {
            result.add(new CustomSelectOption(repair.FM_Repaire_Action_Label__c, repair.RepairAction_Value__c));
        }
        return result;
    }


    public class CustomSelectOption {
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
    
        public CustomSelectOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

}