import { LightningElement, track, api,wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

//LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
//Apex 
import getSearchList from '@salesforce/apex/DN_DealerPortalDisplayController.getSearchList';
import getSearchPicList from '@salesforce/apex/DN_DealerPortalDisplayController.getSearchPicList';
import { publish, MessageContext, subscribe} from 'lightning/messageService';
export default class DN_DealerPortalFilter extends LightningElement {
    
    @api uuid;
  
    @track _filterList=[];
    isFilterInit = false;
    
    /**
     * LMC
     */
    @wire(MessageContext)
    messageContext;
    subscription = null;
    // startValue = new Date().toISOString();
    // endValue = new Date().toISOString();
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
      publish(this.messageContext, DealerPortalLMC, messagePush);
    }
    isErrorMsg = false;
    /**
     * set subscription
     */
    setSubscriptionLMC(){
      this.subscription = subscribe(this.messageContext, DealerPortalLMC, (msg) => {
        // console.log(JSON.stringify(msg),' MSG');
          // 테이블 컴포넌트에서 모달창 호출 시 해당 수신이 타서 에러가 발생해 예외처리
          //let isSubCheck = this._filterList.some((item) => item.fieldApiName === msg.message.field);
          //console.log(isSubCheck,' < ==isSubCheck');
          if(msg.uuid == this.uuid ) {
            // if(window.sessionStorage.getItem('isBack') == 'true') {
            //   setTimeout(() => {
            //     this._filterList = JSON.parse(window.sessionStorage.getItem('filterHistory'));
            //     console.log(this._filterList,'',' < == this._filterList');
            //   }, 500);
            // }
            // if(msg.type == 'historyBack') {
            //   window.sessionStorage.setItem('filterHistory', JSON.stringify(this._filterList));
            // }

            // 모달창에서 선택한 값 업데이트
            if(msg.cmpName =='DN_DealerPortalDisplay') {
              if(msg.type == 'filterModal') {
                // 모달창 이벤트 수신
                let targetCmp = this.template.querySelector(`[data-id="${msg.message.field}"]`);
                // 인풋박스(하위컴포넌트)에 벨류값 조정
                let childCmp = this.template.querySelector(`[data-child="${msg.message.field}"]`);
                if(childCmp) {
                  let data = {'field' : msg.message.field,'value' : msg.message.value , 'label': msg.message.label};
                  childCmp.handleCmpValue(msg.message.label);
                  let datas = [];
                  let currentField = this._filterList.find(filedInfo => filedInfo.fieldApiName ==msg.message.field);
                  // console.log(JSON.stringify(currentField),' :: currentField');
                  // console.log(targetCmp,' :: targetCmp');
                  // 디펜던시 관계가 있을 경우 관계된 필드도 변경
                  let depency = this._filterList.find(filedInfo => filedInfo.parentFieldApiName ==msg.message.field);
                  // console.log(JSON.stringify(depency),' :: depency');
                  if(depency) {
                    for(let i=0; i<depency.filterButtonList.length; i++) {
                      if(depency.filterButtonList[i].parentKey) {
                        let depenButtons = this.template.querySelector(`[data-dependencykey="${depency.filterButtonList[i].parentKey}"]`);
                        // console.log(depenButtons,' :: depenButtons');
                        let param = depenButtons.dataset.defaultparam;
                        if(param) param += `,machineNo=`+  msg.message.value;
                        depenButtons.dataset.param = param;
                      } 
                    }  
                  }
                  //현재 필드의 상위 값 반영
                  if(currentField.parentFieldApiName !=undefined) {
                    let childCmpByParent = this.template.querySelector(`[data-child="${currentField.parentFieldApiName}"]`);
                    if(childCmpByParent) {
                      childCmpByParent.handleCmpValue(msg.message.dependencyValue);
                      datas.push({'field' : currentField.parentFieldApiName,'value' : msg.message.dependencyValue});
                    }
                    for(let i=0; i<currentField.filterButtonList.length; i++) {
                      let buttons = currentField.filterButtonList[i];
                      // console.log(JSON.stringify(datas), ' data:::');
                      if(buttons.parentKey !=undefined) {
                        // console.log(buttons.parentKey,' :: buttons.parentKey');
                        let depenButton = this.template.querySelector(`[data-dependencykey="${buttons.parentKey}"]`);
                        let param = depenButton.dataset.defaultparam;
                        // console.log(param, ' ::: param');
                        if(param) param += `,machineNo=`+  msg.message.dependencyValue;
                        depenButton.dataset.param = param;
                        // console.log(depenButton,' ::: depenButton');
                      }
                    }
                    //상위 디펜던시의 값도 변경시 Array 로 송신
                    if(datas.length > 0)  {
                      datas.push(data);
                      data = datas;
                    }
                  } 
                  this.messagePublish('filterChange',data,'dN_DealerPortalFilter');   
                } 

                if(targetCmp) {
                  targetCmp.value = msg.message.label;
                  let datas = [];
                  let data = {'field' : msg.message.field,'value' : msg.message.value , 'label': msg.message.label};
                  //필수인 경우 화면에 필수값 입력 경고문 제거
                  let currntField = this._filterList.find(filterInfo=> filterInfo.fieldApiName == msg.message.field);
                  if(currntField.isRequired) {
                    this.setErrorCssRemove(targetCmp, msg.message.field);
                  }
                  //상위 Dependency 값 변경
                  let parentFilterKey = targetCmp.dataset.dependency;
                  if(parentFilterKey) {
                    [...this.template.querySelectorAll(`[data-id="${parentFilterKey}"]`)]?.forEach((dependency)=>{
                      dependency.value = msg.message.dependencyValue;
                      datas.push({'field' : parentFilterKey,'value' : msg.message.dependencyValue});
                    });
                  }
                  
                  // 하위 디펜던시 추가 모달 기능 
                  [...this.template.querySelectorAll(`[data-dependencykey="${msg.message.field}"]`)]?.forEach((dependency)=>{
                    let param = dependency.dataset.defaultparam;
                    let dependencyValue = (msg.message?.isLabel) ? msg.message.label : msg.message.value;
                    if(param) param += `,${msg.message.dependencyField}=`+  dependencyValue;
                    dependency.dataset.param = param;
                  });
                  
                  //상위 디펜던시의 값도 변경시 Array 로 송신
                  if(datas.length > 0)  {
                    datas.push(data);
                    data = datas;
                  }
                  
                  this.messagePublish('filterChange',data,'dN_DealerPortalFilter');
                }
              } 
            } // end of if : DN_DealerPortalDisplay // 모달창에서 데이터 수신
            else if (msg.cmpName =='dN_DealerPortalFilter'){
                
            } // 필터항목 필수값 체크
            else if(msg.cmpName =='dN_DealerPortalButton') {
              let isValCheck = false;
              // setTimeout(() => {
                if(msg.type == 'SeachFilter' || msg.type=='SaveFilter') {
                  for(let i=0; i<this._filterList.length; i++) {
                    let ele = this._filterList[i];
                    let element = this.template.querySelector(`[data-id="${ele.fieldApiName}"]`);
                    let child = this.template.querySelector(`[data-child="${ele.fieldApiName}"]`);
                    if(child) {
                      if(ele.isRequired) {
                        child.handleVal();
                      }
                      // console.log(child.inputvalue, ' ::: child.inputvalue');
                      //필수값일때만 입력값이 올바르진 체크? 해야하는거 아닌지?
                      if(ele.isRequired && child.inputvalue ==undefined) {
                        this.toast('', `${ele.fieldLabel}의 입력값이 올바르지 않습니다.`, 'error');
                        return;
                      }
                    }
                    if(element) {
                      // console.log(element,' :: element');
                      if(ele.isRequired) {
                        // console.log(element.value,' :: element.value');
                        if(element.value =='') {
                          isValCheck = true;
                          if(element.tagName != 'LIGHTNING-INPUT') {
                            this.setErrorCss(element,ele.fieldApiName);
                          } else {
                            if(element.disabled) {
                              this.setErrorCss(element,ele.fieldApiName);
                            } else {
                              // console.log('teste111');
                              element.reportValidity();
                              element.focus();
                              element.blur();
                            }
                          }
                        } else {
                          if(element.disabled) {
                            this.setErrorCssRemove(element,ele.fieldApiName);
                          }
                          if(element.tagName != 'LIGHTNING-INPUT') {
                            this.setErrorCssRemove(element,ele.fieldApiName);
                          }
                        }
                      }
                    }
                  }
                  if(!isValCheck) {
                    // console.log(JSON.stringify(msg.message),' < ==Filter msg.message');
                    this.messagePublish(msg.type.replace("Filter", ""),msg.message, msg.cmpName);
                  } else {
                    this.toast('필수값 확인', '필수값을 입력해주세요.', 'error');
                  }
                }  
              // }, 300);
              
            } else {
              //2025.02.14 진현욱 작업 button Disabled 처리.
              if(msg.type == 'filterToggleDisabled') {
                let key = msg.message.field;
                let filterList = this._filterList.filter(filterInfo=>filterInfo.fieldApiName === key);

                filterList.forEach(filter=> {
                  filter.filterButtonList.forEach((button)=>{
                    let targetCmp = this.template.querySelector(`[data-disabled="${button.id}"]`);
                    if(targetCmp) targetCmp.disabled = msg.message.value;
                  });
                }) 
              }else if(msg.type == 'filterReset') {
                let targetCmp = this.template.querySelector(`[data-id="${msg.message.field}"]`);
                targetCmp.value = msg.message.label;
              }
            }
          }
      });
    }

    setErrorCss(element, fieldApiName) {
      // console.log(element.id,' ::: element.id');
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

    // 커넥티드 콜백
    connectedCallback() {
      this.setParentDependency();
      if(!this.subscription) {
        this.setSubscriptionLMC();     
      }
    }

    //필터 속성 Dependency 추가
    _childFilterInfo = {};
    setParentDependency() {
      let childFilterList = this._filterList.filter(filterInfo => filterInfo.parentFieldApiName && filterInfo.parentFieldValue).map(filter=>filter);
      childFilterList.forEach((parentFilter)=>{
        parentFilter.parentFieldValue = JSON.parse(parentFilter.parentFieldValue);
        if(this._childFilterInfo[parentFilter.parentFieldApiName]) {
          this._childFilterInfo[parentFilter.parentFieldApiName].push(parentFilter);
        }else {
          this._childFilterInfo[parentFilter.parentFieldApiName] = [parentFilter];
        }
      });
    }

    

    // 렌더링 콜백
    async renderedCallback() {
      if(this.isFilterInit) {
        let filterSection =  this.filterSection ==undefined? 4 : this.filterSection;
        const cardElement = this.template.querySelector('.filterSection');
        cardElement.style.gridTemplateColumns = `repeat(${filterSection}, 1fr)`;
        await this.setDefaultSetting();  
        // 필터 검색기능 중에 검색기능 x인 경우
        for (let element of this._filterList) {
          if (!element.isSearch && element.fieldType === 'SearchPickList') {
            try {
              // 직렬 실행을 보장하며 데이터를 처리
              await this.getPickSearch(
                element.objectName,
                element.additionalField,
                element.whereCondition,
                element
              );
              //검색 픽리스트의 디폴트 벨류가 없는 경우 목록중에 첫번쨰로 설정
              let value = this.template.querySelector(`[data-id="${element.fieldApiName}"]`).value;
              let option = this.template.querySelector(`[data-id="${element.fieldApiName}"]`).options;
              let filters = option.filter(item => item.value == value);
              if(filters.length ==0) {
                this.template.querySelector(`[data-id="${element.fieldApiName}"]`).value = option[0].value;
                let msg = {
                  'field' : element.fieldApiName,
                  'value' : option[0].value,
                  'fieldType' : element.fieldType
                };
                this.messagePublish('filterChange',msg,'dN_DealerPortalFilter'); 
              }
            } catch (error) {
              console.error("Error in processing element:", element, error);
            }
          }
        }
        // const promises = this._filterList.map(async (element) => {
        //   if (!element.isSearch && element.fieldType === 'SearchPickList') {
        //     try {
        //       await this.getPickSearch(
        //         element.objectName,
        //         element.defaultValue,
        //         element.whereCondition,
        //         element
        //       );
        //     } catch (error) {
        //       console.error("Error in processing element:", element, error);
        //     }
        //   }
        // });
        
        // 모든 작업이 완료될 때까지 기다림
        // await Promise.all(promises);
        // console.log("All elements processed.");



      }
      
    }
    // Search PickList -------------------
    additionalField =[];
    showAssetDropdown = false;
    searchQuery = ''; // 입력된 텍스트를 저장
    debounceTimeout;

    // 콤보박스 관련 getter
    get comboboxClass() {
      return `slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ${
          this.showAssetDropdown ? 'slds-is-open' : ''
      }`;
    }



    // 인풋 검색 // defaultValue
    handleSearch(event) {
      let searchField = event.currentTarget.dataset.field;
      let objectName = event.currentTarget.dataset.object;
      let additional = event.currentTarget.dataset.name.split(',');
      let where = event.currentTarget.dataset.where;
      let values = event.currentTarget.dataset.value;
      this.searchQuery =event.currentTarget.value;
      
      // 디바운싱 적용
      clearTimeout(this.debounceTimeout);
      this.debounceTimeout = setTimeout(() => {
        this.showAssetDropdown = false;
        this.getSearch(objectName,additional,this.searchQuery,searchField,where,values); 
      }, 300);
    }

    

    //handleFocus
    handleFocus(event) {
      let searchField = event.currentTarget.dataset.field;
      let objectName = event.currentTarget.dataset.object;
      let additional = event.currentTarget.dataset.name.split(',');
      let where = event.currentTarget.dataset.where;
      let values = event.currentTarget.dataset.value;
      //let searchValue = this.template.querySelector(`[data-input="${event.currentTarget.dataset.field}"]`).value;
      this.searchQuery =event.currentTarget.value;
      // 디바운싱 적용
      clearTimeout(this.debounceTimeout);
      this.debounceTimeout = setTimeout(() => {
        this.showAssetDropdown = false;
        this.getSearch(objectName,additional,this.searchQuery,searchField,where,values); 
      }, 300);
    }

    //handleBlur
    handleBlur(event){
      event.stopPropagation();
      this.showAssetDropdown =false;
    }


    // 검색한 픽리스트 선택;
    handleSelectPic(event) {
      //선택 후 데이터 메세지 채널로 전송
      this.template.querySelector(`[data-input="${event.currentTarget.dataset.name}"]`).value = event.currentTarget.dataset.value;
      this.getSelected(event.currentTarget.dataset.name, true);

      this.showAssetDropdown = false;
      let msg = {
        'field' : event.currentTarget.dataset.name,
        'value' : event.currentTarget.dataset.id,
        'fieldType' : event.currentTarget.dataset.type
      };
      this.messagePublish('filterChange',msg,'dN_DealerPortalFilter'); 
    }
    
    //검색 데이터 조회 - 검색기능 비활성화
    getPickSearch(objectName, additionalField, whereCondition, element) {
      return new Promise((resolve, reject) => {
        getSearchPicList({
          objectName: objectName,
          additionalField: additionalField,
          whereCondition: whereCondition,
        })
          .then((result) => {
    
            // // element.pickListValue 초기화 확인
            // if (!element.pickListValue) {
            //   element.pickListValue = [];
            // }
            // // 기본값 추가
            // element.pickListValue.push({
            //   label: element.defaultValueLabel,
            //   value: element.defaultValueLabel,
            // });
    
            // 결과값 추가
            const additionalFieldList = additionalField.split(",");
            for (let i = 0; i < result.length; i++) {
              const data = result[i];
              element.pickListValue.push({
                label: data[additionalFieldList[0]],
                value: data.Id,
              });
            }
            // 화면 렌더링 고려
            this.template.querySelector(`[data-id="${element.fieldApiName}"]`).options = element.pickListValue;
            resolve();
          })
          .catch((error) => {
            console.error("Error in getSearchPicList:", error);
            reject(error);
          });
      });
    }

    // 검색 데이터 조회 - 검색기능 활성화
    getSearch(objectName,additional,searchValue,searchField,where,defaultValue) {
      getSearchList({
        objectName : objectName,
        additionalField : additional,
        searchValue : searchValue,
        whereCondition : where,
        defaultValue : defaultValue
      }).then( result => {
        //console.log(JSON.stringify(result), ' < ==result');
        // 픽리스트에 검색 목록 화면에 공통으로 뿌려주기 위해 displayName0,displayName1,displayName2로 재구성
        let resultSet = JSON.parse(JSON.stringify(result));
        let searchList = [];
        resultSet.forEach(element => {
          for(let i=0; i<additional.length; i++) {
            element['displayName'+i] = element[additional[i].trim()];
            delete element[additional[i].trim()];
          }
          searchList.push(element);
        });
        // 가공한 데이터를 실제 데이터 할당
        this._filterList.forEach(element => {
          if(element.fieldApiName == searchField) {
            element.searchList =[];
            element.searchList = searchList;
            element.searchListLength = result.length > 0 ? false : true;
            //console.log(JSON.stringify(element.searchList), ' teste');
          }
        });
        // List 목록 오픈
        this.showAssetDropdown = true;
      }).catch(error => {
          console.log(JSON.stringify(error), ' getSearchList  error');
      });
    }
    // Blur
    handleBlur(event){
      event.stopPropagation();
      this.showAssetDropdown=false;
    }

    // 선택값 삭제
    handleSelectRemove(event) {
      this.template.querySelector(`[data-input="${event.currentTarget.dataset.icon}"]`).value = '';
      this.getSelected(event.currentTarget.dataset.icon, false);
      let msg = {
        'field' : event.currentTarget.dataset.icon,
        'value' : event.currentTarget.value,
        'fieldType' : event.currentTarget.dataset.type
      };
      this.messagePublish('filterChange',msg,'dN_DealerPortalFilter');  
    }

    // 선택값 찾기
    getSelected(field, isSelected) {
      for (let obj of this._filterList) {
        if (obj.fieldApiName === field) {
          obj.isSelected = isSelected;
        break; // 첫 번째 매칭 객체를 찾으면 수정하고 종료
        }
      }
    }

    // 필터의 필수값을 입력한 경우
    handleBlurValue(event) {
      // console.log(' handleBlurValue');
      let field = event.target.dataset.id;
      
      
      let value = event.target.value;
      let element = this.template.querySelector(`[data-id="${field}"]`);
      // console.log(JSON.stringify(this._filterList),' :: this._filterList');
      let currntField = this._filterList.find(filterInfo=> filterInfo.fieldApiName == field);  
      // console.log(JSON.stringify(currntField),' :::currntField.isRequired');
      // console.log(field, ' :: field');
      // console.log(value,' :: value');
      if(currntField.isRequired) {
        if(value !='') {
          this.setErrorCssRemove(element,field);
        } else {
          this.setErrorCss(element,field);
        }
        
      }
     
    }

    // 필터값 변경 이벤트
    handleChange(event) {
      //console.log(event.target.value,' < ==event.target.value');
      let field = event.target.dataset.id;
      let value = event.target.value;
      let fieldType = event.target.dataset.type;
      let dependencefield = event.target.dataset.dependencefield;

      // 디펀던쉽 필드 있는 경우 설정
      if(dependencefield) {
          this.dependeceSetting(dependencefield,value);
      }

      if(fieldType == 'DateToDate' || fieldType =='YearMonthToYearMonth') {
        field = field+event.target.dataset.set;
      }
      if(fieldType =='CheckBox') {
        value = event.target.checked;
      }

      let msg = {
        'field' : field,
        'value' : value,
        'fieldType' : fieldType
      };
      this.messagePublish('filterChange',msg,'dN_DealerPortalFilter');  

       //필터 속성 Dependency 추가
      if(this._childFilterInfo[field]) {
        this._childFilterInfo[field].forEach((childFieldFilter)=>{
          let childValue = childFieldFilter.parentFieldValue;
          for(let childKey in childValue[value]) {
            if(childFieldFilter.hasOwnProperty(childKey))
            childFieldFilter[childKey]= childValue[value][childKey];
          }
          let childCmps = this.template.querySelectorAll(`[data-id="${childFieldFilter.fieldApiName}"][data-type="${childFieldFilter.fieldType}"]`);
          //DateToDate
          if(childCmps.length > 1) {              
            let previousValue;
            childCmps.forEach((childCmp)=> {
              if(previousValue) {
                previousValue += '_' + childCmp.value;
                // childCmp.value = previousValue;
              }
              else {
                previousValue = childCmp.value;
              }
            });

            if(previousValue)
            childFieldFilter.previousValue = previousValue;
            
          } else if(childCmps.length > 0) {
            let previousValue = childCmps[0]?.value;
            
            if(previousValue) 
            childFieldFilter.previousValue = previousValue;
  
          }

          setTimeout(() => {
              this.publishDefault(childFieldFilter, childFieldFilter.previousValue);
          }, 0);
          
        });

      }
    }

    // 추가 버튼 기능
    handleAdditionButton(event) {
      
      let param = event.target.dataset.param == undefined ? '' : event.target.dataset.param;
      let msg = {
        'modalName' : event.target.dataset.cmpname,
        'param' :  param
      }
      this.messagePublish('CustomModal', msg,event.target.dataset.cmpname);
    }

    // 룩업필드의 경우 인풋데이터 삭제
    handleClear(event) {
      let input = this.template.querySelector(`[data-id="${event.target.dataset.clear}"]`);
      if(input) {
        // console.log(input,' ::: input');
        input.value='';
      }
      let msg = {
        'field' : event.target.dataset.clear,
        'value' : '',
        'fieldType' : event.target.dataset.type
      };
      this.messagePublish('filterChange',msg,'dN_DealerPortalFilter'); 
      //하위 컴포넌트 초기화
      let child = this.template.querySelector(`[data-child="${event.target.dataset.clear}"]`);
      if(child) {
        // 디펜던시 관계가 있을 경우 관계된 필드도 변경
        let depency = this._filterList.find(filedInfo => filedInfo.parentFieldApiName ==event.target.dataset.clear);
        if(depency) {
          for(let i=0; i<depency.filterButtonList.length; i++) {
            if(depency.filterButtonList[i].parentKey) {
              let depenButtons = this.template.querySelector(`[data-dependencykey="${depency.filterButtonList[i].parentKey}"]`);
              depenButtons.dataset.param = depenButtons.dataset.defaultparam;
            } 
          }  
        }
        child.handleClear();
      }
      
      
    }

    // 한 Row당 필터 수
    // _filterSection =0;
    @api filterSection;
    //get filterSection() {
    //   return this._filterSection;
    // }
    // set filterSection(value) {
    //   console.log(value, ' < ====filterSection');
    //   this._filterSection = value;
    // }

    // 버튼 목록 get set
    @api
    get displayFilterMdtList() {
      return this._filterList;
    }
    // 각필드 타입별 isBoolean 설정
    set displayFilterMdtList(value) {
      //console.log(JSON.stringify(value),' ><===value');
      this._filterList = JSON.parse(JSON.stringify(value));
      this._filterList.forEach((element) => {
        
        if(!element.isInput) {
          switch (element.fieldType) {
            case 'Lookup':
              element.isLookup = true;
              break;
            case 'PickList':
              element.isPickList = true;
              break;
            case 'MultiPickList':
              element.isMultiPickList = true;
              break;
            case 'DateToDate':
              element.isDateToDate = true;
              break;
            case 'YearMonth':
              element.isYearMonth = true;
              break;
            case 'RadioButton':
              element.isRadioButton = true;
              break;
            case 'SearchPickList':
              element.isSearchPickList = true;
              break;
            case 'RichText':
              element.isRichText = true;
              break;
            case 'Date':
              element.isDate = true;
              break;
            case 'YearMonthToYearMonth':
              element.isYearMonthToYearMonth = true;
              break;
            case 'CheckBox':
              element.isCheckBox = true;
              break;  
          }
        } 
      });
      this.isFilterInit = true;
      //console.log(JSON.stringify(this._filterList),' < === _filterList Value');
    }
    

    // pickList는 별도의 작업 필요 x defaultValue가 있을 경우 설정
    async setDefaultSetting() {
      let msg = {
        'field' : '',
        'value' : '',
        'fieldType' : ''
      };
      //this.messagePublish('defaultFilter',msg,'dN_DealerPortalFilter');   

      this._filterList.forEach(element => {
        // 디펜던쉽 설정 - Search PickList, PickList
        this.setDependenceField(element);

        if(element.defaultValue !='') {
          //필터 속성 Dependency 추가
          if(this._childFilterInfo[element.fieldApiName]) {
            this._childFilterInfo[element.fieldApiName].forEach((childFieldFilter)=>{
              let childValue = childFieldFilter.parentFieldValue;
              for(let childKey in childValue[element.defaultValue]) {
                if(childFieldFilter.hasOwnProperty(childKey))
                childFieldFilter[childKey]= childValue[element.defaultValue][childKey];
              }
            });
          }

          this.publishDefault(element);
        } 
      });      
      this.isFilterInit = false;
    }

    //date - 화면 적용
    dateSetting(element) {
      const todaySet = new Date();
      const year = todaySet.getFullYear();
      const month = String(todaySet.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작
      const date = String(todaySet.getDate()).padStart(2, '0');
      const todayFormatted = `${year}-${month}-${date}`;
      if(element.defaultValue == 'Today') {
        this.template.querySelector(`[data-id="${element.fieldApiName}"]`).value = todayFormatted;  
      }
      return todayFormatted;
    }

    // YearMonth - 화면 적용
    yearMonthSetting(element, previousValue) {
      const todaySet = new Date();
      const year = todaySet.getFullYear();
      const month = String(todaySet.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작
      const date = String(todaySet.getDate()).padStart(2, '0');
      let targetValue = `${year}-${month}`;
      // const todayFormatted = `${year}-${month}`;
      if(previousValue) {
        targetValue = previousValue;
        this.template.querySelector(`[data-id="${element.fieldApiName}"]`).value = targetValue;
      }if(element.defaultValue == 'Today') {
        this.template.querySelector(`[data-id="${element.fieldApiName}"]`).value = targetValue;  
      }
      return targetValue;
    }



    // 디폴트 설정
    setDependenceField(element) {
      // 디펜던쉽 설정
      if(element.dependenceField) {
        let defaultValue = this.template.querySelector(`[data-id="${element.fieldApiName}"]`).value;  
        let depenList = element.dependenceField.split(',');
        depenList.forEach(ele => {
          let dependeceEle = this.template.querySelector(`[data-id="${ele}"]`); 
          let data = dependeceEle.dataset.dependencevalue;
          // 픽리스트 형태를 JSON 파싱하는데 계속된 에러로 인해 분기처리하여 작업
          if(dependeceEle.dataset.type == 'PickList') {
            let pickList = data.split('=');
          } else {
            data = data
            ?.replace(/([a-zA-Z0-9가-힣]+)\s*:/g, '"$1":') // 키에 큰따옴표 추가 (영어, 한글)
            ?.replace(/:\s*([a-zA-Z0-9가-힣]+)\s*(,|\})/g, ': "$1"$2') // 값에 큰따옴표 추가 (영어, 한글)
            ?.replace(/\n/g, ', '); // 줄바꿈을 쉼표로 변환
            data = `{${data}}`; // JSON 객체 형태로 감싸기 
            
            //객체로 변환
            const jsonObject =JSON.parse(data);
            
            // 디세이블 있는 경우 디펜던쉽 필터 디세이블 처리
            if(jsonObject[defaultValue].disabled !=undefined) {
              dependeceEle.disabled = jsonObject[defaultValue].disabled;
            }

            // 디폴트값 설정한 경우
            if(jsonObject[defaultValue].defaultValue !=undefined) {
              //console.log(jsonObject[defaultValue].defaultValue, ' defalut value::::');
              dependeceEle.value = jsonObject[defaultValue].defaultValue;
            }
          }
          // this.messagePublish('defaultFilter',{
          //   'field' : element.dependenceField,
          //   'value' : dependeceEle.value,
          //   'fieldType' : dependeceEle.dataset.type
          // },'dN_DealerPortalFilter'); 
        });
        
      }
    }

    // dependencefield 설정
    dependeceSetting(dependencefield,value) {
      let depenSetting = this.template.querySelector(`[data-id="${dependencefield}"]`);
      let data = depenSetting.dataset.dependencevalue;
      //console.log(data,' ::: data');
      //console.log(depenSetting, ' ::::depenSetting');
      //console.log(depenSetting.dataset.type,' ::: depenSetting.dataset.type')
      // 픽리스트 형태를 JSON 파싱하는데 계속된 에러로 인해 분기처리하여 작업
      if(depenSetting.dataset.type == 'PickList') {
        let pickList = data.split(';');
        let pickSet = [];
        //픽리스트 데이터 가공공
        for(let i=0; i<pickList.length; i++) {
          let data = pickList[i];
          if(data.includes(value)) {
            data = data.replace(`${value}`,'').replace('=','');
            let dataSet = data.split('/');
            for(let i=0; i<dataSet.length; i++) {
              let pic = dataSet[i].split(',');
              pickSet.push({
                label : pic[0].replace('label','').replace(':','').trim(),
                value : pic[1].replace('value','').replace(':','').trim(),
              })
            }
            break;
          }
          
        }
        depenSetting.options = pickSet;
        depenSetting.value = pickSet[0].value;
        let msg = {
          'field' : dependencefield,
          'value' : pickSet[0].value,
          'fieldType' : depenSetting.dataset.type
        };
        this.messagePublish('filterChange',msg,'dN_DealerPortalFilter');
      } else {
        data = data
        .replace(/([a-zA-Z0-9가-힣]+)\s*:/g, '"$1":') // 키에 큰따옴표 추가 (영어, 한글)
        .replace(/:\s*([a-zA-Z0-9가-힣]+)\s*(,|\})/g, ': "$1"$2') // 값에 큰따옴표 추가 (영어, 한글)
        .replace(/\n/g, ', '); // 줄바꿈을 쉼표로 변환
        data = `{${data}}`; // JSON 객체 형태로 감싸기  
        //객체로 변환
        const jsonObject =JSON.parse(data);
        // 디세이블 설정 및 디세이블이 있는 경우 데이터 기본값으로 변경경
        if(jsonObject[value].disabled !=undefined) {
          depenSetting.disabled = jsonObject[value].disabled;
          depenSetting.value = jsonObject[value].defaultValue;
        }
        // option이 있는 경우 재할당
        if(depenSetting.options) {
          depenSetting.options = depenSetting.options;
        }
        let msg = {
          'field' : dependencefield,
          'value' : depenSetting.value,
          'fieldType' : depenSetting.dataset.type
        };
        this.messagePublish('filterChange',msg,'dN_DealerPortalFilter');
      }
    }

    publishDefault(element, retainPreviousValue) {
      //디폴트 설정 및 메세지 전달
      let field = element.fieldApiName;
      let vaule = element.defaultValue;
      let fieldType = element.fieldType;
  
      //필드 타입 - DateToDate + YearMonthToYearMonth 추가
      if(element.fieldType =='DateToDate' || element.fieldType =='YearMonthToYearMonth') { 
        let dateSet = element.defaultValue.split(',');
        let dataList = [dateSet[0].trim(), dateSet[1].trim()];
        let fieldSet = '';
        let valueSet = '';
        let fieldTypeSet = '';
        dataList.forEach( (elemen, elemenIdx) => {
          let ele = elemen.split(':');
          let days = ele[1];
          const todaySet = new Date();
          const year = todaySet.getFullYear();
          const month = String(todaySet.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작
          const date = String(todaySet.getDate()).padStart(2, '0');
          let dtdFormatted = `${year}-${month}-${date}`;
          let ymFormatted = `${year}-${month}`;
          const todayFormatted = element.fieldType =='DateToDate' ? dtdFormatted : ymFormatted;
          const msInADay = 24 * 60 * 60 * 1000;
          //제발..
          if(retainPreviousValue){
            if(!this.template.querySelector(`[data-set="${ele[0].trim()}"]`)) return;
            this.template.querySelector(`[data-set="${ele[0].trim()}"]`).value = retainPreviousValue.split('_')[elemenIdx];
            fieldSet = element.fieldApiName+ele[0].trim();
            valueSet = retainPreviousValue.split('_')[elemenIdx];
            fieldTypeSet = element.fieldType;
            
          } else if(days == 'Today') { 
            if(!this.template.querySelector(`[data-set="${ele[0].trim()}"]`)) return;
            this.template.querySelector(`[data-set="${ele[0].trim()}"]`).value = todayFormatted;
            // 메세지 데이터 설정
            fieldSet = element.fieldApiName+ele[0].trim();
            valueSet = todayFormatted;
            fieldTypeSet = element.fieldType;
          } else if( days =='OneDay') { 
            const onDayFormatted = `${year}-${month}-01`;
            if(!this.template.querySelector(`[data-set="${ele[0].trim()}"]`)) return;
            this.template.querySelector(`[data-set="${ele[0].trim()}"]`).value = onDayFormatted;
            // 메세지 데이터 설정
            fieldSet = element.fieldApiName+ele[0].trim();
            valueSet = onDayFormatted;
            fieldTypeSet = element.fieldType;
          } else if(days.includes('FixDate')) { // FixDate_2015-07-30
            let fixDate = days.replace('FixDate_','');
            if(!this.template.querySelector(`[data-set="${ele[0].trim()}"]`)) return;
            this.template.querySelector(`[data-set="${ele[0].trim()}"]`).value = fixDate;
            // 메세지 데이터 설정
            fieldSet = element.fieldApiName+ele[0].trim();
            valueSet = fixDate;
            fieldTypeSet = element.fieldType;
          } else {
            let daySet = new Date();
            // 투데이기준 -는 그만큼 날짜 빼기, +는 그만큼 더하기
            if(days.includes('-')) { 
              let int = days.replace('-','');
              daySet = new Date(todaySet.getTime() - parseInt(int) * msInADay);
            } else {
              let int = days.replace('+','');
              daySet = new Date(todaySet.getTime() + parseInt(int) * msInADay);
            }
            const year = daySet.getFullYear();
            const month = String(daySet.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작
            const date = String(daySet.getDate()).padStart(2, '0');
            const todayFormatted = `${year}-${month}-${date}`;
            if(!this.template.querySelector(`[data-set="${ele[0].trim()}"]`)) return;
            this.template.querySelector(`[data-set="${ele[0].trim()}"]`).value =todayFormatted;
            // 메세지 데이터 설정
            fieldSet = element.fieldApiName+ele[0].trim();
            valueSet = todayFormatted;
            fieldTypeSet = element.fieldType;
          }
          // LMS 메세지 전달
          this.messagePublish('defaultFilter',{
            'field' : fieldSet,
            'value' : valueSet,
            'fieldType' : fieldTypeSet
          },'dN_DealerPortalFilter');   
        });
      } 

      // 필드타입 - 데이트
      if(element.fieldType == 'Date') {
        let defaultValue = this.dateSetting(element);
        // 메세지 데이터 설정
        field = element.fieldApiName;
        vaule = defaultValue;
        fieldType = element.fieldType;
      } 

      //필드타입 - SearchPickList
      if(element.fieldType =='SearchPickList') {
        this.template.querySelector(`[data-id="${element.fieldApiName}"]`).value = element.defaultValue;  
        // 메세지 데이터 설정
        field = element.fieldApiName;
        vaule = element.defaultValue;
        fieldType = element.fieldType;
      } 

      //필드타입 - YearMonth
      if(element.fieldType =='YearMonth') {
        // 선택값 유지..
        let defaultValue = this.yearMonthSetting(element, retainPreviousValue);
        // 메세지 데이터 설정
        field = element.fieldApiName;
        vaule = defaultValue;
        fieldType = element.fieldType;
      }

      //필드타입 - CheckBox
      if(element.fieldType =='CheckBox') {
          if(element.defaultValue !='') {
            this.template.querySelector(`[data-id="${element.fieldApiName}"]`).checked = element.defaultValue;  
            // 메세지 데이터 설정
            field = element.fieldApiName;
            vaule = element.defaultValue;
            fieldType = element.fieldType;
          }
      }



      // 디폴트 벨류 LMS 전달
    if(element.fieldType !='DateToDate' && element.fieldType !='YearMonthToYearMonth') {  
        this.messagePublish('defaultFilter',{
          'field' : field,
          'value' : vaule,
          'fieldType' : fieldType
        },'dN_DealerPortalFilter');   
      }
    }


    errorCallback(error, stack) {
      // 오류 메시지와 스택 트레이스를 로그로 출력
      console.error('Error: ', error);
      console.error('Stack: ', stack);   
    }

    // toast
    toast(title,message,variant) {
      const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
      });
      this.dispatchEvent(evt);
    }

    // input Combox 이벤트 하위 컴포넌트 수신
    handleInputChange(event) {
      // console.log('하위요소 정보');
      // console.log(JSON.stringify(event.detail),' Details::');
      let label = event.detail.label;
      let field = event.detail.field;
      let value = event.detail.value;
      let fieldType = event.detail.type;
      

      if(fieldType == 'DateToDate' || fieldType =='YearMonthToYearMonth') {
        field = field+event.target.dataset.set;
      }
      if(fieldType =='CheckBox') {
        value = event.target.checked;
      }

      let msg = {
        'field' : field,
        'label' : label,
        'value' : value,
        'fieldType' : fieldType
      };
      this.messagePublish('filterChange',msg,'dN_DealerPortalFilter');  
      // 디펜던시 관계가 있을 경우 관계된 필드도 변경
      let depency = this._filterList.find(filedInfo => filedInfo.parentFieldApiName ==event.detail.field);
      if(depency) {
        for(let i=0; i<depency.filterButtonList.length; i++) {
          if(depency.filterButtonList[i].parentKey) {
            let depenButtons = this.template.querySelector(`[data-dependencykey="${depency.filterButtonList[i].parentKey}"]`);
            let param = depenButtons.dataset.defaultparam;
            if(param) param += `,machineNo=`+  event.detail.value;
            depenButtons.dataset.param = param;
          } 
        }  
      }
      
      
       
    }
    
}