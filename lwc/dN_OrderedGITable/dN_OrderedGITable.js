/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-03-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-03-2025   youjin.shim@sbtglobal.com   Initial Version
**/
import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// static Resource
import { loadScript, loadStyle }     from 'lightning/platformResourceLoader';
import EXCEL_JS from '@salesforce/resourceUrl/ExcelJS'; 
import SheetJS from '@salesforce/resourceUrl/SheetJS'; 

//LMC
import DealerPortalLMC    from '@salesforce/messageChannel/DealerPortalLMC__c';
import { publish, MessageContext, subscribe} from 'lightning/messageService';

// APEX
import getDataList from '@salesforce/apex/DN_OrderedGITableController.getDataList';
import insertShipmentOrder from '@salesforce/apex/DN_OrderedGITableController.insertShipmentOrder';
import insertGoodsIssue from '@salesforce/apex/DN_OrderedGITableController.insertGoodsIssue';


export default class DN_OrderedGITable extends NavigationMixin(LightningElement) {
    // excelJs = EXCEL_JS + '/unpkg/exceljs.min.js';
    // sheetJs = SheetJS + '/xlsx-js-style-master/dist/xlsx.bundle.js';
    isAll = false;
    @api uuid;
    isSpinner = false;
    _SearchOption = {
        searchOption : '',
        dateStart : null,
        dateEnd : null
    }
    urlParamIds = [];
    
    @track seletedList =[];

    //window.open(`${this.currentUrl}Notice-PopUp?recordId=${element.Id}`, `${element.Name}`, `top=10, left=10, width=${element.Width__c}, height=${element.Height__c}, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=${element.IsScroll__c}`);                
    @track orderList=[];

    
    /**
     * LMC
     */
    @wire(MessageContext)
    messageContext;
    subscription = null;
    connectedCallback() {
        Promise.all([
            loadScript(this, EXCEL_JS + '/unpkg/exceljs.min.js'),
            loadScript(this, SheetJS + '/xlsx-js-style-master/dist/xlsx.bundle.js'),
            //loadScript(this, this.excelJs),
        ])
        .then(() => {  
            console.log('완료!!');
        })
        .catch( error => {
            console.log(error,' < ---error')
        });


        if(!this.subscription) {
            this.setSubscriptionLMC();        
        }
        const parsedUrl = new URL(window.location.href);
        // URLSearchParams로 쿼리 파라미터 추출
        const queryParams = parsedUrl.searchParams;
        let c__dealerorderItems = queryParams.get("c__dealerorderItems"); 
        console.log(c__dealerorderItems,' < ==c__dealerorderItems');
        if(c__dealerorderItems !=null) {
            let recordList = c__dealerorderItems.split(',');
            this.urlParamIds = recordList;
            this.getList();
        }
        console.log(queryParams.get("c__isAll"),'  isAll');
        if(queryParams.get("c__isAll") !=null && queryParams.get("c__isAll")) {
            this.isAll = true;
        }
    }

