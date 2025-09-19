import { LightningElement, track,api, wire} from 'lwc';

//Modal
import OrderStatusModal  from 'c/dN_DealerPurchaseOrderStatusModal';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';
//Apex 
import getDataList from '@salesforce/apex/DN_PurchaseManagementTable.getOrderSummaryList';

export default class DN_PurchaseManagementTable extends NavigationMixin(LightningElement) {
    

    searchParams = {};

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
    totalPage = 0;
    nextPage = 1;
    
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
        if(!this.subscription) {
            this.setSubscriptionLMC();        
        }
    }

    disconnectedCallback() {
        this.isImmediateStop = true;
        this.blobExcel = undefined;
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
                            console.log(JSON.stringify(msg.message), ' < ==msg.message');
                            this.setFilterChange(msg.message);
                        } 
                        if(msg.type =='defaultFilter') {
                            console.log(JSON.stringify(msg.message), '    :::::::defaultFilter');
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
                            this.excelDataMap = new Map();
                            this.getData('Seach');
                        }else if(msg.type == 'ExcelDownload') {
                            console.log('ExcelDownload');
                            this._exceldata = []; //초기화

                            if(this.dataList.length < 1) {
                                this.showToast('', '검색된 데이터가 존재하지 않습니다.', 'warning')
                                return ;
                            }
                            this.directExcelDownload();
                            // this.excelDownloadParallel();
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
            orderBy : this.orderBy
        }
        let nextPage = this.nextPage;

        console.log(`getData this.searchParams : ${JSON.stringify(searchParams)}`);
        getDataList({...searchParams, page, nextPage}).then( result => {
            let { status, recordListSet, page } = result;
            // console.log('recordListSet : '+ JSON.stringify(recordListSet));
            console.log('page : '+ JSON.stringify(page));
            if(status.code === 200) {
                //성공
                this.dataList = recordListSet;

                // this.exceldata = this.dataList; // 추후 전체데이터 쿼리도 필요할 수 있음
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
            }

            if(status.code === 400) {
                this.dataList = [];
                console.log(JSON.stringify(error), ' dN_PurchaseManagementTable error');
                this.showToast('', '관리자에게 문의부탁드립니다.', 'Error');
            }else if(status.code === 500) {
                this.dataList = [];
                console.log(JSON.stringify(error), '관리자에게 문의하세요.');
                this.showToast('', '관리자에게 문의부탁드립니다.', 'Error');
            }

            this.stopSpinner(500);
        }).catch(error => {
            console.log(JSON.stringify(error), ' dN_PurchaseManagementTable error');
            
        });
    }

    navigateToDetail(event) {
        let rowIndex = event.currentTarget.getAttribute('accesskey');
        let order = this.dataList[rowIndex];

        switch (order.type) {
            case 'Dealer':
                this[NavigationMixin.Navigate]({
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": order.poId,
                        "objectApiName": "DealerPurchaseOrder__c",
                        "actionName": "view"
                    }
                });
                break;
        
            case 'DNS':
                //LMS 로 상위 컴포넌트 호출\
                this.openDNSPOModal(order.poSeq, 'DN_PurchaseOrderDetail');//DN_PurchaseOrderDetail
                break;
        }
        
    }
    //
    // 
    openDNSPOModal(dnsSeq, pageName, startDate, endDate) {
        let params = {
            'param':`partOrderNo=${dnsSeq}`,
            'modalName':pageName
        };

        if(startDate) {
            params.param += ',startDate='+startDate
        }

        if(endDate) {
            params.param += ',endDate='+endDate
        }

        this.messagePublish('CustomModal',
            params
        );
    }

    async openOrderStatusModal(event) {
        let rowIndex = event.currentTarget.getAttribute('accesskey');
        let order = this.dataList[rowIndex];

        switch (order.type) {
            case 'Dealer':
                const result = await OrderStatusModal.open({
                    orderId:order.poId,
                });
                break;
        
            case 'DNS':
                //LMS 로 상위 컴포넌트 호출\
                this.openDNSPOModal(order.poSeq, 'DN_DeliveryDateInquiryModal', order.orderDate, order.orderDate);
                break;
        }
        
    }
    

    _exceldata = [];
    excelDownload(_currentPage, _nextPage) {
        this.showSpinner();
        let searchParams = this._excelDownloadParams;
        let currentPage = (!_currentPage) ? 1 : _currentPage;
        let nextPage = (!_nextPage) ? 1 : _nextPage;
        // 페이징 처리 데이터
        let page = {
            itemsPerPage : this.itemsPerPage,
            currentPage : currentPage,
            pagesPerGroup : this.pagesPerGroup,
            orderByField : this.orderByField,
            orderBy : this.orderBy
        }

        getDataList({...searchParams, page, nextPage}).then( result => {
            let { status, recordListSet, page } = result;
            // console.log('recordListSet : '+ JSON.stringify(recordListSet));
            console.log('page : '+ JSON.stringify(page));
            if(status.code === 200) {
                //성공
                console.log('ExcelDownload 버튼 클릭 성공');
                this._exceldata = this._exceldata.concat(recordListSet);
                
                if(page.totalRecordSize <= this._exceldata.length) {
                    //ExcelDownload
                    // console.log(JSON.stringify(this._exceldata));
                    (async()=>{
                        try {
                            const excelDownloadResult = await this.generateExcel();
                            console.log(`excelDownloadResult: ${excelDownloadResult}`);
                        } catch (error) {
                            console.error('Error fetching data:', error);
                        }
                    })();
                    
                    this.stopSpinner(500);
                }else {
                    this.excelDownload(page.currentPage, page.currentPage+1);
                    
                }

            }

            if(status.code === 400) {
                this._exceldata = [];
                console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
                this.stopSpinner(500);
                this.showToast('', '에러가 발생하였습니다. 관리자에게 문의부탁드립니다.', 'Error');
            }
            
            if(status.code === 500) {
                this._exceldata = [];
                console.log(JSON.stringify(error), '관리자 한테 문의하세요.');
                this.stopSpinner(500);
                this.showToast('', '에러가 발생하였습니다. 관리자에게 문의부탁드립니다.', 'Error');
            }
            
        }).catch(error => {
            console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
        });
        
    }

    isExcelDataLoading = true;
    excelDataMap = new Map();
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

            // const promiseResult = await Promise.all(promises);    
            // const excelDownloadResult = await this.generateExcel();
            //                 console.log(`excelDownloadResult: ${excelDownloadResult}`);
        } catch (error) {
            console.error('ExcelDownloadParallel Error occurred:', error);
            this.isExcelDataLoading = false;
            this.blobExcel = undefined;
            this.excelDataMap = new Map();
        } finally {
            this.stopSpinner(500);
        }
        console.timeEnd("excelDownloadParallel"); 
    }

    isImmediateStop = false;
    async excelDownloadParallelRecursive (_currentPage, _nextPage, itemsPerPage = 200) {
        if(this.isImmediateStop) return Promise.reject('Immediate Stop');
        // this.showSpinner();

        let searchParams = this._excelDownloadParams;
        let currentPage = (!_currentPage) ? 1 : _currentPage;
        let nextPage = (!_nextPage) ? 1 : _nextPage;
        
        // 페이징 처리 데이터
        let page = {
            itemsPerPage : itemsPerPage,
            currentPage : currentPage,
            pagesPerGroup : this.pagesPerGroup,
            orderByField : this.orderByField,
            orderBy : this.orderBy
        }

        try {
            const result = await getDataList({...searchParams, page, nextPage}).then( result => {
                let { status, recordListSet, page, dealerOrderItemMap } = result;
                // console.log('recordListSet : '+ JSON.stringify(recordListSet));
                console.log('page : '+ JSON.stringify(page));
                if(status.code === 200) {
                    console.log(JSON.stringify(recordListSet),' ::: recordListSet');
                    // recordListSet.forEach(record => {
                    //     record.itemList.forEach(item => {
                    //         if(dealerOrderItemMap && dealerOrderItemMap[item.Id]) {
                                
                    //         }
                    //     })
                    // });
                    //성공
                    // this._exceldata = this._exceldata.concat(recordListSet);
                    this.excelDataMap.set(page.currentPage , recordListSet);
                }
    
                if(status.code === 400 || status.code === 500) {
                    this.excelDataMap = new Map();
                    const errorMsg = (status.code === 400) ? 'excelDownloadParallelRecursive getDataList error' : '관리자 한테 문의하세요.';
                    console.log(JSON.stringify(errorMsg), ' excelDownloadParallelRecursive getDataList error');
                    return Promise.reject('excelDownloadParallelRecursive getDataList Error');
                }
          
            }).catch(error => {
                console.log(JSON.stringify(error), ' excelDownloadParallelRecursive getDataList error');
                return Promise.reject('');
            });
        } catch (error) {
            // 네트워크 또는 API 호출 실패 처리
            console.log('excelDownloadParallelRecursive getDataList error', JSON.stringify(error));
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
    excelName = '_구매관리';
    async generateExcel() {
        console.time("generateExcel");
        try {
            console.log('generateExcel');

            let flattenDealerOrderData = (orders) => {
                const flattenedData = [];
              
                // 각 주문을 순차적으로 처리
                for (const order of orders) {
                  const { 
                    poSeq, 
                    customerName,       //구매처
                    customerOrerNumber,
                    orderDate,
                    statusLabel,
                    customerOrderSeq,
                    itemList
                  } = order;
                  
                  // 각 품목에 대해 주문 정보와 품목 정보 결합
                  for (const item of itemList) {
                    console.log('Dealer Item  : ', JSON.stringify(item));
                    flattenedData.push({
                        poSeq, 
                        customerName, 
                        customerOrerNumber,
                        orderDate,
                        itemSeq : item.itemSeq,
                        replacingPartName : item.replacingPartName,
                        replacingPartDetails : item.replacingPartDetails,
                        quantity : item.quantity,
                        unit : item.unit,
                        giQuantity : item.giQuantity,
                        pendingQuantity : item.pendingQuantity,
                        discountAmount : item.discountAmount,
                        giDate : item.giDate,
                        currencyCode : item.currencyCode,
                        customerOrderSeq,
                        customerOrderItemSeq: item.itemSeq,
                        statusLabel: statusLabel,
                    });
                  }
                }
              
                return flattenedData;
            }

            let flattenDNSOrderData = (orders) => {
                const flattenedData = [];
              
                // 각 주문을 순차적으로 처리
                for (const order of orders) {
                  const { 
                    poSeq, 
                    customerName,       //구매처
                    customerOrerNumber,
                    orderDate,
                    statusLabel,
                    itemList
                  } = order;
                  console.log(JSON.stringify(itemList), ' flattenDNSOrderData');
                  // 각 품목에 대해 주문 정보와 품목 정보 결합
                  for (const item of itemList) {
                    flattenedData.push({
                        poSeq, 
                        customerName, 
                        customerOrerNumber,
                        orderDate,
                        itemSeq : item.itemSeq,
                        replacingPartName : item.replacingPartName,
                        replacingPartDetails : item.replacingPartDetails,
                        quantity : item.quantity,
                        unit : item.unit,
                        confirmQuantity : item.confirmQuantity,
                        pendingQuantity : item.pendingQuantity,
                        giQuantity : item.giQuantity,
                        discountAmount : item.discountAmount,
                        currencyCode : item.currencyCode,
                        expectedSupplyDate: item.expectedSupplyDate,
                        revisedSupplyDate: item.revisedSupplyDate,
                        giDate : item.giDate,
                        departureSite : item.departureSite,
                        statusLabel: statusLabel,
                    });
                  }
                }
              
                return flattenedData;
            }
    
            
            const workbook = new ExcelJS.Workbook();
            // console.log(JSON.stringify(this.currentUserInfo));
            this.excelName = `${this.currentUserInfo.name}_구매관리`;
            const dmtWorksheet = workbook.addWorksheet('DMT');
            const dealerWorksheet = workbook.addWorksheet('DEALER');
    
            //header 
            //주문번호	항목	Delivery Schedule Line Number	고객주문번호	구매처	주문일	주문품번	품명	주문수량	단위	확정수량	대기수량	완료수량	구매금액	통화	예상공급일	변경공급 예정일	출고일	발송지점	상태
            //
            let dmtHeaderParams = [
                { key: 'poSeq', header:'주문번호', },
                { key: 'itemSeq', header:'항목' },
                // { key: 'dsLineNumber', header:'Delivery Schedule Line Number' },
                { key: 'customerOrerNumber', header:'고객주문번호', },
                { key: 'customerName', header:'구매처', },
                { key: 'orderDate', header:'주문일', },
                { key: 'replacingPartName', header:'주문품번' },
                { key: 'replacingPartDetails', header:'품명' },
                { key: 'quantity', header:'주문수량' },
                { key: 'unit', header:'단위' },
                { key: 'confirmQuantity', header:'확정수량' },
                { key: 'pendingQuantity', header:'대기수량' },
                { key: 'giQuantity', header:'완료수량' },
                { key: 'discountAmount', header:'구매금액', },
                { key: 'currencyCode', header:'통화', },
                { key: 'expectedSupplyDate', header:'예상공급일', },
                { key: 'revisedSupplyDate', header:'변경공급일', },
                { key: 'giDate', header:'출고일', },
                { key: 'departureSite', header:'발송지점', },
                { key: 'statusLabel', header:'상태', },
            ];
            
            dmtWorksheet.columns = dmtHeaderParams;
            dmtWorksheet.getColumn('orderDate').numFmt = 'yyyy-mm-dd'; // 날짜 포맷
            dmtWorksheet.getColumn('discountAmount').numFmt = '#,##0'; 
            dmtWorksheet.getColumn('giDate').numFmt = 'yyyy-mm-dd';

            dmtWorksheet.getRow(1).eachCell((cell, colNumber) => {
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
                orderList = orderList.concat(excelFormatData);
                // UI가 멈추지 않도록 배치 처리 후 requestAnimationFrame을 사용하여 비동기 처리
                await new Promise(resolve => {
                    requestAnimationFrame(resolve);
                });
            }

            let dnsOrderList = orderList.filter(order=> order.type === 'DNS');
            
            if(dnsOrderList.length > 0) {
                console.log(JSON.stringify(dnsOrderList),' ::: dnsOrderList');
                const flattenedOrderItem = flattenDNSOrderData(dnsOrderList);
                dmtWorksheet.addRows(flattenedOrderItem);
    
                // dmtWorksheet.columns.forEach((column) => {
                //     dmtWorksheet.getColumn(column.key).eachCell((cell) => {
                //       // 테두리 설정
                //       cell.border = {
                //         top: { style: 'thin', color: { argb: 'FF000000' } },
                //         left: { style: 'thin', color: { argb: 'FF000000' } },
                //         bottom: { style: 'thin', color: { argb: 'FF000000' } },
                //         right: { style: 'thin', color: { argb: 'FF000000' } }
                //       };
                //     });
                // });
            }

            //주문번호	항목	고객주문번호	구매처	주문일	주문품번	품명	주문수량	단위	출고수량	미결수량	결품수량	구매금액	통화	Cust.Order No.	Cust Order Item	상태

            let dealerHeaderParams = [
                { key: 'poSeq', header:'주문번호', },
                { key: 'itemSeq', header:'항목' },
                { key: 'customerOrerNumber', header:'고객주문번호', },
                { key: 'customerName', header:'구매처', },
                { key: 'orderDate', header:'주문일', },
                { key: 'replacingPartName', header:'주문품번' },
                { key: 'replacingPartDetails', header:'품명' },
                { key: 'quantity', header:'주문수량' },
                { key: 'unit', header:'단위' },
                { key: 'giQuantity', header:'출고수량' },
                { key: 'pendingQuantity', header:'미결수량' },
                { key: 'availableQuantity', header:'결품수량' }, //
                { key: 'discountAmount', header:'구매금액', },
                { key: 'currencyCode', header:'통화', },
                { key: 'customerOrderSeq', header:'Cust.Order No.', },
                { key: 'customerOrderItemSeq', header:'Cust Order Item', },
                { key: 'giDate', header:'출고일', },
                { key: 'departureSite', header:'발송지점', },
                { key: 'statusLabel', header:'상태', },
            ];
            
            dealerWorksheet.columns = dealerHeaderParams;
            dealerWorksheet.getColumn('orderDate').numFmt = 'yyyy-mm-dd'; // 날짜 포맷
            dealerWorksheet.getColumn('discountAmount').numFmt = '#,##0'; 
            dealerWorksheet.getColumn('giDate').numFmt = 'yyyy-mm-dd';

            dealerWorksheet.getRow(1).eachCell((cell, colNumber) => {
                cell.fill = {
                    type: 'pattern',
                    pattern: 'solid',
                    fgColor: { argb: 'D3D3D3' } 
                };
            });

            let dealerOrderList = orderList.filter(order=> order.type === 'Dealer');
            if(dealerOrderList.length > 0) {
                const flattenedOrderItem = flattenDealerOrderData(dealerOrderList);
                dealerWorksheet.addRows(flattenedOrderItem);
    
                // dealerWorksheet.columns.forEach((column) => {
                //     dealerWorksheet.getColumn(column.key).eachCell((cell) => {
                //       // 테두리 설정
                //       cell.border = {
                //         top: { style: 'thin', color: { argb: 'FF000000' } },
                //         left: { style: 'thin', color: { argb: 'FF000000' } },
                //         bottom: { style: 'thin', color: { argb: 'FF000000' } },
                //         right: { style: 'thin', color: { argb: 'FF000000' } }
                //       };
                //     });
                // });
            }
    
            // worksheet1.getCell(`C${flattenedOrderItem.length+2}`).value = '합계';
            // const totalOrderCountCell = worksheet1.getCell(`D${flattenedOrderItem.length+2}`);
            // totalOrderCountCell.value = this._exceldata.length;
            // totalOrderCountCell.numFmt = null;
            // const sumCell = worksheet1.getCell(`E${flattenedOrderItem.length+2}`);
            // sumCell.value = { formula: `sum(R2:R${flattenedOrderItem.length+1})`, result: totalItemAmountResult}; // result >> 동적으로 값을 계산하지 않으므로 편집하기를 누르지 않으면 계산이 안됨.

            const buffer = await workbook.xlsx.writeBuffer();
            this.blobExcel = new Blob([buffer]);
    
            // workbook.xlsx.writeBuffer().then(function(buffer) {
            //     var blob        = new Blob([buffer], { type: 'application/octet-stream' });
            //     var link        = document.createElement('a');
            //     link.href       = URL.createObjectURL(blob);
            //     link.download   = excelName + '.xlsx';
            //     document.body.appendChild(link);
            //     link.click();
            //     document.body.removeChild(link);
            // });
           
        } catch (error) {
            console.error(error);
        }
        
        console.timeEnd("generateExcel");
        return true;
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

}