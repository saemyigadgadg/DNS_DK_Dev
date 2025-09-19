/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 09-01-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   01-09-2025   Hanyeong Choi   Initial Version
**/
global with sharing class DN_DeviceManagerBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {
    
    /* Batch 시작 */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('DN_DeviceManagerBatch Start ------------');
        try {
            String query;
            query = 'SELECT Id, ' +
                            'SATNR__c, ' + // Product_Representative__c의 Product__c 룩업 필드에 연결된 값
                            'MAKTX__c, ' + // Product_Representative__c의 Product__c 룩업 필드에 연결된 값
                            'WERKS__c, ' + // Plant
                            'EMPNO_RD1__c, ' + // User의 CustomerCode__c 조회 -> Product_Representative__c User__c 맵핑
                            'EMPNM_RD1__c, ' +
                            'EPMAIL_RD1__c, ' + // Product_Representative__c MachineEmail__c 맵핑
                            'DEPNM_RD1__c, ' + // Product_Representative__c MachineTeam__c 맵핑
                            'DEPHD_RD1__c, ' + // User CustomerCode__c 조회 -> Product_Representative__c MachineUserLeader__c
                            'EMPNM_RD2__c, ' +
                            'EMPNO_RD2__c, ' + // User CustomerCode__c 조회 -> Product_Representative__c ControlUser__c 맵핑
                            'EPMAIL_RD2__c, ' + // Product_Representative__c ControlEmail__c 맵핑
                            'DEPNM_RD2__c, ' + // Product_Representative__c ControlTeam__c 맵핑
                            'DEPHD_RD2__c, ' + // User CustomerCode__c 조회 -> Product_Representative__c ControlUserLeader__c
                            'IsConverted__c, ' + // IsConverted 필드
                            'DEPNO_RD1__c, ' +
                            'DEPNO_RD2__c, ' +
                            'DPMAIL_RD1__c, ' +
                            'DPMAIL_RD2__c, ' +
                            'EMPNO_RD3__c, ' + // User의 CustomerCode__c 조회 -> Product_Representative__c User__c 맵핑
                            'EMPNM_RD3__c, ' +
                            'EPMAIL_RD3__c, ' + // Product_Representative__c MachineEmail__c 맵핑
                            'DEPNM_RD3__c, ' + // Product_Representative__c MachineTeam__c 맵핑
                            'DEPHD_RD3__c, ' + // User CustomerCode__c 조회 -> Product_Representative__c MachineUserLeader__c
                            'EMPNM_RD4__c, ' +
                            'EMPNO_RD4__c, ' + // User CustomerCode__c 조회 -> Product_Representative__c ControlUser__c 맵핑
                            'EPMAIL_RD4__c, ' + // Product_Representative__c ControlEmail__c 맵핑
                            'DEPNM_RD4__c, ' + // Product_Representative__c ControlTeam__c 맵핑
                            'DEPHD_RD4__c ' +
                            'FROM IF_DeviceManager__c ' +
                            'WHERE IsConverted__c = false ' +
                            'AND (WERKS__c = \'1840\' ' +
                            'OR WERKS__c = \'1842\') ' +
                            'ORDER BY WERKS__c ASC';
            System.debug('query ::: ' + query);
            System.debug('result ::: ' + Database.getQueryLocator(query));
            return Database.getQueryLocator(query);
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* Batch 실행 */
    global void execute(Database.BatchableContext bc, List<IF_DeviceManager__c> scope) {
        System.debug('DN_DeviceManagerBatch Excute ------------');
        try {
            List<IF_DeviceManager__c>           ifDmList        = scope;
            List<IF_DeviceManager__c>           realDmList      = new List<IF_DeviceManager__c>();
            Set<String>                         modelCodes      = new Set<String>();
            Map<String, List<Model__c>>         modelMap        = new Map<String, List<Model__c>>();
            Set<Id>                             modelIds        = new Set<Id>();
            Set<Id>                             userIds         = new Set<Id>();
            Map<Id, Product_Representative__c>  existingPRMap   = new Map<Id, Product_Representative__c>();
            List<Product_Representative__c>     prList          = new List<Product_Representative__c>();
            Map<String, Id>                     userMap         = new Map<String, Id>();
            Map<String, String>                 userEmailMap    = new Map<String, String>();
            List<IF_DeviceManager__c>           updateFlagList  = new List<IF_DeviceManager__c>();

            Map<String, List<IF_DeviceManager__c>> maktxToDmMap = new Map<String, List<IF_DeviceManager__c>>();

            for (IF_DeviceManager__c dm : ifDmList) {
                modelCodes.add(dm.SATNR__c);
                if (!maktxToDmMap.containsKey(dm.SATNR__c)) {
                    maktxToDmMap.put(dm.SATNR__c, new List<IF_DeviceManager__c>());
                }
                maktxToDmMap.get(dm.SATNR__c).add(dm);
            }

            for (String maktx : maktxToDmMap.keySet()) {
                List<IF_DeviceManager__c> dmList = maktxToDmMap.get(maktx);

                if (dmList.size() > 1) {
                    for (IF_DeviceManager__c dm : dmList) {
                        if (dm.WERKS__c == '1840') {
                            realDmList.add(dm);
                        }
                    }
                } else {
                    realDmList.addAll(dmList);
                }
            }

            List<Product2> product2List = [
                SELECT Id, Model__r.MaterialCode__c, Model__r.Name
                FROM Product2
                WHERE Model__r.MaterialCode__c IN :modelCodes
            ];
            List<Model__c> modelList = [
                SELECT Id, Name, MaterialCode__c
                FROM Model__c
                WHERE MaterialCode__c IN :modelCodes
            ];

            for (Model__c model : modelList) {
                if(!modelMap.containsKey(model.MaterialCode__c)) {
                    modelMap.put(model.MaterialCode__c, new List<Model__c>());
                }
                modelMap.get(model.MaterialCode__c).add(model);
                modelIds.add(model.Id);
            }

            List<Product_Representative__c> existingPRList = [
                SELECT Id, Model__c, ControlUser__c, User__c
                FROM Product_Representative__c
                WHERE Model__c IN :modelIds
            ];

            for (Product_Representative__c pr : existingPRList) {
                existingPRMap.put(pr.Model__c, pr);
            }

            // List<User> userList = [SELECT Id, Portal_EmployeeNumber__c FROM User WHERE Portal_EmployeeNumber__c IN :getCustomerCodes(realDmList)];
            List<User> userList = DN_WithoutSharingClass.getEmployeeEmails(getCustomerCodes(realDmList));
            if(!userList.isEmpty()) {
                for (User u : userList) {
                    userMap.put(u.Portal_EmployeeNumber__c, u.Id);
                    userEmailMap.put(u.Portal_EmployeeNumber__c, u.Email);
                }
            }

            for (IF_DeviceManager__c dm : realDmList) {
                if (modelMap.containsKey(dm.SATNR__c)) {
                    List<Model__c> prdList = modelMap.get(dm.SATNR__c);
            
                    for(Model__c md : prdList) {
                        Product_Representative__c pr = new Product_Representative__c();
                        if (existingPRMap.containsKey(md.Id)) {
                            pr = existingPRMap.get(md.Id);
                        } else {
                            pr = new Product_Representative__c();
                            pr.Model__c = md.Id;
                        }

                        if(dm.EMPNO_RD1__c != null) {
                            if(getUserId(dm.EMPNO_RD1__c, userMap) != null) {
                                pr.User__c              = getUserId(dm.EMPNO_RD1__c, userMap);
                                pr.MachineEmail__c      = getUserEmail(dm.EMPNO_RD1__c, userEmailMap);
                                pr.MachineTeam__c       = dm.DEPNM_RD1__c;
                                pr.MachineUserLeader__c = getUserId(dm.DEPNO_RD1__c, userMap);
                                pr.MachineLeaderEmail__c = getUserEmail(dm.DEPNO_RD1__c, userEmailMap);
                            } else {
                                pr.User__c              = getUserId(dm.EMPNO_RD3__c, userMap);
                                if(dm.EMPNO_RD3__c != null && getUserId(dm.EMPNO_RD3__c, userMap) != null) {
                                    pr.MachineEmail__c      = getUserEmail(dm.EMPNO_RD3__c, userEmailMap);
                                    pr.MachineTeam__c       = dm.DEPNM_RD3__c;
                                }
                            }
                        } else {
                            pr.User__c              = getUserId(dm.EMPNO_RD3__c, userMap);
                            if(dm.EMPNO_RD3__c != null && getUserId(dm.EMPNO_RD3__c, userMap) != null) {
                                pr.MachineEmail__c      = getUserEmail(dm.EMPNO_RD3__c, userEmailMap);
                                pr.MachineTeam__c       = dm.DEPNM_RD3__c;
                            }
                        }

                        if(dm.EMPNO_RD2__c != null) {
                            if(getUserId(dm.EMPNO_RD2__c, userMap) != null) {
                                pr.ControlUser__c       = getUserId(dm.EMPNO_RD2__c, userMap);
                                pr.ControlEmail__c      = getUserEmail(dm.EMPNO_RD2__c, userEmailMap);
                                pr.ControlTeam__c       = dm.DEPNM_RD2__c;
                                pr.ControlUserLeader__c = getUserId(dm.DEPNO_RD2__c, userMap);
                                pr.ControlLeaderEmail__c = getUserEmail(dm.DEPNO_RD2__c, userEmailMap);
                            } else {
                                pr.ControlUser__c       = getUserId(dm.EMPNO_RD4__c, userMap);
                                if(dm.EMPNO_RD4__c != null && getUserId(dm.EMPNO_RD4__c, userMap) != null) {
                                    pr.MachineEmail__c      = getUserEmail(dm.EMPNO_RD4__c, userEmailMap);
                                    pr.MachineTeam__c       = dm.DEPNM_RD4__c;
                                }
                            }
                        } else {
                            if(dm.EMPNO_RD4__c != null && getUserId(dm.EMPNO_RD4__c, userMap) != null) {
                                pr.MachineEmail__c      = getUserEmail(dm.EMPNO_RD4__c, userEmailMap);
                                pr.MachineTeam__c       = dm.DEPNM_RD4__c;
                            }
                        }

                        System.debug('pr ::: ' + pr);
                        if(pr.User__c != null || pr.ControlUser__c != null) {
                            prList.add(pr);
                            updateFlagList.add(dm);
                        }
                    }
            

                } else {
                    System.debug('No match Product : ' + dm);
                }
            }

            System.debug('prList ::: ' + prList);
            if (!prList.isEmpty()) {
                upsert prList;
                System.debug('Upserted Product_Representative__c records: ' + prList.size());
            }

            for (IF_DeviceManager__c dm : updateFlagList) {
                dm.IsConverted__c = true;
            }

            update ifDmList;

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* Batch 끝 */
    global void finish(Database.BatchableContext bc){
        System.debug('DN_DeviceManagerBatch Finish ------------');
    }

    /* Batch 스케쥴 */
    global void execute(SchedulableContext sc) {
        DN_DeviceManagerBatch batch = new DN_DeviceManagerBatch();
        Database.executeBatch(batch, 200);
    }

    /* employee number별 User 찾기 */
    private Id getUserId(String empNo, Map<String, Id> userMap) {
        if (String.isBlank(empNo)) return null;
        return userMap.get(empNo);
    }

    /* employee number별 Email 찾기  */
    private String getUserEmail(String empNo, Map<String, String> userEmailMap) {
        if (String.isBlank(empNo)) return null;
        return userEmailMap.get(empNo);
    }

    /* Customer Code 꺼내기 */
    private Set<String> getCustomerCodes(List<IF_DeviceManager__c> ifDmList) {
        Set<String> customerCodes = new Set<String>();
        for (IF_DeviceManager__c dm : ifDmList) {
            if (!String.isBlank(dm.EMPNO_RD1__c)) customerCodes.add(dm.EMPNO_RD1__c);
            if (!String.isBlank(dm.EMPNO_RD2__c)) customerCodes.add(dm.EMPNO_RD2__c);
            if (!String.isBlank(dm.DEPNO_RD1__c)) customerCodes.add(dm.DEPNO_RD1__c);
            if (!String.isBlank(dm.DEPNO_RD2__c)) customerCodes.add(dm.DEPNO_RD2__c);
            if (!String.isBlank(dm.EMPNO_RD3__c)) customerCodes.add(dm.EMPNO_RD3__c);
            if (!String.isBlank(dm.EMPNO_RD4__c)) customerCodes.add(dm.EMPNO_RD4__c);
        }
        return customerCodes;
    }
}