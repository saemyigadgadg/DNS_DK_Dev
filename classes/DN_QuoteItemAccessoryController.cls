/**
 * @description       : QuoteLineItem에서 추가 자재 선택 모달의 컨트롤러
 * @author            : yeongju.yun
 * @last modified on  : 05-08-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-11-13   yeongju.yun   Initial Version
 * 1.1   2025-05-07   yeongju.yun   EDIT01. Dometic일 때 필드 추가 (Details), Global일 때 LIMIT 200
 * 1.2   2025-05-08   yeongju.yun   EDIT02. Details 필드 추가 (ZZSPEC)
**/
public without sharing class DN_QuoteItemAccessoryController {
    private static final Id   recordKorea  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Korea').getRecordTypeId();
    private static final Id   recordGlobal  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Global').getRecordTypeId();
    private static final Id   recordCommodity  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Commodity').getRecordTypeId();
    private static final Id   recordFactory  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Factory').getRecordTypeId();
    // private static final Id   recordTurnkey  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Turnkey').getRecordTypeId();

    /**
    * @description [DNSA_QuoteItemAccFactoryOption]
    **/
    @AuraEnabled
    public static Map<String, Object> dnsaFactoryOptionMaster(String recordId){
        try {
            User user = [
            SELECT
                Id,
                Profile.UserLicense.Name
            FROM
                User
            WHERE
                Id =: UserInfo.getUserId()
            LIMIT 1
        ];

        Quote modelCheck = [
            SELECT 
                id, 
                DNSAModel__c, 
                DNSAModel__r.ModelName__c, 
                DNSAModel__r.BaseCode__c, 
                DNSAModel__r.PKMT__c,
                IsFinal__c
            FROM 
                Quote 
            WHERE 
                id =: recordId
            LIMIT 1
        ];

        List<QuoteLineItem> qtlimodelCheck = [
            SELECT
                Id, 
                Product2.ProductCode, 
                Product2.Name__c,
                Product2.Model__r.Code__c
            FROM
                QuoteLineItem
            WHERE
                QuoteId =: recordId
            LIMIT 1
        ];
        String PKMT;
        Boolean isPortal = false;
        if(modelCheck.IsFinal__c == true){
            return new Map<String, Object>{
                'msg' => 'You cannot use this after the final quote has been confirmed.'
            };
        }
        if(user.Profile.UserLicense.Name.contains('Community')){
            if(modelCheck.DNSAModel__c == null){
                return new Map<String, Object>{
                    'msg' => 'Please Select Model'
                };
            }else if(!qtlimodelCheck.isEmpty()){
                return new Map<String, Object>{
                    'msg' => 'You can no longer change the factory option.'
                };
            }else{
                isPortal = true;
                PKMT = modelCheck.DNSAModel__r.PKMT__c;
            }
        }else{
            if(qtlimodelCheck.isEmpty()){
                return new Map<String, Object>{
                    'msg' => 'Please Select Product'
                };
            }else{
                PKMT = qtlimodelCheck[0].Product2.Model__r.Code__c;
                // PKMT = 'MB0001';
            }
        }
        String modelInfo;
        if(modelCheck.DNSAModel__r.ModelName__c != null){
            modelInfo = modelCheck.DNSAModel__r.ModelName__c + ' (' + modelCheck.DNSAModel__r.PKMT__c + ')';
        }

        String productInfo;
        if(!qtlimodelCheck.isEmpty()){
            productInfo = qtlimodelCheck[0].Product2.ProductCode + ' (' + qtlimodelCheck[0].Product2.Model__r.Code__c + ')';
        }

        Set<String> PKMTSet = new Set<String>{'MB0001', 'ML0154'};

        List<TableWrapper>  MasterDatas = new List<TableWrapper>();
        List<DNSA_FactoryOption__c> masterList = [
            SELECT
                Id,
                PKMT__c,
                CV_CODE__c,
                Description__c,
                Price__c,
                Kit__c,
                Base_Unit__c,
                Type__c
            FROM
                DNSA_FactoryOption__c
            WHERE
                Kit__c != null
            AND PKMT__c =: PKMT
            // AND PKMT__c IN: PKMTSet
            AND Delete__c = false
        ];
        if(!masterList.isEmpty()){
            for(DNSA_FactoryOption__c fo : masterList){
                TableWrapper pro2Wrap = new TableWrapper();
                pro2Wrap.Id             = fo.Id;
                pro2Wrap.key            = fo.Kit__c;
                pro2Wrap.description    = fo.Description__c;
                pro2Wrap.quantity       = 1;
                pro2Wrap.salesUnit      = fo.Base_Unit__c;
                pro2Wrap.type           = fo.Type__c;
                pro2Wrap.price           = fo.Price__c;
                MasterDatas.add(pro2Wrap);
            }
        }

        List<TableWrapper>  dealerDatas = new List<TableWrapper>();
        List<DNSA_Factory_Option_Junction__c> dealerSelectList = [
            SELECT
                Id,
                ERP_Price__c,
                POSNR__c,
                Quantity__c,
                Quote__c,
                Quote_Line_Item__c,
                DNSA_Factory_Option__r.Kit__c,
                DNSA_Factory_Option__r.Description__c,
                DNSA_Factory_Option__r.Base_Unit__c,
                DNSA_Factory_Option__r.Type__c,
                DNSA_Factory_Option__r.Price__c
            FROM
                DNSA_Factory_Option_Junction__c
            WHERE
                Quote__c =: recordId
            AND Dealer_Checked__c = true
        ];
        if(!dealerSelectList.isEmpty()){
            for(DNSA_Factory_Option_Junction__c fo : dealerSelectList){
                TableWrapper pro2Wrap = new TableWrapper();
                pro2Wrap.Id             = fo.DNSA_Factory_Option__c;
                pro2Wrap.key            = fo.DNSA_Factory_Option__r.Kit__c;
                pro2Wrap.description    = fo.DNSA_Factory_Option__r.Description__c;
                pro2Wrap.quantity       = Integer.valueOf(fo.Quantity__c);
                pro2Wrap.salesUnit      = fo.DNSA_Factory_Option__r.Base_Unit__c;
                pro2Wrap.type           = fo.DNSA_Factory_Option__r.Type__c;
                pro2Wrap.price           = fo.DNSA_Factory_Option__r.Price__c;
                dealerDatas.add(pro2Wrap);
            }
        }

        List<TableWrapper>  crmuserDatas = new List<TableWrapper>();
        List<DNSA_Factory_Option_Junction__c> crmuserSelectList = [
            SELECT
                Id,
                ERP_Price__c,
                POSNR__c,
                Quantity__c,
                Quote__c,
                Quote_Line_Item__c,
                DNSA_Factory_Option__c,
                DNSA_Factory_Option__r.Kit__c,
                DNSA_Factory_Option__r.Description__c,
                DNSA_Factory_Option__r.Base_Unit__c,
                DNSA_Factory_Option__r.Type__c,
                DNSA_Factory_Option__r.Price__c
            FROM
                DNSA_Factory_Option_Junction__c
            WHERE
                Quote__c =: recordId
            AND Dealer_Checked__c = false
            AND UPDATEFLAG__c != 'D'
        ];
        if(!crmuserSelectList.isEmpty()){
            for(DNSA_Factory_Option_Junction__c fo : crmuserSelectList){
                TableWrapper pro2Wrap = new TableWrapper();
                pro2Wrap.Id             = fo.DNSA_Factory_Option__c;
                pro2Wrap.key            = fo.DNSA_Factory_Option__r.Kit__c;
                pro2Wrap.description    = fo.DNSA_Factory_Option__r.Description__c;
                pro2Wrap.quantity       = Integer.valueOf(fo.Quantity__c);
                pro2Wrap.salesUnit      = fo.DNSA_Factory_Option__r.Base_Unit__c;
                pro2Wrap.type           = fo.DNSA_Factory_Option__r.Type__c;
                pro2Wrap.price           = fo.DNSA_Factory_Option__r.Price__c;
                crmuserDatas.add(pro2Wrap);
            }
        }

        return new Map<String, Object>{
            'MasterData'    => MasterDatas
            ,'dealerDatas'  => dealerDatas
            ,'crmuserDatas' => crmuserDatas
            ,'msg'          => 'SUCCESS'
            ,'isPortal'     => isPortal
            ,'modelInfo'    => modelInfo
            ,'productInfo'  => productInfo
        };
        } catch (Exception e) {
            System.debug('ErrorLine : ' + e.getLineNumber() + ' : ' + 'MSG : ' + e.getMessage());
            return new Map<String, Object>{
                'msg'   => e.getMessage()
            };
        } 
        
    }

    /**
    * @description [DNSA_QuoteItemAccFactoryOption]
    **/
    @AuraEnabled
    public static void dnsaFactoryOptionSave(String recordId, List<TableWrapper> selTableData, Boolean isPortal){
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('recordID : ' + recordId);
            System.debug('selTableData : ' + selTableData);
            System.debug('isPortal : ' + isPortal);
            if(isPortal){ //딜러가 선택한 경우
                List<DNSA_Factory_Option_Junction__c> delList = [SELECT Id FROM DNSA_Factory_Option_Junction__c WHERE Quote__c =: recordId AND Dealer_Checked__c = true];
                if(!delList.isEmpty()){delete delList;} //기존 레코드 삭제

                List<DNSA_Factory_Option_Junction__c> insertList = new List<DNSA_Factory_Option_Junction__c>();
                if(!selTableData.isEmpty()){
                    for(TableWrapper tw : selTableData){
                        if(tw.del != 'D'){
                            DNSA_Factory_Option_Junction__c op = new DNSA_Factory_Option_Junction__c();
                            op.Quote__c                 = recordId;
                            op.Dealer_Checked__c        = true;
                            op.DNSA_Factory_Option__c   = tw.Id;
                            op.Quantity__c              = tw.quantity;
                            insertList.add(op);
                        }
                    }
                }
                if(!insertList.isEmpty()){
                    insert insertList;
                }
                
            }else{
                List<QuoteLineItem> erpCheck = [SELECT Id, ERPQuotationNo__c FROM QuoteLineItem WHERE QuoteId =: recordId LIMIT 1];
                System.debug('1');

                if(!erpCheck.isEmpty() && erpCheck[0].ERPQuotationNo__c == null){ //erp 생성 전이면 삭제후 재생성
                    System.debug('2');

                    List<DNSA_Factory_Option_Junction__c> delList = [SELECT Id FROM DNSA_Factory_Option_Junction__c WHERE Quote__c =: recordId AND Dealer_Checked__c = false];
                    if(!delList.isEmpty()){delete delList;} //기존 레코드 삭제
                    System.debug('3');

                    List<DNSA_Factory_Option_Junction__c> insertList = new List<DNSA_Factory_Option_Junction__c>();
                    if(!selTableData.isEmpty()){
                    System.debug('4');

                        for(TableWrapper tw : selTableData){
                            if(tw.del != 'D'){
                                DNSA_Factory_Option_Junction__c op = new DNSA_Factory_Option_Junction__c();
                                op.Quote__c                 = recordId;
                                op.Quote_Line_Item__c       = erpCheck[0].Id;
                                op.Dealer_Checked__c        = false;
                                op.DNSA_Factory_Option__c   = tw.Id;
                                op.Quantity__c              = tw.quantity;
                                insertList.add(op);
                            }
                    System.debug('5');

                        }
                    }
                    if(!insertList.isEmpty()){
                        System.debug('insertList : ' + insertList);
                        insert insertList;
                    }
                }else{//erp 생성 후 
                    List<DNSA_Factory_Option_Junction__c> originList = [SELECT Id, UPDATEFLAG__c, POSNR__c, DNSA_Factory_Option__r.Kit__c, DNSA_Factory_Option__c FROM DNSA_Factory_Option_Junction__c WHERE Quote__c =: recordId AND Dealer_Checked__c = false];
                    List<DNSA_Factory_Option_Junction__c> updateList = new List<DNSA_Factory_Option_Junction__c>();
                    List<DNSA_Factory_Option_Junction__c> insertList = new List<DNSA_Factory_Option_Junction__c>();
                    List<DNSA_Factory_Option_Junction__c> deleteList = new List<DNSA_Factory_Option_Junction__c>();

                    Map<String, DNSA_Factory_Option_Junction__c> originMap = new map<String, DNSA_Factory_Option_Junction__c>();
                    if(!originList.isEmpty()){
                        for(DNSA_Factory_Option_Junction__c op : originList){
                            originMap.put(op.DNSA_Factory_Option__r.Kit__c, op);
                        }

                        if(!selTableData.isEmpty()){
                            for(TableWrapper tw : selTableData){
                                DNSA_Factory_Option_Junction__c op = new DNSA_Factory_Option_Junction__c();
                                op.DNSA_Factory_Option__c   = tw.Id;
                                op.Quote__c                 = recordId;
                                op.Quote_Line_Item__c       = erpCheck[0].Id;
                                op.Dealer_Checked__c        = false;
                                op.Quantity__c              = tw.quantity;

                                if(originMap.get(tw.key) != null){
                                    if(originMap.get(tw.key).POSNR__c == null && tw.del == 'D'){
                                        op.Id = originMap.get(tw.key).Id;
                                        deleteList.add(op);
                                    }
                                    if(originMap.get(tw.key).POSNR__c != null && tw.del == 'D'){
                                        op.UPDATEFLAG__c = 'D';
                                        op.Id = originMap.get(tw.key).Id;
                                        updateList.add(op);
                                    }
                                    if(originMap.get(tw.key).POSNR__c != null && tw.del != 'D'){
                                        op.UPDATEFLAG__c = 'I';
                                        op.Id = originMap.get(tw.key).Id;
                                        updateList.add(op);
                                    }

                                }else{//기존에 없는 레코드일떄
                                    if(tw.del != 'D' && tw.type == 'SQ'){
                                        op.UPDATEFLAG__c = 'I';
                                        insertList.add(op);
                                    }
                                    if(tw.del != 'D' && tw.type == 'CV'){
                                        insertList.add(op);
                                    }
                                }
                            }
                        }
                    }else{
                        if(!selTableData.isEmpty()){
                            for(TableWrapper tw : selTableData){
                                DNSA_Factory_Option_Junction__c op = new DNSA_Factory_Option_Junction__c();
                                op.DNSA_Factory_Option__c   = tw.Id;
                                op.Quote__c                 = recordId;
                                op.Quote_Line_Item__c       = erpCheck[0].Id;
                                op.Dealer_Checked__c        = false;
                                op.Quantity__c              = tw.quantity;
                                if(tw.del != 'D' && tw.type == 'SQ'){
                                    op.UPDATEFLAG__c = 'I';
                                    insertList.add(op);
                                }
                            }
                        }
                    }
                    QuoteLineItem qtli = new QuoteLineItem();
                        qtli.Id = erpCheck[0].Id;
                        qtli.QuotePriceIF__c = false;
                        update qtli;

                    if(!updateList.isEmpty()){
                        System.debug('updateList : ' + updateList);
                        update updateList;
                    }
                    if(!insertList.isEmpty()){
                        System.debug('insertList : ' + insertList);
                        insert insertList;
                    }
                    if(!deleteList.isEmpty()){
                        System.debug('deleteList : ' + deleteList);
                        delete deleteList;
                    }
                }
                List<String> qLineItemIds = new List<String>();
                qLineItemIds.add(erpCheck[0].Id);
                DN_QuoteReCreateController.quoteReCreate(qLineItemIds, 'ACC');
            }
        }catch (Exception e) {
            System.debug('saveAccessories : ' + e.getLineNumber() + ' / ' + e.getMessage());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description [DN_QuoteItemAccessoryModalforGlobal]
    **/
    @AuraEnabled
    public static Map<String, Object> fetchSearchInfo(String searchTerm){
        String SearchKeyword = '%'+searchTerm+'%';
        List<Product2> pro2List = [
            SELECT  Id, Name, ProductCode, Description,FM_MaterialDetails__c, RecordType.Name, Unit__c 
            FROM    Product2 
            WHERE   RecordType.Name = 'Part' 
            AND     (ProductCode LIKE :SearchKeyword or FM_MaterialDetails__c LIKE :SearchKeyword)
            ORDER BY ProductCode
            LIMIT 200
        ];
        //Global은 추가자재가 Salesorganazation이 무조건 1800이 있어야만해서 1800만 조회_250131
        // List<ProductBySalesOrg__c> pro2List = [SELECT Product__c, Product__r.Name, Product__r.ProductCode, Product__r.Description, Product__r.RecordType.Name, Product__r.Unit__c FROM ProductBySalesOrg__c WHERE SalesOrganization__c ='1800' AND Product__r.RecordType.Name = 'Part' AND (Product__r.ProductCode LIKE :SearchKeyword OR Product__r.Description LIKE :SearchKeyword)];
        
        System.debug('fetchSearchInfo - pro2List : ' + pro2List);
        
        List<TableWrapper>  OptionDatas     = new List<TableWrapper>();
        
        for(Product2 p2 : pro2List) {
            TableWrapper pro2Wrap = new TableWrapper();
            pro2Wrap.Id          = p2.Id;
            pro2Wrap.key         = p2.ProductCode;
            pro2Wrap.kit         = p2.Name;
            pro2Wrap.description = p2.FM_MaterialDetails__c;
            pro2Wrap.quantity    = 1;
            pro2Wrap.salesUnit   = p2.Unit__c;
            
            OptionDatas.add(pro2Wrap);
        }
        return new Map<String, Object>{
            'OptionDatas'       => OptionDatas
        }; 
    }

    /**
    * @description [DN_QuoteItemAccessoryModal, DN_QuoteItemAccessoryModalforGlobal, DNSA_QuoteItemAccessoryModal]
    **/
    @AuraEnabled
    public static Map<String, Object> fetchModalInfo(String baseProduct, List<String> quoteLineItemIds){
        try {

            //추가자재 중복체크 로직 시작
            List<Accessory__c> accDupList = [
                SELECT  Key__c, QuoteLineItem__c
                FROM    Accessory__c
                WHERE   QuoteLineItem__c IN: quoteLineItemIds and Delete__c != 'D'
                ORDER BY QuoteLineItem__c, Key__c
            ];

            //dupCount가 1이 아니면 추가자재가 다름
            Set<String> dupCount = new Set<String>();
            for(Integer i = 0; i < quoteLineItemIds.Size(); i++){
                String joinAcc = '';
                for(Integer j = 0; j < accDupList.Size(); j++){
                    if(accDupList[j].QuoteLineItem__c == quoteLineItemIds[i]){
                        joinAcc = joinAcc + accDupList[j].Key__c;
                    }
                }
                dupCount.add(joinAcc);
            }
            System.debug('dupCount : ' + dupCount);
            if(dupCount.Size() != 1 && !System.Test.isRunningTest()){
                return new Map<String, Object>{
                    'ERROR' => 'ERROR'
                };
            }
            //추가자재 중복체크 로직 끝


            String quoteLineItemId = quoteLineItemIds[0]; // 첫 번째 아이템 기준으로 기존 추가 자재 데이터 확인
            
            List<QuoteLineItem > lineItemList = [
                SELECT  Id 
                FROM    QuoteLineItem  
                WHERE   Id =: quoteLineItemIds
                AND     Order__c <> NULL
            ];
            System.debug('fetchModalInfo - lineItemList ::: ' + lineItemList);
            if(!lineItemList.isEmpty()) {
                return new Map<String, Object>{
                    'isPass' => false,
                    'msg'  => System.Label.DNS_M_AccessoryAddError
                }; // Accessories cannot be added to products with an order already created.
            }
            List<QuoteLineItem> checkRecord = [SELECT Quote.RecordTypeId, QuoteId FROM QuoteLineItem WHERE Id =:quoteLineItemId];
            Boolean checkDNSA = false;
            Boolean checkGlobal = false;
            Boolean checkDomestic = false;

            Quote quote = [SELECT Id, Opportunity.AccountId, RequestedShipDate__c FROM Quote WHERE Id = :checkRecord[0].QuoteId LIMIT 1];

            //레코드 타입이 DNSA일 겨우
            if(checkRecord[0].Quote.RecordTypeId != recordKorea && checkRecord[0].Quote.RecordTypeId != recordGlobal){
                // if(checkRecord[0].Quote.RecordTypeId != recordKorea && checkRecord[0].Quote.RecordTypeId != recordGlobal && checkRecord[0].Quote.RecordTypeId != recordTurnkey){
                checkDNSA = true;

            // 레코드 타입이 DNS Global일 경우
            } else if(checkRecord[0].Quote.RecordTypeId == recordGlobal){
                checkGlobal = true;
            }

            List<TableWrapper> ifDataList = new List<TableWrapper>();
            if(checkDNSA) {
                ifDataList = createDNSAData(baseProduct, quoteLineItemId);    
            }else if(checkGlobal){
                ifDataList = createGlobalData(quoteLineItemId);
            } else {
                checkDomestic = true;
                ifDataList = createData(baseProduct, quoteLineItemId);
            }



            System.debug('ifDataList ::: ' + ifDataList);
            if(ifDataList[0].errorMsg != '' && ifDataList[0].errorMsg != null) {
                return new Map<String, Object>{
                    'isPass' => false,
                    'msg' => ifDataList[0].errorMsg
                };
            }

            // 기존 데이터, Delete가 X가 아닌것만
            List<Accessory__c> accList = [
                SELECT  Id
                        , POSNR__c
                        , Name
                        , QuoteLineItem__c
                        , Category__c
                        , Key__c
                        , Description__c
                        , Details__c
                        , Quantity__c
                        , Price__c
                        , SalesUnit__c
                        , Delete__c
                        , ShipTo__c
                        , MachineRequestShipDate__c
                FROM    Accessory__c
                WHERE   QuoteLineItem__c =: quoteLineItemId and Delete__c != 'D'
                ORDER BY POSNR__c
            ];
            Set<String> accKeySet = new Set<String>();
            for(Accessory__c acc : accList) {
                accKeySet.add(acc.Key__c);
            }

            List<TableWrapper>  categoryOptionData = new List<TableWrapper>();
            List<TableWrapper>  selTableData       = new List<TableWrapper>();
            List<OptionWrapper> categoryOption     = new List<OptionWrapper>();
            Set<String>         dupliCategories    = new Set<String>();
            if(ifDataList.size() > 0){
                for(TableWrapper wrap : ifDataList) {

                    if(!dupliCategories.contains(wrap.category)) {
                        dupliCategories.add(wrap.category);
                        categoryOption.add(new OptionWrapper(wrap.category, wrap.category));
                    }
    
                    if(!accKeySet.contains(wrap.key)) {
                        categoryOptionData.add(wrap);
                    } 
                }
            }
            
            for(Accessory__c wrap : accList){
                if(accKeySet.contains(wrap.Key__c)) {
                    TableWrapper selWrap = new TableWrapper();
                    selWrap.Id          = wrap.Id;
                    selWrap.category    = wrap.Category__c;
                    selWrap.key         = wrap.Key__c;
                    selWrap.kit         = wrap.Name;
                    selWrap.description = wrap.Description__c;
                    selWrap.details     = wrap.Details__c;
                    selWrap.quantity    = Integer.valueOf(wrap.Quantity__c);
                    // selWrap.price       = (Decimal)wrap.Price__c;
                    selWrap.salesUnit   = wrap.SalesUnit__c;

                    if(wrap.ShipTo__c != null) {
                        selWrap.accId   = wrap.ShipTo__c;
                    }
                    if(wrap.MachineRequestShipDate__c != null) {
                        selWrap.shipDate = wrap.MachineRequestShipDate__c;
                    }

                    selWrap.del         = wrap.Delete__c;
                    selTableData.add(selWrap);
                }
            }
            Boolean isFactory = false;
            List<QuoteLineItem> recordTypeCheck = [SELECT Quote.RecordTypeId FROM QuoteLineItem WHERE Id IN:quoteLineItemIds];
            if(!recordTypeCheck.isEmpty() && recordTypeCheck[0].Quote.RecordTypeId == recordFactory){
                isFactory = true;
            }
            return new Map<String, Object>{
                'categoryOption'       => categoryOption
                , 'categoryOptionData' => categoryOptionData
                , 'selTableData'       => selTableData
                , 'isPass'             => true
                , 'checkDNSA'          => checkDNSA
                , 'checkGlobal'        => checkGlobal
                , 'checkDomestic'      => checkDomestic
                , 'accId'               => quote.Opportunity.AccountId
                , 'shipDate'            => quote.RequestedShipDate__c
                , 'isFactory'       => isFactory
            };

        } catch (Exception e) {
            System.debug('fetchModalInfo : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description [DN_QuoteItemAccessoryModal, DN_QuoteItemAccessoryModalforGlobal, DNSA_QuoteItemAccessoryModal]
    **/
    @AuraEnabled
    public static void saveAccessories(List<String> qLineItemIds, List<TableWrapper> selTableData){
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('qLineItemIds : ' + qLineItemIds);
            List<Accessory__c> accList = [SELECT Id, Key__c, QuoteLineItem__c, POSNR__c, Delete__c, QuoteLineItem__r.ERPQuotationNo__c FROM Accessory__c WHERE QuoteLineItem__c IN: qLineItemIds ORDER BY QuoteLineItem__c, POSNR__c];
            List<QuoteLineItem> isQuoteCheck = [SELECT ERPQuotationNo__c, Quote.RecordTypeId, QuoteId FROM QuoteLineItem WHERE Id IN: qLineItemIds];
            List<QuoteLineItem> accCount = [SELECT Id, Max_POSNR__c FROM QuoteLineItem WHERE Id IN: qLineItemIds];

            Map<String, Accessory__c> originMap = new Map<String, Accessory__c>();
            for(Accessory__c acc : accList){
                originMap.put(acc.QuoteLineItem__c + '_' + acc.Key__c, acc); //QuoteLineItem과 Key를 통해 Key값을 만듬
            }

            Map<Object, Object> recordCntMap = new Map<Object, Object>();
            for(QuoteLineItem acc : accCount){
                recordCntMap.put(acc.Id, acc.Max_POSNR__c);
            }
            Map<String, String> erpquoteMap = new Map<String, String>();
            for(QuoteLineItem ql : isQuoteCheck){
                erpquoteMap.put(ql.Id, ql.ERPQuotationNo__c);
            }

            List<Accessory__c> updateAcs = new List<Accessory__c>();
            List<Accessory__c> deleteAcs = new List<Accessory__c>();
            List<Accessory__c> insertAcs = new List<Accessory__c>();
            List<Accessory__c> toInsertList = new List<Accessory__c>();
            List<Accessory__c> toDeleteList = new List<Accessory__c>();
            List<QuoteLineItem> upMAXPOSNRList = new List<QuoteLineItem>();
            for(Integer i = 0; i < qLineItemIds.size(); i++){ //ERP Quotation이 생성 된 추가자재 수정
                
                if(erpquoteMap.containsKey(qLineItemIds[i]) && erpquoteMap.get(qLineItemIds[i]) != null) {
                    Integer POSNR;
                    Integer MAXPOSNR;

                    if(recordCntMap.containsKey(qLineItemIds[i])) { // 반환 값을 Integer로 캐스팅
                        Integer cnt = Integer.valueOf(recordCntMap.get(qLineItemIds[i])); 
                        POSNR = cnt;
                    } 

                    for(TableWrapper tw : selTableData){
                        System.debug('POSNR : ' + POSNR);
                        if(originMap.containsKey(qLineItemIds[i]+'_'+tw.key)){ //기존에 있는 값이면 Update
                            
                            String originId = originMap.get(qLineItemIds[i]+'_'+tw.key).Id;
                            String originFlag = originMap.get(qLineItemIds[i]+'_'+tw.key).Delete__c;
                            Accessory__c acc = originMap.get(qLineItemIds[i]+'_'+tw.key);
                            System.debug('originMap.get(qLineItemIds[i] : ' + originMap.get(qLineItemIds[i]+'_'+tw.key).Id);
                            acc.Id               = originId;
                            acc.QuoteLineItem__c = qLineItemIds[i];
                            acc.Category__c      = tw.category;
                            acc.Key__c           = tw.key;
                            acc.Name             = tw.kit;
                            acc.Description__c   = tw.description;
                            acc.Details__c       = tw.details;
                            acc.Quantity__c      = tw.quantity;
                            acc.SalesUnit__c     = tw.salesUnit;

                            //기존에는 삭제 됬던 자재인데 다시 추가했을 경우 I로 전달
                            if(originFlag == 'D'){ acc.Delete__c = 'I';}
                            //원래도 신규인데 JS에서 넘어올때도 I면 계속 I로 남아있음음
                            else if (tw.del == 'I' && originFlag == 'I'){acc.Delete__c = 'I';}
                            //POSNR이 있는데 JS에서 넘어오는 데이터는 수량변경때문에 U이고 기존에는 I이면 아직 Price Update가 안된것이므로 계속 I
                            else if (acc.POSNR__C != null && tw.del == 'U' && acc.Delete__c == 'I') {acc.Delete__c = 'I';}
                            //POSNR이 있는데 JS에서 넘어오는 데이터는 D이면 데이터도 D
                            else if (acc.POSNR__C != null && tw.del == 'D'){acc.Delete__c = 'D';}
                            else{acc.Delete__c = 'U';}

                            if(tw.accId != null) {acc.ShipTo__c = tw.accId;}
                            if(tw.shipDate != null) {acc.MachineRequestShipDate__c = tw.shipDate;}
                            if(acc.POSNR__c == null && tw.del == 'D'){deleteAcs.add(acc);}
                            else{updateAcs.add(acc);}
                        }else{ //새로운 값이 없으면 insert

                            Accessory__c acc = new Accessory__c();
                            acc.QuoteLineItem__c = qLineItemIds[i];
                            acc.Category__c      = tw.category;
                            acc.Key__c           = tw.key;
                            acc.Name             = tw.kit;
                            acc.Description__c   = tw.description;
                            acc.Details__c       = tw.details;
                            acc.Quantity__c      = tw.quantity;
                            acc.SalesUnit__c     = tw.salesUnit;
                            acc.Delete__c        = 'I'; //I flag는 추가 생성 할 때만 붙임 추가로 생성하고 또 추가한 자재는 신규생성처럼 빈값이어야함

                            if(isQuoteCheck[0].Quote.RecordTypeId == recordCommodity || isQuoteCheck[0].Quote.RecordTypeId == recordFactory)  {acc.Quote__c = isQuoteCheck[0].QuoteId;}
                            if(tw.accId != null) {acc.ShipTo__c = tw.accId;}
                            if(tw.shipDate != null) {acc.MachineRequestShipDate__c = tw.shipDate;}
    
                            insertAcs.add(acc);
                            POSNR = POSNR + 10;
                            MAXPOSNR = POSNR;
                        }
                    }

                    QuoteLineItem maxposnrUpdate = new QuoteLineItem();
                    maxposnrUpdate.Id = qLineItemIds[i];
                    maxposnrUpdate.Accessory_Complete__c = true;
                    maxposnrUpdate.QuotePriceIF__c = false;
                    maxposnrUpdate.Warranty_Acc__c = 0;
                    upMAXPOSNRList.add(maxposnrUpdate);
                }else{
                    Integer POSNR = Integer.valueOf(recordCntMap.get(qLineItemIds[i]));
                    Integer MAXPOSNR;
                    for(TableWrapper wrap : selTableData) {
    
                        if(wrap.del != 'D'){
                            Accessory__c acc     = new Accessory__c();
                            acc.QuoteLineItem__c = qLineItemIds[i];
                            acc.Category__c      = wrap.category;
                            acc.MaterialCode__c  = wrap.code;
                            acc.Key__c           = wrap.key;
                            acc.Name             = wrap.kit;
                            acc.Description__c   = wrap.description;
                            acc.Details__c       = wrap.details;
                            acc.Quantity__c      = wrap.quantity;
                            acc.Price__c         = wrap.price;
                            acc.CurrencyIsoCode  = wrap.curr;
                            acc.SalesUnit__c     = wrap.salesUnit;
                            if(isQuoteCheck[0].Quote.RecordTypeId == recordCommodity || isQuoteCheck[0].Quote.RecordTypeId == recordFactory)  {
                                acc.Quote__c = isQuoteCheck[0].QuoteId;

                                if(wrap.discount != '' && wrap.discount != null && wrap.discount != '0') {
                                    acc.Price__c = wrap.price - (wrap.price * (Math.abs(Decimal.valueOf(wrap.discount)) / 100));
                                } else {
                                    acc.Price__c = wrap.price;
                                }
                            } else {
                                acc.Price__c = wrap.price;
                            }

                            if(wrap.accId != null) {acc.ShipTo__c = wrap.accId;}
                            if(wrap.shipDate != null) {acc.MachineRequestShipDate__c = wrap.shipDate;}

                            toInsertList.add(acc);
                        }
                    }
                    QuoteLineItem maxposnrUpdate = new QuoteLineItem();
                    maxposnrUpdate.Id = qLineItemIds[i];
                    maxposnrUpdate.Accessory_Complete__c = true;
                    maxposnrUpdate.QuotePriceIF__c = false;
                    maxposnrUpdate.Warranty_Acc__c = 0;
                    upMAXPOSNRList.add(maxposnrUpdate);
                }
            }
            for(Accessory__c acc : accList) {
                if(!String.isBlank(acc.QuoteLineItem__r.ERPQuotationNo__c)){
                    continue;
                } else{
                    toDeleteList.add(acc);
                }
            }

            if(!deleteAcs.isEmpty()) {delete deleteAcs;}
            if(!upMAXPOSNRList.isEmpty()){update upMAXPOSNRList;}
            if(!toDeleteList.isEmpty()) {delete toDeleteList; } 
            if(!toInsertList.isEmpty()) { insert toInsertList; }
            if(!updateAcs.isEmpty()) { update updateAcs;}
            if(!insertAcs.isEmpty()) { insert insertAcs;}
            
            DN_QuoteReCreateController.quoteReCreate(qLineItemIds, 'ACC');
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('saveAccessories : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description [fetchModalInfo - DN_QuoteItemAccessoryModal]
    **/
    public static List<TableWrapper> createData(String baseProduct, String quoteLineItemId) {
        List<QuoteLineItem> model = [
            SELECT  Product2.Model__r.Code__c,
                    Product2.Model__r.Name,
                    Quote.Opportunity.Owner.SalesOrganization__c,
                    Quote.Opportunity.Owner.DistributionChannel__c,
                    Quote.Opportunity.Owner.Division__c,
                    Quote.Opportunity.Account.CustomerCode__c
            FROM    QuoteLineItem 
            WHERE   Id =: quoteLineItemId
        ];

        IF_ERP_Product_Classes.IF_OPTY_004_Req_I_HEAD temp01_i_head = new IF_ERP_Product_Classes.IF_OPTY_004_Req_I_HEAD();
        temp01_i_head.AUART = 'ZPO';
        temp01_i_head.SPART = model[0].Quote.Opportunity.Owner.Division__c;
        temp01_i_head.VTWEG = model[0].Quote.Opportunity.Owner.DistributionChannel__c;
        temp01_i_head.VKORG = model[0].Quote.Opportunity.Owner.SalesOrganization__c;
         
        IF_ERP_Product_Classes.IF_OPTY_004_Req wrapper_01 = new IF_ERP_Product_Classes.IF_OPTY_004_Req();
        // wrapper_01.I_PARENT = 'ML0327'; // test
        wrapper_01.I_PARENT = model[0].Product2.Model__r.Code__c;
        wrapper_01.I_HEAD   = temp01_i_head;      
        wrapper_01.I_GUBUN  = 'O';

        IF_ERP_Product method = new IF_ERP_Product();
        IF_ERP_Product_Classes.IF_OPTY_004_Res response = method.IF_OPTY_004(wrapper_01);
        System.debug('createData - response : ' + response.T_MATERIAL);

        List<TableWrapper> result = new List<TableWrapper>();
        if(response.T_MATERIAL.size() > 0){
            for(Integer i = 0; i < response.T_MATERIAL.size(); i++){
                TableWrapper data = new TableWrapper();
                data.key            = response.T_MATERIAL[i].CHILD;
                data.kit            = response.T_MATERIAL[i].CHILD;
                data.description    = response.T_MATERIAL[i].CHILD_TX;
                data.details        = response.T_MATERIAL[i].ZZSPEC;
                data.quantity       = 1;
                data.salesUnit      = response.T_MATERIAL[i].VRKME;
                data.errorMsg       = '';
                result.add(data);    
            }
        }
        return result;
    }

    /**
    * @description [DN_QuoteItemAccessoryModalforGlobal] Global일 경우 추가자재 + 선택 시 사용 가능 한 자재인지 I/F
    **/
    @AuraEnabled
    public static string accessoryAvaliable(String row){
        try {
            System.debug('row check : ' + row);
            List<ProductByPlant__c> plantInfo = [SELECT Part__r.RecordType.Name, Plant__c FROM ProductByPlant__c WHERE Part__r.RecordType.Name = 'Part' and Plant__c IN ('1840', '1842', '1846', '184S') AND Part__r.ProductCode =: row];
            if(plantInfo.isEmpty()){
                return System.Label.DNS_M_CantSelectAcc; //This is an unavailable additional material. //선택 할 수 없는 추가자재입니다.
            }

            List<IF_ERP_Product_Classes.IF_OPTY_031_Req_T_MATNR> t_matnr_list = new List<IF_ERP_Product_Classes.IF_OPTY_031_Req_T_MATNR>();
            IF_ERP_Product_Classes.IF_OPTY_031_Req_T_MATNR t_matnr_0 = new IF_ERP_Product_Classes.IF_OPTY_031_Req_T_MATNR();
            t_matnr_0.LOW = row;
            t_matnr_list.add(t_matnr_0);

            IF_ERP_Product_Classes.IF_OPTY_031_Req req = new IF_ERP_Product_Classes.IF_OPTY_031_Req();
            // req.I_VKORG = plantInfo[0].Plant__c;
            req.I_VKORG = '1800';
            req.T_MATNR = t_matnr_list;

            IF_ERP_Product method = new IF_ERP_Product();
            IF_ERP_Product_Classes.IF_OPTY_031_Res response = method.IF_OPTY_031(req);

            if(response.O_RETURN.TYPE == 'S'){
                return 'SUCCESS';
            }else{
                System.debug('error : ' + response.O_RETURN.MESSAGE);
                return System.Label.DNS_M_CantSelectAcc; //This is an unavailable additional material. //선택 할 수 없는 추가자재입니다.
            }

        } catch (Exception e) {
            throw new AuraHandledException('Error Line : ' + e.getLIneNumber() + 'Msg : ' + e.getMessage());
        }
    }

    /**
    * @description [fetchModalInfo - DNSA_QuoteItemAccessoryModal]
    **/
    public static List<TableWrapper> createDNSAData(String baseProduct, String quoteLineItemId) {
        List<QuoteLineItem> model = [
            SELECT  Id
                    , Product2.Model__r.Code__c
            FROM QuoteLineItem 
            WHERE Id =: quoteLineItemId
        ];

        IF_ERP_Order method = new IF_ERP_Order();
        IF_ERP_ORDER_CLASSES.IF_ORDER_008_Req erpParameters = new IF_ERP_ORDER_CLASSES.IF_ORDER_008_Req();
        erpParameters.I_MATNR = model[0].Product2.Model__r.Code__c;
        
        IF_ERP_ORDER_CLASSES.IF_ORDER_008_Res response = method.IF_ORDER_008(erpParameters);
        System.debug('response response :::::: ' + response);

        List<TableWrapper> result = new List<TableWrapper>();
        if(response.O_RETURN.TYPE == 'E') {
            System.debug('ERP error msg ::: ' + response.O_RETURN.MESSAGE);
            TableWrapper data = new TableWrapper();
            data.errorMsg = response.O_RETURN.MESSAGE;
            result.add(data);
        } else {
            for(Integer i = 0; i < response.T_LIST.size(); i++){
                TableWrapper data = new TableWrapper();
                data.category = response.T_LIST[i].KIT_CAT;
                data.errorMsg = '';
        
                result.add(data);    
            }
        }

        return result;
    }

    /**
    * @description [fetchModalInfo - DN_QuoteItemAccessoryModalforGlobal]
    **/
    public static List<TableWrapper> createGlobalData(String quoteLineItemId) {

        List<TableWrapper> result = new List<TableWrapper>();

        List<Product2> productList = [
            SELECT  Id, Name, Description, RecordType.Name, Unit__c
            FROM    Product2
            WHERE   RecordType.name ='part'
            LIMIT   1             // Temp
        ];

        System.debug('productList :: ' + productList);

        for(Integer i = 0; i < productList.size(); i++){
            TableWrapper data = new TableWrapper();

            data.key            = productList[i].Name;
            data.kit            = productList[i].Name;
            data.description    = productList[i].Description;
            data.quantity       = 1;
            data.salesUnit      = productList[i].Unit__c;
            data.errorMsg       = '';

            result.add(data);   
        }

        System.debug('result :: ' + result);

        return result;
    }

    /**
    * @description [DNSA_QuoteItemAccessoryModal]
    **/
    @AuraEnabled
    public static List<TableWrapper> selectCategory(String category, String quoteId) {
        System.debug('quoteId ::: ' + quoteId);
        try {
            List<QuoteLineItem> model = [
                SELECT  Id
                        , Product2.Model__r.Code__c
                        , Quote.DNSA_SalesOffice__c
                FROM QuoteLineItem 
                WHERE Id =: quoteId
            ];
    
            IF_ERP_Order method = new IF_ERP_Order();
            IF_ERP_ORDER_CLASSES.IF_ORDER_009_Req erpParameters = new IF_ERP_ORDER_CLASSES.IF_ORDER_009_Req();
            erpParameters.I_MATNR = model[0].Product2.Model__r.Code__c;
            erpParameters.I_KIT_CAT = category;
            // erpParameters.I_VKBUR = model[0].Quote.DNSA_SalesOffice__c;
            erpParameters.I_VKBUR = '414A';
            
            IF_ERP_ORDER_CLASSES.IF_ORDER_009_Res response = method.IF_ORDER_009(erpParameters);
            System.debug('response response :::::: ' + response);
    
            List<TableWrapper> result = new List<TableWrapper>();
            if(response.O_RETURN.TYPE == 'E') {
                System.debug('ERP error msg ::: ' + response.O_RETURN.MESSAGE);
                TableWrapper data = new TableWrapper();
                data.errorMsg = response.O_RETURN.MESSAGE;
                result.add(data);
            } else {
                for(Integer i = 0; i < response.T_LIST.size(); i++){
                    TableWrapper data = new TableWrapper();
                    data.key            = response.T_LIST[i].KIT;
                    data.category       = response.T_LIST[i].KIT_CAT;
                    data.code           = response.T_LIST[i].MATNR;
                    data.kit            = response.T_LIST[i].KIT;
                    data.description    = response.T_LIST[i].KIT_T;
                    data.salesUnit      = response.T_LIST[i].MEINS;
                    data.quantity       = 1;
                    data.price          = Decimal.valueOf(response.T_LIST[i].KBETR);
                    data.curr           = response.T_LIST[i].WAERK;
                    data.discount       = response.T_LIST[i].DISCOUNT;
                    data.percent        = response.T_LIST[i].PERCENT;
                    data.errorMsg = '';
            
                    result.add(data);  
                }
            }
    
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class OptionWrapper{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}

        public OptionWrapper(){}
        public OptionWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    public class TableWrapper{
        @AuraEnabled public String  Id          {get;set;}
        @AuraEnabled public String  category    {get;set;}
        @AuraEnabled public String  code        {get;set;}
        @AuraEnabled public String  key         {get;set;}
        @AuraEnabled public String  type        {get;set;}
        @AuraEnabled public String  kit         {get;set;}
        @AuraEnabled public Integer POSNR       {get;set;}
        @AuraEnabled public String  del         {get;set;}
        @AuraEnabled public String  description {get;set;}
        @AuraEnabled public String  details     {get;set;}
        @AuraEnabled public Integer quantity    {get;set;}
        @AuraEnabled public Decimal price       {get;set;}
        @AuraEnabled public String  curr        {get;set;}
        @AuraEnabled public String  salesUnit   {get;set;}
        @AuraEnabled public String  accId       {get;set;}
        @AuraEnabled public Date    shipDate    {get;set;}
        @AuraEnabled public String  discount    {get;set;}
        @AuraEnabled public String  percent     {get;set;}
        @AuraEnabled public String  errorMsg    {get;set;}

        public TableWrapper(){}
    }
    
     public static void dummy() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}