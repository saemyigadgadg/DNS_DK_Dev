/**
* @Class : CS_Util
*
* @Author : Sangil, Park
* @Date : 2024. 12. 18.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-12-18 | Sangil, Park   | 최초작성
*
*/
public without sharing class CS_Util {
    public static Integer tempIDX = 0;
    public static List<ID> returnIDS = new List<ID>();
    /*
     * @ Method : getAssignmentUser
     * @ Description : 각 Process 별 담당자 할당을 위한 Get Method
     * @ Parameter 
     *    - aId : Assignment Rule ID
     *  
     */
    public static AssignmentWrapper getAssignmentUser(AssignmentRequest requestWrapper){
        AssignmentWrapper result = new AssignmentWrapper();
        
        List<AssignmentRule__c> aList = [SELECT ID, AssignmentType__c FROM AssignmentRule__c
                                         WHERE ID =: requestWrapper.aid];
        if(aList.size() == 0){
            result.status 		= 'Fail';
            result.errMessage 	= 'invalid ID';
        }else{
            // 상담사가 휴가 or 교육 일 경우 제외
            List<ConsultationAttendance__c> caList = [SELECT Id, Name, CurrencyIsoCode, Consultant__c, Consultant__r.Name, AttendanceDate__c, AttendanceType__c, OffStartTime__c, OffEndTime__c  
                                                      FROM ConsultationAttendance__c
                                                      WHERE AttendanceDate__c = TODAY];
            
            System.debug('caList : ' + Json.serialize(caList));
            SET<ID> userIDs = new SET<ID>();            
            for(ConsultationAttendance__c obj : caList){
                if(obj.AttendanceType__c != 'Waiting' &&  obj.OffStartTime__c != null){
                    Integer startHours = String.isEmpty(obj.OffStartTime__c.subString(0,2)) ? 0 : Integer.valueOf(obj.OffStartTime__c.subString(0,2));
                    Integer startMinute = String.isEmpty(obj.OffStartTime__c.subString(2,4)) ? 0 : Integer.valueOf(obj.OffStartTime__c.subString(2,4));
                    Integer endHours = String.isEmpty(obj.OffEndTime__c.subString(0,2)) ? 0 : Integer.valueOf(obj.OffEndTime__c.subString(0,2));
                    Integer endMinute = String.isEmpty(obj.OffEndTime__c.subString(2,4)) ? 0 : Integer.valueOf(obj.OffEndTime__c.subString(2,4));
                    
                    Datetime offStartDatetime = Datetime.newinstance(Date.today(), Time.newInstance(startHours, startMinute,0,0));
                    Datetime offEndDatetime = Datetime.newinstance(Date.today(), Time.newInstance(endHours, endMinute,0,0));
                    
                    if(offStartDatetime <= System.now() && offEndDatetime >= System.now()){
                        userIDs.add(obj.Consultant__c);
                    }  
                }
            }
            System.debug('userIDs : ' + Json.serialize(userIDs));
            AssignmentRule__c ar = aList[0];
            // 중복 방지로직 추가 - Sangil, Park 2025-06-10
            List<AssignmentMember__c> amList = [SELECT ID, User__c, CurrentAssignment__c FROM AssignmentMember__c 
                                                WHERE AssignmentRule__c =: ar.ID AND CurrentAssignment__c = True
                                                Order By LastmodifiedDate desc];
            
            System.debug('amList : ' + Json.serialize(amList));
            
            List<AssignmentMember__c> amList2;
            
            ID tempID;
            if(amList.size() > 1){
                tempID = amList[0].ID;
                for(AssignmentMember__c am : amList){
                    if(am.ID == tempID) continue;
                    else am.CurrentAssignment__c = false;
                }
                Database.SaveResult[] srList = Database.update(amList);
                Boolean UpdateFlag = True;
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        System.debug('성공 ::: ' + sr.getId());
                    } else {
                        System.debug('실패 ::: ' + sr.getErrors());
                        UpdateFlag = False;
                    }
                }
                if(UpdateFlag){
                    amList2 = [SELECT ID, User__c, CurrentAssignment__c FROM AssignmentMember__c 
                               WHERE AssignmentRule__c =: ar.ID
                               AND User__c Not IN: userIDs
                               Order By Index__c desc];
                }else{
                    result.errMessage = '배정룰 오류 관리자에게 문의해주세요.';
                    result.status	  = 'Fail';
                    return result;
                }
            }else{
                amList2 = [SELECT ID, User__c, CurrentAssignment__c FROM AssignmentMember__c 
                           WHERE AssignmentRule__c =: ar.ID
                           AND User__c Not IN: userIDs
                           Order By Index__c desc];
            }
            
            
            System.debug('amList2 : ' + Json.serialize(amList2));
            
            
            if(ar.AssignmentType__c == 'Owner'){                
                if(amList2.size() == 0){
                    result.status 		= 'Fail';
                    result.errMessage 	= 'Member is Empty';
                }else{
                    Integer idx = 0;
                    
                    for(Integer i = 0; i < amList2.size(); i++){
                        if(amList2[i].CurrentAssignment__c){
                            idx = i;
                            tempIDX = i+1;
                            break;
                        }
                    }
                    
                    List<ID> uIDs = new List<ID>();
                    for(AssignmentMember__c obj : amList2){
                        uIDs.add(obj.User__c);
                    }
                    
                    while(true){
                        System.debug('uIDs : ' + uIDs);
                        System.debug('requestWrapper.size : ' + requestWrapper.size);
                        System.debug('tempIDX : ' + tempIDX);
                        System.debug('returnIDS : ' + Json.serialize(returnIDS));
                        Boolean continueFlag = selfAsign(uIDs, requestWrapper.size, tempIDX);
                        if(!continueFlag) Break;
                    }
                    result.userList.addALL(returnIDS);
                    
                    amList2[idx].CurrentAssignment__c = False;
                    amList2[tempIDX].CurrentAssignment__c = True;

                    Database.SaveResult[] srList = Database.update(amList2);
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            System.debug('성공 ::: ' + sr.getId());
                        } else {
                            System.debug('실패 ::: ' + sr.getErrors());
                        }
                    }
                    // Update amList;
                }
            }else if(ar.AssignmentType__c == 'Team Member'){
                for(AssignmentMember__c obj : amList2){
                    result.userList.add(obj.User__c);
                }
            }
        }
        System.debug('result : ' + Json.serialize(result));
        return result;
    }
    
    public static Boolean selfAsign(List<ID> uIDs, Integer cnt, Integer idx){    
        if(uIDs.size() <= idx){
            tempIDX = 0;
            return True;
        }else if(returnIDS.size() == cnt){
            return False;
        }else{
            System.debug('idx : ' + idx);
            returnIDS.add(uIDs[idx]);
            if(returnIDS.size() == cnt) return False;
            else {
                tempIDX++;
                return True;
            }
        }
    }
    
    /*
     * @Variable
     *  - aID     : Assignment Rule ID
     *  - size    : Type 이 Owner 일 경우 발생한 Ticket의 갯수
     */
    public class AssignmentRequest{
        public ID aID			{get; set;}
        public Integer size		{get; set;}
    }
    
    /*
     * @Variable
     *  - status     : Success or Fail
     *  - errMessage : 실패 시 에러메세지
     *  - userList   : Rule Type이 Owner면 ListSize 1 , TeamMember 면 User List
     */
    public class AssignmentWrapper{
        public String status 		{get; set;}
        public String errMessage 	{get; set;}
        public List<ID> userList 	{get; set;}
        
        public AssignmentWrapper(){
            this.status 	= 'Success';
            this.userList	= new List<ID>();
        }
    }
}