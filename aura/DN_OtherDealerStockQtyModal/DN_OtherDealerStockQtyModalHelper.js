/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2024-06-28
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-28   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    closeModal : function(component) {
        var modal = component.find("otherDealerStockModal");
        var modalBackGround = component.find("otherDealerStockModalBackGround");

        //modal close
        $A.util.removeClass(modal, "slds-fade-in-open");
        //modalbackground close
        $A.util.removeClass(modalBackGround, "slds-backdrop_open");
        //modal hide
        $A.util.addClass(modal, "slds-hide");
        
        modalBackGround.getElement().removeEventListener("click", function(e) {
            e.stopPropagation();
        });
    },

    // 체크박스 상태
    updateCheckboxState: function (component, event) {
        let odsList = component.get('v.dealerStockList');
        let checkboxes = component.find("checkbox");
        let index = Number(event.target.name);
        let partsNum = odsList[index].partName;

        if (checkboxes[index].get("v.checked")) {
            for (let i = 0; i < odsList.length; i++) {
                if (i != index && odsList[i].partName == partsNum) {
                    checkboxes[i].set("v.disabled", true);
                }
            }
        } else {
            for (let i = 0; i < odsList.length; i++) {
                if (i != index && odsList[i].partName == partsNum) {
                    checkboxes[i].set("v.disabled", false);
                }
            }
        }
    },

    gfnGetRequestParam: function (component) {
        let requestParam = {};
        component.get('v.partList').forEach(part=>{
            requestParam[part.partName] = part;
        });
        return requestParam;
    },

    gfnSetStaus: function(component, availableStockList) {
        let partialAvailableStatus = component.get('v.partialAvailableStatus');
        let allAvailableStatus = component.get('v.allAvailableStatus');
        let self = this;
        availableStockList.forEach((availableStock)=> {
            if(availableStock.avaiableQuantity >= availableStock.requestQuantity) {
                availableStock.stockStatus = allAvailableStatus;
            }else {
                availableStock.stockStatus = partialAvailableStatus;
            }
            
            availableStock.discountPrice = self.gfnDiscountRateFromPrice(availableStock.customerPrice, availableStock.discountRate);
        });
        return availableStockList;
    }
})