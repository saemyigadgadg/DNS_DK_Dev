import { LightningElement, track,api, wire} from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

//Modal
import OrderStatusModal  from 'c/dN_AgencyCustomerOrderStatusModal';
import ReturnListModal  from 'c/dN_AgencyCustomerReturnListModal';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


//LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';

//Apex 
import getDataList from '@salesforce/apex/DN_AgencyCustomerOrderCreateController.getOrderSummaryList';
const formatKey = `dN_AgencyCustomerOrderManagementTable`;
export default class DN_AgencyCustomerOrderManagementTable extends NavigationMixin(LightningElement) {
    
    searchParams = {};
    isData = 'false';
    /**
     * LMC
     */
    @wire(MessageContext)
    messageContext;
    subscription = null;
    // 클래스에서 페이징 처리
    lastRecordId ='';
    recordList =[];
    // 공통 컴포넌트에서 페이지 관련 필드 상속받아옴
    @api itemsPerPage;
    @api currentPage;
    @api pagesPerGroup;
    @api orderByField;
    @api orderBy;
    @api currentUserInfo;
    dateKeyField = 'FM_OrderDate__c';
    totalPage = 0;
    nextPage =1;
    
    @api uuid;
    isLoading = false;
    dataList=[];

    get totalItemCount() {
        return this.dataList.reduce((totalItemCount, currentItem) => totalItemCount + currentItem.totalItemCount, 0);
    }
    get totalItemAmount() {
        return this.dataList.reduce((totalItemAmount, currentItem) => totalItemAmount + currentItem.totalItemAmount, 0);
    }

    connectedCallback() {
        //this.getHistoryData();
        if(!this.subscription) {
            this.setSubscriptionLMC();        
        }
    }
    

