import { LightningElement, api, track,wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Widgetapi from '@salesforce/resourceUrl/Widgetapi';
//Apex class
import getYoutubeId from '@salesforce/apex/DN_BoardYoutubeController.getYoutubeId';

export default class DN_BoardYoutubePlayer extends LightningElement {
    @api recordId;
    //static renderMode = 'light'; // Light DOM 활성화
    player;
    youtubeIds ='';
    youtubeLink = '';
    activeSections = ['accordion-General']; //accordion 초기 활성화
    get isYoutubeCheck() {
        return this.youtubeIds != '' ? true : false;
    }

    connectedCallback() {    
        Promise.all([
            // loadScript(this, IFRAME_API),
            loadScript(this, Widgetapi)
        ])
        .then(() => {
            if(this.recordId ==undefined) {
                let currentUrl = window.location.href;
                let urlSet = currentUrl.split('/');
                
                console.log(JSON.stringify(urlSet), 'urlSet');
                for(let i=0; i<urlSet.length; i++) {
                    if(urlSet[i] == 'board') {
                        this.recordId = urlSet[i+1];
                    }
                }
            }
            if(this.recordId !=undefined) {
                this.getYoutubeLink();
            } 
            
        })
        .catch( error => {
            console.log(error,' < ---error')
        });
        // 유투브 링크 조회
        
        
    }

    renderedCallback() {
        if(this.isYoutubeCheck) {
            console.log(this.isYoutubeCheck + ' < =---vbbbb');
            this.initYouTubePlayer();
        }
    }
    initYouTubePlayer() {
        const containerElem = this.template.querySelector('.youtubeList');
        const playerElem = document.createElement('Div');
        playerElem.className = 'player';
        containerElem.appendChild(playerElem);
        this.player = new YT.Player(containerElem, {
            height: '360',
            width: '100%',
            videoId: this.youtubeIds, // 첫 번째 동영상 재생
            events: {
                //onReady: this.onPlayerReady,
                //onStateChange: this.onPlayerStateChange.bind(this),
            },
        });
        console.log(this.player,' < ===this.player');
        console.log(JSON.stringify(this.player),' < ===this.player');
    }
    onPlayerReady(event) {
        console.log('Player is ready');
        event.target.playVideo(); // 비디오 자동 재생
    }

    onPlayerStateChange(event) {
        console.log('Player state changed:', event.data);
        // 상태 변경에 따른 추가 로직 구현 가능
    }


    // 유투브 링크 
    getYoutubeLink() {
        getYoutubeId({recordId : this.recordId})
        .then(result =>{
            // link
            this.youtubeLink = result;
            // Id setting
            let strSet = result.substr(result.indexOf('watch?v='), result.length);
            strSet = strSet.replace('watch?v=','');
            this.youtubeIds = strSet;
            
        }).catch(error =>{
            console.log(error);
        });
    }
    
   
}