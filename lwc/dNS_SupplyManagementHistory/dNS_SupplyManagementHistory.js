import { LightningElement, api, wire, track } from 'lwc';
import { label } from 'c/commonUtils';
import GetChargingPartList from '@salesforce/apex/DN_SupplyManagementHistory.getChargingPartList';
import DeleteProduct from '@salesforce/apex/DN_SupplyManagementHistory.deletePMHistory';
import upsertRequestProduct from '@salesforce/apex/DN_SupplyManagementHistory.upsertRequestProduct';
import GetProductDetails from '@salesforce/apex/DN_SupplyManagementHistory.getProductDetails';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DNS_SupplyManagementHistory extends LightningElement {
    cLabel = label;
    @api recordId;
    @api objectApiName;
    @track curTableRow = 0;
    @track resultData = [];

    @track isSpinner = false;

    connectedCallback() {
        if(this.recordId){
            this.refreshList();
        }
    }

    // 행 추가
    addRowClick() {
        // 선택된 행이 있는지 확인
        const selectedRow = this.resultData.find(row => row.isChecked);
        let newEntry;
        if (selectedRow) {
            newEntry = {
                ...selectedRow,
                PartAmountNo: `PartAmount${Date.now()}`, // 품명
                ProductRequestRecordId: null,
                isChecked: true,
                isApproved: false,  // 승인됐는지 안됐는지, 됐으면 Disabled
                ProductUrl: selectedRow.ProductId ? '/lightning/r/Product2/' + selectedRow.ProductId + '/view?navRef=1' : null,
            };
        } else {
            newEntry = {
                EditMode: true,
                isChecked: true,
                isApproved: false,
                ProductCode: null,
                ProductId: '',
                ProductName: null,
                ProductUrl: null,
                PartAmount: null,   // 수량
                PartAmountNo: `PartAmount${Date.now()}`,    // 품명
                ProductRequestRecordId: null,
            };
        }

        if (this.resultData.length == 0) {
            this.resultData = [newEntry];
        } else {
            this.resultData = [...this.resultData, newEntry];
        }

        // 선택 상태 초기화
        // this.resultData = this.resultData.map(row => ({
        //     ...row,
        //     isChecked: false
        // }));
    }

    get resultDataWithDisabled() {
        return this.resultData.map(row => ({
            ...row,
        }));
    }

    // 선택 행 삭제
    deleteSelectedRows() {
        const selectedRows = this.resultData.filter(row => row.isChecked && !row.isApproved);
        if (selectedRows.length == 0) {
            this.showToast('알림', '삭제할 항목을 선택하십시오.', 'warning');
            return;
        }
        const deletePromises = selectedRows
            .filter(row => row.ProductRequestRecordId)
            .map(row => DeleteProduct({ recordId: row.ProductRequestRecordId }));
        if (deletePromises.length > 0) {
            Promise.all(deletePromises)
                .then(() => {
                    this.resultData = this.resultData.filter(row => !row.isChecked || row.isApproved);
                    this.showToast('성공', '선택한 항목들이 삭제되었습니다.', 'success');
                })
                .catch(error => {
                    console.error('Error deleting records:', error);
                    this.showToast('오류', '삭제 중 오류가 발생했습니다.', 'error');
                });
        } else {
            this.resultData = this.resultData.filter(row => !row.isChecked || row.isApproved);
            this.showToast('성공', '선택한 항목들이 삭제되었습니다.', 'success');
        }
    }

    // 행 전체 선택
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

    // 행 개별 선택
    checkCellClick(event) {
        const checkbox = event.target;
        const rowId = checkbox.dataset.id;
        const row = this.resultData.find(item => item.PartAmountNo === rowId);
        
        // 승인된 항목인 경우 체크 방지
        // if (row && row.isApproved) {
        //     event.preventDefault();
        //     checkbox.checked = false;
        //     return;
        // }
        
        // 현재 행의 체크 상태만 업데이트
        if (row) {
            row.isChecked = checkbox.checked;
        }
    }

    deleteLine(event) {
        const rowId = event.target.dataset.id;
        const rowIndex = this.resultData.findIndex(row => row.PartAmountNo == rowId);
        
        if (rowIndex !== -1) {
            const row = this.resultData[rowIndex];
            // if (row.isApproved) {
            //     this.showToast('경고', '승인된 행은 삭제할 수 없습니다.', 'warning');
            //     return;
            // }
            
            if (row.ProductRequestRecordId) {
                DeleteProduct({
                    recordId: row.ProductRequestRecordId
                })
                .then(() => {
                    this.resultData = this.resultData.filter((_, index) => index !== rowIndex);
                    // this.isSpindleDisabled = false;
                    this.showToast('성공', '선택한 행이 삭제되었습니다.', 'success');
                })
                .catch(error => {
                    console.error('Error deleting record:', error);
                    this.showToast('오류', '삭제 중 오류가 발생했습니다: ' + (error.body?.message || error.message || '알 수 없는 오류'), 'error');
                });
            } else {
                this.resultData = this.resultData.filter((_, index) => index !== rowIndex);
                // this.isSpindleDisabled = false;
                this.showToast('성공', '선택한 행이 삭제되었습니다.', 'success');
            }
        }
    }

    saveBtnClick() {
        // 체크된 행만 필터링
        const rowsToCHk = this.resultData.filter(row => row.isChecked === true);
        
        if (rowsToCHk.length == 0) {
            this.showToast('알림', '저장할 항목을 선택해주세요.', 'warning');
            return;
        }
        // 필수 필드 검증
        const invalidRows = rowsToCHk.filter(row => {
            const requiredFields = [!row.ProductId, !row.PartAmount];
            return requiredFields.some(field => field === true);
        });
        if (invalidRows.length > 0) {
            this.showToast('경고', '품명, 수량은 필수 입력 항목입니다.', 'warning');
            return;
        }

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
            };
        });

        console.log('Saving wrapper list:', JSON.stringify(wrapperList));
        this.isSpinner = true;
        
        //주석 나중에 다시 풀어야 함
        upsertRequestProduct({
            requestProductList: wrapperList,
            caseId : this.recordId
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

    showToast(title, message, variant = 'info') {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant // info, success, warning, error
        });
        this.dispatchEvent(evt);
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

    refreshList(){
        console.log('호출하기전에 한번');
        GetChargingPartList({caseId: this.recordId})
        .then(result => {
            console.log('GetChargingPartList ::: ', result);
            if (result.length == 0) {
                // this.addRowClick(); // 20250107 첫 화면 빈 줄 제외 요청
            } else {
                this.resultData = result.map((item, index) => {
                    // const isApproved = item.ProgressStatus === 'Approved';

                    return {
                        ...item,
                        PartAmountNo: 'PartAmount' + (index + 1),
                        PartNo: item.PartNo,
                        ProductCode: item.ProductCode,
                        ProductUrl: item.ProductId ? '/lightning/r/Product2/' + item.ProductId + '/view?navRef=1' : '',
                        EditMode: false
                        // EditMode: !isApproved,
                        // isApproved: isApproved,
                    };
                });
            }
            this.curTableRow = this.resultData.length;
            this.isSpinner = false;
        })
        .catch(error => {
            console.log('Error ::: ', error);
            this.isSpinner = false;
        });
    }

}