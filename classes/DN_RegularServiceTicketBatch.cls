/**
* @Class : DN_RegularServiceTicketBatch
*
* @Author : Junyeong, Choi
* @Date : 2024. 10. 22.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-10-22 | Junyeong, Choi   | 최초작성
*  2. | 2024-12-18 | Junyeong, Choi   | Ver 2. 서비스 패키지 오브젝트 삭제. Asset 과 Product 기준으로 Ticket 생성
*  3. | 2025-03-19 | Junyeong, Choi   | Ver 3. 월 배치로 변경, 매월 초 해당 월에 생성되는 Ticket 을 한 번에 만들어준다.
*/
global class DN_RegularServiceTicketBatch implements Database.Batchable<ServicePackageProduct__c>, Database.Stateful, Database.AllowsCallouts, Schedulable{
    // Batch Start List
    public List<Product2> PDList                    = new List<Product2>();
    public List<Asset> EQList                       = new List<Asset>();
    public List<ServicePackageProduct__c> sppList   = new List<ServicePackageProduct__c>();
    public List<Campaign> cpList                    = new List<Campaign>();
    Map<Id, Id> prodForSppId                        = new Map<Id, Id>();
    Map<Id, Id> assetForSppId                       = new Map<Id, Id>();
    
    public DN_RegularServiceTicketBatch() {
        this.sppList = 
        [
            SELECT Id, Equipments__c, Product__c, Order__c, Order__r.CreatedDate, Order__r.SelectDay__c, Order__r.LastOilChangeTime__c
            FROM ServicePackageProduct__c
            WHERE Equipments__c != null
            AND Product__c != null
        ];
        System.debug('sppList' + sppList);
        SET<Id> equipIds = new Set<Id>();
        SET<Id> prodIds = new Set<Id>();
        for(ServicePackageProduct__c spp : this.sppList) {
            equipIds.add(spp.Equipments__c);
            prodIds.add(spp.Product__c);
        }
        System.debug('equipIds' + equipIds);
        System.debug('prodIds' + prodIds);

        for (ServicePackageProduct__c spp : this.sppList) {
            this.prodForSppId.put(spp.Id, spp.Product__c);
            this.assetForSppId.put(spp.Id, spp.Equipments__c);
        }
        
        this.cpList = [
            SELECT Id, CampaignType__c, RegularServiceType__c, IsActive, CreatedDate
            FROM Campaign
            WHERE CampaignType__c       = 'RegularInspections'
            AND RegularServiceType__c   = 'General Regular Service'
            AND IsActive                = true
        ];
        System.debug('cpList'+cpList);
    }

    public List<ServicePackageProduct__c> start(Database.BatchableContext context){
        return this.sppList;
    }

    public void execute(Database.BatchableContext context, List<ServicePackageProduct__c> scope) {
        try {
            System.debug(' =============== Batch Execute ================');
            System.debug('scope.Size() : ' + scope.size());
            System.debug('scope.Size() : ' + scope);

            List<Case> caseList = new List<Case>();
            List<Campaign> campaignList = cpList;
            System.debug('campaignList : ' + campaignList);
            String prodId;
            String assetId;
        
            for(ServicePackageProduct__c spp : scope) {
                prodId    = prodForSppId.get(spp.Id);
                assetId   = assetForSppId.get(spp.Id);
            }

            Product2 prod = [SELECT Id, Name, StandardDay__c, StandardOilDay__c, Field2__c, SelectDay__c, ServicePackage__c, OilChangeCycle__c FROM Product2 WHERE Id =: prodId];
            Asset asset = [SELECT Id, Name, AccountId, InstallationFinish__c FROM Asset WHERE Id =: assetId];

            for(ServicePackageProduct__c spp : scope){
                System.debug('prod : ' + prod);
                System.debug('asset : ' + asset);
                String servicePackageType = prod.ServicePackage__c;
                String oilChangeCycle = prod.OilChangeCycle__c;
                String StandardDay   = prod.StandardDay__c; // 기준일
                String standardOilDay   = prod.StandardOilDay__c; // 기준일
                String PackageInfo   = prod.Field2__c;
                System.debug('StandardDay' + StandardDay);
                System.debug('PackageInfo' + PackageInfo);  // 1개월;3개월;5개월;7개월;9개월

                // 오일교체 주기 - suheon.ha
                List<String> splitOilInfo          = oilChangeCycle.split(';');
                List<String> exceptOilInfo         = new List<String>();
                List<Integer> exceptOilInfoParse   = new List<Integer>();

                for(String oilInfo : splitOilInfo) {
                    String oilMonth = oilInfo.replaceAll('[^0-9]', '');
                    exceptOilInfo.add(oilMonth);
                }
                for(String strOilValue : exceptOilInfo) {
                    exceptOilInfoParse.add(Integer.valueOf(strOilValue));
                }

                // 기존 준영님 코드
                List<String> splitInfo          = PackageInfo.split(';');
                List<String> exceptInfo         = new List<String>();
                List<Integer> exceptInfoParse   = new List<Integer>();
                List<Date> dateList             = new List<Date>();

                for(String info : splitInfo) {
                    String month = info.replaceAll('[^0-9]', '');
                    exceptInfo.add(month);
                }

                for(String strValue : exceptInfo) {
                    exceptInfoParse.add(Integer.valueOf(strValue));
                }


                System.debug('exceptInfoParse' + exceptInfoParse);  // 1, 3, 5, 7, 9
                System.debug('asset : ' + asset);
                System.debug('asset.InstallationFinish__c : ' + asset.InstallationFinish__c);
                System.debug('assetForSppId.get(spp.Id) : ' + assetForSppId.get(spp.Id));
                // 설치일
                Date InstallDate  = asset.InstallationFinish__c;
                System.debug('InstallDate : ' + InstallDate);   // 2025. 03. 19

                // 판매일
                Date salesDate  = spp.Order__r.CreatedDate.date();
                System.debug('salesDate : ' + salesDate);

                // 지정일
                Date selectDay   = spp.Order__r.SelectDay__c; // 2025. 03. 20
                Date lastOilChangeDate   = spp.Order__r.LastOilChangeTime__c; // 2025. 03. 20
                System.debug('selectDay : ' + selectDay);
                System.debug('lastOilChangeDate : ' + lastOilChangeDate);

                // 매월 초 배치
                Date today       = System.today();    // 2025-04-01
                String yearMonth = String.valueOf(today.year()) + '_' + String.valueOf(today.month()); // 20254
                // String testOilYearMonth = '2025_5'; // 20254

                // 추후 삭제
                Date testToDay = Date.newInstance(2025, 4, 1);
                String testYearMonth = String.valueOf(testToDay.year()) + '_' + String.valueOf(testToDay.month());
                //
                if(!String.isEmpty(StandardDay) || StandardDay != null) {
                    switch on StandardDay {
                        when '설치일' {
                            System.debug('기준일 : 설치일');
                            List<Date> installDateList = new List<Date>();
                            if(InstallDate != null) {   // 2025. 03. 19
                                for(Integer addDate : exceptInfoParse) {
                                    installDateList.add(InstallDate.addMonths(addDate));
                                }
                                System.debug('installDateList : ' + installDateList); //2025-04-19, 2025-06-19, 2025-08-19, 2025-10-19, 2025-12-19
                                String cpId;
                                for(Date it : installDateList) {
                                    String itYM = String.valueOf(it.year()) + '_' + String.valueOf(it.month()); // 20254
                                    if(itYM == yearMonth) { // 이거 나중에 yearMonth 로 바꿔야 함
                                        for(Campaign cp : campaignList) {
                                            Date cpCreatedDate = cp.CreatedDate.date().addMonths(1); // 2025. 03. 31. -> 2025. 04. 
                                            if(it.year() == cpCreatedDate.year() && it.month() == cpCreatedDate.month()) {
                                                cpId = cp.Id;
                                            }
                                        }
                                        Integer monthDiffer = calMonthDiffer(today, InstallDate);
                                        Case newCase                    = new Case();
                                        newCase.Status                  = 'New';
                                        newCase.Campaign__c             = cpId;                     // 해당 Campaign의 Id 설정
                                        newCase.AssetId                 = assetId;
                                        newCase.TicketType__c           = 'Internal request';       // 내부요청
                                        newCase.InternalTicketType__c   = 'Regular Inspections';    // 정기점검
                                        newCase.AccountId	            = asset.AccountId;
                                        newCase.ReceptionDetails__c     = '서비스패키지 구매, 정기점검 ' + monthDiffer + '개월차';
                                        caseList.add(newCase);
                                    } else {
                                        System.debug('Ticket 생성 날짜가 아님');        
                                    }
                                }
                            } else {
                                System.debug('장비의 설치일자가 비워져 있음');
                                break;
                            }
                        } when '판매일' {
                            System.debug('기준일 : 판매일');
                            if(spp.Order__c != null) {
                                List<Date> salesDateList = new List<Date>();
                                for(Integer addDate : exceptInfoParse) {
                                    salesDateList.add(salesDate.addmonths(addDate));
                                }
                                System.debug('salesDateList : ' + salesDateList); //2025-04-12, 2025-06-12, 2025-08-12, 2025-10-12, 2025-12-12)
                                String cpId;
                                for(Date sd : salesDateList) {
                                    String sdYM = String.valueOf(sd.year()) + '_' + String.valueOf(sd.month()); // 20254
                                    if(sdYM == yearMonth) { // 이거 Today 로 바꿔야 함
                                        for(Campaign cp : campaignList) {
                                            Date cpCreatedDate = cp.CreatedDate.date().addMonths(1);   // 2024. 12. 31. -> 2025. 01. 31
                                            if(sd.year() == cpCreatedDate.year() && sd.month() == cpCreatedDate.month()) {
                                                cpId = cp.Id;
                                            }
                                        }
                                        Integer monthDiffer = calMonthDiffer(today, salesDate);
                                        Case newCase                    = new Case();
                                        newCase.Status                  = 'New';
                                        newCase.Campaign__c             = cpId;                     // 해당 Campaign의 Id 설정
                                        newCase.AssetId                 = assetId;
                                        newCase.TicketType__c           = 'Internal request';       // 내부요청
                                        newCase.InternalTicketType__c   = 'Regular Inspections';    // 정기점검
                                        newCase.AccountId	            = asset.AccountId;
                                        newCase.ReceptionDetails__c     = '서비스패키지 구매, 정기점검 ' + monthDiffer + '개월차';
                                        caseList.add(newCase);
                                    } else {
                                        System.debug('Ticket 생성 날짜가 아님');
                                    }
                                }
                            } else {
                                System.debug('Service Package Product 에 오더가 비워져있음');
                            }
                        } when '지정일' {
                            System.debug('기준일 : 지정일');
                            if(selectDay != null) { // 2025.03.20
                                List<Date> selectDateList = new List<Date>();
                                for(Integer addDate : exceptInfoParse) { // 1, 6, 12
                                    selectDateList.add(selectDay.addMonths(addDate)); 
                                }
                                System.debug('selectDateList : ' + selectDateList); // 2025.04.20 / 2025.09.20 / 2026.03.20
                                String cpId;
                                for(Date sl : selectDateList) {
                                    String slYM = String.valueOf(sl.year()) + '_' + String.valueOf(sl.month()); // 20254 / 20259 / 20263
                                    System.debug('slYM =>' + slYM);
                                    if(slYM == yearMonth) { // 이거 Today 로 바꿔야 함
                                        System.debug('yearMonth =>' + yearMonth);
                                        for(Campaign cp : campaignList) {
                                            Date cpCreatedDate = cp.CreatedDate.date().addMonths(1);   // 2025. 03. 31. -> 2025. 04
                                            if(sl.year() == cpCreatedDate.year() && sl.month() == cpCreatedDate.month()) {
                                                cpId = cp.Id;
                                            }
                                        }
                                        Integer monthDiffer = calMonthDiffer(today, selectDay);
                                        Case newCase                    = new Case();
                                        newCase.Status                  = 'New';
                                        newCase.Campaign__c             = cpId;                     // 해당 Campaign의 Id 설정
                                        newCase.AssetId                 = assetId;
                                        newCase.TicketType__c           = 'Internal request';       // 내부요청
                                        newCase.InternalTicketType__c   = 'Regular Inspections';    // 정기점검
                                        newCase.AccountId	            = asset.AccountId;
                                        newCase.ReceptionDetails__c     = '서비스패키지 구매, 정기점검 ' + monthDiffer + '개월차';
                                        caseList.add(newCase);
                                    } else {
                                        System.debug('Ticket 생성 날짜가 아님');
                                    }
                                }
                            } else {
                                System.debug('지정일 날짜가 비어있음');
                            }
                        }
                    }
                    // 각종 오일 교체인 경우 정기점검 Ticket + 오일교체 Ticket 총 2개의 Ticket이 생성
                    if (servicePackageType == '각종 오일 교체') {
                        // 오일도 정기점검처럼 가져가야됨
                        switch on standardOilDay {
                            when '설치일' {
                                System.debug('기준일 : 설치일');
                                List<Date> installDateList = new List<Date>();
                                if(InstallDate != null) {   // 2025. 03. 19
                                    for(Integer addDate : exceptInfoParse) {
                                        installDateList.add(InstallDate.addMonths(addDate));
                                    }
                                    System.debug('installDateList : ' + installDateList); //2025-04-19, 2025-06-19, 2025-08-19, 2025-10-19, 2025-12-19
                                    String cpId;
                                    for(Date it : installDateList) {
                                        String itYM = String.valueOf(it.year()) + '_' + String.valueOf(it.month()); // 20254
                                        if(itYM == yearMonth) { // 이거 나중에 yearMonth 로 바꿔야 함
                                            for(Campaign cp : campaignList) {
                                                Date cpCreatedDate = cp.CreatedDate.date().addMonths(1); // 2025. 03. 31. -> 2025. 04. 
                                                if(it.year() == cpCreatedDate.year() && it.month() == cpCreatedDate.month()) {
                                                    cpId = cp.Id;
                                                }
                                            }
                                            Integer monthDiffer = calMonthDiffer(today, InstallDate);
                                            Case newCase                    = new Case();
                                            newCase.Status                  = 'New';
                                            newCase.Campaign__c             = cpId;                     // 해당 Campaign의 Id 설정
                                            newCase.AssetId                 = assetId;
                                            newCase.TicketType__c           = 'Internal request';       // 내부요청
                                            newCase.InternalTicketType__c   = 'Regular Inspections';    // 오일교체
                                            newCase.AccountId	            = asset.AccountId;
                                            newCase.ReceptionDetails__c     = '서비스패키지 구매, 오일교체 ' + monthDiffer + '개월차';
                                            caseList.add(newCase);
                                        } else {
                                            System.debug('Ticket 생성 날짜가 아님');        
                                        }
                                    }
                                } else {
                                    System.debug('장비의 설치일자가 비워져 있음');
                                    break;
                                }
                            } when '판매일' {
                                System.debug('기준일 : 판매일');
                                if(spp.Order__c != null) {
                                    List<Date> salesDateList = new List<Date>();
                                    for(Integer addDate : exceptInfoParse) {
                                        salesDateList.add(salesDate.addmonths(addDate));
                                    }
                                    System.debug('salesDateList : ' + salesDateList); //2025-04-12, 2025-06-12, 2025-08-12, 2025-10-12, 2025-12-12)
                                    String cpId;
                                    for(Date sd : salesDateList) {
                                        String sdYM = String.valueOf(sd.year()) + '_' + String.valueOf(sd.month()); // 20254
                                        if(sdYM == yearMonth) { // 이거 Today 로 바꿔야 함
                                            for(Campaign cp : campaignList) {
                                                Date cpCreatedDate = cp.CreatedDate.date().addMonths(1);   // 2024. 12. 31. -> 2025. 01. 31
                                                if(sd.year() == cpCreatedDate.year() && sd.month() == cpCreatedDate.month()) {
                                                    cpId = cp.Id;
                                                }
                                            }
                                            Integer monthDiffer = calMonthDiffer(today, salesDate);
                                            Case newCase                    = new Case();
                                            newCase.Status                  = 'New';
                                            newCase.Campaign__c             = cpId;                     // 해당 Campaign의 Id 설정
                                            newCase.AssetId                 = assetId;
                                            newCase.TicketType__c           = 'Internal request';       // 내부요청
                                            newCase.InternalTicketType__c   = 'Regular Inspections';    // 오일교체
                                            newCase.AccountId	            = asset.AccountId;
                                            newCase.ReceptionDetails__c     = '서비스패키지 구매, 오일교체 ' + monthDiffer + '개월차';
                                            caseList.add(newCase);
                                        } else {
                                            System.debug('Ticket 생성 날짜가 아님');
                                        }
                                    }
                                } else {
                                    System.debug('Service Package Product 에 오더가 비워져있음');
                                }
                            } when '지정일' {
                                System.debug('기준일 : 지정일');
                                if (lastOilChangeDate != null) {
                                    List<Date> oilChangeDateList = new List<Date>();
                                    for(Integer addDate : exceptOilInfoParse) {
                                        oilChangeDateList.add(lastOilChangeDate.addMonths(addDate));
                                    }
                                    String cpId;
                                    for (Date oilDate : oilChangeDateList) {
                                        String oilYM = String.valueOf(oilDate.year()) + '_' + String.valueOf(oilDate.month());
                                        if (oilYM == yearMonth) {
                                            for(Campaign cp : campaignList) {
                                                Date cpCreatedDate = cp.CreatedDate.date().addMonths(1);
                                                if (oilDate.year() == cpCreatedDate.year() && oilDate.month() == cpCreatedDate.month()) {
                                                    cpId = cp.Id;
                                                }
                                            }
                                            Integer monthDiffer = calMonthDiffer(today, lastOilChangeDate);
                                            
                                            Case newOilCase = new Case();
                                            newOilCase.Status                  = 'New';
                                            newOilCase.Campaign__c             = cpId;
                                            newOilCase.AssetId                 = assetId;
                                            newOilCase.TicketType__c           = 'Internal request';
                                            newOilCase.InternalTicketType__c   = 'Regular Inspections';
                                            newOilCase.AccountId	            = asset.AccountId;
                                            newOilCase.ReceptionDetails__c     = '서비스패키지 구매, 오일교체 ' + monthDiffer + '개월차';
                                            caseList.add(newOilCase);
                                        }
                                    }
                                } else {
                                    System.debug('지정일 날짜가 비어있음');
                                }
                            }
                        }
                    }
                } else {
                    System.debug('기준일이 비어 있습니다.');
                }
            }

            if (!caseList.isEmpty()) {
                insert caseList;
                System.debug('Case 생성: ' + caseList.size());
            } else {
                System.debug('생성될 CaseList 없음');
            }

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public void finish(Database.BatchableContext context){
        System.debug('배치 실행 완료');
    }

    // N 개월차 날짜 계산 함수
    private Integer calMonthDiffer(Date todayDate, Date fromDate) {
        Integer yDifferM = (todayDate.year() - fromDate.year()) * 12;
        Integer mDiffer = todayDate.month() - fromDate.month();
        return yDifferM + mDiffer;
    }

    global void execute(SchedulableContext sc) {
        DN_RegularServiceTicketBatch batch = new DN_RegularServiceTicketBatch();
        Database.executeBatch(batch, 1);        
    }
}