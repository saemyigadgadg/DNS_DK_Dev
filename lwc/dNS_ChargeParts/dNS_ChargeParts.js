/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-15
 * @last modified by  : Hyerin Ro
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-11-28   yeongdeok.seo@sbtglobal.com   Initial Version
**/
import { LightningElement, api, wire, track } from 'lwc';
import GetChargingPartList from '@salesforce/apex/DN_WorkOrderChargingPartController.getChargingPartList';
import GetProductDetails from '@salesforce/apex/DN_WorkOrderChargingPartController.getProductDetails';
import GetProductByCode from '@salesforce/apex/DN_WorkOrderChargingPartController.getProductByCode';
import checkProduct from '@salesforce/apex/DN_WorkOrderChargingPartController.checkProduct';
import DeleteProduct from '@salesforce/apex/DN_WorkOrderChargingPartController.deleteRequestProduct';
import getServiceTerritories from '@salesforce/apex/DN_WorkOrderChargingPartController.getServiceTerritories';
import getGPESProducts from '@salesforce/apex/DN_WorkOrderChargingPartController.getGPESProducts';
import getAssetName from '@salesforce/apex/DN_WorkOrderChargingPartController.getAssetName';
import getWorkOrder from '@salesforce/apex/DN_WorkOrderChargingPartController.getWorkOrder';
import searchSpindle from '@salesforce/apex/DN_WorkOrderChargingPartController.searchSpindle';
import searchDealerStock from '@salesforce/apex/DN_WorkOrderChargingPartController.searchDealerStock';
import searchMultipleProductStock from '@salesforce/apex/DN_WorkOrderChargingPartController.searchMultipleProductStock';
import getProductId from '@salesforce/apex/DN_WorkOrderChargingPartController.getProductId';
import getLastSequence from '@salesforce/apex/DN_WorkOrderChargingPartController.getLastSequence';

import upsertPRData from '@salesforce/apex/DN_WorkOrderChargingPartController.upsertPRData';



import { label } from 'c/commonUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import JsBarcode from '@salesforce/resourceUrl/JsBarcode';
import getHistoryData from '@salesforce/apex/DN_GIHistorySearchController.getHistoryData';

const FIELDS = ["Product2.Name"];

const columns = [
    { label: '진행상태', fieldName: 'ProgressStatus', type: 'text', editable: true, sortable: true, initialWidth: 100 },
    { label: '순번', fieldName: 'PartNo', type: 'text', editable: false, sortable: true, initialWidth: 80 },
    { 
        label: '품번', 
        fieldName: 'ProductUrl',
        type: 'url',
        typeAttributes: { 
            label: { fieldName: 'ProductCode' },
            target: '_blank'
        },
        sortable: true, 
        initialWidth: 120 
    },
    { label: '품명', fieldName: 'ProductName', type: 'text', editable: false, sortable: true, initialWidth: 200 },
    { 
        label: '수량', 
        fieldName: 'PartAmount', 
        type: 'number', 
        editable: true, 
        sortable: true, 
        initialWidth: 80,
        typeAttributes: { minimumIntegerDigits: 1 }
    },
    { 
        label: '탁송구분', 
        fieldName: 'TransportDivision', 
        type: 'text', 
        editable: true, 
        sortable: true, 
        initialWidth: 150,
        wrapText: true
    },
    { 
        label: '배송처', 
        fieldName: 'ShipTo', 
        type: 'text', 
        editable: true, 
        sortable: true, 
        initialWidth: 150,
        wrapText: true
    },
    { 
        label: '대리점명', 
        fieldName: 'WorkCenterName', 
        type: 'text', 
        editable: false, 
        sortable: true, 
        initialWidth: 150,
        wrapText: true
    },
    { 
        label: '무게', 
        fieldName: 'WeightWithUnit', 
        type: 'text', 
        editable: false, 
        sortable: true, 
        initialWidth: 100 
    },
    { label: '스핀들구분', fieldName: 'SpindleType', type: 'text', editable: false, sortable: true, initialWidth: 100 }
];

const progressStatusOptions = [
    { label: '신청', value: 'New' },
    { label: '승인', value: 'Approved' },
    { label: '반출', value: 'CarryOut' },
    { label: '배송 중', value: 'InDelivery' },
    { label: '미반출', value: 'NotShipped' },
];

const statusMapping = {
    'New': '신청',
    'Approved': '승인',
    'CarryOut': '반출',
    'InDelivery': '배송 중',
    'NotShipped': '미반출'
};

const transportDivisionOptions = [
    { label: '[본사]화물영업소', value: '20' },
    { label: '[본사]택배직송', value: '10' },
    { label: '[본사]퀵서비스', value: '90' },
    { label: '[본사]방문수령', value: '99' },
    { label: '[대리점]화물영업소', value: '2' },
    { label: '[대리점]택배직송', value: '1' },
    { label: '[대리점]퀵서비스', value: '3' },
    { label: '[대리점]방문수령', value: '4' },
];

export default class dNS_ChargeParts extends LightningElement {
    cLabel = label;

    @api recordId;
    @api objectApiName;
    @api productId;
    @track lastSeq = '0010';
    @track resultData = [];
    @track beforeData = [];
    @track curTableRow = 0;
    @track _orderType;
    @track _status;
    @track isAddLineDisabled = false;
    @track isSaveLineDisabled = false;
    @track isSpindleDisabled = true;
    @track isButtonGroupDisabled = false;
    @track isButtonDisabled = false;
    @track selectPartNo = '';
    
    @track hasSpindleError = false;
    @track spindleErrorMessage = '';
    @track spindleShiptoId = '';

    @track spindleColumns = [
        { label: '구분', fieldName: 'ZTYPE', type: 'text', initialWidth: 120 },
        { label: '품번', fieldName: 'MATNR', type: 'text', initialWidth: 200 },
        { label: '품명', fieldName: 'MAKTX', type: 'text', initialWidth: 200 },
        { label: '판매가', fieldName: 'NETWR', type: 'text', initialWidth: 200 },
        { label: '통화키', fieldName: 'WAERS', type: 'text', initialWidth: 120 },
        { label: '가용재고', fieldName: 'MENGE', type: 'text', initialWidth: 200 },
        { label: '수량단위', fieldName: 'MEINS', type: 'text', initialWidth: 120 },
        { label: '예상납기(일)', fieldName: 'PLIFZ', type: 'text', initialWidth: 200 },
        { type: 'action', typeAttributes: { rowActions: [{ label: '선택' }] }}
    ];

    // @wire(getRecord, { recordId: "$productId", fields: FIELDS })
    // productName;
  
    isNewLine = false;
    columnsData = columns;
    progressStatusOptions = progressStatusOptions;
    transportDivisionOptions = transportDivisionOptions;
    
    @track isSpinner = false;
    @track isStockModalSpinner = false; //부품별 재고 현황 조회 모달 스피너
    @track isServiceModalSpinner = false; //부품재고 전체 대리점 조회 모달 스피너
    @track isSpindleModalSpinner = false; //스핀들 조회 모달 스피너
    @track isPasting = false;//엑셀 붙여넣기 
    

    @track isGPESModal = false;
    @track isStockModal = false;
    @track isServiceModal = false;
    @track isSpindleModal = false;
    // @track stockResult = [];
    @track serviceResult = [];
    @track spindleResult = [];
    partId;
    serviceIndex;
    serviceProductId;
    serviceProductCode;
    serviceQuantity;

    // GPES
    handleMessage;
    assetGijong;
    assetHogi;
    apexPageURL;
    
    @track serviceTerritoryOptions = [];

    @track stockColumns = [
        { label: '대리점코드', fieldName: 'DEALER_CD', type: 'text' },
        { label: '대리점명', fieldName: 'NAME1', type: 'text' },
        { label: '단위', fieldName: 'UNIT', type: 'text'},
        { label: '현재고', fieldName: 'CURRENT_QTY', type: 'number', cellAttributes: { alignment: 'left' } },
        { label: '가용재고', fieldName: 'AVAIL_QTY', type: 'number', cellAttributes: { alignment: 'left' } },
        { label: '주문예약재고', fieldName: 'ORDER_QTY', type: 'number', cellAttributes: { alignment: 'left' } },
        { type: 'button', typeAttributes: {label: '대리점 선택'} }
    ];
    @track stockColumnsChange =[];

    @track stockResult = {};
    @track stockTableData = [];

    @track serviceColumns = [
        { label: '대리점코드', fieldName: 'DEALER_CD', type: 'text' },
        { label: '대리점명', fieldName: 'NAME1', type: 'text' },
        { type: 'action', typeAttributes: { rowActions: [{ label: '대리점 선택' }] }}
    ];
    

