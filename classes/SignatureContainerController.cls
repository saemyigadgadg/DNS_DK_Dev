/**
 * @description       : 
 * @author            : geonsang.park@sobetec.com
 * @group             : 
 * @last modified on  : 05-20-2025
 * @last modified by  : geonsang.park@sobetec.com
**/
public without sharing class SignatureContainerController {
    
    @AuraEnabled
    public static boolean saveSignatureNew(String signatureBody, id parentId, String signatureType) {
        try {
            System.debug('>>>>> saveSignatureNew start >>>>>>>>>>');

            // Create Salesforce File
            // Insert ContentVersion
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; // S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.

            cVersion.PathOnClient = 'Signature-'+signatureType+'-'+System.now() +'.png';//File name with extention 

            cVersion.Origin = 'H';// C-Content Origin. H-Chatter Origin.
            // cVersion.OwnerId = attach.OwnerId; // Owner of the file

            String Title = 'Signature-'+signatureType+'-'+System.now();

            cVersion.Title = Title + '.png';// Name of the file
            cVersion.DealerPotalFileType__c = 'Signature';
            cVersion.VersionData = EncodingUtil.base64Decode(signatureBody); // File content
            Insert cVersion;
            
            // After saved the Content Verison, get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            
            // Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument; // Add ContentDocumentId
            cDocLink.LinkedEntityId = parentId; // Add attachment parentId
            cDocLink.ShareType = 'I'; // V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers'; // AllUsers, InternalUsers, SharedUsers
            Insert cDocLink;
            
            List<WorkOrder> woList = [SELECT Id, hasCustomerSign__c, hasEngineerSign__c FROM WorkOrder WHERE Id = :parentId];
            if(woList != null) {
                if(signatureType == 'engineer'){
                    woList[0].hasEngineerSign__c = true;
                }else{
                    woList[0].hasCustomerSign__c = true;
                }
                update woList;
            }

            ContentDistribution cDist = new ContentDistribution();
            cDist.ContentVersionId = cVersion.Id; // 업로드된 ContentVersion의 Id
            cDist.Name = '공유용_' + cVersion.Title;
            cDist.PreferencesAllowViewInBrowser = true; // 브라우저에서 보기 허용
            cDist.PreferencesExpires = false; // 만료 여부 설정 (true면 만료일 필요)
            cDist.PreferencesNotifyOnVisit = false;
            insert cDist;
            
            
            
            return true;
        } catch (Exception e) {
            System.debug('[' + e.getLineNumber() + '] ' + e.getMessage());
            return false;
        }
    }
    
    
    @AuraEnabled
    public static String deleteSignFile(String recordId, String signatureType) {
        System.debug('Delete Sign 진입');
        System.debug('recordId :: ' + recordId);
        String result = '';

        try {
            if (recordId != null) {
                List<WorkOrder> woList = [SELECT Id, hasCustomerSign__c, hasEngineerSign__c FROM WorkOrder WHERE Id = :recordId];
            if(woList != null) {
                if(signatureType == 'engineer'){
                    woList[0].hasEngineerSign__c = false;
                }else{
                    woList[0].hasCustomerSign__c = false;
                }
                update woList;
            }
                String sql = ' SELECT \n';
                sql += ' Id, LinkedEntityId, ContentDocumentId \n';
                sql += ' FROM ContentDocumentLink \n';
                sql += ' WHERE LinkedEntityId=: recordId AND ContentDocument.Title Like \'%' + signatureType + '%\'';
                sql += ' ORDER BY SystemModstamp DESC LIMIT 1';
                
                List<ContentDocumentLink> lastSignList = Database.query(sql);
                System.debug( 'lastSignList 쿼리 :: ' + lastSignList);
                
                if (lastSignList.size() > 0) {
                    delete lastSignList[0];
                    result = 'SUCCESS';
                    System.debug('Success Zone');
                } else {
                    result = 'ERROR :: No Signature File';
                    System.debug('Error Zone');
                }
            } else {
                result = 'ERROR';
            }
            System.debug('result :: ' + result);
            return result;
        } catch (Exception e) {
            return 'ERROR_MSG :: ' + '[' + e.getLineNumber() + '] ' + e.getMessage();
        }
    }
    @auraEnabled
    public static String getSignature(String recordId, String signatureType){
        Set<String> docSet = new Set<String>();
        Map<String, ContentDocumentLink> cdlMap = new Map<String, ContentDocumentLink>();
        String LastestVersionId;
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        String sql = ' SELECT \n';
        sql += ' Id, LinkedEntityId, ContentDocumentId \n';
        sql += ' FROM ContentDocumentLink \n';
        sql += ' WHERE LinkedEntityId=: recordId AND ContentDocument.Title Like \'%' + signatureType + '%\'';
        sql += ' ORDER BY SystemModstamp DESC';
        cdlList = Database.query(sql);
        
        List<ContentDistribution> cdiList = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl, ContentDocumentId 
                                                FROM ContentDistribution 
                                                WHERE ContentDocumentId =:cdlList[0].ContentDocumentId
                                                ORDER BY SystemModstamp DESC];
       
        
        String strSign = cdiList[0].ContentDownloadUrl;
       

        return strSign;

    }
    
   
   
}