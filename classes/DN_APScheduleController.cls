/**
 * @description       : 채무 >> 스케줄
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 07-24-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-24-2024   daewook.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_APScheduleController {
    public DN_APScheduleController() {}

    // 로그인하는 사용자 정보
    @AuraEnabled
    public static DN_PortalLoginUser.DealerInfo GetUserInfo(){
            String userId = System.UserInfo.getUserId();
            DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId);
            return dealerInfo;
    }

    // 스케줄 조회
    @AuraEnabled
    public static IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res GetApList(DN_PortalLoginUser.DealerInfo dli){
        try {
            IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Req req = new IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Req();
            IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Req_I_USERINFO();

            I_USERINFO.KUNNR        = dli.dealerCode;
            I_USERINFO.VKORG        = dli.salesOrganization;
            I_USERINFO.VTWEG        = dli.distributionChannel;
            I_USERINFO.SPART        = dli.division;
            I_USERINFO.LAND1        = dli.country;
            I_USERINFO.DF_CHK       = 'X'; 
        
            req.I_USERINFO          = I_USERINFO;
        
            IF_ERP_Parts_Pending instance = new IF_ERP_Parts_Pending();
            IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res result = instance.IF_PARTS_021(req);
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}