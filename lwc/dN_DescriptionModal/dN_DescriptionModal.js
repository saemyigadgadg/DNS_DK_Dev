import { LightningElement, api, track } from 'lwc';

export default class DN_DescriptionModal extends LightningElement {
    @api sqText = ''; // 부모로부터 받은 sqText
    @api recordId;   // recordId도 필요하면 사용 가능
    @track textList = [];

    // 컴포넌트 초기화
    connectedCallback() {
        this.init();
    }

    // sqText를 #$로 분리하여 textList 생성
    init() {
        const originalText = this.sqText || '';
        this.textList = originalText.split('#$').filter(item => item.trim() !== '');
    }

    // Close 버튼 클릭 시 이벤트 발송
    handleClickClose() {
        this.cancelModal();
    }

    // 모달 닫기 이벤트 발송
    cancelModal() {
        const modalEvent = new CustomEvent('modalevent', {
            detail: {
                modalName: 'dNSA_DescriptionModal',
                actionName: 'CancelDescriptionModal',
                message: 'CancelDescriptionModal'
            }
        });
        this.dispatchEvent(modalEvent);
    }
}