    // ServiceTerritory 데이터를 가져오는 wire 메소드
    @wire(getServiceTerritories)
    wiredServiceTerritories({ error, data }) {
        if (data) {
            const result = data.find(item => item.Name === "스핀들수리실");
            this.spindleShiptoId = result ? result.Id : '';
            
            this.serviceTerritoryOptions = data.map(territory => ({
                label: territory.Name,
                value: territory.Id,
                workCenterName: territory.Name
            }));
            this.serviceTerritoryOptions.unshift({
                label: '고객직송(신청)',
                value: '고객직송',
                workCenterName: '고객직송'
            });           
        } else if (error) {
            console.error('Error fetching service territories:', error);
        }
    }

    handleWorkCenterChange(event) {
        const selectedId = event.target.value;
        const rowId = event.target.dataset.id;
        
        // 대리점이 선택되지 않은 경우 필드 초기화
        if (selectedValue=='') {
            const rowIndex = this.resultData.findIndex(row => row.PartAmountNo === rowId);
            if (rowIndex !== -1) {
                const updatedRow = { ...this.resultData[rowIndex] };
                updatedRow.WorkCenterId = null;
                updatedRow.WorkCenterName = null;
                
                this.resultData[rowIndex] = updatedRow;
                this.resultData = [...this.resultData];
            }
            return;
        }
    }

    openWorkCenterModal(event) {
        this.selectedRowId = event.target.dataset.id;
        this.isWorkCenterModal = true;
        this.workCenterOptions = this.serviceTerritoryOptions.map(opt => ({
            id: opt.value,
            name: opt.label,
            address: opt.address
        }));
    }

    closeWorkCenterModal() {
        this.isWorkCenterModal = false;
    }

    selectWorkCenter(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedCenter = this.workCenterOptions.find(wc => wc.id === selectedId);
        
        if (selectedCenter && this.selectedRowId) {
            const rowIndex = this.resultData.findIndex(row => row.PartAmountNo === this.selectedRowId);
            if (rowIndex !== -1) {
                this.resultData = [...this.resultData];
                this.resultData[rowIndex] = {
                    ...this.resultData[rowIndex],
                    WorkCenterName: selectedCenter.name,
                    WorkCenterId: selectedCenter.id
                };
            }
        }
        this.closeWorkCenterModal();
    }

    refreshList(){
        console.log('호출하기전에 한번');
        GetChargingPartList({workOrderId: this.recordId})
        .then(result => {
            console.log('GetChargingPartList ::: ', result);
            if (result.length === 0) {
                // this.addRowClick(); // 20250107 첫 화면 빈 줄 제외 요청
            } else {
                if (result.some(item => item.ProductType != null && this.addLineDisabledMessage=='')) { //스핀들 하나라도 있으면 버튼 disabled
                    this.isSpindleDisabled = true;
                    this.isButtonGroupDisabled = false;
                    this.isAddLineDisabled = false;
                } else {
                    if(this.OrderType__c == '202' && this.addLineDisabledMessage=='') {
                        this.isSpindleDisabled = false;
                        this.isButtonGroupDisabled = true;
                        this.isAddLineDisabled = true;
                    }
                }

                this.resultData = result.map((item, index) => {
                    const isApproved = item.ProgressStatus === 'Approved';

                    return {
                        ...item,
                        PartAmountNo: 'PartAmount' + (index + 1),
                        PartNo: item.PartNo,
                        ProductCode: item.ProductCode,
                        ProductUrl: item.ProductId ? '/lightning/r/Product2/' + item.ProductId + '/view?navRef=1' : '',
                        WeightWithUnit: item.Weight && item.UnitCode ? `${item.Weight} ${item.UnitCode}` : item.Weight || '',
                        EditMode: !isApproved,
                        isApproved: isApproved,
                        isSpinShip: isApproved?isApproved:(this.OrderType__c == '215' || this.OrderType__c=='214') ? true:false,
                        // isSpinShip: false,
                        ProgressStatus: statusMapping[item.ProgressStatus] || item.ProgressStatus,
                        ProductRequestId: item.ProductRequestRecordId
                    };
                });
                console.log('this.resultData', this.resultData);
                
            }
            this.curTableRow = this.resultData.length;
            this.isSpinner = false;
        })
        .catch(error => {
            console.log('Error ::: ', error);
            this.isSpinner = false;
        });
    }
    
    connectedCallback() {
        if(this.recordId){
            this.isSpinner = true;
            this.isButtonDisabled = true;
            this.isButtonGroupDisabled = true;
            this.isSpindleDisabled = true;
            this.isAddLineDisabled = true;
            this.isSaveLineDisabled = true;
            
            this.getWorkOrderType();
            this.refreshList();

            getAssetName({
                recordId : this.recordId
            }).then(result => {
                this.assetGijong = '';
                this.assetHogi = '';
                console.log('AssetName ::: ', result);
                this.assetGijong = result.split('-')[0];
                this.assetHogi = result.split('-')[1];
                console.log('Gijong ::: ' , this.assetGijong);
                console.log('Hogi ::: ' , this.assetHogi);
                var type = 'reqParts';
                this.apexPageURL = '/apex/IF_GPES_T?gijong=' + this.assetGijong + '&hogi=' + this.assetHogi + '&type=' + type;
                console.log('url ::: ' , this.apexPageURL);
                // this.apexPageURL = '/apex/IF_GPES_T?&type=' + type + '&part_no=R18181'; // pi
                // this.apexPageURL = '/apex/IF_GPES_T?gijong=' + this.assetGijong + '&type=' + type; //pc
            }).catch(error => {
                console.log('Error ::: ', error);
            });

            this.checkLastSeq();
        }
    }

    renderedCallback(){
        if (this.recordId && !this.resultDataLoaded) {
            this.resultDataLoaded = true; // 데이터를 한 번만 로드
        }

        this.adjustSldsStyles();
    }

    // 메시지를 처리하는 메서드
    chargingPartHandleMessage(event) {
        // 메시지가 JSON인지 확인
        try {
            console.log('이벤트 부품리스트 ::: ', event);
            const data = event.data;
            console.log('이벤트 부품리스트 ::: ', data);
            console.log('이벤트 부품리스트 JSON ::: ', JSON.parse(data));
            
            getGPESProducts({
                gpesPartsList : JSON.parse(data)
            }).then(result => {
                console.log('result', JSON.stringify(result));

                var dataList = JSON.parse(data);
                var partsList = result.partsList;
                
                partsList.forEach(productDetails => {
                    var object = dataList.find(obj => obj.partNo === productDetails.ProductCode);
                    const newEntry = {
                        EditMode: true,
                        isApproved: false,
                        isSpinShip: false,
                        ProductCode: productDetails.ProductCode,
                        ProductId: productDetails.Id,
                        ProductName: productDetails.Name,
                        ProductUrl: '/lightning/r/Product2/' + productDetails.Id + '/view?navRef=1',
                        PartNo: ((this.resultData.length + 1) * 10).toString().padStart(4, '0'),
                        PartAmount: object.qty,
                        PartAmountNo: `PartAmount${Date.now()}_${this.resultData.length}`,
                        ProductRequestRecordId: null,
                        HandInFlag: null,
                        TransportDivision: null,
                        ShipTo: null,
                        WorkCenterName: null,
                        WorkCenterId: null,
                        ProgressStatus: '신청',
                        Weight: productDetails.Weight__c,
                        UnitCode: productDetails.WeightUnit__c,
                        WeightWithUnit: productDetails.Weight__c && productDetails.WeightUnit__c ? `${productDetails.Weight__c} ${productDetails.WeightUnit__c}` : productDetails.Weight__c || ''
                    };
                    this.resultData.push(newEntry);
                });
    
                if (!result.isSuccess) {
                    this.showToast('Fail', result.message, 'error');
                }

                window.removeEventListener('message', this.handleMessage);
                this.handleMessage = null;
                this.isGPESModal = false;
            }).catch(error => {
                console.log('error', error.message);
            });
        } catch (error) {
            console.error('Invalid JSON data received:', error.message);
        }
    }    

