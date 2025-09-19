/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-11-20   yuhyun.park@sbtglobal.com   Initial Version
**/
public with sharing class DN_AccountValidateForLeadController {

    // 기존에 생성된 Account 레코드와 중복되는지 확인
    @AuraEnabled
    public static String checkAccountDuplication(String recordId) {
        String result;
        try {

            List<Lead> leadList = [
                SELECT Id, Company, Representative__c, IsERPValidated__c
                FROM Lead 
                WHERE Id = :recordId 
                LIMIT 1
                ];

            System.debug(' leadList :: ' + leadList);

            Map<String, Object> fieldMap = new Map<String, Object>();

            if(leadList[0].IsERPValidated__c){
                result = 'Validated';
                return result;
            }

            if (String.isBlank(leadList[0].Representative__c) || String.isBlank(leadList[0].Company)) {
                result = 'Required for Vaildate Missing';
                System.debug(result);
                return result;
            }

            if(!leadList.isEmpty()){
                fieldmap.put('Company', leadList[0].Company);
                fieldmap.put('Representative', leadList[0].Representative__c);
            }

            System.debug(' fieldMap :: ' + fieldMap);


            if(!fieldMap.isEmpty()){
                IF_ERP_Account_Classes.IF_ACCOUNT_014_Res erpResponse = interfaceAccount014(fieldMap);

                System.debug(' erpResponse :: ' + erpResponse);

                // 중복 없음 (고객 생성 가능)
                if (erpResponse.O_RECODE == 'S') {
                    result = 'Success';
                    System.debug('ERP Success');

                    // update IsERPValidated__c 
                    if (!leadList.isEmpty()) {
                        Lead leadToUpdate = leadList[0];
                        leadToUpdate.IsERPValidated__c = true;
                        update leadToUpdate;
                        System.debug('Lead IsERPValidated__c updated to true');
                    }

                // 중복 (고객 생성 불가능)
                }else if(erpResponse.O_RECODE == 'F' && erpResponse.O_RETURN == 'Y'){
                    result = 'Duplicate';

                // 통신 에러
                }else{
                    result = 'ERP validation failed: ' + (erpResponse.O_REMSG != null ? erpResponse.O_REMSG : 'Unknown error');
                    System.debug('ERP Fail');
                }
            }
            return result;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('ERP 통신 실패: ' + e.getMessage());
        }
    }


    private static IF_ERP_Account_Classes.IF_ACCOUNT_014_Res interfaceAccount014(Map<String, Object> fieldMap) {
        IF_ERP_Account_Classes.IF_ACCOUNT_014_Req erpParameters = new IF_ERP_Account_Classes.IF_ACCOUNT_014_Req();

        erpParameters.I_NAME1       = (String) fieldMap.get('Company');
        erpParameters.I_J_1KFREPRE  = (String) fieldMap.get('Representative');


        System.debug(' erpParameters :: ' + erpParameters);

        IF_ERP_Account erpService = new IF_ERP_Account();
        return erpService.IF_ACCOUNT_014(erpParameters);

    }
}