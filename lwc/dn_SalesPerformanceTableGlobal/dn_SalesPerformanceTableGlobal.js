import { LightningElement } from 'lwc';
import getPerformanceDataGlobal from '@salesforce/apex/DN_SalesPerformanceTable.getPerformanceDataGlobal';

export default class Dn_SalesPerformanceTableGlobal extends LightningElement {
    rows = [];
    months = [
        '1M', '2M', '3M', '4M', '5M', '6M', '7M', '8M', '9M', '10M', '11M', '12M'];
    quarters = {
        'Target': [],
        'Order Total': [],
        'Oppty Total': []
    };

    connectedCallback(){
        getPerformanceDataGlobal()
        .then(result => {

            this.rows = result
            .filter(row => 
                ['Target','OrderTotal','firmedGlobal','StretchGlobal','OthersGlobal','OpptyTotal'].includes(row.label)
            )
            .map(row => {
            console.log('result : ' + JSON.stringify(row));

                let displayLabel;
                if(row.label == 'Target'){
                    displayLabel = 'Target';
                }else if(row.label == 'OrderTotal'){
                    displayLabel = 'Order Total'
                }else if(row.label == 'firmedGlobal'){
                    displayLabel = 'firmed'
                }else if(row.label == 'StretchGlobal'){
                    displayLabel = 'Stretch'
                }else if(row.label == 'OthersGlobal'){
                    displayLabel = 'Others'
                }else if(row.label == 'OpptyTotal'){
                    displayLabel = 'Oppty Total'
                }else {
                    displayLabel = row.label;
                }
                return {
                    label: displayLabel,
                    monthlyValues: row.monthlyValues.map(v => this.formatNumber(v)),
                    yearTotal: this.formatNumber(row.yearTotal)
                }
            });

            const targetLabels = ['Target', 'OrderTotal', 'OpptyTotal'];
            targetLabels.forEach(label => {
                const row = result.find(r => r.label === label);
                if (row && row.quarterSums) {
                    this.quarters[label] = [
                        ...row.quarterSums.map(q => this.formatNumber(q)),
                        this.formatNumber(row.yearTotal)
                    ];
                }
            });
            console.log(JSON.stringify(result));
        })
        .catch(error => {
            console.error('Apex error:', error.body.message);
        });
    }
    formatNumber(value) {
        if (isNaN(value)) return value;
        return new Intl.NumberFormat('ko-KR').format(value);
    }
}