    addRowClick() {
        console.log('addRowClick');
        // 선택된 행이 있는지 확인
        const selectedRow = this.resultData.find(row => row.isChecked);
        const spindleRow = this.resultData.find(row => row.ProductType && row.EditMode);
        console.log(JSON.stringify(spindleRow));
        let newEntry;
        if(!spindleRow){
            newEntry = {
                // ...selectedRow,
                EditMode: true,
                isChecked: true,
                isApproved: false,
                // isSpinShip:  (this.OrderType__c == '215' || this.OrderType__c=='214') ? true:false,
                isSpinShip: false,
                ProductCode: null,
                ProductId: '',
                ProductName: null,
                // PartNo: '0010',  // 초기 순번 설정
                PartAmount: null,
                PartAmountNo: `PartAmount${Date.now()}`,
                ProductRequestRecordId: null,
                isChecked: true,
                isApproved: false,
                // isSpinShip: (this.OrderType__c == '215' || this.OrderType__c=='214' ) ? true:false,
                isSpinShip: false,
                ProgressStatus: '신청',
                ProductUrl: null,
                // PartNo: '0010',  // 초기 순번 설정
                PartNo: '',  // 초기 순번 설정
                ShipTo: (this.OrderType__c == '215' || this.OrderType__c=='214' ) ? this.spindleShiptoId:null
            };
        }else{
            newEntry = {
                EditMode: true,
                isChecked: true,
                isApproved: false,
                // isSpinShip:  (this.OrderType__c == '215' || this.OrderType__c=='214') ? true:false,
                isSpinShip: false,
                ProductCode: null,
                ProductId: '',
                ProductName: null,
                ProductUrl: null,
                // PartNo: '0010',  // 초기 순번 설정
                PartNo: '',  // 초기 순번 설정
                PartAmount: null,
                PartAmountNo: `PartAmount${Date.now()}`,
                ProductRequestRecordId: null,
                HandInFlag: null,
                TransportDivision: null,
                ShipTo: (this.OrderType__c == '215' || this.OrderType__c=='214') ? this.spindleShiptoId:null, // || spindleRow!=undefined
                AccountNm: null,
                WorkCenterName: null,
                WorkCenterId: null,
                ProgressStatus: '신청'
            };
        }

        // if (selectedRow && !spindleRow) {
        //     newEntry = {
        //         ...selectedRow,
        //         PartAmountNo: `PartAmount${Date.now()}`,
        //         ProductRequestRecordId: null,
        //         isChecked: true,
        //         isApproved: false,
        //         // isSpinShip: (this.OrderType__c == '215' || this.OrderType__c=='214' ) ? true:false,
        //         isSpinShip: false,
        //         ProgressStatus: '신청',
        //         ProductUrl: selectedRow.ProductId ? '/lightning/r/Product2/' + selectedRow.ProductId + '/view?navRef=1' : null,
        //         // PartNo: '0010',  // 초기 순번 설정
        //         PartNo: '',  // 초기 순번 설정
        //         ShipTo: (this.OrderType__c == '215' || this.OrderType__c=='214' ) ? this.spindleShiptoId:null
        //     };
        // } else {
        //     newEntry = {
        //         EditMode: true,
        //         isChecked: true,
        //         isApproved: false,
        //         // isSpinShip:  (this.OrderType__c == '215' || this.OrderType__c=='214') ? true:false,
        //         isSpinShip: false,
        //         ProductCode: null,
        //         ProductId: '',
        //         ProductName: null,
        //         ProductUrl: null,
        //         // PartNo: '0010',  // 초기 순번 설정
        //         PartNo: '',  // 초기 순번 설정
        //         PartAmount: null,
        //         PartAmountNo: `PartAmount${Date.now()}`,
        //         ProductRequestRecordId: null,
        //         HandInFlag: null,
        //         TransportDivision: null,
        //         ShipTo: (this.OrderType__c == '215' || this.OrderType__c=='214') ? this.spindleShiptoId:null, // || spindleRow!=undefined
        //         AccountNm: null,
        //         WorkCenterName: null,
        //         WorkCenterId: null,
        //         ProgressStatus: '신청'
        //     };
        // }

        if (this.resultData.length === 0) {
            // newEntry.PartNo = '0010';
            this.resultData = [newEntry];
        } else {
            this.resultData = [...this.resultData, newEntry];
            // this.updateSequenceNumbers('Add');
        }

        // 선택 상태 초기화
        // this.resultData = this.resultData.map(row => ({
        //     ...row,
        //     isChecked: false
        // }));
    }

    checkAllClick(event) {
        const isChecked = event.target.checked;
        const checkboxes = this.template.querySelectorAll('lightning-input[data-id]');
        
        checkboxes.forEach(checkbox => {
            const rowId = checkbox.dataset.id;
            const row = this.resultData.find(item => item.PartAmountNo === rowId);
            
            // 승인된 항목이 아닌 경우에만 체크 상태 변경
            if (row && !row.isApproved) {
                checkbox.checked = isChecked;
                row.isChecked = isChecked;
            }
        });
    }

    checkCellClick(event) {
        const checkbox = event.target;
        const rowId = checkbox.dataset.id;
        const row = this.resultData.find(item => item.PartAmountNo === rowId);
        
        // 승인된 항목인 경우 크 방지
        if (row && row.isApproved) {
            event.preventDefault();
            checkbox.checked = false;
            return;
        }
        
        // 현재 행의 체크 상태만 업데이트
        if (row) {
            row.isChecked = checkbox.checked;
        }
    }

    deleteLine(event) {
        const rowId = event.target.dataset.id;
        const rowIndex = this.resultData.findIndex(row => row.PartAmountNo === rowId);
        
        if (rowIndex !== -1) {
            const row = this.resultData[rowIndex];
            if (row.isApproved) {
                this.showToast('경고', '승인된 행은 삭제할 수 없습니다.', 'warning');
                return;
            }
            
            if (row.ProductRequestRecordId) {
                DeleteProduct({
                    recordId: row.ProductRequestRecordId
                })
                .then(() => {
                    this.resultData = this.resultData.filter((_, index) => index !== rowIndex);
                    // this.isSpindleDisabled = false;
                    if (this.resultData.some(item => item.ProductType != null)) { //스핀들 하나라도 있으면 버튼 disabled --> ? 질문 필요
                        this.isSpindleDisabled = true;
                        this.isButtonGroupDisabled = false;
                        this.isAddLineDisabled = false;
                    } else {
                        if(this.OrderType__c == '202') {
                            this.isSpindleDisabled = false;
                            // this.isButtonGroupDisabled = true;
                            // this.isAddLineDisabled = true;
                        }
                    }
                    // this.updateSequenceNumbers('Delete');
                    this.showToast('성공', '선택한 행이 삭제되었습니다.', 'success');
                })
                .catch(error => {
                    console.error('Error deleting record:', error);
                    this.showToast('오류', '삭제 중 오류가 발생했습니다: ' + (error.body?.message || error.message || '알 수 없는 오류'), 'error');
                });
            } else {
                this.resultData = this.resultData.filter((_, index) => index !== rowIndex);
                // this.isSpindleDisabled = false;
                if (this.resultData.some(item => item.ProductType != null)) { //스핀들 하나라도 있으면 버튼 disabled
                    this.isSpindleDisabled = true;
                    this.isButtonGroupDisabled = false;
                    this.isAddLineDisabled = false;
                } else {
                    if(this.OrderType__c == '202') {
                        this.isSpindleDisabled = false;
                        // this.isButtonGroupDisabled = true;
                        // this.isAddLineDisabled = true;
                    }
                }
                // this.updateSequenceNumbers('Delete');
                
                this.showToast('성공', '선택한 행이 삭제되었습니다.', 'success');
            }
        }
    }

    controlChkBox(isChecked, allCondition){
        var clickedIndex = [];
        if(allCondition){
            const checkBoxes = this.template.querySelectorAll('[data-id="itemCheckBox"]'); // itemCheckBox으로 찾기
            checkBoxes.forEach((element, index) => {
                element.checked = isChecked;
                if(isChecked == true){
                    clickedIndex.push(index);
                }
            });
        }else{
            const checkBoxes = this.template.querySelectorAll('[data-id="itemCheckBox"]'); // itemCheckBox으로 찾기
            checkBoxes.forEach((element, index) => {
                if(element.checked){
                    clickedIndex.push(index);
                }
            });
        }
        console.log('clickedIndex 결과 ::: ' + clickedIndex);   
        
        for(var index = 0; index < this.resultData.length; index++){
            if(clickedIndex.includes(index)){
                this.resultData[index].CheckBox = true;
                this.serviceIndex = index;
            }
            else{
                this.resultData[index].CheckBox = false;
            }
        }
        this.serviceProductId = this.resultData[this.serviceIndex].ProductId;
        this.serviceProductCode = this.resultData[this.serviceIndex].ProductCode;
        this.serviceQuantity = this.resultData[this.serviceIndex].PartAmount;

        console.log('과 ::: ' + JSON.stringify(this.resultData));
    }


    editBtnClick(event){
        //기존값을 가지고 있는다.
        if(this.isEditMode == false){
            console.log('수정모드 진입');
            this.beforeData = JSON.parse(JSON.stringify(this.resultData));

            // ShipTo 값을 serviceTerritoryOptions의 value로 매핑
            this.resultData = this.resultData.map(item => {
                if (item.ShipTo) {
                    const territory = this.serviceTerritoryOptions.find(opt => opt.label === item.ShipTo);
                    if (territory) {
                        return { ...item, ShipTo: territory.value, EditMode: true };
                    }
                }
                return { ...item, EditMode: true };
            });
            
            console.log('수정모드 데:', JSON.stringify(this.resultData));
        }
        else {
            console.log('읽기모드 진');
            if(this.beforeData.length > 0){
                this.resultData = JSON.parse(JSON.stringify(this.beforeData));
            }
        }
        this.isEditMode = !this.isEditMode;
    }

