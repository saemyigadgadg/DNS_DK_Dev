/**
 * @description       : 
 * @author            : geonsang.park@sobetec.com
 * @group             : 
 * @last modified on  : 04-03-2025
 * @last modified by  : geonsang.park@sobetec.com
**/
public without sharing class DN_CustomServiceReportController {
    @AuraEnabled
    public static void saveServiceSignatures(Id workOrderId, String engineerName, String customerName) {        

        try{
            List<WorkOrder> woList = [SELECT Id, ServiceEngineerName__c, CustomerName__c FROM WorkOrder WHERE Id = :workOrderId];
            if(woList.size() > 0) {
                woList[0].ServiceEngineerName__c = engineerName;
                woList[0].CustomerName__c = customerName;
                update woList;
            }        
    
            // 이 시점에서 백엔드에서 PDF를 렌더링/저장할 수 있다면 여기에 호출
            generatePdf(workOrderId, engineerName, customerName);
        }catch(Exception e){
            System.debug(e.getMessage() + ' line : ' + e.getLineNumber());
        }
    }

    // private static Blob base64ToBlob(String dataUrl) {
    //     if (String.isBlank(dataUrl)) return null;
    //     String base64Data = dataUrl.replaceFirst('^data:image/[^;]+;base64,', '');
    //     return EncodingUtil.base64Decode(base64Data);
    // }

    private static void generatePdf(Id workOrderId, String engineerName, String customerName) {
        // PDF 생성 로직 샘플 (VF 페이지를 백엔드에서 호출해서 PDF 생성하고 저장)
        try{
            PageReference pdfPage = Page.DN_ServiceReportAPrint;
            pdfPage.getParameters().put('recordId', String.valueOf(workOrderId));
            
            pdfPage.getParameters().put('engineerName', String.valueOf(engineerName));
            pdfPage.getParameters().put('customerName', String.valueOf(customerName));
            Blob pdfBlob;            
            System.debug('pdf Blob Create;');
            if(!Test.isRunningTest()){
                System.debug('pdf Blob Create; isNotRunningTest');
                pdfBlob = pdfPage.getContentAsPDF();
            }else{                
                System.debug('pdf Blob Create; isRunningTest');
                pdfBlob = Blob.valueOf('Test PDF');
            }
            System.debug('go pdf');
            ContentVersion pdf = new ContentVersion();
            pdf.Title = 'Service_Report_FSL_' + System.now();
            pdf.PathOnClient = 'ServiceReport_FSL_'+System.now()+'.pdf';
            pdf.VersionData = pdfBlob;
            pdf.FirstPublishLocationId = workOrderId;
            insert pdf;
        }catch(Exception e){
            System.debug(e.getMessage() + ' line : ' + e.getLineNumber());
        }
    }

    
}