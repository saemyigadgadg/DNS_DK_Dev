/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-07-25
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-02-18   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public without sharing class DN_AssetIFRunController {
    public DN_AssetIFRunController() {}

    // 장비 정보 변경 시 오류발생하면 장비 상세화면에서 버튼으로 해당장비 정보 재전송 하는 메서드
    @auraEnabled
    public static ResultWrapper callAssetIF(String recordId) {

        ResultWrapper result = new ResultWrapper();

        // String fieldSetName = 'ERP_Fields';

        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get('Asset');
        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = describeResult.fieldSets.getMap();
        List<String> fields = new List<String>();

        if (fieldSetMap.containsKey('ERP_Fields')) {
            Schema.FieldSet fieldSet = fieldSetMap.get('ERP_Fields');
            for (Schema.FieldSetMember field : fieldSet.getFields()) {
                fields.add(field.getFieldPath());
            }
        } else {
            result.isSuccess = false;
            result.message = 'FieldSet "ERP_Fields" not found for Object Asset';
            return result;
        }
        String query = 'SELECT ' + String.join(fields, ', ')+ ', WorkCenter__r.WCCode__c, IsECUSCahnge__c, Name, Account.CountryLookup__r.CountryCode__c, Account.Name, Account.Representative__c, Account.ShippingAddress, Account.ShippingStreet, Account.ShippingPostalCode, Account.ShippingCity, Account.RegionLookup__r.RegionCode__c, Account.Phone, Account.CustomerCode__c, SoldTo__r.CustomerCode__c, MainWorkCtr__r.WCCode__c, Owner.ERP_Key__c, OwnerId' + ' FROM Asset WHERE Id = \'' + recordId + '\' LIMIT 1';

        System.debug(query);

        Asset asset = Database.query(query);

        IF_ERP_Material_Classes.IF_CSPLUS_017_Req wrapper_01 = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req();

        IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_ADDRESS temp01_i_address = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_ADDRESS();
        
        temp01_i_address.NAME1      = asset.Account.Name;
        temp01_i_address.NAME2      = asset.Account.Representative__c;
        temp01_i_address.STREET     = asset.Account.ShippingStreet == null ? '' : asset.Account.ShippingStreet;
        temp01_i_address.POST_CODE1 = asset.Account.ShippingPostalCode == null ? '' : asset.Account.ShippingPostalCode.replace('-', '');
        temp01_i_address.CITY1      = asset.Account.ShippingCity == null ? '' : asset.Account.ShippingCity;

        temp01_i_address.COUNTRY    = asset.Account.CountryLookup__r.CountryCode__c;
        temp01_i_address.REGION     = asset.Account.RegionLookup__r.RegionCode__c;
        temp01_i_address.TEL_NUMBER = asset.Account.Phone;

        IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_GENERAL temp01_i_general = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_GENERAL();
        // temp01_i_general.OBJECTTYPE     = asset.ObjectType__c;
        // temp01_i_general.START_FROM     = asset.StartUpDate__c == null ? '' : formattingDate(asset.StartUpDate__c);
        // temp01_i_general.ACQDATE        = asset.AcquisitionDate__c == null ? '' : formattingDate(asset.AcquisitionDate__c);
        // temp01_i_general.MANFACTURE     = asset.ManufacturerCode__c;
        // temp01_i_general.MANMODEL       = asset.MachineName__c; //asset.ManufacturerName__c 인거같음 MachineName__c 은 매핑정의서 존재 x

        // temp01_i_general.MANCOUNTRY     = asset.ManufCountry__c;
        // // ConstrYrMth__c 값이 null이 아니면 /를 기준으로 나누어 CONSTYEAR와 CONSTMONTH 설정
        // if (asset.ConstrYrMth__c != null && asset.ConstrYrMth__c != '') {
        //     List<String> yearMonth = asset.ConstrYrMth__c.split('/');
        //     System.debug('yearMonth ::: ' + yearMonth);
        //     if (yearMonth.size() == 2) {
        //         temp01_i_general.CONSTYEAR = yearMonth[0]; // 년도
        //         temp01_i_general.CONSTMONTH = yearMonth[1]; // 월
        //     }
        // }
        // temp01_i_general.ZZ_INST_START  = asset.InstallationStart__c == null ? '' : formattingDate(asset.InstallationStart__c);
        // temp01_i_general.ZZ_INST_FINISH = asset.InstallationFinish__c == null ? '' : formattingDate(asset.InstallationFinish__c);

        IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_LOCATION temp01_i_location = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_LOCATION();
        temp01_i_location.MAINTPLANT    = asset.Maintplant__c;
        // temp01_i_location.PLSECTN       = asset.PlantSectionCode__c;
        temp01_i_location.ARBPL         = asset.WorkCenter__r.WCCode__c;
        temp01_i_location.WERKS         = asset.Maintplant__c;

        IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_WARRANTY temp01_i_warranty = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_WARRANTY();
        temp01_i_warranty.GWLDT         = asset.WarrantyStartDateWages__c == null ? '' : formattingDate(asset.WarrantyStartDateWages__c);
        temp01_i_warranty.GWLEN         = asset.WarrantyEndWages__c == null ? '' : formattingDate(asset.WarrantyEndWages__c);
        temp01_i_warranty.V_GWLEN       = asset.WarrantyEnd__c == null ? '' : formattingDate(asset.WarrantyEnd__c);
        temp01_i_warranty.DELFLAG       = asset.WarrantyStartDateWages__c == null && asset.WarrantyEnd__c == null && asset.WarrantyEndWages__c == null? 'X' : '';

        IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_ORG temp01_i_org = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_ORG();
        // temp01_i_org.BUS_AREA           = asset.BusinessArea__c;
        temp01_i_org.PLANPLANT          = asset.PlanningPlant__c;
        temp01_i_org.PLANGROUP          = asset.PlannerGrp__c;
        temp01_i_org.ARBPL              = asset.MainWorkCtr__r.WCCode__c;
        temp01_i_org.WERKS              = asset.PlanningPlant__c;
        // temp01_i_org.CATPROFILE         = asset.CatalogProfile__c;

        IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_USERINFO temp01_i_userInfo = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_USERINFO();
        temp01_i_userInfo.BNAME    = asset.OwnerId;

        temp01_i_userInfo.RNAME = String.valueOf(asset.Owner.ERP_Key__c);

        wrapper_01.I_EQUNR           = asset.Name;
        wrapper_01.I_AG_PARNR        = asset.SoldTo__r.CustomerCode__c == null ? '' : asset.SoldTo__r.CustomerCode__c.leftPad(10, '0'); // Sold To
        wrapper_01.I_WE_PARNR        = asset.Account.CustomerCode__c == null ? '' : asset.Account.CustomerCode__c.leftPad(10, '0'); // Ship To
        wrapper_01.I_PARTNER_DEL_FLG = asset.SoldTo__r.CustomerCode__c == null && asset.Account.CustomerCode__c == null ? 'X' : '';
        wrapper_01.I_NOTE            = asset.InternNoteLong__c;
        // wrapper_01.I_CLASS_VALUE     = asset.NCNo__c;
        // wrapper_01.I_DESC            = asset.Description;
        wrapper_01.I_STATUS_FLG      = asset.IsECUSCahnge__c ? 'X' : '';

        wrapper_01.I_USERINFO        = temp01_i_userInfo;
        wrapper_01.I_ADDRESS         = temp01_i_address;
        wrapper_01.I_GENERAL         = temp01_i_general;
        wrapper_01.I_LOCATION        = temp01_i_location;
        wrapper_01.I_ORG             = temp01_i_org;
        wrapper_01.I_WARRANTY        = temp01_i_warranty;
    
        IF_ERP_Material method = new IF_ERP_Material();
        IF_ERP_Material_Classes.IF_CSPLUS_017_Res response = method.IF_CSPLUS_017(wrapper_01);

        System.debug('asset:::' + asset);
        System.debug('response:::' + response);

        if (response.O_RETURN.TYPE == 'E') {
            asset.IsERPUpdate__c = true;
            asset.ERPUpdateError__c = response.O_RETURN.MESSAGE;
            result.isSuccess = false;
            result.message = response.O_RETURN.MESSAGE;
        } else if (response.O_RETURN.TYPE == '' && response.T_RETURN.size() > 0) {
            asset.IsERPUpdate__c = true;
            asset.ERPUpdateError__c = response.T_RETURN[0].MESSAGE;
            result.isSuccess = false;
            result.message = response.T_RETURN[0].MESSAGE;
        } else if (response.O_RETURN.TYPE == 'S') {
            asset.IsERPUpdate__c = false;
            asset.ERPUpdateError__c = '';
            asset.IsECUSCahnge__c = false;
        }

        TriggerHandler.bypass('AssetTriggerHandler');

        update asset;

        TriggerHandler.clearBypass('AssetTriggerHandler');

        return result;
    }

    // 장비 상세 화면에서 버튼으로 ERP의 장비 정보를 수신해서 장비 정보 업데이트 하는 메서드
    @AuraEnabled
    public static ResultWrapper updateAssetFromERP(String recordId) {

        ResultWrapper result = new ResultWrapper();
        Asset asset = [SELECT Id, Name, IsECUSCahnge__c, Order__c, SalesAgency__c FROM Asset WHERE Id = :recordId LIMIT 1];

        try {
    
            IF_ERP_Material_Classes.IF_CSPLUS_018_Req request = new IF_ERP_Material_Classes.IF_CSPLUS_018_Req();
            // request.I_FROM = '20250219';
            // request.I_TO = '20250219';
            IF_ERP_Material_Classes.IF_CSPLUS_018_Req_T_ITEM t_item = new IF_ERP_Material_Classes.IF_CSPLUS_018_Req_T_ITEM();
            t_item.EQUNR = asset.Name;
            request.T_ITEM.add(t_item);
            // request.I_DOCUMENT_FILE = 'X';
            
            IF_ERP_Material instance = new IF_ERP_Material();
            IF_ERP_Material_Classes.IF_CSPLUS_018_Res response = instance.IF_CSPLUS_018(request);

            result.message = response.O_RETURN.MESSAGE;
            if (response.O_RETURN.TYPE == 'E') {
                result.isSuccess = false;
                asset.IsERPUpdate__c = true;
                asset.ERPUpdateError__c = response.O_RETURN.MESSAGE;
            } else if (response.O_RETURN.TYPE == 'S') {
                if (response.T_ITEM.size() > 0) {
                    asset.IsERPUpdate__c = false;
                    asset.ERPUpdateError__c = '';
                    IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_ITEM ifMaterial = response.T_ITEM[0];

                    // General
                    asset.MachineName__c        = ifMaterial.TYPBZ; // Model number
                    asset.Description           = ifMaterial.EQKTX; // Description
                    asset.Material__c           = ifMaterial.MATNR; // Material
                    asset.SerialNumber          = ifMaterial.SERNR; // Serial Number
                    asset.Status                = ifMaterial.TXT04; // Status
                    asset.InternNoteLong__c     = ifMaterial.INTERNAL_NOTE; // Intern.note(장비특성)
                    
                    asset.Class__c              = ifMaterial.IF_CLASS; // Class
                    asset.ObjectType__c         = ifMaterial.EQART; // Object_type
                    asset.StartUpDate__c        = ifMaterial.INBDT == '0000-00-00' || ifMaterial.INBDT == '' || ifMaterial.INBDT == null? null: Date.valueOf(ifMaterial.INBDT); // Start-up date
                    asset.AcquisitionDate__c    = ifMaterial.ANSDT == '0000-00-00' || ifMaterial.ANSDT == '' || ifMaterial.ANSDT == null? null: Date.valueOf(ifMaterial.ANSDT); // Acquisition date
                    asset.ManufacturerCode__c   = ifMaterial.HERST; // Manufacturer(Code)
        
                    asset.NCType__c             = ifMaterial.M_ATWRT; // NC type
                    asset.NCNo__c               = ifMaterial.ATWRT; // NC No
                    asset.ManufacturerName__c   = ifMaterial.HERST == '' ? null : ifMaterial.HERST.contains('/') ? ifMaterial.HERST.split('/')[1] : ifMaterial.HERST; // Manufacturer(Name)
                    asset.ManufCountry__c       = ifMaterial.HERLD; // ManufCountry
                    asset.CharValue__c          = ifMaterial.M_ATWRT2; // MAX. SPINDLE SPEED
                    if (ifMaterial.BAUJJ == '' || ifMaterial.BAUMM == '') {
                        asset.ConstrYrMth__c = '';
                    } else {
                        asset.ConstrYrMth__c        = ifMaterial.BAUJJ + '/' + ifMaterial.BAUMM; // Constr.yr/mth
                    }
                    asset.InstallationStart__c  = ifMaterial.ZZ_INST_START  == '0000-00-00' || ifMaterial.ZZ_INST_START    == '' || ifMaterial.ZZ_INST_START    == null? null: Date.valueOf(ifMaterial.ZZ_INST_START); // Installation start
                    asset.InstallationFinish__c = ifMaterial.ZZ_INST_FINISH == '0000-00-00' || ifMaterial.ZZ_INST_FINISH   == '' || ifMaterial.ZZ_INST_FINISH   == null? null: Date.valueOf(ifMaterial.ZZ_INST_FINISH); // Installation End

                    // asset.SalesAgency__c = ifMaterial.ZI_NAME1;
                    if (ifMaterial.KDAUF != '') {
                        List<Order> orderList = [SELECT Id, RelatedDealer__r.Name, ERPRSONo__c FROM Order WHERE ERPPSONo__c = :ifMaterial.KDAUF];

                        System.debug('orderList ::: ' + JSOn.serialize(orderList));

                        // 변경 로직
                        if(orderList.size() > 1){
                            for(Order order : orderList){
                                if(order.ERPRSONo__c != null){
                                    asset.Order__c          = order.Id; // Sales Order (Lookup)
                                    asset.SalesAgency__c    = order.RelatedDealer__r.Name; // Sales Agency
                                    break;
                                }
                            }
                        }else if(orderList.size() > 0 && orderList[0].RelatedDealer__r.Name != null){
                            asset.Order__c          = orderList[0].Id;
                            asset.SalesAgency__c    = orderList[0].RelatedDealer__r.Name;
                        }
                        // 기존 로직
                        // asset.Order__c = orderList.size() > 0 ? orderList[0].Id : asset.Order__c;
                        // asset.SalesAgency__c = orderList.size() > 0 ? (orderList[0].RelatedDealer__r.Name == null ? asset.SalesAgency__c : orderList[0].RelatedDealer__r.Name) : asset.SalesAgency__c;
                    }

                    if (ifMaterial.PERSON_RES != '' && ifMaterial.PERSON_RES != '00000000') {
                        String staffNumber = ifMaterial.PERSON_RES.substring(4);
                        List<ServiceResource> srList = [SELECT Id FROM ServiceResource WHERE StaffNumber__c = :staffNumber];
                        asset.InstEngineer__c = srList.size() > 0 ? srList[0].Id : null; // Installation Engineer
                    } else {
                        asset.InstEngineer__c = null;
                    }

                    if (ifMaterial.RES_MN_WK_CTR != '') {
                        List<ServiceTerritory> wcList = [SELECT Id FROM ServiceTerritory WHERE WCCode__c = :ifMaterial.RES_MN_WK_CTR];
                        asset.InstWorkCenter__c = wcList.size() > 0 ? wcList[0].Id : null;
                    } else {
                        asset.InstWorkCenter__c = null;
                    }

                    // Warranty
                    asset.WarrantyStartDateWages__c     = ifMaterial.GWLDT   == '0000-00-00' || ifMaterial.GWLDT   == '' || ifMaterial.GWLDT   == null? null : Date.valueOf(ifMaterial.GWLDT);
                    asset.WarrantyEndWages__c           = ifMaterial.GWLEN   == '0000-00-00' || ifMaterial.GWLEN   == '' || ifMaterial.GWLEN   == null? null : Date.valueOf(ifMaterial.GWLEN);
                    asset.WarrantyStartDate__c          = ifMaterial.V_GWLDT == '0000-00-00' || ifMaterial.V_GWLDT == '' || ifMaterial.V_GWLDT == null? null : Date.valueOf(ifMaterial.V_GWLDT);
                    asset.WarrantyEnd__c                = ifMaterial.V_GWLEN == '0000-00-00' || ifMaterial.V_GWLEN == '' || ifMaterial.V_GWLEN == null? null : Date.valueOf(ifMaterial.V_GWLEN);
                    asset.Biliing__c                    = ifMaterial.WADAT_IST == '0000-00-00'? 'N' : 'Y';
                    asset.WarrantyMasterLabor__c        = ifMaterial.MGANR == '' || ifMaterial.MGANR == '0000000000000000' ? null : ifMaterial.MGANR;
        
                    // Location
                    asset.Maintplant__c         = ifMaterial.SWERK;
                    asset.PlantSectionCode__c   = ifMaterial.BEBER;
                    asset.PlantSectionName__c   = ifMaterial.BEBER_TXT;
                    if (ifMaterial.LOC_ARBPL != '') {
                        List<ServiceTerritory> wcList = [SELECT Id FROM ServiceTerritory WHERE WCCode__c = :ifMaterial.LOC_ARBPL];
                        asset.WorkCenter__c = wcList.size() > 0 ? wcList[0].Id : null;
                    } else {
                        asset.WorkCenter__c = null;
                    }
        
                    // Organization
                    asset.CompanyCode__c        = ifMaterial.BUKRS;
                    asset.BusinessArea__c       = ifMaterial.GSBER; // Business Area
                    asset.PlanningPlant__c      = ifMaterial.IWERK; // Planning Plant
                    asset.PlannerGrp__c         = ifMaterial.INGRP; // Planner Grp
                    if (ifMaterial.ORG_ARBPL != '') {
                        // WCCode__c
                        List<ServiceTerritory> wcList = [SELECT Id FROM ServiceTerritory WHERE WCCode__c = :ifMaterial.ORG_ARBPL];
                        asset.MainWorkCtr__c = wcList.size() > 0 ? wcList[0].Id : null;
                    } else {
                        asset.MainWorkCtr__c = null;
                    }
        
                    asset.CatalogProfile__c     = ifMaterial.RBNR; // Catalog Profile

                }

                Map<String, String> partnerMap = new Map<String, String>();
                if (response.T_PARTNERS_INFO.size() > 0) {
                    for (IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_PARTNERS_INFO partner : response.T_PARTNERS_INFO) {
                        if (partner.VTEXT == 'Sold-to party') {
                            partnerMap.put('Sold-to party', String.valueOf(Integer.valueOf(partner.PARNR)));
                        } else if (partner.VTEXT == 'Ship-to party') {
                            partnerMap.put('Ship-to party', String.valueOf(Integer.valueOf(partner.PARNR)));
                        }
                    }

                    List<Account> partnerList = [SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c IN :partnerMap.values()];
                    Map<String, String> accMap = new Map<String, String>();

                    for (Account acc : partnerList) {
                        accMap.put(acc.CustomerCode__c, acc.Id);
                    }

                    // System.debug('Test1 ::: ' + accMap.get(partnerMap.get('Sold-to party')));
                    // System.debug('Test2 ::: ' + accMap.get(partnerMap.get('Ship-to party')));
                    
                    asset.SoldTo__c = accMap.get(partnerMap.get('Sold-to party'));
                    asset.AccountId = accMap.get(partnerMap.get('Ship-to party'));
                } else {
                    asset.SoldTo__c = null;
                    asset.AccountId = null;
                }

                // Map<String, List<String>> documentFileMap = new Map<String, List<String>>();
                // if (response.T_DOCUMENT_FILE.size() > 0) {

                //     for (IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_DOCUMENT_FILE documentFile : response.T_DOCUMENT_FILE) {
                //         List<String> dataList = new List<String>();
                //         if (documentFileMap.get(documentFile.DOKAR) != null) dataList = documentFileMap.get(documentFile.DOKAR);
                //         dataList.add(documentFile.BUFFER);
                //         documentFileMap.put(documentFile.DOKAR, dataList);
                //     }
                // }

                asset.IsERPUpdate__c = false;
                asset.ERPUpdateError__c = '';
                // asset.IsTrigger__c = true;
                TriggerHandler.bypass('AssetTriggerHandler');
                
                Database.SaveResult sr = Database.update(asset);
                if (sr.isSuccess()) {
                    List<IF_Material__c> materialList = [SELECT Id FROM IF_Material__c WHERE IsComplete__c = false AND EQUNR__c = :asset.Name];
                    if (materialList.size() > 0) {
                        List<IF_Material__c> updateList = new List<IF_Material__c>();
                        for (IF_Material__c material : materialList) {
                            material.IsComplete__c = true;
                            updateList.add(material);
                        }

                        if (updateList.size() > 0) update updateList;
                    }

                    // List<ContentVersion> insertCVList = new List<ContentVersion>();
                    // if (response.T_DOCUMENT.size() > 0) {

                    //     deleteFile(sr.getId());

                    //     for (IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_DOCUMENT document : response.T_DOCUMENT) {
                    //         ContentVersion cv = new ContentVersion();
                    //         List<String> fileDataList = documentFileMap.get(document.DOKAR);
                    //         String fileDataString = '';
                    //         for (String dataString : fileDataList) {
                    //             fileDataString += dataString;
                    //         }

                    //         Blob fileData = EncodingUtil.base64Decode(fileDataString);
                    //         cv.VersionData      = fileData;

                    //         String fileName     = document.DKTXT;
                    //         cv.Title            = fileName;
                    //         cv.PathOnClient     = fileName + getExtension(fileData);
                    //         System.debug('cv.PathOnClient ::: ' + cv.PathOnClient);
                
                    //         cv.AssetName__c     = document.OBJKY;
                    //         cv.IsSAPFile__c        = true;
                    //         insertCVList.add(cv);
                    //     }
                    //     if(insertCVList.size() > 0) Database.insert(insertCVList);

                    //     List<String> cvIdList = new List<String>();
                    //     for (ContentVersion cv : insertCVList) cvIdList.add(cv.Id);
            
                    //     List<ContentVersion> queryCVList = [
                    //         SELECT Id, ContentDocumentId, AssetName__c
                    //         FROM ContentVersion
                    //         WHERE Id IN :cvIdList
                    //     ];

                    //     List<ContentDocumentLink> insertCdlList = new List<ContentDocumentLink>();
                    //     for (ContentVersion cv : queryCVList) insertCdlList.add(generateContentDocumentLink(cv, sr.getId()));
                    //     if(insertCdlList.size() > 0) Database.insert(insertCdlList);
                    // }

                }

                TriggerHandler.clearBypass('AssetTriggerHandler');
            }
            
        } catch (Exception e) {
            System.debug('Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
            result.isSuccess = false;
            result.message = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
            asset.IsERPUpdate__c = true;
            asset.ERPUpdateError__c = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
        }

        // update asset;

        return result;

    }

    // Date형태의 값을 yyyyMMdd 형태의 String값으로 변경하는 메서드
    public static String formattingDate(Date dateValue) {
        Datetime datetimeValue = Datetime.newInstance(dateValue.year(), dateValue.month(), dateValue.day());

        return datetimeValue.format('yyyyMMdd');
    }

    // public static void deleteFile(String assetId) {

    //     List<ContentDocument> deleteDocumentList = new List<ContentDocument>();

    //     List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :assetId];



    //     if (cdlList.size() > 0) {
    //         List<String> documentIds = new List<String>();
    //         for (ContentDocumentLink link : cdlList) {
    //             documentIds.add(link.ContentDocumentId);
    //         }

    //         List<ContentVersion> cvList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE IsSAPFile__c = true AND ContentDocumentId IN :documentIds];

    //         List<String> cdIds = new List<String>();
    //         if (cvList.size() > 0) {
    //             for (ContentVersion cv : cvList) {
    //                 cdIds.add(cv.ContentDocumentId);
    //             }

    //             List<ContentDocument> cdList = [SELECT Id FROM ContentDocument WHERE Id IN :cdIds];
    //             if (cdList.size() > 0) deleteDocumentList = cdList;
                
    //         }

    //     }

    //     if (deleteDocumentList.size() > 0) delete deleteDocumentList;

    // }

    // public static String getExtension(Blob fileData){
    //     try {
    //         String fileString = EncodingUtil.convertToHex(fileData).substring(0, 25).toUpperCase();
    //         System.debug('fileString ::: ' + fileString);
            
    //         // pdf, png, jpeg, avi(보류)
    //         if(fileString.startsWith('255044462D')){
    //             return '.pdf';
    //         }else if(fileString.startsWith('89504E470D0A1A0A')){
    //             return '.png';
    //         }else if(
    //             fileString.startsWith('89504E470D0A1A0A')
    //             || fileString.startsWith('FFD8FFDB')
    //             || fileString.startsWith('FFD8FFE000104A4649460001')
    //             || fileString.startsWith('FFD8FFEE')
    //             || fileString.startsWith('FFD8FFE0')){
    //             return '.jpg';
    //         }else if(
    //             fileString.startsWith('EFBBBF')
    //             || fileString.startsWith('FFFE')
    //             || fileString.startsWith('FEFF')
    //             || fileString.startsWith('FFFE0000')
    //             || fileString.startsWith('0000FEFF')
    //             || fileString.startsWith('0EFEFF')){
    //             return '.txt';
    //         }else if(fileString.startsWith('52494646????????41564920')){
    //             return '.avi';
    //         }
    //     } catch (Exception e) {
    //         throw e;
    //     }
    //     return '';
    // }

    // public static ContentDocumentLink generateContentDocumentLink(ContentVersion cv, String assetId){
    //     ContentDocumentLink cdl = new ContentDocumentLink();
    //     try {
    //         cdl.ContentDocumentId   = cv.ContentDocumentId;
    //         cdl.LinkedEntityId      = assetId;
    //         cdl.ShareType = 'I';
    //         cdl.Visibility = 'AllUsers';
    //     } catch (Exception e) {
    //         throw e;
    //     }
    //     return cdl;
    // }

    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess { get; set;}
        @AuraEnabled public String message { get; set;}

        public ResultWrapper() {
            this.isSuccess = true;
            this.message = 'Success';
        }
    }
}