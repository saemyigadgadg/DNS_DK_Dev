import { LightningElement } from 'lwc';
export default class DN_DealerAdminCssSetting extends LightningElement {
    connectedCallback() {
        // const observer = new MutationObserver(() => {
        //     const headerElement = document.querySelector('.slds-page-header.header.flexipageHeader');
        //     console.log(headerElement ,' :::headerElement');
        //     if (headerElement) {
                
        //         headerElement.style.display = 'none';
        //         observer.disconnect(); // 감지 중지
        //     }
        // });
    
        // observer.observe(document.body, { childList: true, subtree: true });
    }

    handleCss() {
        const parentElements = document.querySelectorAll('.lwcAppFlexipage'); // 모든 탭 컨테이너 선택
        if (parentElements.length > 0) {
            parentElements.forEach((parentElement) => {
                const targetElements = parentElement.querySelectorAll('.slds-page-header.header.flexipageHeader'); // 각 탭의 헤더 선택
                targetElements.forEach((targetElement) => {
                    console.log(targetElement, ':: targetElement'); // 디버깅용 출력
                    targetElement.style.display = 'none'; // 모든 일치하는 요소 숨기기
                });
            });
        }
    }
    renderedCallback() {
        this.handleCss();
    }
}