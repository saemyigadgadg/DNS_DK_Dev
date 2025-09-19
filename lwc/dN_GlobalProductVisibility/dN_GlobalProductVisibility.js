import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getGlobalProducts from '@salesforce/apex/DN_GlobalProductVisibilityController.getGlobalProducts';
import updateProducts from '@salesforce/apex/DN_GlobalProductVisibilityController.updateProducts';
import { refreshApex } from '@salesforce/apex';
import isCurrentUserAdmin from '@salesforce/apex/DN_GlobalProductVisibilityController.isCurrentUserAdmin';
import userId from '@salesforce/user/Id';



export default class dN_GlobalProductVisibility extends LightningElement {
    @track products = [];
    @track draftValues = [];
    @track searchKey = '';
    @track isAdminUser = false;
    columns = [];
   
    // 시스템 관리자 여부 확인 후 columns 구성
    connectedCallback() {
        isCurrentUserAdmin().then(result => {
            this.isAdminUser = result;
            //개발환경
            //const exceptionUsers = ['005F7000006CqEGIA0'];
            //운영환경
            const exceptionUsers = ['005TJ000004ec5tYAA'];
            
            if (this.isAdminUser && !exceptionUsers.includes(userId)) {
                // 시스템 어드민용 columns (3개 필드 모두 노출)
                this.columns = [
                    { label: '모델명', fieldName: 'modelName' },
                    { label: '제품명', fieldName: 'Name' },
                    { label: '상세설명', fieldName: 'Name__c' },
                    { label: 'Global 여부', fieldName: 'IsGlobal__c', type: 'boolean', editable: true },
                    { label: 'Korea 여부', fieldName: 'IsKorea__c', type: 'boolean', editable: true },
                    { label: '동남아 노출 여부', fieldName: 'IsSEADisplayed__c', type: 'boolean', editable: true }
                ];
            } else {
                // 글로벌 영업 담당자 사용자용 columns (동남아 노출 필드만 editable)
                this.columns = [
                    { label: '모델명', fieldName: 'modelName' },
                    { label: '제품명', fieldName: 'Name' },
                    { label: '상세설명', fieldName: 'Name__c' },
                    { label: '동남아 노출 여부', fieldName: 'IsSEADisplayed__c', type: 'boolean', editable: true }
                ];
            }
        }).catch(error => {
            console.error('관리자 여부 확인 실패:', error);
        });
    }

    get hasChanges() {
        return this.draftValues.length > 0;
    }

    @wire(getGlobalProducts, { searchKey: '$searchKey' })
    wiredProducts(result) {
        this.wiredResult = result;
        const { data, error } = result;
        if (data) {
            this.products = data.map(item => ({
            ...item,
            modelName: item.Model__r?.Name || ''
            //modelName: item.Model__r.Name ? item.Model__r.Name : ''
        }));
        } else if (error) {
            console.error('조회 오류:', error);
        }
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value;
    }

    handleSave(event) {
        const updatedFields = event.detail ? event.detail.draftValues : this.draftValues;

        //추가
        const updatedMap = new Map();
        updatedFields.forEach(update => updatedMap.set(update.Id, update));
        //추가
        this.products = this.products.map(row => {
            if (updatedMap.has(row.Id)) {
                return { ...row, ...updatedMap.get(row.Id) }; // 수정된 값 반영
            }
            return row;
        });

        updateProducts({ data: updatedFields })
            .then(() => {
                this.draftValues = [];
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '저장 완료',
                        message: '변경사항이 성공적으로 저장되었습니다.',
                        variant: 'success'
                    })
                );

                return refreshApex(this.wiredResult);
            })
            .catch(error => {
                console.error('저장 오류:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '저장 실패',
                        message: error.body?.message || '저장 중 오류가 발생했습니다.',
                        variant: 'error'
                    })
                );
            });
    }
}