public with sharing class DN_RFQ_RejectController {

    @AuraEnabled
    public static string currentStatus(String recordId){
        
        try {
            List<PS__c> statusCheck = 
            [
                SELECT
                    Id,
                    Status__c
                FROM
                    PS__c
                WHERE
                    Id =: recordId
            ];

            List<User> roleCheck = 
            [
                SELECT
                    Id,
                    UserRole.PortalRole
                FROM
                    USER
                WHERE
                    Id =: UserInfo.getUserId()
            ];
            if(!roleCheck.isEmpty()){
                if(roleCheck[0].UserRole.PortalRole != 'Manager'){
                    return System.Label.DNS_M_RFQManager;
                }
            }

            if(statusCheck[0].Status__c != 'SEReceipt' && statusCheck[0].Status__c != 'SalesConfirm'){
                return System.Label.DNS_M_RFQRejectError;
            }else {
                return 'SUCCESS';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String rfqRejct(String recordId, String rejectReason, String rejectType){
        try {
            List<PS__c> rejectUpdate = 
            [
                SELECT 
                    Id,
                    Name,
                    Status__c,
                    RejecType__c,
                    RejectReason__c,
                    Opportunity__r.Opportunity_Owner__c //해당 딜러
                FROM
                    PS__c
                WHERE
                    Id =: recordId
            ];
            System.debug('rejectType : ' + rejectType);
            if(rejectUpdate.size() > 0) {
                if(rejectType == 'Reject'){
                    PS__c reqUpdate = new PS__c();
                    reqUpdate.Id = rejectUpdate[0].Id;
                    reqUpdate.Status__c = 'RequestToReview';
                    reqUpdate.RejectReason__c = rejectReason;
                    reqUpdate.RejecType__c = rejectType;
                    reqUpdate.AERejectDate__c = Date.today();
                    update reqUpdate;
                    
                    //딜러에게 Noti 로직 추가
                }else if(rejectType == 'Discard'){
                    PS__c reqUpdate = new PS__c();
                    reqUpdate.Id = rejectUpdate[0].Id;
                    reqUpdate.Status__c = 'Rejected';
                    reqUpdate.RejectReason__c = rejectReason;
                    reqUpdate.RejecType__c = rejectType;
                    update reqUpdate;
                    //딜러에게 Noti 로직 추가

                }
                
                //Noti는 국내 -> 딜러, 지사장에게   글로벌 -> 글로벌영업 담당자에게    => 해당 레코드의 매니저에게 보내면됨
 
                // List<User> getEmail = [SELECT Id, Email, Manager.Id, Manager.Email FROM User WHERE Id =: rejectUpdate[0].Opportunity__r.Opportunity_Owner__c];
                Set<Id> ownerId = new Set<Id>();
                ownerId.add(rejectUpdate[0].Opportunity__r.Opportunity_Owner__c);
                List<User> getEmail =  DN_WithoutSharingClass.getUserEmails(ownerId);
                String lang;
                String type;
                List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners']; // FIXME : Partners 맞는지 확인 후 수정
                String instanceUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login') + '/s/ps/' + rejectUpdate[0].Id;
                if(getEmail[0].LanguageLocaleKey == 'ko'){
                    lang = 'ko';
                    if(rejectType == 'Reject'){
                        type = '반려';
                    }else {
                        type = '기각';
                    }
                }else{
                    lang = 'en';
                    type = rejectType;
                }
                List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'PS Reject Alert'];
                Id alertId;

                if(!am.isEmpty()){
                    alertId = am[0].Id;
                }else{
                    alertId = 'a0xF7000009v4JTIAY';
                }
                UTIL_Alert.HistoryWrapper wrapEmail = new UTIL_Alert.HistoryWrapper();
                    wrapEmail.alertID            = alertId;
                    wrapEmail.targetID           = rejectUpdate[0].Id;
                    wrapEmail.alertType          = 'Email';
                    wrapEmail.receiverforEmail   = new List<String>{getEmail[0].Email, getEmail[0].Manager.Email};
                    // wrapEmail.receiverforEmail   = new List<String>{'sejin.kwon@dncompany.com'};
                    wrapEmail.alertLanguage      = lang;
                    wrapEmail.elementList        = new List<String>{type, instanceUrl};

                UTIL_Alert.HistoryWrapper wrapNoti = new UTIL_Alert.HistoryWrapper();
                    wrapNoti.alertID            = alertId;
                    wrapNoti.targetID           = rejectUpdate[0].Id;
                    wrapNoti.alertType          = 'Notification';
                    wrapNoti.receiverforID      = new Set<Id>{rejectUpdate[0].Opportunity__r.Opportunity_Owner__c, getEmail[0].Manager.Id};
                    wrapNoti.alertLanguage      = lang;
                    wrapNoti.elementList        = new List<String>{rejectUpdate[0].Name, type};

                UTIL_Alert.runAlertEvent(new List<UTIL_Alert.HistoryWrapper>{wrapEmail,wrapNoti});
                return 'SUCCESS';

            }
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

//PS I/F
// private static void callRFQInterfqce(String recordId, String rejectType){
//     List<PS__C> psList = 
//     [
//         SELECT
//             Id,
//             ERPInquiryNo__c,
//             Version__c,
//             LastModifiedDate,
//             RequiredDelivryDate__c,
//             ResponsibleBranch__c,
//             Owner.Name,
//             AEUser__r.Name,
//             CustomerName__c,
//             Opportunity__r.Owner.Account.CustomerCode__c,
//             PartsforMachining__c,
//             ProductionVolumeYearly__c,
//             WorkingHoursDaily__c,
//             WorkingDaysMonthly__c,
//             OperationRate__c,
//             CycleTimeRequired__c,
//             CustomerRequirement__c,
//             CustomerEmail__c,
//             CustomerMobileNo__c,
//             InquirySeq__c,
//             AEUser__r.CustomerCode__c
//         FROM
//             PS__c
//         WHERE
//             Id =: recordId
//     ];
//     PS__c ps = psList[0];
            
//     DateTime now = DateTime.now();
//     String formattedDate = now.format('yyyyMMddHHmmss');
//     // String I_RFQ_ACCEPT_DATE = ps.LastModifiedDate.format('yyyyMMddHHmmss');
//     // String I_REVIEW_REQUEST_DATE = String.valueOf(ps.RequiredDelivryDate__c).replace('-','');

//     String I_INQUIRY_NO = ps.ERPInquiryNo__c;
//     String I_VERSION = String.valueOf(ps.Version__c);
//     String I_RFQ_ACCEPT_DATE = String.valueOf(ps.LastModifiedDate.format('yyyyMMddHHmmss'));
//     String I_REVIEW_REQUEST_DATE = String.valueOf(ps.RequiredDelivryDate__c).replace('-','');
//     String I_BRANCH_NAME = ps.ResponsibleBranch__c;
//     String I_SALES_PERSON = ps.Owner.Name;
//     String I_SE_PERSON = ps.AEUser__r.Name;
//     String I_CUSTOMER_COMPANY = ps.CustomerName__c;
//     String I_DEALER_CODE = ps.Opportunity__r.Owner.Account.CustomerCode__c;
//     String I_PRODUCT_NAME = ps.PartsforMachining__c;
//     String I_OUTPUT = String.valueOf(ps.ProductionVolumeYearly__c);
//     String I_WORKING_HOURS = String.valueOf(ps.WorkingHoursDaily__c);
//     String I_DUTY_DAY = String.valueOf(ps.WorkingDaysMonthly__c);
//     String I_OPERATION_RATE = String.valueOf(ps.OperationRate__c);
//     String I_CYCLE_IME_REQUEST = String.valueOf(ps.CycleTimeRequired__c);
//     String I_REMARK = ps.CustomerRequirement__c;
//     String I_EMAIL = ps.CustomerEmail__c;
//     String I_TEL = ps.CustomerMobileNo__c;
//     String I_WRITER = ps.Owner.Name;
//     String I_IF_DATE = formattedDate;
//     String I_INQUIRY_SEQ = ps.InquirySeq__c;
//     String I_INQUIRY_DATE = formattedDate;
//     String I_SE_PERSON_NO = ps.AEUser__r.CustomerCode__c;
//     String i_STATUS;
//     if(rejectType == '반려'){
//         i_STATUS = '-99';
//     }else if(rejectType == '기각'){
//         i_STATUS = '-7';
//     }
//     String I_ADDRESS = 'TEST ADDRESS';
    
//     IF_AEPortal_PS_Classes.IF_OPTY_013_Req req = new IF_AEPortal_PS_Classes.IF_OPTY_013_Req();

//         List<IF_AEPortal_PS_Classes.IF_OPTY_013_Req_TB_MTS_PROP_IF> TB_MTS_PROP_IF_List = new List<IF_AEPortal_PS_Classes.IF_OPTY_013_Req_TB_MTS_PROP_IF>();

//         IF_AEPortal_PS_Classes.IF_OPTY_013_Req_TB_MTS_PROP_IF TB_MTS_PROP_IF = new IF_AEPortal_PS_Classes.IF_OPTY_013_Req_TB_MTS_PROP_IF();

//         TB_MTS_PROP_IF.I_INQUIRY_NO             = I_INQUIRY_NO;
//         TB_MTS_PROP_IF.I_VERSION                = I_VERSION;
//         TB_MTS_PROP_IF.I_RFQ_ACCEPT_DATE        = I_RFQ_ACCEPT_DATE;
//         TB_MTS_PROP_IF.I_REVIEW_REQUEST_DATE    = I_REVIEW_REQUEST_DATE;
//         TB_MTS_PROP_IF.I_BRANCH_NAME            = I_BRANCH_NAME;
//         TB_MTS_PROP_IF.I_SALES_PERSON           = I_SALES_PERSON;
//         TB_MTS_PROP_IF.I_SE_PERSON              = I_SE_PERSON;
//         TB_MTS_PROP_IF.I_CUSTOMER_COMPANY       = I_CUSTOMER_COMPANY;
//         TB_MTS_PROP_IF.I_DEALER_CODE            = I_DEALER_CODE;
//         TB_MTS_PROP_IF.I_PRODUCT_NAME           = I_PRODUCT_NAME;
//         TB_MTS_PROP_IF.I_OUTPUT                 = I_OUTPUT;
//         TB_MTS_PROP_IF.I_WORKING_HOURS          = I_WORKING_HOURS;
//         TB_MTS_PROP_IF.I_DUTY_DAY               = I_DUTY_DAY;
//         TB_MTS_PROP_IF.I_OPERATION_RATE         = I_OPERATION_RATE;
//         TB_MTS_PROP_IF.I_CYCLE_IME_REQUEST      = I_CYCLE_IME_REQUEST;
//         TB_MTS_PROP_IF.I_REMARK                 = I_REMARK;
//         TB_MTS_PROP_IF.I_EMAIL                  = I_EMAIL;
//         TB_MTS_PROP_IF.I_TEL                    = I_TEL;
//         TB_MTS_PROP_IF.I_WRITER                 = I_WRITER;
//         TB_MTS_PROP_IF.I_IF_DATE                = I_IF_DATE;
//         TB_MTS_PROP_IF.I_INQUIRY_SEQ            = I_INQUIRY_SEQ;
//         TB_MTS_PROP_IF.I_INQUIRY_DATE           = I_INQUIRY_DATE;
//         TB_MTS_PROP_IF.I_SE_PERSON_NO           = I_SE_PERSON_NO;
//         TB_MTS_PROP_IF.i_STATUS                 = i_STATUS;
//         TB_MTS_PROP_IF.I_ADDRESS                = I_ADDRESS;

//         TB_MTS_PROP_IF_List.add(TB_MTS_PROP_IF);

//         req.TB_MTS_PROP_IF = TB_MTS_PROP_IF_List;

//         IF_AEPortal_PS instance = new IF_AEPortal_PS();
//         IF_AEPortal_PS_Classes.IF_OPTY_013_Res response = instance.IF_OPTY_013(req);
//         System.debug('response : ' + response);
    
//     }
// public static void dummy() {
//     Integer i = 0;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
    
// }

}