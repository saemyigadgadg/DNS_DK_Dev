/** 변수명 정리
 *      assetEField                    - Asset.Name Schema Data
 *      T_ITEMForName                  - 장비 Name 을 Key로 장비에 속한 T_ITEM 중 BatchExecuteTime__c이 가장 최신인 ifMaterial-T_ITEM을 가져옴
 *      updateIFMaterialList           - isComplete__c true로 변경한 ifMaterial List *ifMaterial update 용
 *      accountIdForCustomerCode       - CutomerCode를 Key로 accountId 를 가져옴 *asset 파트너 필드 mapping 용
 *      assetForEKey                   - EKey를 Key로 asset을 가져옴 *asset upsert 용
 *      EKey          : EQUNR__c                            - Asset.Name External Key
 *      SONo          : Order.ERPPSONo__c                   - SalseOrder Number *ERP Key
 *      StaffNo       : ServiceResource.StaffNumber__c      - Staff Number *ERP Key
*/
public without sharing class DN_UpdateAssetFromERPBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {    
    private InterfaceCommonLog.interfaceLog         interfaceLog                = new InterfaceCommonLog.interfaceLog('IF-CSPLUS-018', 'IF_ERP_Material');
    private static Map<String,Schema.SObjectType>   schemaMap                   = Schema.getGlobalDescribe();

    // asset의 ExternalKey-EQUNR__c *asset upsert 용
    private static Schema.SObjectField              assetEField                 = schemaMap.get('Asset').getDescribe().fields.getMap().get('Name');
    
    // 장비 Name 을 Key로 장비에 속한 List를 가져옴 *ifMaterial isComplete__c true 변경용
    // List 로 하지않은 이유 : List 로 해서 한번에 dml 하면 IF_Material__c 가 너무 많아 dml row limit 10000에 걸릴 수도 있을 것 같아서 Map으로 만들어 Execute에서 나눠서 처리
    private Map<String, List<IF_Material__c>>       ifMaterialListForName       = new Map<String, List<IF_Material__c>>();
    // 장비 Name 을 Key로 해당 장비 최신 batch execute 시간을 가져옴 *장비별 최신 오브젝트 불러오기 용
    private Map<String, Datetime>                   batchExecuteTimeForName     = new Map<String, Datetime>();
    // 장비 Name 을 Key로 Asset Id를 가져옴
    private Map<String, String>                     assetIdForName              = new Map<String, String>();
    // 장비정보 Insert 후 주문의 SOSerial Number 업데이트 위한 Map
    private Map<String, Order>                      updateOrderMap              = new Map<String, Order>();
    // batch method
    public List<IF_Material__c> start(Database.BatchableContext bc) {
        System.debug('DN_UpdateAssetFromERPBatch Start ------------');
        try {
            Map<String, Schema.SObjectField> objectFields = schemaMap.get('IF_Material__c').getDescribe().fields.getMap();
            List<String> fieldsToQuery = new List<String>(objectFields.keySet());

            String  query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM IF_Material__c';
                    query += ' WHERE IsComplete__c = false AND ParameterName__c = \'T_ITEM\'';
                    query += ' ORDER BY CreatedDate ASC, EQUNR__c ASC LIMIT 5000';

            List<IF_Material__c>        ifMaterialList      = (List<IF_Material__c>) Database.query(query);
            // 2025.04.13 추가 - 반복해서 배치를 돌리기 때문에 query해서 더이상 변환할 IF_Material__c 이 없으면 멈춤
            if(ifMaterialList.isEmpty()) System.abortJob(bc.getJobId());
            Map<String, IF_Material__c> T_ITEMForName       = new Map<String, IF_Material__c>();

            System.debug('ifMaterialList ::: ' + ifMaterialList);

            // EQUNR이 같은 중복 ifMaterial-T_ITEM 제거 및 isComplete__c true로 변경
            for (IF_Material__c ifMaterial : ifMaterialList) {
                
                if(T_ITEMForName.get(ifMaterial.EQUNR__c) == null
                    || T_ITEMForName.get(ifMaterial.EQUNR__c).BatchExecuteTime__c < ifMaterial.BatchExecuteTime__c){
                    
                    T_ITEMForName.put(ifMaterial.EQUNR__c, ifMaterial);
                }

                ifMaterial.IsComplete__c = true;
                if(this.ifMaterialListForName.get(ifMaterial.EQUNR__c) != null){
                    this.ifMaterialListForName.get(ifMaterial.EQUNR__c).add(ifMaterial);
                }else{
                    this.ifMaterialListForName.put(ifMaterial.EQUNR__c, new List<IF_Material__c>{ifMaterial});
                }
            }

            // 장비별 최신 오브젝트 시간 저장
            for (IF_Material__c ifMaterial : T_ITEMForName.values()) {
                this.batchExecuteTimeForName.put(ifMaterial.EQUNR__c, ifMaterial.BatchExecuteTime__c);
            }

            return T_ITEMForName.values();
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
        System.debug('DN_UpdateAssetFromERPBatch Execute ------------');

        TriggerHandler.bypass('AssetTriggerHandler');
        System.debug('<< TriggerHandler.bypass On >>');
        
        List<IF_Material__c> updateIFMaterialList = new List<IF_Material__c>();

        System.SavePoint savePoint = Database.setSavepoint();
        try {
            // 0. T_PARTNERS_INFO query 에 필요한 scope 장비 Name List 생성 + mapping에 필요한 object query용 map 생성
            List<String> nameList = new List<String>();
            Map<String, Order>              orderForSONo                = new Map<String, Order>();
            Map<String, ServiceResource>    serviceResourceForStaffNo   = new Map<String, ServiceResource>();
            Map<String, ServiceTerritory>   serviceTerritoryForWCCode   = new Map<String, ServiceTerritory>();
            for (IF_Material__c T_ITEM : scope) {
                nameList.add(T_ITEM.EQUNR__c);
                if(!isEmptyValue(T_ITEM.KDAUF__c))          orderForSONo.put(T_ITEM.KDAUF__c, null);
                if(!isEmptyValue(T_ITEM.PERSON_RES__c))     serviceResourceForStaffNo.put(T_ITEM.PERSON_RES__c.substring(4), null);
                if(!isEmptyValue(T_ITEM.RES_MN_WK_CTR__c))  serviceTerritoryForWCCode.put(T_ITEM.RES_MN_WK_CTR__c, null);
                if(!isEmptyValue(T_ITEM.LOC_ARBPL__c))      serviceTerritoryForWCCode.put(T_ITEM.LOC_ARBPL__c, null);
                if(!isEmptyValue(T_ITEM.ORG_ARBPL__c))      serviceTerritoryForWCCode.put(T_ITEM.ORG_ARBPL__c, null);
            }

            // ifMaterial-T_PARTNERS_INFO query 후 mapping 용 accountIdForCustomerCode 생성
            // 1. ifMaterial-T_PARTNERS_INFO  query
            Map<String, Schema.SObjectField> objectFields = schemaMap.get('IF_Material__c').getDescribe().fields.getMap();
            List<String> fieldsToQuery = new List<String>(objectFields.keySet());

            String  query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM IF_Material__c';
                    query += ' WHERE IsComplete__c = false AND ParameterName__c = \'T_PARTNERS_INFO\'';
                    query += ' AND EQUNR__c IN (\''+ String.join(nameList, '\',\'') +'\')';
                    query += ' ORDER BY CreatedDate ASC LIMIT 50000';

            List<IF_Material__c> T_PARTNERS_INFOList = (List<IF_Material__c>) Database.query(query);
            
            // 2. account query 에 필요한 최신 ifMaterial-T_PARTNERS_INFO 의 customerCodeList 생성 및 isComplete__c true로 변경 
            Map<String, List<IF_Material__c>> T_PARTNERS_INFOListForName = new Map<String, List<IF_Material__c>>();
            List<String> customerCodeList = new List<String>();

            for(IF_Material__c T_PARTNERS_INFO : T_PARTNERS_INFOList){
                T_PARTNERS_INFO.isComplete__c = true;
                T_PARTNERS_INFO.PARNR__c = String.valueOf(Integer.valueOf(T_PARTNERS_INFO.PARNR__c));

                if(T_PARTNERS_INFO.BatchExecuteTime__c == this.batchExecuteTimeForName.get(T_PARTNERS_INFO.EQUNR__c)){
                    customerCodeList.add(T_PARTNERS_INFO.PARNR__c);

                    // 3. 최신 ifMaterial-T_PARTNERS_INFO에서 장비 Name 을 Key로 ifMaterial-T_PARTNERS_INFO List 를 가진 Map 생성
                    if(T_PARTNERS_INFOListForName.get(T_PARTNERS_INFO.EQUNR__c) == null){
                        T_PARTNERS_INFOListForName.put(T_PARTNERS_INFO.EQUNR__c, new List<IF_Material__c>{T_PARTNERS_INFO});
                    }else{
                        T_PARTNERS_INFOListForName.get(T_PARTNERS_INFO.EQUNR__c).add(T_PARTNERS_INFO);
                    }
                }
            }
            if(T_PARTNERS_INFOList.size() > 0) updateIFMaterialList.addAll(T_PARTNERS_INFOList);

            // 4. account query 후 accountIdForCustomerCode 생성
            Map<String, String> accountIdForCustomerCode = new Map<String, String>();

            List<Account> accountList = [
                SELECT Id, CustomerCode__c
                FROM Account
                WHERE CustomerCode__c IN :customerCodeList
            ];
            for (Account account : accountList) accountIdForCustomerCode.put(account.CustomerCode__c, account.Id);

            // 5. mapping에 필요한 object map 전부 채우기
            // 5-1. orderForSONo 에 order query 해서 채워넣기
            List<Order> orderList = [
                SELECT  Id, RelatedDealer__c, RelatedDealer__r.Name, ERPPSONo__c, ERPRSONo__c, SOSerialNumber__c, SerialNumber__c
                FROM    Order
                WHERE   ERPPSONo__c IN :orderForSONo.keySet()
            ];

            for (Order order : orderList) {
                if(orderForSONo.get(order.ERPPSONo__c) == null) orderForSONo.put(order.ERPPSONo__c, order);
                else {
                    Order currentOrder  = orderForSONo.get(order.ERPPSONo__c);

                    if(currentOrder.ERPRSONo__c != null) continue;
                    else if(order.ERPRSONo__c   != null) orderForSONo.put(order.ERPPSONo__c, order);
                }
            }
            // 5-2. serviceResourceForStaffNo 에 query 해서 채워넣기
            List<ServiceResource> serviceResourceList = [
                SELECT  Id, StaffNumber__c
                FROM    ServiceResource
                WHERE   StaffNumber__c IN :serviceResourceForStaffNo.keySet()
            ];
            for (ServiceResource serviceResource : serviceResourceList) 
                serviceResourceForStaffNo.put(serviceResource.StaffNumber__c, serviceResource);
            // 5-3. serviceTerritoryForWCCode 에 query 해서 채워넣기
            List<ServiceTerritory> serviceTerritoryList = [
                SELECT  Id, WCCode__c
                FROM    ServiceTerritory
                WHERE   WCCode__c IN : serviceTerritoryForWCCode.keySet()
            ];
            for (ServiceTerritory serviceTerritory : serviceTerritoryList) 
                serviceTerritoryForWCCode.put(serviceTerritory.WCCode__c, serviceTerritory);

            // 6. asset mapping 및 적재 object isComplete__c true update
            Map<String, Asset> assetForEKey = new Map<String, Asset>();

            for (IF_Material__c ifMaterial : scope) {
                System.debug('ifMaterial ::: ' + ifMaterial);
                Asset asset = generateAsset(ifMaterial,
                    T_PARTNERS_INFOListForName, 
                    accountIdForCustomerCode,
                    orderForSONo,
                    serviceResourceForStaffNo,
                    serviceTerritoryForWCCode);

                assetForEKey.put(asset.Name, asset);

                if(this.ifMaterialListForName.get(ifMaterial.EQUNR__c) != null) 
                    updateIFMaterialList.addAll(this.ifMaterialListForName.get(ifMaterial.EQUNR__c));
            }

            if(assetForEKey.keySet().size() > 0) {
                Map<String, Order> SerialUpdate = new Map<String, Order>();
                System.debug('assetForEKey ::: ' + assetForEKey);
                Database.Upsert(assetForEKey.values(), assetEField, true);
                for(Asset asset : assetForEKey.values()){
                    assetIdForName.put(asset.Name, asset.Id);
                    if(updateOrderMap.get(asset.Name) != null) {
                        Order serialMatching = updateOrderMap.get(asset.Name);
                        serialMatching.SOSerialNumber__c = asset.Id;
                        SerialUpdate.put(serialMatching.Id, serialMatching);
                    }
                }
                if(SerialUpdate.size() > 0) update SerialUpdate.values();
            }
            if(!updateIFMaterialList.isEmpty())     Database.Update(updateIFMaterialList, true);
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

        TriggerHandler.clearBypass('AssetTriggerHandler');
        System.debug('<< TriggerHandler.bypass Off >>');
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('DN_UpdateAssetFromERPBatch Finish ------------');
        try {
            // 필요 파라미터들 들고 파일 생성
            // DN_UploadFileToAssetFromERPBatch batchInstance =
            //     new DN_UploadFileToAssetFromERPBatch(this.batchExecuteTimeForName, this.assetIdForName);

            // Database.executeBatch(batchInstance);

            // 2025.04.13 추가 - 한번에 너무 많은 데이터를 돌리면 heapsize Error 가 떠서 LIMIT 줄이고 Batch 반복
            DN_UpdateAssetFromERPBatch batchInstance = new DN_UpdateAssetFromERPBatch();
            if(!Test.isRunningTest()) Database.executeBatch(batchInstance);
        } catch (Exception e) {
            this.interfaceLog.errorText = new List<String>();
            this.interfaceLog.errorText.add('[' + e.getLineNumber() + ']' + e.getMessage());   
            InterfaceCommonLog ifCommonLog = new InterfaceCommonLog();
            ifCommonLog.insertLog(new List<InterfaceCommonLog.interfaceLog>{this.interfaceLog});

            System.debug('Error ::: '         + e.getMessage());
            System.debug('Line Number ::: '   + e.getLineNumber());

            System.abortJob(bc.getJobId());
        }
    }


    //util method
    private Asset generateAsset(IF_Material__c ifMaterial, 
        Map<String, List<IF_Material__c>> T_PARTNERS_INFOListForName,
        Map<String, String> accountIdForCustomerCode, 
        Map<String, Order> orderForSONo,
        Map<String, ServiceResource> serviceResourceForStaffNo,
        Map<String, ServiceTerritory> serviceTerritoryForWCCode){
            
        Asset asset = new Asset();
        try {
            // General
            asset.Name                  = isEmptyValue(ifMaterial.EQUNR__c) ? null : ifMaterial.EQUNR__c;
            asset.MachineName__c        = isEmptyValue(ifMaterial.TYPBZ__c) ? null : ifMaterial.TYPBZ__c;

            asset.Description           = isEmptyValue(ifMaterial.EQKTX__c) ? null : ifMaterial.EQKTX__c;
            asset.Material__c           = isEmptyValue(ifMaterial.MATNR__c) ? null : ifMaterial.MATNR__c;
            asset.SerialNumber          = isEmptyValue(ifMaterial.SERNR__c) ? null : ifMaterial.SERNR__c;
            asset.Status                = isEmptyValue(ifMaterial.TXT04__c) ? null : ifMaterial.TXT04__c;
            asset.InternNoteLong__c     = isEmptyValue(ifMaterial.INTERNAL_NOTE__c) ? null : ifMaterial.INTERNAL_NOTE__c;
            
            asset.Class__c              = isEmptyValue(ifMaterial.CLASS__c) ? null : ifMaterial.CLASS__c;
            asset.ObjectType__c         = isEmptyValue(ifMaterial.EQART__c) ? null : ifMaterial.EQART__c;
            asset.StartUpDate__c        = ifMaterial.INBDT__c == '0000-00-00' || isEmptyValue(ifMaterial.INBDT__c) ? null: Date.valueOf(ifMaterial.INBDT__c);
            asset.AcquisitionDate__c    = ifMaterial.ANSDT__c == '0000-00-00' || isEmptyValue(ifMaterial.ANSDT__c) ? null: Date.valueOf(ifMaterial.ANSDT__c);
            asset.ManufacturerCode__c   = isEmptyValue(ifMaterial.HERST__c) ? null : ifMaterial.HERST__c;
            
            asset.NCType__c             = isEmptyValue(ifMaterial.M_ATWRT__c)   ? null : ifMaterial.M_ATWRT__c;
            asset.NCNo__c               = isEmptyValue(ifMaterial.ATWRT__c)     ? null : ifMaterial.ATWRT__c;
            asset.ManufacturerName__c   = isEmptyValue(ifMaterial.HERST__c)     ? null : ifMaterial.HERST__c.contains('/') ? ifMaterial.HERST__c.split('/')[1] : ifMaterial.HERST__c;
            asset.ManufCountry__c       = isEmptyValue(ifMaterial.HERLD__c)     ? null : ifMaterial.HERLD__c;
            asset.CharValue__c          = isEmptyValue(ifMaterial.M_ATWRT2__c)  ? null : ifMaterial.M_ATWRT2__c;
            
            if(isEmptyValue(ifMaterial.BAUJJ__c) || isEmptyValue(ifMaterial.BAUMM__c)) asset.ConstrYrMth__c = '';
            else asset.ConstrYrMth__c   = ifMaterial.BAUJJ__c + '/' + ifMaterial.BAUMM__c;

            asset.InstallationStart__c  = ifMaterial.ZZ_INST_START__c   == '0000-00-00' || isEmptyValue(ifMaterial.ZZ_INST_START__c)  ? null: Date.valueOf(ifMaterial.ZZ_INST_START__c);
            asset.InstallationFinish__c = ifMaterial.ZZ_INST_FINISH__c  == '0000-00-00' || isEmptyValue(ifMaterial.ZZ_INST_FINISH__c) ? null: Date.valueOf(ifMaterial.ZZ_INST_FINISH__c);

            String orderSONo = null;

            if(!isEmptyValue(ifMaterial.KDAUF__c)) {
                orderSONo = ifMaterial.KDAUF__c;
            }
            
            if(orderForSONo.get(orderSONo) != null){
                asset.Order__c              = orderForSONo.get(orderSONo).Id;
                asset.SalesAgency__c        = orderForSONo.get(orderSONo).RelatedDealer__c != null ? '' : orderForSONo.get(orderSONo).RelatedDealer__r.Name;
             
                if(orderForSONo.get(orderSONo).SOSerialNumber__c == null && orderForSONo.get(orderSONo).SerialNumber__c != null){
                    Order order = orderForSONo.get(orderSONo);
                    updateOrderMap.put(ifMaterial.EQUNR__c, order);
                }
            }

            String staffNo = '';
            if(ifMaterial.PERSON_RES__c != null && ifMaterial.PERSON_RES__c.length() > 4) staffNo = ifMaterial.PERSON_RES__c.substring(4);
            if(serviceResourceForStaffNo.get(staffNo) == null){
                asset.InstEngineer__c       = null;
            }else{
                asset.InstEngineer__c       = serviceResourceForStaffNo.get(staffNo).Id;
            }

            if(serviceTerritoryForWCCode.get(ifMaterial.RES_MN_WK_CTR__c) == null){
                asset.InstWorkCenter__c     = null;
            }else{
                asset.InstWorkCenter__c     = serviceTerritoryForWCCode.get(ifMaterial.RES_MN_WK_CTR__c).Id;
            }
            if(serviceTerritoryForWCCode.get(ifMaterial.LOC_ARBPL__c) == null){
                asset.WorkCenter__c         = null;
            }else{
                asset.WorkCenter__c         = serviceTerritoryForWCCode.get(ifMaterial.LOC_ARBPL__c).Id;
            }
            if(serviceTerritoryForWCCode.get(ifMaterial.ORG_ARBPL__c) == null){
                asset.MainWorkCtr__c        = null;
            }else{
                asset.MainWorkCtr__c        = serviceTerritoryForWCCode.get(ifMaterial.ORG_ARBPL__c).Id;
            }

            // Warranty
            asset.WarrantyStartDateWages__c     = ifMaterial.GWLDT__c   == '0000-00-00' || isEmptyValue(ifMaterial.GWLDT__c)   ? null: Date.valueOf(ifMaterial.GWLDT__c);
            asset.WarrantyEndWages__c           = ifMaterial.GWLEN__c   == '0000-00-00' || isEmptyValue(ifMaterial.GWLEN__c)   ? null: Date.valueOf(ifMaterial.GWLEN__c);
            asset.WarrantyStartDate__c          = ifMaterial.V_GWLDT__c == '0000-00-00' || isEmptyValue(ifMaterial.V_GWLDT__c) ? null: Date.valueOf(ifMaterial.V_GWLDT__c);
            asset.WarrantyEnd__c                = ifMaterial.V_GWLEN__c == '0000-00-00' || isEmptyValue(ifMaterial.V_GWLEN__c) ? null: Date.valueOf(ifMaterial.V_GWLEN__c);
            asset.Biliing__c                    = ifMaterial.WADAT_IST__c == '0000-00-00' || isEmptyValue(ifMaterial.WADAT_IST__c) ? 'N' : 'Y';
            asset.WarrantyMasterLabor__c        = ifMaterial.MGANR__c == '0000000000000000' || isEmptyValue(ifMaterial.MGANR__c) ? null: ifMaterial.MGANR__c;

            // Location
            asset.Maintplant__c         = isEmptyValue(ifMaterial.SWERK__c)     ? null : ifMaterial.SWERK__c;
            asset.PlantSectionCode__c   = isEmptyValue(ifMaterial.BEBER__c)     ? null : ifMaterial.BEBER__c;
            asset.PlantSectionName__c   = isEmptyValue(ifMaterial.BEBER_TXT__c) ? null : ifMaterial.BEBER_TXT__c;

            // Organization
            asset.CompanyCode__c        = isEmptyValue(ifMaterial.BUKRS__c)     ? null : ifMaterial.BUKRS__c;
            asset.BusinessArea__c       = isEmptyValue(ifMaterial.GSBER__c)     ? null : ifMaterial.GSBER__c; // Business Area
            asset.PlanningPlant__c      = isEmptyValue(ifMaterial.IWERK__c)     ? null : ifMaterial.IWERK__c; // Planning Plant
            asset.PlannerGrp__c         = isEmptyValue(ifMaterial.INGRP__c)     ? null : ifMaterial.INGRP__c; // Planner Grp

            asset.CatalogProfile__c     = isEmptyValue(ifMaterial.RBNR__c) ? null : ifMaterial.RBNR__c; // Catalog Profile

            if(T_PARTNERS_INFOListForName.get(ifMaterial.EQUNR__c) != null){
                for (IF_Material__c T_PARTNERS_INFO : T_PARTNERS_INFOListForName.get(ifMaterial.EQUNR__c)) {
                    if(T_PARTNERS_INFO.VTEXT__c == 'Sold-to party' && accountIdForCustomerCode.get(T_PARTNERS_INFO.PARNR__c) != null) 
                        asset.SoldTo__c = accountIdForCustomerCode.get(T_PARTNERS_INFO.PARNR__c);
                    else if(T_PARTNERS_INFO.VTEXT__c == 'Ship-to party' && accountIdForCustomerCode.get(T_PARTNERS_INFO.PARNR__c) != null) 
                        asset.AccountId = accountIdForCustomerCode.get(T_PARTNERS_INFO.PARNR__c);
                }
            }

            asset.IsMig__c = true;
        } catch (Exception e) {
            System.debug('['+ e.getLineNumber() +'] ' + e.getMessage());
            return null;
        }
        return asset;
    }
    private Boolean isEmptyValue(String value){
        return value == 'null' || value == '' || value == null;
    }
}