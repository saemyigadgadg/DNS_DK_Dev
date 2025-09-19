/**
 * @description       : (포탈) 판매가 > 조회 > 상세조회 > PDF
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 09-02-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-13-2025   daewook.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_priceDetailViewPDFController {
    public DN_PortalLoginUser.DealerInfo dli  {get; set;}
    public DN_PortalSaleProfressStatusController.StatusDetail detailInfo {get;set;}
    String peNo {get; set;}

    // 판매가 상세 조회
    public DN_priceDetailViewPDFController() {
        Map<String, String> paramInfo = ApexPages.currentPage().getParameters();
        peNo      = paramInfo.get('peNo');

        system.debug('peNo>> '+peNo);

        String userId = System.UserInfo.getUserId();
        dli = DN_PortalLoginUser.GetUserInfo(userId);
        system.debug('dli >> ' + dli);

        detailInfo = DN_PortalSaleProfressStatusController.GetStatusDetail(dli, peNo);
        system.debug('detailInfo >>> ' +detailInfo);

        List<DN_PortalSaleProfressStatusController.StatusRecord> itemList = (List<DN_PortalSaleProfressStatusController.StatusRecord>) detailInfo.statusRecord;
        system.debug('itemList >>>' + itemList);

        for (DN_PortalSaleProfressStatusController.StatusRecord srd : itemList) {
            if (srd.suggestPrice != null) { 
                srd.suggestPrice = addCommas(srd.suggestPrice);
            }

            if (srd.systemPrice != null) { 
                srd.systemPrice = addCommas(srd.systemPrice);
            }

            if (srd.newPrice != null) { 
                srd.newPrice = addCommas(srd.newPrice);
            }
        }
    }

    // 단위 표시
    public static String addCommas(String numberStr) {
        if (String.isEmpty(numberStr)) return '';
    
        // 숫자로 변환 시도
        try {
            Decimal num = Decimal.valueOf(numberStr);
            return num.format(); // Apex의 Decimal.format() 사용하여 천 단위 콤마 추가
        } catch (Exception e) {
            return numberStr; // 숫자로 변환할 수 없으면 원래 문자열 반환
        }
    }
}