    handleInputChange(event) {
        const field = event.target.name;
        const value = event.target.value;
        const recordId = event.target.dataset.id;
        
        console.log('Input Change - Field:', field);
        console.log('Input Change - Value:', value);
        console.log('Input Change - RecordId:', recordId);
        
        const index = this.resultData.findIndex(item => item.PartAmountNo === recordId);
        if (index !== -1) {
            const updatedRow = { ...this.resultData[index] };
            
            // 수량 입력 처리
            if (field === 'PartAmount') {
                const numValue = value ? parseInt(value, 10) : null;
                console.log('Setting PartAmount to:', numValue);
                updatedRow.PartAmount = numValue;
            } 
            // 탁송구분 처리
            else if (field === 'TransportDivision') {
                updatedRow.TransportDivision = value;
            }
            // 다른 필드들 처리
            else {
                updatedRow[field] = value;
            }
            
            // 배열 업데이트
            const newResultData = [...this.resultData];
            newResultData[index] = updatedRow;
            this.resultData = newResultData;
            
            console.log('Updated Row:', JSON.stringify(updatedRow));
            console.log('Full resultData:', JSON.stringify(this.resultData));
        }
    }

    handleShipToChange(event) {
        const value = event.target.value;
        //배송처 수정 시 EditMode == true 인 row 모두 변경
        this.resultData = this.resultData.map(row => {
            if(row.EditMode === true) {// && !row.isSpinShip
                return {
                    ...row,
                    ShipTo: value
                };
            }
            return row;
        });    

        this.handleInputChange(event);
    }

    saveBtnClick() {
        // 체크된 행만 필터링
        const rowsToCHk = this.resultData.filter(row => row.isChecked === true);
        const rowsToFalseCHk = this.resultData.filter(row => row.EditMode === false);

        if (rowsToCHk.length === 0) {
            this.showToast('알림', '저장할 항목을 선택해주세요.', 'warning');
            return;
        }

        // const rowsToCHkList = rowsToCHk.map(row => row.ProductCode);
        // const matchedList = rowsToFalseCHk.filter(map =>
        //     rowsToCHkList.includes(map.ProductCode)
        // );

        // if (matchedList.length > 0) {
        //     const duplicateProductIds = [
        //         ...new Set(
        //         matchedList
        //             .map(item => String(item.ProductCode).trim())
        //             .filter(id => id) // 유효한 값만
        //         )
        //     ];
        //     const duplicateMessage = duplicateProductIds.join(', ');

        //     this.showToast('경고', `존재하는 품번이 있습니다: ${duplicateMessage}`, 'warning');
        //     return;
        // }

        let isChk = false;
        // 필수 필드 검증
        const invalidRows = rowsToCHk.filter(row => {
            let isWork = ['1', '2', '3', '4'].includes(row.TransportDivision) ? true : false; //탁송구분이 대리점 이면 true
            let isPickup = ['4', '99'].includes(row.TransportDivision) ? true : false; //탁송구분이 방문수령 이면 true
            const requiredFields = [!row.ProductId, !row.PartAmount, !row.TransportDivision];

            if((row.TransportDivision!=null && isPickup)==false && row.ShipTo == null){
                isChk=true;
                return;
            }
            if (isWork && !row.WorkCenterId) {
                return true;
            }
            return requiredFields.some(field => field === true);
        });
        if (isChk) {
            this.showToast('경고', '탁송구분이 방문수령이 아닐 경우 배송처는 필수 입력입니다.', 'warning');
            return;
        }
        if (invalidRows.length > 0) {
            this.showToast('경고', '품명, 수량, 탁송구분은 필수 입력 항목입니다.\n탁송구분이 대리점인 경우 대리점도 필수 입력입니다.', 'warning');
            return;
        }

        // 저장하기 전에 번호 업데이트
        // this.saveSequenceNumbers();
        const rowsToSave = this.resultData.filter(row => row.isChecked === true);
        
        // ChargingPartWrapper 형식으로 데이터 변환
        const wrapperList = rowsToSave.map(row => {
            const productId = Array.isArray(row.ProductId) ? row.ProductId[0] : row.ProductId;
            
            return {
                ProductRequestRecordId: row.ProductRequestRecordId || null,
                ProductId: productId,
                ProductName: row.ProductName,
                ProductCode: row.ProductCode,
                PartAmount: row.PartAmount,
                TransportDivision: row.TransportDivision,
                ShipTo: row.ShipTo,
                WorkCenterId: row.WorkCenterId,
                WorkCenterName: row.WorkCenterName,
                ProgressStatus: 'Approved',  // 무조건 Approved로 설정
                Weight: row.Weight,
                ProductType: row.ProductType || null,
                PartNo: row.PartNo
            };
        });

        console.log('Saving wrapper list:', JSON.stringify(wrapperList));
        this.isSpinner = true;
        
        //주석 나중에 다시 풀어야 함
        // upsertRequestProduct({
        //     requestProductList: wrapperList,
        //     workOrderId: this.recordId
        // })
        // .then(result => {
        //     if (result === 'SUCCESS') {
        //         this.showToast('성공', '성공적으로 저장되었습니다.', 'success');
        //         this.refreshList();
        //     } else {
        //         this.showToast('오류', result, 'error');
        //     }
        //     this.isSpinner = false;
        // })
        // .catch(error => {
        //     console.error('Save Error:', error);
        //     this.showToast('오류', '저장 중 오류가 발생했습니다: ' + (error.body?.message || error.message || '알 수 없는 오류'), 'error');
        //     this.isSpinner = false;
        // });
        

        upsertPRData({
            requestProductList: wrapperList,
            workOrderId: this.recordId
        })
        .then(result => {
            if (result === 'SUCCESS') {
                this.showToast('성공', '성공적으로 저장되었습니다.', 'success');
                this.refreshList();
            } else {
                this.showToast('오류', result, 'error');
            }
            this.isSpinner = false;
        })
        .catch(error => {
            console.error('Save Error:', error);
            this.showToast('오류', '저장 중 오류가 발생했습니다: ' + (error.body?.message || error.message || '알 수 없는 오류'), 'error');
            this.isSpinner = false;
        });
    }

    showAlert(message) {
        // 경고 메시지를 표시하는 로직
        alert(message);
    }

    productChange(event) {
        const rowId = event.target.dataset.id;        
        let selectedValue = event.detail.value || event.target.value;

        // 제품이 선택되지 않은 경우 필드 초기화
        if (selectedValue=='') {
            const rowIndex = this.resultData.findIndex(row => row.PartAmountNo === rowId);
            if (rowIndex !== -1) {
                const updatedRow = { ...this.resultData[rowIndex] };
                updatedRow.ProductId = null;
                updatedRow.ProductName = null;
                updatedRow.ProductCode = null;
                updatedRow.ProductUrl = null;
                updatedRow.Weight = null;
                updatedRow.UnitCode = null;
                updatedRow.WeightWithUnit = null;
                
                this.resultData[rowIndex] = updatedRow;
                this.resultData = [...this.resultData];
            }
            return;
        }
        
        // 제품이 선택된 경우 처리
        this.isSpinner = true;
        let productId = selectedValue;
        
        if (Array.isArray(selectedValue)) {
            productId = selectedValue[0];
        } else if (typeof selectedValue === 'object' && selectedValue !== null) {
            productId = selectedValue.id || selectedValue.value || Object.values(selectedValue)[0];
        }
        
        if (typeof productId === 'string') {
            productId = productId.replace(/^"|"$/g, '');
        }
        
        if (!productId) {
            this.isSpinner = false;
            return;
        }
        
        GetProductDetails({ productId: productId })
            .then(result => {
                if (!result) {
                    this.isSpinner = false;
                    return;
                }
                
                const rowIndex = this.resultData.findIndex(row => row.PartAmountNo === rowId);
                if (rowIndex !== -1) {
                    const updatedRow = { ...this.resultData[rowIndex] };
                    updatedRow.ProductId = productId;
                    updatedRow.ProductName = result.FM_MaterialDetails__c;
                    updatedRow.ProductCode = result.ProductCode;
                    updatedRow.ProductUrl = '/lightning/r/Product2/' + productId + '/view?navRef=1';
                    updatedRow.Weight = result.Weight__c || '';
                    updatedRow.UnitCode = result.WeightUnit__c || '';
                    updatedRow.WeightWithUnit = (result.Weight__c && result.WeightUnit__c) ? 
                        `${result.Weight__c} ${result.WeightUnit__c}` : result.Weight__c || '';
                    
                    this.resultData[rowIndex] = updatedRow;
                    this.resultData = [...this.resultData];
                }
                this.isSpinner = false;
            })
            .catch(error => {
                console.error('GetProductDetails Error:', error);
                this.isSpinner = false;
            });
    }

