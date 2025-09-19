/**
 * @test              : DN_OrderServiceTest
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-10-22   yeongju.yun   Initial Version
**/
public without sharing class DN_OrderService {
    public DN_OrderService(){}

    public final Boolean IS_USER = UserInfo.getUserType() == 'Standard'; // true : user, false : portal etc.
    public final List<String> ADMINS = new List<String>{'System Administrator', '시스템 관리자'};
    public final String QM = 'QualityTeam'; // UserRole.DeveloperName 
    public final String KA = '영업 KA';     // profile name
    public final String B_MANAGER = '영업 지사장'; // profile name
    public final String PORTAL_NAME = 'partners';

    // order record type
    public final String ORDER_TYPE_DNS     = 'DNS';
    public final String ORDER_TYPE_DNSA    = 'DNSA';
    public final String ORDER_TYPE_SERVICE = 'Service';

    // order status, Status
    public final String ORDER_CREATE         = 'Created'; // 생성
    public final String ORDER_APPROVED       = 'Approved'; // DNSA ONLY
    public final String ORDER_PROGRESS       = 'ConfirmationInProgress'; // 승인 진행중
    public final String ORDER_SUBMITTED      = 'Submitted'; // DNSA ONLY
    public final String ORDER_CONFIRMED_DNSA = 'OrderConfirmed'; // DNSA ONLY // 승인 완료
    public final String ORDER_CONFIRMED      = 'Confirmed'; // 승인 완료
    public final String ORDER_MAPPED         = 'OrderMapped'; // 주문 매핑 완료
    public final String ORDER_DELIVERY       = 'Delivery'; // 출하
    public final String ORDER_CANCELED       = 'Canceled'; // 취소
    public final String ORDER_Returned       = 'Returned'; // 반품
    public final List<String> UPTO_PROGRESS = new List<String>{'Created', 'InternalApproved', 'ConfirmationInProgress', 'Canceled', 'Returned'};
    public final List<String> UPTO_CONFRIRM = new List<String>{'Created', 'InternalApproved', 'ConfirmationInProgress', 'Confirmed'};

    // order approval status, ApprovalStatus__c
    public final String APPROVAL_NOTSTARTED         = 'NotStarted'; // 미진행
    public final String APPROVAL_INTERNALREQUESTED  = 'InternalApprovalRequested'; // 내부 승인 요청됨
    public final String APPROVAL_CONFIRMREQUESTED   = 'OrderConfirmRequested'; // 주문 승인 요청됨
    public final String APPROVAL_COMPLATED          = 'ApprovalComplated'; // 승인 완료
    public final String APPROVAL_REJECTED           = 'InternalApprovalRejected'; // 내부 승인 반려됨

    // order approval, step name, StepName__c
    public final String STEPNAME_INTERNAL = 'Internal';
    public final String STEPNAME_ERP      = 'ERP';

    // order approval, status, Status__c
    public final String APPROVALSTATUS_PENDING  = 'Pending';
    public final String APPROVALSTATUS_APPROVED = 'Approved';
    public final String APPROVALSTATUS_REJECTED = 'Rejected';

    // delivery status
    public final String DO_CREATED   = 'DOCreated';
    public final String DO_APPROVED  = 'DOInternalApproved';
    public final String DO_CONFIRMED = 'DOConfirmed';

    // delivery internal approval status
    public final String INTERNAL_NOTSTARTED = 'Not Started';
    public final String INTERNAL_PROCESSING = 'Processing';
    public final String INTERNAL_APPROVED   = 'Approved';

    // quote record type
    public final String DNSA_COMMODITY = 'DNSA_Commodity';
    public final String DNSA_FACTORY   = 'DNSA_Factory';

    // ticket status
    public final String TICKET_NEW    = 'New';
    public final String TICKET_REJECT = 'Reject';
    public final String TICKET_PORTAL = 'Dealer portal';
    public final List<String> TICKET_EDITABLE = new List<String>{'Reject'};

    // pricing
    public final String DISCOUNTTYPE01  = System.Label.DNS_F_WholesaleSupplyPrice; // 도매공급가 할인, Wholesale Supply Price Discount
    public final String DISCOUNTTYPE02  = System.Label.DNS_F_ConsignmentSupplyPrice; // 위탁공급가 할인, Consignment Supply Price Discount
    public final String DISCOUNTTYPE05  = System.Label.DNS_F_DirectSalesPrice; // 권장가 할인, Recommended price Discount
    public final Map<String, String> DISCOUNTPAYMENT = new Map<String, String>{
        'C006' => '5 ' + System.Label.DNS_F_Days // 일
        , 'C007' => '30 ' + + System.Label.DNS_F_Days
        , 'C008' => '45 ' + + System.Label.DNS_F_Days
        , 'C009' => '60 ' + + System.Label.DNS_F_Days
    };

    // preparation checklist
    public final String FILE_PREPARATIONCHECKLIST = 'PreparationChecklist';
    public final String FILE_ORDERNOTICE = 'OrderNotice';
    
    // delivery order files
    public final String FILE_BIZREG = 'bizReg';
    public final String FILE_MAP = 'map';
    public final String FILE_BOND = 'bond';

    // order item category
    public final String ITEM_PRODUCT = 'Product';
    public final String ITEM_SQ = 'SQ';
    public final String ITEM_ACCESSORY = 'Accessory';

    // product
    public final String PROD_RECORDTYPE = 'BaseCode';

    // order OrderSegmentation__c
    public final String SEG_CONSIGNMENT = 'Consignment';
    public final String SEG_WHOLESALE   = 'Wholesale';
    public final String SEG_DIRECTSALES = 'DirectSales';


    // order sales channel type
    public final String CHANNER_DOMESTIC        = 'Domestic';
    public final String CHANNER_DOMESTICPARTNER = 'DomesticPartner';
    public final String CHANNER_OVERSEAS        = 'Overseas';
    public final String CHANNER_DNSA            = 'DNSA';
    public final List<String> CHANNER_DOMESTIC_SET = new List<String>{CHANNER_DOMESTIC, CHANNER_DOMESTICPARTNER};


    /**
     * @description 주문의 Sales Channel 설정 (다건)
     * @param wrapList (List<ChannerWrapper>)
     * @return - Domestic(=Direct Sales), DomesticPartner(=Dealer), Overseas(=Dealer), DNSA 
    **/
    public Map<Id, String> setSalesChannel(List<ChannerWrapper> wrapList) {
        Map<Id, String> result = new Map<Id, String>();

        Set<String> userIdSet = new Set<String>();
        for(ChannerWrapper wrap : wrapList) {
            userIdSet.add(wrap.ownerId);
        }

        List<User> userList = [SELECT Id, UserType, Profile.Name FROM User WHERE Id =: userIdSet ];
        Map<Id, User> userMap = new Map<Id, User>(userList);

        for(ChannerWrapper wrap : wrapList) {
            User owner = userMap.get(wrap.ownerId);
            Boolean isGlobal = owner.Profile.Name.contains('글로벌');
            
            String channelType = CHANNER_DOMESTICPARTNER; // '20' && dealer
            if(wrap.isDNSA) { channelType = CHANNER_DNSA; }
            else if(isGlobal) { channelType = CHANNER_OVERSEAS; }
            else if(!isGlobal && owner.UserType == 'Standard') { channelType = CHANNER_DOMESTIC; }

            result.put(wrap.ownerId, channelType);
        }

        return result;
    }

    /**
    * @description 주문의 Sales Channel 설정 (단건)
    **/
    public String setSalesChannel(ChannerWrapper wrap) {
        
        User owner = [SELECT Id, UserType, Profile.Name FROM User WHERE Id =: wrap.ownerId ];
        Boolean isGlobal = owner.Profile.Name.contains('글로벌');
        
        String channelType = CHANNER_DOMESTICPARTNER; // '20' && dealer
        if(wrap.isDNSA) { channelType = CHANNER_DNSA; }
        else if(isGlobal) { channelType = CHANNER_OVERSEAS; }
        else if(!isGlobal && owner.UserType == 'Standard') { channelType = CHANNER_DOMESTIC; }

        return channelType;
    }

    /**
    * @description CRM User / Dealer 구분 (다건)
    * @param userIds 
    * @return Map<Id, Boolean> key : user id, value : true - user, false - portal etc.
    **/
    public Map<Id, Boolean> getUserFlag(Set<Id> userIds){
        Map<Id, Boolean> result = new Map<Id, Boolean>();

        List<User> uList = [SELECT Id, UserType FROM User WHERE IsActive = TRUE AND Id =: userIds];
        for(User u : uList) {
            result.put(u.Id, u.UserType == 'Standard');
        }

        return result;
    }
    
    /**
    * @description CRM User / Dealer 구분 (단건)
    * @param userType 
    * @return Boolean  value : true - user, false - portal etc.
    **/
    public Boolean getUserFlag(String userType) {
        return userType == 'Standard';
    }

    /**
    * @description 매너저 여부 (단건)
    * @param userId 
    * @return Boolean true - manager, false - worker
    **/
    public Boolean isManager(Id userId) {
        User u = [SELECT UserRole.PortalRole FROM User WHERE Id =:userId ];
        return u.UserRole.PortalRole == 'Manager';
    }
    /**
    * @description 매니저 여부 (다건)
    * @param userIds 
    * @return Boolean true - manager, false - worker
    **/
    public Map<Id, Boolean> isManager(Set<Id> userIds) {
        Map<Id, Boolean> result = new Map<Id, Boolean>();

        List<User> uList = [SELECT UserRole.PortalRole FROM User WHERE Id =:userIds ];
        for(User u : uList) {
            result.put(u.Id, u.UserRole.PortalRole == 'Manager');
        }
        return result;
    }

    /**
    * @description CRM / Portal URL Flag값으로 구분
    * @param isPortal true : portal, false : 내부 crm
    * @return String 
    **/
    public String getBaseUrl(Boolean isPortal){
        String result;

        if(isPortal) {
            List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = :PORTAL_NAME]; 
            result = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
        } else {
            result = URL.getOrgDomainUrl().toExternalForm();
        }
        return result;
    }

    /**
    * @description CRM / Portal URL 함께 반환
    * @return Map<String, String> key - portal, crm
    **/
    public Map<String, String> getBaseUrl(){
        List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = :PORTAL_NAME];

        return new Map<String, String>{
            'portal' => Network.getLoginUrl(portal[0].Id).removeEnd('/s/login')
            , 'crm'  => URL.getOrgDomainUrl().toExternalForm()
        };
    }
    
    /**
    * @description 어드민 여부 확인
    * @author yeongju.yun | 2024-11-11 
    * @return Boolean true = admin, false = not admin
    **/
    public Boolean getAdminFlag(){
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
        return ADMINS.contains(profileList[0].Name);
    }
    
    /**
    * @description 이름으로 Alert Manager ID 반환
    **/
    public Id getAlertManagerId(String managerName){
        List<AlertManager__c> managerList = [SELECT Id FROM AlertManager__c WHERE Name = :managerName LIMIT 1];
        return managerList[0].Id;
    }

    /**
    * @description language(en,ko), url(portal, crm), type(email, bell) 별로 alert history 생성
    * @author yeongju.yun | 2024-10-24 
    * @param manangerName 
    * @param alertType bell, email
    * @param objList 
    * @param targetUserMap 
    * @param refMap 
    * @return UTIL_Alert.ResultWrapper 
    **/
    public UTIL_Alert.ResultWrapper sendAlert(
        String manangerName
        , String alertType
        , List<SObject> objList
        , Map<String, Set<Id>> targetUserMap
        , Map<String, Object> refMap
    ){
        List<UTIL_Alert.HistoryWrapper> result = new List<UTIL_Alert.HistoryWrapper>();

        // common value
        Id managerId = getAlertManagerId(manangerName);
        Map<String, String> baseUrl = getBaseUrl();

        Set<Id> allUserSet = new Set<Id>();
        for(Set<Id> alluserIds : targetUserMap.values()) {
            allUserSet.addAll(alluserIds);
        }

        List<User> userList = [SELECT Id, Email, UserType, LanguageLocaleKey FROM User WHERE IsActive = TRUE AND Id =: allUserSet];
        Map<Id, User> userMap = new Map<Id, User>(userList);

        Boolean needURL = true;

        // reference
        Map<Id, String> accNameMap      = new Map<Id, String>();
        Map<Id, String> userNameMap     = new Map<Id, String>();
        Map<Id, String> nameMap         = new Map<Id, String>();
        Map<Id, String> recordMap       = new Map<Id, String>();
        Map<Id, Boolean> flagMap        = new Map<Id, Boolean>();
        Map<String, String> picklistMap = new Map<String, String>();
        List<String> eleList            = new List<String>();
        Map<Id, String> recordIdToComments = new Map<Id, String>(); // 추가: CommodityOrderApproved용 코멘트 맵

        if(manangerName == 'OrderKeyAccountCreated') {
            accNameMap  = (Map<Id, String>) refMap.get('accNameMap');
        } else if(manangerName == 'OrderStatusConfirmed') {
            userNameMap = (Map<Id, String>) refMap.get('userNameMap');
        } else if(manangerName == 'OrderCanceled') {
            userNameMap = (Map<Id, String>) refMap.get('userNameMap');
            picklistMap = (Map<String, String>) refMap.get('reasonMap');
        } else if(manangerName == 'InspectionCreation') {
            nameMap = (Map<Id, String>) refMap.get('ordNameMap');
        } else if(manangerName == 'InspectionConfirmed') {
            userNameMap = (Map<Id, String>) refMap.get('userNameMap');
        } else if(manangerName == 'PreparationChecklistEdited') {
            userNameMap = (Map<Id, String>) refMap.get('userNameMap');
            nameMap     = (Map<Id, String>) refMap.get('preNameMap');
        } else if(manangerName == 'DeliveryOrderConfirmed') {
            userNameMap = (Map<Id, String>) refMap.get('userNameMap');
            nameMap     = (Map<Id, String>) refMap.get('ordNameMap');
            flagMap     = (Map<Id, Boolean>) refMap.get('dnsFlag');
        } else if(manangerName == 'OrderRequestApproval') {
            accNameMap  = (Map<Id, String>) refMap.get('accNameMap');
            userNameMap = (Map<Id, String>) refMap.get('userNameMap');
            nameMap     = (Map<Id, String>) refMap.get('nameMap');
        } else if(manangerName == 'OrderInternalApproved' || manangerName == 'OrderInternalRejected') {
            userNameMap = (Map<Id, String>) refMap.get('userNameMap');
            nameMap     = (Map<Id, String>) refMap.get('nameMap');
        } else if(manangerName == 'DeliveryOrderInternalApproved' || manangerName == 'DeliveryOrderInternalRejected') {
            userNameMap = (Map<Id, String>) refMap.get('userNameMap');
            nameMap     = (Map<Id, String>) refMap.get('nameMap');
        } else if(manangerName == 'OrderChangeRequest') {
            picklistMap = (Map<String, String>) refMap.get('infoMap');
        } else if(manangerName == 'OrderRequestConfirm') {
            accNameMap  = (Map<Id, String>) refMap.get('accNameMap');
            picklistMap = (Map<String, String>) refMap.get('picklistMap');
            needURL = false;
        } else if(manangerName == 'RequestToUseCustomerAlert') {
            recordMap  = (Map<Id, String>) refMap.get('recordIdToWorkitems');
            userNameMap = (Map<Id, String>) refMap.get('userNameMap');
        } else if(manangerName == 'OrderRequestConfirmDNSA_F') {
            eleList = (List<String>) refMap.get('eleList');
            needURL = false;
        } else if(manangerName == 'CommodityOrderApprovalRequest') {
            recordMap  = (Map<Id, String>) refMap.get('recordIdToWorkitems');
            userNameMap = (Map<Id, String>) refMap.get('userNameMap');
            recordIdToComments = (Map<Id, String>) refMap.get('recordIdToComments');
        }

        // set history
        for(sObject record : objList) {

            UTIL_Alert.HistoryWrapper sample = new UTIL_Alert.HistoryWrapper();
            sample.alertID  = managerId;
            sample.targetID = record.Id;
            
            // yeongju.yun
            if(manangerName == 'OrderKeyAccountCreated') {
                sample.elementList.add(String.valueOf(record.get('OrderNumber')));
                sample.elementList.add(accNameMap.get(String.valueOf(record.get('AccountId'))));
            } else if(manangerName == 'OrderStatusConfirmed') {
                sample.elementList.add(String.valueOf(record.get('OrderNumber')));
                sample.elementList.add(userNameMap.get(String.valueOf(record.get('OwnerId'))));
                sample.elementList.add(String.valueOf(record.get('ERPOrderNo__c')));
            } else if(manangerName == 'OrderCanceled') {
                sample.elementList.add(userNameMap.get(String.valueOf(record.get('OwnerId'))));
                sample.elementList.add(String.valueOf(record.get('OrderNumber')));
                sample.elementList.add(picklistMap.get(String.valueOf(record.get('CancelReason__c'))));

                String erpOrderNo = record.get('ERPOrderNo__c') == null ? '' : String.valueOf(record.get('ERPOrderNo__c'));
                sample.elementList.add(erpOrderNo);
            } else if(manangerName == 'InspectionCreation') {
                sample.elementList.add(String.valueOf(record.get('FM_CompanyName__c')));
                sample.elementList.add(nameMap.get(String.valueOf(record.get('Order__c'))));
                sample.elementList.add(String.valueOf(record.get('Name')));
            } else if(manangerName == 'InspectionConfirmed') {
                sample.elementList.add(String.valueOf(record.get('FM_CompanyName__c')));
                sample.elementList.add(userNameMap.get(String.valueOf(record.get('Order__c'))));
                sample.elementList.add(String.valueOf(record.get('Name')));
                sample.elementList.add(String.valueOf(record.get('Start_Date_of_Visit__c')));
                sample.elementList.add(String.valueOf(record.get('End_Date_of_Visit__c')));
            } else if(manangerName == 'PreparationChecklistEdited') {
                sample.elementList.add(userNameMap.get(String.valueOf(record.get('OwnerId'))));
                sample.elementList.add(nameMap.get(String.valueOf(record.get('PreparationChecklist__c'))));
                sample.elementList.add(String.valueOf(record.get('CaseNumber')));
            } else if(manangerName == 'DeliveryOrderConfirmed') {
                Boolean isDNS = flagMap.get(String.valueOf(record.get('Order__c')));
                sample.elementList.add(userNameMap.get(String.valueOf(record.get('OwnerId'))));
                sample.elementList.add(String.valueOf(record.get('Name')));
                String tempSerial = record.get('SerialNumber__c') == null ? '' : String.valueOf(record.get('SerialNumber__c'));
                String serialNum = isDNS ? tempSerial : '';
                sample.elementList.add(serialNum);
                sample.elementList.add(nameMap.get(String.valueOf(record.get('Order__c'))));
                String templateStyle = isDNS ? '' : 'style="display:none;"';
                sample.elementList.add(templateStyle);
            } else if(manangerName == 'DeliveyOrderERPSent') {
                sample.elementList.add(String.valueOf(record.get('Name')));
            } else if(manangerName == 'DeliveryOrderERPFail') {
                sample.elementList.add(String.valueOf(record.get('Name')));
            } else if(manangerName == 'OrderRequestApproval') {
                sample.elementList.add(String.valueOf(record.get('OrderNumber')));
                sample.elementList.add(accNameMap.get(String.valueOf(record.get('SoldTo__c'))));
                sample.elementList.add(accNameMap.get(String.valueOf(record.get('ShipTo__c'))));
                sample.elementList.add(userNameMap.get(String.valueOf(record.get('Id'))));
                sample.elementList.add(nameMap.get(String.valueOf(record.get('Id'))));
            } else if(manangerName == 'OrderInternalApproved' || manangerName == 'OrderInternalRejected') {
                sample.elementList.add(String.valueOf(record.get('OrderNumber')));
                sample.elementList.add(userNameMap.get(String.valueOf(record.get('Id'))));
                sample.elementList.add(nameMap.get(String.valueOf(record.get('Id'))));
            } else if(manangerName == 'DeliveryOrderInternalApproved' || manangerName == 'DeliveryOrderInternalRejected') {
                sample.elementList.add(String.valueOf(record.get('Name')));
                sample.elementList.add(userNameMap.get(String.valueOf(record.get('Id'))));
                sample.elementList.add(nameMap.get(String.valueOf(record.get('Id'))));
            } else if(manangerName == 'OrderChangeRequest') {
                sample.elementList.add(picklistMap.get('OrderNumber'));
                sample.elementList.add(picklistMap.get('Requester'));
                sample.elementList.add(picklistMap.get('Reason'));
                sample.elementList.add(picklistMap.get('ERPOrderNo'));
                sample.elementList.add(picklistMap.get('Detail'));
            } else if(manangerName == 'OrderRequestConfirm') {
                sample.elementList.add(String.valueOf(record.get('OrderNumber')));
                sample.elementList.add(String.valueOf(record.get('ERPOrderNo__c')));
                sample.elementList.add(accNameMap.get(String.valueOf(record.get('SoldTo__c'))));
                sample.elementList.add(accNameMap.get(String.valueOf(record.get('ShipTo__c'))));

                sample.elementList.add(picklistMap.get('Style01'));
                sample.elementList.add(picklistMap.get('Style02'));

                if(picklistMap.get('isGlobal') == 'TRUE') {
                    sample.elementList.add(picklistMap.get('productPrice'));
                    sample.elementList.add(picklistMap.get('cvTotal'));
                    sample.elementList.add(picklistMap.get('sqTotal'));
                    sample.elementList.add(picklistMap.get('accTotal'));
                    sample.elementList.add(picklistMap.get('listPrice'));
                    sample.elementList.add(picklistMap.get('dcPercent'));
                    sample.elementList.add(picklistMap.get('dcPrice'));
                    sample.elementList.add(picklistMap.get('netPrice'));
                    sample.elementList.add(picklistMap.get('adjPrice'));
                    sample.elementList.add(picklistMap.get('netAdjPrice'));
                    sample.elementList.add(picklistMap.get('warrPrice'));
                    sample.elementList.add(picklistMap.get('qPrice'));
                }
            } else if(manangerName == 'OrderRequestConfirmDNSA_F') {
                sample.elementList.addAll(eleList);
            } else if(manangerName == 'OrderERPFail') {
                sample.elementList.add(String.valueOf(record.get('OrderNumber')));
            } else if(manangerName == 'OrderERPFailSupport') {
                sample.elementList.add(String.valueOf(record.get('OrderNumber')));
                sample.elementList.add(String.valueOf(record.get('IF_ERROR__c')));
            } else if(manangerName == 'DeliveryOrderERPFailSupport') {
                sample.elementList.add(String.valueOf(record.get('Name')));
                sample.elementList.add(String.valueOf(record.get('IF_ERROR__c')));
            } 
            
            
            
            
            // Yuhyun Park
            else if(manangerName == 'DealerSalesGoalOwnerUpdateAlert') {
                // 2024-10-28 Yuhyun Park : alertOwnerUpdate(DealerSalesGoal)
                sample.elementList.add(String.valueOf(record.get('Year__c')));
            } else if(manangerName == 'DealerBonusOwnerUpdateAlert') {
                // 2024-12-07 Yuhyun Park : alertOwnerUpdate(DealerBonus)
                sample.elementList.add(String.valueOf(record.get('Year__c')));
                sample.elementList.add(String.valueOf(record.get('Month__c')));
            } else if(manangerName == 'SalesPlanTargetReminder'){
                // 2025-01-23 Yuhyun Park : SalesPlanTargetReminder(DealerSalesPlan Target)
                sample.elementList.add(String.valueOf(record.get('FM_Year__c')));
                sample.elementList.add(String.valueOf(record.get('Month__c')));
            } else if(manangerName == 'RequestToUseCustomerAlert'){
                // 2025-04-03 Yuhyun Park : Request To Use Cutomer for Portal User
                sample.elementList.add(String.valueOf(record.get('FM_TargetAccountName__c')));              
                sample.elementList.add(String.valueOf(record.get('FM_TargetAccountRepresentative__c')));
                sample.elementList.add(String.valueOf(record.get('FM_TargetAccountCustomerCode__c')));
                sample.elementList.add(userNameMap.get(String.valueOf(record.get('CreatedById'))));
                sample.elementList.add(String.valueOf(record.get('RequestReason__c')));
                sample.elementList.add(baseUrl.get('crm') + '/' + recordMap.get(String.valueOf(record.get('Id'))));
            } 
            
            
            
            
            // hanyeong.choi
            else if(manangerName == 'CommodityOrderApprovalRequest') {
                sample.elementList.add(userNameMap.get(String.valueOf(record.get('CreatedById')))); // {0}: CRM Order Number
                sample.elementList.add(recordIdToComments.get(record.Id) != null ? recordIdToComments.get(record.Id) : ''); // {2}: Comments from Manager
                sample.elementList.add(baseUrl.get('crm') + '/' + String.valueOf(record.get('Id'))); // {3}: CRM URL

                sample.elementList.add(record.getSObject('SoldTo__r') != null ? String.valueOf(record.getSObject('SoldTo__r').get('Name')) : '');
                sample.elementList.add(record.getSObject('ShipTo__r') != null ? String.valueOf(record.getSObject('ShipTo__r').get('Name')) : '');

                sample.elementList.add(String.valueOf(record.get('OrderNumber'))); // {0}: CRM Order Number
                sample.elementList.add(String.valueOf(record.get('PurchaseOrderNo__c'))); // {0}: CRM Order Number
                sample.elementList.add(String.valueOf(record.get('PaymentTerms_DNSA__c'))); // {1}: Customer PO
                sample.elementList.add(String.valueOf(record.get('CurrencyIsoCode'))); // {0}: CRM Order NumberId')))); // {3}: CRM URL
                sample.elementList.add(String.valueOf(record.get('MachinePartsWarranty__c'))); // {0}: CRM Order Number
                sample.elementList.add(String.valueOf(record.get('ExtWarranty__c'))); // {1}: Customer PO
                sample.elementList.add(String.valueOf(record.get('DiscountfromSalesAvailabilityList__c'))); // {0}: CRM Order Number
                sample.elementList.add(String.valueOf(record.get('PromotionalPackage__c'))); // {0}: CRM Order Number
                sample.elementList.add(String.valueOf(record.get('ProfitMarginSubsidyPlan__c'))); // {0}: CRM Order Number
                sample.elementList.add(String.valueOf(record.get('OtherDiscount__c'))); // {0}: CRM Order Number
                sample.elementList.add(String.valueOf(record.get('ServiceReimbursement__c'))); // {0}: CRM Order Number
                sample.elementList.add(String.valueOf(record.get('ServiceReimbursementPrice__c'))); // {0}: CRM Order Number
                sample.elementList.add(String.valueOf(record.get('TotalAmount'))); // {0}: CRM Order Number
            }


            String targetRecord = String.valueOf(record.Id);

            if(!targetUserMap.containsKey(targetRecord)) continue;
            Set<Id> targetUserIds = targetUserMap.get(targetRecord);

            // User 
            Map<Id, String> userEnCRM    = new Map<Id, String>(); // key : user id, value : user email
            Map<Id, String> userEnPortal = new Map<Id, String>(); // key : user id, value : user email
            Map<Id, String> userKoCRM    = new Map<Id, String>(); // key : user id, value : user email
            Map<Id, String> userKoPortal = new Map<Id, String>(); // key : user id, value : user email
            for(Id userId : targetUserIds) {
                if(!userMap.containsKey(userId)) continue;
                User u = userMap.get(userId);

                if(getUserFlag(u.UserType)) {
                    if(u.LanguageLocaleKey == 'ko') {
                        userKoCRM.put(u.Id, u.Email);
                    } else {
                        userEnCRM.put(u.Id, u.Email);
                    }
                } else {
                    if(u.LanguageLocaleKey == 'ko') {
                        userKoPortal.put(u.Id, u.Email);
                    } else {
                        userEnPortal.put(u.Id, u.Email);
                    }
                }
            }

            if(alertType == 'bell') {
                sample.alertType = 'Notification';

                if(!userEnCRM.isEmpty()) {
                    UTIL_Alert.HistoryWrapper copyHistory = sample.clone();
                    copyHistory.alertLanguage = 'en';
                    copyHistory.receiverforID = userEnCRM.keySet();
                    result.add(copyHistory);
                }
    
                if(!userEnPortal.isEmpty()) {
                    UTIL_Alert.HistoryWrapper copyHistory = sample.clone();
                    copyHistory.alertLanguage = 'en';
                    copyHistory.receiverforID = userEnPortal.keySet();
                    result.add(copyHistory);
                }
    
                if(!userKoCRM.isEmpty()) {
                    UTIL_Alert.HistoryWrapper copyHistory = sample.clone();
                    copyHistory.alertLanguage = 'ko';
                    copyHistory.receiverforID = userKoCRM.keySet();
                    result.add(copyHistory);
                }
    
                if(!userKoPortal.isEmpty()) {
                    UTIL_Alert.HistoryWrapper copyHistory = sample.clone();
                    copyHistory.alertLanguage = 'ko';
                    copyHistory.receiverforID = userKoPortal.keySet();
                    result.add(copyHistory);
                }
            } else {
                sample.alertType = 'Email';

                if(!userEnCRM.isEmpty()) {
                    if(needURL) sample.elementList.add(baseUrl.get('crm') + '/' + record.Id);

                    UTIL_Alert.HistoryWrapper copyHistory = sample.clone();
                    copyHistory.alertLanguage = 'en';
                    copyHistory.receiverforEmail = userEnCRM.values();
                    result.add(copyHistory);
                }
                
                if(!userEnPortal.isEmpty()) {
                    if(needURL) sample.elementList.add(baseUrl.get('portal') + '/' + record.Id);

                    UTIL_Alert.HistoryWrapper copyHistory = sample.clone();
                    copyHistory.alertLanguage = 'en';
                    copyHistory.receiverforEmail = userEnPortal.values();
                    result.add(copyHistory);
                }
    
                if(!userKoCRM.isEmpty()) {
                    if(needURL) sample.elementList.add(baseUrl.get('crm') + '/' + record.Id);

                    UTIL_Alert.HistoryWrapper copyHistory = sample.clone();
                    copyHistory.alertLanguage = 'ko';
                    copyHistory.receiverforEmail = userKoCRM.values();
                    result.add(copyHistory);
                }
    
                if(!userKoPortal.isEmpty()) {
                    if(needURL) sample.elementList.add(baseUrl.get('portal') + '/' + record.Id);
    
                    UTIL_Alert.HistoryWrapper copyHistory = sample.clone();
                    copyHistory.alertLanguage = 'ko';
                    copyHistory.receiverforEmail = userKoPortal.values();
                    result.add(copyHistory);
                }
            }
        }

        if(!result.isEmpty()) {
            UTIL_Alert.ResultWrapper rWrap = UTIL_Alert.runAlertEvent(result);
            return rWrap;
        } else {
            return null;
        }
    }

    /**
    * @description Picklist(API) 반환
    * @author yeongju.yun | 2024-10-25 
    * @param objName    object api name
    * @param fieldName  field api name
    * @return List<String> 
    **/
    public List<String> getPicklist(String objName, String fieldName){
        List<String> result = new List<String>();
        
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();

        for(Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
            if(pickListVal.isActive()) { result.add(pickListVal.getValue()); }
        }
        return result;
    }

    /**
    * @description Picklist(Label & API) 반환
    * @author yeongju.yun | 2024-10-30 
    * @param objName    object api name
    * @param fieldName  field api name
    * @return Map<String, String> key : picklist api name, value : label
    **/
    public Map<String, String> getPicklistMap(String objName, String fieldName){
        Map<String, String> result = new Map<String, String>();
        
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();

        for(Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
            if(pickListVal.isActive()) { result.put(pickListVal.getValue(), pickListVal.getLabel()); }
        }
        return result;
    }

    /**
    * @description Picklist(Label & API) Wrapper로 반환
    * @author yeongju.yun | 2024-11-08 
    * @param objName    object api name
    * @param fieldName  field api name
    * @return List<OptionWrapper> 
    **/
    public List<OptionWrapper> getPicklistWrap(String objName, String fieldName){
        List<OptionWrapper> result = new List<OptionWrapper>();

        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();

        for(Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
            if(pickListVal.isActive()) { 
                OptionWrapper wrap = new OptionWrapper();
                wrap.label         = pickListVal.getLabel();
                wrap.value         = pickListVal.getValue();
                result.add(wrap);
            }
        }
        return result;
    }

    /**
    * @description Picklist API명으로 Label명 반환
    * @author yeongju.yun | 2024-12-10 
    * @param objName    object api name
    * @param fieldName  field api name
    * @param apiValue   picklist api name
    * @return String 
    **/
    public String getPicklistLabel(String objName, String fieldName, String apiValue) {
        String fieldLabel = '';

        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult describeSObject = sObjectType.getDescribe();
        Schema.DescribeFieldResult fieldResult = describeSObject.fields.getMap().get(fieldName).getDescribe();

        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.getValue() == apiValue) {
                fieldLabel = entry.getLabel();
                break;
            }
        }

        return fieldLabel;
    }

    /**
    * @description 필드와 필수 필드 전달 시 필드 정보 반환
    * @author yeongju.yun | 2024-11-08 
    * @param objName        object api name
    * @param targetFields   field api names
    * @param requiredFields
    * @return List<FieldWrapper>
    DN_OrderService ordSvc = new DN_OrderService();
    ordSvc.getFieldInfo(
        'DeliveryOrder__c'
        , new List<String>{'DestinationZone__c', 'CapitalNo__c', 'ActualGIDate__c', 'Note__c'}
        , new List<String>{'DestinationZone__c', 'CapitalNo__c', 'ActualGIDate__c', 'Note__c'}
        );
    **/
    public List<FieldWrapper> getFieldInfo(String objName, List<String> targetFields, List<String> requiredFields){
        List<FieldWrapper> result = new List<FieldWrapper>();

        Map<Integer, FieldWrapper> tempMap = new Map<Integer, FieldWrapper>();
        SObjectType type = Schema.getGlobalDescribe().get(objName);
        Map<String,Schema.SObjectField> sFields = type.getDescribe().fields.getMap();
        for(String f : sFields.keySet()){
            Schema.DescribeFieldResult dfr = sFields.get(f).getDescribe();
            if(targetFields.contains(dfr.getName())) {
                FieldWrapper wrap = new FieldWrapper();
                wrap.label        = dfr.getLabel();
                wrap.apiName      = dfr.getName();
                wrap.type         = String.valueOf(dfr.getType());
                wrap.isRequired   = requiredFields.contains(wrap.apiName);
                
                if(wrap.type == 'PICKLIST') {

                    List<OptionWrapper> options = new List<OptionWrapper>();
                    for(Schema.PicklistEntry pickListVal : dfr.getPicklistValues()){
                        if(pickListVal.isActive()) { 
                            OptionWrapper optionWrap = new OptionWrapper();
                            optionWrap.label         = pickListVal.getLabel();
                            optionWrap.value         = pickListVal.getValue();
                            options.add(optionWrap);
                        }
                    }
                    wrap.options = options;
                }

                tempMap.put(targetFields.indexOf(wrap.apiName), wrap);
            }
        }
        
        List<Integer> sortList = new List<Integer>(tempMap.keySet());
        sortList.sort();

        for(Integer order : sortList) {
            result.add(tempMap.get(order));
        }
        System.debug('getFieldInfo - ' + objName + ' ::: ' + result);
        return result;
    }

    /**
    * @description UserId 기준으로 Account찾기
                    user가 dealer일 때 user의 accountid
                    user가 sales일 때 user의 sales office와 동일한 dns direct accountid
    * @author yeongju.yun | 2024-11-06 
    * @param userIds 
    * @return Map<Id, Id> 
    **/
    public Map<Id, Id> getRelatedAccounts(Set<Id> userIds){
        Map<Id, Id> result = new Map<Id, Id>();

        Map<Id, Boolean> userFlagMap = getUserFlag(userIds);

        Set<Id> toGetDirectSet = new Set<Id>();
        Set<Id> toGetAccSet    = new Set<Id>();

        for(Id userId : userFlagMap.keySet()) {
            if(userFlagMap.get(userId)) { toGetDirectSet.add(userId); }
            else { toGetAccSet.add(userId); }
        }

        if(!toGetDirectSet.isEmpty()) {
            List<User> userList = [ SELECT Id, SalesOffice__c, SalesOrganization__c FROM User  WHERE   Id = :toGetDirectSet ];

            Set<String> officeSet = new Set<String>();
            Set<String> orgSet    = new Set<String>();
            for(User u : userList) {
                officeSet.add(u.SalesOffice__c);
                orgSet.add(u.SalesOrganization__c);
            }

            List<Account> accList = [
                SELECT  Id, Name, SalesOffice__c, SalesOrganization__c
                FROM    Account 
                WHERE   IsDNSDirectAccount__c = true 
                AND     SalesOffice__c =: officeSet
            ];

            for(User u : userList) {
                for(Account acc : accList) {
                    if(u.SalesOffice__c != acc.SalesOffice__c) continue;

                    result.put(u.Id, acc.Id);
                }
            }
        }

        if(!toGetAccSet.isEmpty()) {
            List<User> userList = [ SELECT Id, AccountId, Account.Name FROM User  WHERE   Id = :toGetAccSet ];
            for(User u : userList) {
                result.put(u.Id, u.AccountId);
            }
        }

        return result;
    }

    /**
    * @description User Id로 User명 조회
    * @param userIds 
    * @return Map<Id, String> key : user id, value : user name
    **/
    public Map<Id, String> getUserNameMap(Set<Id> userIds) {
        Map<Id, String> userNameMap = new Map<Id, String>();

        List<User> userList = [SELECT Id, Name FROM User WHERE IsActive = TRUE AND Id =: userIds];
        for(User u : userList) {
            userNameMap.put(u.Id, u.Name);
        }

        return userNameMap;
    }

    /**
    * @description 텍스트 앞에 0 추가
    * @param totalLength 
    * @param baseStr 
    * @return String 
    DN_OrderService ordSvc = new DN_OrderService();
    System.debug('formatCodeForSAP : ' + ordSvc.formatCodeForSAP(10, '1124140'));
    **/
    public String formatCodeForSAP(Integer totalLength, String baseStr){
        if(totalLength == null || String.isBlank(baseStr)) return baseStr;
        return baseStr.leftPad(totalLength, '0');
    }

    /**
    * @description 텍스트 앞에 0 제외
    **/
    public String formatCodeForSAP(String baseStr) {
        if(String.isBlank(baseStr)) return baseStr;
        return baseStr.replaceFirst('^0+', '');
    }

    /**
    * @description Date을 정의 된 형태로 변경
    * @param dateValue 
    * @return String 
    DN_OrderService ordSvc = new DN_OrderService();
    System.debug('formatDateForSAP : ' + ordSvc.formatDateForSAP(Date.today()));
    **/
    public String formatDateForSAP(Date dateValue, Boolean isSeparated) {
        if(dateValue == null) return'';

        String year  = dateValue.year() + '';
        String month = dateValue.month() < 10 ? '0' + dateValue.month() : dateValue.month() + '';
        String day   = dateValue.day() < 10 ? '0' + dateValue.day() : dateValue.day() + '';

        String result = isSeparated ? year + '-' + month + '-' + day : year + month + day;

        return result;
    }

    /**
    * @description Datetime을 정의 된 형태로 변경
    * @param datetimeValue 
    * @return Map<String, String> 
    DN_OrderService ordSvc = new DN_OrderService();
    System.debug('formatDateTimeForSAP : ' + ordSvc.formatDateTimeForSAP(DateTime.now()));
    **/
    public Map<String, String> formatDateTimeForSAP(Datetime datetimeValue, Boolean isSeparated) {
        if (datetimeValue == null) return new Map<String,String>{'date'=>'', 'time'=>''};

        Date datePart = datetimeValue.date();
        Time timePart = datetimeValue.time();

        String hour   = timePart.hour() < 10 ? '0' + timePart.hour() : timePart.hour() + '';
        String minute = timePart.minute() < 10 ? '0' + timePart.minute() : timePart.minute() + '';
        String second = timePart.second() < 10 ? '0' + timePart.second() : timePart.second() + '';

        return new Map<String, String>{
            'date'   => formatDateForSAP(datePart, isSeparated)
            , 'time' => hour + ':' + minute + ':' + second
        };
    }

    /**
    * @description Picklist > Component Option 변환 Wrapper
    **/
    public class OptionWrapper{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}

        public OptionWrapper(){}
    }

    /**
    * @description 파일 정보 Wrapper
    **/
    public class FieldWrapper{
        @AuraEnabled public String  label      {get;set;}
        @AuraEnabled public String  apiName    {get;set;}
        @AuraEnabled public String  type       {get;set;}
        @AuraEnabled public Boolean isRequired {get;set;}

        @AuraEnabled public List<OptionWrapper> options {get;set;}

        public FieldWrapper(){}
    }

    /**
    * @description Sales Channel Param Wrapper
    **/
    public class ChannerWrapper{
        @AuraEnabled public String ownerId {get;set;}
        @AuraEnabled public Boolean isDNSA {get;set;}

        public ChannerWrapper(){}
        public ChannerWrapper(String ownerId, Boolean isDNSA){
            this.ownerId  = ownerId;
            this.isDNSA   = isDNSA;
        }
    }

    /**
    * @description DNSA Order Appoval 기반 알림 발송
    **/
    @future
    public static void sendApprovalNotificationAsync(Set<Id> approvalIds) {
        List<Order> target = [
            SELECT  Id
                    , DNSA_SalesOffice__c
                    , OrderNumber
                    , PurchaseOrderNo__c
                    , CreatedBy.Name
                    , SoldTo__r.Name
                    , ShipTo__r.Name
                    , PaymentTerms_DNSA__c
                    , CurrencyIsoCode
                    , MachinePartsWarranty__c
                    , ExtWarranty__c
                    , DiscountfromSalesAvailabilityList__c
                    , PromotionalPackage__c
                    , ProfitMarginSubsidyPlan__c
                    , OtherDiscount__c
                    , ServiceReimbursement__c
                    , ServiceReimbursementPrice__c
                    , TotalAmount
            FROM Order 
            WHERE Id IN :approvalIds
        ];
        
        DN_OrderService ordSvc = new DN_OrderService();
        Set<Id> createdUser = new Set<Id>();
        List<ProcessInstance> piList = [
            SELECT Id, TargetObjectId 
            FROM ProcessInstance 
            WHERE TargetObjectId IN :approvalIds
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Map<Id, Id> processInstanceToRecordMap = new Map<Id, Id>();
        if(!piList.isEmpty()) {
            for(ProcessInstance pi : piList) {
                processInstanceToRecordMap.put(pi.Id, pi.TargetObjectId);
            }

            // ProcessInstanceStep 조회
            List<ProcessInstanceStep> steps = [
                SELECT ProcessInstance.TargetObjectId, ActorId, Actor.Name, Comments
                FROM ProcessInstanceStep
                WHERE ProcessInstanceId IN :processInstanceToRecordMap.keySet()
                AND StepStatus = 'Started'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            // 최신 코멘트 매핑
            Map<Id, String> recordIdToComments = new Map<Id, String>();
            for(ProcessInstanceStep step : steps) {
                Id recordId = processInstanceToRecordMap.get(step.ProcessInstanceId);
                if(recordId != null && !recordIdToComments.containsKey(recordId)) {
                    recordIdToComments.put(recordId, step.Comments != null ? step.Comments : '');
                }
            }

            List<ProcessInstanceWorkitem> workItems = [
                SELECT Id, ProcessInstanceId, OriginalActorId, CreatedById 
                FROM ProcessInstanceWorkitem 
                WHERE ProcessInstanceId IN :processInstanceToRecordMap.keySet()
            ];

            Map<String, Object> recordIdToWorkitems = new Map<String, Object>();
            Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();

            if(!workItems.isEmpty()) {
                for(ProcessInstanceWorkitem workItem : workItems) {
                    Id actorId = workItem.OriginalActorId;
                    createdUser.add(workItem.CreatedById);
    
                    Id recordId = processInstanceToRecordMap.get(workItem.ProcessInstanceId);
                    Set<Id> innerSet = targetUserMap.containsKey(recordId) ? targetUserMap.get(recordId) : new Set<Id>();
    
                    if(recordId != null) {
                        String key = String.valueOf(recordId);
                        if(!recordIdToWorkitems.containsKey(key)) {
                            recordIdToWorkitems.put(key, new List<ProcessInstanceWorkitem>());
                        }
                        ((List<ProcessInstanceWorkitem>)recordIdToWorkitems.get(key)).add(workItem);
                    }    
    
                    if (actorId.getSObjectType() == Group.sObjectType) {
                        List<GroupMember> groupMembers = [
                            SELECT UserOrGroupId
                            FROM GroupMember
                            WHERE GroupId = :actorId
                        ];
    
                        if(!groupMembers.isEmpty()) {
                            for(GroupMember gm : groupMembers) {
                                innerSet.add(gm.UserOrGroupId);
                            }
                        }
                    } else {
                        innerSet.add(actorId);
                    }
                    targetUserMap.put(recordId, innerSet);
                }
            }

            if(!createdUser.isEmpty()) {
                Map<Id, User> createdUserMap = new Map<Id, User>([
                    SELECT Id, Name 
                    FROM User 
                    WHERE Id IN :createdUser
                ]);
    
                Map<Id, String> userNameMap = new Map<Id, String>();
                for (Id userId : createdUserMap.keySet()) {
                    userNameMap.put(userId, createdUserMap.get(userId).Name);
                }
    
                Map<Id, String> recordMapForSend = new Map<Id, String>();
                for(String key : recordIdToWorkitems.keySet()){
                    Id recId = (Id) key;
                    List<ProcessInstanceWorkitem> wiList = (List<ProcessInstanceWorkitem>) recordIdToWorkitems.get(key);
                    String value = (wiList != null && !wiList.isEmpty()) ? String.valueOf(wiList[0].Id) : '';
                    recordMapForSend.put(recId, value);
                }
    
                if(!targetUserMap.isEmpty()){
                    UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                        'CommodityOrderApprovalRequest',
                        'email',
                        target,
                        targetUserMap,
                        new Map<String, Object>{
                            'recordIdToWorkitems' => recordMapForSend, 
                            'userNameMap' => userNameMap,
                            'recordIdToComments' => recordIdToComments
                        }
                    );
                    if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { 
                        target[0].addError(emailAlertResult.errMessage); 
                    }
                }
            }
        }
    }
}