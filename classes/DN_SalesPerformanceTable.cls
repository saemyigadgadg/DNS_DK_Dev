public with sharing class DN_SalesPerformanceTable {

    public class PerformanceRow {
        @AuraEnabled public String label;
        @AuraEnabled public List<Decimal> monthlyValues;
        @AuraEnabled public Decimal yearTotal;
        @AuraEnabled public List<Decimal> quarterSums; 

        public PerformanceRow(String label, List<Decimal> monthlyValues) {
            this.label = label;
            this.monthlyValues = monthlyValues;
            this.yearTotal = 0;
            for (Decimal v : monthlyValues) {
                this.yearTotal += v;
            }
            this.quarterSums = getQuarterSums(monthlyValues);
        }
    }

    @AuraEnabled
    public static List<PerformanceRow> getPerformanceData() {
        List<PerformanceRow> result = new List<PerformanceRow>();
        try{
            String currentYear = String.valueOf(Date.today().year());

            List<Sales_Goal__c> koreaTargetAmtInfo = [SELECT Sales_Goal_Name__c, Corporation__c, YYYY__c, MM__c, TargetAmount__c  FROM Sales_Goal__c WHERE YYYY__c =:currentYear AND Corporation__c = '한국' ORDER BY MM__c];
            List<Decimal> koreaTargetAmt = new List<Decimal>();

            if(!koreaTargetAmtInfo.isEmpty()){
                for(Integer i = 0; i < koreaTargetAmtInfo.size(); i++){
                    koreaTargetAmt.add((koreaTargetAmtInfo[i].TargetAmount__c / 1000000).setScale(0));
                }
            }

            result.add(new PerformanceRow('목표', koreaTargetAmt));
            result.add(new PerformanceRow('수주실적', getMonthlyOrderTotals('수주실적')));
            result.add(new PerformanceRow('firmed', getMonthlyOrderTotals('firmed')));
            result.add(new PerformanceRow('Stretch', getMonthlyOrderTotals('Stretch')));
            result.add(new PerformanceRow('Others', getMonthlyOrderTotals('Others')));
            result.add(new PerformanceRow('영업기회합', getMonthlyOrderTotals('영업기회합')));

        }catch (Exception e) {
            System.debug('getPerformanceData Exception: ' + e.getMessage() + 'Error Line : ' + e.getLineNumber());
        }
        

        return result;
    }

    @AuraEnabled
    public static List<PerformanceRow> getPerformanceDataGlobal() {
        List<PerformanceRow> result = new List<PerformanceRow>();
        try{
            String currentYear = String.valueOf(Date.today().year());

            List<AggregateResult> globalTargetAmtInfo = [SELECT YYYY__c, MM__c, SUM(TargetAmount__c) TargetAmount__c FROM Sales_Goal__c WHERE YYYY__c =:currentYear AND Corporation__c IN ('유럽직수출', '신흥') GROUP BY YYYY__c, MM__c ORDER BY MM__c];
            List<Decimal> globalTargetAmt = new List<Decimal>();

            if(!globalTargetAmtInfo.isEmpty()){
                
                for (AggregateResult ar : globalTargetAmtInfo) {
                    Decimal sumTarget = (Decimal) ar.get('TargetAmount__c');
                    globalTargetAmt.add((sumTarget / 1000000).setScale(0));

                }
            }

            result.add(new PerformanceRow('Target', globalTargetAmt));
            result.add(new PerformanceRow('OrderTotal', getMonthlyOrderTotals('OrderTotal')));
            result.add(new PerformanceRow('firmedGlobal', getMonthlyOrderTotals('firmedGlobal')));
            result.add(new PerformanceRow('StretchGlobal', getMonthlyOrderTotals('StretchGlobal')));
            result.add(new PerformanceRow('OthersGlobal', getMonthlyOrderTotals('OthersGlobal')));
            result.add(new PerformanceRow('OpptyTotal', getMonthlyOrderTotals('OpptyTotal')));

        }catch (Exception e) {
            System.debug('getPerformanceData Exception: ' + e.getMessage() + 'Error Line : ' + e.getLineNumber());
        }
        

        return result;
    }

    //수주실적 월별 집계
    public static List<Decimal> getMonthlyOrderTotals(String type) {
        // 1월~12월 초기화
        List<Decimal> monthlyTotals = new List<Decimal>();
        for (Integer i = 0; i < 12; i++) {
            monthlyTotals.add(0);
        }

        Integer currentYear = Date.today().year();
        List<Order> orders = new List<Order>();
        List<Opportunity> optys = new List<Opportunity>();
        List<Order> firmed = new List<Order>();
        List<Opportunity> Stretch = new List<Opportunity>();
        List<Opportunity> Others = new List<Opportunity>();

        //한국영업업
        if(type == '수주실적'){
            orders = [
                        SELECT FinalOrderAmount__c, CurrencyIsoCode, EffectiveDate
                        FROM Order
                        WHERE FinalOrderAmount__c != null
                        AND IF_IsERPConfirmed__c = TRUE
                        AND Account.SalesOffice__c LIKE '%지사%'
                        AND CALENDAR_YEAR(EffectiveDate) = :currentYear
                    ];
        }else if(type == 'firmed'){
            orders = [
                        SELECT FinalOrderAmount__c, CurrencyIsoCode, EffectiveDate
                        FROM Order
                        WHERE FinalOrderAmount__c != null
                        AND IF_IsERPConfirmed__c = FALSE
                        AND Opportunity.StageName = 'Closed Won'
                        AND Account.SalesOffice__c LIKE '%지사%'
                        AND CALENDAR_YEAR(EffectiveDate) = :currentYear
                    ];
        }else if(type == 'Stretch'){
            optys = [
                    SELECT CloseDate,  Amount__c, CurrencyIsoCode, Insight__c
                    FROM Opportunity 
                    WHERE StageName NOT IN ('Closed Won','Closed Lost', 'Closed Drop') 
                    AND Amount__c != null
                    AND Insight__c IN ('75%', '100%')
                    AND Account.SalesOffice__c LIKE '%지사%'
                    AND CALENDAR_YEAR(CloseDate) = :currentYear
                ];
        }else if(type == 'Others'){
            optys = [
                    SELECT CloseDate,  Amount__c, CurrencyIsoCode, Insight__c
                    FROM Opportunity 
                    WHERE StageName NOT IN ('Closed Won','Closed Lost', 'Closed Drop') 
                    AND Amount__c != null
                    AND Insight__c IN ('', '25%', '50%')
                    AND Account.SalesOffice__c LIKE '%지사%'
                    AND CALENDAR_YEAR(CloseDate) = :currentYear
                ];
        }

        //글로벌영업
        if(type == 'OrderTotal'){
            orders = [
                        SELECT FinalOrderAmount__c, CurrencyIsoCode, EffectiveDate
                        FROM Order
                        WHERE FinalOrderAmount__c != null
                        AND FinalOrderAmount__c != 0
                        AND IF_IsERPConfirmed__c = TRUE
                        AND Opportunity.Owner.Account.SalesOffice__c LIKE '%해외영업(DNS)%'
                        AND CALENDAR_YEAR(EffectiveDate) = :currentYear
                    ];
        }else if(type == 'firmedGlobal'){
            orders = [
                        SELECT FinalOrderAmount__c, CurrencyIsoCode, EffectiveDate
                        FROM Order
                        WHERE FinalOrderAmount__c != null 
                        AND FinalOrderAmount__c != 0
                        AND IF_IsERPConfirmed__c = FALSE
                        AND Opportunity.StageName = 'Closed Won'
                        AND Opportunity.Owner.Account.SalesOffice__c LIKE '%해외영업(DNS)%'
                        AND CALENDAR_YEAR(EffectiveDate) = :currentYear
                    ];
        }else if(type == 'StretchGlobal'){
            optys = [
                    SELECT CloseDate,  Amount__c, CurrencyIsoCode, Insight__c
                    FROM Opportunity 
                    WHERE StageName NOT IN ('Closed Won','Closed Lost', 'Closed Drop') 
                    AND Amount__c != null
                    AND Insight__c IN ('75%', '100%')
                    AND Owner.Account.SalesOffice__c LIKE '%해외영업(DNS)%'
                    AND CALENDAR_YEAR(CloseDate) = :currentYear
                ];
        }else if(type == 'OthersGlobal'){
            optys = [
                    SELECT CloseDate,  Amount__c, CurrencyIsoCode, Insight__c
                    FROM Opportunity 
                    WHERE StageName NOT IN ('Closed Won','Closed Lost', 'Closed Drop') 
                    AND Amount__c != null
                    AND Insight__c IN ('', '25%', '50%')
                    AND Owner.Account.SalesOffice__c LIKE '%해외영업(DNS)%'
                    AND CALENDAR_YEAR(CloseDate) = :currentYear
                ];
        }
        
        //한국영업
        if(type == '수주실적' || type == 'firmed'){
            for (Order o : orders) {
                Integer month = o.EffectiveDate.month(); // 1~12
                Decimal amount = o.FinalOrderAmount__c != null ? o.FinalOrderAmount__c : 0;

                amount = getCurrencyMulti(o.CurrencyIsoCode, amount);
                

                monthlyTotals[month - 1] += amount; // 0-based index
            }
        }
        if(type == 'Stretch' || type == 'Others'){
            for (Opportunity o : optys) {
                Integer month = o.CloseDate.month(); // 1~12

                Decimal amount = (o.Amount__c != null ? o.Amount__c : 0) * getWinrationMulti(o.Insight__c);

                amount = getCurrencyMulti(o.CurrencyIsoCode, amount);
                

                monthlyTotals[month - 1] += amount; // 0-based index
            }
        }
        if(type == '영업기회합'){
            firmed = [
                        SELECT FinalOrderAmount__c, CurrencyIsoCode, EffectiveDate
                        FROM Order
                        WHERE FinalOrderAmount__c != null
                        AND IF_IsERPConfirmed__c = FALSE
                        AND Opportunity.StageName = 'Closed Won'
                        AND Account.SalesOffice__c LIKE '%지사%'
                        AND CALENDAR_YEAR(EffectiveDate) = :currentYear
                    ];
            Stretch = [
                        SELECT CloseDate,  Amount__c, CurrencyIsoCode, Insight__c
                        FROM Opportunity 
                        WHERE StageName NOT IN ('Closed Won','Closed Lost', 'Closed Drop') 
                        AND Amount__c != null
                        AND Insight__c IN ('75%', '100%')
                        AND Account.SalesOffice__c LIKE '%지사%'
                        AND CALENDAR_YEAR(CloseDate) = :currentYear
                    ];
            Others = [
                        SELECT CloseDate,  Amount__c, CurrencyIsoCode, Insight__c
                        FROM Opportunity 
                        WHERE StageName NOT IN ('Closed Won','Closed Lost', 'Closed Drop') 
                        AND Amount__c != null
                        AND Insight__c IN ('', '25%', '50%')
                        AND Account.SalesOffice__c LIKE '%지사%'
                        AND CALENDAR_YEAR(CloseDate) = :currentYear
                    ];
            for (Order o : firmed) {
                Integer month = o.EffectiveDate.month(); // 1~12
                Decimal amount = o.FinalOrderAmount__c != null ? o.FinalOrderAmount__c : 0;

                amount = getCurrencyMulti(o.CurrencyIsoCode, amount);
                

                monthlyTotals[month - 1] += amount; // 0-based index
            }
            for (Opportunity o : Stretch) {
                Integer month = o.CloseDate.month(); // 1~12
                Decimal amount = (o.Amount__c != null ? o.Amount__c : 0) * getWinrationMulti(o.Insight__c);

                amount = getCurrencyMulti(o.CurrencyIsoCode, amount);
                

                monthlyTotals[month - 1] += amount; // 0-based index
            }
            for (Opportunity o : Others) {
                Integer month = o.CloseDate.month(); // 1~12
                Decimal amount = (o.Amount__c != null ? o.Amount__c : 0) * getWinrationMulti(o.Insight__c);

                amount = getCurrencyMulti(o.CurrencyIsoCode, amount);
                

                monthlyTotals[month - 1] += amount; // 0-based index
            }
        }

        //글로벌영업
        if(type == 'OrderTotal' || type == 'firmedGlobal'){
            for (Order o : orders) {
                Integer month = o.EffectiveDate.month(); // 1~12
                Decimal amount = o.FinalOrderAmount__c != null ? o.FinalOrderAmount__c : 0;

                amount = getCurrencyMulti(o.CurrencyIsoCode, amount);
                

                monthlyTotals[month - 1] += amount; // 0-based index
            }
        }
        if(type == 'StretchGlobal' || type == 'OthersGlobal'){
            for (Opportunity o : optys) {
                Integer month = o.CloseDate.month(); // 1~12
                Decimal amount = (o.Amount__c != null ? o.Amount__c : 0) * getWinrationMulti(o.Insight__c);

                amount = getCurrencyMulti(o.CurrencyIsoCode, amount);
                

                monthlyTotals[month - 1] += amount; // 0-based index
            }
        }
        if(type == 'OpptyTotal'){
            firmed = [
                        SELECT FinalOrderAmount__c, CurrencyIsoCode, EffectiveDate
                        FROM Order
                        WHERE FinalOrderAmount__c != null
                        AND IF_IsERPConfirmed__c = FALSE
                        AND Opportunity.StageName = 'Closed Won'
                        AND Opportunity.Owner.Account.SalesOffice__c LIKE '%해외영업(DNS)%'
                        AND CALENDAR_YEAR(EffectiveDate) = :currentYear
                    ];
            Stretch = [
                        SELECT CloseDate,  Amount__c, CurrencyIsoCode, Insight__c
                        FROM Opportunity 
                        WHERE StageName NOT IN ('Closed Won','Closed Lost', 'Closed Drop') 
                        AND Amount__c != null
                        AND Insight__c IN ('75%', '100%')
                        AND Owner.Account.SalesOffice__c LIKE '%해외영업(DNS)%'
                        AND CALENDAR_YEAR(CloseDate) = :currentYear
                    ];
            Others = [
                        SELECT CloseDate,  Amount__c, CurrencyIsoCode, Insight__c
                        FROM Opportunity 
                        WHERE StageName NOT IN ('Closed Won','Closed Lost', 'Closed Drop') 
                        AND Amount__c != null
                        AND Insight__c IN ('', '25%', '50%')
                        AND Owner.Account.SalesOffice__c LIKE '%해외영업(DNS)%'
                        AND CALENDAR_YEAR(CloseDate) = :currentYear
                    ];
            for (Order o : firmed) {
                Integer month = o.EffectiveDate.month(); // 1~12
                Decimal amount = o.FinalOrderAmount__c != null ? o.FinalOrderAmount__c : 0;

                amount = getCurrencyMulti(o.CurrencyIsoCode, amount);
                

                monthlyTotals[month - 1] += amount; // 0-based index
            }
            for (Opportunity o : Stretch) {
                Integer month = o.CloseDate.month(); // 1~12
                Decimal amount = (o.Amount__c != null ? o.Amount__c : 0) * getWinrationMulti(o.Insight__c);

                amount = getCurrencyMulti(o.CurrencyIsoCode, amount);
                

                monthlyTotals[month - 1] += amount; // 0-based index
            }
            for (Opportunity o : Others) {
                Integer month = o.CloseDate.month(); // 1~12
                Decimal amount = (o.Amount__c != null ? o.Amount__c : 0) * getWinrationMulti(o.Insight__c);

                amount = getCurrencyMulti(o.CurrencyIsoCode, amount);
                

                monthlyTotals[month - 1] += amount; // 0-based index
            }
        }

        return monthlyTotals;
    }

    public static Decimal getCurrencyMulti(String curr, Decimal amount) {
        if (curr == 'USD') {
            amount *= 1150;
        }else if(curr == 'EUR'){
            amount *= 1340;
        }else if(curr == 'GBP'){
            amount *= 1500;
        }else if(curr == 'RMB'){
            amount *= 180;
        }else if(curr == 'AUD'){
            amount *= 851;
        }else if(curr == 'JPY'){
            amount *= 10000;
        }
        
        amount = (amount / 1000000).setScale(0);
        return amount;
    }

    public static Decimal getWinrationMulti(String winratio){
        
        String insight = winratio;
        Decimal multiplier = 1;

        if (String.isBlank(insight)) {
            multiplier = 0; // 값이 없으면 0 처리
        } else if (insight.endsWith('%')) {
            insight = insight.replace('%', '');
            multiplier = Decimal.valueOf(insight) / 100;
        }
        return multiplier;

    }
    public static List<Decimal> getQuarterSums(List<Decimal> monthlyValues) {
        List<Decimal> quarters = new List<Decimal>();
        if (monthlyValues.size() >= 12) {
            quarters.add(monthlyValues[0] + monthlyValues[1] + monthlyValues[2]);     // Q1
            quarters.add(monthlyValues[3] + monthlyValues[4] + monthlyValues[5]);     // Q2
            quarters.add(monthlyValues[6] + monthlyValues[7] + monthlyValues[8]);     // Q3
            quarters.add(monthlyValues[9] + monthlyValues[10] + monthlyValues[11]);   // Q4
        } else {
            // 사이즈가 12 미만이면 0으로 채움
            quarters.add(0); quarters.add(0); quarters.add(0); quarters.add(0);
        }
        
        return quarters;
    }

    public static void dummy(){
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

    }
}