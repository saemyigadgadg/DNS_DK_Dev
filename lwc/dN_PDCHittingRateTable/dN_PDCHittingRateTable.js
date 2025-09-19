import { LightningElement, track,api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';
//static resource
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import EXCEL_JS from '@salesforce/resourceUrl/ExcelJS'; 
import FileSaver from '@salesforce/resourceUrl/FileSaver'; 
//Apex 
import getHitList from '@salesforce/apex/DN_PDCHittingRateTableController.getHitList';

export default class DN_PDCHittingRateTable extends NavigationMixin(LightningElement) {
    excelJs = EXCEL_JS + '/unpkg/exceljs.min.js';
    fileSaver = FileSaver + '/FileSaver.js';
    searchParams = {};

    /**
     * LMC
    */
    @wire(MessageContext)
    messageContext;
    //subscription = null;

    @api uuid;

    @track rateList  = []; //조회row데이터
    @track rateSample= []; //화면에보여줄가공데이터
    @track excelList = []; //엑셀데이터
    @track sumList   = []; //sumList 

    @track totalOrderCnt = 0; //요청수량합
    @track totalCalAvCnt = 0;  //가용재고값 ->가공한 가용재고값 sum calAvQty
    @track totalEOAvg    = 0; //가용재고/요청수량
    @track totalItemSum  = 0;  //아이템별적중률(SUM)
    @track totalItemCntSum =0; //아이템수(SUM)
    @track totalItemAvg  = 0;  //아이템별적중률 평균
    @track totalOrderSum = 0; //주문수SUM 
    @track totalOrdeCntSum =0; //주문별아이템수(SUM)
    @track totalOrderAvg = 0; //주문별적중률 평균 (sum/항목수)
    @track isLoading = false;
    
    connectedCallback() {
        console.log('부품 대리점 적용율 connected Callback');
        Promise.all([
            loadScript(this, EXCEL_JS + '/unpkg/exceljs.min.js'),
            //loadScript(this, this.excelJs),
            loadScript(this, this.fileSaver)
        ])
        .then(() => {  
            console.log('적용율!!');
        })
        .catch( error => {
            console.log(error,' < ---error')
        });
        if(!this.subscription) {
            this.setSubscriptionLMC();        
        }
    }
     /**
     * publish 
     * 
     */
     messagePublish(eventType,msg) {
        let messagePush = {
            uuid : this.uuid,
            type : eventType,
            message : msg,
            cmpName : 'dataTable'
        }
        publish(this.messageContext, DealerPortalLMC, messagePush);
    }

     /**
     * set subscription
     */
     setSubscriptionLMC(){
        this.subscription = subscribe(this.messageContext, DealerPortalLMC, (msg) => {
            if(msg.uuid == this.uuid) {
                // button 컴포넌트의 이벤트 : 검색,엑셀 등등
                switch (msg.cmpName) {
                    case 'dN_DealerPortalFilter':
                        if(msg.type =='filterChange') {
                            console.log(JSON.stringify(msg.message), ' < ==msg.message');
                            this.setFilterChange(msg.message);
                        } 
                        if(msg.type =='defaultFilter') {
                            console.log(JSON.stringify(msg.message), ' :::::::defaultFilter');
                            this.setFilterChange(msg.message); 
                        }
                        break;
                    case 'dN_DealerPortalButton':
                        if(msg.type =='Seach') {

                            console.log('Seach 부품');
                            console.log(JSON.stringify(this.searchParams));
                            
                            this.getData('Search');
                        }  
                        if(msg.type =='ExcelDownload'){
                            console.log('ExcelDownload');
                            this.handleExcelDownload();
                        }
                        break;
                    case 'dN_DealerPortalQueryPage':
                        break;  
                }
            }
        });
    }

    setFilterChange(message) {
        this.searchParams[message.field] = message.value;
    }


    getSearchParams() {
        return {...this.searchParams};
    }

    getData(type) {
            this.isLoading = true;
            let searchParams = this.getSearchParams();
            console.log(`+++++getData this.searchParams : ${JSON.stringify(searchParams)}`);
            console.log(searchParams);
            getHitList({...searchParams}).then( result => {
                this.clearDataSet();
                console.log(result);
                console.log('rateList : '+ JSON.stringify(result.rateList));
                if(result.rateList.length == 0) {
                    this.showToast('No data','검색조건에 만족하는 데이터가 존재하지 않습니다.','error');
                    this.isLoading = false;
                    return;
                }
                this.rateList = result.rateList;
                this.processSamples(this.rateList);
                this.sumAverage(this.rateList);
                this.isLoading = false;
            }).catch(error => {
                console.log(JSON.stringify(error), ' dN_PCDSUPPLYRATETABLE error');
                this.showToast('관리자문의','관리자 한테 문의하세요.','error');
                this.isLoading = false;
            });
    }

    //화면에 표기할 머지 데이터 생성
    processSamples(data) {
        let currentDealerName = '';
        let currentOrderDate = '';
        let currentCustomerName = '';
        let currentOrderNumber = '';
        data.sort((a, b) => {
            const orderCompare = b.orderNumber.localeCompare(a.orderNumber); // orderNumber는 그대로 내림차순
            if (orderCompare !== 0) {
                return orderCompare;
            }
            return a.orderItemNumber.localeCompare(b.orderItemNumber); // 오름차순으로 변경
        });

        data.forEach((item, index) => {
          if (
            item.dealerName === currentDealerName &&
            item.orderDate === currentOrderDate &&
            item.customerName === currentCustomerName &&
            item.orderNumber === currentOrderNumber
          ) {
            // 동일한 항목이 존재하면 이 행은 숨기고 rowspan을 0으로 설정
            item.isHidden =  'slds-hide';  // 이 행은 숨겨야 함
          } else {
            item.rowspan = item.rowspan; 
            currentDealerName = item.dealerName;
            currentOrderDate = item.orderDate;
            currentCustomerName = item.customerName;
            currentOrderNumber = item.orderNumber;
          }

        });
        this.rateSample = data;
        this.excelList  = data;
    }

    //화면에 표기할 sum data 계산
    sumAverage(rowList){
        const doSet = new Set();
        rowList.forEach(ele => {
            if(!doSet.has(ele.doId)){
                doSet.add(ele.doId);
                this.sumList.push(ele);
            }
        });
        //요청수량 합
        this.totalOrderCnt = this.rateList.reduce((sum,record) => { return sum + record.orderQty; },0);
        //가용재고 합
        this.totalCalAvCnt = this.rateList.reduce((sum,record) => { return sum + record.calAvQty; },0);
        //아이템별 수량별 적중율 합계
        this.totalEOAvg = ((((this.totalCalAvCnt / this.totalOrderCnt) * 100.0) * 10) / 10).toFixed(2);//Math.round(((this.totalCalAvCnt / this.totalOrderCnt) * 100.0) * 10) / 10;
        // 아이템 적중률 SUM (주문 아이템별 적중률 SUM/ 주문별 총 아이템 수 )
        this.totalItemSum = this.rateList.reduce((sum,record) => { return Number(sum) + Number(record.calPerItem); },0);
        // 총 아이템 수 
        this.totalItemCntSum = this.sumList.reduce((sum,record) => { return Number(sum) + Number(record.totalOrderCnt); },0);
        // 아이템 적중률 평균 (주문 아이템별 적중률 SUM/ 총 아이템 수 )
        this.totalItemAvg = (((this.totalItemSum /  this.totalItemCntSum) * 10) / 10).toFixed(2);//Math.round((this.totalItemSum /  this.totalItemCntSum) * 10) / 10;
        // 주문별 적중률 SUM (주문 아이템별 적중률 SUM/ 주문별 총 아이템 수 )
        this.totalOrderSum = this.sumList.reduce((sum,record) => { return sum + record.perOrder; },0);
        //총 주문수
        this.totalOrdeCntSum = this.sumList.length;
        // 주문별 적중률 평균 (주문 아이템별 적중률 SUM/ 주문별 총 아이템 수 )
        this.totalOrderAvg =(((this.totalOrderSum / this.totalOrdeCntSum) * 10) / 10).toFixed(2);// Math.round((this.totalOrderSum / this.totalOrdeCntSum) * 10) / 10;
    }

    //Excel Data생성하기
    handleExcelDownload(){
        console.log('1.엑셀');
        if(this.excelList.length ==0) {
            this.showToast('No data','조회된 데이터가 없습니다','error');
            return;
        } 
        console.log('2.엑셀');
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('대리점적중율목록');
        
        ///Header
        worksheet.columns = [
            { header: '대리점명', key: 'dealerName', width: 15, style: { alignment: { horizontal: 'center' }}},
            { header: '주문일', key: 'orderDate', width: 15, style: { alignment: { horizontal: 'center' }}},
            { header: '고객사명', key: 'customerName', width: 15, style: { alignment: { horizontal: 'center' }}},
            { header: '주문번호', key: 'orderNumber', width: 15, style: { alignment: { horizontal: 'center' }}},
            { header: '항목', key: 'orderItemNumber', width: 15, style: { alignment: { horizontal: 'center' }}},
            { header: '품번', key: 'partNumber', width: 15 , style: { alignment: { horizontal: 'center' }}},
            { header: '품명', key: 'partName', width: 15 , style: { alignment: { horizontal: 'center' }}},
            { header: '요청수량', key: 'orderQty', width: 15, style: { alignment: { horizontal: 'right' } } },
            { header: '가용재고', key: 'avQty', width: 15, style: { alignment: { horizontal: 'right' } } },
            { header: '아이템 적중률', key: 'calPerItem', width: 15, style: { alignment: { horizontal: 'right' } } },
            { header: '주문별 적중률', key: 'perOrder', width: 15, style: { alignment: { horizontal: 'right' } } }
        ];

        const headerRow = worksheet.getRow(1);
        headerRow.eachCell((cell, colNumber) => {
            cell.fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'D5D5D5'} 
            };
            cell.alignment = {
                horizontal: 'center',
                vertical: 'middle'   
            };
            cell.font = {
                bold: true,  
                color: { argb: '000000' } 
            };
            cell.border = {
                top: { style: 'thin', color: { argb: 'FF000000' } },
                left: { style: 'thin', color: { argb: 'FF000000' } },
                bottom: { style: 'thin', color: { argb: 'FF000000' } },
                right: { style: 'thin', color: { argb: 'FF000000' } }
            };
        });

        //// Body Data
        this.excelList.forEach((sample) => {
            const row = worksheet.addRow({
                 dealerName: sample.dealerName
                ,orderDate: sample.orderDate
                ,customerName: sample.customerName
                ,orderNumber: sample.orderNumber
                ,orderItemNumber: sample.orderItemNumber
                ,partNumber: sample.partNumber
                ,partName: sample.partName
                ,orderQty: sample.orderQty
                ,avQty: sample.avQty
                ,calPerItem: `${sample.calPerItem}%`
                ,perOrder: `${sample.perOrder}%`
                ,rowspan : sample.rowspan//sample.totalOrderCnt
            });
            row.eachCell((cell, colNumber) => {
                if (cell.value === null || cell.value === undefined) {
                    cell.value = '';  
                }
                cell.border = {
                    top: { style: 'thin', color: { argb: 'FF000000' } },
                    left: { style: 'thin', color: { argb: 'FF000000' } },
                    bottom: { style: 'thin', color: { argb: 'FF000000' } },
                    right: { style: 'thin', color: { argb: 'FF000000' } }
                };
                cell.alignment = {
                    vertical: 'middle'   
                };
            });
    
        });
        let mergeMap = [];
        let buyPass=0;
        //셀병합
        worksheet.eachRow((row, rowNumber) => {
            if (rowNumber === 1) return;
            const sample = this.excelList[rowNumber - 2];
            if (!sample) return; 
            
        
            
            
            // rowspan이 1 이상이면 해당 범위만큼 병합 처리
            if (sample.rowspan > 1) {
                console.log(JSON.stringify(sample),' ::: sample');
                console.log(rowNumber, 'test2222');
                
                if(buyPass != rowNumber) {
                    if(buyPass <rowNumber) {
                        worksheet.mergeCells(`A${rowNumber}:A${rowNumber + sample.rowspan - 1}`);
                        worksheet.mergeCells(`B${rowNumber}:B${rowNumber + sample.rowspan - 1}`);
                        worksheet.mergeCells(`C${rowNumber}:C${rowNumber + sample.rowspan - 1}`);
                        worksheet.mergeCells(`D${rowNumber}:D${rowNumber + sample.rowspan - 1}`);
                        worksheet.mergeCells(`K${rowNumber}:K${rowNumber + sample.rowspan - 1}`);
                        buyPass = rowNumber + sample.rowspan - 1;
                    }
                } 
            }
         
        });

        /////첫번째풋터
        const footerRow1 = worksheet.addRow([
            '평균', '', '', '', '', '', '', '', '',`${this.totalItemAvg}%`,`${this.totalOrderAvg}%`
        ]);
        worksheet.mergeCells(`A${this.excelList.length + 2}:I${this.excelList.length + 2}`); 
        /////두번째풋터
        const footerRow2 = worksheet.addRow([
            '아이템 수량별 적중율 합계', '', '', '', '', '', '', '', '', '',`${this.totalEOAvg}%`
        ]);
        worksheet.mergeCells(`A${this.excelList.length + 3}:J${this.excelList.length +3}`); 

        footerRow1.eachCell((cell, colNumber) => {
            cell.fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'D4F4FA' } 
            };
            cell.border = {
                top: { style: 'thick', color: { argb: '4374D9' } },
                left: { style: 'thin', color: { argb: 'FF000000' } },
                bottom: { style: 'thin', color: { argb: 'FF000000' } },
                right: { style: 'thin', color: { argb: 'FF000000' } }
            };
            cell.alignment = {
                horizontal: 'right',  
                vertical: 'middle'   
            };
            cell.font = {
                bold: true,  
                color: { argb: '000000' } 
            };
        });

        
        footerRow2.eachCell((cell, colNumber) => {
            cell.fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'D4F4FA' } 
            };
            cell.border = {
                top: { style: 'thick', color: { argb: '4374D9' } },
                left: { style: 'thin', color: { argb: 'FF000000' } },
                bottom: { style: 'thin', color: { argb: 'FF000000' } },
                right: { style: 'thin', color: { argb: 'FF000000' } }
            };
            cell.alignment = {
                horizontal: 'right',  
                vertical: 'middle'   
            };
            cell.font = {
                bold: true,  
                color: { argb: '000000' } 
            };
        });


        // 파일 생성
        workbook.xlsx.writeBuffer().then((buffer) => {
            const blob = new Blob([buffer], { type: 'application/octet-stream' });
            saveAs(blob,'대리점적중율.xlsx');
        });
        
    }

    // toast메세지
    showToast(title,message,variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    clearDataSet(){
        this.rateList   = [];
        this.rateSample = [];
        this.sumList    = [];
        this.excelList  = [];
        this.totalOrderCnt   = 0;
        this.totalCalAvCnt   = 0;
        this.totalEOAvg      = 0;
        this.totalItemSum    = 0; 
        this.totalItemCntSum = 0;
        this.totalItemAvg    = 0;
        this.totalOrderSum   = 0;
        this.totalOrdeCntSum = 0;
        this.totalOrderAvg   = 0;
    }
}