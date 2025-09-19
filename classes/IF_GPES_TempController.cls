/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-09-01
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-04-04   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public without sharing class IF_GPES_TempController {

    public String childDomain   { get; set; }
    public String gijong        { get; set; }
    public String hogi          { get; set; }
    public String type          { get; set; }
    public String part_no       { get; set; }
    public String loginNo       { get; set; }

    // GPES화면의 Apex Page의 생성자
    public IF_GPES_TempController() {
        Map<String, String> parameterMap = new Map<String, String>();
        if (!Test.isRunningTest()) {
            parameterMap = ApexPages.currentPage().getParameters();
        }

        this.childDomain = System.Label.DN_GPES_Url;
        
        User currentUser = [SELECT Id, EmployeeNumber, Portal_EmployeeNumber__c FROM User WHERE Id =:UserInfo.getUserId()];

        String loginCode = currentUser.EmployeeNumber == null || currentUser.EmployeeNumber == '' ? (currentUser.Portal_EmployeeNumber__c == null || currentUser.Portal_EmployeeNumber__c == '' ? 'mtgpesadmin' : currentUser.Portal_EmployeeNumber__c) : currentUser.EmployeeNumber;

        this.loginNo = loginCode;

        this.gijong = parameterMap.get('gijong') == null ? '' : parameterMap.get('gijong');
        this.hogi = parameterMap.get('hogi') == null ? '' : parameterMap.get('hogi');
        this.type = parameterMap.get('type') == null ? '' : parameterMap.get('type');
        this.part_no = parameterMap.get('part_no') == null ? '' : parameterMap.get('part_no');

    }

}