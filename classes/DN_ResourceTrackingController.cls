/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-09-01
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-07-31   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_ResourceTrackingController {

    public DN_ResourceTrackingController() {}

    // 서비스요원 위치조회 Init
    @AuraEnabled
    public static Map<String, Object> getInit(String recordId) {
        Map<String, Object> result = new Map<String, Object>();

        result.put('isSuccess', true);

        try {
            
            result.put('getWorkCenterList',  getWorkCenterList());
            result.put('getResourceAbsenceType',  getResourceAbsenceType());
            result.put('getFirstCenterLocation',  getFirstCenterLocation(recordId));
            Map<String, Object> equipMap = (Map<String, Object>) result.get('getFirstCenterLocation');
            
            System.debug('isSuccess ::: ' + (Boolean)equipMap.get('isSuccess'));
            if ((Boolean)equipMap.get('isSuccess')) {
                System.debug('equipMap ::: ' + equipMap.get('equipId'));
                Decimal lat = (Decimal) equipMap.get('lat');
                Decimal lng = (Decimal) equipMap.get('lng');
                String equipId = (String) equipMap.get('equipId');
    
                if (equipId == '') {
                    result.put('isSuccess', false);
                    result.put('message', '장비가 없습니다.');
                    result.put('getDispatchedHistory',  new List<Technician>());
                } else {
                    result.put('getDispatchedHistory',  getDispatchedHistory(equipId, lat, lng));
                }
            } else {
                result.put('isSuccess', false);
                result.put('message', (String) equipMap.get('errorMessage'));
            }
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            result.put('isSuccess', false);
            result.put('message', 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
        }

        return result;
    }

    // 서비스요원 조회
    @AuraEnabled
    public static Map<String, Object> getSearchTechnicians(String affiliation, String workStatus, String resourceName) {
        Map<String, Object> result = new Map<String, Object>();
        try {

            result.put('getTechnicians',  getTechnicians(affiliation, workStatus, resourceName));

            return result;

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 현장주변 요원조회
    @AuraEnabled
    public static Map<String, Object> getDistanceTechnicians(String distance, Decimal equipLat, Decimal equipLng) {
        Map<String, Object> result = new Map<String, Object>();
        try {

            result.put('getTechniciansInDistance',  getTechniciansInDistance(distance, equipLat, equipLng));

            return result;

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 주소 조회
    @AuraEnabled
    public static Map<String, Object> getSearchAddress(String searchAddress) {
        Map<String, Object> result = new Map<String, Object>();
        try {

            result.put('getAddress',  getAddress(searchAddress));

            return result;

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 조회한 주소 선택시 좌표 조회
    @AuraEnabled
    public static Map<String, Object> getSelectAddressEquipment(String selectAddress) {
        Map<String, Object> result = new Map<String, Object>();
        try {

            result.put('getAddressEquipment',  getAddressEquipment(selectAddress));

            return result;

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 조회된 서비스요원 목록 Sorting
    @AuraEnabled
    public static Map<String, Object> getTechnicianSortingList(List<Object> objList, String sortingField, Decimal sortType) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            List<Object> sortingList = sortingList(objList, sortingField, sortType);
            List<Technician> resultList = new List<Technician>();
            for (Object obj : sortingList) {
                Technician tech = (Technician) JSON.deserialize(JSON.serialize(obj), Technician.class);
                resultList.add(tech);
            }


            result.put('sortingList',  resultList);

            return result;

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 업무 상태 Picklist
    private static List<Object> getResourceAbsenceType() {

        Schema.DescribeSObjectResult schemaReady        = Schema.getGlobalDescribe().get('ServiceResource').getDescribe();
        Map<String, Schema.SObjectField> schemaFieldMap = schemaReady.fields.getMap();

        Schema.sObjectField token           = schemaFieldMap.get('CurrentStatus__c');
        List<Schema.PicklistEntry> Entries  = token.getDescribe().getPicklistValues();
        
        List<Object> resuorceTypeList = new List<Object>();
        Map<String, String> resuorceTypeFirst = new Map<String, String>();

        resuorceTypeFirst.put('label', Label.DNS_SRT_All);
        resuorceTypeFirst.put('value', Label.DNS_SRT_All);
        resuorceTypeList.add(resuorceTypeFirst);

        for (Schema.PicklistEntry entry : Entries) {
            Map<String, String> resuorceType = new Map<String, String>();
            resuorceType.put('label', entry.getLabel());
            resuorceType.put('value', entry.getValue());
            resuorceTypeList.add(resuorceType);
        }

        return resuorceTypeList;
    }

    // 소속 Picklist
    private static List<Object> getWorkCenterList() {
        List<ServiceTerritory> stList = [SELECT Id, Name FROM ServiceTerritory WHERE PlanningPlant__c = '184S' AND IsActive = true];
        Set<String> stNameSet = new Set<String>();
        for (ServiceTerritory st : stList) {
            stNameSet.add(st.Name);
        }

        List<String> stNameList = new List<String>(stNameSet);
        stNameList.sort();

        List<Object> workCenterList = new List<Object>();
        Map<String, String> workcenterDetailFirst = new Map<String, String>();

        workcenterDetailFirst.put('label', Label.DNS_SRT_All);
        workcenterDetailFirst.put('value', Label.DNS_SRT_All);
        workCenterList.add(workcenterDetailFirst);
        
        for (String workcenter : stNameList) {
            Map<String, String> workcenterDetail = new Map<String, String>();
            workcenterDetail.put('label', workcenter);
            workcenterDetail.put('value', workcenter);
            workCenterList.add(workcenterDetail);
        }
        return workCenterList;
    }

    // 현장주변 요원조회
    private static Map<String, Object> getTechniciansInDistance(String distance, Decimal equipLat, Decimal equipLng) {
        Map<String, Object> resultMap = new Map<String, Object>();
        Decimal d = Decimal.valueOf(distance);
        Map<String, String> currentStatusMap = getCurrentStatusType();

        List<Technician> technicianList = new List<Technician>();
        List<Technician> drList = new List<Technician>();
        List<Technician> nrList = new List<Technician>();
        List<Technician> drSortingList = new List<Technician>();
        List<Technician> nrSortingList = new List<Technician>();

        List<ServiceResource> resourceList = [SELECT Id, Name, Service_Territory__r.Name, Service_Territory__r.Id, Service_Territory__r.classify__c, Service_Territory__r.ControlWorkcenter__r.Name, StaffNumber__c, LastKnownLatitude, LastKnownLongitude, PhoneNumber__c, FSL__GanttLabel__c, CurrentStatus__c
                                            FROM ServiceResource
                                            WHERE IsActive = true AND ResourceType = 'T' AND Service_Territory__r.PlanningPlant__c = '184S' AND LastKnownLatitude != null AND LastKnownLongitude != null ORDER BY Name];

        for (ServiceResource resource : resourceList) {
            Decimal dist = 0;
            if (resource.CurrentStatus__c != null) {

                String technicianLoc = '';

                if (resource.LastKnownLatitude != null && resource.LastKnownLongitude != null) {
                    dist = getDistance(equipLat, equipLng, resource.LastKnownLatitude, resource.LastKnownLongitude);
    
                    if (d == 0 || dist <= d) {
                        Technician technician = new Technician();
                        technician.id = resource.Id;
                        technician.sapId = resource.StaffNumber__c == null ? '' : resource.StaffNumber__c;
                        technician.name = resource.Name == null ? '' : resource.Name;
                        String replacePhonenumber = resource.PhoneNumber__c == null ? '' : String.valueOf(resource.PhoneNumber__c).replace('-', '');
                        technician.phone = replacePhonenumber == '' ? '' : replacePhonenumber.substring(0, 3) + '-' + replacePhonenumber.substring(3, 7) + '-' + replacePhonenumber.substring(7, 11);
                        if (resource.Service_Territory__r.classify__c == 'W/C') {
                            technician.topWorkcenter = resource.Service_Territory__r.ControlWorkcenter__r.Name == null ? '' : resource.Service_Territory__r.ControlWorkcenter__r.Name;
                        } else {
                            technician.topWorkcenter = resource.Service_Territory__r.Name == null ? '' : resource.Service_Territory__r.Name;
                        }
                        technician.workcenter = resource.Service_Territory__r.Name == null ? '' : resource.Service_Territory__r.Name;
                        technician.workcenterId = resource.Service_Territory__r.Id;
                        technician.location = technicianLoc;
                        technician.distance = dist.setScale(2);
                        technician.status = currentStatusMap.get(resource.CurrentStatus__c);
                        technician.lat = resource.LastKnownLatitude;
                        technician.lng = resource.LastKnownLongitude;
                        switch on resource.CurrentStatus__c {
                            when 'Wait' {
                                technician.imageSrc = '/resource/MapImage/awaiting.png';
                                drList.add(technician);
                            }
                            when 'Meeting' {
                                technician.imageSrc = '/resource/MapImage/meeting.png';
                                nrList.add(technician);
                            }
                            when 'Education' {
                                technician.imageSrc = '/resource/MapImage/training.png';
                                nrList.add(technician);
                            }
                            when else {
                                technician.imageSrc = '/resource/MapImage/working.png';
                                nrList.add(technician);
                            }
                        }
                        technicianList.add(technician);
                    }
                }

            }

        }

        List<Object> drObjList = sortingList(drList, 'distance', 1);
        for (Object obj : drObjList) {
            Technician tech = (Technician) JSON.deserialize(JSON.serialize(obj), Technician.class);
            drSortingList.add(tech);
        }

        List<Object> nrObjList = sortingList(nrList, 'distance', 1);
        for (Object obj : nrObjList) {
            Technician tech = (Technician) JSON.deserialize(JSON.serialize(obj), Technician.class);
            nrSortingList.add(tech);
        }

        resultMap.put('technicianList', technicianList);
        resultMap.put('drList', drSortingList);
        resultMap.put('nrList', nrSortingList);

        return resultMap;
    }

    // 서비스요원 조건조회
    private static List<Technician> getTechnicians(String affiliation, String workStatus, String resourceName) {
        
        Map<String, String> currentStatusMap = getCurrentStatusType();

        String query = 'SELECT Id, Name, Service_Territory__r.Name, Service_Territory__r.Id, Service_Territory__r.classify__c, Service_Territory__r.ControlWorkcenter__r.Name, StaffNumber__c, LastKnownLatitude, LastKnownLongitude, PhoneNumber__c, FSL__GanttLabel__c, CurrentStatus__c FROM ServiceResource WHERE IsActive = true AND ResourceType = \'T\'  AND Service_Territory__r.Branch__c = \'DNS\' ';
        
        if (affiliation != '전체' && affiliation != 'All') query += ' AND Service_Territory__r.Name = \'' + affiliation + '\'';
        if (resourceName != '' && resourceName != null) query += ' AND Name LIKE \'%' + resourceName + '%\'';

        query += ' ORDER BY Name';
        
        List<ServiceResource> resourceFullList = Database.query(query);
        
        List<ServiceResource> resourceList = new List<ServiceResource>();
        List<Technician> technicianList = new List<Technician>();

        if (workStatus != '전체' && workStatus != 'All') {

            for (ServiceResource resource : resourceFullList) {
                if (resource.CurrentStatus__c != null && resource.CurrentStatus__c == workStatus) {
                    resourceList.add(resource);
                }
            }
            
        } else {
            resourceList = resourceFullList;
        }

        for (ServiceResource resource : resourceList) {
            String technicianLoc = '';

            Technician technician = new Technician();

            if (resource.LastKnownLatitude != null && resource.LastKnownLongitude != null) {
                technician.lat = resource.LastKnownLatitude;
                technician.lng = resource.LastKnownLongitude;
            }
            
            
            technician.id = resource.Id;
            technician.sapId = resource.StaffNumber__c == null ? '' : resource.StaffNumber__c;
            technician.name = resource.Name == null ? '' : resource.Name;
            String replacePhonenumber = resource.PhoneNumber__c == null ? '' : String.valueOf(resource.PhoneNumber__c).replace('-', '');
            technician.phone = replacePhonenumber == '' ? '' : replacePhonenumber.substring(0, 3) + '-' + replacePhonenumber.substring(3, 7) + '-' + replacePhonenumber.substring(7, 11);
            if (resource.Service_Territory__r.classify__c == 'W/C') {
                technician.topWorkcenter = resource.Service_Territory__r.ControlWorkcenter__r.Name == null ? '' : resource.Service_Territory__r.ControlWorkcenter__r.Name;
            } else {
                technician.topWorkcenter = resource.Service_Territory__r.Name == null ? '' : resource.Service_Territory__r.Name;
            }
            technician.workcenter = resource.Service_Territory__r.Name == null ? '' : resource.Service_Territory__r.Name;
            technician.workcenterId = resource.Service_Territory__r.Id == null ? '' : resource.Service_Territory__r.Id;
            technician.location = technicianLoc;
            technician.status = currentStatusMap.get(resource.CurrentStatus__c);
            
            switch on resource.CurrentStatus__c {
                when 'Wait' {
                    technician.imageSrc = '/resource/MapImage/awaiting.png';
                }
                when 'Meeting' {
                    technician.imageSrc = '/resource/MapImage/meeting.png';
                }
                when 'Education' {
                    technician.imageSrc = '/resource/MapImage/training.png';
                }
                when else {
                    technician.imageSrc = '/resource/MapImage/working.png';
                }
            }
            technicianList.add(technician);
            
        }

        return technicianList;
    }

    // Init에 필요한 장비의 정보조회
    private static Map<String, Object> getFirstCenterLocation(String recordId) {
        Map<String, Object> locationMap = new Map<String, Object>();

        locationMap.put('isSuccess', true);

        Decimal latitude = 37.5570572;
        Decimal longitude = 126.9736211;
        String equipImg = '/resource/MapImage/machine.png';
        String objectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        System.debug('objectType ::: ' + objectType);
        String city = '';
        String street = '';
        String assetId = '';

        if (objectType == 'Case') {
            Case ticket = [SELECT Id, AssetId FROM Case WHERE Id = :recordId LIMIT 1];
            assetId = ticket.AssetId;
        } else {
            WorkOrder order = [SELECT Id, AssetId FROM WorkOrder WHERE Id = :recordId LIMIT 1];
            assetId = order.AssetId;
        }

        try {

            List<ServiceResource> srList;
            Account acc = new Account();
            locationMap.put('equipId', assetId);

            Asset equipment = [SELECT Id, AccountId, InstWorkCenter__c, ShipTo__c FROM Asset WHERE Id = :assetId LIMIT 1];

            if (equipment.AccountId != null) {
                acc = [SELECT Id, BillingStreet, ShippingAddress, ShippingLatitude, ShippingLongitude, sggNm__c, FM_Address__c, ShippingCity, ShippingStreet FROM Account WHERE Id = :equipment.AccountId LIMIT 1];
            }
            if (equipment.InstWorkCenter__c != null) {
                srList = [SELECT Id, Name, StaffNumber__c, AD_ID__c, Service_Territory__r.Name, Service_Territory__r.Id FROM ServiceResource WHERE Service_Territory__c = :equipment.InstWorkCenter__c ORDER BY StaffNumber__c];
            }

            System.debug('acc주소 ::: ' + acc.ShippingAddress.getCity() + ' ' + acc.ShippingAddress.getStreet());

            city = acc.ShippingAddress.getCity() == null ? '' : acc.ShippingAddress.getCity();
            street = acc.ShippingAddress.getStreet() == null ? '' : acc.ShippingAddress.getStreet();

            locationMap.put('accAddress', city + ' ' + street);

            Map<String, Object> equipAddressMap = getAddressEquipment(city + ' ' + street);
            if (equipAddressMap.get('lat') == null || equipAddressMap.get('lng') == null) {
                locationMap.put('accAddress', city + ' ' + street);
                locationMap.put('selectAddress', 'DN서울사무소');
                locationMap.put('equipImg', equipImg);
                locationMap.put('lat', latitude);
                locationMap.put('lng', longitude);
    
                locationMap.put('isSuccess', false);
                locationMap.put('errorMessage', '카카오지도에서 가져올 수 없는 주소입니다.');
                return locationMap;
            }

            latitude = Decimal.valueOf(String.valueOf(equipAddressMap.get('lat')));
            longitude = Decimal.valueOf(String.valueOf(equipAddressMap.get('lng')));
    
            System.debug('latitude ::: ' + latitude);
            System.debug('longitude ::: ' + longitude);
            
            locationMap.put('selectAddress', city + ' ' + street);
            locationMap.put('equipImg', equipImg);
            locationMap.put('lat', latitude);
            locationMap.put('lng', longitude);
            locationMap.put('srList', srList);
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());

            Account acc = new Account();
            Asset equipment = [SELECT Id, AccountId, InstWorkCenter__c, ShipTo__c FROM Asset WHERE Id = :assetId LIMIT 1];

            if (equipment.AccountId != null) {
                acc = [SELECT Id, ShippingCity, ShippingStreet FROM Account WHERE Id = :equipment.AccountId LIMIT 1];
            }

            String selectAddress = getAddressRegioncode(latitude, longitude);
            String errorCity = acc.ShippingCity == null ? '' : acc.ShippingCity;
            String errorStreet = acc.ShippingStreet == null ? '' : acc.ShippingStreet;

            locationMap.put('accAddress', errorCity + ' ' + errorStreet);
            locationMap.put('selectAddress', selectAddress);
            locationMap.put('equipImg', equipImg);
            locationMap.put('lat', latitude);
            locationMap.put('lng', longitude);

            locationMap.put('isSuccess', false);
            locationMap.put('errorMessage', '카카오지도에서 가져올 수 없는 주소입니다.');
        }

        return locationMap;
    }

    // 주소 목록 조회
    private static String getAddress(String searchAddress) { 

        IF_MOIS_Address interfaceTest = new IF_MOIS_Address();
        String result = interfaceTest.getAddressInfo(searchAddress, '1');

        return result;

    }

    // 출동이력보유자 조회
    private static List<Technician> getDispatchedHistory(String equipId, Decimal equipLat, Decimal equipLng) {

        List<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder WHERE AssetId = :equipId];

        Set<String> woIdSet = new Set<String>();

        for (WorkOrder wo : workOrderList) {
            woIdSet.add(wo.Id);
        }

        List<ServiceAppointment> saList = [SELECT Id, ServiceResource__c FROM ServiceAppointment WHERE ParentRecordId IN :woIdSet AND (Status = 'Completed' OR Status = 'Cannot complete' OR Status = 'Confirm')];

        List<String> srIdSet = new List<String>();

        if (Test.isRunningTest()) {
            List<ServiceResource> testSRList = [SELECT Id, Name, PhoneNumber__c, StaffNumber__c, LastKnownLatitude, LastKnownLongitude, Service_Territory__c, Service_Territory__r.Name, Service_Territory__r.Id FROM ServiceResource];
            for (ServiceResource sr : testSRList) {
                srIdSet.add(sr.Id);
            }
        }

        for (ServiceAppointment sa : saList) {
            srIdSet.add(sa.ServiceResource__c);
        }

        List<ServiceResource> srList = [SELECT Id, Name, PhoneNumber__c, StaffNumber__c, LastKnownLatitude, LastKnownLongitude, Service_Territory__c, Service_Territory__r.Name, Service_Territory__r.Id FROM ServiceResource WHERE Id IN :srIdSet];

        System.debug('srList ::: ' + srList);

        List<Technician> technicianList = new List<Technician>();

        for (ServiceResource resource : srList) {
            Decimal dist = 0;
            if (resource.LastKnownLatitude != null && resource.LastKnownLongitude != null) {
                dist = getDistance(equipLat, equipLng, resource.LastKnownLatitude, resource.LastKnownLongitude);
            }

            Technician technician = new Technician();
            technician.id = resource.Id;
            technician.sapId = resource.StaffNumber__c == null ? '' : resource.StaffNumber__c;
            technician.name = resource.Name;
            technician.workcenter = resource.Service_Territory__r.Name;
            technician.workcenterId = resource.Service_Territory__r.Id;
            technician.lat = resource.LastKnownLatitude;
            technician.lng = resource.LastKnownLongitude;
            technician.distance = dist.setScale(2);
            technicianList.add(technician);
        }

        return technicianList;

    }

    // 좌표로 행정구역 조회 (단건)
    public static String getAddressRegioncode(Decimal lat, Decimal lng) {
        
        IF_Authentication__mdt ifAuthMdt = [
            SELECT  Id, Password__c
            FROM    IF_Authentication__mdt
            WHERE   System__c = 'KAKAO'
            LIMIT   1 ];

        String authKey = ifAuthMdt.Password__c;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Authorization', authKey);
        request.setEndpoint('https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?input_coord=WGS84&y=' + lat + '&x=' + lng);

        HttpResponse response = new HttpResponse();

        if (!Test.isRunningTest()) {
            response = http.send(request);
        } else {
            String resBody = '{"documents":[{"region_type":"B","code":"4812310600","address_name":"경상남도 창원시 성산구 남산동","region_1depth_name":"경상남도","region_2depth_name":"창원시 성산구","region_3depth_name":"남산동","region_4depth_name":"","x":128.69658199782057,"y":35.19921580988067},{"region_type":"H","code":"4812356000","address_name":"경상남도 창원시 성산구 성주동","region_1depth_name":"경상남도","region_2depth_name":"창원시 성산구","region_3depth_name":"성주동","region_4depth_name":"","x":128.69506217206344,"y":35.189691366956}]}';
    
            response.setBody(resBody);
            response.setStatusCode(200);
        }
        System.debug('Status ::: ' + response.getStatusCode());
        String regioncode = '';
        if (response.getStatusCode() == 200) {
            System.debug('response.getBody ::: ' + response.getBody());
            Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> resList = (List<Object>) resMap.get('documents');
            Map<String, Object> resObjMap = (Map<String, Object>)resList[1];
            regioncode = String.valueOf(resObjMap.get('address_name'));
        }
        
        return regioncode;
    }

    // 좌표로 행정구역 조회 (다건) (ServiceResource용)
    @AuraEnabled
    public static List<Technician> getAddressRegioncodes(List<Technician> resourceList) {
        IF_Authentication__mdt ifAuthMdt = [
            SELECT  Id, Password__c
            FROM    IF_Authentication__mdt
            WHERE   System__c = 'KAKAO'
            LIMIT   1 ];

        String authKey = ifAuthMdt.Password__c;

        Http http = new Http();
        for (Technician sr : resourceList) {
            String regioncode = '';
            if (sr.lat == null || sr.lng == null) {
                continue;
            }
            Decimal lat = sr.lat;
            Decimal lng = sr.lng;
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setHeader('Authorization', authKey);
            request.setEndpoint('https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?input_coord=WGS84&y=' + lat + '&x=' + lng);

            HttpResponse response = new HttpResponse();
            if (!Test.isRunningTest()) {
                response = http.send(request);
            } else {
                String resBody = '{"meta":{"total_count":2},"documents":[{"region_type":"B","code":"4812310600","address_name":"경상남도 창원시 성산구 남산동","region_1depth_name":"경상남도","region_2depth_name":"창원시 성산구","region_3depth_name":"남산동","region_4depth_name":"","x":128.69658199782057,"y":35.19921580988067},{"region_type":"H","code":"4812356000","address_name":"경상남도 창원시 성산구 성주동","region_1depth_name":"경상남도","region_2depth_name":"창원시 성산구","region_3depth_name":"성주동","region_4depth_name":"","x":128.69506217206344,"y":35.189691366956}]}';
    
                response.setBody(resBody);
                response.setStatusCode(200);
            }

            System.debug('Status ::: ' + response.getStatusCode());
            if (response.getStatusCode() == 200) {
                System.debug('response.getBody ::: ' + response.getBody());
                Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> resList = (List<Object>) resMap.get('documents');
                Map<String, Object> resObjMap = (Map<String, Object>)resList[1];
                regioncode = String.valueOf(resObjMap.get('address_name'));
                sr.location = regioncode;
            }
        }
        
        return resourceList;
    }

    // 장비주소로 좌표조회
    private static Map<String, Object> getAddressEquipment(String selectAddress) {
        Map<String, Object> equipMap = new Map<String, Object>();
        System.debug('selectAddress ::: ' + selectAddress);
        IF_Authentication__mdt ifAuthMdt = [
            SELECT  Id, Password__c
            FROM    IF_Authentication__mdt
            WHERE   System__c = 'KAKAO'
            LIMIT   1 ];

        String authKey = ifAuthMdt.Password__c;

        String equipImg = '/resource/MapImage/machine.png';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Authorization', authKey);
        request.setEndpoint('https://dapi.kakao.com/v2/local/search/address.json?analyze_type=similar&page=1&size=1&query=' + EncodingUtil.urlEncode(selectAddress, 'UTF-8'));

        HttpResponse response = new HttpResponse();
        if (!Test.isRunningTest()) {
            response = http.send(request);
        } else {
            String resBody = '{"documents":[{"address":{"address_name":"경기 성남시 수정구 시흥동 225-4","b_code":"4113111500","h_code":"4113165000","main_address_no":"225","mountain_yn":"N","region_1depth_name":"경기","region_2depth_name":"성남시 수정구","region_3depth_h_name":"시흥동","region_3depth_name":"시흥동","sub_address_no":"4","x":"127.101697384653","y":"37.4195220504075"},"address_name":"경기 성남시 수정구 대왕판교로 887","address_type":"ROAD_ADDR","road_address":{"address_name":"경기 성남시 수정구 대왕판교로 887","building_name":"","main_building_no":"887","region_1depth_name":"경기","region_2depth_name":"성남시 수정구","region_3depth_name":"시흥동","road_name":"대왕판교로","sub_building_no":"","underground_yn":"N","x":"127.101697384653","y":"37.4195220504075","zone_no":"13449"},"x":"127.101697384653","y":"37.4195220504075"}],"meta":{"is_end":true,"pageable_count":1,"total_count":1}}';

            response.setBody(resBody);
            response.setStatusCode(200);
        }
        System.debug('Status ::: ' + response.getStatusCode());
        System.debug('response.getBody() ::: ' + response.getBody());
        if (response.getStatusCode() == 200) {
            Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> resList = (List<Object>) resMap.get('documents');
            if (resList.size() > 0) {
                System.debug('resList ::: ' + resList[0]);
                Map<String, Object> resObjMap = (Map<String, Object>)resList[0];
                Map<String, Object> obj = (Map<String, Object>) resObjMap.get('road_address');
                equipMap.put('selectAddress', obj.get('address_name'));
                equipMap.put('lng', obj.get('x'));
                equipMap.put('lat', obj.get('y'));
                equipMap.put('equipImg', equipImg);
            }
        }

        return equipMap;

    }

    // 좌표사이 거리 구하기
    private static Decimal getDistance(Decimal lat1, Decimal lng1, Decimal lat2, Decimal lng2) {
        Decimal r = 6371; // 지구 반지름 (단위: km)
        Decimal dLat = deg2rad(lat2 - lat1);
        Decimal dLng = deg2rad(lng2 - lng1);
        
        Decimal a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                     Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
                     Math.sin(dLng / 2) * Math.sin(dLng / 2);
        Decimal c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        Decimal distance = r * c; // 두 지점 간의 거리 (단위: km)
        return distance;
    }

    // 좌표사이 거리 구하기에 필요한 공식
    private static Decimal deg2rad(Decimal deg) {
        return deg * (Math.PI / 180);
    }

    // 리스트를 파라메터로 받은 필드 기준으로 Sorting, sortType으로 방향 선택 (1 : 오름차순, 2: 내림차순)
    public static List<Object> sortingList(List<Object> objList, String sortingField, Decimal sortType) {

        Map<String, List<Object>> objListMap = new Map<String, List<Object>>();
        Boolean Decimaltype = false;

        for (Object obj : objList) {


            Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
            List<Object> valueList = new List<Object>();

            String key = String.valueOf(objMap.get(sortingField));
            
            if (objMap.get(sortingField) instanceof Decimal) {
                Decimaltype = true;
            } else {
                Decimaltype = false;
            }
            
            if (objListMap.get(key) != null) {
                valueList = objListMap.get(key);
            }
            valueList.add(obj);
            objListMap.put(key, valueList);
        }
        
        List<Object> resultList = new List<Object>();

        if (Decimaltype) {
            List<Decimal> keyList = new List<Decimal>();

            for (String key : objListMap.keySet()) {
                keyList.add(Decimal.valueOf(key));
            }

            keyList.sort();

            for (Decimal key : keyList) {
                resultList.addAll(objListMap.get(String.valueOf(key)));
            }
            
        } else {
            List<String> keyList = new List<String>();
            
            keyList.addAll(objListMap.keySet());

            keyList.sort();

            for (String key : keyList) {
                resultList.addAll(objListMap.get(key));
            }
        }

        if (sortType == 2) {
            List<Object> reversedList = new List<Object>();

            for (Integer i = resultList.size() - 1; i >= 0; i--) {
                reversedList.add(resultList[i]);
            }

            return reversedList;
        } else {
            return resultList;
        }

    }

    // Id가 어떤 오브젝트인지 판별하는 메서드
    @AuraEnabled
    public static String getObjectType(String recordId) {
        return Id.valueOf(recordId).getSObjectType().getDescribe().getName();
    }

    // Service Order에서 위치조회로 서비스요원선택 시 Service Order의 작업자를 업데이트하는 메서드
    @AuraEnabled
    public static ResultWrapper updateServiceOrder(String recordId, String technicianId, String workcenterId) {
        ResultWrapper result = new ResultWrapper();
        try {

            WorkOrder wo = [SELECT Id, Status, PMActivityType__c, CaseId, FailureAreaValue__c, FailureAreaGroupValue__c, FailurePhenomenonValue__c FROM WorkOrder WHERE Id = :recordId LIMIT 1];

            if (wo.PMActivityType__c == 'CS02') {
                if(String.isEmpty(wo.FailureAreaValue__c) || String.isEmpty(wo.FailureAreaGroupValue__c) || String.isEmpty(wo.FailurePhenomenonValue__c)){
                    System.debug('고장정보 없는 2번 오더');
                    if(wo.CaseId != null){
                        Case ticket = [SELECT Id, FailureAreaValue__c, FailureAreaDetailValue__c, FailurePhenomenonValue__c FROM Case WHERE Id = :wo.CaseId LIMIT 1];
                        if(String.isEmpty(ticket.FailureAreaValue__c) || String.isEmpty(ticket.FailureAreaDetailValue__c) || String.isEmpty(ticket.FailurePhenomenonValue__c)){
        
                            String error = System.Label.DNS_E_EnterTicketFailureInfo;
                            result.isSuccess = false;
                            result.message = error;
        
                        }
                    }
                }
            }

            if (result.isSuccess) {
                wo.Worker__c = technicianId;
                wo.ServiceTerritoryId = workcenterId;
        
                update wo;
            }

        } catch (Exception e) {
            result.isSuccess = false;
            result.message = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
        }
        return result;
    }

    // Service Resource의 현재상태 Picklist값 가져오는 메서드
    private static Map<String, String> getCurrentStatusType() {

        Schema.DescribeSObjectResult schemaReady        = Schema.getGlobalDescribe().get('ServiceResource').getDescribe();
        Map<String, Schema.SObjectField> schemaFieldMap = schemaReady.fields.getMap();

        Schema.sObjectField token           = schemaFieldMap.get('CurrentStatus__c');
        List<Schema.PicklistEntry> Entries  = token.getDescribe().getPicklistValues();
        
        Map<String, String> resuorceTypeMap = new Map<String, String>();

        for (Schema.PicklistEntry entry : Entries) {
            resuorceTypeMap.put(entry.getValue(), entry.getLabel());
        }

        return resuorceTypeMap;
    }

    // 서비스요원
    public class Technician {

        @AuraEnabled public String id               {get; set;}
        @AuraEnabled public String sapId            {get; set;}
        @AuraEnabled public String name             {get; set;}
        @AuraEnabled public String phone            {get; set;}
        @AuraEnabled public String topWorkcenter    {get; set;}
        @AuraEnabled public String workcenter       {get; set;}
        @AuraEnabled public String workcenterId     {get; set;}
        @AuraEnabled public String location         {get; set;}
        @AuraEnabled public String status           {get; set;}
        @AuraEnabled public Decimal lat             {get; set;}
        @AuraEnabled public Decimal lng             {get; set;}
        @AuraEnabled public String imageSrc         {get; set;}
        @AuraEnabled public Decimal distance        {get; set;}
        @AuraEnabled public String reportTime       {get; set;}

        public Technician() {

        }
    }

    public class ResultWrapper {
        
        @AuraEnabled public Boolean isSuccess   {get; set;}
        @AuraEnabled public String  message     {get; set;}

        public ResultWrapper() {
            this.isSuccess = true;
            this.message = '';
        }
    }
}