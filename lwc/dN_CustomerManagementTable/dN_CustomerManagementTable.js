import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';
//static resource
import { loadScript, loadStyle }     from 'lightning/platformResourceLoader';
import EXCEL_JS from '@salesforce/resourceUrl/ExcelJS'; 
import FileSaver from '@salesforce/resourceUrl/FileSaver'; 
//Apex 
import getDataList from '@salesforce/apex/DN_DealerPortalDisplayController.getDataList';
import getDataListQuery from '@salesforce/apex/DN_DealerPortalDisplayController.getDataListQuery';
import isCommunity from '@salesforce/apex/DN_DealerPortalDisplayController.isCommunity';

export default class DN_CustomerManagementTable extends NavigationMixin(LightningElement)  {
    excelJs = EXCEL_JS + '/unpkg/exceljs.min.js';
    fileSaver = FileSaver + '/FileSaver.js';
    /**
     * LMC
     */
    @wire(MessageContext)
    messageContext;
    subscription = null;
    // spinner
    isLoading = false;
    recordList =[];
    // 공통 컴포넌트에서 페이지 관련 필드 상속받아옴
    @api itemsPerPage;
    @api currentPage;
    @api pagesPerGroup;
    @api orderByField;
    @api orderBy;
    @api currentUserInfo;
    totalpage =0;
    nextPage =1;
    isExcelBtn = false;
    isExcelDataload = false;
    @api uuid;
    dataList =[];
    exceldata = [];
    strQuery ='';
    where = [];
    agencyId = '';
    isCommunity = false;
    excelDataMap = new Map();
    sessionKey = 0;
    excelSettingData;


    connectedCallback() {
        
        Promise.all([
            loadScript(this, EXCEL_JS + '/unpkg/exceljs.min.js'),
            //loadScript(this, this.excelJs),
            loadScript(this, this.fileSaver)
        ])
        .then(() => {  
            isCommunity({
            }).then( result => {
                this.isCommunity = result;
            }).catch(error => {
                //console.log(JSON.stringify(error), '  get DataQuery  error');
            });
            
        })
        .catch( error => {
            //console.log(error,' < ---error')
        });
        if(!this.subscription) {
            this.setSubscriptionLMC();        
        }   
    }
    disconnectedCallback() {
        //console.log(' 디스커넥티드 콜백 실행되는지 확인');
        //localStorage.removeItem('session');
        this.sessionKey = '';
    }

