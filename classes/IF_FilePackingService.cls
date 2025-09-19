public with sharing class IF_FilePackingService {
    public IF_FilePackingService() {}

// CALL OUT
    public Map<Id,ContentVersion> packingToMapByHTML(String contentversionId){
        createFilePackedByHtml(new Set<String>{contentversionId});
        return getNewVersionMapByOriginIds(new List<String>{contentversionId});
    }
    public Map<Id,ContentVersion> packingToMapByHTML(List<String> contentversionIds){
        createFilePackedByHtml(new Set<String>(contentversionIds));
        return getNewVersionMapByOriginIds(contentversionIds);
    }


    public List<Id> packingToListByHTML(String contentversionId){
        return new List<Id>(packingToMapByHTML(contentversionId).keySet());
    }

    public List<Id> packingToListByHTML(List<String> contentversionIds){
        return new List<Id>(packingToMapByHTML(contentversionIds).keySet());
    }



// INNNER
    private void                createFilePackedByHtml(Set<String> contentVersionIds){
        // 1. Version Id 로 ContentVersion 반환 
        Map<Id,ContentVersion>      versionMap           = getVersionMapByIds(contentVersionIds);

        // 2. 추출한 ContentVersion 의 ContentDistribution 할당 
        assignContentDistributions(versionMap);

        Set<Id>                     versionIds           = versionMap.keySet();

        // 3. ContentDistribution 추출          
        Map<Id,ContentDistribution> distributionMap      = getMapVersionId_Distribution(versionIds);

        
        List<ContentVersion>       newContentVersionList = new List<ContentVersion>();


        // 4. loop -> 새로운 ContentVersion 생성 
        for(Id versionId : versionIds){
            String         publicUrl            = distributionMap.get(versionId).DistributionPublicUrl;
            ContentVersion baseContentVersion   = versionMap.get(versionId);
            String         baseContentTitle     = baseContentVersion.Title ;
            String         baseContentExtension = baseContentVersion.FileExtension;

            System.debug('baseContentTitle : '+baseContentTitle);
            baseContentTitle = baseContentTitle.contains('.'+baseContentExtension) ? baseContentTitle.replaceAll('.'+baseContentExtension, ''):baseContentTitle; 

            System.debug('baseContentTitle : '+baseContentTitle);


            if(!baseContentVersion.IsConvertedHTML__c){
                ContentVersion newContentVersion     = new ContentVersion();
                newContentVersion.Title              = baseContentTitle+'.htm'; // EncodingUtil.urlEncode(baseContentTitle+'.htm', 'UTF-8'); /
                newContentVersion.PathOnClient       = baseContentTitle+'.htm';  
                newContentVersion.VersionData        = Blob.valueOf(getHtmlContentsString(publicUrl));
                newContentVersion.IsMajorVersion     = true;
                newContentVersion.IsConvertedHTML__c = true; 
                newContentVersion.FileType__c        = baseContentVersion.FileType__c;
                newContentVersion.OriginVersionId__c = versionId;
                newContentVersion.DealerPotalFileType__c = baseContentVersion.DealerPotalFileType__c;
                newContentVersionList.add(newContentVersion); 
            }
        }

        insert newContentVersionList;
    }

    private String                      getHtmlContentsString(String publicURL){
        return '<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><title>Redirecting...</title><script>(function(){var redirectURL = "' + publicURL + '";window.location.href = redirectURL;document.write(\'<p>If the page does not automatically redirect, <a href="\' + redirectURL + \'">click here.</a></p>\');})();</script></head><body></body></html>';
    }

    private Map<Id,ContentVersion>      getVersionMapByIds(Set<String> contentVersionIds){
        Map<Id,ContentVersion> versionMap = new Map<Id,ContentVersion>(); 
        for(ContentVersion version : [SELECT Id, Title, 
        // VersionData, 
        ContentDocumentId, PathOnClient, FileExtension, 
        IsConvertedHTML__c, FileType__c, OriginVersionId__c, DealerPotalFileType__c
                                        FROM ContentVersion 
                                        WHERE Id IN :contentVersionIds
                                        AND IsLatest = TRUE 
                                    ]){
            if(version!=null){
                versionMap.put(version.Id, version);
            }                                
        }
        System.debug('getVersionMapByIds - versionMap size : '+versionMap.size());
        return versionMap;
    }

    // SFDC 파일 이름으로 데이터 추출 
    private Map<Id,ContentVersion>      getNewVersionMapByOriginIds(List<String> originIds){
        Map<Id,ContentVersion> versionMap = new Map<Id,ContentVersion>();
        Map<Id,ContentVersion> returnMap  = new Map<Id,ContentVersion>(); 
        System.debug('originIds : '+originIds);
        System.debug('originIds.size() : '+originIds.size());
        for(ContentVersion version : [SELECT Id, Title, VersionData, 
        ContentDocumentId, PathOnClient, FileExtension, 
        CreatedDate, IsConvertedHTML__c, OriginVersionId__c,FileType__c, DealerPotalFileType__c
                                        FROM ContentVersion
                                        WHERE OriginVersionId__c IN :originIds
                                        AND IsLatest = TRUE
                                        AND IsConvertedHTML__c = TRUE
                                    ]){
            
            if(version.IsConvertedHTML__c){
                if(versionMap.containsKey(version.OriginVersionId__c)){
                    ContentVersion alreadyAssignVersion = versionMap.get(version.OriginVersionId__c);
                    if(alreadyAssignVersion.CreatedDate < version.CreatedDate){
                        versionMap.put(version.OriginVersionId__c,version);
                    }
                }
                else{
                    versionMap.put(version.OriginVersionId__c,version);
                }
            }                                
        }
        for(Id originId : versionMap.keyset()){
            ContentVersion version = versionMap.get(originId);
            returnMap.put(version.Id,version);
            System.debug('create date : '+version.CreatedDate);
            System.debug('origin Id : '+version.OriginVersionId__c);
        }


        System.debug('getNewVersionMapByOriginIds - returnMap size : '+returnMap.size());
        return returnMap;
    }

    private void                        assignContentDistributions(Map<Id,ContentVersion> versionMap) {
        Set<Id>                      versionIds             = versionMap.keySet();
        List<ContentDistribution>    newDistributions       = new List<ContentDistribution>();
        Map<Id, ContentDistribution> existingDistributions  = getMapVersionId_Distribution(versionIds);
    
        for (ContentVersion version : versionMap.values()) {

            if (!existingDistributions.containsKey(version.Id)) {
                String disforName = 'Distribution for ' + version.Title;
                Integer maxLength = 100;
                String trimmedValue = disforName != null && disforName.length() > maxLength
                    ? disforName.left(maxLength)
                    : disforName;
                    ContentDistribution newCd = new ContentDistribution(
                        ContentVersionId                = version.Id,
                        Name                            = trimmedValue, 
                        PreferencesAllowViewInBrowser   = true
                    );
                    newDistributions.add(newCd);
            }
        }
    
        if (!newDistributions.isEmpty()) {
            insert newDistributions;
        }
    }

    private Map<Id,ContentDistribution> getMapVersionId_Distribution(Set<Id> contentVersionIds){
        System.debug('getMapVersionId_Distribution call');

        Map<Id,ContentDistribution> distributionMap = new Map<Id,ContentDistribution>();
        
        for (ContentDistribution cd : [ SELECT Id, ContentVersionId, Name, DistributionPublicUrl 
                                        FROM ContentDistribution 
                                        WHERE ContentVersionId IN :contentVersionIds]) {   
                                            System.debug('ContentDistribution  : ' + cd.ContentVersionId + '/' + cd);
            distributionMap.put(cd.ContentVersionId, cd);
        }
        System.debug('distributionMap size : ' + distributionMap.size());
        return distributionMap;
    }

}