import { LightningElement, api,wire } from 'lwc';
//Apex 
import getParts from '@salesforce/apex/DN_AgencyPopupResMultiPartController.getParts';
import getStorege from '@salesforce/apex/DN_AgencyPopupResMultiPartController.getStorege';
import getEquipmentInfo from '@salesforce/apex/DN_AgencyPopupResMultiPartController.equipmentInfo';
import getMachineInfo from '@salesforce/apex/DN_AgencyPopupResMultiPartController.machineInfo';
//LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';

export default class DN_DealerPortalInputBox extends LightningElement {
    @api filter
    @api inputvalue = '';
    @api uuid;
    @api isValue = false;
    @api isReq = false;
    // 테이블에서 사용하는 경우 사용
    @api istable = false;
    @api tableIndex;
    isEnter = false;
    
    /**
     * LMC
     */
    @wire(MessageContext)
    messageContext;
    
    /**
     * publish 
     * 
     */
    messagePublish(eventType,msg,cmpName) {
        let messagePush = {
            uuid : this.uuid,
            type : eventType,
            message : msg,
            cmpName : cmpName
        }
        ////console.log(JSON.stringify(messagePush), ' BUTTON MESSAGE');
        publish(this.messageContext, DealerPortalLMC, messagePush);
      }
    
    handleChange(event) {
        //2025-03-19 소문자 > 대문자로 강제 변환 (제품 코드만)
        if(event.target.value && this.filter.fieldApiName =='productCode') event.target.value = event.target.value.toUpperCase();
        if(event.target.value && this.filter.fieldApiName =='SerialNumber') event.target.value = event.target.value.toUpperCase();
        if(event.target.value && this.filter.fieldApiName =='Type') event.target.value = event.target.value.toUpperCase();
        if(event.target.value && this.filter.fieldApiName =='location') event.target.value = event.target.value.toUpperCase();
        const value = event.target.value.split(',').map(item => item.trim());
        //console.log(JSON.stringify(value),' :: value');
        //console.log(value.join(','),'::value.join(',')');
        event.target.value = value.join(',');
        this.setvalue(value,'input');
    }
    handleInput(event) {
        const value = event.target.value.split(',').map(item => item.trim());
        this.setvalue(value,'input');
        
    } 

    // setValue
    setvalue(value, eventType) {
        // 부품
        if(this.filter.fieldApiName =='productCode') {
            this.handlePart(value,eventType);
        }
        //저장위치
        if(this.filter.fieldApiName=='location') {
            this.handleStorege(value,eventType);
        }
        // 장비번호
        if(this.filter.fieldApiName=='SerialNumber') {
            this.handleEquipmentInfo(value,eventType);
        }
        //기종
        if(this.filter.fieldApiName=='Type') {
            this.handleMachineInfo(value,eventType);
        }
    }

    // 기종
    handleMachineInfo(value,eventType) {
        //return new Promise((resolve, reject) => {
            //console.log(value,' :: value');
            getMachineInfo({
                machineName : value
            }).then( result => {
                //console.log(JSON.stringify(result),' :: result');
                let label = [];
                let values = [];
                result.forEach(element => {
                    label.push(element.label);
                    values.push(element.value);
                    //console.log(element.label,' :: 11');
                });
                let labelSet = label.length ==0 ? value.join(',') : label.join(',');
                let valueSet = values.length ==0 ? '' : values.join(',');
                this.inputvalue = valueSet;
                if(valueSet =='') {
                    if(labelSet !='') {
                        this.inputvalue = undefined;
                    } else {
                        this.inputvalue ='';
                    }
                }
                if(!this.istable) {
                    if(eventType=='ENTER') {
                        this.messagePublish('SeachFilter',{"param":""},'dN_DealerPortalButton');
                    } else {
                        const customEvent = new CustomEvent('inputchange', {
                            detail: { 
                                'eventType' :eventType,
                                'field' : this.filter.fieldApiName,
                                'value' : valueSet,
                                'label' : labelSet,
                                'type' : this.filter.fieldType
                            },
                            bubbles: true,
                            composed: true
                        });    
                        this.dispatchEvent(customEvent); // 이벤트 발생   
                    }
                } else {
                    //console.log(this.tableIndex,' index');
                    const customEvent = new CustomEvent('inputchange', {
                        detail: { 
                            'eventType' :eventType,
                            'field' : this.filter.fieldApiName,
                            'value' : valueSet,
                            'label' : labelSet,
                            'type' : this.filter.fieldType,
                            'index' : this.tableIndex
                        },
                        bubbles: true,
                        composed: true
                    });
                    //console.log()
                    this.dispatchEvent(customEvent); // 이벤트 발생 
                }
                //resolve();
            }).catch(error => {
                //reject();
                //console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
            });
        //});    
    }



