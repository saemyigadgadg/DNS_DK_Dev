/** 
 * @Class :  DN_UserDetails
 * 
 * @Test: 
 * @Author : Hyunwook Jin 
 * @Date : 2024. 12. 24. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2024-12-24 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_UserDetails {
    public DN_UserDetails() {}

    /*
    * @ Description : 현재 유저 정보
    *  
    */
    private User currentUser {
        get {
            if(currentUser == null) {
                currentUser = [
                    SELECT Id, Profile.Name,  
                           AccountId, 
                           Account.SalesOrganization__c,
                           Account.DistributionChannel__c, 
                           Account.Division__c,
                           Account.Name, 
                           Account.CustomerCode__c,
                        Account.DealerGrade__c,  //영업 대리점 등급
                           Account.DealerGrade_Parts__c, //부품 대리점 등급
                           UserType,
                           LanguageLocaleKey,
                           Country__c,
                           SalesOrganization__c, DistributionChannel__c, Division__c 
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
                    LIMIT 1
                ];
            }
            return currentUser;
        }
        set;
    }

    /*
    * @ Description : 현재 유저 기준 Account 정보
    */
    private Account currentAccount {
        get {
            if(currentAccount == null) {
                for(SalesAreaData__c salesAreaData :[
                    SELECT Account__c, Account__r.CustomerCode__c, Account__r.Name, Account__r.DealerGrade__c, Account__r.DealerGrade_Parts__c
                    FROM SalesAreaData__c
                    WHERE 
                        Account__r.CustomerCode__c = :getAgencyCustomerCode() AND Account__r.RecordType.DeveloperName = 'Dealer'
                    AND SalesOrganization__c = :getSalesOranization() AND CustomerGroup__c = '02'
                ]) {
                    currentAccount = (Account)salesAreaData.getSObject('Account__r');
                }
            }

            //Maximum stack depth reached: 1001 Error 방지
            if(currentAccount == null) currentAccount = new Account();

            return currentAccount;
        } 
        set;
    }

    /*
    * @ Description : DealerPortalUserSetting__mdt 기준으로 설정 정보 
    */
    private DN_DealerPortalSettings.Setting settingInfo {
        get {
            if(settingInfo == null) settingInfo = DN_DealerPortalSettings.getHighPrioritySettings();
            return settingInfo;
        }
        set;
    }

    /*
    * @ Method : getSalesOranization
    * @ Description : settingInfo 기준으로 SalesOrganization 정보 반환
    */
    public String getSalesOranization() {
        if(settingInfo.getHasCustomPermission()) {
            return settingInfo.SalesOrganization;
        }
        return getSalesOranizationByUser();
    }
    
    /*
    * @ Method : getSalesOranizationByUser
    * @ Description : 현재 유저 기준으로 SalesOrganization 정보 반환
    */
    public String getSalesOranizationByUser() {
        return currentUser.SalesOrganization__c;
    }

    /*
    * @ Method : getDistributionChannel
    * @ Description : settingInfo 기준으로 DistributionChannel 정보 반환
    */
    public String getDistributionChannel() {
        if(settingInfo.getHasCustomPermission()) {
            return settingInfo.DistributionChannel;
        }
        return getDistributionChannelByUser();
    }
    
    /*
    * @ Method : getDistributionChannelByUser
    * @ Description : 현재 유저 기준으로 DistributionChannel 정보 반환
    */
    public String getDistributionChannelByUser() {
        return currentUser.DistributionChannel__c;
    }

    /*
    * @ Method : getDivision
    * @ Description : settingInfo 기준으로 Division 정보 반환
    */
    public String getDivision() {
        if(settingInfo.getHasCustomPermission()) {
            return settingInfo.Division;
        }
        return getDivisionByUser();
    }

    /*
    * @ Method : getDivisionByUser
    * @ Description : 현재 유저 기준으로 Division 정보 반환
    */
    public String getDivisionByUser() {
        return currentUser.Division__c;
    }

    /*
    * @ Method : getAgencyId
    * @ Description : currentAccount 기준으로 Id 반환
    */
    public String getAgencyId() {
        if(settingInfo.getHasCustomPermission() && String.isNotBlank(currentAccount.Id)) {
            return currentAccount.Id;
        }
        return getAgencyIdByUser();
    }

    /*
    * @ Method : getAgencyIdByUser
    * @ Description : 현재 유저 기준으로 Id 반환
    */
    public String getAgencyIdByUser() {
        return currentUser.AccountId;
    }

    /*
    * @ Method : getAgencyCustomerCode
    * @ Description : settingInfo 기준으로 대리점 코드 반환
    */
    public String getAgencyCustomerCode() {
        if(settingInfo.getHasCustomPermission() && String.isNotBlank(settingInfo.DealerCode)) {
            return settingInfo.DealerCode;
        }

        return getAgencyCustomerCodeByUser();
    }

    /*
    * @ Method : getAgencyCustomerCodeByUser
    * @ Description : 현재 유저 기준으로 Customer Code 반환
    */
    public String getAgencyCustomerCodeByUser() {
        return currentUser.Account.CustomerCode__c;
    }

    /*
    * @ Method : getAgencyName
    * @ Description : currentAccount 기준으로 대리점명 반환
    */
    public String getAgencyName() {
        if(settingInfo.getHasCustomPermission() && String.isNotBlank(currentAccount.Name)) {
            return currentAccount.Name;
        }
        return currentUser.Account.Name;
    }

    /*
    * @ Method : getCountry
    * @ Description : currentUser 기준으로 국가 반환
    */
    public String getCountry() {
        return String.isNotEmpty(currentUser.Country__c) ? currentUser.Country__c : 'KR';
    }

    /*
    * @ Method : getLanguageLocaleKey
    * @ Description : currentUser 기준으로 언어 반환
    */
    public String getLanguageLocaleKey() {
        return currentUser.LanguageLocaleKey;
    }

    /*
    * @ Method : getDealerGrade
    * @ Description : DealerGrade_Parts 반환
    */
    public String getDealerGrade() {
        if(settingInfo.getHasCustomPermission() && String.isNotBlank(currentAccount.DealerGrade_Parts__c)) {
            return currentAccount.DealerGrade_Parts__c;
        }
        return getDealerGradeByUser();
    }

    /*
    * @ Method : getDealerGradeByUser
    * @ Description : 현재 유저 기준으로 DealerGrade_Parts 반환
    */
    public String getDealerGradeByUser() {
        return currentUser.Account?.DealerGrade_Parts__c;
    }

    /*
    * @ Method : getDealerGradeRate
    * @ Description : gradeRate(등급 할인율) 반환
    */
    public Decimal getDealerGradeRate() {
        Decimal gradeRate = 0;
        String grade = getDealerGrade();
        if(grade == null) grade = '';
        gradeRate = getDealerGradeRateAll().get(grade);
        return gradeRate;
    }

    /*
    * @ Method : getDealerGradeRateAll
    * @ Description : gradeRate(등급 할인율) 전부 반환
    */
    public Map<String,Decimal> getDealerGradeRateAll() {
        Map<String,Decimal> gradeRateMap = new Map<String, Decimal>();

        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Req req = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Req();
        req.I_CON_TYPE      = 'YAI0';
        req.I_VKORG         = getSalesOranizationByUser();
        req.I_PLTYP         = '10';
        DateTime now = System.now();
        String todayStr = now.format('yyyy-MM-dd');

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res response = 
                    (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res)instance.IF_DEALERSTOCK_009(req);
        // System.debug(JSON.serializePretty(response));
        if('S'.equals(response.O_RETURN.TYPE)) {
            for(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res_T_RETURN ifResult : response.T_RETURN) {        
                if(ifResult.DATAB <= todayStr && todayStr <= ifResult.DATBI )  { //&& grade.equals(ifResult.ZZKVGR4)
                    //등급별 할인율
                    gradeRateMap.put(ifResult.ZZKVGR4 , Decimal.valueOf(ifResult.KBETR) / 100);
                    
                }
            }
        }
        return gradeRateMap;
    }

    /*
    * @ Method : getIsAdmin
    * @ Description : Admin 유무 반환
    */
    public Boolean getIsAdmin() {
        Boolean isAdmin = false;

        if('시스템 관리자'.equals(currentUser.Profile.Name) || 'System Administrator'.equals(currentUser.Profile.Name)) isAdmin = true;
        if('Standard'.equals(currentUser.UserType)) isAdmin = true;

        return isAdmin;
    }
}