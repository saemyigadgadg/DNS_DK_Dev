/**
 * @description       : 비회원 AS Ticket 접수를 위한 Class
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-04-17
 * @last modified by  : suheon.ha@sobetec.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-18-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
public without sharing class DN_ASRegisterController {
    private static final Id contactPersonRT = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSCustomer').getRecordTypeId();

    private String accountId;
    private String accountName;
    private String accountPostalCode;
    private String accountAddress;
    private String accountDetailAddress;
    private String symptom;
    private String servicePart;
    private String request;
    private String progressWay;
    private String reservationTime;
    private Id caseId;
    private List<String> selectedFileIds;
    private String contactPhoneNumber;
    private String repairRequestDate;
    private String requestTimeType;
    private String requestTime;
    private String serialNo;
    private String hogi;
    private String equipmentNo;
    private String contactId;
    private String selectedServiceCenter;
    private List<String> namePlateImagefiles;
    private List<String> referenceImagefiles;

    public DN_ASRegisterController() {
        selectedFileIds = new List<String>();
    }

    /**
    @ description : 업무시간 조회 I/F
    **/
    @AuraEnabled
    public static Map<String, Object> checkWorkingHours() {
        Map<String, Object> result = new Map<String, Object>();
        try {
            IF_CTI_DNIS_G002 dnisTest = new IF_CTI_DNIS_G002();
            IF_CTI_DNIS_G002.RequestDto requestApi = new IF_CTI_DNIS_G002.RequestDto();
            requestApi.dnisId = '16004522';
            String responseStr = dnisTest.callOut(requestApi);
            
            // 디버그 로깅
            System.debug('API Raw Response: ' + responseStr);
            
            // JSON 응답 파싱
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
            System.debug('Parsed Response Map: ' + responseMap);
            
            // data 객체 가져오기
            Map<String, Object> dataMap = (Map<String, Object>)responseMap.get('data');
            System.debug('Data Map: ' + dataMap);
            
            // isWork 값 추출
            Boolean isWork = dataMap.get('isWork') != null ? (Boolean)dataMap.get('isWork') : false;
            // Boolean isWork = (Boolean)dataMap.get('isWork');
            System.debug('Is Work: ' + isWork);
            
            // 결과 맵 구성
            result.put('isWork', isWork);
            result.put('success', true);
            result.put('responseData', responseMap);
            result.put('code', dataMap.get('code'));
            result.put('name', dataMap.get('name'));
            result.put('scheduleType', dataMap.get('scheduleType'));
            result.put('scheduleName', dataMap.get('scheduleName'));
            
            return result;
        } catch(Exception e) {
            System.debug('Error in checkWorkingHours: ' + e.getMessage());
            System.debug('Error Stack: ' + e.getStackTraceString());
            result.put('success', false);
            result.put('error', e.getMessage());
            return result;
        }
    }

    /**
    @ description : 근무시간 체크 후 야간 A/S 접수시 담당 서비스 센터 목록 출력
    **/
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getServiceCenterList() {
        List<Map<String, String>> serviceCenters = new List<Map<String, String>>();
        try {
            // 근무시간 체크
            Map<String, Object> workingHoursResult = checkWorkingHours();
            
            // workingHoursResult가 null이거나 success가 false인 경우 기본값으로 처리
            Boolean isWork = workingHoursResult != null && workingHoursResult.containsKey('isWork') ? 
                           (Boolean)workingHoursResult.get('isWork') : true;
            // 야간근무(isWork = false)일 때만 서비스센터 목록 반환
            if (!isWork) {
                // Map<String, String> regionLabels = new Map<String, String>{
                //     '디엠에스' => '경기/인천 : ',
                //     '대구경북서비스' => '대구/경북 : ',
                //     '우리종합기계' => '전라 : ',
                //     '디씨에스' => '충청 : ',
                //     '한영종합기계' => '부산/경남 : '
                // };
            
                for(ServiceTerritory center : [
                    SELECT Id, Name, OperatingHours.Name, Rigion__c
                    FROM ServiceTerritory 
                    WHERE InstCheck__c = true
                    ORDER BY Name ASC
                ]) {
                    // String prefix = regionLabels.containsKey(center.Name) ? regionLabels.get(center.Name) : '';
                    // String label = center.Name;
            
                    serviceCenters.add(new Map<String, String>{
                        'label' => center.Rigion__c + ' : ' + center.Name,
                        'value' => center.Id
                    });
                }
            }
            return serviceCenters;
        } catch(Exception e) {
            System.debug('Error getting service centers: ' + e.getMessage());
            throw new AuraHandledException('서비스센터 목록을 가져오는데 실패했습니다: ' + e.getMessage());
        }
    }

    /**
    @ description : 장비 조회 method
    **/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> searchAssets(String accountId, String searchKey) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            if (String.isNotBlank(accountId)) {
                String query = 'SELECT Id, Name, MachineName__c FROM Asset WHERE AccountId = :accountId';
                if (String.isNotBlank(searchKey)) {
                    searchKey = '%' + searchKey + '%';
                    query += ' AND (Name = :searchKey OR SerialNumber = :searchKey)';
                }
                query += ' LIMIT 100';
                
                List<Asset> assets = Database.query(query);
                if (!assets.isEmpty()) {
                    List<Map<String, String>> assetOptions = new List<Map<String, String>>();
                    for (Asset asset : assets) {
                        assetOptions.add(new Map<String, String>{
                            'label' => asset.Name + (String.isNotBlank(asset.MachineName__c) ? ' (' + asset.MachineName__c + ')' : ''),
                            'value' => asset.Id
                        });
                    }
                    result.put('options', assetOptions);
                }
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('장비 검색 중 오류가 발생했습니다: ' + e.getMessage());
        }
    }

    /**
    @ description : 장비 Object 내 InstEngineer__C 필드 조회
    **/
    @AuraEnabled(cacheable=true)
    public static Boolean getExistEngineer(String selectedAssetId) {
        Boolean existEngineer = null;
        try {
            System.debug('selectedAssetId: ' + selectedAssetId);
            List<Asset> assetList = [SELECT Id, InstEngineer__c FROM Asset WHERE Id =: selectedAssetId];
            if (assetList.isEmpty()) {
                existEngineer = false;
            } else {
                Asset obj = assetList[0];
                existEngineer = String.isNotBlank(obj.InstEngineer__c);
            }
            } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return existEngineer;
    }

    /**
    @ description : 고객의 연락처 기준으로 조회한 고객의 보유 장비 목록 조회
    **/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCustomerAssetList(String searchText, String searchType) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            searchText = searchText.replace('-', '');

            // 연락처로 먼저 검색
            List<Contact> contacts = [
                SELECT Id, AccountId, Account.Name, Account.Phone, 
                       Account.ShippingPostalCode, Account.ShippingState,
                       Account.ShippingCity, Account.ShippingStreet,
                       Account.ShippingAddress, Name
                FROM Contact 
                WHERE Phone = :searchText OR MobilePhone = :searchText
                LIMIT 1
            ];
            
            if (!contacts.isEmpty()) {
                Contact contact = contacts[0];
                if (contact.AccountId != null) {
                    result.put('contactId', contact.Id);
                    result.put('accountId', contact.AccountId);
                    result.put('accountName', contact.Account.Name);
                    result.put('accountPhone', contact.Account.Phone);
                    result.put('postalCode', contact.Account.ShippingPostalCode);

                    result.put('street', contact.Account.ShippingStreet); //상세주소
                    result.put('city', contact.Account.ShippingCity); //배송지 시/군/구
                    result.put('state', contact.Account.ShippingState); //배송지 시/도
                    // // 주소 정보 설정
                    // String street = '';
                    // if (String.isNotBlank(contact.Account.ShippingState)) {
                    //     street += contact.Account.ShippingState + ' ';
                    // }
                    // if (String.isNotBlank(contact.Account.ShippingCity)) {
                    //     street += contact.Account.ShippingCity + ' ';
                    // }
                    // if (String.isNotBlank(contact.Account.ShippingStreet)) {
                    //     street += contact.Account.ShippingStreet;
                    // }
                    // result.put('street', street.trim());
                }
            } else {
                result.put('accountId', '');
                result.put('contactId', '');
                result.put('accountName', '');
                result.put('accountPhone', searchText);
                result.put('postalCode', '');
                result.put('street', '');
                result.put('assetMessage', '고객 정보가 없습니다.');
            }
            return result;
        } catch (Exception e) {
            System.debug('Error in getCustomerAssetList: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('고객 정보를 가져오는데 실패했습니다: ' + e.getMessage());
        }
    }

    /**
    @ description : 고객의 연락처 기준으로 조회한 후 없으면, 새로운 Contact 생성
    **/
    @AuraEnabled
    public static Map<String, Object> createNewCustomer(String name, String phone) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            if (String.isBlank(phone)) {
                throw new AuraHandledException('전화번호가 입력되지 않았습니다.');
            }
            phone = phone.replace('-', '');
            //기존 고객 조회 후 있으면 그대로 사용, 없으면 새로운 연락처 생성
            List<Contact> extContact = [SELECT Id, Name, AccountId, Account.Name, Account.Phone, 
                                                Account.ShippingPostalCode, Account.ShippingState,
                                                Account.ShippingCity, Account.ShippingStreet,
                                                Account.ShippingAddress
                                        FROM Contact 
                                        WHERE Phone = :phone OR MobilePhone = :phone];
            if(extContact.size()>0){
                result.put('contactId', extContact[0].Id);
                result.put('accountId', extContact[0].AccountId);
                result.put('accountName', extContact[0].Account.Name);
                result.put('accountPhone', extContact[0].Account.Phone);
                result.put('postalCode', extContact[0].Account.ShippingPostalCode);
                result.put('street', extContact[0].Account.ShippingStreet);
            } else {
                // 새로운 연락처 생성
                Contact newContact = new Contact(
                    LastName = String.isBlank(name) ? phone.substring(0, Math.min(phone.length(), 3)) : name,
                    Phone = phone
                );
                insert newContact;

                result.put('contactId', newContact.Id);
                result.put('accountId', null);
                result.put('accountName', '');
                result.put('accountPhone', phone);
                result.put('postalCode', '');
                result.put('street', '');
                result.put('assetMessage', '고객 정보가 없습니다.');
            }
            
            return result;
        } catch (Exception e) {
            System.debug('Error in createNewCustomer: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('새 고객 정보 생성에 실패했습니다: ' + e.getMessage());
        }
    }

    public void saveNameSymptomFile() {
        try {
            // Case 생성
            Case caseRecord = new Case();
            caseRecord.ApplicationDateTime__c = System.now();
            caseRecord.AccountId = accountId;
            caseRecord.AssetId = equipmentNo;
            caseRecord.Requester__c = contactId;
            caseRecord.ReceptionPath__c = 'Alarm Talk';
            caseRecord.TicketType__c = 'Technical inquiry';
            caseRecord.InternalTicketType__c = progressWay == 'technicalCouncel' ? 'Technical consultation' : 'Failure receipt';
            caseRecord.ReceptionDetails__c = '증상 : ' + symptom + '\n' +
                                           (String.isNotBlank(request) ? '요청 : ' + request + '\n' : '') + 
                                           (String.isNotBlank(servicePart) ? '서비스 부품 : ' + servicePart + '\n' : '') +
                                           '주소 : (' + accountPostalCode + ') ' + 
                                           accountAddress + ' ' + 
                                           accountDetailAddress;
            
            if(String.isNotBlank(repairRequestDate) && String.isNotBlank(requestTime)) {
                String dateTimeStr = repairRequestDate + ' ' + requestTime + ':00';
                try {
                    DateTime dt = DateTime.valueOf(dateTimeStr);
                    caseRecord.RepairRequestDateTime__c = dt;
                } catch(Exception e) {
                    System.debug('출동요청일시 파싱 오류: ' + e.getMessage());
                }
            }

            insert caseRecord;
            caseId = caseRecord.Id;

            // AlarmTalk 생성
            AlarmTalk__c alarmTalk = new AlarmTalk__c();
            alarmTalk.Name = '[알림톡] 고객 문의';
            alarmTalk.Ticket__c = caseId;
            alarmTalk.Symptom__c = symptom;
            alarmTalk.RequestedTerm__c = request;
            alarmTalk.ServicePart__c = servicePart;
            alarmTalk.AccountName__c = accountName;
            alarmTalk.Phone__c = contactPhoneNumber;
            alarmTalk.PostalCode__c = accountPostalCode;
            alarmTalk.Address__c = accountAddress;
            alarmTalk.DetailAddress__c = accountDetailAddress;
            alarmTalk.TheWayOfProceeding__c = progressWay == 'technicalCouncel' ? 'Technical inquiry' : 'Dispatch repair';
            alarmTalk.EquipmentNumber__c = serialNo;
            alarmTalk.W_C__c = selectedServiceCenter;
            alarmTalk.Equipment__c = equipmentNo;
            alarmTalk.Account__c = accountId;
            alarmTalk.Contact__c = contactId;
            
            if(String.isNotBlank(repairRequestDate) && String.isNotBlank(requestTime)) {
                String dateTimeStr = repairRequestDate + ' ' + requestTime + ':00';
                try {
                    DateTime dt = DateTime.valueOf(dateTimeStr);
                    caseRecord.RepairRequestDateTime__c = dt;
                    alarmTalk.RepairRequestDateTime__c = dt;
                } catch(Exception e) {
                    System.debug('출동요청일시 파싱 오류: ' + e.getMessage());
                }
            }
            
            insert alarmTalk;

            // 파일 첨부
            if(selectedFileIds != null && !selectedFileIds.isEmpty()) {
                List<ContentDocumentLink> links = new List<ContentDocumentLink>();
                
                // ContentVersion에서 ContentDocumentId 조회
                List<ContentVersion> contentVersions = [
                    SELECT Id, ContentDocumentId 
                    FROM ContentVersion 
                    WHERE Id IN :selectedFileIds
                ];
                
                for (ContentVersion cv : contentVersions) {
                    if (cv.ContentDocumentId != null) {
                        ContentDocumentLink alarmLink = new ContentDocumentLink();
                        alarmLink.ContentDocumentId = cv.ContentDocumentId;
                        alarmLink.LinkedEntityId = alarmTalk.Id;
                        alarmLink.ShareType = 'V';
                        alarmLink.Visibility = 'AllUsers';
                        links.add(alarmLink);

                        ContentDocumentLink caseLink = new ContentDocumentLink();
                        caseLink.ContentDocumentId = cv.ContentDocumentId;
                        caseLink.LinkedEntityId = caseId;
                        caseLink.ShareType = 'V';
                        caseLink.Visibility = 'AllUsers';
                        links.add(caseLink);
                    }
                }
                
                if (!links.isEmpty()) {
                    try {
                        insert links;
                    } catch(Exception e) {
                        System.debug('Error linking files: ' + e.getMessage());
                    }
                }
            }
        } catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Getter/Setter 메서드들
    public void setReservationTime(String timeValue) { 
        this.reservationTime = timeValue; 
    }
    public String getReservationTime() { 
        return this.reservationTime; 
    }
    
    public void setCaseId(Id caseIdValue) { 
        this.caseId = caseIdValue; 
    }
    public Id getCaseId() { 
        return this.caseId; 
    }
    
    public void setSelectedFileIds(List<String> fileIds) { 
        this.selectedFileIds = fileIds; 
    }
    public List<String> getSelectedFileIds() { 
        return this.selectedFileIds; 
    }
    
    public String getRepairRequestDate() { 
        return repairRequestDate; 
    }
    public void setRepairRequestDate(String dateValue) { 
        this.repairRequestDate = dateValue; 
    }
    
    public String getRequestTimeType() { 
        return requestTimeType; 
    }
    public void setRequestTimeType(String typeValue) { 
        this.requestTimeType = typeValue; 
    }
    
    public String getRequestTime() { 
        return requestTime; 
    }
    public void setRequestTime(String timeValue) { 
        this.requestTime = timeValue; 
    }
    
    public String getSerialNo() { 
        return serialNo; 
    }
    public void setSerialNo(String serialValue) { 
        this.serialNo = serialValue; 
    }
    
    public String getHogi() { return hogi; }
    public void setHogi(String no) { this.hogi = no; }
    
    public String getEquipmentNo() { return equipmentNo; }
    public void setEquipmentNo(String no) { this.equipmentNo = no; }
    
    public String getContactId() { return contactId; }
    public void setContactId(String id) { this.contactId = id; }
    
    public String getSelectedServiceCenter() { return selectedServiceCenter; }
    public void setSelectedServiceCenter(String center) { this.selectedServiceCenter = center; }
    
    public List<String> getNamePlateImagefiles() { return namePlateImagefiles; }
    public void setNamePlateImagefiles(List<String> files) { this.namePlateImagefiles = files; }
    
    public List<String> getReferenceImagefiles() { return referenceImagefiles; }
    public void setReferenceImagefiles(List<String> files) { this.referenceImagefiles = files; }

    /**
    @ description : 장비 번호 및 시리얼 번호로 장비 정보 조회 method
    **/
    @AuraEnabled
    public static Map<String, Object> setEquipInfo(String equipmentNo, String serialNo, String accountId) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // 장비 ID가 있는 경우
            if (String.isNotBlank(equipmentNo)) {
                Asset selectedAsset = [
                    SELECT Id, Name, SerialNumber, AccountId, Account.Name, Account.Phone,
                           Account.BillingPostalCode, Account.BillingStreet, Account.BillingCity,
                           Account.BillingState
                    FROM Asset 
                    WHERE Id = :equipmentNo 
                    LIMIT 1
                ];
                
                result.put('success', true);
                result.put('found', true);
                result.put('accountId', selectedAsset.AccountId);
                result.put('accountName', selectedAsset.Account.Name);
                result.put('accountPhone', selectedAsset.Account.Phone);
                result.put('postalCode', selectedAsset.Account.BillingPostalCode);
                result.put('street', selectedAsset.Account.BillingStreet);
                result.put('city', selectedAsset.Account.BillingCity);
                result.put('state', selectedAsset.Account.BillingState);
                result.put('serialNo', selectedAsset.SerialNumber);
                result.put('equipmentId', selectedAsset.Id);
            }
            // 제조번호만 있는 경우
            else if (String.isNotBlank(serialNo)) {
                List<Asset> assets = [
                    SELECT Id, Name, SerialNumber, AccountId, Account.Name, Account.Phone,
                           Account.BillingPostalCode, Account.BillingStreet, Account.BillingCity,
                           Account.BillingState
                    FROM Asset 
                    WHERE SerialNumber = :serialNo OR Name = :serialNo
                    LIMIT 1
                ];
                
                if (!assets.isEmpty()) {
                    Asset selectedAsset = assets[0];
                    result.put('success', true);
                    result.put('found', true);
                    result.put('accountId', selectedAsset.AccountId);
                    result.put('accountName', selectedAsset.Account.Name);
                    result.put('accountPhone', selectedAsset.Account.Phone);
                    result.put('postalCode', selectedAsset.Account.BillingPostalCode);
                    result.put('street', selectedAsset.Account.BillingStreet);
                    result.put('city', selectedAsset.Account.BillingCity);
                    result.put('state', selectedAsset.Account.BillingState);
                    result.put('serialNo', selectedAsset.SerialNumber);
                    result.put('equipmentId', selectedAsset.Id);
                } else {
                    // 장비를 찾지 못한 경우에도 성공으로 처리
                    result.put('success', true);
                    result.put('found', false);
                    result.put('serialNo', serialNo);
                }
            }
            // 둘 다 없는 경우
            else {
                result.put('success', true);
                result.put('found', false);
            }
            
            return result;
        } catch (Exception e) {
            System.debug('Error in setEquipInfo: ' + e.getMessage());
            result.put('success', true);  // 에러가 나도 성공으로 처리
            result.put('found', false);
            if (String.isNotBlank(serialNo)) {
                result.put('serialNo', serialNo);
            }
            return result;
        }
    }

    /**
    @ description : 접수자가 보유한 장비의 정보를 시리얼 번호로 조회 method
    **/
    @AuraEnabled
    public static Map<String, Object> getEquipmentBySerialNo(String serialNo, String contactPhoneNumber) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            List<Contact> contactList = new List<Contact>();
            if(contactPhoneNumber != '') {
                System.debug('@@ : ' + contactPhoneNumber);
                contactList = [SELECT Id, AccountId FROM Contact WHERE MobilePhone =:contactPhoneNumber];
            }
            List<Asset> equipments = new List<Asset>();
            if (contactList.size() > 0) {

                // 제조번호로 Asset(장비) 조회
                equipments = [
                    SELECT Id, Name, SerialNumber, AccountId, Account.Name, Account.Phone,
                           Account.ShippingPostalCode, Account.ShippingStreet, Account.ShippingCity,
                           Account.ShippingState
                    FROM Asset 
                    WHERE (SerialNumber = :serialNo OR Name = :serialNo) AND AccountId =:contactList[0].AccountId
                    LIMIT 1
                ];
            } else {
                equipments = [
                    SELECT Id, Name, SerialNumber, AccountId, Account.Name, Account.Phone,
                           Account.ShippingPostalCode, Account.ShippingStreet, Account.ShippingCity,
                           Account.ShippingState
                    FROM Asset 
                    WHERE SerialNumber = :serialNo OR Name = :serialNo
                    LIMIT 1
                ];
            }
                        
            if (equipments.size() >0) {
                Asset equipment = equipments[0];
                result.put('success', true);
                result.put('found', true);
                result.put('accountId', equipment.AccountId);
                result.put('accountName', equipment.Account.Name);
                result.put('accountPhone', equipment.Account.Phone);
                result.put('postalCode', equipment.Account.ShippingPostalCode);
                result.put('street', equipment.Account.ShippingStreet);
                result.put('city', equipment.Account.ShippingCity);
                result.put('state', equipment.Account.ShippingState);
                result.put('serialNo', equipment.SerialNumber);
                result.put('equipmentId', equipment.Id);
            } else {
                result.put('success', true);
                result.put('found', false);
                result.put('message', '입력하신 제조번호의 장비를 찾을 수 없습니다.');
            }
        } catch (Exception e) {
            result.put('success', false);
            result.put('message', '장비 정보 조회 중 오류가 발생했습니다: ' + e.getMessage());
        }
        
        return result;
    }

    /**
    @ description : 접수시 첨부한 파일 연결 Method
    **/
    @testVisible
    private static void attachFiles(List<String> fileIds, Id caseId, Id alarmTalkId) {
        if(fileIds == null || fileIds.isEmpty() || caseId == null || alarmTalkId == null) {
            return;
        }

        try {
            System.debug('Attaching files: ' + fileIds);
            
            // ContentDocumentId 목록 가져오기
            List<ContentDocumentLink> links = new List<ContentDocumentLink>();
            
            for(String fileId : fileIds) {
                try {
                    // AlarmTalk에 파일 연결
                    links.add(new ContentDocumentLink(
                        ContentDocumentId = fileId,
                        LinkedEntityId = alarmTalkId,
                        ShareType = 'V',
                        Visibility = 'AllUsers'
                    ));
                    
                    System.debug('Added links for file: ' + fileId);
                } catch(Exception e) {
                    System.debug('Error processing file ' + fileId + ': ' + e.getMessage());
                }
            }
            
            if(!links.isEmpty()) {
                insert links;
                System.debug('Successfully attached ' + (links.size()/2) + ' files');
            }
        } catch(Exception e) {
            System.debug('Error attaching files: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('파일 첨부 중 오류가 발생했습니다: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String validationNow(Date selectedDate, String selectedTime) {
        System.debug('selectedDate => ' + selectedDate);
        System.debug('selectedTime => ' + selectedTime);
        
        String result = '';
        try {
            String[] strTimeSplit = selectedTime.split(':');
            Time timeChange = Time.newInstance(Integer.valueOf(strTimeSplit[0]) ,Integer.valueOf(strTimeSplit[1]) ,0 ,0);

            DateTime selectDT = DateTime.newInstance(selectedDate,timeChange);
            DateTime nowDT = System.Now();
            
            if(selectDT > nowDT){
                return result = 'Success';
            } else {
                return result = 'Error';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    @ description : 비회원 A/S 접수 처리 Method
    **/
    @AuraEnabled
    public static String setCustomerRequest(
        String accountId, String accountName, String accountPostalCode, 
        String accountAddress, String accountDetailAddress, String symptom, 
        String servicePart, String request, String progressWay, String reservationTime,
        List<String> selectedFileIds, String contactPhoneNumber, String repairRequestDate,
        String requestTimeType, String requestTime, String serialNo, String hogi, String contactName,
        String equipmentNo, String contactId, String selectedServiceCenter, Boolean nightShift, Boolean existEngineer, String receiptMethod, Integer equipmentCheck) {
        try {            

            String assAccId = equipmentNo; //저장 될 장비 Id (장비O) or Name (장비X)
            String accId = accountId; //저장 될 고객사 Id (기본적으로 장비의 Account / 장비가 없고 연락처가 있을 경우 연락처의 Account?)
            Boolean isAccountName = false; //고객정보 수정 여부: true(수정), false(미수정)
            Boolean isContactName = false; //연락처 정보 수정 여부: true(수정), false(미수정)
            Boolean isAccountId = false; //장비 Account Id와 연락처 Account Id 일치 여부: true(일치), false(불일치)
            String msg = ''; //Ticket의 접수내용(ReceptionDetails__c) 문구
            String ticketType = 'Technical inquiry'; //접수상담or기술상담 (General inquiry/Technical inquiry)
            String internalTicketType = progressWay == 'technicalCouncel' ? 'Technical consultation' : 'Failure receipt'; // (접수:Other inquiry, 기술:Technical consultation/Failure receipt)
            String phoneNumber = contactPhoneNumber.replace('-', '');
            String logicCheck = '';

            logicCheck += '----------------------인입 데이터------------------------------\n';
            logicCheck += 'accountId : ' + accountId  + '\n';
            logicCheck += 'accountName : ' + accountName  + '\n';
            logicCheck += 'accountPostalCode : ' + accountPostalCode  + '\n';
            logicCheck += 'accountAddress : ' + accountAddress  + '\n';
            logicCheck += 'accountDetailAddress : ' + accountDetailAddress  + '\n';
            logicCheck += 'symptom : ' + symptom  + '\n';
            logicCheck += 'servicePart : ' + servicePart  + '\n';
            logicCheck += 'request : ' + request  + '\n';
            logicCheck += 'progressWay : ' + progressWay  + '\n';
            logicCheck += 'reservationTime : ' + reservationTime  + '\n';
            logicCheck += 'contactPhoneNumber : ' + contactPhoneNumber  + '\n';
            logicCheck += 'repairRequestDate : ' + repairRequestDate  + '\n';
            logicCheck += 'requestTimeType : ' + requestTimeType  + '\n';
            logicCheck += 'requestTime : ' + requestTime  + '\n';
            logicCheck += 'serialNo : ' + serialNo  + '\n';
            logicCheck += 'hogi : ' + hogi  + '\n';
            logicCheck += 'contactName : ' + contactName  + '\n';
            logicCheck += 'equipmentNo : ' + equipmentNo  + '\n';
            logicCheck += 'contactId : ' + contactId  + '\n';
            logicCheck += 'selectedServiceCenter : ' + selectedServiceCenter  + '\n';
            logicCheck += 'nightShift : ' + nightShift  + '\n';
            logicCheck += 'existEngineer : ' + existEngineer  + '\n';
            logicCheck += 'receiptMethod : ' + receiptMethod  + '\n';
            logicCheck += '----------------------인입 데이터------------------------------\n';

            // if (String.isNotEmpty(selectedServiceCenter)) {
            //     List<ServiceTerritory> obj = 
            //     [
            //         SELECT Id, Name, InstCheck__c, InstEngineer__r.Name
            //         FROM ServiceTerritory
            //         WHERE Id =: selectedServiceCenter
            //     ];
            //     if (obj.size() > 0) {
            //         msg = '업무시간외 알림톡이 접수되어 [' + obj[0].Name + '-' + obj[0].InstEngineer__r.Name + '대표]에게 전달되었습니다.\n';
            //         logicCheck += '업무시간외 접수로 Work Center : ' + obj[0].Name + '\n';
            //     }
            // }

            if(String.isNotEmpty(equipmentNo)){
                String a = [SELECT AccountId FROM Asset WHERE Id = :equipmentNo].AccountId;
                if(a == null) equipmentNo = '';
                logicCheck += 'String.isNotEmpty(equipmentNo) : 1\n';
            }
            
            if(String.isNotEmpty(equipmentNo)){ //........장비O
                logicCheck += ' => String.isNotEmpty(equipmentNo) : 2\n';
                accId = [SELECT AccountId FROM Asset WHERE Id = :equipmentNo].AccountId;
                Account ac = [SELECT Id, Name, ShippingPostalCode, ShippingState,
                                    ShippingCity, ShippingStreet, ShippingAddress 
                              FROM Account 
                              WHERE Id =:accId];

                //고객정보 수정여부 확인
                String acPostalCode = accountPostalCode==''?null:accountPostalCode;
                String acAddress = accountAddress==''?null:accountAddress;
                String acDetailAddress = accountDetailAddress==''?null:accountDetailAddress;
                String inputAddress = ac.ShippingState == null?'':ac.ShippingState;
                if(inputAddress != '') inputAddress+=' ';
                inputAddress+=ac.ShippingCity;
                if(ac.Name != accountName) isAccountName = true;
                else if(ac.ShippingPostalCode != acPostalCode) isAccountName = true;
                else if(inputAddress != acAddress) isAccountName = true;
                else if(ac.ShippingStreet != acDetailAddress) isAccountName = true;

                
                //연락처 존재여부 확인
                if (String.isNotBlank(contactId)) { //........연락처O
                    logicCheck += ' => String.isNotBlank(contactId)\n';
                    Contact co = [SELECT Id, Name, Phone, MobilePhone, AccountId FROM Contact WHERE Id =:contactId];
                    //연락처 정보 수정 여부
                    if(co.Name != contactName) isContactName = true;
                    else if(co.Phone != phoneNumber && co.MobilePhone != phoneNumber) isContactName = true;
                    //장비&연락처 Account 일치 여부
                    if(accId == co.AccountId) isAccountId = true;

                    if(isAccountName){ //........고객정보 수정O
                        logicCheck += ' => isAccountName\n';
                        accId = ''; //고객사 매핑X
                        msg += '고객정보가 수정되었습니다. 장비와 요청자의 고객정보를 확인하세요.\n';
                        if(isContactName){ //........연락처정보 수정O
                            msg += '연락처의 이름이 일치하지 않습니다. 연락처 정보를 확인하세요.\n';
                            msg += '고객명: '+contactName+', 연락처: '+contactPhoneNumber+'\n';
                        }
                        ticketType = 'General inquiry';
                        internalTicketType = 'Other inquiry';
                    } else { //........고객정보 수정X
                        logicCheck += ' => isAccountName else\n';
                        if(isContactName){ //........연락처정보 수정O
                            logicCheck += ' => isContactName\n';
                            if(!isAccountId){ //........장비&연락처 정보 불일치
                                logicCheck += ' => 장비와 연락처의 고객사가 일치하지 않습니다.\n';
                                msg += '장비와 연락처의 고객사가 일치하지 않습니다.\n';
                            }
                            msg += '연락처의 이름이 일치하지 않습니다. 연락처 정보를 확인하세요.\n';
                            msg += '고객명: '+contactName+', 연락처: '+contactPhoneNumber+'\n';

                            ticketType = 'General inquiry';
                            internalTicketType = 'Other inquiry';
                        } else { //........연락처정보 수정X
                            logicCheck += ' => isContactName else\n';
                            if(!isAccountId){ //........장비&연락처 정보 불일치
                                logicCheck += ' => isContactName else !isAccountId\n';
                                msg += '장비와 연락처의 고객사가 일치하지 않습니다.\n';
                                msg += '연락처 정보를 확인하시기 바랍니다.\n';
                                msg += '고객명: '+contactName+', 연락처: '+contactPhoneNumber+'\n';
                            }
                        }
                    }
                } else { //........연락처X
                    logicCheck += ' => String.isNotBlank(contactId) else\n';
                    List<Contact> extContact = [SELECT Id, Name FROM Contact WHERE Phone = :phoneNumber OR MobilePhone = :phoneNumber];
                    
                    if(extContact.size()>0){
                        if(extContact[0].Name != contactName) isContactName = true;
                        if(isContactName){ //........연락처정보 수정O
                            msg += '연락처의 이름이 일치하지 않습니다. 연락처 정보를 확인하세요.\n';
                            msg += '고객명: '+contactName+', 연락처: '+contactPhoneNumber+'\n';
                        }
                        logicCheck += ' => extContact.size()>0\n';
                        contactId = extContact[0].Id;
                        if(extContact.size() == 1) { //연락처가 한 개일 경우
                            logicCheck += ' => extContact.size() == 1\n';
                            contactId = extContact[0].Id;
                        } else { //중복 연락처가 있을 경우
                            logicCheck += ' => 중복 연락처가 있을 경우\n';
                            contactId = extContact[0].Id;
                        }
                    } else {
                        logicCheck += ' => extContact.size()>0 else(새로운 연락처 생성)\n';
                        // 새로운 연락처 생성
                        Contact newCont = new Contact();
                        newCont.MobilePhone = phoneNumber;
                        
                        if(isAccountName){ //........고객정보 수정O
                            logicCheck += ' => isAccountName\n';
                            Account acc = [SELECT Id FROM Account WHERE Name = '미확인 고객사' LIMIT 1];
                            if(acc != null){
                                newCont.AccountId = acc.Id;
                            }
                            msg += '고객정보가 수정되었습니다. 장비와 요청자의 고객정보를 확인하세요.\n';
                            accId = ''; //고객매핑X
                            ticketType = 'General inquiry';
                            internalTicketType = 'Other inquiry';
                        } else { //........고객정보 수정X
                            logicCheck += ' => isAccountName else(고객정보 수정X)\n';
                            newCont.AccountId = accId;
                        }
                        
                        newCont.RecordTypeId = contactPersonRT;
                        newCont.LastName = contactName;
                        insert newCont;

                        contactId = newCont.Id;
                    }
                }
            } else if(String.isNotEmpty(serialNo)){ //제조번호 입력(미일치) _더미 Account 사용
                logicCheck += ' => String.isNotEmpty(equipmentNo) else if {String.isNotEmpty(serialNo)(제조번호 입력(미일치) _더미 Account 사용)}\n';
                System.debug('Here');
                List<Asset> assetList = [
                    SELECT Id, Name, SerialNumber, AccountId
                    FROM Asset
                    WHERE Name = : serialNo OR SerialNumber = : serialNo
                    LIMIT 1
                ];

                if(assetList.size() > 0) {
                    logicCheck += ' => String.isNotEmpty(equipmentNo) else if {assetList.size() > 0}\n';
                    String conAcId = assetList[0].AccountId;
                    List<Contact> conList = [
                        SELECT Id, Phone, MobilePhone, AccountId
                        FROM Contact
                        WHERE (Phone =:contactPhoneNumber OR MobilePhone =:contactPhoneNumber)
                        AND AccountId =: conAcId
                        LIMIT 1
                    ];
                    System.debug('Here1');
                    assAccId = assetList[0].Id;
                    System.debug('Here1 => ' + assAccId);
                    // 04/28 추가
                    if(conList.size() < 1) {
                        logicCheck += ' => String.isNotEmpty(equipmentNo) else if {conList.size() < 1}\n';
                        msg += '제조번호: '+serialNo+'\n';
                        msg += '요청자 정보를 신규 등록하였습니다.\n';
                        Contact newCont = new Contact();
                        newCont.MobilePhone = phoneNumber;
                        newCont.AccountId = conAcId;
                        newCont.RecordTypeId = contactPersonRT;
                        newCont.LastName = contactName;
                        insert newCont;
                        contactId = newCont.Id;
                        accId = newCont.AccountId;
                    } else {
                        logicCheck += ' => String.isNotEmpty(equipmentNo) else if {conList.size() < 1 else}\n';
                        contactId = conList[0].Id;
                        accId = conList[0].AccountId;
                    }
                    //
                } else {
                    logicCheck += ' => String.isNotEmpty(equipmentNo) else(Here2)\n';
                    System.debug('Here2');
                    accId = '';  //고객매핑X
                    assAccId = ''; //장비매핑X
                    msg += '조회된 제조번호가 없습니다. 제조번호를 확인하세요.\n';
                    msg += '제조번호: '+serialNo+'\n';
                    //연락처 존재여부 확인
                    if (String.isNotBlank(contactId)) { //........연락처O
                        logicCheck += ' => String.isNotEmpty(equipmentNo) else(Here2){String.isNotBlank(contactId)}\n';
                        Contact co = [SELECT Id, Name, Phone, MobilePhone, AccountId FROM Contact WHERE Id =:contactId];
                        //연락처 정보 수정 여부
                        if(co.Name != contactName) isContactName = true;
                        else if(co.Phone != phoneNumber && co.MobilePhone != phoneNumber) isContactName = true;
                        if(isContactName){ //........연락처정보 수정O
                            logicCheck += ' => String.isNotEmpty(equipmentNo) else(Here2){String.isNotBlank(contactId) > isContactName(연락처정보 수정O)}\n';
                            msg += '연락처의 이름이 일치하지 않습니다. 연락처 정보를 확인하세요.\n';
                            msg += '고객명: '+contactName+', 연락처: '+contactPhoneNumber+'\n';
                            msg += '업체명: '+accountName+'\n'+
                                               '주소 : (' + accountPostalCode + ') ' + 
                                               accountAddress + ' ' + 
                                               accountDetailAddress;
    
                            ticketType = 'General inquiry';
                            internalTicketType = 'Other inquiry';
                        } 
                    } else {//........연락처X
                        logicCheck += ' => String.isNotEmpty(equipmentNo) else(Here2){String.isNotBlank(contactId) else}\n';
                        // 새로운 연락처 생성
                        Contact newCont = new Contact();
                        newCont.MobilePhone = phoneNumber;
    
                        Account acc = [SELECT Id FROM Account WHERE Name = '미확인 고객사' LIMIT 1];
                        if(acc != null){
                            newCont.AccountId = acc.Id;
                        }
                        newCont.RecordTypeId = contactPersonRT;
                        newCont.LastName = contactName;
                        insert newCont;
    
                        msg += '고객정보가 수정되었습니다. 장비와 요청자의 고객정보를 확인하세요.\n';
                        msg += '고객명: '+contactName+', 연락처: '+contactPhoneNumber+'\n';
                        contactId = newCont.Id;
                        ticketType = 'General inquiry';
                        internalTicketType = 'Other inquiry';
                    }
                }
            } else { //명판사진 첨부
                logicCheck += ' => String.isNotEmpty(equipmentNo) else {명판사진 첨부}\n';
                accId = ''; //고객매핑X
                assAccId = ''; //장비매핑X
                msg += '명판사진으로 접수된 건입니다. 사진을 확인하세요.\n';

                //연락처 존재여부 확인
                if (String.isNotBlank(contactId)) { //........연락처O
                    logicCheck += ' => String.isNotEmpty(equipmentNo) else {명판사진 첨부 > String.isNotBlank(contactId)}\n';
                    Contact co = [SELECT Id, Name, Phone, MobilePhone, AccountId FROM Contact WHERE Id =:contactId];
                    //연락처 정보 수정 여부
                    if(co.Name != contactName) isContactName = true;
                    else if(co.Phone != phoneNumber && co.MobilePhone != phoneNumber) isContactName = true;
                    accId = co.AccountId != null ? co.AccountId : '';
                    if(isContactName){ //........연락처정보 수정O
                        
                        msg += '연락처의 이름이 일치하지 않습니다. 연락처 정보를 확인하세요.\n';
                        msg += '고객명: '+contactName+', 연락처: '+contactPhoneNumber+'\n';
                    } 
                } else {//........연락처X
                    logicCheck += ' => String.isNotEmpty(equipmentNo) else {명판사진 첨부 > String.isNotBlank(contactId) else}\n';
                    // 새로운 연락처 생성
                    Contact newCont = new Contact();
                    newCont.MobilePhone = phoneNumber;
                    
                    Account acc = [SELECT Id FROM Account WHERE Name = '미확인 고객사' LIMIT 1];
                    if(acc != null){
                        newCont.AccountId = acc.Id;
                        accId = acc.Id;
                    }
                    newCont.RecordTypeId = contactPersonRT;
                    newCont.LastName = contactName;
                    insert newCont;

                    contactId = newCont.Id;
                }
                // 명판사진 첨부일 경우 모두 일반문의-기타문의로 변경 (2025-02-17 추가)
                ticketType = 'General inquiry';
                internalTicketType = 'Other inquiry';
            }
            

            // Case 생성
            Case caseRecord = new Case();
            if(String.isNotBlank(accId)) caseRecord.AccountId = accId;
            if(String.isNotBlank(assAccId)) caseRecord.AssetId = assAccId;
            System.debug('Case => ' + contactId);
            caseRecord.ApplicationDateTime__c = System.now();
            caseRecord.Requester__c = contactId;
            caseRecord.ReceptionPath__c = 'Alarm Talk';
            System.debug('equipmentNo : ' + equipmentNo);
            String modifyInfo = '';

            if (isAccountName) {
                logicCheck += ' => 최종 :isAccountName \n';
                modifyInfo += '업체명: '+accountName+'\n'+ '주소 : (' + accountPostalCode + ') ' + accountAddress + ' ' + accountDetailAddress;
            }
            if (equipmentCheck == 2) {
                logicCheck += ' => 최종 :equipmentCheck == 2 \n';
                logicCheck += ' => 최종 :serialNo : ' + serialNo + ', accId : ' + accId + '\n';
                List<Asset> assetList = [
                    SELECT Id, Name, SerialNumber, AccountId
                    FROM Asset
                    WHERE (Name = : serialNo OR SerialNumber = : serialNo) AND AccountId =:accId
                    LIMIT 1
                ];
                if(assetList.size() > 0){
                    logicCheck += ' => 최종 :equipmentCheck == 2 > assetList.size() > 0\n';
                    if(isAccountName){
                        logicCheck += ' => 최종 :equipmentCheck == 2 > isAccountName\n';
                        caseRecord.TicketType__c = 'General inquiry';
                        caseRecord.InternalTicketType__c = 'Other inquiry';
                    } else {
                        logicCheck += ' => 최종 :equipmentCheck == 2 > isAccountName else\n';
                        caseRecord.TicketType__c = 'Technical inquiry';
                        caseRecord.InternalTicketType__c = internalTicketType;
                    }
                } else {
                    logicCheck += ' => 최종 :equipmentCheck == 2 > assetList.size() > 0 else\n';
                    caseRecord.TicketType__c = 'General inquiry';
                    caseRecord.InternalTicketType__c = 'Other inquiry';
                }

                

                if (String.isBlank(msg)) {
                    logicCheck += ' => 최종 :String.isBlank(msg)\n';
                    List<Contact> isCallerNameList = [SELECT Id, Name, Phone, MobilePhone, AccountId FROM Contact WHERE Id =:contactId AND Name LIKE 'Caller%' LIMIT 1];
                    if (!isCallerNameList.isEmpty()) {
                        logicCheck += ' => 최종 :equipmentCheck == 2 else > String.isBlank(msg) > !isCallerNameList.isEmpty()\n';
                        caseRecord.TicketType__c = 'General inquiry';
                        caseRecord.InternalTicketType__c = 'Other inquiry';
                    } else {
                        logicCheck += ' => 최종 :equipmentCheck == 2 else > String.isBlank(msg) > !isCallerNameList.isEmpty() else\n';
                        caseRecord.TicketType__c = 'Technical inquiry';
                        caseRecord.InternalTicketType__c = internalTicketType;
                    }
                } else {
                    logicCheck += ' => 최종 :String.isBlank(msg) else\n';
                    caseRecord.TicketType__c = 'General inquiry';
                    caseRecord.InternalTicketType__c = 'Other inquiry';
                }

                caseRecord.ReceptionDetails__c = msg +
                                                (String.isNotBlank(request) ? '요청 : ' + request + '\n' : '') + 
                                               (String.isNotBlank(servicePart) ? '서비스 부품 : ' + servicePart + '\n' : '') +
                                               modifyInfo + '\n' +'증상 : ' + symptom;
            } else {
                logicCheck += ' => 최종 :equipmentCheck == 2 else\n';
                

                List<Contact> isCallerNameList = [SELECT Id, Name, Phone, MobilePhone, AccountId FROM Contact WHERE Id =:contactId AND Name LIKE 'Caller%' LIMIT 1];
                // caseRecord.TicketType__c = ticketType;
                if (String.isBlank(msg)) {
                    logicCheck += ' => 최종 :equipmentCheck == 2 else > String.isBlank(msg)\n';
                    if (!isCallerNameList.isEmpty()) {
                        logicCheck += ' => 최종 :equipmentCheck == 2 else > String.isBlank(msg) > !isCallerNameList.isEmpty()\n';
                        caseRecord.TicketType__c = 'General inquiry';
                        caseRecord.InternalTicketType__c = 'Other inquiry';
                    } else {
                        logicCheck += ' => 최종 :equipmentCheck == 2 else > String.isBlank(msg) > !isCallerNameList.isEmpty() else\n';
                        caseRecord.TicketType__c = 'Technical inquiry';
                        caseRecord.InternalTicketType__c = internalTicketType;
                    }
                } else {
                    logicCheck += ' => 최종 :equipmentCheck == 2 else > String.isBlank(msg) else\n';
                    caseRecord.TicketType__c = 'General inquiry';
                    caseRecord.InternalTicketType__c = 'Other inquiry';
                }
                
                caseRecord.ReceptionDetails__c = msg + '\n' +
                                               (String.isNotBlank(request) ? '요청 : ' + request + '\n' : '') + 
                                               (String.isNotBlank(servicePart) ? '서비스 부품 : ' + servicePart + '\n' : '') + 
                                               modifyInfo + '\n' +'증상 : ' + symptom;
            }
            logicCheck += ' => 최종 :TicketType__c : ' + caseRecord.TicketType__c + '\n';
            logicCheck += ' => 최종 :InternalTicketType__c : ' + caseRecord.InternalTicketType__c + '\n';
            logicCheck += ' => 최종 :ReceptionDetails__c : ' + caseRecord.ReceptionDetails__c;
            
            if(String.isNotBlank(repairRequestDate) && String.isNotBlank(requestTime)) {
                String dateTimeStr = repairRequestDate + ' ' + requestTime + ':00';
                try {
                    DateTime dt = DateTime.valueOf(dateTimeStr);
                    caseRecord.RepairRequestDateTime__c = dt;
                } catch(Exception e) {
                    System.debug('출동요청일시 파싱 오류: ' + e.getMessage());
                }
            }
            //파일 갯수
            caseRecord.FileCount__c = (selectedFileIds != null && !selectedFileIds.isEmpty())?selectedFileIds.size():0;

            insert caseRecord;

            Case newCaseRecord = [SELECT Id, CaseNumber, AssetId, Asset.InstEngineer__c FROM Case WHERE Id = :caseRecord.Id LIMIT 1];
            
            // AlarmTalk 생성
            AlarmTalk__c alarmTalk = new AlarmTalk__c();
            alarmTalk.Name = '[알림톡] 고객 문의';
            alarmTalk.Ticket__c = caseRecord.Id;
            alarmTalk.Symptom__c = symptom;
            alarmTalk.RequestedTerm__c = request;
            alarmTalk.ServicePart__c = servicePart;
            alarmTalk.AccountName__c = accountName;
            alarmTalk.Phone__c = contactPhoneNumber;
            alarmTalk.PostalCode__c = accountPostalCode;
            alarmTalk.Address__c = accountAddress;
            alarmTalk.DetailAddress__c = accountDetailAddress;
            alarmTalk.EquipmentNumber__c = serialNo;
            // alarmTalk.W_C__c = selectedServiceCenter;
            alarmTalk.ReceiptMethod__c = receiptMethod;
            alarmTalk.LogicCheck__c = logicCheck;

            if(internalTicketType != 'Other inquiry') alarmTalk.TheWayOfProceeding__c = progressWay == 'technicalCouncel' ? 'Technical inquiry' : 'Dispatch repair';
            else alarmTalk.TheWayOfProceeding__c = internalTicketType;
            
            if (String.isNotBlank(assAccId)) {
                alarmTalk.Equipment__c = assAccId;
            }
            if (String.isNotBlank(accId)) {
                alarmTalk.Account__c = accId;
            }
            alarmTalk.Contact__c = contactId;
            
            if(String.isNotBlank(repairRequestDate) && String.isNotBlank(requestTime)) {
                String dateTimeStr = repairRequestDate + ' ' + requestTime + ':00';
                try {
                    DateTime dt = DateTime.valueOf(dateTimeStr);
                    alarmTalk.RepairRequestDateTime__c = dt;
                } catch(Exception e) {
                    System.debug('출동요청일시 파싱 오류: ' + e.getMessage());
                }
            }

            insert alarmTalk;
            System.debug('selectedFileIds1 => ' + selectedFileIds);

            // 파일 첨부
            if(selectedFileIds != null && !selectedFileIds.isEmpty()) {
                List<ContentDocumentLink> links = new List<ContentDocumentLink>();
                System.debug('selectedFileIds2 => ' + selectedFileIds);
                // ContentVersion에서 ContentDocumentId 조회
                List<ContentVersion> contentVersions = [
                    SELECT Id, ContentDocumentId 
                    FROM ContentVersion 
                    WHERE Id IN :selectedFileIds
                ];
                System.debug('contentVersions => ' + contentVersions);

                for (ContentVersion cv : contentVersions) {
                    ContentDocumentLink alarmLink = new ContentDocumentLink();
                    alarmLink.ContentDocumentId = cv.ContentDocumentId;
                    alarmLink.LinkedEntityId = alarmTalk.Id;
                    alarmLink.ShareType = 'V';
                    alarmLink.Visibility = 'AllUsers';
                    links.add(alarmLink);

                    ContentDocumentLink caseLink = new ContentDocumentLink();
                    caseLink.ContentDocumentId = cv.ContentDocumentId;
                    caseLink.LinkedEntityId = caseRecord.Id;
                    caseLink.ShareType = 'V';
                    caseLink.Visibility = 'AllUsers';
                    links.add(caseLink);
                }
                
                if (!links.isEmpty()) {
                    try {
                        insert links;
                    } catch(Exception e) {
                        System.debug('Error linking files: ' + e.getMessage());
                    }
                }
            }

            System.debug('nightShift ::' + nightShift);
            System.debug('existEngineer ::' + existEngineer);


            System.debug('알림톡:::'+newCaseRecord.CaseNumber);
            // 고객에게 알림톡 전송
            String url = 'dn-solutions.my.site.com/service/statusService?ticket='+newCaseRecord.CaseNumber;
            Map<String, String> alarmMap = new Map<String, String>{
                'rcpt_no'   => newCaseRecord.CaseNumber,
                'url'       => url
            };

            //알림톡 AS 접수 완료 안내
            String alertTalkID = [SELECT Id, Name FROM AlertManager__c WHERE Name = 'AS Reception Completion Alarm Talk' LIMIT 1].Id;
            //알림톡 AS 접수 완료 안내_업무시간 외
            String alertTalkID_out = [SELECT Id, Name FROM AlertManager__c WHERE Name = 'AS Reception Completion Outside Hours Alarm Talk' LIMIT 1].Id;
            List<UTIL_Alert.HistoryWrapper> hwList = new List<UTIL_Alert.HistoryWrapper>();
            UTIL_Alert.historyWrapper talkWrapper = new UTIL_Alert.historyWrapper();
            talkWrapper.alertID = nightShift?alertTalkID_out:alertTalkID;
            talkWrapper.targetID = alarmTalk.Id;
            talkWrapper.alertType = 'AlarmTalk';
            talkWrapper.alertLanguage = 'ko';
            talkWrapper.elementMap = alarmMap;
            talkWrapper.receiverforPhone = new Set<String>{ phoneNumber };
            hwList.add(talkWrapper);

            // String alertManagerID = [SELECT Id FROM AlertManager__c WHERE Name = 'Send Noti To Inst Engineer At Night' LIMIT 1].Id;
            // String statusUrl = 'https://dn-solutions.my.site.com/service/statusService?ticket=';
            // if(nightShift == true && String.isNotBlank(selectedServiceCenter)) {
            //     System.debug('selectedServiceCenter ::' + selectedServiceCenter);
            //     List<ServiceTerritory> obj = 
            //     [
            //         SELECT Id, Name, InstCheck__c, InstEngineer__c
            //         FROM ServiceTerritory
            //         WHERE Id =: selectedServiceCenter
            //     ];
    
            //     String receiver = obj[0].InstEngineer__c;
            //     System.debug('receiver'+receiver);
            //     UTIL_Alert.HistoryWrapper hw = new UTIL_Alert.HistoryWrapper();
            //     hw.alertID = alertManagerID;
            //     hw.targetID = newCaseRecord.Id;
            //     hw.alertType = 'Notification';
            //     hw.alertLanguage = 'ko';
            //     hw.title = '업무시간외 서비스 접수 알림';
            //     hw.elementList = new List<String>{ newCaseRecord.CaseNumber };
            //     hw.receiverforID = new Set<Id>{ receiver };
            //     hwList.add(hw);
            //     System.debug('야간, 주치의o' + hwList);
            // }

            if(hwList.size() > 0) {
                UTIL_Alert.runAlertEvent(hwList);
            }
            return '접수가 완료되었습니다.';

        } catch (Exception e) {
            System.debug('Error in setCustomerRequest: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    @ description : 이미 접수된 서비스를 휴대폰 번호 기준으로 조회하는 Method
    **/
    @AuraEnabled
    public static List<AlarmTalkWithWorkOrderStatus> checkAlarmTalk(String phoneNumber) {
        List<AlarmTalkWithWorkOrderStatus> result = new List<AlarmTalkWithWorkOrderStatus>();
        try {
            List<Case> alarmTalks = [SELECT Id, FM_PhoneNumber__c, Account.FM_Address__c, Account.Name, Status,
                                            Asset.Name, Asset.SerialNumber, Asset.MachineName__c, RepairRequestDateTime__c, 
                                            ContactPhone__c, CreatedDate, CaseNumber, WorkOrder__r.Noti_Number__c, ApplicationDateTime__c,
                                            (SELECT Id, Symptom__c, RequestedTerm__c, ServicePart__c FROM AlarmTalk__r),
                                            (SELECT Id FROM ContentDocumentLinks WHERE ContentDocument.Id != null AND ContentDocument.CreatedBy.Name ='사이트 게스트 사용자 서비스센터')
                                    FROM Case
                                    WHERE Status NOT IN ('Reject')
                                    AND Requester__r.MobilePhone =:phoneNumber 
                                    ORDER BY ApplicationDateTime__c DESC];
                                    /**Id IN (SELECT Ticket__c FROM AlarmTalk__c 
                                                 WHERE Phone__c = :phoneNumber 
                                                 AND (NOT Name LIKE '%[고객취소요청]%') AND (NOT Name LIKE '%[완료]%')) */

            // List<ContentDocumentLink> cdl = [SELECT Id, ContentDocumentId, LinkedEntityId
            //                                  FROM ContentDocumentLink
            //                                  WHERE LinkedEntityId IN 
            //                                     (SELECT Id FROM AlarmTalk__c WHERE Phone__c = :phoneNumber AND (NOT Name LIKE '%[고객취소요청]%') AND (NOT Name LIKE '%[완료]%'))
            //                                 ];
            Set<Id> caseId = new Set<Id>();
            for(Case at : alarmTalks){
                if(at.Id != null){
                	caseId.add(at.Id);
                }
            }

            Map<Id, List<WorkOrder>> workOrdersMap = new Map<Id, List<WorkOrder>>();
            if (!caseId.isEmpty()) {
                List<WorkOrder> workOrders = [SELECT Id, Status, CaseId, ServiceOrderNumber__c, Noti_Number__c, ServiceTerritory.Name, Worker__r.Name, Worker__r.RelatedRecord.MobilePhone
                                              FROM WorkOrder 
                                              WHERE CaseId IN: caseId];
            
                for (WorkOrder wo : workOrders) {
                    if (!workOrdersMap.containsKey(wo.CaseId)) {
                        workOrdersMap.put(wo.CaseId, new List<WorkOrder>());
                    }
                    workOrdersMap.get(wo.CaseId).add(wo);
                }
            }

            for (Case alarm : alarmTalks) {
                List<WorkOrder> relatedWorkOrders = new List<WorkOrder>();
                if (workOrdersMap.containsKey(alarm.Id)) {
                    relatedWorkOrders = workOrdersMap.get(alarm.Id);
                }
                result.add(new AlarmTalkWithWorkOrderStatus(alarm, relatedWorkOrders));//, cdl));
            }

            return result;
        } catch (Exception e) {
            throw new AuraHandledException('알림톡 정보 조회하는 중 오류가 발생했습니다: ' + e.getMessage());
        }
    }

    /**
    @ description : 기 접수된 A/S 를 취소하는 Method
    **/
    @AuraEnabled
    public static String cancelAlarmTalk(String caseId, String cancelReason) {
        System.debug('caseId ::' + caseId);
        System.debug('cancelReason ::' + cancelReason);
        try {
            //서비스오더가 완료되었거나, 출발 혹은 도착 했을 경우 취소 실패
            List<WorkOrder> woList = [SELECT Id, Status FROM WorkOrder WHERE CaseId =: caseId AND Status IN ('Arrived','Started','Completed')];
            if(woList.size()>0){
                throw new AuraHandledException('해당 건은 이미 서비스 완료 되었거나, 서비스 기사가 출발 하였습니다.');
            }

            Case tic = 
            [
                SELECT Id, Status, CaseNumber, OwnerId, Account.Name, Requester__r.Name, FM_PhoneNumber__c, EndOfReason__c
                FROM Case
                WHERE Id = :caseId
            ];

            // 수리요청일시 인
            List<AlarmTalk__c> alarmTalk = [
                SELECT Id, Name, Ticket__r.RepairRequestDateTime__c, Ticket__r.OwnerId, Owner.Name, Ticket__c, Ticket__r.Status, Ticket__r.CaseNumber,
                Phone__c, Contact__r.Name, AccountName__c
                FROM AlarmTalk__c 
                WHERE Ticket__c = :caseId 
                LIMIT 1
            ];

            String receptionNo = tic.CaseNumber;
            String orderNo = tic.CaseNumber;
            String receptionist = tic.Requester__r.Name;
            String accountName = tic.Account.Name;
            String phone = tic.FM_PhoneNumber__c;

            if(alarmTalk.size()>0){
                alarmTalk[0].Name = '[고객취소요청][' + cancelReason + ']' + alarmTalk[0].Name;
            }
            tic.Status = 'Closed';
            tic.EndOfReason__c = 'Customer Cancellation';
            tic.ClosedReasonDetails__c = cancelReason;

            update alarmTalk;
            update tic;

            // 내부 기술 상담사(Ticket Owner 에게 노티전송)
            String alertManagerID = [SELECT Id, Name FROM AlertManager__c WHERE Name = 'CS AS Reception Cancel Noti' LIMIT 1].Id;
            List<UTIL_Alert.HistoryWrapper> wrappers   = new List<UTIL_Alert.HistoryWrapper>();
            UTIL_Alert.HistoryWrapper wrapper = new UTIL_Alert.HistoryWrapper();
            wrapper.alertType       = 'Notification';
            wrapper.elementList.add(tic.CaseNumber);
            wrapper.elementList.add(cancelReason);
            wrapper.alertID         = alertManagerID;
            wrapper.targetID        = caseId;
            wrapper.receiverforID   = new Set<Id>{tic.OwnerId};
            wrapper.alertLanguage   = 'ko';
            wrappers.add(wrapper);

            Map<String, String> alarmMap = new Map<String, String>{
                'rcpt_no'            => receptionNo,
                'order_no'           => orderNo,
                'agent_nm'           => receptionist,
                'clnt_nm'            => accountName,
                'reason_to_cancel'   => cancelReason
            };

            // 고객에게 알림톡 전송
            String alertTalkID = [SELECT Id, Name FROM AlertManager__c WHERE Name = 'A/S Reception Cancel Alarm Talk' LIMIT 1].Id;
            UTIL_Alert.historyWrapper talkWrapper = new UTIL_Alert.historyWrapper();
            talkWrapper.alertID = alertTalkID;
            talkWrapper.alertType = 'AlarmTalk';
            talkWrapper.targetID = caseId;
            talkWrapper.receiverforPhone = new Set<String>{ phone };
            talkWrapper.alertLanguage = 'ko';
            talkWrapper.elementMap = alarmMap;
            wrappers.add(talkWrapper);

            System.debug('wrappers'+wrappers);
            UTIL_Alert.runAlertEvent(wrappers);

            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    @ description : 수리 요청 일시 확인
    **/
    @AuraEnabled
    public static Map<String, String> checkRepairRequestDateTime(String caseId) {
        try {
            Map<String, String> result = new Map<String, String>();

            // AlarmTalk__c alarmTalk = [
            //     SELECT Id, Ticket__c, Ticket__r.RepairRequestDateTime__c 
            //     FROM AlarmTalk__c 
            //     WHERE Id = :alarmTalkId 
            //     LIMIT 1 
            // ];

            //서비스오더가 완료되었거나, 출발 혹은 도착 했을 경우
            List<WorkOrder> woList = [SELECT Id, Status FROM WorkOrder WHERE CaseId =: caseId AND Status IN ('Arrived','Started','Completed')];
            if(woList.size()>0){
                result.put('CancelCheck', 'Y'); //취소실패
            } else {
                result.put('CancelCheck', '');
            }
            // result.put('hasRepairRequestDateTime', alarmTalk.Ticket__r?.RepairRequestDateTime__c != null);
            // result.put('repairRequestDateTime', alarmTalk.Ticket__r?.RepairRequestDateTime__c);
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('수리요청일시 확인 중 오류가 발생했습니다: ' + e.getMessage());
        }
    }

    /**
    @ description : A/S 에 필요한 첨부 파일 저장
    **/
    @AuraEnabled
    public static String saveNameSymptomFile(String base64Data, String fileName, String contentType, Integer index, String alarmTalkId) {
        try {
            if(String.isBlank(base64Data) || String.isBlank(fileName) || String.isBlank(alarmTalkId)) {
                throw new AuraHandledException('필수 파라미터가 누락되었습니다.');
            }

            // ContentVersion 생성
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            cv.Title = fileName;
            cv.PathOnClient = fileName;
            cv.IsMajorVersion = true;
            cv.FirstPublishLocationId = alarmTalkId;  // 첫 번째 공유 위치를 설정
            insert cv;

            // ContentDocument 회
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

            // ContentDocumentLink 생성
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conDocId;
            cdl.LinkedEntityId = alarmTalkId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;

            return cv.Id;
        } catch (Exception e) {
            System.debug('Error in saveNameSymptomFile: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('파일 업로드 중 오류가 발생했습니다: ' + e.getMessage());
        }
    }

    /**
    @ description : 접수한 Case 에 첨부된 파일 목록을 가져오는 Method
    **/
    @AuraEnabled
    public static List<FileInfo> getAttachedFiles(String caseId) {
        try {
            List<FileInfo> files = new List<FileInfo>();
            
            // Case 생성 시간 조회
            Case cs = [SELECT CreatedDate FROM Case WHERE Id = :caseId LIMIT 1];
            Datetime caseCreatedDate = cs.CreatedDate;
            
            // 현재 유효한 ContentDocumentLink만 조회
            List<ContentDocumentLink> links = [
                SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId,
                       ContentDocument.Title, ContentDocument.FileExtension
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :caseId
                AND ContentDocument.Id != null
                AND ContentDocument.CreatedBy.Name ='사이트 게스트 사용자 서비스센터'
            ];
            
            Set<Id> versionIds = new Set<Id>();
            for(ContentDocumentLink link : links) {
                if(link.ContentDocument?.LatestPublishedVersionId != null) {
                    versionIds.add(link.ContentDocument.LatestPublishedVersionId);
                }
            }
            
            if (!versionIds.isEmpty()) {
                // ContentVersion 보 조회
                List<ContentVersion> versions = [
                    SELECT Id, Title, FileType, ContentDocumentId,
                           FileExtension, ContentSize, CreatedDate
                    FROM ContentVersion
                    WHERE Id IN :versionIds
                    ORDER BY CreatedDate ASC
                ];
                
                for(ContentVersion cv : versions) {
                    files.add(new FileInfo(cv, caseCreatedDate));
                }
            }
            
            return files;
        } catch (Exception e) {
            throw new AuraHandledException('첨부 파일 조회 중 오류가 발생했습니다: ' + e.getMessage());
        }
    }

    /**
    @ description : 접수한 Case 에 첨부된 파일을 삭제하는 Method
    **/
    @AuraEnabled
    public static void deleteFile(String contentDocumentId, String caseId) {
        try {
            // ContentDocumentLink만 삭제
            List<ContentDocumentLink> links = [
                SELECT Id 
                FROM ContentDocumentLink 
                WHERE ContentDocumentId = :contentDocumentId
                AND LinkedEntityId  =: caseId
                LIMIT 1
            ];
            
            if(!links.isEmpty()) {
                delete links;
                
                Case cs = [SELECT Id, FileCount__c FROM Case WHERE Id =: caseId];
                cs.FileCount__c -= 1;
                update cs;
            }


        } catch (Exception e) {
            System.debug('Error deleting file: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('파일 삭제 중 오류가 발생했습니다: ' + e.getMessage());
        }
    }

    /**
    @ description : 접수한 Case 에 첨부된 파일을 삭제하는 Method
    **/
    @AuraEnabled  
    public static void deleteFiles(string contentVersionId){ //File 삭제
        try {
            // ContentVersion에서 ContentDocumentId 조회
            String contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1].ContentDocumentId;
            
            // ContentDocumentLink 레코드를 삭제할 수 있는지 확인
            List<ContentDocumentLink> linksToDelete = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocumentId];
            if (!linksToDelete.isEmpty()) {
                delete linksToDelete;
            }
            
            // ContentDocument 삭제
            ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId LIMIT 1];
            if (cd != null) {
                delete cd;
            }

        } catch (Exception e) {
            System.debug('Error deleting file: ' + e.getMessage());
        }
    }
    

    // 파일 정보를 담는 래퍼 클래스
    public class FileInfo {
        @AuraEnabled public String id;
        @AuraEnabled public String title;
        @AuraEnabled public String fileType;
        @AuraEnabled public String contentDocumentId;
        @AuraEnabled public String fileExtension;
        @AuraEnabled public Integer contentSize;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Boolean isImage;
        @AuraEnabled public Boolean isVideo;
        @AuraEnabled public String downloadUrl;
        @AuraEnabled public String thumbnailUrl;
        @AuraEnabled public Boolean canDelete;
        
        public FileInfo(ContentVersion cv, Datetime caseCreatedDate) {
            this.id = cv.Id;
            this.title = cv.Title;
            this.fileType = cv.FileType;
            this.contentDocumentId = cv.ContentDocumentId;
            this.fileExtension = cv.FileExtension;
            this.contentSize = cv.ContentSize;
            this.createdDate = cv.CreatedDate;
            
            // 파일 타입 확인
            Set<String> imageTypes = new Set<String>{'JPG', 'JPEG', 'PNG', 'GIF'};
            Set<String> videoTypes = new Set<String>{'MP4', 'MOV', 'AVI'};
            
            this.isImage = imageTypes.contains(cv.FileExtension.toUpperCase());
            this.isVideo = videoTypes.contains(cv.FileExtension.toUpperCase());

            // URL 설정
            String baseUrl = Url.getOrgDomainUrl().toExternalForm();
            this.downloadUrl = baseUrl + '/sfc/servlet.shepherd/document/download/' + cv.ContentDocumentId;
            
            // 썸네일 URL 설정
            if(this.isImage) {
                // 이미지인 경우 썸네일 생성
                this.thumbnailUrl = baseUrl + '/sfc/servlet.shepherd/document/download/' + cv.ContentDocumentId;
            } else if(this.isVideo) {
                // 비디오인 경우 본 비디오 아이콘 표시
                this.thumbnailUrl = baseUrl + '/img/icon/t4v35/standard/video_120.png';
            }
            
            // 삭제 가능 여부 설정 (AlarmTalk 생성 1시간 후에 추가된 파일만 삭제 가능)
            Long timeDifferenceInMinutes = (cv.CreatedDate.getTime() - caseCreatedDate.getTime()) / (1000 * 60);
            this.canDelete = timeDifferenceInMinutes > 60;


            // 위에 코드(1시간 후에 추가된 파일삭제 가능)이 아니라 1시간 이내면 아래코드 사용
            // Integer dayDifference = System.today().daysBetween(cv.CreatedDate.date());
            // if (dayDifference >= 1) {
            //     this.canDelete = false;
            // } else {
            //     // 파일이 업로드된 지 1시간 이내면 삭제 가능
            //     Long minutesDifference = System.now().getTime() - cv.CreatedDate.getTime() / (1000 * 60);
            //     this.canDelete = minutesDifference <= 60;
            // }
        }
    }

    /**
    @ description : 접수한 Case 및 알람톡과 첨부된 File 을 연결하는 Method
    **/
    @AuraEnabled
    public static String linkFileToAlarmTalk(String contentVersionId, String caseId) {
        try {
            // ContentDocumentId 조회
            String contentDocumentId = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id = :contentVersionId 
                LIMIT 1
            ].ContentDocumentId;
    
            // 이미 연결된 파일 개수 조회
            Integer existingFileCount = [
                SELECT COUNT() 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :caseId
            ];
            
            // 새로운 파일 추가
            List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
            
            // 이미 연결되어 있는지 확인
            List<ContentDocumentLink> existingLinks = [
                SELECT Id 
                FROM ContentDocumentLink 
                WHERE ContentDocumentId = :contentDocumentId 
                AND LinkedEntityId = :caseId
            ];
            
            if (existingLinks.isEmpty()) {
                // ContentDocumentLink 생성
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDocumentId;
                cdl.LinkedEntityId = caseId;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                newLinks.add(cdl);
            }
            
            // 새로 추가되는 파일이 있다면 Insert
            if (!newLinks.isEmpty()) {
                insert newLinks;
            }
            
            // Case 파일 개수 업데이트
            if (caseId != null) {
                Case cs = [SELECT Id, FileCount__c FROM Case WHERE Id = :caseId LIMIT 1];
    
                Integer newFileCount = existingFileCount + newLinks.size();
                cs.FileCount__c = newFileCount;
                
                update cs;
            }
    
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Error in linkFileToAlarmTalk: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('파일 연결 중 오류가 발생했습니다: ' + e.getMessage());
        }
    }    

    /**
    @ description : 부품처리현황 조회 Method
    **/
    @AuraEnabled
    public static Object getPartsProgress(String startDate, String orderNumber) { //String partNumber, 
        try {
            IF_ERP_Material_Classes.IF_CSPLUS_007_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req();
            req.FR_RECV_DAT = startDate.substring(0, 10);
            req.TO_RECV_DAT = startDate.substring(0, 10);
            // req.I_MATNR = partNumber; //품번
            List<String> orderNumbers = orderNumber.split(', ');
            // 오더넘버 설정
            List<IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2> T_I_LIST2= new List<IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2>();
            for(String st : orderNumbers){
                IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2 orderList = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2();
                orderList.LOW = st; //오더번호
                T_I_LIST2.add(orderList);
            }
            req.T_I_LIST2 = T_I_LIST2;
            
            IF_ERP_Material instance = new IF_ERP_Material();
            IF_ERP_Material_Classes.IF_CSPLUS_007_Res response = instance.IF_CSPLUS_007(req);
            
            return response;
        } catch (Exception e) {
            throw new AuraHandledException('부품정보 조회 중 오류가 발생했습니다: ' + e.getMessage());
        }
    }

    //parameter ticket 정보 있으면 해당 ticket과 연관된 alarmTalk 정보 가져오기
    @AuraEnabled
    public static CommonWrapper getTicketInfo(String ticketNo) {
        CommonWrapper cw = new CommonWrapper();
        List<AlarmTalkWithWorkOrderStatus> result = new List<AlarmTalkWithWorkOrderStatus>();
        try {
            Id ticketID = [SELECT Id FROM Case WHERE CaseNumber = : ticketNo LIMIT 1].Id;
            List<Case> alarmTalks = new List<Case>();
            alarmTalks = [SELECT Id, FM_PhoneNumber__c, Account.FM_Address__c, Account.Name, 
                                 Asset.Name, Asset.SerialNumber, Asset.MachineName__c, RepairRequestDateTime__c, Status,
                                 ContactPhone__c, CreatedDate, CaseNumber, WorkOrder__r.Noti_Number__c, ApplicationDateTime__c,
                                 (SELECT Id, Symptom__c, RequestedTerm__c, ServicePart__c 
                                  FROM AlarmTalk__r
                                  WHERE (NOT Name LIKE '%[고객취소요청]%') AND (NOT Name LIKE '%[완료]%'))
                                 ,(SELECT Id FROM ContentDocumentLinks WHERE ContentDocument.Id != null AND ContentDocument.CreatedBy.Name ='사이트 게스트 사용자 서비스센터')
                         FROM Case
                         WHERE Id =: ticketID AND Status NOT IN ('Reject')
                         ORDER BY ApplicationDateTime__c DESC];

            // List<ContentDocumentLink> cdl = [SELECT Id, ContentDocumentId, LinkedEntityId
            //                                  FROM ContentDocumentLink
            //                                  WHERE LinkedEntityId IN 
            //                                     (SELECT Id FROM AlarmTalk__c WHERE Ticket__c = :ticketID AND (NOT Name LIKE '%[고객취소요청]%') AND (NOT Name LIKE '%[완료]%'))
            //                                 ];

            Map<Id, List<WorkOrder>> workOrdersMap = new Map<Id, List<WorkOrder>>();
            List<WorkOrder> workOrders = [SELECT Id, Status, CaseId, ServiceOrderNumber__c, Noti_Number__c
                                                , ServiceTerritory.Name, Worker__r.Name, Worker__r.RelatedRecord.MobilePhone
                                          FROM WorkOrder 
                                          WHERE CaseId =: ticketID];
        
            for (WorkOrder wo : workOrders) {
                if (!workOrdersMap.containsKey(ticketID)) {
                    workOrdersMap.put(ticketID, new List<WorkOrder>());
                }
                workOrdersMap.get(ticketID).add(wo);
            }

            for (Case alarm : alarmTalks) {
                List<WorkOrder> relatedWorkOrders = new List<WorkOrder>();
                if (workOrdersMap.containsKey(alarm.Id)) {
                    relatedWorkOrders = workOrdersMap.get(alarm.Id);
                }
                result.add(new AlarmTalkWithWorkOrderStatus(alarm, relatedWorkOrders));//, cdl));
            }

            cw.returnList = result;
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = '알림톡 정보 조회하는 중 오류가 발생했습니다: ' + e.getStackTraceString() + ',' + e.getMessage();
        }
        return cw;
    }

    /**
     * parameter Order Number로 ticket 정보 있으면 해당 ticket과 연관된 alarmTalk 정보 가져오기
     *
     * @param SOrder WorkOrder Number로 Ticket을 조회하기 위한 값
     * @return Ticket 정보
     * @throws Exception 알림톡 정보 조회 중 오류가 발생한 경우에 나는 Exception
     */
    @AuraEnabled
    public static CommonWrapper getOrderInfo(String SOrder) {
        CommonWrapper cw = new CommonWrapper();
        List<AlarmTalkWithWorkOrderStatus> result = new List<AlarmTalkWithWorkOrderStatus>();

        try {
            List<WorkOrder> workorderList = [SELECT Id, CaseId FROM WorkOrder WHERE  ServiceOrderNumber__c =:SOrder];
            if (workorderList.isEmpty()) {
                throw new IllegalArgumentException('ServiceOrder 정보가 없습니다.');
            }
            Id ticketID = workorderList[0].CaseId;
            List<Case> alarmTalks = new List<Case>();
            alarmTalks = [SELECT Id, FM_PhoneNumber__c, Account.FM_Address__c, Account.Name, 
                                 Asset.Name, Asset.SerialNumber, Asset.MachineName__c, RepairRequestDateTime__c, Status,
                                 ContactPhone__c, CreatedDate, CaseNumber, WorkOrder__r.Noti_Number__c, ApplicationDateTime__c,
                                 (SELECT Id, Symptom__c, RequestedTerm__c, ServicePart__c 
                                  FROM AlarmTalk__r
                                  WHERE (NOT Name LIKE '%[고객취소요청]%') AND (NOT Name LIKE '%[완료]%'))
                                 ,(SELECT Id FROM ContentDocumentLinks WHERE ContentDocument.Id != null AND ContentDocument.CreatedBy.Name ='사이트 게스트 사용자 서비스센터')
                         FROM Case
                         WHERE Id =: ticketID AND Status NOT IN ('Reject')
                         ORDER BY ApplicationDateTime__c DESC];

            Map<Id, List<WorkOrder>> workOrdersMap = new Map<Id, List<WorkOrder>>();
            List<WorkOrder> workOrders = [SELECT Id, Status, CaseId, ServiceOrderNumber__c, Noti_Number__c
                                                , ServiceTerritory.Name, Worker__r.Name, Worker__r.RelatedRecord.MobilePhone
                                          FROM WorkOrder 
                                          WHERE CaseId =: ticketID];
        
            for (WorkOrder wo : workOrders) {
                if (!workOrdersMap.containsKey(ticketID)) {
                    workOrdersMap.put(ticketID, new List<WorkOrder>());
                }
                workOrdersMap.get(ticketID).add(wo);
            }

            for (Case alarm : alarmTalks) {
                List<WorkOrder> relatedWorkOrders = new List<WorkOrder>();
                if (workOrdersMap.containsKey(alarm.Id)) {
                    relatedWorkOrders = workOrdersMap.get(alarm.Id);
                }
                result.add(new AlarmTalkWithWorkOrderStatus(alarm, relatedWorkOrders));//, cdl));
            }

            cw.returnList = result;
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = '알림톡 정보 조회하는 중 오류가 발생했습니다: ' + e.getStackTraceString() + ',' + e.getMessage();
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
        public Boolean isSuccess 		          {get; set;}
        @AuraEnabled
        public String errMessage		          {get; set;} 
        @AuraEnabled
        public List<Object> returnList {get; set;}
        
        public CommonWrapper(){
            this.isSuccess 		= true;
            this.errMessage 	= '';
            this.returnList 	= new List<Object>();
        }
    }

    public class AlarmTalkWithWorkOrderStatus{
        @AuraEnabled public Id Id { get; set;}
        @AuraEnabled public String WorkOrderStatus { get; set;}
        @AuraEnabled public String Phone { get; set;}
        @AuraEnabled public String Address { get; set;}
        @AuraEnabled public String AccountName { get; set;}
        @AuraEnabled public String EquipmentName { get; set;}
        @AuraEnabled public String EquipmentSerialNumber { get; set;}
        @AuraEnabled public String EquipmentMachineName { get; set;}
        @AuraEnabled public String Symptom { get; set;}
        @AuraEnabled public String RequestedTerm { get; set;}
        @AuraEnabled public Datetime RepairRequestDateTime { get; set;}
        @AuraEnabled public String ContactPhone { get; set;}
        @AuraEnabled public Datetime CreatedDate { get; set;}
        @AuraEnabled public String NotiNumber { get; set;}
        @AuraEnabled public String CaseNumber { get; set;}
        @AuraEnabled public String ServiceEngineer { get; set;}
        @AuraEnabled public String ServicePhone { get; set;}
        @AuraEnabled public String ServicePart { get; set;}
        @AuraEnabled public String WorkCenter { get; set;}
        @AuraEnabled public String ServiceResource { get; set;}
        @AuraEnabled public String ServiceResourcePhone { get; set;}
        @AuraEnabled public String Status { get; set;}
        @AuraEnabled public Boolean IsStatus { get; set;}
        @AuraEnabled public List<ContentDocumentLink> ContentDocumentLinks { get; set;}

        
        public AlarmTalkWithWorkOrderStatus(Case alarm, List<WorkOrder> workOrders){//, List<ContentDocumentLink> cdl) {
            Id = alarm.Id;
            Phone = alarm.FM_PhoneNumber__c;
            Address = alarm.Account.FM_Address__c;
            AccountName = alarm.Account.Name;
            EquipmentName = alarm.Asset.Name;
            EquipmentSerialNumber = alarm.Asset.SerialNumber;
            EquipmentMachineName = alarm.Asset.MachineName__c;
            RepairRequestDateTime = alarm.RepairRequestDateTime__c;
            ContactPhone = alarm.ContactPhone__c;
            CreatedDate = alarm.ApplicationDateTime__c;
            CaseNumber = alarm.CaseNumber;
            ContentDocumentLinks = alarm.ContentDocumentLinks;
            Status = alarm.Status;
            IsStatus = (alarm.Status != 'Closed'); 

            if (alarm.AlarmTalk__r != null && !alarm.AlarmTalk__r.isEmpty()) {
                // Id = alarm.AlarmTalk__r[0].Id;
                Symptom = alarm.AlarmTalk__r[0].Symptom__c;
                RequestedTerm = alarm.AlarmTalk__r[0].RequestedTerm__c;
                ServicePart = alarm.AlarmTalk__r[0].ServicePart__c;

                // if(cdl != null && !cdl.isEmpty()) {
                //     List<ContentDocumentLink> alarmCDL = new List<ContentDocumentLink>();
                //     for(ContentDocumentLink c : cdl){
                //         if(c.LinkedEntityId == alarm.AlarmTalk__r[0].Id){
                //             alarmCDL.add(c);
                //         }
                //     }
                //     ContentDocumentLinks = alarmCDL;
                // }
            }
            
            List<String> workNumberList = new List<String>();
            List<String> workStatusList = new List<String>();
            List<String> workCenterList = new List<String>();
            List<String> serviceResourceList = new List<String>();
            List<String> servicePhoneList = new List<String>();
            if (workOrders != null && !workOrders.isEmpty()) {
                for (WorkOrder wo : workOrders) {
                    if (wo.ServiceTerritory != null) {
                        workNumberList.add(wo.ServiceOrderNumber__c);
                    }
                    if (wo.ServiceTerritory != null) {
                        workStatusList.add(wo.Status);
                    }
                    if (wo.ServiceTerritory != null) {
                        workCenterList.add(wo.ServiceTerritory.Name);
                    }
                    if (wo.Worker__r != null) {
                        serviceResourceList.add(wo.Worker__r.Name);
                    }
                    if (wo.Worker__r?.RelatedRecord?.MobilePhone != null) {
                        servicePhoneList.add(wo.Worker__r.RelatedRecord.MobilePhone);
                    }
                }
            }
            
            NotiNumber = (workNumberList.isEmpty()) ? '' : String.join(workNumberList, ', ');
            WorkOrderStatus = (workStatusList.isEmpty()) ? '' : String.join(workStatusList, ', ');
            WorkCenter = (workCenterList.isEmpty()) ? '' : String.join(workCenterList, ', ');
            ServiceResource = (serviceResourceList.isEmpty()) ? '' : String.join(serviceResourceList, ', ');
            ServiceResourcePhone = (servicePhoneList.isEmpty()) ? '' : String.join(servicePhoneList, ', ');

            List<String> targetStatuses = new List<String>{'Arrived', 'Started', 'Completed'};
            for (String status : targetStatuses) {
                if (WorkOrderStatus.contains(status)) {
                    WorkOrderStatus = 'NoCancel';
                    break;
                }
            }
        }
    }
}