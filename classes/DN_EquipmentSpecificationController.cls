public with sharing class DN_EquipmentSpecificationController {
    
    // IF-CSPLUS029-출하지시서 조회
    @AuraEnabled
    public static IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res getShippingInstructionInfo(String machineName,String assetName){
        try {
            IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Req req = new IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Req();
            req.I_TYPBZ = machineName; // 기종
            req.I_SERNR = assetName; // 장비번호
            req.I_DEL_FLAG='';//삭제여부
            IF_ERP_ShipmentOrder instance = new IF_ERP_ShipmentOrder();
            IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res res = instance.IF_CSPLUS_029(req);
            System.debug(res + ' :::: res');
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}