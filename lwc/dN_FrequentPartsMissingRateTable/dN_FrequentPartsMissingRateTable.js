/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-04-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-04-2025   youjin.shim@sbtglobal.com   Initial Version
**/
import { LightningElement ,api ,track ,wire } from 'lwc';
import POTAL_TABLE from './dN_FrequentPartsMissingRateTable.html';
import ADMIN_TABLE from './dN_FrequentPartsMissingRateTableAdmin.html';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {CurrentPageReference} from 'lightning/navigation';
import {getRecord } from 'lightning/uiRecordApi';
import UserId from '@salesforce/user/Id';
import AccountId from '@salesforce/schema/User.AccountId';

//LMC
import DealerPortalLMC from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';
//static resource
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import EXCEL_JS from '@salesforce/resourceUrl/ExcelJS'; 
import FileSaver from '@salesforce/resourceUrl/FileSaver'; 
//Apex 
import getDataList from '@salesforce/apex/DN_FrequentPartsMissingRateController.getDataList';

export default class DN_FrequentPartsMissingRateTable extends LightningElement {
    excelJs = EXCEL_JS + '/unpkg/exceljs.min.js';
    fileSaver = FileSaver + '/FileSaver.js';
    @track searchParams = {};


    @api uuid;
    @wire(MessageContext)
    messageContext;
    subscription = null;

    @track accId;
    @track isAdmin = false;
    @track resultList =[];
    @track poData =[];
    @track sumList = [];
    @track rateOrderPerOrder = 0; //주문별 order material
    @track rateOrderPerSupply= 0; //주문별 supply material
    @track rateItemPerOrder  = 0; //아이템별 order material
    @track rateItemPerSupply = 0; //아이템별 supply material
    @track isLoading = false;

   @wire(getRecord, { recordId: UserId, fields: [AccountId] })
    userDetails({ error, data }) {
        if (error) {
            console.log(error);
            this.error = error;
        } else if (data) {
            console.log(data);
            if (data.fields.AccountId.value != null) {
                this.accId = data.fields.AccountId.value;
                console.log(this.accId);
            }
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log(currentPageReference);
            if(currentPageReference.type=="standard__navItemPage"){
               console.log("standard__navItemPage");
               this.isAdmin = true;
            } else {
                console.log("comm__namedPage");
            }
        } 
    }

    connectedCallback() {
        Promise.all([
            loadScript(this, EXCEL_JS + '/unpkg/exceljs.min.js'),
            loadScript(this, this.fileSaver)
            
        ])
        .then(() => {  
           
        })
        .catch( error => {
            console.log(error,' < ---error')
        });
        if(!this.subscription) {
            this.setSubscriptionLMC();        
        }

        // const currentUrl = window.location.pathname;
        // console.log(currentUrl);
        
    }

