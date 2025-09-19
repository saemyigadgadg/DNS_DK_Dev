/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 02. 12. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-12 | Iltae seo      | 최초작성 
 */
public with sharing class DN_DealerPortalSettings {
    private String CUSTOMPERMISSION {get;set;} // 커스텀 퍼미션 명
    
    
    public DN_DealerPortalSettings(String customPermission) {
        this.CUSTOMPERMISSION = customPermission;
    }

    /**
     * @Description
     * 	- 조건에 따라 settings 정보 리턴
    **/ 
    public Setting getSettings() {
        Boolean hasPermission = hasCustomPermission();
        if(hasPermission) {
            DealerPortalUserSetting__mdt setMdt = DealerPortalUserSetting__mdt.getInstance(this.CUSTOMPERMISSION);
            Setting settings = new Setting(setMdt);
            return settings;
        } else {
            User u = [SELECT Id, Name, Account.CustomerCode__c, SalesOrganization__c,DistributionChannel__c,Division__c,Plant__c FROM User where Id=:UserInfo.getUserId()];
            Setting settings = new Setting().convetSetting(u,this.CUSTOMPERMISSION);
            return settings;
        }
    }

    /**
     * @Description
     * 	- Permission 권한 확인
    **/ 
    public Boolean hasCustomPermission() {
        return FeatureManagement.checkPermission(this.CUSTOMPERMISSION);
    }

    /**
     * @Description
     * 	- 우선순위가 높은 User 정보 가져오기
    **/ 
    public static Setting getHighPrioritySettings() {
        DN_DealerPortalSettings settingManager;
        Setting currentSetting = new Setting();
        for(DealerPortalUserSetting__mdt userSettingMdt : [ SELECT 
                    DeveloperName,
                    DealerCode__c,
                    DistributionChannel__c,
                    Division__c,
                    Plant__c,
                    SalesOrganization__c,
                    Priority__c
             FROM DealerPortalUserSetting__mdt ORDER BY Priority__c asc]) {
                settingManager =  new DN_DealerPortalSettings(userSettingMdt.DeveloperName);
                System.debug('hasCustomPermission: ' +settingManager.hasCustomPermission());
                if(settingManager.hasCustomPermission()) {
                    System.debug('userSettingMdt : '+ userSettingMdt.DeveloperName);
                    currentSetting = new Setting(userSettingMdt);
                    break;
                }
        }
        return currentSetting;
    }

    /**
     * @Description
     * 	- Setting 클래스
    **/ 
    public class Setting {
        private Boolean isSourceMeta = false;
        private Boolean hasCustomPermission = false;
        public String DealerCode {get;set;}
        public String DistributionChannel {get;set;}
        public String Division {get;set;}
        public String Plant {get;set;}
        public String SalesOrganization {get;set;}
        public Setting() {
            setHasCustomPermission(false);
        }

        /**
         * @Description
         * 	- hasCustomPermission 유무 반환
        **/ 
        public Boolean getHasCustomPermission() {
            return this.hasCustomPermission;
        }

        /**
         * @Description
         * 	- hasCustomPermission 유무 반환
        **/
        public void setHasCustomPermission(Boolean hasCustomPermission) {
            this.hasCustomPermission = hasCustomPermission;
        }
        
        /**
         * @Description
         * 	- 메타데이터인지 유무 체크
        **/
        public Boolean getIsSourceMeta() { 
            return this.isSourceMeta; 
        }

        public Setting(DealerPortalUserSetting__mdt mdt) {
            this.DealerCode             = mdt.DealerCode__c;
            this.DistributionChannel    = mdt.DistributionChannel__c;
            this.Division               = mdt.Division__c;
            this.Plant                  = mdt.Plant__c;
            this.SalesOrganization      = mdt.SalesOrganization__c;
            this.isSourceMeta = true;
            setHasCustomPermission(true);
        }

        /**
         * @Description
         * 	- 퍼미션이 false일때 User의 정보중에 없는 경우도 대비하기 위해 설정
        **/
        public Setting convetSetting(User use, String customPermission) {
            DealerPortalUserSetting__mdt defaultSetting = DealerPortalUserSetting__mdt.getInstance(customPermission);
            Setting settings = new Setting();
            settings.DealerCode           = String.isBlank(use.Account.CustomerCode__c)?             defaultSetting.DealerCode__c           : use.Account.CustomerCode__c;
            settings.DistributionChannel  = String.isBlank(use.DistributionChannel__c)?              defaultSetting.DistributionChannel__c  : use.DistributionChannel__c;
            settings.Division             = String.isBlank(use.Division__c)?                         defaultSetting.Division__c             : use.Division__c;
            settings.Plant                = String.isBlank(use.Plant__c)?                            defaultSetting.Plant__c                : use.Plant__c;  
            settings.SalesOrganization    = String.isBlank(use.SalesOrganization__c)?                defaultSetting.SalesOrganization__c    : use.SalesOrganization__c;
            settings.isSourceMeta = false;
            
            return settings;
        }
            
    }
}