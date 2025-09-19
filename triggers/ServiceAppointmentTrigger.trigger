/**
* @Class : ServiceAppointmentTrigger
*
* @Author : Hayeong, Min
* @Date : 2024. 06. 14.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-06-14 | Hayeong, Min   | 최초작성
*
*/
trigger ServiceAppointmentTrigger on ServiceAppointment (before insert, after insert, before update, after update) {
    TriggerManager.prepare()
    .bind(new ServiceAppointmentTriggerHandler())
    .execute(); 
}