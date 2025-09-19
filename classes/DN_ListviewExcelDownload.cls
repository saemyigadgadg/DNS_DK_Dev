/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-07-25
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-10-29   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_ListviewExcelDownload {
    private ApexPages.StandardSetController controller;
    public SObject obj                  { get; set; }
    public String listviewId            { get; set; }
    public String objType               { get; set; }
    public String objName               { get; set; }
    // public String jsonString            { get; set; }
    public String returnUrl             { get; set; }

    // 리스트 뷰 화면의 엑셀다운로드 버튼을 위한 Apex Page 생성자
    public DN_ListviewExcelDownload(ApexPages.StandardSetController controller) {
        this.controller = controller;
        // controller.setPageSize(100);
        this.obj = controller.getRecord();
        this.listviewId = controller.getFilterId();
        System.debug('filterId ::: ' + this.listviewId);
        this.objType = String.valueOf(this.obj.getSobjectType());
        this.objName = Schema.getGlobalDescribe().get(this.objType).getDescribe().getLabel();

        // this.jsonString = getListColumns(this.objType, this.listviewId);
        
        String host = URL.getOrgDomainUrl().getHost();
        this.returnUrl = 'https://' + host + '/lightning/o/' + objType + '/list?filterName=' + this.listviewId;
        System.debug('returnUrl ::: ' + this.returnUrl);
    }
}