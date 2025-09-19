import { LightningElement,api,track } from 'lwc';
import getGRGIListPrint from '@salesforce/apex/DN_DealerPortalPrintController.getGRGIListPrint';
import getOrderPrint from '@salesforce/apex/DN_DealerPortalPrintController.getOrderPrint';
import getStockInfoPrint from '@salesforce/apex/DN_DealerPortalPrintController.getStockInfoPrint';
import getLocation from '@salesforce/apex/DN_DealerPortalPrintController.getLocation';
import dueOutDetails from '@salesforce/apex/DN_POListReviewController.dueOutDetails';
import Domain from '@salesforce/schema/Domain.Domain';
import { loadScript } from 'lightning/platformResourceLoader';
import JsBarcode from '@salesforce/resourceUrl/JsBarcode';

export default class DN_DealerPortalPrint extends LightningElement {
    @api recordId;
    isPrintQty = false;
    printQty = 0; // 필요에 따라 사용
    printDate;
    printDateList=[];
    type;
    @track dataList =[];
    isGRGI = false;
    isOrder = false;
    isStockInfo = false;
    isLocation = false;
    isDueOut = false;
    //단건
    record ={};
    // 다건
    recordList =[];
    qtyList = [];
    docNum = '';

    connectedCallback() {
        Promise.all([
            // loadScript(this, IFRAME_API),
            loadScript(this, JsBarcode)
        ])
        .then(() => {
            console.log('loadScript');
            const parsedUrl = new URL(window.location.href);
            // URLSearchParams로 쿼리 파라미터 추출
            const queryParams = parsedUrl.searchParams;
            let c_record = queryParams.get("c_record"); 
            this.type = queryParams.get('c_type');
            
            let c_qty = queryParams.get("c_qty");       
            let c_bin = queryParams.get("c_bin");       
            if(c_qty !=null) {
                this.isPrintQty = true;
                this.qtyList = c_qty.split(','); 
            }
            console.log(JSON.stringify(this.qtyList), ' :::: this.qtyList');
            this.printDate = queryParams.get("c_printDate");
            if(this.printDate !=null) {
                this.printDateList = this.printDate.split(',');
            }
            
            this.recordList = c_record.split(',');
            
            console.log(this.type,' < ===this.type');
            switch (this.type) {
                case '입고':
                    this.isGRGI = true;
                    this.getPrintInfoListGRGI();
                    break;
                case '출고':
                    this.isGRGI = true;
                    this.getPrintInfoListGRGI();
                    break;
                case '대리점자재종합조회':
                    this.isStockInfo = true;
                    this.printQty = c_qty;
                    console.log(this.isStockInfo + ' < ==isStockInfo');
                    this.getStockInfo();
                    break;   
                case '주문출고':
                    this.isOrder = true;
                    this.getPrintInfoListOrder();
                    break;   
                case '저장소':
                    this.isLocation = true;
                    this.getLocationInfo();
                    break;
                case 'DueOut':
                    this.isDueOut = true; //this.recordList
                    this.getDueOutDetails();
                    break;     
                default:
                    break;
            }
        })
        .catch( error => {
            console.log(error,' < ---error')
        });
    }
   

    handlePirint(event) {
        // let divName = event.target.dataset.name;
        // var printContents = document.getElementById(divName).innerHTML;
        // document.body.innerHTML = printContents;
        window.print();
    }

     /**
    * @description 입/출고증 프린트
    * @author iltae.seo | 2024-12-31
    **/
    getPrintInfoListGRGI() {
        getGRGIListPrint({
            recordIds : this.recordList,
            qtyList : this.qtyList,
            type : this.type
        })
        .then(result =>{
            this.dataList = JSON.parse(JSON.stringify(result));
            let printMap = [];
            console.log(JSON.stringify(this.printDateList),' ::: this.printDateList');
            console.log(this.printDate,' ::: this.printDate');
            console.log(JSON.stringify(this.recordList),' ::: this.recordList');
            console.log(JSON.stringify(result),'1111');
            for(let i=0; i<this.recordList.length; i++) {
                printMap.push({
                    id : this.recordList[i],
                    print : this.printDateList[i]
                })
            }
            console.log(JSON.stringify(printMap), ' ::: printMap');
            this.dataList.forEach(element => {
                for(let i=0; i<printMap.length; i++) {
                    if(element.id == printMap[i].id) {
                        element.printDate =printMap[i].print;
                    } 
                }
            });
            console.log(JSON.stringify(this.dataList),' <==result');
        }).catch(error =>{
            console.log(error);
        });
    }
    