    disconnectedCallback() {
        // this._excelFormatData = [];
        this.isImmediateStop = true;
        this.blobExcel = undefined;
        //this.removeHistoryData();
        
    }


    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
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
                            //console.log(JSON.stringify(msg.message), ' < ==msg.message');
                            this.setFilterChange(msg.message);
                        } 
                        if(msg.type =='defaultFilter') {
                            //console.log(JSON.stringify(msg.message), '    :::::::defaultFilter');
                            this.setFilterChange(msg.message); 
                        }
                        break;
                    case 'dN_DealerPortalButton':
                        //버튼
                        if(msg.type =='Seach') {
                            console.log('serach11');
                            console.log(JSON.stringify(this.searchParams));
                            this.isImmediateStop = this.isExcelDataLoading = true;
                            this.blobExcel = undefined;
                            // this._excelFormatData = [];
                            this.excelDataMap = new Map();
                            this.getData('Seach');
                        }else if(msg.type == 'ExcelDownload') {
                            console.log('ExcelDownload');
                            //this._exceldata = 
                            // this._excelFormatData = []; //초기화
                            if(this.dataList.length < 1) {
                                this.showToast('', '검색된 데이터가 존재하지 않습니다.', 'warning')
                                return ;
                            }

                            this.directExcelDownload();
                            
                            // console.time("excelDownloadSerial");
                            // this.excelDownload();
                        }
                        break;
                    case 'dN_DealerPortalQueryPage':
                        //console.log(JSON.stringify(msg), ' msg');
                        this.nextPage = msg.message.nextpage;
                        this.currentPage = msg.message.currentPage;
                        this.getData('PageChange');
                        break;  
                }
            }
        });
    }

    setFilterChange(message) {
        this.searchParams[message.field] = message.value;
        console.log('필터체인지');
    }

    getSearchParams() {
        let searchParams = {};
        Object.keys(this.searchParams).forEach(key=>{
            if(key === 'CustomerName__c') {
                searchParams['customerId'] = this.searchParams[key];
            }else if(key === 'productCode') {
                if(this.searchParams[key])
                    searchParams['partNameList'] = this.searchParams[key]?.split(',');
                else 
                    searchParams['partNameList'] = undefined;
            }else {
                searchParams[key] = this.searchParams[key];
            }
        });
        return searchParams;
    }

    //데이터 테이블 데이터 조회
    getData(type) {
        this.showSpinner();
        let searchParams = this.getSearchParams();
        if(type =='Seach')
        this._excelDownloadParams = searchParams; // 버튼 클릭후 Excel Download 용

        this.currentPage = type =='Seach'? 1 : this.currentPage
        this.nextPage = type =='Seach'? 1 : this.nextPage
        // 페이징 처리 데이터
        let page = {
            itemsPerPage : this.itemsPerPage,
            currentPage : this.currentPage,
            pagesPerGroup : this.pagesPerGroup,
            orderByField : this.orderByField,
            orderBy : this.orderBy,
            dateKeyField : this.dateKeyField
        }
        let nextPage = this.nextPage;

        
        getDataList({...searchParams, page, nextPage}).then( result => {
            let { status, recordListSet, page } = result;
            console.log('page : '+ JSON.stringify(page));
            if(status.code === 200) {
                //성공
                this.dataList = recordListSet;
                //this.setHistoryData(page,searchParams);
                this.totalPage = Math.ceil(page.totalRecordSize / page.itemsPerPage);
                let mas = {
                    'currentPage' : page.currentPage,
                    'itemsPerPage' : page.itemsPerPage,
                    'pagesPerGroup' : page.pagesPerGroup,
                    'currentRecordSize' : this.dataList.length,
                    'totalRecordSize' : page.totalRecordSize,
                    'startIdx' : page.startIdx,
                    'endIdx' : page.endIdx,
                    'totalPage' : this.totalPage,
                    'eventType' : type
                };
                this.messagePublish('dataListSearch',mas);

                if(type =='Seach') {
                    this.isImmediateStop = false;
                    this.excelDownloadParallel(page.totalRecordSize, 500);
                }
                
                // if(type=='') {
                //     this.messagePublish('historyBack',{
                //         uuid : this.uuid,
                //         type : 'historyBack',
                //         search : JSON.parse(window.sessionStorage.getItem(formatKey)).searchParams
                //     });    
                // }
            }

            else if(status.code === 400) {
                this.dataList = [];
                console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
            }else if(status.code === 500) {
                this.dataList = [];
                console.log(JSON.stringify(error), '관리자 한테 문의하세요.');
            }

            // this.exceldata = this.dataList; // 추후 전체데이터 쿼리도 필요할 수 있음
            
            
            
            this.stopSpinner(500);
        }).catch(error => {
            console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
        });
    }

    // _excelFormatData = [];
    // excelDownload(_currentPage, _nextPage) {
    //     this.showSpinner();
    //     let searchParams = this._excelDownloadParams;
    //     let currentPage = (!_currentPage) ? 1 : _currentPage;
    //     let nextPage = (!_nextPage) ? 1 : _nextPage;
    //     // 페이징 처리 데이터
    //     let page = {
    //         itemsPerPage : this.itemsPerPage,
    //         currentPage : currentPage,
    //         pagesPerGroup : this.pagesPerGroup,
    //         orderByField : this.orderByField,
    //         orderBy : this.orderBy
    //     }

    //     getDataList({...searchParams, page, nextPage}).then( result => {
    //         let { status, recordListSet, page } = result;
    //         console.log('recordListSet : '+ JSON.stringify(recordListSet));
    //         console.log('page : '+ JSON.stringify(page));
    //         if(status.code === 200) {
    //             //성공
    //             console.log('ExcelDownload 버튼 클릭 성공');
    //             this._exceldata = this._exceldata.concat(recordListSet);
                
    //             if(page.totalRecordSize <= this._exceldata.length) {
    //                 //ExcelDownload
    //                 // console.log(JSON.stringify(this._exceldata));
    //                 (async()=>{
    //                     try {
    //                         const excelDownloadResult = this.generateExcel();
    //                         console.log(`excelDownloadResult: ${excelDownloadResult}`);
    //                     } catch (error) {
    //                         console.error('Error fetching data:', error);
    //                     }
    //                     console.timeEnd('excelDownloadSerial');
    //                 })();
                    
    //                 this.stopSpinner(500);
    //             }else {
    //                 this.excelDownload(page.currentPage, page.currentPage+1);
                    
    //             }

    //         }

    //         if(status.code === 400) {
    //             this._exceldata = [];
    //             console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
    //             this.stopSpinner(500);
    //         }
            
    //         if(status.code === 500) {
    //             this._exceldata = [];
    //             console.log(JSON.stringify(error), '관리자 한테 문의하세요.');
    //             this.stopSpinner(500);
    //         }
            
    //     }).catch(error => {
    //         console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
    //     });
        
    // }
    isExcelDataLoading = true;
    excelDataMap = new Map();
    //병렬작업방법으로 필터 조건에 맞는 모든 데이터 호출
    async excelDownloadParallel(totalRecordSize, itemsPerPage = 200) {
        console.time("excelDownloadParallel");
        
        const concurrentLimit = 10;  
        const TOTALSIZE = totalRecordSize / itemsPerPage;
        try {
            console.log('concurrentLimit : ' + concurrentLimit);
            // 배치 단위로 처리
            let promises = [];
            for (let i = 0; i < TOTALSIZE; i++) {
                promises.push(this.excelDownloadParallelRecursive(i ,i+1, itemsPerPage));

                if (promises.length === concurrentLimit) {
                    await Promise.all(promises);
                    promises = [];
                }   
            }

            if(promises.length > 0)
                await Promise.all(promises);

            this.isExcelDataLoading = false;
            // this.generateExcel();
        } catch (error) {
            console.info('ExcelDownloadParallel Error occurred:', error);
            this.isExcelDataLoading = false;
            this.blobExcel = undefined;
            this.excelDataMap = new Map();
            // this._excelFormatData = [];
        } finally {
            this.stopSpinner(500);
        }

        console.timeEnd("excelDownloadParallel"); 
    }

    
    

    //이전
    // async excelDownloadParallel2() {
    //     console.time("excelDownloadParallel2");
    //     let promises = [];
    //     const TOTALSIZE = this.totalPage;
    //     for (let i = 0; i < TOTALSIZE; i++) {
    //         promises.push(this.excelDownloadParallelRecursive(i ,i+1));
    //     }
    //     try {
    //         const promiseResult = await Promise.all(promises);    
    //         const excelDownloadResult = await this.generateExcel();
    //                         console.log(`excelDownloadResult: ${excelDownloadResult}`);
    //     } catch (error) {
    //         console.error('excelDownloadParallel2 Error occurred:', error);
    //     } finally {
    //         this.stopSpinner(500);
    //     }
    //     console.timeEnd("excelDownloadParallel2"); 
    // }

    isImmediateStop = false;
    async excelDownloadParallelRecursive (_currentPage, _nextPage, itemsPerPage = 200) {
        if(this.isImmediateStop) return Promise.reject('Immediate Stop');

        // this.showSpinner();
        let searchParams = this._excelDownloadParams;
        let currentPage = (!_currentPage) ? 1 : _currentPage;
        let nextPage = (!_nextPage) ? 1 : _nextPage;

        let flattenOrderData = async (orders) => {
            const flattenedData = [];
          
            // 각 주문을 순차적으로 처리
            for (const order of orders) {
              const { 
                seq, 
                customerName, 
                customerOrerNumber,
                orderDate,
                totalItemAmount,
                deliveryStatus,
                piroirty,
                dealerPo,
                currencyCode,
                itemList
              } = order;

              // 각 품목에 대해 주문 정보와 품목 정보 결합
              for (const item of itemList) {
                flattenedData.push({
                    seq, 
                    customerName, 
                    customerOrerNumber,
                    orderDate,
                    totalItemAmount,
                    deliveryStatus,
                    piroirty,
                    dealerPo,
                    currencyCode,
                    itemSeq : item.itemSeq,
                    replacingPartName : item.replacingPartName,
                    replacingPartDetails : item.replacingPartDetails,
                    quantity : item.quantity,
                    unit : item.unit,
                    avaiableQuantity : item.avaiableQuantity,
                    reservedQuantity : item.reservedQuantity,
                    itemCurrencyCode: item.currencyCode,
                    customerPrice : item.customerPrice,
                    discountAmount : item.discountAmount,
                    discountRate : item.discountRate,
                    giDate : item.giDate,
                });
              }
            }
          
            return flattenedData;
        }
        
        try {
             // 페이징 처리 데이터
            let currentPageInfo = {
                itemsPerPage : itemsPerPage, //this.itemsPerPage,
                currentPage : currentPage,
                pagesPerGroup : this.pagesPerGroup,
                orderByField : this.orderByField,
                orderBy : this.orderBy,
                dateKeyField : this.dateKeyField
            };
            const result = await getDataList({...searchParams, page:currentPageInfo, nextPage});

            let { status, recordListSet, page } = result;
            // console.log('recordListSet : '+ JSON.stringify(recordListSet));
            console.log('page : '+ JSON.stringify(page));
            if(status.code === 200) {
                //성공
                // console.log('ExcelDownload 버튼 클릭 성공');
                // this._exceldata = this._exceldata.concat(recordListSet);
                const excelFormatData = await flattenOrderData(recordListSet);
                this.excelDataMap.set(page.currentPage , excelFormatData);
                // this._excelFormatData = this._excelFormatData.concat(excelFormatData);
            }

            else if(status.code === 400 || status.code === 500) {
                this.excelDataMap = new Map();
                const errorMsg = (status.code === 400) ? 'excelDownloadParallelRecursive error' : '관리자 한테 문의하세요.';
                console.log(JSON.stringify(errorMsg), ' excelDownloadParallelRecursive error');
                return Promise.reject('excelDownloadParallelRecursive getDataList Error');
            }
        } catch (error) {
            // 네트워크 또는 API 호출 실패 처리
            console.log('dN_AgencyCustomerOrderManagementTable error', JSON.stringify(error));
            return Promise.reject('');
            // this.stopSpinner(500);
        }
        return Promise.resolve();
    }

    intervalId;
    async directExcelDownload() {
        this.showSpinner();
        this.intervalId = setInterval(async () => {
            if(this.isImmediateStop) {
                console.log('멈춰!!');
                if(this.intervalId) {
                    clearInterval(this.intervalId);
                    this.intervalId = undefined;
                    this.stopSpinner(0);
                }
                return;
            }

            if(!this.isExcelDataLoading) {
                if(this.intervalId) {
                    clearInterval(this.intervalId);
                    this.intervalId = undefined;
                }

                if(!this.blobExcel) {
                    await this.generateExcel();
                }

                const link        = document.createElement('a');
                link.href         = URL.createObjectURL(new Blob([this.blobExcel], { type: 'application/octet-stream' }));
                link.download     = this.excelName + '.xlsx';
                link.click();
                URL.revokeObjectURL(link.href);
                
                this.stopSpinner(500);
            }
        }, 1000);
    }

    blobExcel;
    excelName = '_고객주문서관리';
    async generateExcel() {
        console.time("generateExcel");
        try {
            var totalItemAmountResult = 0;
    
            console.log('generateExcel');
            const workbook = new ExcelJS.Workbook();
            const worksheet1 = workbook.addWorksheet(this.excelName);
    
            //header 
            //주문번호	고객사명	고객주문번호	주문일	주문금액	통화	상태	긴급도	Dealer PO No	납입지연	항목	주문품번	품명	수량	단위	가용재고	예약수량	통화	고객판매가	할인판매금액	할인율(%)	출고일자
            //seq, customerName, customerOrerNumber, orderDate, currencyCode, status, piroirty, dealerPoNo
            let headerParams = [
                { key: 'seq', header:'주문번호', },
                { key: 'customerName', header:'고객사명', },
                { key: 'customerOrerNumber', header:'고객주문번호', },
                { key: 'orderDate', header:'주문일', },
                { key: 'totalItemAmount', header:'주문금액', },
                { key: 'currencyCode', header:'통화', },
                { key: 'deliveryStatus', header:'상태', },
                { key: 'piroirty', header:'긴급도', },
                { key: 'dealerPo', header:'Dealer PO No' },
                { key: 'itemSeq', header:'항목' },
                { key: 'replacingPartName', header:'주문품번' },
                { key: 'replacingPartDetails', header:'품명' },
                { key: 'quantity', header:'수량' },
                { key: 'unit', header:'단위' },
                { key: 'avaiableQuantity', header:'가용재고' },
                { key: 'reservedQuantity', header:'예약수량' },
                { key: 'itemCurrencyCode', header:'통화', },
                { key: 'customerPrice', header:'고객판매가' },
                { key: 'discountAmount', header:'할인판매금액', },
                { key: 'discountRate', header:'할인율', },
                { key: 'giDate', header:'출고일자', },
            ];
            
            worksheet1.columns = headerParams;

            worksheet1.getColumn('orderDate').numFmt = 'yyyy-mm-dd'; // 날짜 포맷
            worksheet1.getColumn('totalItemAmount').numFmt = '#,##0'; 
            worksheet1.getColumn('customerPrice').numFmt = '#,##0'; 
            worksheet1.getColumn('discountAmount').numFmt = '#,##0'; 
            worksheet1.getColumn('giDate').numFmt = 'yyyy-mm-dd';

            worksheet1.getRow(1).eachCell((cell, colNumber) => {
                cell.fill = {
                    type: 'pattern',
                    pattern: 'solid',
                    fgColor: { argb: 'D3D3D3' } 
                };
            });
    
            //data
            let orderList = [];
            for(let i = 0; i < this.excelDataMap.size; i++) {
                let excelFormatData = this.excelDataMap.get(i+1);
                worksheet1.addRows(excelFormatData);    
                orderList = orderList.concat(excelFormatData);
                // UI가 멈추지 않도록 배치 처리 후 requestAnimationFrame을 사용하여 비동기 처리
                await new Promise(resolve => {
                    requestAnimationFrame(resolve);
                });
            }

            let orderSet = new Set();
            for(let i = 0; i < orderList.length; i++) {
                orderSet.add(orderList[i].seq);
            }

            // worksheet1.columns.forEach((column) => {
            //     worksheet1.getColumn(column.key).eachCell((cell) => {
            //       // 테두리 설정
            //       cell.border = {
            //         top: { style: 'thin', color: { argb: 'FF000000' } },
            //         left: { style: 'thin', color: { argb: 'FF000000' } },
            //         bottom: { style: 'thin', color: { argb: 'FF000000' } },
            //         right: { style: 'thin', color: { argb: 'FF000000' } }
            //       };
            //     });
            // });
    
            worksheet1.getCell(`C${orderList.length+2}`).value = '합계';
            const totalOrderCountCell = worksheet1.getCell(`D${orderList.length+2}`);
            totalOrderCountCell.value = orderSet.size;
            totalOrderCountCell.numFmt = null;
            const sumCell = worksheet1.getCell(`E${orderList.length+2}`);
            sumCell.value = { formula: `sum(R2:R${orderList.length+1})`, result: totalItemAmountResult}; // result >> 동적으로 값을 계산하지 않으므로 편집하기를 누르지 않으면 계산이 안됨.
    
            

            // BUFFER
            // setTimeout(async()=>{
                const buffer = await this.writeBufferAsync(workbook); //workbook.xlsx.writeBuffer(); 
                this.blobExcel = new Blob([buffer]); //new Blob([buffer]);
            // }, 0)
            
            // const link        = document.createElement('a');
            // link.href         = URL.createObjectURL(new Blob([buffer], { type: 'application/octet-stream' }));
            // link.download     = excelName + '.xlsx';
            // link.click();
            // URL.revokeObjectURL(link.href);
           
        } catch (error) {
            console.error(error);
        }
        console.timeEnd("generateExcel");
        return true;
    }

    // 버퍼 생성 작업을 비동기적으로 나누어 처리하는 함수
    // 속도 이슈 비슷
    async writeBufferAsync(workbook) {
        return new Promise((resolve, reject) => {
        const processBuffer = () => {
            workbook.xlsx.writeBuffer().then((buffer) => {
            resolve(buffer);  // 작업 완료 시 버퍼 반환
            }).catch(reject);
        };

        // `setTimeout`을 사용하여 메인 쓰레드가 차단되지 않도록 비동기 처리
        setTimeout(processBuffer, 0);
    });
  }


    navigateToDetail(event) {
        //window.sessionStorage.setItem('isBack','true');
        // this.messagePublish('historyBack',{
        //     uuid : this.uuid,
        //     type : 'historyBack'
        // });
        let rowIndex = event.currentTarget.getAttribute('accesskey');
        let orderId = this.dataList[rowIndex].id;
        // this[NavigationMixin.Navigate]({
        //     "type": "standard__recordPage",
        //     "attributes": {
        //         "recordId": orderId,
        //         "objectApiName": "DealerOrder__c",
        //         "actionName": "view"
        //     },
        // });

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: orderId, // 대상 레코드 ID
                objectApiName: 'DealerOrder__c',
                actionName: 'view'
            }
        }).then(url => {
            window.open(`${url}`, ``, `top=10, left=10, width=1500, height=1000, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`);
            //window.open(url, '_blank');
        });

    }

    showSpinner(milliseconds) {
        setTimeout(() => {
            this.isLoading = true;
        }, milliseconds)
    }

    stopSpinner(milliseconds) {
        setTimeout(() => {
            this.isLoading = false;
        }, milliseconds)
    }

    // 
    async openOrderStatusModal(event) {
    let rowIndex = event.currentTarget.getAttribute('accesskey');
        let orderId = this.dataList[rowIndex].id;
        const result = await OrderStatusModal.open({
            orderId,
        });
    }

    async openReturnOrderItemModal(event) {
        let rowIndex = event.currentTarget.getAttribute('accesskey');
        if(this.dataList[rowIndex].returnOrder !== 'Y') {
            return;
        }

        let orderId = this.dataList[rowIndex].id;
        const result = await ReturnListModal.open({
            orderId,
        });
    }
    
    getHistoryData() {
        
        if(window.sessionStorage.getItem('isBack') =='true' ) {
            //console.log(JSON.stringify(window.sessionStorage.getItem(formatKey)));
            if(window.sessionStorage.getItem(formatKey) !=null && window.sessionStorage.getItem('isData') =='true') {
                let { page, nextPage, searchParams } = JSON.parse(window.sessionStorage.getItem(formatKey));
                this.itemsPerPage = page.itemsPerPage;
                this.currentPage = page.currentPage;
                this.pagesPerGroup = page.pagesPerGroup;
                this.orderByField = page.orderByField;
                this.orderBy = page.orderBy;
                this.dateKeyField = page.dateKeyField;
                this.dateKeyField = page.dateKeyField;
                this.nextPage = nextPage;
                this.searchParams = searchParams;
                new Promise((resolve) => {
                    this.getData('');    
                    resolve();
                }).then(async () => {
                    window.sessionStorage.setItem('isBack', 'false');
                    // console.log(JSON.stringify(searchParams), ' :: searchParams11');
                    // this.searchParams = window.sessionStorage.getItem(formatKey);
                    // this.messagePublish('historyBack',{
                    //     uuid : this.uuid,
                    //     type : 'historyBack',
                    //     search : searchParams
                    // });
                    
                })
                
            }
        } else {
            this.removeHistoryData();
        }
    }

    setHistoryData(pages, searchData) {
        let page = {
            itemsPerPage : pages.itemsPerPage,
            currentPage : pages.currentPage,
            pagesPerGroup : pages.pagesPerGroup,
            orderByField : this.orderByField,
            orderBy : this.orderBy,
            dateKeyField : this.dateKeyField
            
        }
        let nextPage = this.nextPage;
        let param= {
            page : page,
            nextPage : nextPage,
            searchParams : searchData
        }
        
        if(searchData !=undefined) {
            this.searchParams = searchData;
        } 
        this.isData = this.dataList.length > 0 ? 'true' : 'false';
        //console.log(JSON.stringify(searchData), ' :: set history data searchParams');
        window.sessionStorage.setItem('isData', this.isData);
        window.sessionStorage.setItem(formatKey,JSON.stringify(param));
    }
    removeHistoryData() {
        window.sessionStorage.clear();
    }

}