    render() {
        console.log('render');
        // this.styleCSS();
        return this.isAdmin ? ADMIN_TABLE : POTAL_TABLE;
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
                switch (msg.type) {
                    case 'defaultFilter':
                        this.setFilterChange(msg.message);
                        break;
                    case 'filterChange':
                        this.setFilterChange(msg.message);
                        break;    
                    case 'Seach':
                        console.log('SeachSeachSeachSeach');
                        this.resetData();
                        this.getDataList();
                        break;
                    case 'ExcelDownload':
                        this.handleExcelDownload();
                        break;
                    default:
                        break;
                }
            }
        });
    }

    setFilterChange(message) {
        this.searchParams[message.field] = message.value;
    }

    getSearchParams() {
        let searchParams = {};
        let headerParams = this.searchParams;
        console.log(`headerParams : ${JSON.stringify(headerParams)}`);
        if (!('customerId' in headerParams)) {
            console.log('없음');
            if(this.accId!=null){
                searchParams.customerId = this.accId;
            }
        }
        Object.keys(headerParams).forEach(key=>{
            if(key === 'orderDateStart') {
                const [yearS, monthS] = this.searchParams[key].split('-');
                const firstDay =this.setDate(new Date(yearS, monthS - 1, 1));
                searchParams['orderDateStart'] = firstDay;
            }else if(key === 'orderDateEnd') {
                const [yearE, monthE] = this.searchParams[key].split('-');
                const lastDay = this.setDate(new Date(yearE, monthE, 0));
                searchParams['orderDateEnd'] = lastDay;
            }else {
                searchParams[key] = this.searchParams[key];
            }
        });
        return searchParams;
    }
    //// 날짜 셋팅해서 넘겨주기
    setDate(yyyyMM){
        console.log(yyyyMM);
        let dayFormatted;
        const year = yyyyMM.getFullYear();
        const month = String(yyyyMM.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작
        const date = String(yyyyMM.getDate()).padStart(2, '0');
              dayFormatted = `${year}-${month}-${date}`;
        return dayFormatted;
    }

    getDataList(){
        this.isLoading = true;
        let searchParams = this.getSearchParams();
        console.log(`this.searchParams : ${JSON.stringify(searchParams)}`);
        console.log(searchParams);
        getDataList({...searchParams}).then( result => {
            //console.log(JSON.stringify(result));
            let { resultList} = result;
        
            if(resultList.length == 0) {
                this.showToast('No data','검색조건에 만족하는 데이터가 존재하지 않습니다.','error');
                this.isLoading = false;
                return;
            }
            console.log(resultList);
            this.resultList = resultList;
            this.handleData(this.resultList);
            this.sumAverage(this.resultList);
            this.isLoading = false;
        }).catch(error => {
            this.showToast('관리자문의','관리자 한테 문의하세요.','error');
            console.log(JSON.stringify(error), ' 다빈도 부품 결품율 error');
            this.isLoading = false;
        });
    }
    ////// 화면 row병합하기 위한 데이터 가공
    handleData(data) {
        let currentpurchaseId = '';
        console.log('handleData');
        data.forEach((item, index) => {
            if (item.poId === currentpurchaseId) {
                item.rowspan = 1; 
                item.isHidden = 'slds-hide'; 
            } else {
                item.rowspan = item.totalItems;
                currentpurchaseId = item.poId;
            }
        });

        this.poData = data;
    }

    // Rate by Order / Rate by Item 계산 
    sumAverage(rowList){
        console.log('화면에 표기할 Average 계산');
        const poSet = new Set();
        let orderCnt = 0;   
        let supplyCnt = 0; 
        //주문별 rate 계산하기 위해
        rowList.forEach(r => {
            if (!poSet.has(r.poId)) {
                poSet.add(r.poId);
                this.sumList.push(r);
            }
        });

        rowList.forEach(r => {
            if(r.orderStatus ==='O') orderCnt++;  
            if(r.supplyStatus ==='O') supplyCnt++; 
            //if(r.supplyMaterial ==='400206-00913A') supplyCnt++; 
        });
       
        //// 총 주문 카운트
        let totalOrderCnt = this.sumList.length;
        //// 총 Item 카운트 
        let totalItemCnt  = this.resultList.length;
       
        //// 총 주문의 Order Material 계산
        this.rateOrderPerOrder  = orderCnt  == 0 ? 100.00 : Math.trunc(((100-((orderCnt/totalOrderCnt)*100))*10))/10;
        //// 총 주문의 Supply Material 계산
        this.rateOrderPerSupply = supplyCnt == 0 ? 100.00 : Math.trunc(((100-((supplyCnt/totalOrderCnt)*100))*10))/10;
        //// 총 아이템의 Order Material 계산
        this.rateItemPerOrder   = orderCnt  == 0 ? 100.00 : Math.trunc(((100-((orderCnt/totalItemCnt)*100))*10))/10;
        //// 총 아이템의 Supply Material 계산
        this.rateItemPerSupply  = supplyCnt == 0 ? 100.00 : Math.trunc(((100-((supplyCnt/totalItemCnt)*100))*10))/10;
    }
    //Excel Data생성하기
    handleExcelDownload(){
        
        if(this.poData.length ==0) {
            this.showToast('No data','조회된 데이터가 없습니다','error');
            return;
        } 
     
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('다빈도부품결품율관리');
       
        
        ///Header
        let columns = [
             { header: 'SO Type', key: 'soType', width: 15, style: { alignment: { horizontal: 'center' }}}
            ,{ header: 'Doc. Date', key: 'docDate', width: 15, style: { alignment: { horizontal: 'center' }}}
            ,{ header: 'SO No.', key: 'soNo', width: 15, style: { alignment: { horizontal: 'center' }}}
            ,{ header: 'Item', key: 'item', width: 15, style: { alignment: { horizontal: 'left' }}}
            ,{ header: 'Order Material', key: 'orderMaterial', width: 15, style: { alignment: { horizontal: 'left' }}}
            ,{ header: 'ABC Ind.', key: 'orderAbc', width: 15 , style: { alignment: { horizontal: 'center' }}}
            ,{ header: 'Status', key: 'orderStatus', width: 15 , style: { alignment: { horizontal: 'center' }}}
            ,{ header: 'Supply Material', key: 'supplyMaterial', width: 15, style: { alignment: { horizontal: 'left' }}}
            ,{ header: 'ABC Ind.', key: 'supplyAbc', width: 15, style: { alignment: { horizontal: 'center' }}}
            ,{ header: 'Status', key: 'supplyStatus', width: 15, style: { alignment: { horizontal: 'center' }}}
            ,{ header: 'Supply Material Description', key: 'supplyDesc', width: 15, style: { alignment: { horizontal: 'left' }}}
            ,{ header: 'Order Qty', key: 'qtyUnit', width: 15, style: { alignment: { horizontal: 'right' }}}
            ,{ header: 'Unit Per Price', key: 'unitPerPrice', width: 15, style: { alignment: { horizontal: 'right' }}}
        ];
        if (this.isAdmin) {  
            columns.unshift ({ header: 'Sold-to', key: 'dealerName', width: 15, style: { alignment: { horizontal: 'center' }}});
        }
        console.log('after header');

        worksheet.columns = columns;
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
        this.poData.forEach((sample) => {
            const rowData ={
                soType: sample.soType
                ,docDate: sample.docDate
                ,soNo: sample.soNo
                ,item: sample.item
                ,orderMaterial: sample.orderMaterial
                ,orderAbc: sample.orderAbc
                ,orderStatus: sample.orderStatus
                ,supplyMaterial: sample.supplyMaterial
                ,supplyAbc: sample.supplyAbc
                ,supplyStatus: sample.supplyStatus
                ,supplyMaterial: sample.supplyMaterial
                ,supplyDesc : sample.supplyDesc
                ,qtyUnit: sample.qtyUnit
                ,unitPerPrice: Number(sample.unitPerPrice).toLocaleString()
                ,rowspan : sample.rowspan
            };
            if(this.isAdmin){
                rowData.dealerName=sample.dealerName;
            };
            const row = worksheet.addRow(rowData);
            // const row = worksheet.addRow({
            //     soType: sample.soType
            //     ,docDate: sample.docDate
            //     ,soNo: sample.soNo
            //     ,item: sample.item
            //     ,orderMaterial: sample.orderMaterial
            //     ,orderAbc: sample.orderAbc
            //     ,orderStatus: sample.orderStatus
            //     ,supplyMaterial: sample.supplyMaterial
            //     ,supplyAbc: sample.supplyAbc
            //     ,supplyStatus: sample.supplyStatus
            //     ,supplyMaterial: sample.supplyMaterial
            //     ,qtyUnit: sample.supplyDesc
            //     ,unitPerPrice: sample.unitPerPrice
            //     ,rowspan : sample.rowspan
                
            // });
           
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
        // 셀병합
        worksheet.eachRow((row, rowNumber) => {
            if (rowNumber === 1) return;

            const sample = this.poData[rowNumber - 2];
            if (!sample) return; 
            
            // rowspan이 1 이상이면 해당 범위만큼 병합 처리
            if (sample.rowspan > 1) {
                worksheet.mergeCells(`A${rowNumber}:A${rowNumber + sample.rowspan - 1}`);
                worksheet.mergeCells(`B${rowNumber}:B${rowNumber + sample.rowspan - 1}`);
                worksheet.mergeCells(`C${rowNumber}:C${rowNumber + sample.rowspan - 1}`);
                if(this.isAdmin){
                    worksheet.mergeCells(`D${rowNumber}:D${rowNumber + sample.rowspan - 1}`);
                }
            }
        });

        let footerRow1;
        let footerRow2;
        let oFooterRow;
        let tFooterRow;

        if(this.isAdmin){
            oFooterRow =[
                'Rate by Order','', '', '', '', '', '', '', '', '','Order Material',`${this.rateOrderPerOrder}%`,'Supply Material	',`${this.rateOrderPerSupply}%`
            ];
            footerRow1 = worksheet.addRow(oFooterRow);
            worksheet.mergeCells(`A${this.poData.length + 2}:J${this.poData.length + 2}`);
            tFooterRow =[
                'Rate by Items','' , '', '', '', '', '', '', '', '','Order Material',`${this.rateItemPerOrder}%`,'Supply Material	',`${this.rateItemPerSupply}%`
            ];
            footerRow2 = worksheet.addRow(tFooterRow);
            worksheet.mergeCells(`A${this.poData.length + 3}:J${this.poData.length + 3}`);
        } else{
            oFooterRow =[
                'Rate by Order', '', '', '', '', '', '', '', '','Order Material',`${this.rateOrderPerOrder}%`,'Supply Material	',`${this.rateOrderPerSupply}%`
            ];
            footerRow1 = worksheet.addRow(oFooterRow);
            worksheet.mergeCells(`A${this.poData.length + 2}:I${this.poData.length + 2}`);
            tFooterRow =[
                'Rate by Items', '', '', '', '', '', '', '', '','Order Material',`${this.rateItemPerOrder}%`,'Supply Material	',`${this.rateItemPerSupply}%`
            ];
            footerRow2 = worksheet.addRow(tFooterRow);
            worksheet.mergeCells(`A${this.poData.length + 3}:I${this.poData.length +3}`);
        }
        //const footerRow2 = worksheet.addRow([tFooterRow]);
         // const footerRow1 = worksheet.addRow([
        //     'Rate by Order', '', '', '', '', '', '', '', '','Order Material',`${this.rateOrderPerOrder}%`,'Supply Material	',`${this.rateOrderPerSupply}%`
        // ]);
        //worksheet.mergeCells(`A${this.poData.length + 2}:I${this.poData.length + 2}`); 
        // const footerRow2 = worksheet.addRow([
        //     'Rate by Items', '', '', '', '', '', '', '', '','Order Material',`${this.rateItemPerOrder}%`,'Supply Material	',`${this.rateItemPerSupply}%`
        // ]);
        // worksheet.mergeCells(`A${this.poData.length + 3}:I${this.poData.length +3}`); 

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
            saveAs(blob,'다빈도부품결품율관리.xlsx');
        });
        
    }

     // toast message.
     showToast(title,message,variant) { 
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    resetData(){
        this.resultList = [];
        this.poData = [];
        // this.excelData = [];
        this.sumList = [];
        this.rateOrderPerOrder = 0
        this.rateOrderPerSupply= 0
        this.rateItemPerOrder  = 0
        this.rateItemPerSupply = 0
    }

    // styleCSS() {
    //     const style = document.createElement('style');
	// 	style.innerText = `
    //     c-d-n_-frequent-parts-missing-rate-table>div {
    //         max-height: calc(100vh - 27rem);
    //         overflow: scroll;
    //     }

    //     c-d-n_-frequent-parts-missing-rate-table>div thead {
    //         position: sticky;
    //         z-index: 3;
    //         top: -1px;
    //     }
    //     `;
	// 	this.template.querySelector('div').appendChild(style);
    // }
}