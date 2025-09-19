/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 05-19-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-27-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_PortalPartWrapperTest {
    @TestSetup
    static void makeData(){
        PurchaseOrder__c pco = new PurchaseOrder__c(
            PartOrderNo__c      = '7100253598'
            ,CustomerOrderNo__c = 'TestCONo'
            ,OriginDocDate__c   = Date.valueOf('2024-03-29')
            ,CurrencyIsoCode    = 'KRW'
        );
        insert pco;

        PurchaseOrderItems__c pci = new PurchaseOrderItems__c(
            PurchaseOrder__c = pco.Id
            ,ItemNo__c       = '000011'
            ,Invoice__c      = '9006380060'
            ,OrderPartNo__c  = 'R46946'
            ,Description__c  = 'ELBOW;ONE TOUCH(COMPACT)'
            ,Quantity__c     = Decimal.valueOf('20')
            ,Unit__c         = 'EA'
            ,UnitPrice__c    = Decimal.valueOf('1400')
            ,CurrencyIsoCode = 'KRW'
            ,Note__c         = '반품 생성 확장자 확인'
            ,OriginDocDate__c    = Date.valueOf('2024-03-29')
            ,ComplaintReason1__c = 'B'
            ,ComplaintReason2__c = 'B01'
        );
        insert pci;
    }

    @isTest
    static void Test_CreateReturnOrderTerms() {
        Date today = Date.today();

        DN_PortalLoginUser.DealerInfo dealerInfo = new DN_PortalLoginUser.DealerInfo();
        dealerInfo.dealerCode  = '';
        dealerInfo.accountName = '';
        dealerInfo.accountCEO  = '';

        List<DN_PortalPartWrapper.RoiList> roiList = new List<DN_PortalPartWrapper.RoiList>();
        DN_PortalPartWrapper.RoiList ror = new DN_PortalPartWrapper.RoiList();
        ror.sequenceNumber  = 100;
        ror.orderPartNo     = '';
        ror.partName        = '';
        ror.cpReasonOne     = '';
        ror.cpReasonTwo     = '';
        ror.cpNote          = '';
        ror.invoiceNo       = '';
        ror.salesDate       = '';
        ror.returnStatus    = '';
        ror.returnQuantity  = 100;
        ror.unit            = '';
        ror.unitPrice       = '100';
        ror.totalAmount     = 100;
        roiList.add(ror);

        List<DN_PortalPartWrapper.FileInfo> fiList = new List<DN_PortalPartWrapper.FileInfo>();
        DN_PortalPartWrapper.FileInfo fif = new DN_PortalPartWrapper.FileInfo();
        fif.INT_NO      = '';
        fif.DOCU_ITEM   = '';
        fif.FILE_ID     = '';
        fif.FILE_DOC_ID = '';
        fif.FILE_NAME   = '';
        fif.DESCRIPTION = '';
        fif.FILE_NO     = '';
        fif.FILE_DATA   = '';

        fiList.add(fif);

        List<DN_PortalPartWrapper.CrmFileInfo> crList = new List<DN_PortalPartWrapper.CrmFileInfo>();
        DN_PortalPartWrapper.CrmFileInfo cfi = new DN_PortalPartWrapper.CrmFileInfo();
        cfi.Id          = '';
        cfi.ContentSize = '';
        cfi.Title       = '';
        cfi.verId       = '';

        crList.add(cfi);

        List<DN_PortalPartWrapper.RefundDetail> rdList = new List<DN_PortalPartWrapper.RefundDetail>();
        DN_PortalPartWrapper.RefundDetail rdl = new DN_PortalPartWrapper.RefundDetail();
        rdl.customerOrderNo = '';
        rdl.partOrderId     = '';
        rdl.machineName     = '';
        rdl.equipmentNo     = '';
        rdl.purchaseOrder   = '';
        rdl.poiId           = '';
        rdl.urgency         = '';

        rdl.invoice     = '';
        rdl.itemNo      = '';
        rdl.orderPartNo = '';
        rdl.note        = '';
        rdl.orderQty    = '';
        rdl.unit        = '';
        rdl.unitPrice  = 100;

        rdl.netValue         = '';
        rdl.complaintReason1 = '';
        rdl.complaintReason2 = '';
        rdl.description      = '';

        rdl.attachFile    = '';
        rdl.originDocDate = today;
        rdl.orderDate     = today;
        rdl.itemSpr       = '';

        rdl.fileInfo    = fiList;
        rdl.crmFileInfo = crList;

        rdList.add(rdl);
        
        DN_PortalPartWrapper.ReturnOrderTerms terms = new DN_PortalPartWrapper.ReturnOrderTerms();
            terms.dealerInfo    = dealerInfo;
            terms.returnOrderNo = '';
            terms.referenceNo   = '';
            terms.orderPartNo   = '';
            terms.startDate     = today;
            terms.endDate       = today;

        DN_PortalPartWrapper.RefundOrderInfo roi = new DN_PortalPartWrapper.RefundOrderInfo();
            roi.dealerInfo    = dealerInfo;
            roi.refundOrderNo = '';
            roi.partOrderNo   = '';
            roi.refundCustomerOrderNo = '';
            roi.refundList  = rdList;

            String returnOrderNo = '7100253598';
            PurchaseOrder__c por = [
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

        DN_PortalPartWrapper.ReturnPDF rPDF = new DN_PortalPartWrapper.ReturnPDF(por, dealerInfo);
    }
}