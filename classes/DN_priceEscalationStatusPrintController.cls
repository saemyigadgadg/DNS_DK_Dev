/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 07-24-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-13-2025   daewook.kim@sbtglobal.com   Initial Version
**/
public without sharing class DN_priceEscalationStatusPrintController {
    public String statusValue {get; set;}
    
    public DN_PortalLoginUser.DealerInfo dli { get; set; }
    public DN_PortalSaleProfressStatusController.Params prs {get; set;}
    public List<DN_PortalSaleProfressStatusController.StatusResult> srt {get; set;}
    public String line {get; set;}
    public Integer listSize {get; set;}

    public Boolean showMessage {get; set;}

    // PDF용 정보 추출
    public DN_priceEscalationStatusPrintController() {

        Map<String, String> searchInfo = ApexPages.currentPage().getParameters();
        String startDate = searchInfo.get('sDate');
        String endDate   = searchInfo.get('eDate');
        String poNo      = searchInfo.get('pon');
        String peNo      = searchInfo.get('pen');
        String pageNo    = searchInfo.get('page');
        String status    = searchInfo.get('status');

        statusValue = status == '' ? 'All' : status == 'Q' ? '확인중' : status == 'A' ? '승인' : '거절';

        prs = new DN_PortalSaleProfressStatusController.Params();
        prs.startDate = startDate;
        prs.endDate   = endDate;
        prs.poNo      = poNo;
        prs.peNo      = peNo;
        prs.pageNo    = pageNo;
        prs.status    = status;

        String userId = System.UserInfo.getUserId();
        dli = DN_PortalLoginUser.GetUserInfo(userId);

        Map<String,Object> pageData = DN_PortalSaleProfressStatusController.GetStatusList(dli, prs);

        line = String.valueOf(pageData.get('line'));

        List<DN_PortalSaleProfressStatusController.StatusResult> allData =
            (List<DN_PortalSaleProfressStatusController.StatusResult>) pageData.get('list');

        srt = filtering(allData, poNo, peNo);
        system.debug('길이:: ' +srt.size());
        if(srt.size() == 1) {
            showMessage = true;
        }else {
            showMessage = false;
        }

        system.debug('Filtered list >> ' + srt);

        listSize = srt.size();
    }


    // 정보 필터링
    public static List<DN_PortalSaleProfressStatusController.StatusResult> filtering(
        List<DN_PortalSaleProfressStatusController.StatusResult> dataList, 
        String poNo, 
        String peNo
    ) {
        List<DN_PortalSaleProfressStatusController.StatusResult> filteredList = new List<DN_PortalSaleProfressStatusController.StatusResult>();

        // poNo, peNo가 모두 비어 있으면 전체 데이터 반환
        if (String.isEmpty(poNo) && String.isEmpty(peNo)) {
            return dataList;
        }

        // 필터링 로직 실행
        for (DN_PortalSaleProfressStatusController.StatusResult record : dataList) {
            Boolean matchPoNo = String.isNotEmpty(poNo) ? record.poNo == poNo : true;
            Boolean matchPeNo = String.isNotEmpty(peNo) ? String.valueOf(record.peNo) == peNo : true;

            // poNo, peNo 조건을 만족하는 데이터만 추가
            if (matchPoNo && matchPeNo) {
                filteredList.add(record);
            }
        }

        return filteredList;
    }
}