    renderedCallback() {
	    this.styleCss();	    
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
                console.log(JSON.stringify(msg), ' dN_OrderedGITable');
                switch (msg.type) {
                    case 'Seach':
                        this.getList();
                        break;
                    case 'defaultFilter':
                        this.setFilterChange(msg.message);
                        break;
                    case 'filterChange':
                        this.setFilterChange(msg.message);
                        break;    
                    case 'Output':
                        if(this.seletedList.length == 0) {
                            this.showToast('출력', '출력할 항목을 선택해주세요','error');
                            break;
                        }
                        this.handlePrint();
                        break;
                    case 'Save':
                        if(this.seletedList.length == 0) {
                            this.showToast('출고완료', '출고완료할 항목을 선택해주세요','error');
                            return;
                        } //background-color: #FEADD1;
                        for(let i=0; i<this.seletedList.length; i++) {
                            let rowData = this.seletedList[i];
                            if(rowData.currentStockQuantity < rowData.gIPossibleQty) {
                                //부품번호 S4006532 의 재고가 부족합니다.
                                this.showToast('재고부족', `부품번호 ${rowData.partNumber} 의 재고가 부족합니다.`,'error');
                                return;
                            }
                            //console.log(parseInt(rowData.quantity), ' ::: parseInt(rowData.quantity)');
                            //console.log(parseInt(rowData.gIPossibleQty) + parseInt(rowData.gICompletedQTY), ' ::: parseInt(rowData.gIPossibleQty) + parseInt(rowData.gICompletedQTY)');
                            let checkQty = Number(rowData.quantity) - (Number(rowData.gIPossibleQty) + Number(rowData.gICompletedQTY));
                            console.log(Number(checkQty),' ::: checkQty');
                            if(Number(checkQty) !=0) {
                                console.log(' 조건식 확인');
                                if(Number(checkQty) < 0) {
                                    this.showToast('주문수량 확인', `주문서 ${rowData.orderNumber} / ${rowData.itemNumber} 의 출고수량이 오더수량을 초과합니다.`,'error');
                                    return;
                                }
                            }
                            
                            if(rowData.gIPossibleQty <=0) {
                                this.showToast('출고수량확인', `출고 수량을 확인해주세요`,'error');
                                return;
                            }

                        }
                        this.handleInsertGoodsIssue();
                        break;
                    default:
                        break;
                }
            }
        });
    }
    // 데이터 조회
    getList() {
        console.log(JSON.stringify(this._SearchOption),' :: this._SearchOption');
        this.isSpinner = true;
        getDataList({
            search : this._SearchOption,
            urlParamIds : this.urlParamIds
        }).then( result => {
            this.seletedList = [];
            this.orderList = JSON.parse(JSON.stringify(result));
            this.orderList.forEach(element => {
                element.isDisabled = false;
            });
            console.log(JSON.stringify(this.orderList), ' ::: this.orderList');
            
            //const element = this.template.querySelector(`td[data-id="${this.index}"]`);
            ////background-color: #FEADD1;
            this.urlParamIds = [];
        }).then( () => {
            if(this.orderList.length > 0) {
                for(let i=0; i<this.orderList.length; i++) {
                    let qty = this.orderList[i].quantity -this.orderList[i].gICompletedQTY;
                    if(qty > this.orderList[i].currentStockQuantity ) {
                        let element = this.template.querySelector(`[data-currentqty="${i}"]`);
                        element.classList.add('emergency');
                    }
                }
            }
            this.resetCheckbox();
        }).catch(error => {
            this.isSpinner = false;
            console.log(JSON.stringify(error), '  get DataQuery  error');
        });
    }

    // OPEN 주문서 상세
    openCustomerOrderDetail(event) {
        this.isSpinner = true;
        // let url = window.location.pathname.split('/');
        // console.log(JSON.stringify(url), ' url!!');
        // console.log(event.currentTarget.dataset.id, ' < ===1111');
        // url.pop();
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.currentTarget.dataset.id,
                actionName: 'view',
            },
        }).then((url) => {
            console.log(url + ' < ===111');
            this.isSpinner = false;
            window.open(`${url}`, `주문서 상세`, `top=10, left=10, width=1000, height=1000, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`);                
        }); 
    }

    //출고완료
    handleInsertGoodsIssue() {
        //console.log(this.seletedList[0],' < ===this.seletedList[0]');
        this.isSpinner = true;
        insertGoodsIssue({
            goodsIssue : this.seletedList
        }).then( result => {
            if(this.isAll) {
                this.template.querySelector(`[data-id="isAll"]`).checked = false;
                this.isAll = false;
                const baseUrl = window.location.origin + window.location.pathname;
                window.history.replaceState({}, '', baseUrl);
            }
            
            this.seletedList=[];
            this.showToast('출고완료', `${result[0].InventoryNumber__c} 출고완료되었습니다.`,'success');
            this.getList();
        }).catch(error => {
            this.showToast('', `${error.body.message}`, 'error');
            this.getList();
            this.isSpinner = false;
        });
    }

    // 출고지시
    handleInsertShipmentOrder(event) {
        if(this.seletedList.length ==0) {
            this.showToast('출고지시', `출고지시 할 항목을 선택해주세요`,'error');
            return;
        }
        for(let i=0; i<this.seletedList.length; i++) {
            let rowData = this.seletedList[i];
            console.log(JSON.stringify(rowData),' ::: rowData');
            
            if(rowData.gIOrderPossibleQty <=0 || rowData.gIOrderPossibleQty =='')  {
                this.showToast('출고지시수량확인', `출고지시 수량이 없습니다.`,'error');
                return;  
            }
            if(rowData.quantity < (parseInt(rowData.gIOrderPossibleQty)+parseInt(rowData.gIOrderCompletedQTY))) { //gIOrderCompletedQTY
                //주문서 8000288465 / 000010 의 출고수량이 오더수량을 초과합니다.
                this.showToast('주문수량 확인', `주문서 ${rowData.orderNumber} / ${rowData.itemNumber} 의 출고지시수량이 오더수량을 초과합니다.`,'error');
                return;
            }
            if(rowData.currentStockQuantity < rowData.gIOrderPossibleQty) {
                //부품번호 S4006532 의 재고가 부족합니다.
                this.showToast('재고부족', `부품번호 ${rowData.partNumber} 의 재고가 부족합니다.`,'error');
                return;
            }
            

        }

        this.isSpinner = true;
        let shipList = [];
        this.seletedList.forEach(element => {
            shipList.push({
                quantity : element.gIOrderPossibleQty,
                goodsIssueHistory : element.gIDescription,
                orderItemId : element.orderItemId
            });
        });
        insertShipmentOrder({
            shipList : shipList
        }).then( result => {
            this.seletedList = [];
            let excelHeader = result[0];
            console.log('test');
            // 엑셀 기능
            this.isSpinner = false;
            let workbook = new ExcelJS.Workbook();
            console.log('test1');
            let worksheet = workbook.addWorksheet('Sheet1');
            console.log('test2');
            worksheet.mergeCells('A1:G1');
            worksheet.getCell('A1').value = '출고지시서';        
            worksheet.getCell('A1').alignment = { vertical: 'middle', horizontal: 'center' };
            worksheet.mergeCells('A2:B6');
            worksheet.getCell('A2').value = 'DN 솔루션즈';
            worksheet.getCell('A2').alignment = { vertical: 'middle', horizontal: 'center' };
            worksheet.mergeCells('C2:D2');
            worksheet.getCell('C2').value = '고객사명';
            worksheet.getCell('C2').alignment = { vertical: 'middle', horizontal: 'center' };
            worksheet.getCell('E2').value = '출고지시번호';
            worksheet.getCell('F2').value = '출고지시일자';
            worksheet.getCell('G2').value = '출고지시시간';
            worksheet.mergeCells('C3:D3');
            worksheet.getCell('C3').value = excelHeader.accountName;
            worksheet.getCell('E3').value = excelHeader.deliveryOrderNumber;
            worksheet.getCell('F3').value = excelHeader.deliveryDate;
            worksheet.getCell('G3').value = excelHeader.deliveryTime;
            worksheet.getCell('C4').value = '대표주소';
            worksheet.mergeCells('D4:E4');
            worksheet.getCell('D4').value = excelHeader.address;
            worksheet.getCell('F4').value = '우편번호';
            worksheet.getCell('G4').value = excelHeader.postalCode;
            worksheet.getCell('C5').value = '대표자명';
            worksheet.mergeCells('D5:E5');
            worksheet.getCell('D5').value = excelHeader.representative;
            worksheet.getCell('F5').value = '전화번호';
            worksheet.getCell('G5').value = excelHeader.phone;
            worksheet.getCell('C6').value = '배송 방법';
            worksheet.mergeCells('D6:E6');
            worksheet.getCell('D6').value = excelHeader.shippingType;
            console.log('test3');
            const font = { bold: true };
            const fill = {type: 'pattern',pattern: 'solid',fgColor: { argb: 'F2F2F2' }};
            const alignment = { horizontal: 'center' };
            // 출고지시서 문서 목록 헤더
            worksheet.getCell('A8').value = 'No';
            worksheet.getCell('A8').font = font;
            worksheet.getCell('A8').fill = fill;
            worksheet.getCell('A8').alignment = { horizontal: 'center' };
            console.log('test4');
            worksheet.getCell('B8').value = '고객주문번호';
            worksheet.getCell('B8').font = font;
            worksheet.getCell('B8').fill = fill;
            worksheet.getCell('B8').alignment = { horizontal: 'center' };
            console.log('test5');
            worksheet.getCell('C8').value = '주문번호';
            worksheet.getCell('C8').font = font;
            worksheet.getCell('C8').fill = fill;
            worksheet.getCell('C8').alignment = { horizontal: 'center' };
            console.log('test6');
            worksheet.getCell('D8').value = '품번';
            worksheet.getCell('D8').font = font;
            worksheet.getCell('D8').fill = fill;
            worksheet.getCell('D8').alignment = { horizontal: 'center' };
            console.log('test7');
            worksheet.getCell('E8').value = '품명';
            worksheet.getCell('E8').font = font;
            worksheet.getCell('E8').fill = fill;
            worksheet.getCell('E8').alignment = { horizontal: 'center' };
            console.log('test8');
            worksheet.getCell('F8').value = '수량';
            worksheet.getCell('F8').font = font;
            worksheet.getCell('F8').fill = fill;
            worksheet.getCell('F8').alignment = { horizontal: 'center' };
            console.log('test9');
            worksheet.getCell('G8').value = '저장위치';
            worksheet.getCell('G8').font = font;
            worksheet.getCell('G8').fill = fill;
            worksheet.getCell('G8').alignment = { horizontal: 'center' };
            console.log('test10');
            // 출고지시서 목록
            let index = 1;
            let excelRow = 9;
            console.log(JSON.stringify(result),' ::: result');
            for(let i=0; i<result.length; i++) {
                let data = result[i];
                worksheet.getCell(`A${excelRow}`).value = index;
                worksheet.getCell(`B${excelRow}`).value = data.customerOrderNumber;
                worksheet.getCell(`C${excelRow}`).value = data.orderNumber;
                worksheet.getCell(`D${excelRow}`).value = data.partNumber;
                worksheet.getCell(`E${excelRow}`).value = data.partName;
                worksheet.getCell(`F${excelRow}`).value = data.quantity;
                worksheet.getCell(`G${excelRow}`).value = data.location;
                index ++;
                excelRow ++;
            }
            console.log('test11');
            for (let row = 1; row <= excelRow; row++) {
                const rowObj = worksheet.getRow(row);
                // 테두리 스타일 정의
                const borderStyle = {
                  top: { style: 'thin' },
                  left: { style: 'thin' },
                  bottom: { style: 'thin' },
                  right: { style: 'thin' }
                };
                
                // 각 셀에 테두리 적용
                for (let col = 1; col <= worksheet.columns.length; col++) {
                  const cell = rowObj.getCell(col);
                  cell.border = borderStyle;
                }
            }
    
            // 열 너비 자동 조정
            worksheet.columns.forEach((column) => {
                let maxLength = 0;
                column.eachCell({ includeEmpty: true }, (cell) => {
                    const cellValue = cell.value ? cell.value.toString() : '';
                    maxLength = Math.max(maxLength, cellValue.length);
                });
            
                column.width = maxLength + 2; // 여유 공간을 더하기 위해 2를 추가
            });
            console.log('test12');
            // Export file
            workbook.xlsx.writeBuffer()
                .then(function (buffer) {
                    var blob = new Blob([buffer], { type: 'application/octet-stream' });
                    var link = document.createElement('a');
                    link.href = URL.createObjectURL(blob);
                    link.download = '출고지시번호_' + excelHeader.deliveryOrderNumber + '.xlsx';
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                })
                .catch(function (error) {
                    console.error('Error while generating Excel file:', error);
                });

        }).then( result => {
            // 출고지시관리로 페이지 이동
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name : 'ShippingInstructionManagement__c'
                },
            });
        }).catch(error => {
            console.log(error, ' ::: error');
            this.isSpinner = false;
        });
    }
    
    //체크박스 초기화
    resetCheckbox() {
        for(let i=0; i<this.orderList.length; i++) {
            let checkbox = this.template.querySelector(`lightning-input[data-index="${i}"]`);
            if (checkbox) {
                checkbox.checked = false; // DOM의 체크 상태 변경
            }
        }
        this.isSpinner = false;
    }

    // 사용자 입력값
    handleChange(event) {
        let value = event.currentTarget.value;
        let currentData = this.orderList[event.currentTarget.name];
        
        
        console.log(JSON.stringify(currentData), ' currentData:::');
        if(event.currentTarget.dataset.field=='gIOrderPossibleQty' || event.currentTarget.dataset.field=='gIPossibleQty') {
            if(/[^0-9]/.test(value)) {
                value = 0;
            } else {
                value = Number(value);
            }
            let element = this.template.querySelectorAll(`[data-field="${event.currentTarget.dataset.field}"]`);
            element[event.currentTarget.name].value = value;
            // element.forEach((ele, index) => {
            //     ele[event.currentTarget.name].value = value;
            // });
            
        } 
        currentData[event.currentTarget.dataset.field] = value;
        this.orderList[event.currentTarget.name] = currentData;
        
        

        this.seletedList.forEach(element => {
            if(element.orderItemId == currentData.orderItemId) {
                element = currentData;
            }
        });
        
        console.log(JSON.stringify(this.seletedList), ' < this.orderList');
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
    
    // 필터정보 변경
    setFilterChange(message) {
        console.log(JSON.stringify(message), ' testet');
        if(message.value) {
            if(message.field =='CustomerName__c') {
                this._SearchOption['accountId'] = message.value;
            } else {
                this._SearchOption[message.field] = message.value;
            }
            
        } else {
            if(message.field =='CustomerName__c') {
                delete this._SearchOption['accountId'];
            } 
            delete this._SearchOption[message.field];
        }
    }
    
    //출력 기능
    handlePrint() {
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name : 'PrintView__c'
            },
        }).then((url) => {
            let recordIds =[];
            let qtys = [];
            let printDate =[]
            for(let i=0; i<this.seletedList.length; i++) {
                recordIds.push(this.seletedList[i].orderItemId);
                qtys.push(this.seletedList[i].gIPossibleQty);
                printDate.push(this.seletedList[i].printDate);
            }
            let openUrl = `${url}?c_record=${recordIds.join(',')}&c_qty=${qtys.join(',')}&c_printDate=${printDate.join(',')}&c_type=주문출고`;
            window.open(`${openUrl}`, `주문출력`, `top=10, left=10, width=500, height=500, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`);                  
        }); 
        //DealerPortalPrintView?c_record=${recordIds}&c_qty=${qtys}&c_printDate=${printDate}&c_type=입고`);
    }

    // 전체 선택
    handleCheckAll(event) {
        let check = event.currentTarget.checked;
        if(check) {
            this.seletedList = this.orderList;
            
        } else {
            this.seletedList = [];
        }
        for(let i=0; i<this.orderList.length; i++) {
            this.template.querySelector(`[data-index="${i}"]`).checked =check;
        }
        
        
        
    }

    // 테이블 목록 선택
    handleCheckboxChange(event) {
        let check = event.currentTarget.checked;
        let index = event.currentTarget.dataset.index;
        if(check) {
            this.seletedList.push(this.orderList[index]);
           
        } else {
            this.seletedList = this.seletedList.filter(item => item !== this.orderList[index]);
        }
        if(this.seletedList.length > 0) {
            this.seletedList.forEach(ele => {
                this.orderList.forEach(element => {
                    console.log(JSON.stringify(element), ' ele');
                    if(ele.shipToCode ==element.shipToCode && ele.shipToPhone == element.shipToPhone) {
                        if(ele.shipToCode =='9999999999') {
                            if(ele.orderItemId !=element.orderItemId) {
                                element.isDisabled = true;
                            }
                        } else {
                            element.isDisabled = false;
                        }
                    } else {
                        element.isDisabled = true;
                    }
                    // //일반고객
                    // if(ele.accountId =='') {
                    //     if(ele.orderItemId != element.orderItemId) {
                    //         element.isDisabled = true;
                    //     }
                    // } else {
                    //     if(ele.accountId !=element.accountId) {
                    //         element.isDisabled = true;
                    //     }
                    // }
                });
            });
        } else {
            this.orderList.forEach(element => {
                element.isDisabled = false;
            });
        }
        console.log(JSON.stringify(this.seletedList), ' :::: this.seletedList');
    }

    //css
    styleCss() {
        const style = document.createElement('style');
		style.innerText = `
        /*달력*/
        .slds-datepicker__month td{
            border: none !important;
            background-color: #fff !important;
            padding: .25rem !important;
            font-size: .75rem !important;
        }
        .slds-datepicker__month th{
            padding: .5rem !important;
            font-weight: 400 !important;
            background-color: #fff !important;
            border: none !important;
        }
        .slds-datepicker__month tr{
            border-bottom: none !important;
        }
        `;
		this.template.querySelector('div').appendChild(style);
    }

    handleCopy() {
        const element = this.template.querySelector('[data-id="copyTarget"]');
        const cloned = element.cloneNode(true);
        // "무시할" 요소들 제거
        cloned.querySelectorAll(".copy-ignore").forEach(el => el.remove());
        const html = cloned.innerHTML;
        const listener = function(e) {
            e.clipboardData.setData("text/html", html);
            e.clipboardData.setData("text/plain", html.replace(/<[^>]+>/g, "")); // 단순 텍스트 fallback
            e.preventDefault();
        };
        document.addEventListener("copy", listener);
        document.execCommand("copy");
        document.removeEventListener("copy", listener);
        this.showToast('success', '복사되었습니다.','success');
        
    }
}