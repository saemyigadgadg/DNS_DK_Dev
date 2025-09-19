/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-03-17
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-11-04   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    apexCall: function (component, event, helper, methodName, params) {
        return new Promise($A.getCallback(function (resolve, reject) {
            let action = component.get('c.' + methodName);

            if (typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function (response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({ 'c': component, 'h': helper, 'r': response.getReturnValue(), 'state': response.getState() });
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    isISO8601Format: function (dataString) {
        const iso8601Regex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z$/;
        return iso8601Regex.test(dataString);
    },

    replaceTagFormatTest: function (dataString) {
        const tagRegex = /<\/?[^>]+(>|$)/g;
        return tagRegex.test(dataString);
    },

    replaceTagFormat: function (dataString) {
        const tagRegex = /<\/?[^>]+(>|$)/g;
        return dataString.replace(tagRegex, '');
    },

    formatUTCDate: function (dateString) {
        const date = new Date(dateString);

        const yyyy = date.getFullYear();
        const mm = String(date.getMonth() + 1).padStart(2, '0');
        const dd = String(date.getDate()).padStart(2, '0');
        const hh = String(date.getHours()).padStart(2, '0');
        const mi = String(date.getMinutes()).padStart(2, '0');
        const ss = String(date.getSeconds()).padStart(2, '0');

        return `${yyyy}-${mm}-${dd} ${hh}:${mi}:${ss}`;
    }
})