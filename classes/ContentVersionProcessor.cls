public class ContentVersionProcessor implements Queueable, Database.AllowsCallouts {
    private List<Id> contentVersionIds;

    public ContentVersionProcessor(List<Id> ids) {
        this.contentVersionIds = ids;
    }

    public void execute(QueueableContext context) {
        List<ContentVersion> cvList = [
            SELECT Id, Title, FileType, FileType__c, PathOnClient, Checksum,
                   FirstPublishLocationId, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN :contentVersionIds
        ];
        
        System.debug('@@ cvList : ' + cvList);

        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(cvList);
        Set<Id> psIds = new Set<Id>();
        Set<String> incomingChecksums = new Set<String>();

        for (ContentVersion cv : cvList) {
            if (cv.FirstPublishLocationId != null) {
                psIds.add(cv.FirstPublishLocationId);
            }
            if (cv.Checksum != null) {
                incomingChecksums.add(cv.Checksum);
            }
        }

        Map<String, ContentVersion> duplicateMap = new Map<String, ContentVersion>();
        if (!incomingChecksums.isEmpty()) {
            for (ContentVersion existing : [
                SELECT Id, Title, Checksum 
                FROM ContentVersion 
                WHERE Checksum IN :incomingChecksums AND Id NOT IN :contentVersionMap.keySet()
            ]) {
                duplicateMap.put(existing.Checksum, existing);
            }
        }

        Map<Id, PS__c> psMap = new Map<Id, PS__c>([
            SELECT Id, Name, Status__c, InquirySeq__c, IsInterfaced__c,
                   Opportunity__r.Id, Opportunity__r.Opportunity_Owner__r.Email,
                   Opportunity__r.Opportunity_Owner__r.Manager.Name,
                   Opportunity__r.Opportunity_Owner__r.LanguageLocaleKey
            FROM PS__c
            WHERE Id IN :psIds
        ]);

        Map<Id, List<ContentVersion>> psToContentVersions = new Map<Id, List<ContentVersion>>();
        for (ContentVersion existingCv : [
            SELECT Id, Title, FileType, FirstPublishLocationId
            FROM ContentVersion
            WHERE FirstPublishLocationId IN :psIds
        ]) {
            if (!psToContentVersions.containsKey(existingCv.FirstPublishLocationId)) {
                psToContentVersions.put(existingCv.FirstPublishLocationId, new List<ContentVersion>());
            }
            psToContentVersions.get(existingCv.FirstPublishLocationId).add(existingCv);
        }

        Map<Id, ContentDocumentLink> cdLinkMap = new Map<Id, ContentDocumentLink>();
        for (ContentDocumentLink cdl : [
            SELECT ContentDocumentId, LinkedEntityId, LinkedEntity.Type, ContentDocument.Title
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :contentVersionMap.keySet()
        ]) {
            if (psIds.contains(cdl.LinkedEntityId)) {
                cdLinkMap.put(cdl.ContentDocumentId, cdl);
            }
        }

        List<ContentDistribution> distributionsToInsert = new List<ContentDistribution>();
        List<DN_RFQFileSend.RFQFileRequest> fileRequests = new List<DN_RFQFileSend.RFQFileRequest>();

        for (ContentVersion cv : cvList) {
            if (isLogoFile(cv)) {
                System.debug('🧾 무시된 로고 이미지: ' + cv.Title);
                continue;
            }

            if (!cdLinkMap.containsKey(cv.ContentDocumentId) || !psMap.containsKey(cv.FirstPublishLocationId)) {
                continue;
            }

            PS__c ps = psMap.get(cv.FirstPublishLocationId);
            if (ps.Status__c != 'Draft' && ps.Status__c != 'RequestToReview') {
                continue;
            }

            Integer duplicateCount = 0;
            for (ContentVersion existingCv : psToContentVersions.get(cv.FirstPublishLocationId)) {
                if (existingCv.Title == cv.Title && existingCv.FileType == cv.FileType) {
                    duplicateCount++;
                }
            }

            if (duplicateCount > 1) {
                continue;
            }

            ContentDistribution dist = new ContentDistribution();
            dist.Name = cv.PathOnClient;
            dist.ContentVersionId = cv.Id;
            dist.PreferencesAllowViewInBrowser = true;
            dist.PreferencesAllowOriginalDownload = true;
            distributionsToInsert.add(dist);
        }

        if (!distributionsToInsert.isEmpty()) {
            insert distributionsToInsert;

            Map<Id, ContentDistribution> insertedMap = new Map<Id, ContentDistribution>([
                SELECT Id, ContentVersionId, ContentDownloadUrl 
                FROM ContentDistribution 
                WHERE Id IN :distributionsToInsert
            ]);

            for (ContentDistribution dist : insertedMap.values()) {
                ContentVersion cv = contentVersionMap.get(dist.ContentVersionId);
                PS__c ps = psMap.get(cv.FirstPublishLocationId);

                fileRequests.add(new DN_RFQFileSend.RFQFileRequest(
                    cv.PathOnClient,
                    ps.InquirySeq__c,
                    dist.ContentDownloadUrl,
                    ps.Opportunity__r.Id
                ));
            }
        }

        if (!fileRequests.isEmpty()) {
            String serialized = JSON.serialize(fileRequests);
            DN_RFQFileSend.callRFQ2(serialized);
        }
    }

    private Boolean isLogoFile(ContentVersion cv) {
        String title = cv.Title != null ? cv.Title.toLowerCase() : '';
        String path = cv.PathOnClient != null ? cv.PathOnClient.toLowerCase() : '';
    
        System.debug('@@cv.PathOnClient : ' + cv.PathOnClient);
        System.debug('@@cv.Title : ' + cv.Title);
        
        List<String> logoKeywords = new List<String>{
            'image', 'cid', 'logo', 'signature'
        };
        List<String> imageExts = new List<String>{'.png', '.jpg', '.jpeg', '.gif'};
    
        Boolean hasLogoKeyword = false;
        for (String keyword : logoKeywords) {
            if (title.contains(keyword) || path.contains(keyword)) {
                hasLogoKeyword = true;
                break;
            }
        }
    
        Boolean hasImageExt = false;
        for (String ext : imageExts) {
            if (title.endsWith(ext) || path.endsWith(ext)) {
                hasImageExt = true;
                break;
            }
        }
    
        return hasLogoKeyword && hasImageExt;
    }

}