    //재고 button
    stockModal(event) {
        this.isStockModal = !this.isStockModal;
        this.stockColumnsChange = this.stockColumns.filter((column) => column.type != 'button');

        if (this.isStockModal) {
            // 체크된 행이 있는지 확인
            const selectedRow = this.resultData.find(item => item.isChecked);
            if (selectedRow && selectedRow.ProductCode) {
                // 모달이 열린 후 제품 선택 필드에 값을 설정하기 위해 setTimeout 사용
                setTimeout(() => {
                    const inputField = this.template.querySelectorAll('[data-id="product2Id"]')[0];
                    if (inputField) {
                        inputField.value = selectedRow.ProductId;
                        // 선택된 제품으로 재고 조회 
                        this.loadStockInfo(selectedRow.ProductId,selectedRow.PartAmount);
                    }
                }, 100);

            } else {
                const inputField = this.template.querySelectorAll('[data-id="product2Id"]')[0];
                if (inputField) {
                    inputField.value = '';
                }
                this.stockResult = {};
                this.stockTableData = [];
                this.loadStockInfo('','');
            }
        }
    }

    stockSearch(event) {
        event.preventDefault();
        const productId = event.detail.value;
        // 재고 조회
        this.stockResult = {};
        this.stockTableData = [];
        this.loadStockInfo(productId,'');
    }

    loadStockInfo(productId,partAmount) {
        // 배열인 경우 첫 번째 값을 사용
        let finalProductId = Array.isArray(productId) ? productId[0] : productId;
        let finalpartAmount = Array.isArray(partAmount) ? partAmount[0] : partAmount;
        
        this.stockResult = {};
        this.stockTableData = [];

        if (!finalProductId) {
            // this.showToast('알림', '품번을 선택해주세요.', 'warning');
            return;
        }
        
        this.isStockModalSpinner = true;
        finalpartAmount = finalpartAmount==null?'':finalpartAmount;
        searchDealerStock({ productId: finalProductId,partAmount:finalpartAmount })
            .then(result => {
                console.log('Stock search result:', result);
                
                // 인터페이스 결과 처리
                if (result.ES_INFO) {
                    const esInfo = result.ES_INFO;
                    this.stockResult = {
                        ...esInfo,
                        NETPR:  esInfo.NETPR ? new Intl.NumberFormat('ko-KR').format(esInfo.NETPR) : '0',
                        LABST:  esInfo.LABST  || '0',
                        LABST2: esInfo.LABST2 || '0',
                        AVRLT:  esInfo.AVRLT  || '0',
                        PLIFZ:  esInfo.PLIFZ  || '0',
                        hasNoData: false,
                        MATNR: result.productCode,
                        // 각 필드별로 'Not define' 또는 빈 값인 경우 '정보없음' 표시
                        MAKTX: esInfo.MAKTX || '정보없음',
                        REPNR: esInfo.REPNR === 'Not define' ? '정보없음' : (esInfo.REPNR || '정보없음'), //대체품
                        THREAD: esInfo.THREAD === 'Not define' ? '정보없음' : (esInfo.THREAD || '정보없음'), //규격
                        MEINS: esInfo.MEINS === 'Not define' ? '정보없음' : (esInfo.MEINS || '정보없음'), //단위
                        NONMV: esInfo.NONMV === 'Not define' ? '정보없음' : (esInfo.NONMV || '정보없음'), //비가공여부
                        DISMM: esInfo.DISMM === 'Not define' ? '정보없음' : (esInfo.DISMM || '정보없음'), //MRP유형
                        MAABC: esInfo.MAABC === 'Not define' ? '정보없음' : (esInfo.MAABC || '정보없음'), //ABC등급
                        WAERS: esInfo.WAERS === 'Not define' ? '정보없음' : (esInfo.WAERS || '정보없음') //판매가 단위
                    };
                } else {
                    this.stockResult = {
                        hasNoData: true,
                        message: '부품 재고조회(CSPLUS-021) 인터페이스 결과가 없습니다.'
                    };
                }
                // 대리점 재고 정보 처리
                if (result && result.stockList && result.stockList.length > 0) {
                    this.stockTableData = result.stockList;
                    this.hasNoStockData = false;
                } else {
                    this.stockTableData = [];
                    this.hasNoStockData = true;
                }
                this.isStockModalSpinner = false;
            })
            .catch(error => {
                console.error('Error searching stock:', error);
                let errorMessage = '재고 조회 중 오류가 발생했습니다.';
                if (error.body && error.body.message) {
                    errorMessage += ' ' + error.body.message;
                } else if (error.message) {
                    errorMessage += ' ' + error.message;
                }
                this.showToast('오류', errorMessage, 'error');
                this.isStockModalSpinner = false;
            });
    }

