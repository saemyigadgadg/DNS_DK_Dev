/**
 * @author            : iltae.seo
 * @last modified on  : 2025-04-18
 * @last modified by  : iltae.seo
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-12-26   iltae.seo     Initial Version
**/
public with sharing class DN_DealerLocationController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }
    
    /**
     * @Description
     * 	- 현재 유저 기준으로 재고위치 목록 반환
    **/ 
    @AuraEnabled
    public static Map<String,List<sObject>> getInit(){
        try {
            Map<String,List<sObject>> returnMap = new Map<String,List<sObject>>();
            User user =[select Id, Name, Account.Id,Account.Name from User where Id=:UserInfo.getUserId()];
            List<DealerLocation__c> locationList =[ select 
                Id, Name, Description__c, Loc6__c, 
                Loc5__c, Loc4__c, Loc3__c, Loc2__c, 
                Loc1__c, Dealer__c, Division__c, 
                DistributionChannel__c, 
                SalesOrganization__c, FM_Loc__c 
                from DealerLocation__c 
                where Dealer__c =:currentUser.getAgencyId() 
                AND FM_Loc__c !=null
                ORDER BY FM_Loc__c ASC 
            ];
            List<DealerLocation__c> totalRecord = [
                SELECT Id FROM DealerLocation__c 
                WHERE Dealer__c =:currentUser.getAgencyId() 
                limit 30000
            ];
            returnMap.put('total',totalRecord);
            returnMap.put('locationList',locationList);
            returnMap.put('user',new List<User>{user});
            return returnMap;
        } catch (Exception e) {
            throw new DN_DealerLocationControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 재고위치 설정/변경
    **/ 
    @AuraEnabled
    public static void  getSettingCheck(String fmLoc, String part){
        try {
            System.debug(fmLoc + ' > ==fmLoc');
            System.debug(part + ' > ==fmLoc');
            List<Product2> prod = [SELECT Id, Name, ProductCode FROM Product2 where Id =:part];
            List<DealerLocation__c> locationList =[select Id, Name, Description__c, Loc6__c, Loc5__c, Loc4__c, Loc3__c, Loc2__c, Loc1__c, Dealer__c, Division__c, DistributionChannel__c, SalesOrganization__c, FM_Loc__c 
                                                        from DealerLocation__c 
                                                        where Dealer__c =:currentUser.getAgencyId() AND FM_Loc__c =:fmLoc ];
            
            System.debug(locationList + ' < ===locationList');
            if(locationList.size() > 0) {
                DealerStock__c stock = new DealerStock__c();
                stock.Part__c = part;
                stock.Dealer__c = currentUser.getAgencyId();
                stock.Division__c = currentUser.getDivision();
                stock.DistributionChannel__c = currentUser.getDistributionChannel();
                stock.SalesOrganization__c = currentUser.getSalesOranization();
                stock.DealerLocation__c = locationList[0].Id;
                stock.ExternalKey__c = currentUser.getSalesOranization()+'-'+currentUser.getDistributionChannel()+'-'+currentUser.getDivision()+'-'+currentUser.getAgencyCustomerCode()+'-'+prod[0].ProductCode;
                upsert stock ExternalKey__c;
            } else {
                throw new DN_DealerLocationControllerException('저장위치가 존재하지 않습니다.');    
            }
        } catch (Exception e) {
            throw new DN_DealerLocationControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 재고위치 중복체크
    **/ 
    @AuraEnabled
    public static List<DealerLocation__c> insertLocationCheck(List<DealerLocation__c> locList){
        System.debug(locList  + ' ::: locList');
        try {
            set<String> duplicateCheckList = new set<String>();
            
            if(locList.size() >0) {
                for(DealerLocation__c del : locList) {
                    System.debug(del + ' :: del');
                    String fmLoc = '';
                    if(del.Loc1__c !='') {fmLoc += del.Loc1__c.trim();} 
                    if(del.Loc2__c !='') {fmLoc += '-'+del.Loc2__c.trim();}
                    if(del.Loc3__c !='') {fmLoc += '-'+del.Loc3__c.trim();}
                    if(del.Loc4__c !='') {fmLoc += '-'+del.Loc4__c.trim();}
                    if(del.Loc5__c !='') {fmLoc += '-'+del.Loc5__c.trim();}
                    if(del.Loc6__c !='') {fmLoc += '-'+del.Loc6__c.trim();}
                    duplicateCheckList.add(fmLoc);
                }
                List<DealerLocation__c> dupLocationList =[select Id, Name, Description__c, Loc6__c, Loc5__c, Loc4__c, Loc3__c, Loc2__c, Loc1__c, Dealer__c, Division__c, DistributionChannel__c, SalesOrganization__c, FM_Loc__c 
                                                        from DealerLocation__c 
                                                        where Dealer__c =:currentUser.getAgencyId() AND FM_Loc__c IN: duplicateCheckList];
                System.debug(dupLocationList+ ' ::: dupLocationList');
                if(dupLocationList.size() >0) {
                    throw new DN_DealerLocationControllerException('저장위치'+dupLocationList[0].FM_Loc__c+'가 중복됩니다');    
                } 
                // 생성 목록 중에 중복체크
                if(duplicateCheckList.size()!=locList.size()) {
                    throw new DN_DealerLocationControllerException('저장위치 목록 중에 중복값이 있습니다.');    
                }
            } else {
                throw new DN_DealerLocationControllerException('생성할 저장위치 목록이 없습니다.');
            }
            System.debug(duplicateCheckList + ' ::: duplicateCheckList');
            System.debug(duplicateCheckList.size() + ' :: duplicateCheckList');
            System.debug(locList.size() + ' :: locList');
            return locList;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' message');
            System.debug(e.getStackTraceString() + ' getStackTraceString');
            throw new DN_DealerLocationControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 재고위치 생성
    **/ 
    @AuraEnabled
    public static void insertLocation(List<DealerLocation__c> locList){
        try {
            List<String> duplicateCheckList = new List<String>();
            if(locList.size() >0) {
                for(DealerLocation__c del : locList) {
                    String fmLoc = '';
                    if(del.Loc1__c !='') {fmLoc += del.Loc1__c;} 
                    if(del.Loc2__c !='') {fmLoc += '-'+del.Loc2__c;}
                    if(del.Loc3__c !='') {fmLoc += '-'+del.Loc3__c;}
                    if(del.Loc4__c !='') {fmLoc += '-'+del.Loc4__c;}
                    if(del.Loc5__c !='') {fmLoc += '-'+del.Loc5__c;}
                    if(del.Loc6__c !='') {fmLoc += '-'+del.Loc6__c;}
                    duplicateCheckList.add(fmLoc);
                }
                List<DealerLocation__c> dupLocationList =[select Id, Name, Description__c, Loc6__c, Loc5__c, Loc4__c, Loc3__c, Loc2__c, Loc1__c, Dealer__c, Division__c, DistributionChannel__c, SalesOrganization__c, FM_Loc__c 
                                                        from DealerLocation__c 
                                                        where Dealer__c =:currentUser.getAgencyId() AND FM_Loc__c IN: duplicateCheckList];
                if(dupLocationList.size() >0) {
                    throw new DN_DealerLocationControllerException('저장위치'+dupLocationList[0].FM_Loc__c+'가 중복됩니다');    
                } else {
                    insert locList;
                }
            } else {
                throw new DN_DealerLocationControllerException('생성할 저장위치 목록이 없습니다.');
            }
            
        } catch (Exception e) {
            throw new DN_DealerLocationControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 재고 위치 삭제
    **/ 
    @AuraEnabled
    public static void deleteLocation(String recordId){
        try {
            List<DealerLocation__c> locationList = [select Id from DealerLocation__c where Id =:recordId FOR UPDATE];
            delete locationList;
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DN_DealerLocationControllerException extends Exception {}

}