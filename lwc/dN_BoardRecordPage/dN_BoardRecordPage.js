import { LightningElement } from 'lwc';
export default class DN_BoardRecordPage extends LightningElement {
    isElement = false;
    connectedCallback() {
        // setTimeout(() => {
        //     const resizable = document.getElementById('resizable');
        //     const resizer = document.createElement('div');
        //     resizer.className = 'resizer';
        //     resizable.appendChild(resizer);

        //     let isResizing = false;

        //     resizer.addEventListener('mousedown', (e) => {
        //         e.preventDefault();
        //         isResizing = true;
                
        //         // 초기 마우스 위치 저장
        //         const initialMouseX = e.clientX;
        //         const initialMouseY = e.clientY;
        //         const initialWidth = resizable.offsetWidth;
        //         const initialHeight = resizable.offsetHeight;

        //         // 마우스 이동 이벤트
        //         const onMouseMove = (e) => {
        //             if (!isResizing) return;

        //             const newWidth = initialWidth + (e.clientX - initialMouseX);
        //             const newHeight = initialHeight + (e.clientY - initialMouseY);

        //             // 크기 조절 값 적용
        //             resizable.style.width = `${newWidth}px`;
        //             resizable.style.height = `${newHeight}px`;
        //         };

        //         // 마우스 업 이벤트
        //         const onMouseUp = () => {
        //             isResizing = false;
        //             document.removeEventListener('mousemove', onMouseMove);
        //             document.removeEventListener('mouseup', onMouseUp);
        //         };

        //         // 마우스 이동과 마우스 업 이벤트 추가
        //         document.addEventListener('mousemove', onMouseMove);
        //         document.addEventListener('mouseup', onMouseUp);
        //     });    
        // }, );
        // const observer = new MutationObserver((mutations) => {
        //     mutations.forEach((mutation) => {
        //         const element = document.querySelector('.slds-rich-text-area__content.slds-grow.slds-text-color-weak.standin');
        //         if (element) {
        //             console.log(element, 'Element dynamically found!');
        //             //observer.disconnect(); // 더 이상 감지할 필요 없으면 중단
        //         }
        //     });
        // });
        
        // // 감지 설정
        // observer.observe(document.body, { childList: true, subtree: true });

        const onClick = (event) => {
            // if(window.location.href.includes('Board__c')) {
                
            // }
            let className = event.target.className
            // 스탠다드 화면에서 수정버튼 클릭 시 Contents필드 크기 수정
            console.log(className,' <> ==')
            if(className.includes('inline-edit-trigger')) {
                setTimeout(() => {
                    let xpath = "//div[contains(@class, 'slds-rich-text-area__content') and " +
                    "contains(@class, 'slds-grow') and " +
                    "contains(@class, 'slds-text-color-weak') and " +
                    "contains(@class, 'standin')]";
        
                    let element = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
                    
                    if (element) {
                        console.log('Element found using XPath:', element);
                    
                        // 스타일 속성 추가
                        element.style.minHeight = '300px';
                        element.style.resize = 'both';
                        element.style.overflow = 'auto';
                        element.style.maxWidth = 'unset';
                        element.style.maxHeight = 'unset';
                    } 
                    let eles = document.querySelector('.ql-editor.slds-rich-text-area__content.slds-grow.slds-text-color_weak');
                    if(eles) {
                        // 스타일 변경
                        eles.style.minHeight = '300px';
                        eles.style.resize = 'both';
                        eles.style.overflow = 'auto';
                        eles.style.maxWidth = 'unset';
                        eles.style.maxHeight = 'unset';
                    }  
                }, );  
            } else {
                let eles = document.querySelector('.ql-editor.slds-rich-text-area__content.slds-grow.slds-text-color_weak');
                if(eles) {
                    // 스타일 변경
                    eles.style.minHeight = '300px';
                    eles.style.resize = 'both';
                    eles.style.overflow = 'auto';
                    eles.style.maxWidth = 'unset';
                    eles.style.maxHeight = 'unset';
                }
                    
            }
           
        }
        window.addEventListener('click', onClick);
    }

    

    renderedCallback() {
        // if(!this.isElement) {
        //     const element = document.querySelector('.ql-editor.slds-rich-text-area__content.slds-grow.slds-text-color_weak');
        //     console.log('inte',element);
        // }
        
        
    }
}