import { LightningElement } from 'lwc';
import getPerformanceData from '@salesforce/apex/DN_SalesPerformanceTable.getPerformanceData';

export default class Dn_SalesPerformanceTable extends LightningElement {

    rows = [];
    months = [
        '1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
    quarters = {
    '목표': [],
    '주문실적': [],
    '영업기회합': []
    };
    connectedCallback(){
        getPerformanceData()
        .then(result => {
            this.rows = result
            .filter(row => 
            ['목표','수주실적','firmed','Stretch','Others','영업기회합'].includes(row.label)
            )
            .map(row => {
                let displayLabel;
                if(row.label == '영업기회합'){
                    displayLabel = '영업기회 합';
                }else{
                    displayLabel = row.label;
                }
                return {
                    label: displayLabel,
                    monthlyValues: row.monthlyValues.map(v => this.formatNumber(v)),
                    yearTotal: this.formatNumber(row.yearTotal)
                }
            });

            const targetLabels = ['목표', '수주실적', '영업기회합'];
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