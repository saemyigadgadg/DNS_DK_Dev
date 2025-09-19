/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-07-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-07-2025   youjin.shim@sbtglobal.com   Initial Version
**/
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { showToast, style, label } from 'c/commonUtils';
import { CloseActionScreenEvent } from 'lightning/actions';
import updateResult from '@salesforce/apex/DN_ModelManagerController.updateResult';
import getFailureAreaMajor from '@salesforce/apex/DN_ModelManagerController.getFailureAreaMajor';
import getFailureAreaMiddle from '@salesforce/apex/DN_ModelManagerController.getFailureAreaMiddle';
import getFailurePhenomenon from '@salesforce/apex/DN_ModelManagerController.getFailurePhenomenon';
import getFailureCause from '@salesforce/apex/DN_ModelManagerController.getFailureCause';
import getRepairAction from '@salesforce/apex/DN_ModelManagerController.getRepairAction';
import getServiceAppointment from '@salesforce/apex/DN_ModelManagerController.getServiceAppointment';
import getWorkOrder from '@salesforce/apex/DN_ModelManagerController.getWorkOrder';

export default class DN_InputWorkResultButton extends LightningElement {
    @track isLoading = false;
    @track isModalOpen = true;
    @track isDNSA = false;
    // @track picklistOptions = [];
    @track isSelectDisabled = true;
    @track isMiddleDisabled = true;
    @track isPhenomenonDisabled = true;
    @track isCauseDisabled = true;
    // @track isRepairDisabled = true;
    
    @track selectedFailureArea = '';
    @track selectedFailureAreaGroup = '';
    @track selectedFailurePhenomenon = '';
    @track selectedCauseOfFailure = '';
    @track selectedAction = '';
    @track pendingDetails = '';
    @api recordId;
    
    @api objectType; 
    @track options = []; 
    @track selectedValue = ''; 
    error;

    @track reportOptions = [];
    @track reportValue = '';
    @track majorOptions = [];
    @track majorLabel = '';
    @track middleOptions = [];
    @track middleLabel = '';
    @track phenomenonOptions = [];
    @track phenomenonLabel = '';
    @track causeOptions = [];
    @track causeLabel = '';
    @track repairOptions = [];
    @track repairLabel = '';
    @track editObject = {};

    @track machineDown = '';
    @track repairStart = '';
    @track repairEnd = '';


    // picklistOptions = [];
    reportOptions = [
        { label: 'Installation(I)', value: 'Installation(I)' },
        { label: 'Non-WRT(N)', value: 'Non-WRT(N)' },
        { label: 'Warranty(W)', value: 'Warranty(W)' },
        { label: 'Others(O)', value: 'Others(O)' },
    ];

    majorOptions = [];
    majorValue = '';
    majorLabel = '';
    middleOptions = [];
    middleValue = '';
    middleLabel = '';
    phenomenonOptions = [];
    phenomenonValue = '';
    phenomenonLabel = '';
    causeOptions = [];
    causeValue = '';
    causeLabel = '';
    repairOptions = [];
    repairValue = '';
    repairLabel = '';



    cLabel = label;

    // SLDS Styles
    renderedCallback() {
        this.styleCSS();
    }

    connectedCallback() {
        this.loadMajorPicklistOptions();
        this.loadGetWorkOrderResultValue();
        console.log('edit Object', JSON.stringify(this.editObject));
        // ServiceAppointment 조회
        getServiceAppointment({ saId: this.recordId})
            .then((result) => {
                if (result === 'IS_ORDERTYPE_FALSE') {
                    this.showToast(label.DNS_FSL_Alarm, label.DNS_FSL_OrderTypeNotSupportInputWorkResult, 'warning');
                    this.isModalOpen = false;
                    // this.isCompletionModalOpen = true;
                }  
            })
            .catch((error) => {
                console.error('faile get value: ', error);
                // this.showToast('Error', '값 저장 중 오류가 발생했습니다.', 'error');
            });
    }

