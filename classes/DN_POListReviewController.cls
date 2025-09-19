/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 02. 25. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-25 | Iltae seo      | 최초작성 
 */ 
public without sharing class DN_POListReviewController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }
    /***
     * - MRP Batch	
        안전재고 대상(MRP Type 'VB') 품목 + 주문서 등록 품목 대상으로 추천 PO 수량 계산	
        PO 추천 수량에 안전재고 포함하여 계산	
            
        - Open Order Only	
        주문서 등록 품목 대상으로 추천 PO 수량 계산	
        PO 추천 수량에 안전재고 포함하여 계산	
            
        - Backorder Only	
        주문서 등록 품목 대상으로 추천 PO 수량 계산	
        PO 추천 수량에 안전재고 미포함	
        PO Qty 계산	
            
        1. MRP TYPE 'VB' 이고 ( MRP Batch 또는 Open Order Only) 일 경우	
        1. (가용재고 + DueIn - DueOut) < ROP 이면 PO Qty = Max Lv. - (가용재고 + DueIn - DueOut)	
        2.  Min Lot 반영	
        PO Qty < Min Lot 이면 PO Qty = Min Lot	
        3. Round Value 반영	
        Ex.) PO Qty 가 4 R-Val 이 3 일 경우 PO Qty = 6 	
            
            
        2. MRP TYPE 'ND' 또는 Backorder Only 조회 일 경우	
        PO Qty = DueOut - 가용재고 - DueIn ( PO Qty < 0 이면 PO Qty = 0)	
        ABC 등급이 'M', 'P', 'S', 'Z' 가 아닐 경우 Min Lot 반영, Round Value 반영	
            
            
        3. PO Qty = 0 이고 Material = Last Parts 이고 대체이전품과의 관계가 'I'(단방향) 일 경우	
        대체 이전품의 Dueout, Duein, 가용재고를 제외한 본인 품번만의 수량으로 계산	
        PO Qty = DueOut - 가용재고 - DueIn ( PO Qty < 0 이면 PO Qty = 0)	
     
        * ZSST8060 - DealerOrderItem__c / ZSST8070 - DealerFreeDispatch__c 
     * 
     * 
     * 
     * PO List 컨디션 기준으로 
     * 1. DealerPartMasterByMPPS__c  또는 주문서 목록의 품번들을 추려낸다.
     * 2. 추려낸 품번기준으로 DealerPartMasterByMPPS__c를 재조회한다.
       3. 
     * 
     */
    
    /**
     * @Description
     * 	- Twice Interval PO Review Batch 정보 확인
    **/ 
    @AuraEnabled
    public static List<CronTrigger> initJob(){
        try {
            List<CronTrigger> cronTriggerList = [
                select Id, CronJobDetail.Name, format(PreviousFireTime) PreviousFireTime 
                from CronTrigger  
                WHERE CronJobDetail.Name='Twice Interval PO Review Batch' 
                Order by CreatedDate desc
            ];
            return cronTriggerList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- PO List 조회
    **/ 
    @AuraEnabled
    public static PageReturn getDataListQuery(PageReturn page, Integer nextPage, Boolean isExcelLoad){
        try {
            System.debug(page + ' : page');
            System.debug(nextPage + ' : nextPage');
            System.debug(isExcelLoad + ' : isExcelLoad');
            PageReturn returnPage = page;
            Map<String,Integer> pageMap = setpageSetting(returnPage,nextPage);
            Integer limitSet = pageMap.get('limit');
            Integer startIdx = pageMap.get('startIdx');
            Integer endIdx = pageMap.get('endIdx');
            // 부품 목록 -  PO Review Condition
            Map<String, Object> partQueryMap = getPartList(returnPage.strQuery, limitSet);

            Set<String> materialSet = (Set<String>) partQueryMap.get('materialSet');
            Set<String> partIdSet = (Set<String>) partQueryMap.get('partIdSet');
            
            returnPage.recordList = new List<POListReview>();
            // 데이터 조회 //FROM DealerPartMasterByMPPS__c WHERE Dealer__c =\''+currentUser.getAgencyId()+'\'';
            String dataQuery = ' SELECT Id,Name,Part__c,Part__r.ProductCode,Part__r.FM_MaterialDetails__c,DealerStock__r.AvailableQuantity__c,DealerStock__r.CurrentStockQuantity__c,DueIn__c,FM_DueOut__c,';
            dataQuery += 'WAMD__c,MRPType__c,ABCIndicator__c,ReorderPoint__c,MaximumStock__c,MinimumLotSize__c,RoundingValue__c,PlannedDeliveryDays__c ';
            dataQuery += ' FROM DealerPartMasterByMPPS__c ';
            
            String dataCountQuery = ' SELECT count() FROM DealerPartMasterByMPPS__c ';
            String whereQuery = ' WHERE  Dealer__c =\''+currentUser.getAgencyId()+'\' AND Part__c != null AND DealerStock__c != null AND ABCIndicator__c != null  '; //MRPType //ABCIndicator

            // MRP Type
            if(returnPage.strQuery.get('MRPType') !='ALL') {
                whereQuery += ' AND MRPType__c =\''+returnPage.strQuery.get('MRPType')+'\'';
            }
            // ABCIndicator__c
            if(returnPage.strQuery.get('ABCIndicator') !='ALL') {
                whereQuery += ' AND ABCIndicator__c =\''+returnPage.strQuery.get('ABCIndicator')+'\'';
            }
            // System.debug(materialSet + ' ::: materialSet');

            // productCode 
            if( (String) returnPage.strQuery.get('productCode') !=null) {
                String productCode =(String) returnPage.strQuery.get('productCode');
                System.debug(productCode +' ::: productCode');
                Set<String> filterMaterialSet = new Set<String>(productCode.split(','));
                if(filterMaterialSet.size() > 0) {
                    whereQuery += ' AND Part__c IN(\'' +String.join(filterMaterialSet, '\',\'')+'\')'; 
                }

            }

            String partWhereQuery = '';
            if(partIdSet.size() >0) {
                partWhereQuery += ' Part__c IN(\'' +String.join(partIdSet, '\',\'')+'\')'; 
            }

            if((String) returnPage.strQuery.get('POReview') != 'BackorderOnly') {
                whereQuery += ' AND  FM_IsNeedPO__c = true ';
            }else {
                //BackorderOnly
                if(partIdSet.size() == 0)
                    whereQuery += ' AND  Part__c = null ';
            }
            
            if(String.isNotBlank(partWhereQuery)) {
                whereQuery += ' AND ( '+partWhereQuery +')';
            }

            dataQuery += whereQuery;
            dataCountQuery += whereQuery;

            System.debug(dataQuery + ' LIMIT 2000 ');
            System.debug('확인: ' + returnPage.orderBy + ' : '+ returnPage.orderByField);
            String orderBy = ' ';
            if(String.isNotBlank(returnPage.orderByField) || String.isNotBlank(returnPage.orderBy)) orderBy =  ' ' + returnPage.orderByField +' ' + returnPage.orderBy;
            // if(String.isNotBlank(returnPage.orderBy)) orderBy +=  ;
            System.debug(limitSet  +' ::: limitSet');
            // 주문서 기준 
            List<DealerPartMasterByMPPS__c> dealerByMppsList = Database.query(dataQuery + orderBy + ' LIMIT '+limitSet);
            partIdSet.clear();
            returnPage.query = dataQuery + orderBy + ' LIMIT 20000';

            System.debug(dealerByMppsList + ' :: dealerByMppsList');
            // 최종적으로 필요한 부품정보
            set<String> materialFilter = new set<String>();
    
            // 파츠별로 마지막 파츠정보
            Map<String,ProductByPlant__c> partByLastpartMap = new Map<String,ProductByPlant__c>();
            // Last Part ICCTD = I이고 라스트 품번
            Map<String,ProductByPlant__c> lastpartDetailMap = new Map<String,ProductByPlant__c>();
            //Last Part의 DueIn, DueOut
            Map<String,LastPart> lastPartInOutMpa = new Map<String,LastPart>();
            // 부품별 가격,DNS재고확인
            Map<String,IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL> partByIfDataMap = new Map<String,IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL>();
            // 타대리점 재고
            Map<String,Decimal> partByOtherStokMap = new Map<String,Decimal>();
           
            if(dealerByMppsList.size() > 0) {
                // 시작 데이터 Indx 부터 End Indx까지
                Set<String> partCodeSet = new Set<String>();
                //21 
                for(Integer i=startIdx-1; i<dealerByMppsList.size(); i++) {
                    if(i < endIdx) {
                        if(String.isNotBlank(dealerByMppsList[i].Part__r.ProductCode.toUpperCase())) {
                            partCodeSet.add(dealerByMppsList[i].Part__r.ProductCode.toUpperCase());
                            partIdSet.add(dealerByMppsList[i].Part__c);
                        }
                    }
                }
                if(partCodeSet.size() > 0) {
                    partByIfDataMap = getIFDATA(partCodeSet);
                    partByOtherStokMap = otherStock(partCodeSet);
                }

                if(partIdSet.size() > 0) {
                    lastpartDetailMap = getDetailLastPart(partIdSet);
                    partByLastpartMap = getLastPart(partIdSet); 
                }

                for(Integer i=startIdx-1; i<dealerByMppsList.size(); i++) {
                    if(i < endIdx) {
                        DealerPartMasterByMPPS__c wrapper = dealerByMppsList[i];
                        POListReview poList = new POListReview(wrapper);
                        Boolean isLastpart = false;

                        ProductByPlant__c materialInfo = partByLastpartMap.get(wrapper.Part__r.ProductCode);
                        poList.lastParts = '';
                        if(materialInfo !=null) {
                            poList.lastParts = materialInfo.LastPart__r.ProductCode;
                            if(poList.pdt == null || poList.pdt == 0) poList.pdt = materialInfo.PlannedDeliveryDay__c;
                        }
                        
                        if(lastpartDetailMap.containsKey(wrapper.Part__r.ProductCode)) isLastpart = true;
                        
                        // 부품별 가격,DNS재고확인
                        System.debug(wrapper.Part__r.ProductCode + ' :: wrapper.Part__r.ProductCode');
                        poList.price = partByIfDataMap.get(wrapper.Part__r.ProductCode) == null ? 0 :Decimal.valueOf(partByIfDataMap.get(wrapper.Part__r.ProductCode).NETPR);
                        poList.dnsQTY = partByIfDataMap.get(wrapper.Part__r.ProductCode) ==null? 0: Decimal.valueOf(partByIfDataMap.get(wrapper.Part__r.ProductCode).AVAIL_QTY);
                        // 타 대리점 재고
                        poList.otherQTY = partByOtherStokMap.get(wrapper.Part__r.ProductCode) !=null? partByOtherStokMap.get(wrapper.Part__r.ProductCode) : 0;
                        // BOQTY , PO QTY 
                        poList.boQTY = getBOQTY(wrapper);
                        poList.poQTY = getPOQTY(wrapper, (String) returnPage.strQuery.get('POReview'), isLastpart);
                        if( String.valueOf(returnPage.strQuery.get('isPOCheck')) == 'true' && returnPage.strQuery.get('POReview') == 'BackorderOnly') {
                            if(poList.poQTY > 0) {
                                returnPage.recordList.add(poList);
                            }
                        } else {
                            returnPage.recordList.add(poList);  
                        }
                    } else {
                        break;
                    }
                }
                
                // 엑셀 데이터 로드 유무
                if(!isExcelLoad) {
                    returnPage.totalRecordSize = Database.countQuery(dataCountQuery);
                    returnPage.startIdx = startIdx;
                    returnPage.endIdx = endIdx;
                    returnPage.currentPage = nextPage;
                }
                System.debug(returnPage.recordList + '  ::: returnPage.recordList');
            }
            return returnPage;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            throw new DN_POListReviewControllerControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 컨디션에 따른 부품목록 리턴
    **/ 
    public static Map<String, Object> getPartList(Map<String,Object> strQuery, Integer limitSet){
        Map<String, Object> partMap = new Map<String, Object>();
        Set<String> partIdSet = new Set<String>();
        Set<String> materialSet = new Set<String>();
        partMap.put('materialSet', materialSet);
        partMap.put('partIdSet', partIdSet);

        String condition = (String) strQuery.get('POReview');
        Map<String,List<sObject>> returnMap = new Map<String,List<sObject>>();
        String delaerOrderItemQ =' SELECT Id,Part__c, Part__r.ProductCode FROM DealerOrderItem__c WHERE Order__r.Dealer__c =\'' +currentUser.getAgencyId()+ '\' AND Delete__c !=\'Y\'  ';
        String dealerFreeDispatchQ ='SELECT Id,FM_Part__c, OrderItem__r.Product__c   FROM DealerFreeDispatch__c WHERE Dealer__c =\'' +currentUser.getAgencyId()+ '\' AND Delete__c !=\'Y\' ';
        //String mrpBatchQ = ' SELECT Id, Part__c,Part__r.ProductCode FROM DealerPartMasterByMPPS__c where MRPType__c =\'VB\' AND Part__c !=null ';
        // 컨디션에 따른 쿼리 설정
        switch on condition {
            when 'BackorderOnly' {         
                if((String) strQuery.get('docDateStart') !=null) {
                    delaerOrderItemQ += ' AND DAY_ONLY(CreatedDate ) >= '+ (String)strQuery.get('docDateStart');
                    dealerFreeDispatchQ += ' AND DAY_ONLY(CreatedDate ) >= '+ (String)strQuery.get('docDateStart');
                }
                if((String) strQuery.get('docDateEnd') !=null) {
                    delaerOrderItemQ += ' AND DAY_ONLY(CreatedDate ) <= '+ (String)strQuery.get('docDateEnd');
                    dealerFreeDispatchQ += ' AND DAY_ONLY(CreatedDate ) <= '+ (String)strQuery.get('docDateEnd');
                }
            }
            when 'MRPBatch' {
                return partMap;
            }
            when else {}
        }
        List<DealerOrderItem__c> orderItemList = Database.query(delaerOrderItemQ +' LIMIT 10000');    
        List<DealerFreeDispatch__c> freeDispatchList = Database.query(dealerFreeDispatchQ +' LIMIT 10000');    
        for(DealerOrderItem__c order : orderItemList) {
            materialSet.add(order.Part__r.ProductCode);
            partIdSet.add(order.Part__c);
        }
        for(DealerFreeDispatch__c free : freeDispatchList) {
            materialSet.add(free.FM_Part__c);
            partIdSet.add(free.OrderItem__r.Product__c);
        }

        
    
        return partMap;
    }

    /**
     * @Description
     * 	- 현재 Part 기준으로 LastPart 정보
    **/ 
    public static Map<String,ProductByPlant__c> getLastPart(Set<String> materialSet) {
        Map<String,ProductByPlant__c> lastPartMap = new Map<String,ProductByPlant__c>();
        for(ProductByPlant__c prod : [SELECT 
                Id, Name, Plant__c, Part__r.ProductCode, LastPart__r.ProductCode, PlannedDeliveryDay__c 
            FROM ProductByPlant__c 
            WHERE Plant__c ='1846' AND Part__c IN : materialSet ]
        ) {
            lastPartMap.put(prod.Part__r.ProductCode,prod);
        }
        return lastPartMap;
    }

    /**
     * 3. PO Qty = 0 이고 Material = Last Parts 이고 대체이전품과의 관계가 'I'(단방향) 일 경우		
        대체 이전품의 Dueout, Duein, 가용재고를 제외한 본인 품번만의 수량으로 계산		
        PO Qty = DueOut - 가용재고 - DueIn ( PO Qty < 0 이면 PO Qty = 0)		
        조건에 해당하는 파츠의 DueOut, DueIn 정보 
    */
    public static Map<String,ProductByPlant__c> getDetailLastPart(set<String> materialSet) {
        Map<String,ProductByPlant__c> returnMap = new Map<String,ProductByPlant__c>();
        List<ProductByPlant__c> prodByList = [
            SELECT Id, Name, Plant__c,ReplacingPart__c ,Part__r.FM_MaterialDetails__c,
            Part__r.ProductCode, LastPart__r.ProductCode,
            InterchangeabilityCode__c , PlannedDeliveryDay__c
            FROM ProductByPlant__c 
            WHERE Plant__c ='1846'
            AND ReplacingPart__c = null
            AND LastPart__c IN : materialSet
            AND InterchangeabilityCode__c ='I' 
        ];  
        for(ProductByPlant__c prod : prodByList) {
            returnMap.put(prod.Part__r.ProductCode, prod);
        }    
        return returnMap;
    }

    /**
     * @Description
     * 	- 멀티 부품 파츠 조회해 - 가격정보, DNS재고 정보
    **/ 
    public static Map<String,IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL> getIFDATA(set<STring> materialSet) {
        try {
            Map<String,IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL> returnMap = new Map<String,IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL>();
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req req = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req();
            req.I_LANGU = currentUser.getLanguageLocaleKey().subString(0,2);//user.LanguageLocaleKey;
            List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL> D_DETAIL_List = new List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL>();
            
            for(String key : materialSet) {
                IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL D_DETAIL = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL();
                D_DETAIL.MATNR = key;
                D_DETAIL_List.add(D_DETAIL);
            }

            req.D_DETAIL = D_DETAIL_List;
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO();
            I_USERINFO.KUNNR        = currentUser.getAgencyCustomerCode();
            I_USERINFO.VKORG        = currentUser.getSalesOranization();
            I_USERINFO.VTWEG        = currentUser.getDistributionChannel();
            I_USERINFO.SPART        = currentUser.getDivision();
            I_USERINFO.LAND1        = currentUser.getLanguageLocaleKey().subString(0,2);//currentUser.getLanguageLocaleKey(); //user.get('Country__c') ==null ? 'KR' : user.Country__c;
            I_USERINFO.DF_CHK       = 'X';
            req.I_USERINFO        = I_USERINFO;

            IF_ERP_Parts_Multipart instance = new IF_ERP_Parts_Multipart();
            
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res result = instance.IF_PARTS_022(req);
            System.debug(result + ' ::: result');
            for(IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL detail : result.D_DETAIL) {
                System.debug(detail.MATNR + ' :::111111');
                returnMap.put(detail.MATNR, detail);
            }
            return returnMap;
        } catch (Exception e) {
            System.debug('Emsg :: '+e.getMessage());
            System.debug('Line :: '+e.getLineNumber());
            System.debug('Stack :: '+e.getStackTraceString());
            throw new DN_POListReviewControllerControllerException(e.getMessage());
        } 
    }

    /**
     * @Description
     * 	- 타대리점 재고
    **/ 
    public static Map<String,Decimal> otherStock(set<STring> materialSet){
        try {
            System.debug(materialSet + ' :: materialSet');
            Map<String,Decimal> returnMap = new Map<String,Decimal>();
            List<AggregateResult> aggreList = [
                SELECT Part__r.ProductCode, 
                MAX(AvailableQuantity__c) AvailableQuantity__c,
                MAX(CurrentStockQuantity__c ) CurrentStockQuantity__c
                FROM DealerStock__c  
                WHERE Part__r.ProductCode IN:materialSet
                AND Dealer__c !=:currentUser.getAgencyId()
                group by Part__r.ProductCode
            ];
            System.debug(aggreList  +' ::: aggreList');
            for(AggregateResult ages : aggreList) {
                returnMap.put( (String) ages.get('ProductCode'), (Decimal) ages.get('AvailableQuantity__c') );
            }       
            return returnMap;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' message');
            System.debug(e.getStackTraceString() + ' StackTraceString');
            throw new DN_POListReviewControllerControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- PO QTY 계산식
    **/ 
    public static Decimal getPOQTY(DealerPartMasterByMPPS__c prod, String condition, Boolean isLastpart) { 
        Decimal poQTY = 0; //POReview //BackorderOnly //MRPBatch
        Decimal availableQTY = prod.DealerStock__c != null? prod.DealerStock__r?.CurrentStockQuantity__c : 0;
        Decimal dueIn = prod.DueIn__c !=null ? prod.DueIn__c:0;

        if(prod.MRPType__c =='VB') {
            if((availableQTY + dueIn - prod.FM_DueOut__c) < prod.ReorderPoint__c) {
                // 1. (가용재고 + DueIn - DueOut) < ROP 이면 PO Qty = Max Lv. - (가용재고 + DueIn - DueOut)	
                poQTY = prod.MaximumStock__c - (availableQTY + dueIn - prod.FM_DueOut__c);
            } else {
                //2.  Min Lot 반영	
                poQTY = prod.MinimumLotSize__c;
            }
            //PO Qty < Min Lot 이면 PO Qty = Min Lot
            if(poQTY < prod.MinimumLotSize__c) {
                poQTY = prod.MinimumLotSize__c;
            }
            //3. Round Value 반영 Ex.) PO Qty 가 4 R-Val 이 3 일 경우 PO Qty = 6 

            if(poQTY > prod.RoundingValue__c) {
                if(prod.RoundingValue__c >0) {
                    poQTY = Math.ceil((Decimal)poQTY / prod.RoundingValue__c) * prod.RoundingValue__c; // 3,6,90
                }
            } else {
                poQTY = prod.RoundingValue__c;
            }
        }else if(prod.MRPType__c =='ND' || condition == 'BackorderOnly') { //2. MRP TYPE 'ND' 또는 Backorder Only 조회 일 경우	
            //PO Qty = DueOut - 가용재고 - DueIn ( PO Qty < 0 이면 PO Qty = 0)	
            poQTY = prod.FM_DueOut__c - availableQTY - dueIn;
            poQTY = poQTY < 0 ? 0 : poQTY;
            //ABC 등급이 'M', 'P', 'S', 'Z' 가 아닐 경우 Min Lot 반영, Round Value 반영	
            if(prod.ABCIndicator__c != null || !'M,P,S,Z'.contains(prod.ABCIndicator__c)) {
                if(poQty < prod.MinimumLotSize__c) {
                    poQTY = prod.MinimumLotSize__c;
                }

                if(poQTY > prod.RoundingValue__c) {
                    poQTY = Math.ceil((Decimal)poQTY / prod.RoundingValue__c) * prod.RoundingValue__c;
                } else {
                    poQTY = prod.RoundingValue__c;
                }
            }
        }

        //3. PO Qty = 0 이고 Material = Last Parts 이고 대체이전품과의 관계가 'I'(단방향) 일 경우	
        if(poQTY ==0) {
            if(isLastpart) {
                //추후 수정이 필요함
                // 대체 이전품의 Dueout, Duein, 가용재고를 제외한 본인 품번만의 수량으로 계산	
                // PO Qty = DueOut - 가용재고 - DueIn ( PO Qty < 0 이면 PO Qty = 0)	
                poQTY = prod.FM_DueOut__c - availableQTY - dueIn;
                poQTY = poQTY < 0 ? 0 : poQTY;
            }
        }
        return poQTY;
    }
    
    /**
     * @Description
     * 	- BOQTY Due Out - 가용재고 - Duein 계산수량이 < 0 경우 BO Qty = 0
    **/ 
    public static Decimal getBOQTY(DealerPartMasterByMPPS__c prod) {
        System.debug(prod.FM_DueOut__c + ' :: prod.FM_DueOut__c');
        System.debug(prod.DealerStock__r.AvailableQuantity__c + ' :: prod.DealerStock__r.AvailableQuantity__c');
        System.debug(prod.DueIn__c + ' ::: prod.DueIn__c');
        Decimal availableQTY = prod.DealerStock__c !=null? prod.DealerStock__r.CurrentStockQuantity__c : 0;
        Decimal dueIn = prod.DueIn__c !=null ? prod.DueIn__c : 0;
        Decimal boQTY = prod.FM_DueOut__c  - availableQTY - dueIn;
        if(boQTY < 0) {
            boQTY = 0;
        }
        return boQTY;
    }

    /**
     * @Description
     * 	- Due Out 디테일 정보
    **/ 
    @AuraEnabled
    public static List<Details> dueOutDetails(String partCode){
        try {
            System.debug(partCode + ' :: partCode');
            List<Details> returnList = new List<Details>();
            List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS> etCrossList = replacingPart(partCode);
            
            System.debug(etCrossList + ' :: etCrossList');
            set<String> partSet = new set<String>();
            Map<String,String> icaMap = new Map<String,String>();
            for(IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS etCross :  etCrossList) {
                partSet.add(etCross.MATNR);
                icaMap.put(etCross.MATNR,etCross.ITCCD);
            }
            System.debug( partSet + ' :: partSet');
            List<DealerOrderItem__c> dealerOrderItemList = [
                SELECT Id,FM_OrderNumber__c,OrderItemNumber__c,Part__r.ProductCode,
                Part__r.FM_MaterialDetails__c,
                Order__r.FM_CustomerName__c,
                Quantity__c,
                GICompletedQuantity__c,
                FM_PendingQuantity__c,
                CreatedDate  
                FROM DealerOrderItem__c 
                WHERE Part__r.ProductCode IN :partSet
                AND Delete__c !='Y'
                AND Order__r.Dealer__c =:currentUser.getAgencyId()
                AND ( CreatedDate = LAST_N_MONTHS:7 OR CreatedDate = THIS_MONTH)
            ];
            List<DealerFreeDispatch__c> dealerFreeList = [
                SELECT Id,FM_OrderNumber__c,
                FM_OrderItemNumber__c,
                FM_Part__c,OrderItem__r.Product__r.FM_MaterialDetails__c,
                OrderItem__r.WorkOrder.Case.Account.Name,CreatedDate,
                FM_RequestQuantity__c,ShippingQuantity__c 
                FROM DealerFreeDispatch__c  
                WHERE Delete__c !='Y'
                AND FM_Part__c IN :partSet
                AND Dealer__c =:currentUser.getAgencyId() 
                AND ( CreatedDate = LAST_N_MONTHS:7 OR CreatedDate = THIS_MONTH)
            ];
            System.debug(dealerOrderItemList + ' ::dealerOrderItemList');
            for(DealerOrderItem__c orderItem : dealerOrderItemList) {
                Details detail = new Details();
                detail.docNo = orderItem.FM_OrderNumber__c;
                detail.item = orderItem.OrderItemNumber__c;
                detail.ica = icaMap.get(orderItem.Part__r.ProductCode)==null? '': icaMap.get(orderItem.Part__r.ProductCode);
                detail.material = orderItem.Part__r.ProductCode;
                detail.materialDesc = orderItem.Part__r.FM_MaterialDetails__c;
                detail.customerName = orderItem.Order__r.FM_CustomerName__c;
                detail.orderQty = orderItem.Quantity__c;
                detail.release = orderItem.GICompletedQuantity__c;
                detail.unRelease = orderItem.FM_PendingQuantity__c;
                detail.docDate = orderItem.CreatedDate.format('YYYY.MM.dd');
                returnList.add(detail);
            }
            for(DealerFreeDispatch__c free : dealerFreeList) {
                Details detail = new Details();
                detail.docNo = free.FM_OrderNumber__c;
                detail.item = free.FM_OrderItemNumber__c;
                detail.ica = icaMap.get(free.FM_Part__c)==null? '': icaMap.get(free.FM_Part__c);
                detail.material = free.FM_Part__c;
                detail.materialDesc = free.OrderItem__r.Product__r.FM_MaterialDetails__c;
                detail.customerName = free.OrderItem__r.WorkOrder.Case.Account.Name;
                detail.orderQty = free.FM_RequestQuantity__c == null ? 0 : free.FM_RequestQuantity__c;
                detail.release = free.ShippingQuantity__c == null ? 0 : free.ShippingQuantity__c;
                detail.unRelease = detail.orderQty - detail.release;
                detail.docDate = free.CreatedDate.format('YYYY.MM.dd');
                returnList.add(detail);
            }
            System.debug(dealerOrderItemList + ' :: dealerOrderItemList');
            System.debug(dealerFreeList + ' :: dealerFreeList');
            System.debug(returnList + ' ::: returnList');
            return returnList;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' message');
            System.debug(e.getStackTraceString() + ' StackTraceString');
            throw new DN_POListReviewControllerControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- Due In 디테일 정보
    **/ 
    @AuraEnabled
    public static List<Details> dueInDetails(String partCode){
        try {
            List<Details> returnList = new List<Details>();
            List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS> etCrossList = replacingPart(partCode);
            set<String> partSet = new set<String>();
            for(IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS etCross :  etCrossList) {
                partSet.add(etCross.MATNR);
                
            }
            // 대리점 구매
            List<DealerPurchaseOrderItem__c> dealerPurItemList = [
                SELECT Id,FM_OrderNumber__c,
                OrderItemNumber__c,Part__r.ProductCode,
                DealerPurchaseOrder__r.Customer__r.Name,
                Part__r.FM_MaterialDetails__c,
                DealerPurchaseOrder__r.Dealer__r.Name,
                Quantity__c,CreatedDate 
                FROM DealerPurchaseOrderItem__c 
                WHERE DealerPurchaseOrder__r.Dealer__c =:currentUser.getAgencyId()
                AND ( CreatedDate = LAST_N_MONTHS:7 OR CreatedDate = THIS_MONTH)
                AND Part__r.ProductCode IN : partSet
            ];
            set<String> dealerOrderIds = new set<String>();
            for(DealerPurchaseOrderItem__c dealerItem : dealerPurItemList) {
                dealerOrderIds.add(dealerItem.Id);
            }
            
            // 출고 수량
            Map<String,Decimal> giMap = new Map<String,Decimal>();
            List<AggregateResult> giList = [
                SELECT DealerPurchaseOrderItem__c ,SUM(Quantity__c) Quantity__c FROM DealerInventoryMovements__c
                WHERE DealerPurchaseOrderItem__c  IN:dealerOrderIds
                AND RecordType.DeveloperName ='GoodsIssue'
                AND InventoryChange__c ='H'
                GROUP BY DealerPurchaseOrderItem__c 
            ];
            for(AggregateResult gi : giList) {
                giMap.put((String) gi.get('DealerPurchaseOrderItem__c'), (Decimal) gi.get('Quantity__c'));
            }
            // 입고 수량
            Map<String,Decimal> grMap = new Map<String,Decimal>();
            List<AggregateResult> grList = [
                SELECT DealerPurchaseOrderItem__c ,SUM(Quantity__c) Quantity__c FROM DealerInventoryMovements__c
                WHERE DealerPurchaseOrderItem__c  IN:dealerOrderIds
                AND RecordType.DeveloperName ='GoodsReceipt'
                AND InventoryChange__c ='S'
                GROUP BY DealerPurchaseOrderItem__c 
            ];
            for(AggregateResult gr : grList) {
                grMap.put((String) gr.get('DealerPurchaseOrderItem__c'), (Decimal) gr.get('Quantity__c'));
            }
            // 대리점 아이템
            for(DealerPurchaseOrderItem__c dealerPur : dealerPurItemList) {
                Decimal giQty = giMap.get(dealerPur.Id) == null ? 0 : giMap.get(dealerPur.Id);
                Decimal grQty = grMap.get(dealerPur.Id) == null ? 0 : grMap.get(dealerPur.Id);
                Details details  = new Details();
                details.docNo                   = dealerPur.FM_OrderNumber__c;
                details.item                    = dealerPur.OrderItemNumber__c;
                details.material                = dealerPur.Part__r.ProductCode;
                details.materialDesc            = dealerPur.Part__r.FM_MaterialDetails__c;
                details.customerName            = dealerPur.DealerPurchaseOrder__r.Customer__r.Name;
                details.orderQty                = dealerPur.Quantity__c;
                details.confirmQty              = 0;
                details.waitingQty              = (dealerPur.Quantity__c - giQty);
                details.release                 = giQty;
                details.grQty                   = grQty;
                details.unRelease               = (giQty -grQty); // 출고처리보다 입고를 먼저한 경우 0으로 표기
                details.docDate                 = dealerPur.CreatedDate.format('YYYY.MM.dd');
                details.etd                     = '0000.00.00';
                returnList.add(details);
            }
            
            // DNS 구매아이템
            List<PurchaseOrderItems__c> purOrderList = [
                SELECT Id, PurchaseOrder__r.PartOrderNo__c,
                ItemNo__c,OrderPartId__r.ProductCode,
                OrderPartId__r.FM_MaterialDetails__c,
                DepartureSite__c,Quantity__c,
                ConfirmedQty__c,PenddingQty__c,
                CompletedQty__c,CreatedDate,
                ExpectedSupplyDate__c 
                FROM PurchaseOrderItems__c 
                WHERE PurchaseOrder__r.RecordType.DeveloperName ='Order' 
                AND PurchaseOrder__r.Buyer__r.Name =:currentUser.getAgencyId() 
                AND ( CreatedDate = LAST_N_MONTHS:7 OR CreatedDate = THIS_MONTH) 
            ];
            set<String> purIds = new set<String>();
            for(PurchaseOrderItems__c ordes : purOrderList) {
                purIds.add(ordes.Id);
            }
            
            // 입고 수량
            Map<String,Decimal> dnsGrMap = new Map<String,Decimal>();
            List<AggregateResult> dnsGrList = [
                SELECT PurchaseOrderItem__c,SUM(Quantity__c) Quantity__c FROM DealerInventoryMovements__c
                WHERE PurchaseOrderItem__c IN:purIds
                AND RecordType.DeveloperName ='GoodsReceipt'
                AND InventoryChange__c ='S'
                GROUP BY PurchaseOrderItem__c
            ];
            for(AggregateResult gr : grList) {
                dnsGrMap.put((String) gr.get('PurchaseOrderItem__c'), (Decimal) gr.get('Quantity__c'));
            }
            // 대리점 아이템
            for(PurchaseOrderItems__c purItem : purOrderList) {
                Decimal grQty = grMap.get(purItem.Id) == null ? 0 : grMap.get(purItem.Id);
                Details details  = new Details();
                details.docNo                   = purItem.PurchaseOrder__r.PartOrderNo__c;
                details.item                    = purItem.ItemNo__c;
                details.material                = purItem.OrderPartId__r.ProductCode;
                details.materialDesc            = purItem.OrderPartId__r.FM_MaterialDetails__c;
                details.customerName            = '디엔솔루션즈 부품';
                details.orderQty                = purItem.Quantity__c;
                details.confirmQty              = purItem.ConfirmedQty__c;
                details.waitingQty              = purItem.PenddingQty__c;
                details.release                 = purItem.CompletedQty__c;
                details.grQty                   = grQty;
                details.unRelease               = (purItem.CompletedQty__c -grQty);
                details.docDate                 = purItem.CreatedDate.format('YYYY.MM.dd');
                DateTime myDateTime             = DateTime.newInstance(purItem.ExpectedSupplyDate__c, Time.newInstance(0, 0, 0, 0));
                details.etd                     = myDateTime.format('YYYY.MM.dd');
                returnList.add(details);
            }
            List<DealerOrderSummary__c> orderSum = [select Id, Part__r.ProductCode, PartCode__c from DealerOrderSummary__c  where Dealer__c ='001F700001jPza0IAC' AND Part__c =null];
            set<String> prodIds = new set<String>();
            for(DealerOrderSummary__c sums : orderSum) {
                prodIds.add(sums.PartCode__c);
            }
            return returnList;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' message');
            System.debug(e.getStackTraceString() + ' StackTraceString');
            throw new DN_POListReviewControllerControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 부품별 디테일 정보 리턴
    **/ 
    @AuraEnabled
    public static List<Details> getStock(String partCode){
        try {
            List<Details> returnList = new List<Details>();
            List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS> etCrossList = replacingPart(partCode);
            set<String> partSet = new set<String>();
            Map<String,IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS> partByIFMap = new Map<String,IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS>();
            for(IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS etCross :  etCrossList) {
                partSet.add(etCross.MATNR);
                partByIFMap.put(etCross.MATNR,etCross);
            }
            Map<String,Decimal> stockMap = new Map<String,Decimal>();
            List<DealerStock__c> stockList = [
                SELECT Id,Name,Part__c,
                Part__r.ProductCode,
                Part__r.FM_MaterialDetails__c,
                AvailableQuantity__c,
                CurrentStockQuantity__c 
                FROM DealerStock__c
                WHERE Part__r.ProductCode IN : partSet
                AND Dealer__c =:currentUser.getAgencyId()
            ];
            for(DealerStock__c stock : stockList) {
                stockMap.put(stock.Part__r.ProductCode, stock.CurrentStockQuantity__c);
            }

            Map<String,String> partByPlant = new Map<String,String>();
            List<ProductByPlant__c> prodByPlantList = [
                SELECT Id, Name,
                Part__c,Part__r.ProductCode,
                ReplacingPart__c,ReplacingPart__r.ProductCode
                FROM ProductByPlant__c
                WHERE Part__r.ProductCode IN:partSet
            ];
            for(ProductByPlant__c prodBy : prodByPlantList) {
                partByPlant.put(prodBy.Part__r.ProductCode,prodBy.ReplacingPart__r.ProductCode);
            }
            for(String parts : partSet) {
                Details details = new Details();
                details.seq = partByIFMap.get(parts).SEQ;
                details.material = partByIFMap.get(parts).MATNR;
                details.materialDesc = partByIFMap.get(parts).MAKTX;
                details.replacingPart = partByPlant.get(parts);
                details.ica = partByIFMap.get(parts).ITCCD;
                details.stockQty = stockMap.get(parts) ==null ? 0 : stockMap.get(parts);
                returnList.add(details);
            }
            return returnList;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' message');
            System.debug(e.getStackTraceString() + ' StackTraceString');
            throw new DN_POListReviewControllerControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- AMD 정보 리턴
    **/ 
    @AuraEnabled
    public static List<WAMD> getAMD(String partCode){
        try {
            List<Monthly> monthlyList = new List<Monthly>();
            List<DealerAreaByMPPS__c> dealerAreaBy = [select Id, Name, Dealer__r.Name, Area__r.Name,Area__r.Area__c from DealerAreaByMPPS__c where Dealer__c =:currentUser.getAgencyId()];
            String areaName = '';
            String areaLabel = '';
            if(dealerAreaBy.size() > 0) {
                areaName = dealerAreaBy[0].Area__r.Area__c;
                areaLabel = dealerAreaBy[0].Area__r.Name;
            } else {
                throw new DN_POListReviewControllerControllerException('현재 지역정보가 없습니다. 관리자에게 문의하세요');
            }
            // 현재 날짜 기준으로 연도와 월 계산
            Date today = System.today();
        
            Date date18M = today.addMonths(-18);
            // "YYYYMM" 포맷으로 변환 (텍스트 필드 비교용)
            String todayStr     = today.year() + String.valueOf(today.month()).leftPad(2, '0');
            String period18M = date18M.year() + String.valueOf(date18M.month()).leftPad(2, '0');
            List<Details> returnList = new List<Details>();
            Map<String,Decimal> dealerQTYMap = new Map<String,Decimal>();
            Map<String,Decimal> areaQTYMap = new Map<String,Decimal>();
            Map<String,Decimal> otherAreaQTYMap = new Map<String,Decimal>();
            //대리점별 부품별 합산정보
            List<AggregateResult> ageList = [
                SELECT Part__r.ProductCode, AnalysisPeriodMonth__c,  
                SUM(FM_TotalQuantity__c) FM_TotalQuantity__c
                FROM MonthlyDemandSummaryByDealer__c 
                WHERE Part__c =:partCode
                AND AnalysisPeriodMonth__c >=:period18M
                AND AnalysisPeriodMonth__c <:todayStr  
                group by Part__r.ProductCode,AnalysisPeriodMonth__c 
                ORDER BY Part__r.ProductCode ASC
            ];
            for(AggregateResult dealer: ageList) {
                dealerQTYMap.put( (String)dealer.get('AnalysisPeriodMonth__c'), (Decimal)dealer.get('FM_TotalQuantity__c'));
            }
            // 본인 지역
            List<AggregateResult> areaList = [
                SELECT Part__r.ProductCode, 
                Area__r.Name,AnalysisPeriodMonth__c, 
                SUM(FM_TotalQuantity__c) FM_TotalQuantity__c  
                FROM MonthlyDemandSummaryByRegion__c  
                WHERE Part__c =:partCode
                AND Area__r.Area__c =:areaName
                AND AnalysisPeriodMonth__c >=:period18M
                AND AnalysisPeriodMonth__c <:todayStr  
                group by Part__r.ProductCode,Area__r.Name,AnalysisPeriodMonth__c
            ];
            for(AggregateResult area : areaList) {
                areaQTYMap.put((String) area.get('AnalysisPeriodMonth__c'), (Decimal) area.get('FM_TotalQuantity__c'));
            }
            //본인 지역 외
            List<AggregateResult> otherAreaList = [
                SELECT Part__r.ProductCode, 
                AnalysisPeriodMonth__c, 
                SUM(FM_TotalQuantity__c) FM_TotalQuantity__c  
                FROM MonthlyDemandSummaryByRegion__c  
                WHERE Part__c =:partCode
                AND Area__r.Area__c =:areaName
                AND AnalysisPeriodMonth__c >=:period18M
                AND AnalysisPeriodMonth__c <:todayStr  
                group by Part__r.ProductCode,AnalysisPeriodMonth__c
            ];
            for(AggregateResult other : otherAreaList) {
                otherAreaQTYMap.put((String) other.get('AnalysisPeriodMonth__c'), (Decimal) other.get('FM_TotalQuantity__c'));
            }
            

            //날짜 설정
            DateTime currentDate = DateTime.now();
            for (Integer j = 17; j >= 0; j--) {
                String yyyymm =DN_DealerStockManager.getPastMonths(currentDate, -j);
                String mKey = 'm' + String.valueOf(j);
                Decimal dealerQty = dealerQTYMap.get(yyyymm) == null ? 0 : dealerQTYMap.get(yyyymm);
                Decimal areaQty = areaQTYMap.get(yyyymm) == null ? 0 : areaQTYMap.get(yyyymm);
                Decimal otherAreaQty = otherAreaQTYMap.get(yyyymm) == null ? 0 : otherAreaQTYMap.get(yyyymm);
                Monthly monthBy  = new Monthly(mKey,yyyymm,dealerQty,areaQty,otherAreaQty);
                monthlyList.add(monthBy);
            }
            List<WAMD> wamdList = new List<WAMD>();
            WAMD dealerWamd = new WAMD();
            dealerWamd.name = currentUser.getAgencyName(); // 대리점명
            dealerWamd.wamdType = 'dealer';
            dealerWamd.monthlyList = monthlyList;
            WAMD areaWamd = new WAMD();
            areaWamd.name = areaLabel; // 지역명
            areaWamd.wamdType = 'area';
            areaWamd.monthlyList = monthlyList;
            WAMD allAreaWamd = new WAMD();
            allAreaWamd.name = '국내전체'; // 지역명
            allAreaWamd.wamdType = 'all';
            allAreaWamd.monthlyList = monthlyList;
            wamdList.add(dealerWamd);
            wamdList.add(areaWamd);
            wamdList.add(allAreaWamd);

            return wamdList;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' message');
            System.debug(e.getStackTraceString() + ' StackTraceString');
            throw new DN_POListReviewControllerControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 대체품 정보 조회
    **/ 
    public static List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS> replacingPart(String productCode){
        try {
            System.debug(productCode + ' ::: productCode');
            List<Product2> productCheck = [SELECT Id FROM Product2 WHERE ProductCode =:productCode AND RecordType.DeveloperName = 'Part'];
            if(productCheck.size() >0) {
                IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req_I_USERINFO i_userinfo = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req_I_USERINFO();
                i_userinfo.KUNNR = currentUser.getAgencyCustomerCode();
                i_userinfo.VKORG = currentUser.getSalesOranization();
                i_userinfo.VTWEG = currentUser.getDistributionChannel();
                i_userinfo.SPART = currentUser.getDivision();
            
                IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req req = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req();

                req.I_MATNR = productCode;
                req.I_LANGU = currentUser.getLanguageLocaleKey().subString(0,2);//user.LanguageLocaleKey;
                //req.I_REPLACE = 'X'; //??? 
                req.I_USERINFO = i_userinfo;
                Map<String,String> getStockQTYMap = new Map<String,String>();
                IF_ERP_Service_PartsDetail method = new IF_ERP_Service_PartsDetail();
                IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res result = method.IF_SERVICE_037(req);
                System.debug(result + ' ::: IF result');
                return result.ET_CROSS;
            } else {
                throw new DN_POListReviewControllerControllerException('부품 정보가 올바르지 않습니다.');    
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage() + ' :: e.getMessage()');
            System.debug(e.getStackTraceString() + ' :: e.getStackTraceString()');
            throw new DN_POListReviewControllerControllerException(e.getMessage());
        }
    }

    
    /**
    * @description 페이지 설정
    * @author iltae.seo | 2025-02-25
    **/
    public static Map<string,Integer> setpageSetting(PageReturn returnPages, Integer nextPage) {
        Map<String,Integer> returnMap = new Map<String,Integer>();
        
        // Stage Idx, Last Idx - 인덱스 설정
        Integer startIdx = 0;
        Integer endIdx = 0;
        //페이지 클릭한 경우 처리로직 - 같은 경우 뒤로가기 또는 현재 페이지 클릭
        if(returnPages.currentPage == nextPage) {
            startIdx = (returnPages.currentPage * returnPages.itemsPerPage);
            startIdx = (startIdx - returnPages.itemsPerPage) + 1;
            endIdx = (nextPage*returnPages.itemsPerPage);    
        } else {
            startIdx = (nextPage*returnPages.itemsPerPage -returnPages.itemsPerPage) +1;//(returnPages.currentPage * returnPages.itemsPerPage)+1;
            endIdx = (nextPage*returnPages.itemsPerPage);       
        }
        Integer limitSet = startIdx + endIdx + returnPages.itemsPerPage;
        returnMap.put('limit',limitSet);
        returnMap.put('startIdx',startIdx);
        returnMap.put('endIdx',endIdx);
        return returnMap;
    }

    /**
     * Po List Review
     */
    // 데이터 리턴 페이징 처리까지
    public class PageReturn {
        @AuraEnabled public Map<String,Object> strQuery { get; set; } // 전체 데이터 쿼리
        @AuraEnabled public Integer totalRecordSize { get; set; } // 전체 레코드 사이즈
        @AuraEnabled public List<POListReview> recordList { get; set; } // 현재 페이지 데이터
        @AuraEnabled public List<POListReview> allData { get; set; } // 전체데이터
        @AuraEnabled public Integer itemsPerPage { get; set; } // 한 페이지당 표시할 데이터 수
        @AuraEnabled public Integer currentPage { get; set; } // 현재 페이지
        @AuraEnabled public Integer pagesPerGroup {get;set;} // 현재 화면에 표시할 페이지 갯수
        @AuraEnabled public Integer startIdx {get;set;} // 시작인덱스
        @AuraEnabled public Integer endIdx {get;set;} // 마지막인덱스
        @AuraEnabled public String orderByField {get;set;} // 정렬 필드,
        @AuraEnabled public String orderBy {get;set;} // 정렬 필드,
        @AuraEnabled public String query {get;set;}
        public PageReturn() {} 
    }

    public class POListReview {
        @AuraEnabled public String material         { get; set; } // Material
        @AuraEnabled public String materialDesc     { get; set; } // Material Desc.
        @AuraEnabled public String lastParts        { get; set; } // Last Parts
        @AuraEnabled public Decimal boQTY           { get; set; } // BO Qty
        @AuraEnabled public Decimal poQTY           { get; set; } // PO Qty
        @AuraEnabled public Decimal price           { get; set; } // Price
        @AuraEnabled public Decimal availableQTY    { get; set; } // 가용재고
        @AuraEnabled public Decimal dnsQTY          { get; set; } // DNS 재고	
        @AuraEnabled public Decimal otherQTY        { get; set; } // 타대리점 재고	
        @AuraEnabled public Decimal dueOut          { get; set; } // Due Out	
        @AuraEnabled public Decimal dueIn           { get; set; } // Due In		
        @AuraEnabled public Decimal wAMD            { get; set; } // W.AMD		
        @AuraEnabled public String mrpType          { get; set; } // MRP Type	
        @AuraEnabled public Decimal rop             { get; set; } // ROP	
        @AuraEnabled public Decimal maxLv           { get; set; } // Max Lv.		
        @AuraEnabled public Decimal minLot          { get; set; } // Min Lot		
        @AuraEnabled public Decimal rVal            { get; set; } // R-VAL		
        @AuraEnabled public Decimal pdt             { get; set; } // PDT
        public POListReview() {}
        public POListReview(DealerPartMasterByMPPS__c byMpps) {
            this.material       = byMpps.Part__r.ProductCode;                
            this.materialDesc   = byMpps.Part__r.FM_MaterialDetails__c;                    
            this.availableQTY   = byMpps.DealerStock__r.CurrentStockQuantity__c;                    
            this.dueOut         = byMpps.FM_DueOut__c;            
            this.dueIn          = byMpps.DueIn__c !=null? byMpps.DueIn__c : 0;            
            this.wAMD           = byMpps.WAMD__c;            
            this.mrpType        = byMpps.MRPType__c;                
            this.rop            = byMpps.ReorderPoint__c;            
            this.maxLv          = byMpps.MaximumStock__c;            
            this.minLot         = byMpps.MinimumLotSize__c;            
            this.rVal           = byMpps.RoundingValue__c;            
            this.pdt            = byMpps.PlannedDeliveryDays__c;            
        }
    }

    public class LastPart {
        public Decimal dueIn         { get; set; } // dueIn
        public Decimal dueOut         { get; set; } // dueOut
    }

    public class Details {
        @AuraEnabled public String docNo { get; set; } // Doc No.
        @AuraEnabled public String item { get; set; } // Item
        @AuraEnabled public String seq { get; set; } // SEQ
        @AuraEnabled public String ica { get; set; } // ICA
        @AuraEnabled public String material { get; set; } // Material
        @AuraEnabled public String materialDesc { get; set; } // Material Desciption
        @AuraEnabled public String replacingPart { get; set; } // Replacing Parts	
        @AuraEnabled public String customerName { get; set; } // Customer Name
        @AuraEnabled public Decimal orderQty { get; set; } // Order Qty
        @AuraEnabled public Decimal confirmQty { get; set; } // 확정
        @AuraEnabled public Decimal waitingQty { get; set; } // 대기
        @AuraEnabled public Decimal release { get; set; } // 출고
        @AuraEnabled public Decimal grQty { get; set; } // 입고
        @AuraEnabled public Decimal unRelease { get; set; } // 미출고
        @AuraEnabled public String docDate { get; set; } // Doc. Date
        @AuraEnabled public Decimal stockQty { get; set; } // 대리점 재고
        @AuraEnabled public String etd { get; set; } // ETD
    }

    public class WAMD {
        @AuraEnabled public String name {get;set;}   
        @AuraEnabled public String wamdType {get;set;}   
        @AuraEnabled public List<Monthly> monthlyList {get;set;}   
        public WAMD () {
            this.monthlyList = new List<Monthly>();
        }
    }

    public class Monthly {
        @AuraEnabled public String monthKey {get;set;}
        @AuraEnabled public String yyyymm {get;set;}
        @AuraEnabled public Decimal dealaerQty {get;set;}
        @AuraEnabled public Decimal areaQty {get;set;}
        @AuraEnabled public Decimal otherQty {get;set;}
        public Monthly() {}
        public Monthly(String mKey, String yyyymm, Decimal dealaerQty, Decimal areaQty, Decimal otherQty) {
            this.monthKey       =  mKey;            
            this.yyyymm         =  yyyymm;        
            this.dealaerQty     =  dealaerQty;            
            this.areaQty        =  areaQty;        
            this.otherQty       =  otherQty;            
        }
    }



    public class DN_POListReviewControllerControllerException extends Exception {}    
}