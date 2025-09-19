/**
 * @author            : yeongju.yun
 * @last modified on  : 2024-07-29
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-05-23   yeongju.yun   Initial Version
**/
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import label from './Labels/label';

/**
 * @param {*} cmp : this
 * @param {String} variant : info (default), success, warning, and error.
 * @param {String} title : toast title
 * @param {String} message : toast message
 */
export function showToast(cmp, variant, title, message){
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    })

    cmp.dispatchEvent(event);
}

/**
 * 
 * @param {FetchResponse|FetchResponse[]} errors 
 * @return {String[]} Error messages
 */
export function reduceErrors(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
        .filter((error) => !!error)
        .map((error) => {
            if (Array.isArray(error.body)) {
                return error.body.map((e) => e.message);
            }
            else if (
                error?.body?.pageErrors &&
                error.body.pageErrors.length > 0
            ) {
                return error.body.pageErrors.map((e) => e.message);
            }
            else if (
                error?.body?.fieldErrors &&
                Object.keys(error.body.fieldErrors).length > 0
            ) {
                const fieldErrors = [];
                Object.values(error.body.fieldErrors).forEach(
                    (errorArray) => {
                        fieldErrors.push(
                            ...errorArray.map((e) => e.message)
                        );
                    }
                );
                return fieldErrors;
            }
            else if (
                error?.body?.output?.errors &&
                error.body.output.errors.length > 0
            ) {
                return error.body.output.errors.map((e) => e.message);
            }
            else if (
                error?.body?.output?.fieldErrors &&
                Object.keys(error.body.output.fieldErrors).length > 0
            ) {
                const fieldErrors = [];
                Object.values(error.body.output.fieldErrors).forEach(
                    (errorArray) => {
                        fieldErrors.push(
                            ...errorArray.map((e) => e.message)
                        );
                    }
                );
                return fieldErrors;
            }
            // else if (error.body && typeof error.body.message === 'string') {
            //     return error.body.message;
            // }
            else if (error.body && error.body.message) {
                return error.body.message;
            }
            else if (typeof error.message === 'string') {
                return error.message;
            }
            return error.statusText;
        })
        .reduce((prev, curr) => prev.concat(curr), [])
        .filter((message) => !!message)
    );
}

export const style = {
    set: (customStyle) => {
        let styleElement = document.createElement("style");
        styleElement.setAttribute("id", customStyle.id);
        styleElement.innerHTML = customStyle.style;
        document.body.appendChild(styleElement);
    },
    remove: (customStyle) => {
        const target = document.querySelector("style#" + customStyle.id);
        if(target) target.remove();
    }
}

export function checkIsNull(str){
    return typeof str == "undefined" || str == null || str == '';
}

export { label }