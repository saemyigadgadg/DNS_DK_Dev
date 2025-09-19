/**
 * @description       : 반품조회 >> 상세 >> 프린트
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 03-26-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-13-2025   daewook.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_PurchaseOrderPDFController {
    public String returnOrderNo                      { get; set; }
    public PurchaseOrder__c pco                      { get; set; }
    public DN_PortalLoginUser.DealerInfo dli         { get; set; }
    public DN_PortalPartWrapper.ReturnPDF returnPDF  { get; set; }

    public DN_PurchaseOrderPDFController(ApexPages.StandardController controller) {
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        returnOrderNo = params.get('returnOrderNo');
        System.debug('Return Order No: ' + returnOrderNo);

        String userId = System.UserInfo.getUserId();
        dli = DN_PortalLoginUser.GetUserInfo(userId);

        pco = [
                SELECT PartOrderNo__c, CustomerOrderNo__c, OriginDocDate__c, CurrencyIsoCode, CreatedDate, 
                       (
                           SELECT Id, ItemNo__c, Invoice__c, OrderPartNo__c, PartName__c,
                                  SupplyPartNo__c, Description__c, Quantity__c,
                                  Unit__c, UnitPrice__c, CurrencyIsoCode,
                                  NetValue__c, Note__c, OriginDocDate__c,
                                  ReturnStatus__c, ComplaintReason1__c, ComplaintReason2__c
                           FROM PurchaseOrderItems__r
                       )
                FROM PurchaseOrder__c
                WHERE PartOrderNo__c = :returnOrderNo
                Limit 1
        ];
        system.debug('pco >>>>>' + pco);
        returnPDF = new DN_PortalPartWrapper.ReturnPDF(pco, dli);        
        System.debug('returnPDF :: ' + returnPDF);
    }
}