    // test
    testUrl() {
        //console.log('testURL');
        // this[NavigationMixin.Navigate](
        //     {
        //          type: 'standard__recordPage',
        //          attributes: {
        //              recordId: '069F7000002HNF2IAO', // pass the record id here.
        //              actionName: 'edit',
        //          },
        //      });
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: '069F7000002HNF2IAO',
        //         objectApiName: 'ContentDocument',
        //         actionName: 'view' // 파일 미리보기 화면으로 이동
        //     }
        // });
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: '069F7000002HNF2IAO'
            }
        });
            //  this[NavigationMixin.Navigate]({
            //     type: "comm__namedPage",
            //     attributes: {
            //       pageName: "filePreview",
            //     },
            //     state: {
                  
            //       selectedRecordId: "069F7000002HNF2IAO",
            //     },
            //   });
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
                // 이벤트를 발생시키는 컴포넌트로 1차 분기처리
                //console.log(JSON.stringify(msg), ' table 11111');
                switch (msg.cmpName) {
                    case 'dN_DealerPortalFilter':
                        if(msg.type =='filterChange') {
                            this.setFilterChange(msg.message);
                            //console.log(JSON.stringify(msg.message), ' < ==msg.message');
                        } 
                        if(msg.type =='defaultFilter') {
                            //console.log(JSON.stringify(msg), '    :::::::defaultFilter');
                            this.setFilterChange(msg.message); 
                        }
                        break;
                    case 'dN_DealerPortalButton':
                        if(msg.type =='Seach') {
                            this.isLoading = true;
                            this.sessionKey =crypto.randomUUID();
                            this.getDataQuery('Seach', false, this.nextPage)
                                .then(async () => {
                                    this.exceldata = [];
                                    this.excelDataMap = new Map();
                                    this.isExcelDataload = true;
                                    let batchSize = 15; // 한 번에 실행할 요청 개수
                                    let promises = [];
                                    let currentKey = this.sessionKey;
                                    for (let i = 0; i < this.totalpage; i++) {
                                        promises.push(this.getDataQuery('PageChnage', true, i+1));
                                        // 프로미스 실행 시 실행 당시 키값이랑 새로운 요청이 들어오면 변경된 키값이랑 비교해 reject하거나 정상적인 실행
                                        if(currentKey != this.sessionKey) {
                                            //console.log('sessionKey가 다름');
                                            return Promise.reject();
                                        } 
                                        // batchSize만큼 요청을 모아서 실행
                                        if (promises.length === batchSize || i === this.totalpage - 1) {
                                            let results = await Promise.allSettled(promises);  // 현재 배치 실행 후 대기 //requestAnimationFrame,requestIdleCallback
                                            requestIdleCallback(async () => {
                                                const results = await Promise.allSettled(promises);
                                                //console.log(results);
                                            });
                                            promises = [];  // 초기화 후 다음 배치 준비
                                        }
                                        // if(localStorage.getItem('session') != this.sessionKey) {
                                        //     console.log('sessionKey가 다름');
                                        //     return Promise.reject();
                                        // } 
                                    }
                                })
                                .then( async ()=>{
                                    // 모든 요청이 완료된 후 실행
                                    for(let i = 0; i < this.totalpage; i++) {
                                        // if(sessionStorage.getItem('sessionKey') == this.sessionKey) {
                                            this.exceldata.push(...this.excelDataMap.get(i+1)); //this.sessionKey+'_'+nextPages
                                        //}
                                    }
                                    //this.exceldata = this.exceldata.slice(0, 2000);
                                    // 속도 고려해 Excel형태로 먼저 가공처리
                                    await this.setExcelData();
                                    this.isExcelDataload = false;
                                    if (this.isExcelBtn) {
                                        this.handleExcelDownload();
                                    }
                                })
                                .catch(error => {
                                    //console.log(JSON.stringify(error), ':: 요청 실패');
                                });
                        }
                        if(msg.type =='ExcelDownload'){
                            this.isLoading = true;
                            this.isExcelBtn = true;
                            
                            if(!this.isExcelDataload) {
                                this.handleExcelDownload();
                            }
                        }
                        if(msg.type =='ButtonPickList'){
                            //console.log(' ButtonPickList ::', JSON.stringify(msg.message));
                            this.setFilterChange(msg.message);
                        }
                        break;
                        //page Change
                    case 'dN_DealerPortalQueryPage':
                        //console.log(JSON.stringify(msg), ' msg');
                        this.nextPage = msg.message.nextpage;
                        this.currentPage = msg.message.currentPage;
                        this.isLoading = true;
                        this.getDataQuery('PageChnage', false,this.nextPage);
                        break;    

                    default:
                        break;
                }
            }
        });
    }

    // 페이징 처리 데이터
    getDataQuery(type, isExcelData, nextPages) {
        return new Promise((resolve, reject) => {
            this.setQuery();
            this.currentPage = type=='Seach'? 1 : this.currentPage;
            this.nextPage = type=='Seach'? 1 : this.nextPage;
            if(isExcelData) {
                this.nextPage = nextPages;
            }
            let itemPage = isExcelData? 200 :this.itemsPerPage;
            //console.log(this.strQuery, ' ::: this.strQuery');
            getDataListQuery({
                page : {
                    strQuery : this.strQuery,
                    recordList : this.recordList,
                    itemsPerPage : itemPage,
                    currentPage : this.currentPage,
                    pagesPerGroup : this.pagesPerGroup,
                    orderByField : this.orderByField,
                    orderBy : this.orderBy,
                },
                nextPage : this.nextPage,
                isExcelDataLoad : isExcelData,
                customerId : this.agencyId
            }).then( result => {
                if(isExcelData) {
                    //this.exceldata.push(...result.recordList);
                    this.excelDataMap.set(nextPages, result.recordList);
                    // resolve({ 
                    //     'pageNumber' : nextPages,
                    //     'recordList' : result.recordList
                    // });
                } else {
                    let mas = {
                        'currentPage' : result.currentPage,
                        'itemsPerPage' : result.itemsPerPage,
                        'pagesPerGroup' : result.pagesPerGroup,
                        'currentRecordSize' : result.recordList.length,
                        'totalRecordSize' : result.totalRecordSize,
                        'startIdx' : result.startIdx,
                        'endIdx' : result.endIdx,
                        'totalPage' : Math.ceil(result.totalRecordSize / result.itemsPerPage),
                        'eventType' : type
                    };
                    this.totalpage = Math.ceil(result.totalRecordSize / result.itemsPerPage);
                    this.messagePublish('dataListSearch',mas);
                    this.dataList = result.recordList;
                    if(this.dataList.length ==0) {
                        this.showToast('No data','조회된 데이터가 없습니다','error');
                    } else {
                        this.showToast('검색완료','검색이 완료되었습니다.','success');
                    }
                    this.isLoading = false;
                }
                resolve();
            }).catch(error => {
                reject('리젝으로 떨구기', this.excelDataMap.size);
                //console.log(JSON.stringify(error), '  get DataQuery  error');
            });
        });    
    }

    // 엑셀 
    async handleExcelDownload() {    
        if (this.dataList.length === 0) {
            this.showToast('No data', '조회된 데이터가 없습니다', 'error');
            this.isLoading = false;
            return;
        } 

        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('고객관리 목록');

        const columns = [
            { header: '고객코드', key: 'CustomerCode__c', width: 15 },
            { header: '고객사명', key: 'Name', width: 25 },
            { header: '주소', key: 'FM_Address__c', width: 30 },
            { header: '대표자', key: 'Representative__c', width: 15 },
            { header: '대표번호', key: 'Phone__c', width: 20 },
            { header: '부품담당자', key: 'FM_PartsManagerName__c', width: 20 },
            { header: '담당자 핸드폰', key: 'FM_PartsManagerPhone__c', width: 20 },
            { header: '생성일자', key: 'FM_CreatedDate__c', width: 15 },
            { header: '활성화', key: 'FM_Active__c', width: 10 }
        ];

        // 🔹 엑셀 헤더 설정 (스타일 포함)
        worksheet.columns = columns;
        worksheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
        worksheet.getRow(1).fill = {
            type: 'pattern',
            pattern: 'solid',
            fgColor: { argb: 'FF4F81BD' } // 파란색 배경
        };
        worksheet.getRow(1).alignment = { horizontal: 'center' };

        // 🔹 데이터를 배열로 변환 후 `addRows()`로 한 번에 추가
        const dataRows = this.exceldata.map(ele => ({
            CustomerCode__c: ele.CustomerCode__c,
            Name: ele.Name,
            FM_Address__c: ele.FM_Address__c,
            Representative__c: ele.Representative__c,
            Phone__c: ele.Phone__c,
            FM_PartsManagerName__c: ele.FM_PartsManagerName__c,
            FM_PartsManagerPhone__c: ele.FM_PartsManagerPhone__c,
            FM_CreatedDate__c: ele.FM_CreatedDate__c,
            FM_Active__c: ele.FM_Active__c
        }));
        worksheet.addRows(dataRows);

        // // 🔹 파일 생성 (await 적용)
        // const buffer = await workbook.xlsx.writeBuffer();
        // const blob = new Blob([buffer], { type: 'application/octet-stream' });

        saveAs(this.excelSettingData, '고객관리.xlsx');
        this.isLoading = false;    
        this.isExcelBtn = false;
    }

    async setExcelData() {
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('고객관리 목록');

        const columns = [
            { header: '고객코드', key: 'CustomerCode__c', width: 15 },
            { header: '고객사명', key: 'Name', width: 25 },
            { header: '주소', key: 'FM_Address__c', width: 30 },
            { header: '대표자', key: 'Representative__c', width: 15 },
            { header: '대표번호', key: 'Phone__c', width: 20 },
            { header: '부품담당자', key: 'FM_PartsManagerName__c', width: 20 },
            { header: '담당자 핸드폰', key: 'FM_PartsManagerPhone__c', width: 20 },
            { header: '생성일자', key: 'FM_CreatedDate__c', width: 15 },
            { header: '활성화', key: 'FM_Active__c', width: 10 }
        ];

        // 🔹 엑셀 헤더 설정 (스타일 포함)
        worksheet.columns = columns;
        worksheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
        worksheet.getRow(1).fill = {
            type: 'pattern',
            pattern: 'solid',
            fgColor: { argb: 'FF4F81BD' } // 파란색 배경
        };
        worksheet.getRow(1).alignment = { horizontal: 'center' };

        // 🔹 데이터를 배열로 변환 후 `addRows()`로 한 번에 추가
        const dataRows = this.exceldata.map(ele => ({
            CustomerCode__c: ele.CustomerCode__c,
            Name: ele.Name,
            FM_Address__c: ele.FM_Address__c,
            Representative__c: ele.Representative__c,
            Phone__c: ele.Phone__c,
            FM_PartsManagerName__c: ele.FM_PartsManagerName__c,
            FM_PartsManagerPhone__c: ele.FM_PartsManagerPhone__c,
            FM_CreatedDate__c: ele.FM_CreatedDate__c,
            FM_Active__c: ele.FM_Active__c
        }));
        worksheet.addRows(dataRows);

        // 🔹 파일 생성 (await 적용)
        const buffer = await workbook.xlsx.writeBuffer();
        this.excelSettingData = new Blob([buffer], { type: 'application/octet-stream' });
    }


    // toast메세지
    showToast(title,message,variant) { //success, warning, 및 error.
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    // 필터 체인지 설정
    setFilterChange(message) {
        //console.log(JSON.stringify(message),' ::setFilterChange');
        const isCheck = this.where.some(item => item.field === message.field);
        // console.log(isCheck, ' <===isCheck');
        // console.log(message.value.trim().length, ' < ==message.value.trim().length');
        if(isCheck) {
            if(message.value.trim().length > 0) {
                this.where.forEach(element => {
                    if(element.field == message.field) {
                        element.value = message.value;
                    }
                });
            } else {
                // 해당필터에 값이 없는 경우 제거
                this.where.forEach(element => {
                    //console.log(element.field,' <element.field');
                    //console.log(message.field,' <=message.field');
                    if(element.field == message.field) {
                        delete element.field;
                        delete element.value;
                        delete element.fieldType;
                    }
                });
                this.where = this.where.filter(item => Object.keys(item).length > 0);
            }
        } else {
            this.where.push(
                {
                    'field' : message.field,
                    'value' : message.value,
                    'fieldType' : message.fieldType
                }
            );
        }
        //console.log(JSON.stringify(this.where),' < ===this.where'); 
    }
    // handleDetal
    handleDetail(event) {
        //console.log(event.target.dataset.id,' < ===event.target.dataset.id');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: `${event.target.dataset.id}`,
                actionName: 'view',
            },
        })
    }

    // 쿼리 재설정
    setQuery() {
        this.strQuery ='';
        this.strQuery += 'select  Id,CRMCustomerCode__c, CustomerCode__c,Name,FM_Address__c,Representative__c,Phone__c,PartManagerName__c,IsActive__c,FM_Active__c';
        this.strQuery += `, FM_PartsManagerPhone__c,FM_CreatedDate__c,FM_PartsManagerName__c from DealerCustomer__c where Id !=null `; //limit 50000
        this.strQuery += ` AND (FM_DealerCode__c ='${this.currentUserInfo.customerCode}' OR IsDealer__c = true) AND SourceAccount__r.CustomerCode__c !='${this.currentUserInfo.customerCode}'`;
        if(this.where.length > 0) {
            this.where.forEach(element => {
                switch (element.field) {
                    case 'CustomerCode__c':
                        this.strQuery += ` AND CustomerCode__c LIKE '%${element.value}%'`;
                        break;
                    case 'Name':
                        this.strQuery += ` AND Name LIKE '%${element.value}%'`;
                        break;
                    case 'FM_CreatedDate__cStart':
                        this.strQuery += ` AND FM_CreatedDateTime__c >=${element.value}T00:00:00.000+09:00`;
                        break;
                    case 'FM_CreatedDate__cEnd':
                        this.strQuery += ` AND FM_CreatedDateTime__c <=${element.value}T23:59:59.000+09:00`;
                        break;    
                    case 'IsActive__c':
                        if(element.value !='all') { //20250218 all 추가 
                            this.strQuery += ` AND IsActive__c =${element.value}`;
                        }
                        break;
                    case 'Representative__c':
                        this.strQuery += ` AND Representative__c LIKE '%${element.value}%'`;
                        break;
                    case 'Phone__c':
                        this.strQuery += ` AND Phone__c LIKE '%${element.value}%'`;
                        break;
                    case 'CustomerType':
                        if(element.value !='all') {
                            if(element.value =='agency') {
                                this.strQuery += ` AND SourceAccount__c !=null`;
                            } else {
                                this.strQuery += ` AND Dealer__c !=null`;
                            }
                        }
                        break;
                    case 'CustomerName__c':
                        //console.log(JSON.stringify(element),' ::: element');
                        this.agencyId = element.value;
                        //this.strQuery += ` AND Dealer__c ='${element.value}'`;
                        break;                        
                }
            });
        }
        //console.log(this.strQuery, ' < ==set Query ==> this.strQuery'); 
    }

}