    // 장비번호
    handleEquipmentInfo(value, eventType) {
        //return new Promise((resolve, reject) => {
            getEquipmentInfo({
                mn : value
            }).then( result => {
                //console.log(JSON.stringify(result),' :: result');
                let label = [];
                let values = [];
                result.forEach(element => {
                    label.push(element.label);
                    values.push(element.value);
                    //console.log(element.label,' :: 11');
                });
                let labelSet = label.length ==0 ? value.join(',') : label.join(',');
                let valueSet = values.length ==0 ? '' : values.join(',');
                this.inputvalue = valueSet;
                if(valueSet =='') {
                    if(labelSet !='') {
                        this.inputvalue = undefined;
                    } else {
                        this.inputvalue ='';
                    }
                }
                if(!this.istable) {
                    if(eventType=='ENTER') {
                        this.messagePublish('SeachFilter',{"param":""},'dN_DealerPortalButton');
                    } else {
                        const customEvent = new CustomEvent('inputchange', {
                            detail: { 
                                'eventType' :eventType,
                                'field' : this.filter.fieldApiName,
                                'value' : valueSet,
                                'label' : labelSet,
                                'type' : this.filter.fieldType
                            },
                            bubbles: true,
                            composed: true
                        });    
                        this.dispatchEvent(customEvent); // 이벤트 발생   
                    }
                } else {
                    //console.log(this.tableIndex,' index');
                    const customEvent = new CustomEvent('inputchange', {
                        detail: { 
                            'eventType' :eventType,
                            'field' : this.filter.fieldApiName,
                            'value' : valueSet,
                            'label' : labelSet,
                            'type' : this.filter.fieldType,
                            'index' : this.tableIndex
                        },
                        bubbles: true,
                        composed: true
                    });
                    //console.log()
                    this.dispatchEvent(customEvent); // 이벤트 발생 
                }
                //resolve();
                //resolve();
            }).catch(error => {
                //reject();
                //console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
            });
        // });    
    }


    handleStorege(value,eventType) {
        //return new Promise((resolve, reject) => {
            getStorege({
                binSearch : value
            }).then( result => {
                //console.log(JSON.stringify(result),' :: result');
                let label = [];
                let values = [];
                result.forEach(element => {
                    label.push(element.label);
                    values.push(element.value);
                    //console.log(element.label,' :: 11');
                });
                let labelSet = label.length ==0 ? value.join(',') : label.join(',');
                let valueSet = values.length ==0 ? '' : values.join(',');
                this.inputvalue = valueSet;
                if(valueSet =='') {
                    if(labelSet !='') {
                        this.inputvalue = undefined;
                    } else {
                        this.inputvalue ='';
                    }
                }
                if(!this.istable) {
                    if(eventType=='ENTER') {
                        this.messagePublish('SeachFilter',{"param":""},'dN_DealerPortalButton');
                    } else {
                        const customEvent = new CustomEvent('inputchange', {
                            detail: { 
                                'eventType' :eventType,
                                'field' : this.filter.fieldApiName,
                                'value' : valueSet,
                                'label' : labelSet,
                                'type' : this.filter.fieldType
                            },
                            bubbles: true,
                            composed: true
                        });    
                        this.dispatchEvent(customEvent); // 이벤트 발생   
                    }
                } else {
                    //console.log(this.tableIndex,' index');
                    const customEvent = new CustomEvent('inputchange', {
                        detail: { 
                            'eventType' :eventType,
                            'field' : this.filter.fieldApiName,
                            'value' : valueSet,
                            'label' : labelSet,
                            'type' : this.filter.fieldType,
                            'index' : this.tableIndex
                        },
                        bubbles: true,
                        composed: true
                    });
                    //console.log()
                    this.dispatchEvent(customEvent); // 이벤트 발생 
                }
                //resolve();
            }).catch(error => {
                //reject();
                //console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
            });
        //})
    }

