/**
* @Class : DN_TicketBillingBtnController
*
* @Author : Hayeong, Min
* @Date : 2024. 11. 21.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-11-21 | Hayeong, Min   | 최초작성
*
*/
public without sharing class DN_TicketBillingBtnController {
    /*
     * @Description
     * 	- Ticket에 엮인 장비의 Saels Order의 isBilled 필드를 확인 후 
     *    N인 경우 Ticket의 isBilled 필드를 True로 변경하여 
     *    임의로 부품청구가 가능하도록 한다. 
     * 
     * @Parameter
     *  - recordId	    : ticket Id
     */
    @AuraEnabled
    public static CommonWrapper changeBillingStatus(String recordId){
        CommonWrapper cw = new CommonWrapper();
        try {
            Case ticket = [SELECT isBilled__c, AssetId, Asset.Order__r.IsBilled__c FROM Case WHERE Id = :recordId];
            if(String.isNotEmpty(ticket.Asset.Order__c)){//order 정보 있으면
                if(ticket.Asset.Order__r?.IsBilled__c == 'Y'){
                    cw.isSuccess = false;
                    cw.errMessage = '이미 매출정보가 입력된 ticket입니다.';
                }else{
                    ticket.isBilled__c = true;
                    update ticket;
                }
            }else{
                ticket.isBilled__c = true;
                update ticket;
            }
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }



     /*
     * @Description 
     *  - CommonWrapper
     * 
     * @Variable 
     *  - isSuccess 		: 성공여부
     *  - errMessage 	    : 에러메시지
     */ 
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess		                {get; set;}
        @AuraEnabled
        public String errMessage		                {get; set;}
    
    
        public CommonWrapper(){
            this.isSuccess 		    = true;
            this.errMessage 	    = '';
        }
    }
}