    loadGetWorkOrderResultValue() {
        this.isLoading = true;
        getWorkOrder({ saId: this.recordId })
            .then((result) => {
                console.log('WorkOrderResult:::', result);

                this.isDNSA = result.RecordType?.Name === 'WorkOrder(DNSA)';
                this.reportValue = result.Report_Type__c;
                this.machineDown = result.isMachineDown__c;
                this.repairStart = result.RepairStartDate__c;
                this.repairEnd = result.RepairEndDate__c;

                this.isMiddleDisabled = !(result && result.FailureAreaValue__c);
                this.isPhenomenonDisabled = !(result && result.FailureAreaGroupValue__c);
                this.isCauseDisabled = !(result && result.FailurePhenomenonValue__c);

                this.majorValue = result.FailureAreaValue__c;
                this.middleValue = result.FailureAreaGroupValue__c;
                this.phenomenonValue = result.FailurePhenomenonValue__c;
                this.causeValue = result.CauseOfFailureValue__c;
                this.repairValue = result.RepairActionValue__c;
                // 고장부위(대)
                getFailureAreaMajor({ saId: this.recordId })
                .then((result) => {
                    this.majorOptions = result;
                    // value = result;
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.majorOptions = [];
                });
                // 고장부위(중)
                if (!this.isMiddleDisabled) {
                    getFailureAreaMiddle({
                        majorValue : this.majorValue
                    }).then(result => {
                        this.middleOptions = result;
                    });
                }
                // 고장현상
                if (!this.isPhenomenonDisabled) {
                    // this.majorValue = result.FailureAreaValue__c;
                    // this.middleValue = result.FailureAreaGroupValue__c;
                    // const phenomenonValue = `${majorValue}${middleValue}`;
                    // this.phenomenonValue = majorValue + middleValue;
                    // console.log('phenomenonValue:::', phenomenonValue);
                    getFailurePhenomenon({
                        middleValue : this.majorValue + this.middleValue
                    }).then(result => {
                        this.phenomenonOptions = result;
                    });
                }
                // 고장원인
                if (!this.isCauseDisabled) {
                    // this.majorValue = result.FailureAreaValue__c;
                    // this.middleValue = result.FailureAreaGroupValue__c;
                    // this.phenomenonValue = result.FailurePhenomenonValue__c;
                    // const causeValue = `${majorValue}${middleValue}${phenomenonValue}`;
                    // const causeValue = '';
                    // console.log('causeValue:::', causeValue);
                    getFailureCause({
                        phenomenonValue : this.majorValue + this.middleValue + this.phenomenonValue
                    }).then(result => {
                        this.causeOptions = result;
                    });
                }
                // 조치내역
                getRepairAction({ saId: this.recordId })
                .then((result) => {
                    this.repairOptions = result;
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.repairOptions = [];
                });

                if (result) {
                    console.log('result.FailureAreaValue__c:::'+result.FailureAreaValue__c);
    
                    this.editObject = {
                        FailureAreaValue__c: result.FailureAreaValue__c ? result.FailureAreaValue__c : '',
                        FailureAreaGroupValue__c: result.FailureAreaGroupValue__c ? result.FailureAreaGroupValue__c : '',
                        FailurePhenomenonValue__c: result.FailurePhenomenonValue__c ? result.FailurePhenomenonValue__c : '',
                        CauseOfFailureValue__c: result.CauseOfFailureValue__c ? result.CauseOfFailureValue__c : '',
                        RepairActionValue__c: result.RepairActionValue__c ? result.RepairActionValue__c : '',
                        PendingOrCustomerMatters__c: result.PendingOrCustomerMatters__c ? result.PendingOrCustomerMatters__c : '',
                        FailurePhenomenonDetail__c: result.FailurePhenomenonDetail__c ? result.FailurePhenomenonDetail__c : '',
                        CauseOfFailureDetail__c: result.CauseOfFailureDetail__c ? result.CauseOfFailureDetail__c : '',
                    };
                    console.log('edit Object3', JSON.stringify(this.editObject));
                } else {
                    this.editObject = {
                        FailureAreaValue__c: '',
                        FailureAreaGroupValue__c: '',
                        FailurePhenomenonValue__c: '',
                        CauseOfFailureValue__c: '',
                        RepairActionValue__c: '',
                        PendingOrCustomerMatters__c: '',
                        FailurePhenomenonDetail__c: '',
                        CauseOfFailureDetail__c: '',
                    };
                }
            })
            .catch((error) => {
                console.error('Error fetching WorkOrderResult: ', error);
                // this.showToast('오류', '작업 결과 조회 중 오류가 발생했습니다.', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
            console.log('edit Object2', JSON.stringify(this.editObject)
        );
    }
    
    loadMajorPicklistOptions() {
        getFailureAreaMajor({ saId: this.recordId })
        .then((result) => {
                console.log('result:::'+result);
                this.majorOptions = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.majorOptions = [];
            });

        getRepairAction({ saId: this.recordId })
            .then((result) => {
                this.repairOptions = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.repairOptions = [];
            });
    }

    handleFailureAreaMajorChange(event) {
        var name = event.target.name;
        var value = event.target.value;
        if (name === 'failureAreaMajor') {
            this.majorValue = value;
            this.middleValue = '';
            this.phenomenonValue = '';
            this.causeValue = '';
            this.isMiddleDisabled = true;
            this.isPhenomenonDisabled = true;
            this.isCauseDisabled = true;
            var majorLabelOptions = this.majorOptions.find(option => option.value === this.majorValue);
            this.majorLabel = majorLabelOptions.label;
            this.editObject = { ...this.editObject, [name]: {'label' : this.majorLabel, 'value' : this.majorValue}};
            this.middleOptions = [];
            console.log('majorLabelOptions.label:::'+majorLabelOptions.label);
            getFailureAreaMiddle({ majorValue: this.majorValue })
                .then((result) => {
                    console.log('result:::'+JSON.stringify(result));
                    this.middleOptions = result;
                    this.isMiddleDisabled = false;
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.middleOptions = [];
                    this.isMiddleDisabled = true;
                });
        }
    }
    handleFailureAreaMiddleChange(event) {
        var name = event.target.name;
        var value = event.target.value;
        // this.middleValue = value;
        if (name === 'failureAreaMiddle') {
            this.middleValue = value;
            this.phenomenonValue = '';
            this.causeValue = '';
            this.isPhenomenonDisabled = true;
            this.isCauseDisabled = true;
            // const majorValue = this.editObject.failureAreaMajor.value;
            // const middleValue = this.majorValue + this.middleValue; // majorValue + middleValue 조합
            // console.log('majorValue:::', majorValue);
            // console.log('middleValue:::', middleValue);
            var middleLabelOptions = this.middleOptions.find(option => option.value === this.middleValue);
            this.middleLabel = middleLabelOptions.label;
            this.editObject = { ...this.editObject, [name]: {'label' : this.middleLabel, 'value' : this.middleValue}};
            this.phenomenonOptions = [];
            console.log('middleLabelOptions.label:::'+middleLabelOptions.label);
            var key = this.majorValue + this.middleValue;
            getFailurePhenomenon({ middleValue: key })
                .then((result) => {
                    this.phenomenonOptions = result;
                    this.isPhenomenonDisabled = false;
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.phenomenonOptions = [];
                    this.isPhenomenonDisabled = true;
                });
        }
    } 
    handleFailurePhenomenonChange(event) {
        var name = event.target.name;
        var value = event.target.value;
        // this.phenomenonValue = value;
        if (name === 'failurePhenomenon') {
            this.phenomenonValue = value;
            this.causeValue = '';
            this.isCauseDisabled = true;
            // const majorValue = this.editObject.failureAreaMajor.value;
            // const middleValue = this.editObject.failureAreaMiddle.value;
            // const phenomenonValue = `${majorValue}${middleValue}${value}`;
            var phenomenonLabelOptions = this.phenomenonOptions.find(option => option.value === this.phenomenonValue);
            this.phenomenonLabel = phenomenonLabelOptions.label;
            this.editObject = { ...this.editObject, [name]: {'label' : this.phenomenonLabel, 'value' : this.phenomenonValue}};
            var phenomenonKey = this.majorValue + this.middleValue + this.phenomenonValue;

            console.log('phenomenonLabelOptions.label:::'+phenomenonLabelOptions.label);
            // console.log('middleValue:::', middleValue);
            // console.log('phenomenonValue:::', phenomenonValue);

            this.causeOptions = [];
            getFailureCause({ phenomenonValue: phenomenonKey})
                .then((result) => {
                    console.log('result:::', JSON.stringify(result)); 
                    
                    this.causeOptions = result;
                    this.isCauseDisabled = false;
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.causeOptions = [];
                    this.isCauseDisabled = true;
                });
        }
    }
    
    handleReportTypeChange(event) {
        this.reportValue = event.target.value;
        // var name = event.target.name;
        // var value = event.target.value;
        // this.reportValue = value;

        // var reportOptions = this.reportOptions.find(option => option.value === this.reportValue);
        // this.reportLabel = reportOptions.label;
        // this.editObject = { ...this.editObject, [name]: {'label' : this.reportLabel, 'value' : this.reportValue}};
    }

    handleCheckboxChange(event) {
        const { name, checked } = event.target;
        if (name === 'machineDown') {
            this.machineDown = checked;
        }
    }
    
    handleInputChange(event) {
        const { name, value } = event.target;
        if (name === 'repairStart') {
            this.repairStart = value;
        } else if (name === 'repairEnd') {
            this.repairEnd = value;
        }
    }
    

    handleFailureCauseChange(event) {
        var name = event.target.name;
        var value = event.target.value;
        this.causeValue = value;

        var causeLabelOptions = this.causeOptions.find(option => option.value === this.causeValue);
        this.causeLabel = causeLabelOptions.label;
        this.editObject = { ...this.editObject, [name]: {'label' : this.causeLabel, 'value' : this.causeValue}};
    }

    handleRepairActionChange(event) {
        var name = event.target.name;
        var value = event.target.value;
        this.repairValue = value;

        var repairOptions = this.repairOptions.find(option => option.value === this.repairValue);
        this.repairLabel = repairOptions.label;
        this.editObject = { ...this.editObject, [name]: {'label' : this.repairLabel, 'value' : this.repairValue}};
    }

    handlePicklistChange(event) {
        const name = event.target.name;
        const value = event.target.value;
    
        this.editObject = { ...this.editObject, [name]: value };
    }

    handleTextareaFocus() {
        const container = this.template.querySelector('.scroll-container');
        const textarea = event.target;
        const offsetTop = textarea.offsetTop;

        const userAgent = navigator.userAgent;
        const specificModels = ['SM-S931', 'SM-S936', 'SM-S938'];
        const isSpecificModel = specificModels.some(model => userAgent.includes(model));

        container.classList.remove('keyboard-open', 'keyboard-open-two');
        
        if (isSpecificModel) {
            container.classList.add('keyboard-open');
        } else {
            container.classList.add('keyboard-open-two');
        }

        setTimeout(() => {
            container.scrollTo({
                top: offsetTop,
                behavior: 'smooth'
            });
        }, 300);
    }

    handleTextareaBlur() {
        const container = this.template.querySelector('.scroll-container');
        container.classList.remove('keyboard-open', 'keyboard-open-two');
    }
    

    disconnectedCallback() {
        window.removeEventListener('resize', this.setVh);
    }

    handleUpdate() {
        console.log('recordId:::' + this.recordId);
        this.isLoading = true;
        console.log('saveObject1:::', JSON.stringify(this.editObject));

        if (this.editObject.failureAreaMajor == null) {
            var value = this.editObject.FailureAreaValue__c;
            var label = this.majorOptions.find(option => option.value === value).label;
            this.editObject['failureAreaMajor'] = { "label" : label, "value" : value};
        }
        if (this.editObject.failureAreaMiddle == null) {
            var value = this.editObject.FailureAreaGroupValue__c;
            var label = this.middleOptions.find(option => option.value === value).label;
            this.editObject['failureAreaMiddle'] = { "label" : label, "value" : value};
        }
        if (this.editObject.failurePhenomenon == null) {
            var value = this.editObject.FailurePhenomenonValue__c;
            var label = this.phenomenonOptions.find(option => option.value === value).label;
            this.editObject['failurePhenomenon'] = { "label" : label, "value" : value};
        }
        if (this.editObject.failureCause == null) {
            var value = this.editObject.CauseOfFailureValue__c;
            var label = this.causeOptions.find(option => option.value === value).label;
            this.editObject['failureCause'] = { "label" : label, "value" : value};
        }
        if (this.editObject.repairAction == null) {
            var value = this.editObject.RepairActionValue__c;
            var label = this.repairOptions.find(option => option.value === value).label;
            this.editObject['repairAction'] = { "label" : label, "value" : value};
        }
        if (this.editObject.failurePhenomenonDetail == null) {
            this.editObject['failurePhenomenonDetail'] = this.editObject.FailurePhenomenonDetail__c;
        }
        if (this.editObject.causeOfFailureDetail == null) {
            this.editObject['causeOfFailureDetail'] = this.editObject.CauseOfFailureDetail__c;
        }
        if (this.editObject.pendingOrCustomerMatters == null) {
            this.editObject['pendingOrCustomerMatters'] = this.editObject.PendingOrCustomerMatters__c;
        }
        console.log('saveObject2:::', JSON.stringify(this.editObject));
        
        updateResult({
            saId: this.recordId,
            saveObject: JSON.stringify(this.editObject),
            reportValue: this.reportValue,
            machineDown: this.machineDown,
            repairStart: this.repairStart,
            repairEnd: this.repairEnd
        }).then((result) => {
                if (result === 'IS_PENDING_PROCESS_TRUE') {
                    this.showToast('Error', label.DNS_FSL_DispatchPendingProcessed, 'error');
                    this.isModalOpen = false;
                } else if (result === 'IS_CONFIRM_TRUE') {
                    this.showToast('Error', label.DNS_FSL_AlreadyConfirmed, 'error');
                    // this.isModalOpen = false;
                } else if (result === 'SUCCESS') {
                    this.isModalOpen = false;
                    this.isCompletionModalOpen = true;
                    this.showToast('Success', label.DNS_FSL_InputWorkResultSuccessful, 'success');
                } else {
                    this.showToast('Error', label.DNS_FSL_SavingValue, 'error');
                }   
            })
            .catch((error) => {
                console.error('Error saving value: ', error);
                this.showToast('Error', label.DNS_FSL_SavingValue, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    closeCompletionModal() {
        this.isCompletionModalOpen = false;
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    closeModal() {
        this.isModalOpen = false;
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

    // Mobile Height Compatibility

    setVh() {
        const vh = window.innerHeight * 0.01;
        document.documentElement.style.setProperty('--vh', `${vh}px`);
    }

    styleCSS() {
        const style = document.createElement('style');
        style.innerText = `
        .total-wrap .icon-wrap .slds-icon{fill: #0176D3 !important;}
        .total-wrap .input-wrap .slds-textarea{
            height: 6rem;
            border: 1px solid #aeaeae;
            font-size: 18px;
            padding: 0.75rem 1rem;
        }
        .total-wrap .input-wrap .slds-input_faux {
            padding: 0.5rem 1.25rem;
        }
        .total-wrap .input-wrap .slds-form-element__label {
            font-size: 1rem;
        }
        .total-wrap .input-wrap.date .slds-input {
            min-height: 3rem !important;
        }

        `;
        this.template.querySelector('.total-wrap').appendChild(style);
    }
}