    handlePart(value, eventType) {
        //return new Promise((resolve, reject) => {
            getParts({
                partSearch : value
              }).then( result => {
                //console.log(JSON.stringify(result),' :: result');
                let label = [];
                let values = [];
                result.forEach(element => {
                    label.push(element.label);
                    values.push(element.value);
                    //console.log(element.label,' :: 11');
                });
                let labelSet = label.length ==0 ? value.join(',') : label.join(',');
                let valueSet = values.length ==0 ? '' : values.join(',');
                this.inputvalue = valueSet;
                if(valueSet =='') {
                    if(labelSet !='') {
                        this.inputvalue = undefined;
                    } else {
                        this.inputvalue ='';
                    }
                }
                
                if(!this.istable) {
                    if(eventType=='ENTER') {
                        this.messagePublish('SeachFilter',{"param":""},'dN_DealerPortalButton');
                    } else {
                        const customEvent = new CustomEvent('inputchange', {
                            detail: { 
                                'eventType' :eventType,
                                'field' : this.filter.fieldApiName,
                                'value' : valueSet,
                                'label' : labelSet,
                                'type' : this.filter.fieldType
                            },
                            bubbles: true,
                            composed: true
                        });    
                        this.dispatchEvent(customEvent); // 이벤트 발생   
                    }
                } else {
                    //console.log(this.tableIndex,' index');
                    const customEvent = new CustomEvent('inputchange', {
                        detail: { 
                            'eventType' :eventType,
                            'field' : this.filter.fieldApiName,
                            'value' : valueSet,
                            'label' : labelSet,
                            'type' : this.filter.fieldType,
                            'index' : this.tableIndex
                        },
                        bubbles: true,
                        composed: true
                    });
                    console.log('dispatching event: ', customEvent);
                    //console.log()
                    this.dispatchEvent(customEvent); // 이벤트 발생 
                }
                //resolve();
            }).catch(error => {
                //reject();
                //console.log(JSON.stringify(error), ' dN_AgencyCustomerOrderManagementTable error');
            });       
        //})
        
    }

    // 룩업필드의 경우 인풋데이터 삭제
    @api
    handleClear() {
        this.template.querySelector(`[data-id="${this.filter.fieldApiName}"]`).value ='';
        this.isValue = false;
        //console.log(this.template.querySelector(`[data-id="${filter.fieldApiName}"]`).value,' test1111');
        if(!this.istable){
            // Aura에서 받을 수 있도록 composed: true 설정
            const customEvent = new CustomEvent('inputchange', {
                detail: { 
                    'field' : this.filter.fieldApiName,
                    'value' : '',
                    'type' : this.filter.fieldType
                    },
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(customEvent); // 이벤트 발생
        }
        
    }

    @api
    handleBlur() {
        this.template.querySelector(`[data-id="${this.filter.fieldApiName}"]`).blur();
    }

    // 모달창에서 받은 데이터 매핑
    @api
    handleCmpValue(value) {
        //console.log(value,' :: value');
        this.template.querySelector(`[data-id="${this.filter.fieldApiName}"]`).value =value;
        //console.log(this.template.querySelector(`[data-id="${this.filter.fieldApiName}"]`).value,' input value');
    }

    @api
    getInputValue() {
        return this.template.querySelector(`[data-id="${this.filter.fieldApiName}"]`).value;
    }


    @api
    handleVal() {
        let element = this.template.querySelector(`[data-id="${this.filter.fieldApiName}"]`);
        element.reportValidity();
    }

    @api
    handleValRemove() {
        let element = this.template.querySelector(`[data-id="${this.filter.fieldApiName}"]`);
        this.setErrorCssRemove(element, this.filter.fieldApiName);
    }

    setErrorCss(element, fieldApiName) {
        //console.log(element.id,' ::: element.id');
        if(element.id =='') {
            element.classList.add('slds-has-error');
            element.setAttribute('Id', fieldApiName);
            let errorMessage = document.createElement('div');
            errorMessage.setAttribute('Id', fieldApiName);
            errorMessage.className = 'slds-form-element__help';
            errorMessage.innerText = '이 필드를 완료하십시오.';
            element.appendChild(errorMessage); 
        } 
    }

    setErrorCssRemove(element, fieldApiName) {
        element.classList.remove('slds-has-error');
        element.removeAttribute('id');
        let errorMessages = document.querySelectorAll('.slds-form-element__help');
        errorMessages.forEach(errorMessage => {
            if(errorMessage.id == fieldApiName) {
            errorMessage.remove();
            }
        });
    }

    // 엔터키 누를경우
    handleKeydown(event) {
        if(this.isEnter) {
            return;
        }
        
        if (event.key === 'Enter' && !event.repeat) {
            this.isEnter = true;
            if(this.istable) {
                this.setvalue([event.target.value.trim()],'ENTER');
            } else {
                const value = event.target.value.split(',').map(item => item.trim());
                this.setvalue(value,'ENTER');
            }
        }             
        setTimeout(() => {
            this.isEnter = false;
        }, 500);
    
    }

    handleKeyUp(event) {
        if(this.isEnter) {
            return;
        }
        if (event.key === 'Enter' && !event.repeat) {
            //console.log(event.target.value,' :: event.target.value');
            this.isEnter = true;
            if(this.istable) {
                this.setvalue([event.target.value.trim()],'ENTER');
            } else {
                const value = event.target.value.split(',').map(item => item.trim());
                this.setvalue(value,'ENTER');
            }
            
            setTimeout(() => {
                this.isEnter = false;
            }, 500);
        }    
    }
}