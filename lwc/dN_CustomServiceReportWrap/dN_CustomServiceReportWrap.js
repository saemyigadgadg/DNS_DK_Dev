/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-03-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-02-2025   youjin.shim@sbtglobal.com   Initial Version
**/
import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import saveServiceSignatures from '@salesforce/apex/SignatureContainerController.saveSignatureNew';
import generatePDF from '@salesforce/apex/DN_CustomServiceReportController.saveServiceSignatures';
import { CloseActionScreenEvent } from 'lightning/actions';
import SIGNATURE_LIB from '@salesforce/resourceUrl/Signature';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class DN_CustomServiceReportWrap extends LightningElement {
    @api recordId;
    engiPad;
    custPad;
    signaturePadLoaded = false;
    isSaving = false;
    @track
    engineerName = '';
    @track
    customerName = '';
    @track
    isLoading    = true;
      
    renderedCallback() {
        if (this.signaturePadLoaded) return;
    
        Promise.all([
            loadScript(this, SIGNATURE_LIB + '/signature_pad.min.js')
        ]).then(() => {
            const engiCanvas = this.template.querySelector('[data-id="engiSign"]');
            const custCanvas = this.template.querySelector('[data-id="custSign"]');
            console.log('engiCanvas :: ' ,engiCanvas);
            console.log('custCanvas :: ' ,custCanvas);
            if (engiCanvas && custCanvas) {
                this.engiPad = new SignaturePad(engiCanvas);
                this.custPad = new SignaturePad(custCanvas);
                this.signaturePadLoaded = true;
                this.isLoading = false;
            } else {
                console.error('🛑 Canvas elements not found.');
            }
        }).catch(error => {
            console.error('🛑 SignaturePad Loading Failed:', error);
            this.isLoading = false;
        });

        this.styleCSS();
    }
    
    async handleSave() {
        if (!this.engiPad || !this.custPad) {
            this.showToast('Signature Error', 'Signature Not Recognized', 'error');
            return;
        }
    
        if (this.engiPad.isEmpty() || this.custPad.isEmpty()) {
            this.showToast('Signature Missing', 'Please enter all required signatures', 'warning');
            return;
        }
    
        let engiSignature = this.engiPad.toDataURL();
        let custSignature = this.custPad.toDataURL();
        console.log('engiSignature :: ' ,engiSignature);
        console.log('engiSignature :: ' , typeof(engiSignature));
        console.log('custSignature :: ' ,custSignature);
        
        engiSignature = engiSignature.replace(/^data:image\/[^;]+;base64,/, "");
        custSignature = custSignature.replace(/^data:image\/[^;]+;base64,/, "");
        let engineerName = this.engineerName;
        let customerName = this.customerName;
        this.isSaving = true;
        this.isLoading = true;
        console.log('isLoading:', this.isLoading);
        console.log('engineer :: ' , engineerName);
        console.log('customerName :: ' , customerName);
        // {workOrderId: this.recordId,engiSignData: engiSignature,custSignData: custSignature,engineerName: engineerName,customerName: customerName}
        
        try {            
            saveServiceSignatures({signatureBody:engiSignature, parentId:this.recordId, signatureType:'Engineer-FSL'})
            .then(result => {
                console.log();
                
                if(result){
                    saveServiceSignatures({signatureBody:custSignature, parentId:this.recordId, signatureType:'Customer-FSL'})
                    .then(result => {
                        if(result){
                            generatePDF({workOrderId: this.recordId,engineerName: engineerName,customerName: customerName})
                            .then(result => {
                                console.log('result ::; ' ,result);                                
                                this.showToast('SUCCESS', 'Service Report has been saved', 'success');
                                setTimeout(() => {
                                    this.dispatchEvent(new CloseActionScreenEvent());
                                }, 500);
                            }).catch(error => {
                                console.log(error);
                                
                            })
                            
                        }else{
                            this.showToast('Save Failed', 'An issue occurred while saving the customer’s signature', 'error');
                        }
                    })
                }else{
                    this.showToast('Save Failed', 'An issue occurred while saving the engineer’s signature', 'error');
                }
            });
    
            // this.showToast('성공', '서명이 저장되었습니다.', 'success');
    
            
        } catch (error) {
            this.showToast('Save Failed', 'An issue occurred while saving the signature', 'error');
        } finally {
            this.isSaving = false;
            // this.isLoading = false;
        }
    }
    
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: 'dismissable'
            })
        );
    }

    clearEngiSignature() {
        if (this.engiPad) {
            this.engiPad.clear();
        }
    }
      
    clearCustSignature() {
        if (this.custPad) {
            this.custPad.clear();
        }
    }
    handleEngieerNameChange(event) {
        this.engineerName = event.target.value;
    }
    handleCustomerNameChange(event){
        this.customerName = event.target.value;
    }

    styleCSS() {
        const style = document.createElement('style');
        style.innerText = `
            .field-wrap .input-wrap:has(canvas) {
                display: flex;
                flex-direction: column;
                align-items: flex-start;
                gap: 0.5rem;
            }
            .field-wrap .input-wrap canvas {
                border: 1px solid #444444;
            }
            .field-wrap .input-wrap lightning-button {
                margin-left: 0;
            }

            .field-wrap .input-wrap .slds-form-element__label {
                display: none;
            }

            .wrapper .btn-wrap {
                text-align: right;
                margin-top: 1rem;
            }
        `;
        this.template.querySelector('lightning-card').appendChild(style);
      }
}