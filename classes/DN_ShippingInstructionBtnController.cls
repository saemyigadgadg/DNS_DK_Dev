/**
 * @description       : 
 * @author            : Hayeong Min
 * @last modified on  : 05-26-2025
 * @last modified by  : Hayeong Min
**/
public with sharing class DN_ShippingInstructionBtnController {
    
    /**
     * @Description
     * 	- Asset Id로 해당 장비/Case에 등록된 장비의 기종정보 조회
     * @author Hayeong Min 
     * @Parameter
     *  - recordId	    : Ticket/Asset Id
     *  - objName	    : Object API Name (Case or Asset)
    **/
    @AuraEnabled
    public static CommonWrapper getInitInfo(String recordId, String objName){
        CommonWrapper cw = new CommonWrapper();
        try {
            if(objName == 'Case'){
                Case ticket = [SELECT Id, AssetId, Asset.MachineName__c FROM Case WHERE Id = :recordId];
                cw.assetId = ticket.AssetId;
                cw.model = ticket.Asset.MachineName__c;
            }else{
                Asset equip = [SELECT Id, MachineName__c FROM Asset WHERE Id = :recordId];
                cw.assetId = equip.Id;
                cw.model = equip.MachineName__c;
            }

        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
     * @Description
     * 	- 해당 장비의 정보 조회
     * @author Hayeong Min 
     * @Parameter
     *  - assetId	    : Asset Id
    **/
    @AuraEnabled
    public static CommonWrapper getAssetInfo(String assetId){
        CommonWrapper cw = new CommonWrapper();
        try {
            Asset asset = [SELECT Id, MachineName__c FROM Asset WHERE Id = :assetId];
            cw.assetId = asset.Id;
            cw.model = asset.MachineName__c;
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
     * @Description
     * 	- 해당 장비로 등록된 출하지시서 실시간 I/F 조회
     * @author Hayeong Min 
     * @Parameter
     *  - equipId	    : Asset Id
     *  - equipModel	: Asset 기종
    **/
    @AuraEnabled
    public static CommonWrapper getShippingInstructionInfo(String equipId, String equipModel){
        CommonWrapper cw = new CommonWrapper();
        try {
            Asset equip = [SELECT Id, Name, MachineName__c FROM Asset WHERE Id = :equipId];
            
            IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Req req = new IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Req();
            req.I_TYPBZ = equipModel; //장비 기종
            // req.I_TYPBZ = 'MX1600ST 735'; //장비 기종
            req.I_SERNR = equip.Name; //장비번호
            // req.I_SERNR = 'MM0032-000050'; //장비번호
            req.I_DEL_FLAG = ''; //삭제 레코드 조회 여부

            System.debug('{"Input":' + JSON.serialize(req) + '}');

            IF_ERP_ShipmentOrder instance = new IF_ERP_ShipmentOrder();
            IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res res = instance.IF_CSPLUS_029(req);
            IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_O_RETURN o_return = res.O_RETURN;
            IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_O_HEADER o_header = res.O_HEADER;
            List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_Classification> t_o_classification = res.T_O_Classification;
            List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_MANNUAL> t_o_mannual = res.T_O_MANNUAL;
            List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_REMARK> t_o_remark = res.T_O_REMARK;
            List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_MATERIAL> t_o_material = res.T_O_MATERIAL;
            List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_SHIPPING_PART_LIST> t_o_shipping_part_list = res.T_O_SHIPPING_PART_LIST;
            List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_RSP_LIST> t_o_rsp_list = res.T_O_RSP_LIST;

            
            if(o_return.TYPE == 'S'){
                cw.assetId = equip.Id;
                cw.model = equipModel;
                cw.resultStr = res.toString();
                cw.o_header = o_header;
                cw.t_o_classification = t_o_classification;
                cw.t_o_mannual = t_o_mannual;
                cw.t_o_material = t_o_material;
                cw.t_o_shipping_part_list = t_o_shipping_part_list;
                cw.t_o_rsp_list = t_o_rsp_list;
                cw.t_o_remark = t_o_remark;

                if(t_o_remark.size()>0){
                    String remark = '';
                    for(IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_REMARK re : t_o_remark){
                        remark += re.ZTEXT;
                        remark += '<br/>';
                    }
                    cw.remarkStr = remark;
                }

            }else{
                cw.isSuccess = false;
                cw.errMessage = o_return.MESSAGE;
                System.debug('o_return.MESSAGE : '+o_return.MESSAGE);
            }

        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /*
     * @Description
     * 		- 공용Wrapper
     * 
     * @Variable
     *  	- isSuccess 			: 성공여부
     *  	- errMessage 			: 실패시 에러메세지
     */
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess 		{get; set;}
        @AuraEnabled
        public String errMessage		{get; set;} 
        @AuraEnabled
        public String assetId		{get; set;} 
        @AuraEnabled
        public String model		{get; set;} 
        @AuraEnabled
        public String resultStr		{get; set;} 
        @AuraEnabled
        public IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_O_RETURN o_return                                 {get; set;}
        @AuraEnabled
        public IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_O_HEADER o_header                                 {get; set;}
        @AuraEnabled
        public List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_Classification> t_o_classification		    {get; set;}
        @AuraEnabled
        public List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_MANNUAL> t_o_mannual		                    {get; set;}
        @AuraEnabled
        public List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_REMARK> t_o_remark		                            {get; set;}
        @AuraEnabled
        public String remarkStr		                                                                            {get; set;}
        @AuraEnabled
        public List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_MATERIAL> t_o_material		                {get; set;}
        @AuraEnabled
        public List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_SHIPPING_PART_LIST> t_o_shipping_part_list   {get; set;}
        @AuraEnabled
        public List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_RSP_LIST> t_o_rsp_list		                {get; set;}

        public CommonWrapper(){
            this.isSuccess 		        = true;
            this.errMessage 	        = '';
            this.assetId 	            = '';
            this.model 	                = '';
            this.resultStr 	            = '';
            this.o_return 	            = new IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_O_RETURN();
            this.o_header 	            = new IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_O_HEADER();
            this.t_o_classification 	= new List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_Classification>();
            this.t_o_mannual 	        = new List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_MANNUAL>();
            this.t_o_remark 	        = new List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_REMARK>();
            this.remarkStr 	            = '';
            this.t_o_material 	        = new List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_MATERIAL>();
            this.t_o_shipping_part_list = new List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_SHIPPING_PART_LIST>();
            this.t_o_rsp_list 	        = new List<IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res_T_O_RSP_LIST>();
        }
    }
    
}