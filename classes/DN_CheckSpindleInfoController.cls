public with sharing class DN_CheckSpindleInfoController {

    /**
     * @Description
     * 	- 유상 스핀들 정보 실시간 I/F 조회
     * @author Hayeong Min 
    **/ 
    @AuraEnabled
    public static CommonWrapper getSpindleInfo(String recordId){
        CommonWrapper cw = new CommonWrapper();
        try {
            Asset equip = [SELECT Name, SoldTo__r.CustomerCode__c FROM Asset WHERE Id = :recordId];
            IF_ERP_Material_Classes.IF_CSPLUS_031_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_031_Req();
            
            req.I_VKORG = '1846'; //Sales Organization
            req.I_EQUNR = equip.Name;
            req.I_KUNNR = equip.SoldTo__r?.CustomerCode__c; // 고객번호
            System.debug('{"Input":' + JSON.serialize(req) + '}');

            IF_ERP_Material instance = new IF_ERP_Material();
            IF_ERP_Material_Classes.IF_CSPLUS_031_Res res = instance.IF_CSPLUS_031(req);
            IF_ERP_Material_Classes.IF_CSPLUS_031_O_RETURN o_return = res.O_RETURN;
            List<IF_ERP_Material_Classes.IF_CSPLUS_031_T_O_LIST> t_o_list = res.T_O_LIST;
            System.debug('o_return : '+o_return);
            System.debug('t_o_list : '+t_o_list);
                
            if(o_return.TYPE == 'S'){
                cw.returnValue = t_o_list;
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
     * 		- returnValue 			: 성공시 Return 값 
     */
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess 		{get; set;}
        @AuraEnabled
        public String errMessage		{get; set;} 
        @AuraEnabled
        public List<IF_ERP_Material_Classes.IF_CSPLUS_031_T_O_LIST> returnValue		{get; set;}

        public CommonWrapper(){
            this.isSuccess 		= true;
            this.errMessage 	= '';
            this.returnValue 	= new List<IF_ERP_Material_Classes.IF_CSPLUS_031_T_O_LIST>();
        }
    }
}