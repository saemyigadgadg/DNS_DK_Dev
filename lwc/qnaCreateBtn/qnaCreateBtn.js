/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 03-27-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-27-2025   youjin.shim@sbtglobal.com   Initial Version
**/
import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

const FIELDS = [
    'QnABoard__c.Parent__c', 'QnABoard__c.Title__c', 'QnABoard__c.Status__c'
];

export default class QnaCreateBtn extends NavigationMixin(LightningElement) {
    @api recordId;

    isLoading  = false;

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    record;

    renderedCallback() {
	    this.styleCss();    
	}
    
    get mHeader() {
        if (this.recordId) {
            return 'Answer';
        } else {
            return 'Question';
        }
    }

    get isNewMode() {
        return this.recordId ? false : true; 
    }

    get title() {
        return this.record.data ? this.record.data.fields.Title__c.value : '';
    }

    get parent() {
        console.log('  data --> ' + JSON.stringify(this.record.data) + ' error -->  ' + JSON.stringify(this.record.error) );
        if (this.record.data) {
            this.isLoading = false;
            // const f_parent = this.record.data.fields.Parent__c.value;
            // if (f_parent !== undefined && f_parent !== null) {
            //     console.log('Answer 2nd>>', f_parent);
            //     return f_parent;
            // } else {
            //     console.log('Answer 1st>>', this.recordId);
            //     return this.recordId;
            // }
            return this.recordId;
        } else {
            return '';
        }
    }

    get contents() {
        if (this.recordId) {
            return '';
        } else {
            return '*하기 내용을 기입하여 문의하면 신속한 대응이 가능 합니다.<br/>1) 기종/호기 :<br/><br/>2) 문의하고자 하는 부품의 사용 Unit :<br/><br/>3) 확인 가능한 품명, 사양, 제조사 정보 등 :<br/>(사진 등의 자료는 첨부파일로 저장)<br/><br/>4) 오더 번호 :<br/><br/>5) 품명/품번/수량 :<br/><br/>6) 고객의 장비 상태(장비다운) :<br/>(장비가 정지해 있는 경우에는 긴급으로 등록될 수 있도록 반드시 기록)';
        }
    }

    handleSubmit(event) {
        event.preventDefault();
        this.isLoading = true;
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        this.isLoading = false;
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Record saved Successfuly!',
            variant: 'success'
        });
        this.dispatchEvent(evt);

        this[NavigationMixin.Navigate]({
            'type': 'standard__recordPage',
            'attributes': {
                'recordId': event.detail.id,
                'objectApiName': 'QnABoard__c',
                'actionName': 'view'
            }
        }, true);
    }

    handleError(event) {
        this.isLoading = false;
        console.log('Error :', event.detail);
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Failed to save record.',
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }

    handleCancel() {
        console.log('call handleCancel');
        // window.history.back();
        if (this.recordId) {
            this.dispatchEvent( new CloseActionScreenEvent() );
        } else {
            this[NavigationMixin.Navigate]({
                'type': 'standard__objectPage',
                'attributes': {
                    'objectApiName': 'QnABoard__c',
                    'actionName': 'list'
                }
            }, true);
        }
    }

    styleCss() {
        const style = document.createElement('style');
		style.innerText = `
            c-qna-create-btn .slds-card {
                width: 70%;
                max-width: 1025px;
                min-width: 640px;
                margin: 0 auto;
            }
            c-qna-create-btn .slds-card .slds-card__header {
                display: none;
            }
            c-qna-create-btn .slds-card .slds-card__body {
                margin: 0;
            }
            c-qna-create-btn .slds-form-element_horizontal .slds-form-element__control {
                padding-left: calc((50% - 1rem)* 0.33);
            }
            c-qna-create-btn .slds-rich-text-editor__textarea:last-child .slds-rich-text-area__content {
                min-height: 20rem;
            }

            /*Answer*/
            .slds-modal__container:has(.status) {
                width: min-content;
                max-width: none;
            }
            .slds-card:has(.status) {
                width: 760px;
            }
        `;
		this.template.querySelector('lightning-card').appendChild(style);
    }
}