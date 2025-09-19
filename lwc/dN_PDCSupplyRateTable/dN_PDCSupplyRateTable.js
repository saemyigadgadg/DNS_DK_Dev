import { LightningElement, track,api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';
import {CurrentPageReference} from 'lightning/navigation';
//static resource
import { loadScript, loadStyle }     from 'lightning/platformResourceLoader';
import EXCEL_JS from '@salesforce/resourceUrl/ExcelJS'; 
import FileSaver from '@salesforce/resourceUrl/FileSaver'; 
//Apex 
import getSupplyList from '@salesforce/apex/DN_PDCSupplyRateTableController.getSupplyList';

export default class DN_PDCSupplyRateTable extends NavigationMixin(LightningElement) {
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

    @track supplyList =[];
    @track excelData = [];
    @track processedSamples = [];
    @track distinctDoData = [];
    @track distinctDoitData = [];
    @track totalOrderCnt = 0; //요청수량합
    @track totalExportCnt= 0; //출고수량합(1일이내건)
    @track totalOrderAvg = 0; //항목별공급율평균
    @track totalExportAvg= 0; //주문별공급율평균
    @track totalEOAvg    = 0; //아이템 수량별 공급율합계
    @track totalItem =0;
    @track totalItemPer=0;
    @track totalOrder = 0;
    @track totalOderPer=0;
    @track isLoading = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log(currentPageReference);
        } 
    }

    connectedCallback() {
        console.log('부품대리점공금율 connected Callback');
        Promise.all([
            loadScript(this, EXCEL_JS + '/unpkg/exceljs.min.js'),
            //loadScript(this, this.excelJs),
            loadScript(this, this.fileSaver)
        ])
        .then(() => {  
            console.log('완료!!');
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
                            console.log(JSON.stringify(msg.message), '    :::::::defaultFilter');
                            this.setDefaultSetting(msg.message); 
                        }
                        break;
                    case 'dN_DealerPortalButton':
                        if(msg.type =='Seach') {
                            this.clearDataset();
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
                        //현재 부품 대리점 공급율은 필요없음
                        break;  
                }
            }
        });
    }

    setDefaultSetting(message) {
        this.searchParams[message.field] = message.value;
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
            console.log(`this.searchParams : ${JSON.stringify(searchParams)}`);
            console.log(searchParams);
            getSupplyList({...searchParams}).then( result => {
                console.log(result);
                let { status,supplyList} = result;
                if(status.code === 200) {
                    //성공
                    
                    if(supplyList.length == 0) {
                        this.showToast('No data','검색조건에 만족하는 데이터가 존재하지 않습니다.','error');
                        this.isLoading = false;
                        return;
                    }

                    this.supplyList = supplyList;
                    console.log('data setting');
                    this.processSamples(this.supplyList);
                    this.sumCalculate();
                    this.isLoading = false;
                }
    
                if(status.code === 400) {
                    this.supplyList = [];
                    console.log(JSON.stringify(error), ' 400 dN_PCDSUPPLYRATETABLE error');
                    this.showToast('관리자문의','관리자 한테 문의하세요.','error');
                    this.isLoading = false;
                    return;
                }
                
                if(status.code === 500){
                    console.log(JSON.stringify(error), ' 500 관리자 한테 문의하세요.');
                    this.showToast('관리자문의','관리자 한테 문의하세요.','error');
                    this.isLoading = false;
                    return;
                } 
            }).catch(error => {
                console.log(JSON.stringify(error), ' dN_PCDSUPPLYRATETABLE error');
                this.isLoading = false;
            });
    }
    
    processSamples(data) {
      
        let currentOrderId = '';
        let currentOrderItemId = '';
        let currentOrderNumber ='';
        //let currentOrderDimId =

       data.sort((a, b) => {
            const orderCompare = b.orderNumber.localeCompare(a.orderNumber); // orderNumber는 그대로 내림차순
            if (orderCompare !== 0) {
                return orderCompare;
            }
            return a.orderItemNumber.localeCompare(b.orderItemNumber); // 오름차순으로 변경
        });

        data.forEach((item, index) => {
           
            if (
                item.orderNumber== currentOrderNumber
                //item.doId === currentOrderId 
              //&&item.doitId === currentOrderItemId   
            ) {
                item.rowspan     = 1; 
                item.isHidden    = 'slds-hide'; 
                item.itemRowspan = 1; 
                item.itemRowHidden = item.totalOItemCnt == 1 ? '' : 'slds-hide'; 
            } else {
                item.rowspan     = item.totalExQty; // 이 항목의 `totalExQty` 값 기준으로 rowspan 설정
                item.itemRowspan = item.totalOItemCnt;
                currentOrderId   = item.doId;
                currentOrderItemId = item.doitId;
                currentOrderNumber = item.orderNumber;
            }
        });

        this.processedSamples = data;
        //가공한 데이터 엑셀
        console.log('processedSamples : '+ JSON.stringify(this.processedSamples));
        this.excelData = data;
    }

    sumCalculate(){
        const doSet = new Set();
        const doitSet = new Set();
         
        this.supplyList.forEach(ele => {
            if(!doSet.has(ele.doId)){
                doSet.add(ele.doId);
                this.distinctDoData.push(ele);
            }
        });
        this.supplyList.forEach(eles => {
            if(!doitSet.has(eles.doitId)){
                doitSet.add(eles.doitId);
                this.distinctDoitData.push(eles);
            }
        });
        // console.log('mergeId : '+ JSON.stringify(this.distinctDoData));
        // console.log('mergedoitId : '+ JSON.stringify(this.distinctDoitData));
      
        this.totalOrderCnt = this.distinctDoData.reduce((totalOrderQty,record) => {
            return totalOrderQty + record.totalOrderQty;
        },0);

        this.totalExportCnt = this.supplyList.reduce((sum,record) => {
            return sum + record.exQtyWiOneday;
        },0);
        //주문별 항목건수
        this.totalItem = this.distinctDoData.reduce((sum,record) => {
            return sum + record.totalOItemQty;
        },0);
        //항목별 공급율 sum
        this.totalItemPer = this.distinctDoitData.reduce((sum,record) => {
            return sum + record.rowPerOrderItem;
        },0);

        //주문건수
        this.totalOrder = this.distinctDoData.length;
        // this.totalOrder = this.distinctDoData.reduce((sum,record) => {
        //     // return sum + record.totalOItemQty;
        //     return sum += record.length;
        // },0);

        //주문별 공급율 sum
        this.totalOderPer = this.distinctDoData.reduce((sum,record) => {
            return sum + record.perOrder;
        },0);
       
        this.totalEOAvg = ((((this.totalExportCnt / this.totalOrderCnt) * 100.0) * 10) / 10).toFixed(2);//(Math.round(((this.totalExportCnt / this.totalOrderCnt) * 100.0) * 10) / 10).toFixed(2);
        this.totalOrderAvg = ((((this.totalItemPer / this.totalItem)) * 10) / 10).toFixed(2);//Math.round(((this.totalItemPer / this.totalItem)) * 10) / 10;
        this.totalExportAvg =((((this.totalOderPer /this.totalOrder)) * 10) / 10).toFixed(2); //(Math.round(((this.totalOderPer /this.totalOrder)) * 10) / 10).toFixed(2);
    }

    // 엑셀 다운로드
    handleExcelDownload() {
        if(this.excelData.length ==0) {
            this.showToast('No data','조회된 데이터가 없습니다','error');
            return;
        } 
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('대리점별공급율목록');
        ///Header
        worksheet.columns = [
            { header: '대리점명', key: 'dealerName', width: 15, style: { alignment: { horizontal: 'center' }}},
            { header: '주문일', key: 'orderDate', width: 15, style: { alignment: { horizontal: 'center' }}},
            { header: '고객사명', key: 'customerName', width: 15, style: { alignment: { horizontal: 'center' }}},
            { header: '주문번호', key: 'orderNumber', width: 15, style: { alignment: { horizontal: 'center' }}},
            { header: '항목', key: 'orderItemNumber', width: 15, style: { alignment: { horizontal: 'center' }}},
            { header: '품번', key: 'partNumber', width: 20 },
            { header: '품명', key: 'partName', width: 20 },
            { header: '요청수량', key: 'orderQty', width: 15, style: { alignment: { horizontal: 'right' } } },
            { header: '출고수량', key: 'exportQty', width: 15, style: { alignment: { horizontal: 'right' } } },
            { header: '출고일', key: 'exportDate', width: 15, style: { alignment: { horizontal: 'center' } } },
            { header: '소요일', key: 'dateGap', width: 15, style: { alignment: { horizontal: 'center' } } },
            { header: '항목별 공급율', key: 'perOrderItem', width: 15, style: { alignment: { horizontal: 'right' } } },
            { header: '주문별 공급율', key: 'perOrder', width: 15, style: { alignment: { horizontal: 'right' } } }
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
       
        this.excelData.forEach((sample, index) => {
            const row = worksheet.addRow({
                 dealerName: sample.dealerName , style: { alignment: {horizontal: 'center' }}
                ,orderDate: sample.orderDate ,style: { alignment: { horizontal: 'center' }}
                ,customerName: sample.customerName ,style: { alignment: { horizontal: 'left' }}
                ,orderNumber: sample.orderNumber ,style: { alignment: { horizontal: 'center' }}
                ,orderItemNumber: sample.orderItemNumber ,style: { alignment: { horizontal: 'center' }}
                ,partNumber: sample.partNumber ,style: { alignment: { horizontal: 'left' }}
                ,partName: sample.partName ,style: { alignment: { horizontal: 'left' }}
                ,orderQty: sample.orderQty ,style: { alignment: { horizontal: 'right' }}
                ,exportQty: sample.exportQty ,style: { alignment: { horizontal: 'right' }}
                ,exportDate: sample.exportDate ,style: { alignment: { horizontal: 'center' }}
                ,dateGap: sample.dateGap ,style: { alignment: { horizontal: 'right' }}
                ,perOrderItem:`${ sample.perOrderItem}%` ,style: { alignment: { horizontal: 'right' }}
                ,perOrder: `${sample.perOrder}%`,style: { alignment: { horizontal: 'right' }}
                ,rowspan : sample.rowspan
                ,itemRowspan : sample.itemRowspan
            })
          
            row.eachCell((cell) => {
               
                if (cell.value === null || cell.value === undefined) {
                    cell.value = '';  
                }
            
                cell.border = {
                    top: { style: 'thin', color: { argb: 'FF000000' } },
                    left: { style: 'thin', color: { argb: 'FF000000' } },
                    bottom: { style: 'thin', color: { argb: 'FF000000' } },
                    right: { style: 'thin', color: { argb: 'FF000000' } }
                };
                cell.alignment= {
                    vertical: 'middle'   
                };
            });
        });

        worksheet.eachRow((row, rowNumber) => {
            if (rowNumber === 1) return;

            const sample = this.excelData[rowNumber - 2];
            if (!sample) return; 
            
            // rowspan이 1 이상이면 해당 범위만큼 병합 처리
            if (sample.rowspan > 1) {
                worksheet.mergeCells(`A${rowNumber}:A${rowNumber + sample.rowspan - 1}`);
                worksheet.mergeCells(`B${rowNumber}:B${rowNumber + sample.rowspan - 1}`);
                worksheet.mergeCells(`C${rowNumber}:C${rowNumber + sample.rowspan - 1}`);
                worksheet.mergeCells(`D${rowNumber}:D${rowNumber + sample.rowspan - 1}`);
                worksheet.mergeCells(`M${rowNumber}:M${rowNumber + sample.rowspan - 1}`);
            }
         
        });
        
        worksheet.eachRow((row, rowNumber) => {
            if (rowNumber === 1) return;
            const sample = this.excelData[rowNumber - 2];
            if (!sample) return; 
        
            if (sample.itemRowspan > 1) {
                worksheet.mergeCells(`L${rowNumber}:L${rowNumber + sample.itemRowspan - 1}`);
            }

        });

        ///첫번째풋터
        const footerRow1 = worksheet.addRow([
            '요청수량 합','','', '', '', '', '', '', '', `${this.totalOrderCnt}`, '평균',`${this.totalOrderAvg}%`,`${this.totalExportAvg}%`
        ]);
        worksheet.mergeCells(`A${this.excelData.length+2}:I${this.excelData.length+2}`);
        // /////두번째풋터
        const footerRow2 = worksheet.addRow([
            '아이템 수량별 공급율 합계', '','','', '', '', '', '', '', '', '', '', `${this.totalEOAvg}%`
        ]);
        worksheet.mergeCells(`A${this.excelData.length+3}:L${this.excelData.length+3}`);
        
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
            saveAs(blob,'대리점공급율.xlsx');
        });
    }

    ////// toast메세지
    showToast(title,message,variant) { //success, warning, 및 error.
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    /// 초기화
    clearDataset(){
        this.supplyList=[];
        this.processedSamples=[];
        this.excelData=[];
        this.processedSamples=[];
        this.distinctDoData=[];
        this.distinctDoitData=[];
        this.totalOrderCnt=0;
        this.totalExportCnt=0;
        this.totalOrderAvg=0;
        this.totalExportAvg=0;
        this.totalEOAvg=0;
        this.totalItem=0;
        this.totalItemPer=0;
        this.totalOrder=0;
        this.totalOderPer=0;
    }
}