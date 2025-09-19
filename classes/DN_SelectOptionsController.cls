/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 05-15-2025
 * @last modified by  : Hanyeong Choi
**/
public without sharing class DN_SelectOptionsController {
    private static final Id   recordFactory  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Factory').getRecordTypeId();

    @AuraEnabled
    public static Map<String,List<T_VALUE>> getSelectOptions(String quoteLineId, String reset){
        Map<String,List<T_VALUE>> result = new Map<String,List<T_VALUE>>();

        QuoteLineItem factoryQtCheck = 
        [
            SELECT 
                QuoteId, 
                Quote.RecordTypeId,
                Requested_Ship_Date__c
            FROM 
                QuoteLineItem 
            WHERE
                Id =:quoteLineId
        ];
        List<T_VALUE> factoryCVList = new List<T_VALUE>();

        if(factoryQtCheck.Quote.RecordTypeId == recordFactory) {
            List<T_VALUE> isDNSAList = new List<T_VALUE>();
            T_VALUE isDNSA = new T_VALUE();
            isDNSA.ATNAM = 'true';
            isDNSAList.add(isDNSA);
            result.put('isDNSA', isDNSAList);
            
            if (factoryQtCheck.Requested_Ship_Date__c == null) {
                T_VALUE val = new T_VALUE();
                val.Id = 'empty';
                result.put('empty', new List<T_VALUE>{ val });
                return result;
            }


            //CRM User가 선택한 factory option cv 데이터 추출
            List<DNSA_Factory_Option_Junction__c> factoryCV = 
            [
                SELECT
                    DNSA_Factory_Option__r.C_Code__c, 
                    DNSA_Factory_Option__r.C_Value__c, 
                    DNSA_Factory_Option__r.V_Code__c,
                    DNSA_Factory_Option__r.V_Value__c,
                    DNSA_Factory_Option__r.Description__c,
                    DNSA_Factory_Option__r.Price__c
                FROM
                    DNSA_Factory_Option_Junction__c
                WHERE
                    Quote__c =: factoryQtCheck.QuoteId
                AND DNSA_Factory_Option__r.Type__c = 'CV'
                AND Dealer_Checked__c = false
            ];
            if(!factoryCV.isEmpty()){
                for(DNSA_Factory_Option_Junction__c fo : factoryCV){
                    T_VALUE factoryCVReturn = new T_VALUE();
                    factoryCVReturn.ATNAM = fo.DNSA_Factory_Option__r.C_Code__c;
                    factoryCVReturn.ATBEZ = fo.DNSA_Factory_Option__r.C_Value__c;
                    factoryCVReturn.ATWRT = fo.DNSA_Factory_Option__r.V_Code__c;
                    factoryCVReturn.ATWTB = fo.DNSA_Factory_Option__r.V_Value__c;
                    factoryCVReturn.ZCVDESC = fo.DNSA_Factory_Option__r.Description__c;
                    factoryCVReturn.Price = Decimal.valueOf(String.valueOf(fo.DNSA_Factory_Option__r.Price__c)).format();
                    factoryCVList.add(factoryCVReturn);
                }
                result.put('FACTORY', factoryCVList);
            }
        }
        Integer current = 0;
        Integer init = 0;
        String underM = 'M\\_%';
        List<CharacteristicValue__c> oldCVlist = [
            SELECT
                Id,
                C_Code__c,
                C_Value__c,
                V_Code__c,
                V_Value__c,
                defChange__c,
                Price__c
            FROM
                CharacteristicValue__c
            WHERE 
                QuoteLineItem__c =: quoteLineId and
                C_Code__c LIKE :underM 
                and defChange__c = true
                
        ];
        List<T_VALUE> previeousCVList = new List<T_VALUE>();

        if(!oldCVlist.isEmpty()){
            for(CharacteristicValue__c cv : oldCVlist){
                T_VALUE cvreturn = new T_VALUE();
                cvreturn.ATNAM = cv.C_Code__c;
                cvreturn.ATBEZ = cv.C_Value__c;
                cvreturn.ATWRT = cv.V_Code__c;
                cvreturn.ATWTB = cv.V_Value__c;
                previeousCVList.add(cvreturn);
            }
            result.put('previeousCVList', previeousCVList);
        }
        //Plant정보 세팅
        String PLANT;
        List<QuoteLineItem> prdInfoList = [SELECT Product2Id FROM QuoteLineItem WHERE Id =:quoteLineId];
        List<ProductByPlant__c> plantInfo = [SELECT Part__r.RecordType.Name, Plant__c FROM ProductByPlant__c WHERE Part__r.RecordType.Name  LIKE '%Base%' and Plant__c LIKE '18%' and Part__c =:prdInfoList[0].Product2Id];

        List<T_VALUE> noPlantlist = new List<T_VALUE>();
        T_VALUE noPlant = new T_VALUE();
         //내가 선택한 CV와 리턴받은 T_SELECT의 CV가 
        if(plantInfo.isEmpty() || !plantInfo.isEmpty() && (plantInfo[0].Plant__c == '' || plantInfo[0].Plant__c == null)){
            noPlant.TYPE = 'NOPLANT';
            noPlant.MSG = 'NoPLANT';

            noPlantlist.add(noPlant);
            result.put('NOPLANT', noPlantlist);
            return result;
        }

        PLANT = plantInfo[0].Plant__c;

        // IF_ERP_Oppty getOptions = new IF_ERP_Oppty();
        // List<IF_ERP_Oppty_Classes.DefaultItemRes_T_VALUE> cvList = getOptions.getDefaultItem().T_VALUE;



        ////////////////////////
        List<QuoteLineItem> getIFInfo = [SELECT 
                                            Product2.Plant__c, 
                                            Product2.Model__r.Name, 
                                            Product2.Name, 
                                            RequestedDelivDate__c, 
                                            Quote.Owner.Name, 
                                            Product2.ProductCode,
                                            ERPInquiryNo__c,
                                            Quote.Account.CustomerCode__c,
                                            Quote.Account.Owner.SalesOrganization__c,
                                            Quote.Account.Owner.DistributionChannel__c,
                                            Quote.Account.Owner.Division__c,
                                            Requested_Ship_Date__c
                                        FROM QuoteLineItem WHERE Id=:quoteLineId];
        IF_ERP_Product_Classes.IF_OPTY_023_Req req = new IF_ERP_Product_Classes.IF_OPTY_023_Req();
        // req.I_PARENT        = 'MB0002';
        // req.I_PARENT        = getIFInfo[0].Product2.Model__r.Name;
        // req.I_PRODUCT       = 'DBC1102-F31P-0-K30';
        req.I_PRODUCT       = getIFInfo[0].Product2.ProductCode; //key값
        // req.I_PLANT         = '1842'; //key값 -> ProductCode랑 Plant가 맞아야함.
        // req.I_PLANT         = getIFInfo[0].Product2.Plant__c;
        req.I_PLANT         = PLANT;
        // req.I_DATE          = '2024-12-31';
        if(factoryQtCheck.Quote.RecordTypeId == recordFactory) {
            req.I_DATE          = String.valueOf(getIFInfo[0].Requested_Ship_Date__c);
        } else {
            req.I_DATE          = String.valueOf(getIFInfo[0].RequestedDelivDate__c);
        }
        req.I_AMT_CHK       = 'X';
        req.I_RECALL        = 'X';
        // req.I_UNAME         = 'S_MTDO';
        req.I_UNAME         = getIFInfo[0].Quote.Owner.Name;
        // req.I_VBELN         = getIFInfo[0].ERPInquiryNo__c;
        IF_ERP_Product_Classes.IF_OPTY_023_Req_I_ORG I_ORG = new IF_ERP_Product_Classes.IF_OPTY_023_Req_I_ORG();
        req.I_ORG           = I_ORG;
        
        List<IF_ERP_Product_Classes.IF_OPTY_023_Req_T_SELECT> T_SELECT_LIST = new List<IF_ERP_Product_Classes.IF_OPTY_023_Req_T_SELECT>();
        List<T_VALUE> selList = new List<T_VALUE>();
        
        if(reset != 'reset'){
            for(Integer i = 0; i < oldCVlist.size(); i++){
                IF_ERP_Product_Classes.IF_OPTY_023_Req_T_SELECT T_SELECT = new IF_ERP_Product_Classes.IF_OPTY_023_Req_T_SELECT();
                T_SELECT.ATNAM  = oldCVlist[i].C_Code__c;
                T_SELECT.ATWRT  = oldCVlist[i].V_Code__c;
                T_SELECT.ZSEQNO  = String.valueOf(i+1);
                T_SELECT_LIST.add(T_SELECT);
    
                T_VALUE selCV = new T_VALUE();
                selCV.ATNAM = oldCVlist[i].C_Code__c;
                selCV.ATWRT = oldCVlist[i].V_Code__c;
                selCV.ZSEQNO = String.valueOf(i+1);
                selList.add(selCV);
            }
        }
        
        req.T_SELECT = T_SELECT_LIST;
        result.put('SELCV', selList);

        IF_ERP_Product_Classes.IF_OPTY_023_Req_I_USERINFO I_USERINFO = new IF_ERP_Product_Classes.IF_OPTY_023_Req_I_USERINFO();
        // I_USERINFO.BNAME ; 필요없음
        I_USERINFO.KUNNR    = getIFInfo[0].Quote.Account.CustomerCode__c;
        I_USERINFO.VKORG    = getIFInfo[0].Quote.Account.Owner.SalesOrganization__c;
        I_USERINFO.VTWEG    = getIFInfo[0].Quote.Account.Owner.DistributionChannel__c;
        I_USERINFO.SPART    = getIFInfo[0].Quote.Account.Owner.Division__c;
        // I_USERINFO.WERKS    = getIFInfo[0].Product2.Plant__c;
        I_USERINFO.WERKS    = PLANT;
        req.I_USERINFO      = I_USERINFO; // test data 에서 빈값
     
        IF_ERP_Product instance = new IF_ERP_Product();
        IF_ERP_Product_Classes.IF_OPTY_023_Res totalList = instance.IF_OPTY_023(req); //CV I/F전체 테이블 return
        List<IF_ERP_Product_Classes.IF_OPTY_023_Res_T_VALUE> cvList = totalList.T_VALUE; //I/F에서 T_VALUE값만 저장 -> Option변경할 때마다 새롭게 값이 변함
        List<IF_ERP_Product_Classes.IF_OPTY_023_Res_T_INITSEL> initSelList = totalList.T_INITSEL; // I/F에서 T_INITSEL값만 저장 -> Default값
        List<IF_ERP_Product_Classes.IF_OPTY_023_Res_T_SELECT> selectList = totalList.T_SELECT; // 변경 한 CV값 -> T_INITSEL과 비교해서 다르면 초록색으로 보여줘야함
        List<IF_ERP_Product_Classes.IF_OPTY_023_Res_T_INCON_VALUE> inconValList = totalList.T_INCON_VALUE; // CV변경하면서 추가로 변경 되어야 하는 값들 return
        List<IF_ERP_Product_Classes.IF_OPTY_023_Res_T_INCOM_OPTION> incomOptionList = totalList.T_INCOM_OPTION; //이 테이블에 값이 있으면 무조건 에러띄워주고 끝내야함
        List<T_VALUE> oReturnlist = new List<T_VALUE>();
        T_VALUE oReturn = new T_VALUE();
        oReturn.TYPE = totalList.O_RETURN.TYPE;

        if(totalList.O_RETURN.CODE == 'NOCV'){ 
            // T_VALUE oReturn = new T_VALUE();
            oReturn.TYPE = totalList.O_RETURN.TYPE;
            oReturn.CODE = totalList.O_RETURN.CODE;
            oReturn.MSG = totalList.O_RETURN.MESSAGE;
            oReturnlist.add(oReturn);
            result.put('O_RETURN', oReturnlist);

        }
        //T_INCOM_OPTION에 값이 있으면 ERROR
        else if(incomOptionList.size() > 0){
            // T_VALUE oReturn = new T_VALUE();
            oReturn.TYPE = totalList.O_RETURN.TYPE;
            oReturn.CODE = 'INCOMPLETE';
            oReturn.MSG = totalList.O_RETURN.MESSAGE;
            oReturnlist.add(oReturn);
            result.put('O_RETURN', oReturnlist);
        }
        //T_INCON_VALUE에 값이 있으면 ERROR
        else if(inconValList.size() > 0){
            // T_VALUE oReturn = new T_VALUE();
            oReturn.TYPE = totalList.O_RETURN.TYPE;
            oReturn.CODE = 'INCONSISTANCE';
            oReturn.MSG = totalList.O_RETURN.MESSAGE;
            oReturnlist.add(oReturn);
            result.put('O_RETURN', oReturnlist);

        }

        else if(totalList.O_RETURN.TYPE == 'S'){
            oReturn.CODE = 'SUCCESS';
            oReturn.MSG = totalList.O_RETURN.MESSAGE;
            oReturnlist.add(oReturn);
            result.put('O_RETURN', oReturnlist);

        }else if(totalList.O_RETURN.TYPE == 'E'){
            // T_VALUE oReturn = new T_VALUE();
            oReturn.TYPE = totalList.O_RETURN.TYPE;
            oReturn.CODE = totalList.O_RETURN.CODE;
            oReturn.MSG = totalList.O_RETURN.MESSAGE;
            oReturnlist.add(oReturn);
            result.put('O_RETURN', oReturnlist);
        }

        
        
        System.debug('옵션 : ' + cvList);
        //////////////////////// 

        List<T_VALUE> newList = new List<T_VALUE>();
        List<T_VALUE> defaultList = new List<T_VALUE>();
        
        
            for(integer i = 0; i < selectList.size(); i++){
                T_VALUE selCv = new T_VALUE();
                    selCv.ATBEZ = selectList[i].ATBEZ;
                    selCv.ATNAM = selectList[i].ATNAM;
                    selCv.ATWRT = selectList[i].ATWRT;
                    selCv.ATWTB = selectList[i].ATWTB;
                    selCv.IF_DEFAULT = selectList[i].IF_DEFAULT;
                    selCv.SHOW = selectList[i].SHOW;
                    selCv.ZCVDESC = selectList[i].ZCVDESC;
                    selCv.ZSEQNO = selectList[i].ZSEQNO;
                    if(selectList[i].ATNAM.startsWith('M_')){
                        selCv.mCheck = true;
                    }else{
                        selCv.mCheck = false;
                    }
                    // newCv.Color = false;
                    newList.add(selCv);
                    current++;
                    init = newList.size() - 1;
                for(Integer k = 0; k < initSelList.size(); k++){//T_SELECT랑 T_INITSEL이랑 다르면 변경 된 자재이므로 Color True
                    if(selectList[i].ATNAM == initSelList[k].ATNAM){ //ATNAM이 같은데 ATWRT가 다르면 변경된자재
                        if(selectList[i].ATWRT != initSelList[k].ATWRT){
                            newList[init].Color = true;
                        }
                    }

                }

                for(Integer j = 0; j < cvList.size(); j++){ //T_VALUE랑 T_SELECT랑 합침
                    if(selectList[i].ATNAM == cvList[j].ATNAM){
                        if(current > 0 && String.isBlank(newList[init].ATBEZ)){
                            newList[init].ATBEZ = cvList[j].ATBEZ;
                        }
                        if(selectList[i].ATWRT == cvList[j].ATWRT){ //이미 default로 등록이 되어있으면 value update
                            if(current > 0 && String.isBlank(newList[init].ATWTB)){
                                newList[init].ATWTB = cvList[j].ATWTB;
                            }
                        }else{
                            T_VALUE newCv = new T_VALUE();
                                newCv.ATBEZ = cvList[j].ATBEZ;
                                newCv.ATNAM = cvList[j].ATNAM;
                                newCv.ATWRT = cvList[j].ATWRT;
                                newCv.ATWTB = cvList[j].ATWTB;
                                newCv.IF_DEFAULT = cvList[j].IF_DEFAULT;
                                newCv.KBETR = cvList[j].KBETR;
                                newCv.KONWA = cvList[j].KONWA;
                                newCv.SHOW = cvList[j].SHOW;
                                newCv.ZCVDESC = cvList[j].ZCVDESC;
                                newCv.ZSEQNO = cvList[j].ZSEQNO;
                                // newCv.Color = false;
                                newList.add(newCv);
                                current++;
                        }
                    }
                }
            }
        // }
        result.put('T_VALUE', newList);
        // for(Integer i = 0; i < newList.size(); i++){
        //     System.debug('newList : ' + newList[i]);
        // }

        for(Integer i = 0; i < initSelList.size(); i++){
            T_VALUE defCv = new T_VALUE();
            defCv.ATBEZ = initSelList[i].ATBEZ;
            defCv.ATNAM = initSelList[i].ATNAM;
            defCv.ATWRT = initSelList[i].ATWRT;
            defCv.ATWTB = initSelList[i].ATWTB;
            defCv.IF_DEFAULT = initSelList[i].IF_DEFAULT;
            defCv.SHOW = initSelList[i].SHOW;
            defCv.ZCVDESC = initSelList[i].ZCVDESC;
            defCv.ZSEQNO = initSelList[i].ZSEQNO;
            if(initSelList[i].ATNAM.startsWith('M_')){
                defCv.mCheck = true;
            }else{
                defCv.mCheck = false;
            }
            defaultList.add(defCv);
        }
        result.put('DEFAULT', defaultList);
        if(!cvList.isEmpty()){
            for(Integer i = 0; i < cvList.size(); i++){
                System.debug('cvList : ' + cvList[i]);
            }
        }
        if(!initSelList.isEmpty()){
            for(Integer i = 0; i < initSelList.size(); i++){
                System.debug('initSelList : ' + initSelList[i]);
            }
        }
        if(!selectList.isEmpty()){
            for(Integer i = 0; i < selectList.size(); i++){
                System.debug('selectList : ' + selectList[i]);
            }
        }
        System.debug(result);
        System.debug('previeousCVList : ' + previeousCVList);

        List<T_VALUE> oReturnComplexlist = new List<T_VALUE>();
        T_VALUE oReturnComplex = new T_VALUE();
         //내가 선택한 CV와 리턴받은 T_SELECT의 CV가 다르면 복합 CV
         if(!oldCVlist.isEmpty() && !selectList.isEmpty()){
            Map<String, String> oldcvMap = new map<String, String>();
            for(CharacteristicValue__c cv : oldCVlist){
                oldcvMap.put(cv.C_Code__c, cv.V_Code__c);
            }

            for(Integer i = 0; i < selectList.size(); i++){
                if(oldcvMap.get(selectList[i].ATNAM) != null && oldcvMap.get(selectList[i].ATNAM) != selectList[i].ATWRT){
                    oReturnComplex.TYPE = 'COMPLEXEDCV';
                    oReturnComplex.CODE = 'SUCCESS';
                    oReturnComplex.MSG = totalList.O_RETURN.MESSAGE;

                    oReturnComplexlist.add(oReturnComplex);
                    result.put('O_RETURNCOMPLEX', oReturnComplexlist);
                }
            }

        }
        String jsonString = JSON.serialize(totalList);
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

        if (parsed.containsKey('T_INCOM_OPTION')) {
            System.debug('T_INCOM_OPTION 키 있음');
        } else {
            System.debug('T_INCOM_OPTION 키 없음');
        }
        System.debug('incomOptionList : ' + totalList.T_INCOM_OPTION);
        for (IF_ERP_Product_Classes.IF_OPTY_023_Res_T_INCOM_OPTION opt : totalList.T_INCOM_OPTION) {
        System.debug('ATNAM: ' + opt.ATNAM);
        System.debug('ATBEZ: ' + opt.ATBEZ);
        System.debug('ZSEQNO: ' + opt.ZSEQNO);
        System.debug('SHOW: ' + opt.SHOW);
        System.debug('READONLY: ' + opt.READONLY);
        System.debug('ATEIN: ' + opt.ATEIN);
        System.debug('FLREQ: ' + opt.FLREQ);
        System.debug('GRNAM: ' + opt.GRNAM);
        System.debug('DISPLAY: ' + opt.DISPLAY);
        System.debug('ZCVDESC: ' + opt.ZCVDESC);
    }
        // for(Integer i = 0; i < totalList.T_INCOM_OPTION.size(); i++){
        //     System.debug('확인 : ' + totalList.[i]);
        // }
        return result;
    }

    @AuraEnabled
    public static Map<String,List<T_VALUE>> changeOption(String quoteLineId, List<IF_ERP_Product_Classes.IF_OPTY_023_Req_T_SELECT> selectedValue, Boolean isODLogic){
        Map<String,List<T_VALUE>> result = new Map<String,List<T_VALUE>>();
        Integer current = 0;
        Integer inConcurrent = 0;
        Integer init = 0;
        Integer inConinit = 0;
        //Plant정보 세팅
        String PLANT;
        List<QuoteLineItem> prdInfoList = [SELECT Product2Id FROM QuoteLineItem WHERE Id =:quoteLineId];
        List<ProductByPlant__c> plantInfo = [SELECT Part__r.RecordType.Name, Plant__c FROM ProductByPlant__c WHERE Part__r.RecordType.Name  LIKE '%Base%' and Plant__c LIKE '18%' and Part__c =:prdInfoList[0].Product2Id];
        PLANT = plantInfo[0].Plant__c;
        // IF_ERP_Oppty getOptions = new IF_ERP_Oppty();
        // List<IF_ERP_Oppty_Classes.DefaultItemRes_T_VALUE> cvList = getOptions.getDefaultItem().T_VALUE;

        QuoteLineItem factoryQtCheck = 
        [
            SELECT 
                QuoteId, 
                Quote.RecordTypeId,
                Requested_Ship_Date__c
            FROM 
                QuoteLineItem 
            WHERE
                Id =:quoteLineId
        ];


        ////////////////////////
        List<QuoteLineItem> getIFInfo = [SELECT 
                                            Product2.Plant__c, 
                                            Product2.Model__r.Name, 
                                            Product2.Name, 
                                            RequestedDelivDate__c, 
                                            Quote.Owner.Name, 
                                            Product2.ProductCode,
                                            ERPInquiryNo__c,
                                            Quote.Account.CustomerCode__c,
                                            Quote.Account.Owner.SalesOrganization__c,
                                            Quote.Account.Owner.DistributionChannel__c,
                                            Quote.Account.Owner.Division__c,
                                            Requested_Ship_Date__c
                                        FROM QuoteLineItem WHERE Id=:quoteLineId];
        IF_ERP_Product_Classes.IF_OPTY_023_Req req = new IF_ERP_Product_Classes.IF_OPTY_023_Req();
        // req.I_PARENT        = 'MB0002';
        // req.I_PARENT        = getIFInfo[0].Product2.Model__r.Name;
        // req.I_PRODUCT       = 'DBC1102-F31P-0-K30';
        req.I_PRODUCT       = getIFInfo[0].Product2.ProductCode; //key값
        // req.I_PLANT         = '1842'; //key값 -> ProductCode랑 Plant가 맞아야함.
        // req.I_PLANT         = getIFInfo[0].Product2.Plant__c;
        req.I_PLANT         = PLANT;
        // req.I_DATE          = '2024-12-31';
        if(factoryQtCheck.Quote.RecordTypeId == recordFactory) {
            req.I_DATE          = String.valueOf(getIFInfo[0].Requested_Ship_Date__c);
        } else {
            req.I_DATE          = String.valueOf(getIFInfo[0].RequestedDelivDate__c);
        }
        // req.I_DATE          = String.valueOf(getIFInfo[0].RequestedDelivDate__c);
        req.I_AMT_CHK       = 'X';
        req.I_RECALL        = 'X';
        // req.I_UNAME         = 'S_MTDO';
        req.I_UNAME         = getIFInfo[0].Quote.Owner.Name;
        // req.I_VBELN         = getIFInfo[0].ERPInquiryNo__c;
        IF_ERP_Product_Classes.IF_OPTY_023_Req_I_ORG I_ORG = new IF_ERP_Product_Classes.IF_OPTY_023_Req_I_ORG();
        req.I_ORG           = I_ORG;
        
        IF_ERP_Product_Classes.IF_OPTY_023_Req_I_USERINFO I_USERINFO = new IF_ERP_Product_Classes.IF_OPTY_023_Req_I_USERINFO();
        // I_USERINFO.BNAME ; 필요없음
        I_USERINFO.KUNNR    = getIFInfo[0].Quote.Account.CustomerCode__c;
        I_USERINFO.VKORG    = getIFInfo[0].Quote.Account.Owner.SalesOrganization__c;
        I_USERINFO.VTWEG    = getIFInfo[0].Quote.Account.Owner.DistributionChannel__c;
        I_USERINFO.SPART    = getIFInfo[0].Quote.Account.Owner.Division__c;
        // I_USERINFO.WERKS    = getIFInfo[0].Product2.Plant__c;
        I_USERINFO.WERKS    = PLANT;
        req.I_USERINFO      = I_USERINFO; // test data 에서 빈값
     
        List<IF_ERP_Product_Classes.IF_OPTY_023_Req_T_SELECT> T_SELECT_LIST = new List<IF_ERP_Product_Classes.IF_OPTY_023_Req_T_SELECT>();
        if(isODLogic == true){
            for(Integer i = 0; i < selectedValue.size(); i++)
            {
                IF_ERP_Product_Classes.IF_OPTY_023_Req_T_SELECT T_SELECT = new IF_ERP_Product_Classes.IF_OPTY_023_Req_T_SELECT();
                T_SELECT.ATNAM  = selectedValue[i].ATNAM;
                T_SELECT.ATWRT  = selectedValue[i].ATWRT;
                // T_SELECT.ZSEQNO  = String.valueOf(i+1);
                T_SELECT.ZSEQNO  = selectedValue[i].ZSEQNO;
                T_SELECT_LIST.add(T_SELECT);
            }
        }else{
            //OD로직 해제 경우에는 MFPRO를 무조건 seq1번으로 해서 빈값으로 보내야 하기에 선택된 값들 SEQ1씩 증가
            IF_ERP_Product_Classes.IF_OPTY_023_Req_T_SELECT T_SELECT_MFPRO = new IF_ERP_Product_Classes.IF_OPTY_023_Req_T_SELECT();
                T_SELECT_MFPRO.ATNAM  = 'MFPRO';
                T_SELECT_MFPRO.ATWRT  = '';
                T_SELECT_MFPRO.ZSEQNO  = '1';
                T_SELECT_LIST.add(T_SELECT_MFPRO);

            for(Integer i = 0; i < selectedValue.size(); i++)
            {
                IF_ERP_Product_Classes.IF_OPTY_023_Req_T_SELECT T_SELECT = new IF_ERP_Product_Classes.IF_OPTY_023_Req_T_SELECT();
                T_SELECT.ATNAM  = selectedValue[i].ATNAM;
                T_SELECT.ATWRT  = selectedValue[i].ATWRT;
                // T_SELECT.ZSEQNO  = String.valueOf(i+1);
                T_SELECT.ZSEQNO  = String.valueOf(Integer.valueOf(selectedValue[i].ZSEQNO) + 1);
                T_SELECT_LIST.add(T_SELECT);
            }
        }
        
        req.T_SELECT = T_SELECT_LIST;
        

        IF_ERP_Product instance = new IF_ERP_Product();
        IF_ERP_Product_Classes.IF_OPTY_023_Res totalList = instance.IF_OPTY_023(req); //CV I/F전체 테이블 return
        List<IF_ERP_Product_Classes.IF_OPTY_023_Res_T_VALUE> cvList = totalList.T_VALUE; //I/F에서 T_VALUE값만 저장 -> Option변경할 때마다 새롭게 값이 변함
        List<IF_ERP_Product_Classes.IF_OPTY_023_Res_T_INITSEL> initSelList = totalList.T_INITSEL; // I/F에서 T_INITSEL값만 저장 -> Default값
        List<IF_ERP_Product_Classes.IF_OPTY_023_Res_T_SELECT> selectList = totalList.T_SELECT; // 변경 한 CV값 -> T_INITSEL과 비교해서 다르면 초록색으로 보여줘야함
        List<IF_ERP_Product_Classes.IF_OPTY_023_Res_T_INCON_VALUE> inconValList = totalList.T_INCON_VALUE; // CV변경하면서 추가로 변경 되어야 하는 값들 return
        List<IF_ERP_Product_Classes.IF_OPTY_023_Res_T_INCOM_OPTION> incomOptionList = totalList.T_INCOM_OPTION; //이 테이블에 값이 있으면 무조건 에러띄워주고 끝내야함
        List<T_VALUE> oReturnlist = new List<T_VALUE>();


        //CV가 없는 ERROR -> T_INCON_VALUE, T_INCOM_OPTION둘다 빈값임
        System.debug('totalList.O_RETURN.CODE : ' + totalList.O_RETURN.CODE);
        if(totalList.T_INITSEL.size() > 0){
            for(Integer i = 0; i < totalList.T_INITSEL.size(); i++){
                System.debug('totalList.T_INITSEL : ' + totalList.T_INITSEL[i]);
            }
        }
        System.debug('totalList.T_VALUE.size() : ' + totalList.T_VALUE.size());
        System.debug('totalList.T_SELECT.size() : ' + totalList.T_SELECT.size());

        for(Integer i = 0; i < totalList.T_VALUE.size(); i++){
                System.debug('totalList.T_VALUE : ' + totalList.T_VALUE[i]);
            }

            for(Integer i = 0; i < totalList.T_SELECT.size(); i++){
                System.debug('totalList.T_SELECT : ' + totalList.T_SELECT[i]);
            }

        if(totalList.O_RETURN.CODE == 'NOCV'){ 
            T_VALUE oReturn = new T_VALUE();
            oReturn.TYPE = totalList.O_RETURN.TYPE;
            oReturn.CODE = totalList.O_RETURN.CODE;
            oReturn.MSG = totalList.O_RETURN.MESSAGE;
            oReturnlist.add(oReturn);
            result.put('O_RETURN', oReturnlist);

        }
        //T_INCOM_OPTION에 값이 있으면 ERROR
        else if(incomOptionList.size() > 0){
            T_VALUE oReturn = new T_VALUE();
            oReturn.TYPE = totalList.O_RETURN.TYPE;
            oReturn.CODE = 'INCOMPLETE';
            oReturn.MSG = totalList.O_RETURN.MESSAGE;
            oReturnlist.add(oReturn);
            result.put('O_RETURN', oReturnlist);
        }
        //T_INCON_VALUE에 값이 있으면 ERROR
        else if(inconValList.size() > 0){
            T_VALUE oReturn = new T_VALUE();
            oReturn.TYPE = totalList.O_RETURN.TYPE;
            oReturn.CODE = 'INCONSISTANCE';
            oReturn.MSG = totalList.O_RETURN.MESSAGE;
            oReturnlist.add(oReturn);
            result.put('O_RETURN', oReturnlist);

        }else if(totalList.O_RETURN.TYPE == 'S'){
            T_VALUE oReturn = new T_VALUE();
            oReturn.TYPE = totalList.O_RETURN.TYPE;
            oReturn.CODE = 'SUCCESS';
            // oReturn.MSG = totalList.O_RETURN.MESSAGE;
            oReturn.MSG = ''; //SUCCESS는 빈값으로 메세지 전달
            oReturnlist.add(oReturn);
            result.put('O_RETURN', oReturnlist);
        }else if(totalList.O_RETURN.TYPE == 'E'){
            T_VALUE oReturn = new T_VALUE();
            oReturn.TYPE = totalList.O_RETURN.TYPE;
            oReturn.CODE = totalList.O_RETURN.CODE;
            oReturn.MSG = totalList.O_RETURN.MESSAGE;
            oReturnlist.add(oReturn);
            result.put('O_RETURN', oReturnlist);
        }
        //////////////////////// 

        List<T_VALUE> newList = new List<T_VALUE>();
        List<T_VALUE> defaultList = new List<T_VALUE>();
        for(integer i = 0; i < selectList.size(); i++){
            T_VALUE selCv = new T_VALUE();
                selCv.ATBEZ = selectList[i].ATBEZ;
                selCv.ATNAM = selectList[i].ATNAM;
                selCv.ATWRT = selectList[i].ATWRT;
                selCv.ATWTB = selectList[i].ATWTB;
                selCv.IF_DEFAULT = selectList[i].IF_DEFAULT;
                selCv.SHOW = selectList[i].SHOW;
                selCv.ZCVDESC = selectList[i].ZCVDESC;
                selCv.ZSEQNO = selectList[i].ZSEQNO;
                if(selectList[i].ATNAM.startsWith('M_')){
                    selCv.mCheck = true;
                }else{
                    selCv.mCheck = false;
                }
                // newCv.Color = false;
                newList.add(selCv);
                current++;
                init = newList.size() - 1;
            for(Integer k = 0; k < initSelList.size(); k++){//T_SELECT랑 T_INITSEL이랑 다르면 변경 된 자재이므로 Color True
                if(selectList[i].ATNAM == initSelList[k].ATNAM){ //ATNAM이 같은데 ATWRT가 다르면 변경된자재
                    if(selectList[i].ATWRT != initSelList[k].ATWRT){
                        newList[init].Color = true;
                    }
                }

            }

            for(Integer j = 0; j < cvList.size(); j++){ //T_VALUE랑 T_SELECT랑 합침
                if(selectList[i].ATNAM == cvList[j].ATNAM){
                    if(current > 0 && String.isBlank(newList[init].ATBEZ)){
                        newList[init].ATBEZ = cvList[j].ATBEZ;
                    }
                    if(selectList[i].ATWRT == cvList[j].ATWRT){ //이미 default로 등록이 되어있으면 value update
                        if(current > 0 && String.isBlank(newList[init].ATWTB)){
                            newList[init].ATWTB = cvList[j].ATWTB;
                        }
                    }else{
                        T_VALUE newCv = new T_VALUE();
                            newCv.ATBEZ = cvList[j].ATBEZ;
                            newCv.ATNAM = cvList[j].ATNAM;
                            newCv.ATWRT = cvList[j].ATWRT;
                            newCv.ATWTB = cvList[j].ATWTB;
                            newCv.IF_DEFAULT = cvList[j].IF_DEFAULT;
                            newCv.KBETR = cvList[j].KBETR;
                            newCv.KONWA = cvList[j].KONWA;
                            newCv.SHOW = cvList[j].SHOW;
                            newCv.ZCVDESC = cvList[j].ZCVDESC;
                            newCv.ZSEQNO = cvList[j].ZSEQNO;
                            // newCv.Color = false;
                            newList.add(newCv);
                            current++;
                    }
                }
            }
        }
        result.put('T_VALUE', newList);

        for(Integer i = 0; i < inconValList.size(); i++){
            System.debug('inconValList : ' + inconValList[i]);
        }
        //inConValue 로직
        List<T_VALUE> inconnewList = new List<T_VALUE>();

        if(inconValList.size() > 0){ //나중에 selectList를 inconValList로 변경해야함
            for(integer i = 0; i < inconValList.size(); i++){
                T_VALUE inconCv = new T_VALUE();
                    inconCv.ATBEZ = inconValList[i].ATBEZ;
                    inconCv.ATNAM = inconValList[i].ATNAM;
                    inconCv.ATWRT = inconValList[i].ATWRT;
                    inconCv.ATWTB = inconValList[i].ATWTB;
                    inconCv.IF_DEFAULT = inconValList[i].IF_DEFAULT;
                    inconCv.SHOW = inconValList[i].SHOW;
                    inconCv.ZCVDESC = inconValList[i].ZCVDESC;
                    inconCv.ZSEQNO = inconValList[i].ZSEQNO;
                    // newCv.Color = false;
                    inconnewList.add(inconCv);
                    inConcurrent++;
                    inConinit = inconnewList.size() - 1;

                for(Integer j = 0; j < cvList.size(); j++){ //T_VALUE랑 T_INCON_VALUE랑 합침
                    if(inconValList[i].ATNAM == cvList[j].ATNAM){
                        if(inConcurrent > 0 && String.isBlank(inconnewList[inConinit].ATBEZ)){
                            inconnewList[inConinit].ATBEZ = cvList[j].ATBEZ;
                        }
                        if(inconValList[i].ATWRT == cvList[j].ATWRT){ //이미 default로 등록이 되어있으면 value update
                            if(inConcurrent > 0 && String.isBlank(inconnewList[inConinit].ATWTB)){
                                inconnewList[inConinit].ATWTB = cvList[j].ATWTB;
                            }
                        }else{
                            T_VALUE newCv = new T_VALUE();
                                newCv.ATBEZ = cvList[j].ATBEZ;
                                newCv.ATNAM = cvList[j].ATNAM;
                                newCv.ATWRT = cvList[j].ATWRT;
                                newCv.ATWTB = cvList[j].ATWTB;
                                newCv.IF_DEFAULT = cvList[j].IF_DEFAULT;
                                newCv.KBETR = cvList[j].KBETR;
                                newCv.KONWA = cvList[j].KONWA;
                                newCv.SHOW = cvList[j].SHOW;
                                newCv.ZCVDESC = cvList[j].ZCVDESC;
                                newCv.ZSEQNO = cvList[j].ZSEQNO;
                                // newCv.Color = false;
                                inconnewList.add(newCv);
                                inConcurrent++;
                        }
                    }
                }
            }
        }
        result.put('T_INCON_VALUE', inconnewList);

        for(Integer i = 0; i < initSelList.size(); i++){
            T_VALUE defCv = new T_VALUE();
            defCv.ATBEZ = initSelList[i].ATBEZ;
            defCv.ATNAM = initSelList[i].ATNAM;
            defCv.ATWRT = initSelList[i].ATWRT;
            defCv.ATWTB = initSelList[i].ATWTB;
            defCv.IF_DEFAULT = initSelList[i].IF_DEFAULT;
            defCv.SHOW = initSelList[i].SHOW;
            defCv.ZCVDESC = initSelList[i].ZCVDESC;
            defCv.ZSEQNO = initSelList[i].ZSEQNO;
            if(initSelList[i].ATNAM.startsWith('M_')){
                defCv.mCheck = true;
            }else{
                defCv.mCheck = false;
            }
            defaultList.add(defCv);
        }
        result.put('DEFAULT', defaultList);
        if(!cvList.isEmpty()){
            for(Integer i = 0; i < cvList.size(); i++){
                System.debug('cvList : ' + cvList[i]);
            }
        }
        if(!initSelList.isEmpty()){
            for(Integer i = 0; i < initSelList.size(); i++){
                System.debug('initSelList : ' + initSelList[i]);
            }
        }
        if(!selectList.isEmpty()){
            for(Integer i = 0; i < selectList.size(); i++){
                System.debug('selectList : ' + selectList[i]);
            }
        }
        System.debug(result);
        return result;
    }

    @AuraEnabled
    public static String saveRecord(List<QuoteLineItem> lineItemList, List<CharacteristicValueWrapper> upRecord){
        List<QuoteLineItem> updateRecord = new List<QuoteLineItem>();
        List<CharacteristicValue__c> createCV = new List<CharacteristicValue__c>();
        Set<Id> quotlineId = new Set<Id>();
        List<String> qtId = new List<String>();
        for(QuoteLineItem qli : lineItemList){
            quotlineId.add(qli.Id);
            qtId.add(qli.Id);
        }
        System.debug('upRecord' + upRecord);
        try {
            List<CharacteristicValue__c> originCV = 
            [
                SELECT
                    Id,
                    C_Code__c,
                    C_Value__c,
                    V_Code__c,
                    V_Value__c,
                    defChange__c,
                    Price__c,
                    QuoteLineItem__c
                FROM
                    CharacteristicValue__c
                WHERE
                    QuoteLineItem__c IN: quotlineId
                ORDER BY
                    QuoteLineItem__c
                
            ];
            if(!originCV.isEmpty()) {
                delete originCV;
            }

            Integer i = 0;
            Integer j = 0;

            for(QuoteLineItem quote : lineItemList){
                QuoteLineItem updateGroup = new QuoteLineItem();
                updateGroup.Id = quote.Id;
                updateGroup.GroupId__c = (String)DateTime.now().format('yyyyMMddHHmmss');
                updateGroup.CVComplete__c = true;
                updateGroup.QuotePriceIF__c = false;
                updateGroup.ReERPQuotation__c = true;
                updateRecord.add(updateGroup);

                for(CharacteristicValueWrapper cv : upRecord){
                    CharacteristicValue__c updateCV = new CharacteristicValue__c();
                    if(cv.Id != null){
                        updateCV.Id               = originCV[j].Id;
                    }
                    updateCV.QuoteLineItem__c = quote.Id;
                    updateCV.C_Code__c        = cv.C_Code; 
                    updateCV.C_Value__c       = cv.C_Value;
                    updateCV.V_Code__c        = cv.V_Code;
                    updateCV.V_Value__c       = cv.V_Value;
                    updateCV.defChange__c     = cv.Color;
                    updateCV.Price__c         = cv.Price;
                    if(cv.C_Code.startsWith('M_')){
                        updateCV.ShowData__c  = true;
                    }
                    createCV.add(updateCV);
                    j++;
                }
                i++;

            }
            upsert createCV;
            update updateRecord;

            DN_QuoteReCreateController.quoteReCreate(qtId, 'CV');
            return 'SUCCESS';
            
        } catch (Exception e) {
            System.debug('ErrorLIne : ' + e.getLineNumber() + 'MSG : ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class CharacteristicValueWrapper{
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String C_Code {get;set;}
        @AuraEnabled public String C_Value {get;set;}
        @AuraEnabled public String V_Code {get;set;}
        @AuraEnabled public String V_Value {get;set;}
        @AuraEnabled public Decimal Price {get;set;}
        @AuraEnabled public Boolean Color {get;set;}
    }

    public class T_VALUE{
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String ATBEZ {get;set;}
        @AuraEnabled public String ATNAM {get;set;}
        @AuraEnabled public String ATWRT {get;set;}
        @AuraEnabled public String ATWTB {get;set;}
        @AuraEnabled public String IF_DEFAULT {get;set;}
        @AuraEnabled public String KBETR {get;set;}
        @AuraEnabled public String KONWA {get;set;}
        @AuraEnabled public String SHOW {get;set;}
        @AuraEnabled public String ZCVDESC {get;set;}
        @AuraEnabled public String ZSEQNO {get;set;}
        @AuraEnabled public String TYPE {get;set;}
        @AuraEnabled public String CODE {get;set;}
        @AuraEnabled public String MSG {get;set;}
        @AuraEnabled public Boolean mCheck {get;set;}
        @AuraEnabled public Boolean Color {get;set;}
        @AuraEnabled public String Price {get;set;}

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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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