    showToast(title, message, variant = 'info') {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant // info, success, warning, error
        });
        this.dispatchEvent(evt);
    }

    searchService() {
        this.isServiceModalSpinner = true;
        
        // 선택된 모든 행의 ProductId 수집
        const selectedProducts = this.resultData
            .filter(row => row.isChecked)
            .map(row => ({
                 ProductId:row.ProductId
                ,PartAmount: row.PartAmount
            }));

        if (selectedProducts.length === 0) {
            this.showToast('알림', '조회 할 부품을 선택해주세요.', 'warning');
            this.isServiceModalSpinner = false;
            this.isServiceModal = false;
            return;
        }

        const invalidProduct = selectedProducts.find(product => !product.ProductId);
        if (selectedProducts.length > 0 && invalidProduct) {
            this.showToast('알림', '부품을 입력해주세요.', 'warning');
            this.isServiceModalSpinner = false;
            this.isServiceModal = false;
            return;
        }
        
        const invalidProductAmount = selectedProducts.find(product => !product.PartAmount || product.PartAmount===0);
        if (selectedProducts.length > 0 && invalidProductAmount) {
            this.showToast('알림', '수량을 입력해주세요.', 'warning');
            this.isServiceModalSpinner = false;
            this.isServiceModal = false;
            return;
        }

        searchMultipleProductStock({ products: selectedProducts })
            .then(result => {
                console.log('Service search result:', result);
                this.serviceTableData = result;
                this.isServiceModalSpinner = false;
            })
            .catch(error => {
                console.error('Error searching service:', error);
                let errorMessage = '대리점 조회 중 오류가 발생했습니다.';
                if (error.body && error.body.message) {
                    errorMessage += ' ' + error.body.message;
                } else if (error.message) {
                    errorMessage += ' ' + error.message;
                }
                this.showToast('오류', errorMessage, 'error');
                this.isServiceModalSpinner = false;
            });
    }


    searchSpindle(event) {
        this.isSpindleModalSpinner = true;
        this.hasSpindleError = false;
        this.spindleErrorMessage = '';
        
        searchSpindle({ equipmentNumber: this.recordId })
            .then(result => {
                console.log('원본 Spindle search result:', result);
                
                try {
                    // 문자열로 온 경우 JSON으로 파싱
                    if (typeof result === 'string') {
                        result = JSON.parse(result);
                    }
                    if (result.O_RETURN && result.O_RETURN.TYPE === 'E') {
                        this.hasSpindleError = true;
                        this.spindleErrorMessage = result.O_RETURN.MESSAGE || '조회 결과가 없습니다.';
                        this.spindleTableData = [];
                    } else if (result.T_O_LIST && result.T_O_LIST.length > 0) {
                        // 데이터를 새 배열로 복사하여 할당
                        this.spindleTableData = [...result.T_O_LIST];
                        console.log('테이블에 설정된 데이터:', JSON.stringify(this.spindleTableData, null, 2));
                    } else {
                        this.hasSpindleError = true;
                        this.spindleErrorMessage = '조회된 스핀들 정보가 없습니다.';
                        this.spindleTableData = [];
                    }
                } catch (error) {
                    console.error('데이터 처리 중 오류:', error);
                    this.hasSpindleError = true;
                    this.spindleErrorMessage = '데이터 처리 중 오류가 발생했습니다.';
                    this.spindleTableData = [];
                }
                
                this.isSpindleModalSpinner = false;
            })
            .catch(error => {
                console.error('Error searching spindle:', error);
                this.hasSpindleError = true;
                this.spindleErrorMessage = '스핀들 조회 중 오류가 발생했습니다.';
                if (error.body && error.body.message) {
                    this.spindleErrorMessage += ' ' + error.body.message;
                }
                this.spindleTableData = [];
                this.isSpindleModalSpinner = false;
            });
    }


    serviceRowAction(event){
        const row = event.detail.row;
        
        this.resultData = this.resultData.map(dataRow => {
            if (dataRow.isChecked) { 
                dataRow.WorkCenterId = row.DEALER;
                dataRow.WorkCenterName = row.NAME1;
            }
            return dataRow;
        });

        //모달닫기
        this.isServiceModal = false;
    }

    gpesModal() {
        this.isGPESModal = !this.isGPESModal;

        console.log('isGPESModal ::: ', this.isGPESModal);
        if (this.isGPESModal) {
            this.handleMessage = this.chargingPartHandleMessage.bind(this);
            console.log('handleMessage ::: ', this.handleMessage);
            window.addEventListener('message', this.handleMessage);
        } else {
            window.removeEventListener('message', this.handleMessage);
            this.handleMessage = null;
        }
    }

    serviceModal(event){
        this.isServiceModal = !this.isServiceModal;
        if(this.isServiceModal){
            this.searchService();
        }
    }
    spindleModal(event){
        if(this.resultData.length > 0){
            this.showToast('오류', '스핀들 청구 후 부품청구가 가능합니다.', 'error');
        } else {
            this.isSpindleModal = !this.isSpindleModal;
            if (this.isSpindleModal) {
                this.searchSpindle();
            }
        }
    }
    /* SDLS Styes */
    adjustSldsStyles() {
        const style = document.createElement('style');
        style.innerText = `
            .chargingParts .slds-modal__container {
                width: calc(100vw - 6rem) !important;
                max-width: 120rem !important;
                padding-bottom: 2rem;
            }
            .chargingParts .slds-modal__content {
                max-height: calc(100vh - 14rem);
                height: 50rem;
                padding: 0;
                overflow: hidden;
            }
            .serviceModal .card-01 .input-wrap .slds-form-element {
                width: 100%;
            }
            .stockModal .card-02 .section-control {
                border-raius: 0;
            }
            .stickModal .card-02 .slds-gutters .slds-form-element:nth-of-type(3) {
                grid-area: 2 / 1 / 2 / 3;
            }
            .table-wrap {
                overflow-x: auto;
            }
            .slds-table {
                background-color: white;
            }
            .slds-table td {
                padding: 0.25rem 0.5rem;
                white-space: nowrap;
            }
            .slds-table th {
                padding: 0.5rem;
                background-color: #f3f3f3;
                font-weight: bold;
            }
            .slds-input {
                min-height: 32px;
            }
            .slds-combobox {
                min-height: 32px;
            }
            lightning-input.slds-checkbox {
                margin-bottom: 0;
            }
            .slds-button_icon {
                color: #706e6b;
            }
            .slds-hint-parent:hover {
                background-color: #f3f3f3;
            }
            .slds-table td lightning-input,
            .slds-table td lightning-combobox {
                margin-bottom: 0;
            }
            .slds-table td lightning-input .slds-input,
            .slds-table td lightning-combobox .slds-combobox__input {
                height: 32px;
                padding: 0 0.5rem;
            }
            .chargingParts .table-wrap table tr td .slds-dropdown-trigger .slds-dropdown {
                max-height: 11rem;
                overflow: auto;
                min-height : 160px;

            }
            .table-wrap table tr:nth-of-type(1) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown, 
            .table-wrap table tr:nth-of-type(2) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown, 
            .table-wrap table tr:nth-of-type(3) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown, 
            .table-wrap table tr:nth-of-type(4) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown {
                top: 100% !important;
                bottom: unset !important;
            }
            .table-wrap table tr:nth-last-of-type(1) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown,
            .table-wrap table tr:nth-last-of-type(2) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown,
            .table-wrap table tr:nth-last-of-type(3) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown,
            .table-wrap table tr:nth-last-of-type(4) td:not(:nth-of-type(6)) .slds-dropdown-trigger .slds-dropdown {
                top: unset;
                bottom: 100%;
            }
            .action .slds-button_first, 
            .action .slds-button_last {
                height: 2rem;
            }
           
        `;
        this.template.querySelector('.chargingParts').appendChild(style);
    }
   

    get OrderType__c() {
        return this._orderType;
    }
    
    set OrderType__c(value) {
        this._orderType = value;
    }
    
    get Status() {
        return this._status;
    }
    
    set Status(value) {
        this._status = value;
    }


    getWorkOrderType() { 
        /** checkBillingStatus == Y ||  FM_IsBilled__c == true 일 때, 어떤 경우든 무조건 버튼 비활성화 후 메시지 출력
         *  case1. 오더타입, 추가버튼: 무상Claim(201), 유상 Claim(202), 부품만청구(217) 이면서 장비의 부품보증이 "Y" 인경우
            case2. 오더타입, 추가버튼: 유상 Claim(202) 오더의 출동 W/C가 직영인 경우
            case3. 오더타입, 추가버튼: P-Clamil(204) 장비의 부품 보증여부와 관계 없이 부품 청구 가능
            case4. 오더타입, 추가버튼: 유/무상 SP 입고수리 (215, 214)인 경우
            case5. 오더타입, 추가버튼: Pre-Call (203)인 경우 종결이 아니면 부품 청구 가능
            case6. 오더타입, 스핀들버튼: 유상 Claim(202) 일 땐, (유)스핀들 버튼 활성화
            case7. 오더타입, 스핀들버튼: 확정/삭제 오더시엔  버튼 비활성화
         */
        getWorkOrder({ recordId: this.recordId })
            .then(result => {
                console.log('WorkOrder 타입:', result.OrderType__c);
                console.log('부품보증 :', result.Case.FM_PartsWarranty__c);
                console.log('직영여부:', result.FM_isDirect__c);
                console.log('장비빌링여부:', result.Case.FM_IsBilled__c);
                console.log('매출여부:', result.Case.checkBillingStatus__c);
                console.log('오더상태:', result.Status);
                console.log('고객귀책 :', result.IsDirectPaidService__c);
                this.OrderType__c = result.OrderType__c;
                this.Status = result.Status;
                //버튼제어
                let isButtonUse = false;
                let isSpButtonUse = false;
                if(result.Case.FM_PartsWarranty__c =='Y' 
                    && ['201', '202', '217','219','220'].includes(this.OrderType__c)){ //case1
                    isButtonUse = true;
                }
                if(result.FM_isDirect__c && this.OrderType__c == '202') isButtonUse = true; //case2
                if(this.OrderType__c == '204' || this.OrderType__c == '218') isButtonUse = true; //case3
                if(this.OrderType__c == '215' || this.OrderType__c == '214' || this.OrderType__c == '219' || this.OrderType__c == '220') { //case4
                    isButtonUse = true;
                }
                if(this.OrderType__c == '203' && (this.Status != 'Confirm' && this.Status != 'Completed')){ //case5
                    isButtonUse = true;
                }
                if(this.OrderType__c == '202') isSpButtonUse = true; //case6
                if(this.Status == 'Confirm' || this.Status == 'Canceled'){//case7
                    isButtonUse = false; 
                }

                //장비에 있는 IS Billed가 True이면 그냥 되는데 True 아닌경우에는 매출버튼 눌러야함
                if (result.IsDirectPaidService__c == false && result.Case.checkBillingStatus__c=='N' && !result.Case.FM_IsBilled__c) { //빌링처리 체크
                    if(this.OrderType__c != '204' || this.OrderType__c != '218'){
                        isButtonUse = false;
                    }
                    // isButtonUse = false;
                    isSpButtonUse = false;
                    console.log('* 빌링처리가 되지 않은 장비는 부품 청구가 불가능합니다. 관리자에게 문의해주세요');
                    this.addLineDisabledMessage = '* 빌링처리가 되지 않은 장비는 부품 청구가 불가능합니다. 관리자에게 문의해주세요';
                }
                
                console.log('버튼여부: '+isButtonUse);
                console.log('스핀들버튼여부: '+isSpButtonUse);
                console.log('빌링메시지: '+this.addLineDisabledMessage);

                if(isButtonUse) {
                    this.isButtonDisabled = false;
                    this.isButtonGroupDisabled = false;
                    this.isAddLineDisabled = false;
                    this.isSaveLineDisabled = false;
                }

                if(isSpButtonUse) {
                    this.isSpindleDisabled = false;
                    this.isSaveLineDisabled = false;
                }
            })
            .catch(error => {
                console.error('WorkOrder 타입 회 류:', error);
            });
    }


    saveSequenceNumbers(){
        let lastPartNo = this.lastSeq && this.lastSeq.trim() !== '' ? parseInt(this.lastSeq, 10) : 10;

        // let lastPartNo;  // 마지막 PartNo 저장
        this.resultData = this.resultData
            .filter(row => row.isChecked || row.isApproved)
            .map((row, index) => {
                console.log('this.resultData', JSON.stringify(this.resultData));

                // isApproved === true인 경우, PartNo를 그대로 유지
                if (row.isApproved) {
                    return { ...row, PartNo: row.PartNo };
                }
    
                lastPartNo += 10;
                const sequenceNumber = lastPartNo.toString().padStart(4, '0');
    
                console.log(`New sequence generated: ${sequenceNumber}`);
                // console.log('lastPartNo', lastPartNo);
                this.lastSeq = sequenceNumber;
                console.log('saveSequenceNumbers this.lastSeq', this.lastSeq);
                return { ...row, PartNo: sequenceNumber };






                // if(row.isApproved){
                //     lastPartNo = row.PartNo;
                //     return {
                //         ...row
                //     };
                // }
                // const sequenceNumber = (parseInt(lastPartNo, 10) + 10).toString().padStart(4, '0');
                // lastPartNo = parseInt(sequenceNumber, 10);

                // return {
                //     ...row,
                //     PartNo: row.isApproved?row.PartNo:sequenceNumber
                // };
            });
    }

    checkLastSeq(){
        // var seq = '0010';
        this.isServiceModalSpinner = true;
        getLastSequence({ 
            recordId: this.recordId 
        }).then(result => {
            console.log('getLastSequence result:', result);
            this.lastSeq = result;
            
            console.log('this.lastSeq', this.lastSeq);
            this.isServiceModalSpinner = false;
        }).catch(error => {
            console.error('Error searching service:', error);
            let errorMessage = '마지막 Sequence Number를 가져오는데 문제가 발생했습니다.';
            this.showToast('오류', errorMessage, 'error');
            this.isServiceModalSpinner = false;
        });
        // return seq;
    }

    updateSequenceNumbers(eventName){
        console.log('updateSequenceNumbers');

        let lastPartNo = this.lastSeq && this.lastSeq.trim() !== '' ? parseInt(this.lastSeq, 10) : 10;
        console.log('Initial lastPartNo:', lastPartNo);


        if(eventName == 'Add'){
            //PartNo Max번호
            let maxExistingPartNo = this.resultData
            .filter(row => row.PartNo && row.PartNo !== '') 
            .map(row => parseInt(row.PartNo, 10)) // 숫자로 변환
            .reduce((max, num) => Math.max(max, num), lastPartNo); // 가장 큰 값 찾기

            console.log('Max existing PartNo:', maxExistingPartNo);

            this.resultData = this.resultData.map(row => {
                console.log(`Processing row, PartNo: ${row.PartNo}`);
                console.log('this.resultData', JSON.stringify(this.resultData));
    
    
                // 기존 데이터는 변경하지 않음
                if (row.PartNo && row.PartNo !== '') {
                    return { ...row };
                }
    
                // isApproved === true인 경우, PartNo를 그대로 유지
                if (row.isApproved) {
                    return { ...row, PartNo: row.PartNo };
                }
    
                maxExistingPartNo += 10;
                const sequenceNumber = maxExistingPartNo.toString().padStart(4, '0');
    
                console.log(`New sequence generated: ${sequenceNumber}`);
    
                return { ...row, PartNo: sequenceNumber };
                
                
            });
        }else if(eventName == 'Delete'){
            console.log('this.lastSeq', this.lastSeq);
            let newPartNo = parseInt(this.lastSeq, 10);
            console.log('newPartNo', newPartNo);

            this.resultData = this.resultData.map(row => {
                // isApproved === true인 경우, PartNo를 그대로 유지
                if (row.isApproved) {
                    return { ...row, PartNo: row.PartNo };
                }

                newPartNo += 10;
                return { ...row, PartNo: newPartNo.toString().padStart(4, '0') };
            });
        }
    }


    stockRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        
        // 선택된 대리점 정보 현재 선택된 라인의 대리점 정보 업데이트
        this.resultData = this.resultData.map(dataRow => {
            if (dataRow.PartNo == this.selectPartNo) { 
                dataRow.WorkCenterId = row.DEALER;
                dataRow.WorkCenterName = row.NAME1;
            }
            return dataRow;
        });
        
        this.isStockModal = false;
    }

    handleSubmit(event) {
        event.preventDefault(); // form submit 방지
        return false;
    }

    spindleRowAction(event) {
        const row = event.detail.row;
        let newEntry = {}
        //품번으로 제품아이디 조회 후 넣기
        getProductId({ productName: row.MATNR })
        .then(result => {
            console.log('getProductId result:', JSON.stringify(result));
            newEntry={
                EditMode: true,
                isChecked: true,
                isApproved: false,
                isSpinShip: false,
                ProductCode: result.ProductCode,
                ProductId: result.Id,
                ProductName: result.FM_MaterialDetails__c,
                ProductUrl: '/lightning/r/Product2/' + result.Id + '/view?navRef=1',    
                PartNo: '0010',
                PartAmount: null,
                PartAmountNo: `PartAmount${Date.now()}`,
                ProductRequestRecordId: null,
                HandInFlag: null,
                TransportDivision: null,
                ShipTo: null,
                AccountNm: null,
                WorkCenterName: null,
                WorkCenterId: null,
                ProductType: row.ZTYPE, //구분
                ProgressStatus: '신청'
            };

            if (this.resultData.length === 0) {
                this.resultData = [newEntry];
            } else {
                this.resultData = [...this.resultData, newEntry];
                // this.updateSequenceNumbers('Add');
            }
            
            this.isSpindleModal = false;
    
            if(newEntry.ProductType != null){
                this.isSpindleDisabled = true;
                this.isButtonGroupDisabled = false;
                this.isAddLineDisabled = false;
            }
    
            this.showToast('성공', '스핀들 정보가 적용되었습니다.', 'success');
        })
        .catch(error => {
            console.error('Error searching service:', error);
            this.showToast('오류', '선택한 품번으로 조회된 제품이 없습니다. 관리자에게 확인부탁드립니다.', 'error');
        });
    }    

    @track isExcelModal = false;
    @track excelData = '';
    
    // 엑셀 모달 열기
    openExcelModal() {
        this.isExcelModal = true;
    }

    // 엑셀 모달 닫기
    closeExcelModal() {
        this.isExcelModal = false;
        this.isPasting = false;
        this.excelData = '';
    }

    // 엑셀 데이터 변경 핸들러
    handleExcelDataChange(event) {
        this.excelData = event.target.value;
    }

    // 엑셀 붙여넣기 핸들러
    handlePaste(event) {
        console.log('isPasting', this.isPasting);
        if (this.isPasting) {
            event.preventDefault();
            console.log('Paste is already in progress. Ignored this paste event.');
            return;
        }

        this.isPasting = true;

        event.preventDefault();
        const clipboardData = event.clipboardData || window.clipboardData;
        const pastedData = clipboardData.getData('text');
        this.excelData = pastedData;
        console.log('EXCEL DATA ', pastedData);
        this.processExcelData();
    }

    // 엑셀 데이터 처리
    async processExcelData() {
        if (!this.excelData) {
            this.showToast('알림', '붙여넣을 데이터가 없습니다.', 'warning');
            this.isPasting = false;
            return;
        }

        this.isSpinner = true;
        try {
            console.log('엑셀안에서 오더타입확인: '+this.OrderType__c);
            const rows = this.excelData.trim().split('\n');
            const processedData = rows.map(row => {
                var splitSize = row.split('\t').length;
                const productCode = row.split('\t')[0]?.trim();
                var quantity = 1; // 기본 수량을 1로 설정
                
                if(splitSize > 1){
                    quantity = parseInt(row.split('\t')[1]?.trim());
                }

                return {
                    productCode: productCode,
                    quantity: quantity  
                };
            }).filter(item => item.productCode);

            if (processedData.length === 0) {
                this.isPasting = false;
                throw new Error('처리할 수 있는 데이터가 없습니다.');
            }

            let errorMessages = [];

            var prCodeStr = '';
            for (const data of processedData) {
                if (prCodeStr.length === 0) {
                    prCodeStr = data.productCode;
                } else {
                    prCodeStr += ',' + data.productCode;
                }
            }
            console.log('prCodeStr', prCodeStr);

            var isExist = false;
            if(prCodeStr.length > 0){
                var missingProducts = await checkProduct({ prCodesStr: prCodeStr });
                console.log('missingProducts', missingProducts);
                if(missingProducts.length == 0){
                    isExist = true;
                }else{
                    this.isPasting = false;
                    errorMessages.push('품번 '+missingProducts+'은 확장되지 않은 부품입니다.');
                }
            }
            console.log('isExist', isExist);
            if(isExist){
                for (const data of processedData) {
                    try {
                        const productDetails = await GetProductByCode({ productCode: data.productCode });
                        if (!productDetails) {
                            errorMessages.push(`품번 ${data.productCode}에 대한 제품을 찾을 수 없습니다.`);
                            continue;
                        }
    
                        const newEntry = {
                            EditMode: true,
                            isChecked: true,
                            isApproved: false,
                            // isSpinShip: (this.OrderType__c == '215' || this.OrderType__c=='214') ? true:false,
                            isSpinShip: false,
                            ProductCode: productDetails.ProductCode,
                            ProductId: productDetails.Id,
                            ProductName: productDetails.FM_MaterialDetails__c,
                            ProductUrl: '/lightning/r/Product2/' + productDetails.Id + '/view?navRef=1',
                            // PartNo: ((this.resultData.length + 1) * 10).toString().padStart(4, '0'),
                            PartAmount: data.quantity,
                            PartAmountNo: `PartAmount${Date.now()}_${this.resultData.length}`,
                            ProductRequestRecordId: null,
                            HandInFlag: null,
                            TransportDivision: null,
                            ShipTo: null,
                            WorkCenterName: null,
                            // WorkCenterName: (this.OrderType__c == '215' || this.OrderType__c=='214') ? this.spindleShiptoId:null,
                            WorkCenterId: null,
                            ProgressStatus: '신청',
                            Weight: productDetails.Weight__c,
                            UnitCode: productDetails.WeightUnit__c,
                            WeightWithUnit: productDetails.Weight__c && productDetails.WeightUnit__c ? `${productDetails.Weight__c} ${productDetails.WeightUnit__c}` : productDetails.Weight__c || ''
                        };
    
                        this.resultData = [...this.resultData, newEntry];
                    } catch (error) {
                        errorMessages.push(`품번 ${data.productCode} 처리 중 오류: ${error.message || '알 수 없는 오류'}`);
                    }
                }
            }
            // for (const data of processedData) {
            //     try {
            //         const productDetails = await GetProductByCode({ productCode: data.productCode });
            //         if (!productDetails) {
            //             errorMessages.push(`품번 ${data.productCode}에 대한 제품을 찾을 수 없습니다.`);
            //             continue;
            //         }

            //         const newEntry = {
            //             EditMode: true,
            //             isChecked: true,
            //             isApproved: false,
            //             // isSpinShip: (this.OrderType__c == '215' || this.OrderType__c=='214') ? true:false,
            //             isSpinShip: false,
            //             ProductCode: productDetails.ProductCode,
            //             ProductId: productDetails.Id,
            //             ProductName: productDetails.FM_MaterialDetails__c,
            //             ProductUrl: '/lightning/r/Product2/' + productDetails.Id + '/view?navRef=1',
            //             // PartNo: ((this.resultData.length + 1) * 10).toString().padStart(4, '0'),
            //             PartAmount: data.quantity,
            //             PartAmountNo: `PartAmount${Date.now()}_${this.resultData.length}`,
            //             ProductRequestRecordId: null,
            //             HandInFlag: null,
            //             TransportDivision: null,
            //             ShipTo: null,
            //             WorkCenterName: null,
            //             // WorkCenterName: (this.OrderType__c == '215' || this.OrderType__c=='214') ? this.spindleShiptoId:null,
            //             WorkCenterId: null,
            //             ProgressStatus: '신청',
            //             Weight: productDetails.Weight__c,
            //             UnitCode: productDetails.WeightUnit__c,
            //             WeightWithUnit: productDetails.Weight__c && productDetails.WeightUnit__c ? `${productDetails.Weight__c} ${productDetails.WeightUnit__c}` : productDetails.Weight__c || ''
            //         };

            //         this.resultData = [...this.resultData, newEntry];
            //     } catch (error) {
            //         errorMessages.push(`품번 ${data.productCode} 처리 중 오류: ${error.message || '알 수 없는 오류'}`);
            //     }
            // }

            // this.updateSequenceNumbers('Add');
            this.closeExcelModal();

            if (errorMessages.length > 0) {
                this.showToast('경고', '일부 데이터 처리 중 문제가 발생했습니다:\n\n' + errorMessages.join('\n'), 'warning');
            } else {
                this.showToast('성공', '엑셀 데이터가 성공적으로 추가되었습니다.', 'success');
            }
        } catch (error) {
            this.showToast('오류', error.message || '데이터 처리 중 오류가 발생했습니다.', 'error');
        } finally {
            this.isSpinner = false;
        }
    }

    get tableStyle() {
        return 'height: ' + (this.resultData.length > 10 ? '500px' : 'auto');
    }

    getWorkCenterDisabled(row) {
        if (row.isApproved) return true;  // 승인된 항목은 무조건 비활성화
        if (!row || !row.TransportDivision) return true;
        let isWork = ['1', '2', '3', '4'].includes(row.TransportDivision) ? true : false; //탁송구분이 대리점 이면 true
        return !isWork;
    }

    handleTransportDivisionChange(event) {
        const value = event.target.value;
        const rowId = event.target.dataset.id;
        const rowIndex = this.resultData.findIndex(row => row.PartAmountNo === rowId);

        let isWork = ['1', '2', '3', '4'].includes(value) ? true : false; //탁송구분이 대리점 이면 true
        if (rowIndex !== -1) {
            // 탁송구분이 변경되면 대리점명 초기화
            const updatedRow = {
                ...this.resultData[rowIndex],
                TransportDivision: value,
                WorkCenterId: !isWork ? null : this.resultData[rowIndex].WorkCenterId,
                WorkCenterName: !isWork ? null : this.resultData[rowIndex].WorkCenterName
            };
            
            this.resultData = [
                ...this.resultData.slice(0, rowIndex),
                updatedRow,
                ...this.resultData.slice(rowIndex + 1)
            ];
        }

        //탁송구분 수정 시 EditMode == true 인 row 모두 변경
        this.resultData = this.resultData.map(row => {
            if(row.EditMode === true) {
                return {
                    ...row,
                    TransportDivision: value
                };
            }
            return row;
        });   
    }

    get resultDataWithDisabled() {
        return this.resultData.map(row => ({
            ...row,
            workCenterDisabled: this.getWorkCenterDisabled(row)
        }));
    }

    deleteSelectedRows() {
        const selectedRows = this.resultData.filter(row => row.isChecked && !row.isApproved);
        if (selectedRows.length === 0) {
            this.showToast('알림', '삭제할 항목을 선택해세요.', 'warning');
            return;
        }

        const deletePromises = selectedRows
            .filter(row => row.ProductRequestRecordId)
            .map(row => DeleteProduct({ recordId: row.ProductRequestRecordId }));

        if (deletePromises.length > 0) {
            Promise.all(deletePromises)
                .then(() => {
                    this.resultData = this.resultData.filter(row => !row.isChecked || row.isApproved);
                    // this.isSpindleDisabled = false;
                    if (this.resultData.some(item => item.ProductType != null)) { //스핀들 하나라도 있으면 버튼 disabled
                        this.isSpindleDisabled = true;
                        this.isButtonGroupDisabled = false;
                        this.isAddLineDisabled = false;
                    } else {
                        if(this.OrderType__c == '202') {
                            this.isSpindleDisabled = false;
                            // this.isButtonGroupDisabled = true;
                            // this.isAddLineDisabled = true;
                        }
                    }
                    // this.updateSequenceNumbers('Delete');
                    this.showToast('성공', '선택한 항목들이 삭제되었습니다.', 'success');
                })
                .catch(error => {
                    console.error('Error deleting records:', error);
                    this.showToast('오류', '삭제 중 오류가 발생했습니다.', 'error');
                });
        } else {
            this.resultData = this.resultData.filter(row => !row.isChecked || row.isApproved);
            if (this.resultData.some(item => item.ProductType != null)) { //스핀들 하나라도 있으면 버튼 disabled
                this.isSpindleDisabled = true;
                this.isButtonGroupDisabled = false;
                this.isAddLineDisabled = false;
            } else {
                if(this.OrderType__c == '202') {
                    this.isSpindleDisabled = false;
                    // this.isButtonGroupDisabled = true;
                    // this.isAddLineDisabled = true;
                }
            }
            // this.updateSequenceNumbers('Delete');
            this.showToast('성공', '선택한 항목들이 삭제되었습니다.', 'success');
        }
    }

    //row 별 재고(돋보기) button 클릭 시
    openPart(event){
        this.stockColumnsChange = this.stockColumns;
        event.preventDefault();
        this.isStockModal = true;
        this.selectPartNo = '';

        const rowId = event.target.dataset.id;
        const rowIndex = this.resultData.findIndex(row => row.PartAmountNo === rowId);
        
        if (this.isStockModal) {
            if (rowIndex !== -1) {
                const row = this.resultData[rowIndex];
                this.selectPartNo = this.resultData[rowIndex].PartNo;
                if(row.ProductCode == null || row.ProductCode ==''){
                    this.isStockModal = false;
                    this.showToast('오류', '재고조회 할 품명을 선택해주세요.', 'error');
                    return;
                }
                if(row.PartAmount == null || row.PartAmount =='' || row.PartAmount ==0){
                    this.isStockModal = false;
                    this.showToast('오류', '재고조회 할 품명의 수량을 입력해주세요.', 'error');
                    return;
                }
                if (row.ProductCode && row.PartAmount) {
                    // 모달이 열린 후 제품 선택 필드에 값을 설정하기 위해 setTimeout 사용
                    setTimeout(() => {
                        const inputField = this.template.querySelectorAll('[data-id="product2Id"]')[0];
                        if (inputField) {
                            inputField.value = row.ProductId;
                            // 선택된 제품으로 재고 조회 
                            this.loadStockInfo(row.ProductId,row.PartAmount);
                        }
                    }, 100);
                }
            }
        }
    }
}