/**
* @Class : DN_ConsultationAttendanceBatch
* @Description : 상담배정 근태관리 Report용 DATA 적재 Batch
* @Author : Jiyeong, Park
* @Date : 2025-02-14
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2025-02-14 | Jiyeong, Park   | 최초작성
*
*/
public with sharing class DN_ConsultationAttendanceBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful{
    public List<SObject> start(Database.BatchableContext context){

        List<User> userList = [SELECT  Id, Name 
                               FROM User 
                               WHERE (Profile.Name ='DNS CS Receptionist' OR Profile.Name ='DNS CS Technical Consultant')];

        return userList;
    }

    public void execute(Database.BatchableContext context, List<SObject> scope){
        List<User> userList = (List<User>) scope;
        
        List<ConsultationAttendance__c> upsertList = new List<ConsultationAttendance__c>();
        List<ConsultationAttendance__c> getList = [SELECT Id, Consultant__c, AttendanceDate__c FROM ConsultationAttendance__c];
        Map<String, ConsultationAttendance__c> caMap = new Map<String, ConsultationAttendance__c>();
        
        Date startDate = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
        
        for(ConsultationAttendance__c ca : getList){
            caMap.put(ca.Consultant__c+':'+ca.AttendanceDate__c, ca); 
        }

        for(User u : userList){
            if(getList.size()==0){ //처음 배치: 1년치 데이터 insert
                for(Integer i = 0; i < 365; i++){
                    Date attendanceDate = startDate.addDays(i);
                    
                    ConsultationAttendance__c ca = new ConsultationAttendance__c();
                    ca.Consultant__c = u.Id;
                    ca.AttendanceDate__c = attendanceDate;
                    upsertList.add(ca);
                }
            } else {  //이후 배치
                Date lastAttendanceDate = getLatestAttendanceDate(u.Id, caMap);

                if(lastAttendanceDate == startDate) { //신규 유저
                    Date endDate = [SELECT AttendanceDate__c FROM ConsultationAttendance__c ORDER BY AttendanceDate__c Desc LIMIT 1].AttendanceDate__c;
                    endDate = endDate.addDays(1);
                    for(Date attendanceDate = lastAttendanceDate; attendanceDate <= endDate; attendanceDate = attendanceDate.addDays(1)) {
                        String key = u.Id + ':' + attendanceDate;
                        if(!caMap.containsKey(key)){
                            ConsultationAttendance__c ca = new ConsultationAttendance__c();
                            ca.Consultant__c = u.Id;
                            ca.AttendanceDate__c = attendanceDate;
                            upsertList.add(ca);
                        }
                    }
                } else { // 기존 유저
                    Date nextDay = lastAttendanceDate.addDays(1);
                    String key = u.Id + ':' + nextDay;
                    if(!caMap.containsKey(key)){
                        ConsultationAttendance__c ca = new ConsultationAttendance__c();
                        ca.Consultant__c = u.Id;
                        ca.AttendanceDate__c = nextDay;
                        upsertList.add(ca);
                    }
                }
            }

            // Governor Limits 때문에 나눠서 저장 
            if(upsertList.size() >= 200){
                upsert upsertList;
                upsertList.clear();
            }
        }
        
        // 나머지 저장
        if(!upsertList.isEmpty()){
            upsert upsertList;
        }
    }

    /**
     * @Description
     * 	- 가장 최신 근태일자 반환
    **/ 
    private Date getLatestAttendanceDate(Id userId, Map<String, ConsultationAttendance__c> caMap) {
        Date latestDate = Date.newInstance(System.today().year(), System.today().month(), System.today().day());
        
        for(String key : caMap.keySet()){
            ConsultationAttendance__c ca = caMap.get(key);
            if(ca.Consultant__c == userId){
                Date attendanceDate = ca.AttendanceDate__c;
                if(attendanceDate > latestDate){
                    latestDate = attendanceDate;
                }
            }
        }
        
        return latestDate;
    }


    public void finish(Database.BatchableContext context){
        System.debug('상담배정 근태관리 배치 END');
    }

    public void execute(SchedulableContext sc) {
        DN_ConsultationAttendanceBatch batch = new DN_ConsultationAttendanceBatch();
        Database.executeBatch(batch);
    }
}