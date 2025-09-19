/** 변수명 정리
 *      T_DOCUMENTListForName                - 장비 Name 을 Key로 가장 최신 장비에 속한 T_DOCUMENT List를 가져옴 *file 생성용
 *      EKey                  : EQUNR__c     - Asset.Name External Key // 예시 
 *      FFSFFN                : T_DOCUMENT_FILEForSeqForFileName - 
*/
public with sharing class DN_UploadFileToAssetFromERPBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {    
    private InterfaceCommonLog.interfaceLog         interfaceLog            = new InterfaceCommonLog.interfaceLog('IF-CSPLUS-018', 'IF_ERP_Material');
    private static Map<String,Schema.SObjectType>   schemaMap               = Schema.getGlobalDescribe();
    
    // 장비 Name 을 key로 장비의 BatchExecuteTime__c을 가져옴 *최신 ifMaterial 확인용
    private Map<String, Datetime>                   batchExecuteTimeForName;
    // 장비 Name 을 Key로 모든 T_DOCUMENT List를 가져옴 *ifMaterial isComplete__c true 변경용
    private Map<String, List<IF_Material__c>>       ifMaterialListForName   = new Map<String, List<IF_Material__c>>();
    // 장비 Name 을 Key로 Asset Id를 가져옴 *asset lookup 용
    private Map<String, String>                     assetIdForName          = new Map<String, String>();

    // constructor
    public DN_UploadFileToAssetFromERPBatch(Map<String, Datetime> batchExecuteTimeForName, Map<String, String> assetIdForName) {
        this.batchExecuteTimeForName    = batchExecuteTimeForName;
        this.assetIdForName             = assetIdForName;
    }

    // batch method
    public List<IF_Material__c> start(Database.BatchableContext bc) {
        System.debug('DN_UploadFileToAssetFromERPBatch Start ------------');
        System.debug('this.batchExecuteTimeForName ::: '    + this.batchExecuteTimeForName);
        System.debug('this.assetIdForName ::: '             + this.assetIdForName);
        try {
            Map<String, Schema.SObjectField> objectFields = schemaMap.get('IF_Material__c').getDescribe().fields.getMap();
            List<String> fieldsToQuery = new List<String>(objectFields.keySet());

            String  query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM IF_Material__c';
                    query += ' WHERE IsComplete__c = false AND ParameterName__c = \'T_DOCUMENT\'';
                    query += ' ORDER BY CreatedDate DESC LIMIT 50000';

            List<IF_Material__c>                T_DOCUMENTList        = (List<IF_Material__c>) Database.query(query);
            System.debug('T_DOCUMENTList ::: ' + T_DOCUMENTList);
            Map<String, List<IF_Material__c>>   T_DOCUMENTListForName = new Map<String, List<IF_Material__c>>();

            // EQUNR이 같은 중복 Material 제거 및 isComplete__c true로 변경
            for (IF_Material__c T_DOCUMENT : T_DOCUMENTList) {
                T_DOCUMENT.IsComplete__c = true;
                
                System.debug('T_DOCUMENT.OBJKY__c ::: ' + T_DOCUMENT.OBJKY__c);
                System.debug('this.batchExecuteTimeForName ::: ' + this.batchExecuteTimeForName);
                System.debug('this.batchExecuteTimeForName.get(T_DOCUMENT.OBJKY__c) ::: ' + this.batchExecuteTimeForName.get(T_DOCUMENT.OBJKY__c));
                System.debug('T_DOCUMENT.BatchExecuteTime__c ::: ' + T_DOCUMENT.BatchExecuteTime__c);
                System.debug(this.batchExecuteTimeForName.get(T_DOCUMENT.OBJKY__c) == T_DOCUMENT.BatchExecuteTime__c);

                // batchExecuteTimeForName 을 이용해 장비의 최신 T_DOCUMENT를 List로 생성
                if(this.batchExecuteTimeForName.get(T_DOCUMENT.OBJKY__c) != null
                    && this.batchExecuteTimeForName.get(T_DOCUMENT.OBJKY__c) == T_DOCUMENT.BatchExecuteTime__c){

                    if(T_DOCUMENTListForName.get(T_DOCUMENT.OBJKY__c) != null){
                        T_DOCUMENTListForName.get(T_DOCUMENT.OBJKY__c).add(T_DOCUMENT);
                    }else{
                        T_DOCUMENTListForName.put(T_DOCUMENT.OBJKY__c, new List<IF_Material__c>{T_DOCUMENT});
                    }
                }

                if(ifMaterialListForName.get(T_DOCUMENT.OBJKY__c) != null){
                    this.ifMaterialListForName.get(T_DOCUMENT.OBJKY__c).add(T_DOCUMENT);
                }else{
                    this.ifMaterialListForName.put(T_DOCUMENT.OBJKY__c, new List<IF_Material__c>{T_DOCUMENT});
                }
            }

            System.debug('T_DOCUMENTListForName ::: ' + T_DOCUMENTListForName);
            List<IF_Material__c> scopeList = new List<IF_Material__c>();
            for (List<IF_Material__c> latestT_DOCUMENTList : T_DOCUMENTListForName.values()) {
                scopeList.addAll(latestT_DOCUMENTList);
            }

            return scopeList;
        } catch (Exception e) {
            this.interfaceLog.errorText = new List<String>();
            this.interfaceLog.errorText.add('[' + e.getLineNumber() + ']' + e.getMessage());   
            InterfaceCommonLog ifCommonLog = new InterfaceCommonLog();
            ifCommonLog.insertLog(new List<InterfaceCommonLog.interfaceLog>{this.interfaceLog});

            System.debug('Error ::: '         + e.getMessage());
            System.debug('Line Number ::: '   + e.getLineNumber());

            System.abortJob(bc.getJobId());
            return null;
        }
    }
    public void execute(Database.BatchableContext bc, List<IF_Material__c> scope) {
        System.debug('DN_UploadFileToAssetFromERPBatch Execute ------------');

        List<IF_Material__c> updateIFMaterialList = new List<IF_Material__c>();
        
        System.SavePoint savePoint = Database.setSavepoint();
        try{
            // 0. T_DOCUMENT_FILE query 에 필요한 scope 장비 Name List 생성 및 IsComplete__c 를 위한 updateIFMaterialList add
            Set<String> nameSet = new Set<String>();
            for (IF_Material__c T_DOCUMENT : scope) nameSet.add(T_DOCUMENT.OBJKY__c); 
            for (String name : nameSet) updateIFMaterialList.addAll(this.ifMaterialListForName.get(name));
            
            // 1. T_DOCUMENT_FILE query
            Map<String, Schema.SObjectField> objectFields = schemaMap.get('IF_Material__c').getDescribe().fields.getMap();
            List<String> fieldsToQuery = new List<String>(objectFields.keySet());

            String  query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM IF_Material__c';
                    query += ' WHERE IsComplete__c = false AND ParameterName__c = \'T_DOCUMENT_FILE\'';
                    query += ' AND OBJKY__c IN (\''+ String.join(nameSet, '\',\'') +'\')';
                    query += ' ORDER BY CreatedDate DESC LIMIT 50000';

            List<IF_Material__c> T_DOCUMENT_FILEList = (List<IF_Material__c>) Database.query(query);

            // 2. batchExecuteTimeForName 을 이용해 장비의 최신 T_DOCUMENT_FILE을 mapping 용 FFSFFN : T_DOCUMENT_FILEForSeqForFileName 생성
            Map<String, Map<Integer, IF_Material__c>> FFSFFN = new Map<String, Map<Integer, IF_Material__c>>();

            // 2-1. 최신 장비에 해당하는 T_DOCUMENT_FILE 만 들고 온다
            for(IF_Material__c T_DOCUMENT_FILE : T_DOCUMENT_FILEList){
                if(this.batchExecuteTimeForName.get(T_DOCUMENT_FILE.OBJKY__c) != null
                    || this.batchExecuteTimeForName.get(T_DOCUMENT_FILE.OBJKY__c) == T_DOCUMENT_FILE.BatchExecuteTime__c
                ){
                    // 2-2. mapping 용 FFSFFN 을 생성한다.
                    if(FFSFFN.get(T_DOCUMENT_FILE.DOKNR__c) != null){
                        FFSFFN.get(T_DOCUMENT_FILE.DOKNR__c).put(Integer.valueof(T_DOCUMENT_FILE.FileSequence__c), T_DOCUMENT_FILE);
                    }else{
                        FFSFFN.put(T_DOCUMENT_FILE.DOKNR__c, new Map<Integer, IF_Material__c>{
                            Integer.valueof(T_DOCUMENT_FILE.FileSequence__c) => T_DOCUMENT_FILE
                        });
                    }
                }
                // 2-3. IsComplete__c 를 위한 updateIFMaterialList add
                T_DOCUMENT_FILE.isComplete__c = true;
                updateIFMaterialList.add(T_DOCUMENT_FILE);
            }

            // 3. T_DOCUMENTList를 이용해 기존 ContentDocument List delete, 새로운 ContentVersion List insert
            // 3-1. ContentVersion insert List 생성 및 ContentDocument List delete 에 필요한 Asset Name List 생성
            List<ContentVersion> insertCVList = new List<ContentVersion>();
            List<String> deleteAssetName = new List<String>();
            for (IF_Material__c T_DOCUMENT : scope) {
                insertCVList.add(generateContentVersion(T_DOCUMENT, FFSFFN));
                deleteAssetName.add(T_DOCUMENT.OBJKY__c);
            }

            // 3-2. deleteAssetName List를 이용해 ContentDocument List delete
            List<ContentDocument> deleteCDList = getDeleteContentDocument(deleteAssetName);
            if(deleteCDList.size() > 0) Database.delete(deleteCDList);
            
            // 3-3. ContentVersion List insert
            if(insertCVList.size() > 0) Database.insert(insertCVList);

            // 4. record 에 파일을 올리기 위한 ContentDocumentLink List insert
            // 4-1. ContentVersionId List 를 구해서 다시 query => 이유 : insert 직후의 ContentVersion에는 ContentDocumentId 가 존재하지 않음
            List<String> cvIdList = new List<String>();
            for (ContentVersion cv : insertCVList) cvIdList.add(cv.Id);

            List<ContentVersion> queryCVList = [
                SELECT Id, ContentDocumentId, AssetName__c
                FROM ContentVersion
                WHERE Id IN :cvIdList
            ];

            // 4-2. ContentVersion 정보를 바탕으로 assetIdForName Map을 활용해서 ContentDocumentLink List insert
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            for (ContentVersion cv : queryCVList) cdlList.add(generateContentDocumentLink(cv));
            if(cdlList.size() > 0) Database.insert(cdlList); 

            // 5. ifMaterial isComplete__c true update
            if(updateIFMaterialList.size() > 0) Database.update(updateIFMaterialList);

        } catch (Exception e) {
            Database.rollback(savePoint);

            this.interfaceLog.errorText = new List<String>();
            this.interfaceLog.errorText.add('[' + e.getLineNumber() + ']' + e.getMessage());
            InterfaceCommonLog ifCommonLog = new InterfaceCommonLog();
            ifCommonLog.insertLog(new List<InterfaceCommonLog.interfaceLog>{this.interfaceLog});

            System.debug('Error ::: '         + e.getMessage());
            System.debug('Line Number ::: '   + e.getLineNumber());

            System.abortJob(bc.getJobId());
        }
    }
    public void finish(Database.BatchableContext bc) {
        try {
            System.debug('DN_UploadFileToAssetFromERPBatch Finish ------------');

        } catch (Exception e) {
            System.debug('Error ::: '         + e.getMessage());
            System.debug('Line Number ::: '   + e.getLineNumber());

            System.abortJob(bc.getJobId());
        }
    }

    // util method
    public List<ContentDocument> getDeleteContentDocument(List<String> deleteAssetName){
        List<ContentDocument> cdList = new List<ContentDocument>();
        try {
            List<String> assetIdList = new List<String>();
            for (String assetName : deleteAssetName) {
                assetIdList.add(this.assetIdForName.get(assetName));
            }
            if(assetIdList.size() > 0){
                List<ContentDocumentLink> cdlList = [
                    SELECT Id, ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN :assetIdList
                ];
    
                List<String> cdIdList = new List<String>();
                for (ContentDocumentLink cdl : cdlList) {
                    cdIdList.add(cdl.ContentDocumentId);
                }
    
                List<ContentVersion> cvList = [
                    SELECT Id, ContentDocumentId
                    FROM ContentVersion
                    WHERE IsSAPFile__c = true 
                        AND ContentDocumentId IN :cdIdList
                ];
    
                cdIdList = new List<String>();
                if (cvList.size() > 0) {
                    for (ContentVersion cv : cvList) {
                        cdIdList.add(cv.ContentDocumentId);
                    }
                    cdList = [SELECT Id FROM ContentDocument WHERE Id IN :cdIdList];
                }
            }

        } catch (Exception e) {
            throw e;
        }
        return cdList;
    }
    public ContentVersion generateContentVersion(IF_Material__c T_DOCUMENT, Map<String, Map<Integer, IF_Material__c>> FFSFFN){
        ContentVersion cv = new ContentVersion();
        try {

            String fileDataString   = '';

            Map<Integer, IF_Material__c> T_DOCUMENT_FILEForSeq = FFSFFN.get(T_DOCUMENT.DOKNR__c);

            for (Integer seq = 1; T_DOCUMENT_FILEForSeq.get(seq) != null; seq++) {
                IF_Material__c T_DOCUMENT_FILE = T_DOCUMENT_FILEForSeq.get(seq);

                fileDataString = fileDataString + T_DOCUMENT_FILE.BUFFER__c;
            }
            
            Blob fileData       = EncodingUtil.base64Decode(fileDataString);
            cv.VersionData      = fileData;

            String fileName     = T_DOCUMENT.DKTXT__c;
            cv.Title            = fileName;
            cv.PathOnClient     = fileName + getExtension(fileData);
            System.debug('cv.PathOnClient ::: ' + cv.PathOnClient);

            cv.AssetName__c     = T_DOCUMENT.OBJKY__c;
            
            cv.IsSAPFile__c     = true;
            cv.IsMajorVersion   = true;
        } catch (Exception e) {
            throw e;
        }
        return cv;
    }
    public ContentDocumentLink generateContentDocumentLink(ContentVersion cv){
        ContentDocumentLink cdl = new ContentDocumentLink();
        try {
            cdl.ContentDocumentId   = cv.ContentDocumentId;
            cdl.LinkedEntityId      = this.assetIdForName.get(cv.AssetName__c);
            cdl.ShareType           = 'I';
            cdl.Visibility          = 'AllUsers';
        } catch (Exception e) {
            throw e;
        }
        return cdl;
    }
    public String getExtension(Blob fileData){
        try {
            String fileString = EncodingUtil.convertToHex(fileData).substring(0, 25).toUpperCase();
            System.debug('fileString ::: ' + fileString);
            
            // pdf, png, jpeg, avi(보류)
            if(fileString.startsWith('255044462D')){
                return '.pdf';
            }else if(fileString.startsWith('89504E470D0A1A0A')){
                return '.png';
            }else if(
                fileString.startsWith('89504E470D0A1A0A')
                || fileString.startsWith('FFD8FFDB')
                || fileString.startsWith('FFD8FFE000104A4649460001')
                || fileString.startsWith('FFD8FFEE')
                || fileString.startsWith('FFD8FFE0')){
                return '.jpg';
            }else if(
                fileString.startsWith('EFBBBF')
                || fileString.startsWith('FFFE')
                || fileString.startsWith('FEFF')
                || fileString.startsWith('FFFE0000')
                || fileString.startsWith('0000FEFF')
                || fileString.startsWith('0EFEFF')){
                return '.txt';
            }else if(fileString.startsWith('52494646????????41564920')){
                return '.avi';
            }
        } catch (Exception e) {
            throw e;
        }
        return '';
    }
}