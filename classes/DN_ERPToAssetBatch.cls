/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public class DN_ERPToAssetBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public String query;

    Map<String, String> statusECUSMap = new Map<String, String>();

    public DN_ERPToAssetBatch(String query, Map<String, String> statusECUSMap) {
        this.query = query;
        this.statusECUSMap = statusECUSMap;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('query:::' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        Id currentUserId = UserInfo.getUserId();
        List<Asset> assets = (List<Asset>) scope;
        Asset asset = assets[0];

        try {

            IF_ERP_Material_Classes.IF_CSPLUS_017_Req wrapper_01 = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req();
 
            /**
             * address
             */
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
                //     // System.debug('yearMonth ::: ' + yearMonth);
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
                temp01_i_location.ARBPL         = asset.WorkCenter__r.WCCode__c == null ? '' : asset.WorkCenter__r.WCCode__c;
                temp01_i_location.WERKS         = asset.Maintplant__c;
        
                IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_WARRANTY temp01_i_warranty = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_WARRANTY();
                temp01_i_warranty.GWLDT         = asset.WarrantyStartDateWages__c == null ? '' : formattingDate(asset.WarrantyStartDateWages__c);
                temp01_i_warranty.GWLEN         = asset.WarrantyEndWages__c == null ? '' : formattingDate(asset.WarrantyEndWages__c);
                temp01_i_warranty.V_GWLEN       = asset.WarrantyEnd__c == null ? '' : formattingDate(asset.WarrantyEnd__c);
                // temp01_i_warranty.DELFLAG       = asset.WarrantyStartDateWages__c == null && asset.WarrantyEnd__c == null ? 'X' : '';
        
                IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_ORG temp01_i_org = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_ORG();
                // temp01_i_org.BUS_AREA           = asset.BusinessArea__c;
                temp01_i_org.PLANPLANT          = asset.PlanningPlant__c;
                temp01_i_org.PLANGROUP          = asset.PlannerGrp__c;
                temp01_i_org.ARBPL              = asset.MainWorkCtr__r.WCCode__c == null ? '' : asset.WorkCenter__r.WCCode__c;
                temp01_i_org.WERKS              = asset.PlanningPlant__c;
                // temp01_i_org.CATPROFILE         = asset.CatalogProfile__c;
        
                IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_USERINFO temp01_i_userInfo = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_USERINFO();
                temp01_i_userInfo.BNAME    = asset.OwnerId;
                temp01_i_userInfo.RNAME = String.valueOf(asset.Owner.ERP_Key__c);
    
            /**
             * t_dcument
             */
                // List<IF_ERP_Material_Classes.IF_CSPLUS_017_Req_T_DOCUMENT> temp01_t_document_list =
                //     new List<IF_ERP_Material_Classes.IF_CSPLUS_017_Req_T_DOCUMENT>();
        
                // IF_ERP_Material_Classes.IF_CSPLUS_017_Req_T_DOCUMENT temp01_t_document1 =
                // new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_T_DOCUMENT();
                // temp01_t_document1.DOKAR = 'CS2';
                // temp01_t_document1.DOKNR = '00-MV0177-000080-CS';
                // temp01_t_document1.DOKTL = '000';
                // temp01_t_document1.DOKVR = '00';
                // temp01_t_document_list.add(temp01_t_document1);
        
                // IF_ERP_Material_Classes.IF_CSPLUS_017_Req_T_DOCUMENT temp01_t_document2 =
                // new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_T_DOCUMENT();
                // temp01_t_document2.DOKAR = 'CS2';
                // temp01_t_document2.DOKNR = '00-MV0177-000081-CS';
                // temp01_t_document2.DOKTL = '000';
                // temp01_t_document2.DOKVR = '00';
                // temp01_t_document_list.add(temp01_t_document2);
        
            /**
             *  
             */
            wrapper_01.I_EQUNR           = asset.Name;
            wrapper_01.I_AG_PARNR        = asset.SoldTo__r.CustomerCode__c == null ? '' : asset.SoldTo__r.CustomerCode__c.leftPad(10, '0'); // Sold To
            wrapper_01.I_WE_PARNR        = asset.Account.CustomerCode__c == null ? '' : asset.Account.CustomerCode__c.leftPad(10, '0'); // Ship To
            wrapper_01.I_PARTNER_DEL_FLG = asset.SoldTo__r.CustomerCode__c == null && asset.Account.CustomerCode__c == null ? 'X' : '';
            wrapper_01.I_NOTE            = asset.InternNoteLong__c;
            // wrapper_01.I_CLASS_VALUE     = asset.NCNo__c;
            // wrapper_01.I_DESC            = asset.Description;
            wrapper_01.I_STATUS_FLG      = statusECUSMap.get(asset.Id) == null ? '' : statusECUSMap.get(asset.Id);
    
            wrapper_01.I_USERINFO        = temp01_i_userInfo;
            wrapper_01.I_ADDRESS         = temp01_i_address;
            wrapper_01.I_GENERAL         = temp01_i_general;
            wrapper_01.I_LOCATION        = temp01_i_location;
            wrapper_01.I_ORG             = temp01_i_org;
            wrapper_01.I_WARRANTY        = temp01_i_warranty;
        
            // wrapper_01.T_DOCUMENT        = temp01_t_document_list;
            
            IF_ERP_Material method = new IF_ERP_Material();
            IF_ERP_Material_Classes.IF_CSPLUS_017_Res response = method.IF_CSPLUS_017(wrapper_01);
            if (response.O_RETURN.TYPE == 'E') {
                asset.IsERPUpdate__c = true;
                asset.ERPUpdateError__c = response.O_RETURN.MESSAGE;
                asset.IsECUSCahnge__c = statusECUSMap.get(asset.Id) == 'X' ? true : false;
            } else if (response.O_RETURN.TYPE == '' && response.T_RETURN.size() > 0) {
                asset.IsERPUpdate__c = true;
                asset.ERPUpdateError__c = response.T_RETURN[0].MESSAGE;
                asset.IsECUSCahnge__c = statusECUSMap.get(asset.Id) == 'X' ? true : false;
            } else if (response.O_RETURN.TYPE == 'S') {
                asset.IsERPUpdate__c = false;
                asset.ERPUpdateError__c = '';
                asset.IsECUSCahnge__c = false;
            }


        } catch(Exception e) {
            asset.IsERPUpdate__c = true;
            asset.ERPUpdateError__c = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
        }

        TriggerHandler.bypass('AssetTriggerHandler');
    
        update asset;

        TriggerHandler.clearBypass('AssetTriggerHandler');
        // System.debug('asset ::: ' + asset);


    }

    public void finish(Database.BatchableContext bc) {
        System.debug('DN_ERPToAssetBatch success.');
    }

    // 날짜를 'yyyyMMdd' 형식으로 format
    public String formattingDate(Date dateValue) {
        Datetime datetimeValue = Datetime.newInstance(dateValue.year(), dateValue.month(), dateValue.day());

        return datetimeValue.format('yyyyMMdd');
    }
}