({
    toast : function(component, title, message, variant){
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "variant": variant
        });
    },
    searchDoc : function(component) {
        
        if($A.util.isEmpty(component.get('v.model')) || $A.util.isEmpty(component.get('v.assetId'))){
            this.toast(component, 'ERROR', $A.get('$Label.c.DNS_M_InsertRequiredField'), 'Error');
            return;
        }

        component.set('v.isSpinner', true);
        var action = component.get('c.getShippingInstructionInfo');
        action.setParams({
            equipId : component.get('v.assetId'),
            equipModel : component.get('v.model')
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('result', result);
            if(result.isSuccess){
                component.set('v.o_header', result.o_header);
                component.set('v.t_o_remark', result.remarkStr);
                const t_o_classification = this.setLength('SOCV', result.t_o_classification);
                component.set('v.t_o_classification', t_o_classification);
                const t_o_mannual = this.setLength('Manual', result.t_o_mannual);
                component.set('v.t_o_mannual', t_o_mannual);
                const t_o_material = this.setLength('SalesOrder', result.t_o_material);
                component.set('v.t_o_material', t_o_material);
                const t_o_shipping_part_list = this.setLength('Shipping', result.t_o_shipping_part_list);
                component.set('v.t_o_shipping_part_list', t_o_shipping_part_list);
                const t_o_rsp_list = this.setLength('RSP', result.t_o_rsp_list);
                component.set('v.t_o_rsp_list', t_o_rsp_list);
                component.set('v.isSpinner', false);
            }else{
                this.toast(component, 'ERROR', result.errMessage, 'Error');
                component.set('v.isSpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    setLength : function(listName, list){
        if(listName === 'SOCV'){
            while (list.length < 5) {
                list.push({
                    WKADDR: '',
                    WKVALUE: ''
                });
            }
        }else if (listName === 'SalesOrder') {
            while (list.length < 5) {
                list.push({
                    POSNR: '',
                    MATNR: '',
                    ARKTX: '',
                    ATWRT: '',
                    KWMENG: '',
                    VRKME: ''
                });
            }
        } else if (listName === 'Manual') {
            while (list.length < 5) {
                list.push({
                    MANULDV: '',
                    MANUL: '',
                    PPNOF: '',
                    BOOKN: '',
                    SLANG: '',
                    SERIAL: '',
                    COPIS: ''
                });
            }
        }else if (listName === 'Shipping') {
            while (list.length < 5) {
                list.push({
                    POSNR: '',
                    MATNR: '',
                    ZSPEC: '',
                    MENGE: '',
                    MEINS: ''
                });
            }
        }else if (listName === 'RSP') {
            while (list.length < 5) {
                list.push({
                    POSNR: '',
                    MATNR: '',
                    ZSPEC: '',
                    MENGE: '',
                    MEINS: ''
                });
            }
        }
        return list;
    }
})