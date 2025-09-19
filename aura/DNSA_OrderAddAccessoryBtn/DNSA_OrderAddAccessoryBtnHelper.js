({
    toast: function (type, title, message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title      : title
            , type     : type
            , message  : message
            , duration : 3000
            , mode     : 'dismissible'
        });
        toastEvent.fire();
    }

    , closeModal : function() {
        $A.get('e.force:closeQuickAction').fire();
        $A.get('e.force:refreshView').fire();
    }

    , handleError : function(methodName, errorMsg) {
        var msg = errorMsg;
        if(typeof msg != 'string' && errorMsg.length > 0) { msg = errorMsg[0]; }
        if(msg.message) { msg = msg.message; }

        if(msg.includes('first error:')) msg = msg.split('first error:')[1];

        console.error(methodName + " Error : " + JSON.stringify(msg, null, 2));
        this.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), msg);
    }

    , reverseSpinner : function(component) {
        component.set('v.isLoading', !component.get('v.isLoading'));
    }

    , setColumns : function(component) {

        const tableColumns = [
            {type: 'button-icon', typeAttributes: {iconName: 'utility:add', name: 'add', variant: 'bare'}, initialWidth: 50}
            , {label : 'Kit',         fieldName : 'accCode',  wrapText: true,  initialWidth: 180}
            , {label : 'Description', fieldName : 'accName',  wrapText: true}
            , {label : 'Qty',         fieldName : 'quantity', type : 'number', initialWidth: 100}
        ];

        const filter = {
            criteria: [
                {
                    fieldPath: 'Id',
                    operator: 'in',
                    value: component.get('v.targetShipToIds')
                }
                , {
                    fieldPath: 'RecordTypeId',
                    operator: 'eq',
                    value: component.get('v.dnsaRecordType')
                }
            ]
            , filterLogic: '(1 OR 2)'
        };
        // console.log('filter ::: ' , JSON.stringify(filter, null, 2));
        

        const selTableColumns = [
            // {type: 'button-icon', typeAttributes: {iconName: 'utility:dash', name: 'remove', variant: 'bare'}, initialWidth: 50}
            {
                type: 'customIconAction'
                , typeAttributes: {
                    iconName: 'utility:dash'
                    , actionName: 'remove'
                    , variant: 'bare'
                    , key: { fieldName: 'key' }
                }
                , initialWidth: 50
            }
            , {label : 'Kit',         fieldName : 'accCode',  initialWidth: 160}
            , {label : 'Description', fieldName : 'accName',  initialWidth: 300}
            // , {label : 'Qty',         fieldName : 'quantity', type : 'number', initialWidth: 100, editable: true}
            , {
                type: 'customNumberInput',
                typeAttributes: {
                    key: { fieldName: 'key' }
                    , qty : { fieldName : 'quantity'}
                },
                initialWidth: 70
            }
            , {
                label: 'Ship To'
                , fieldName: 'shipTo'
                , type: 'customRecordPicker'
                , typeAttributes: {
                    objectname : 'Account'
                    , value: { fieldName: 'shipToId' }
                    , label: { fieldName: 'shipTo' }
                    , key: { fieldName: 'key' }
                    , filter : filter
                }
                , initialWidth: 200
            }

            , { label: 'Machine Request Ship Date', fieldName: 'deliveryDate', type: 'date-local', initialWidth: 200}

        ];

        component.set('v.tableColumns',    tableColumns);
        component.set('v.selTableColumns', selTableColumns);
    }

})