    // 주문출고 프린트 
    getPrintInfoListOrder() {
        getOrderPrint({
            recordId : this.recordList
        })
        .then(result =>{ //orderId
            console.log(JSON.stringify(result),' ::: JSON.stringify(result)');
            this.dataList = JSON.parse(JSON.stringify(result));
            let qtyMap = [];
            for(let i=0; i<this.recordList.length; i++) {
                qtyMap.push({
                    id : this.recordList[i],
                    qty : this.qtyList[i],
                    print : this.printDateList[i]
                })
            }
            this.dataList.forEach(element => {
                for(let i=0; i<qtyMap.length; i++) {
                    if(element.id == qtyMap[i].id) {
                        element.qty =qtyMap[i].qty;
                        element.print =qtyMap[i].print;
                    }
                }
            });
            console.log(JSON.stringify(this.qtyList), ' ::: this.qtyList');
            console.log(JSON.stringify(this.printDateList), ' ::: this.printDateList');
            // this.record.quantity = this.qtyList[0];
            // this.record.printDate = this.printDate;
        }).catch(error =>{
            console.log(error);
        });
    }

    //대리점 자재 종합조회 & 재고 위치 설정/수정 프린트
    getStockInfo() {
        getStockInfoPrint({
            recordIds : this.recordList
        })
        .then( result =>{
            this.dataList = JSON.parse(JSON.stringify(result));
            if(this.dataList.size() > 1) {
                
            }
        }).catch(error =>{
            console.log(error);
        });
    }

    //저장소 위치 - 출력
    getLocationInfo() {
        // console.log(this.isLocation, ' this isLocation');
        getLocation({
            recordIds : this.recordList,
        })
        .then(result =>{
            this.dataList = result;
            // console.log(JSON.stringify(this.dataList),' :: this.dataList');
        }).catch(error =>{
            console.log(error);
        });
    }

    // PO List Review에서 프린트 기능
    getDueOutDetails() {
        dueOutDetails({
            partCode : this.recordList[0],
        })
        .then(result =>{
            this.docNum = this.recordList[0];
            this.dataList = JSON.parse(JSON.stringify(result));
            console.log(JSON.stringify(this.dataList), ' :: this.dataList');
        }).then( () =>{
            window.print();
            window.close(); 
        })
        .catch(error =>{
            console.log(error);
        });
    }

    

    // 바코드 기능
    handleBarCode() {
        const canvas = this.template.querySelectorAll(`canvas`);
        canvas.forEach(element => {
            console.log(element,' :: element');
            console.log(element.dataset.index,' :: element.dataset.index');
            
            window.JsBarcode(element, element.dataset.index, { // 여기서 "canvas" 대신 실제 요소 사용
                format: "CODE128",
                width: 2,
                height: 15,
                displayValue: false,
                textAlign: "left",
                lineColor: "#000",
            });
            console.log(JsBarcode,' ::: JsBarcode');
        });
    }
    




    /**
    * @description renderedCallback 불필요한 화면 제거
    * @author youjin.shim | 2024-11-25
    **/
    renderedCallback() {//siteforcePrmBody // .cCenterPanel.slds-m-top--x-large.slds-p-horizontal--medium,forceSkipLink
        const targetDiv = document.querySelector('.cHeaderWrapper.cHeaderWrapper--fixed:has(~div .tb_layout)');
        const targetDIV2 = document.querySelector('.cCenterPanel:has(.tb_layout)');
        const targetDiv3 = document.querySelector('.cHeader .slds-container--fluid'); 
        const targetDiv4 = document.querySelector('.cHeaderWrapper .cHeaderWrapper--fixed');
        const targetDiv5 = document.querySelector('.siteforcePrmBody .cHeaderWrapper.cHeaderWrapper--fixed'); 
        const targetDiv6 = document.querySelector('.cCenterPanel .slds-m-top--x-large.slds-p-horizontal--medium--fixed');
        const targetDiv7 = document.querySelector('.forceSkipLink'); 
        const delDiv = document.querySelector('.siteforcePrmBody');
        const delDiv2 = document.querySelector('.cCenterPanel.slds-m-top--x-large.slds-p-horizontal--medium');
        if(delDiv) {
            delDiv.className ='';
        }
        if(delDiv2) {
            delDiv2.className ='';
        }
        if (targetDiv) {
            //element.classList.remove('slds-m-top--x-large'); class=".cCenterPanel.slds-m-top--x-large slds-p-horizontal--medium"
            //popup header display none
            targetDiv.style.display = 'none';
            targetDiv.style.setProperty('padding', '0px', 'important');
            
        }
        if (targetDIV2) {
            //popup padding-top none
            targetDIV2.style.setProperty('padding', '0px', 'important');
            
        }
        if(targetDiv3) {
            targetDiv3.style.display = 'none';
            targetDiv3.style.setProperty('padding', '0px', 'important');
        }
        if(targetDiv4) {
            targetDiv4.style.display = 'none';
            targetDiv4.style.setProperty('padding', '0px', 'important');
        }
        if(targetDiv5) {
            targetDiv5.style.display = 'none';
            targetDiv5.style.setProperty('padding', '0px', 'important');
        }
        if(targetDiv6) {
            targetDiv6.style.display = 'none';
            targetDiv6.style.setProperty('padding', '0px', 'important');
        }
        if(targetDiv7) {
            targetDiv7.style.display = 'none';
            targetDiv7.style.setProperty('padding', '0px', 'important');
        }

        this.handleBarCode();
    }

    
}