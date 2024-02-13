import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import LOGOS from '@salesforce/resourceUrl/Self_help';

import getClients from '@salesforce/apex/SHP_SearchContainerController.getClients';
import Testing_Program from '@salesforce/label/c.Testing_Program';
import All from '@salesforce/label/c.all';
import SEARCH_PROGRAM_ICON from '@salesforce/label/c.search_program_icon';

export default class ArticleDetailPageHeaderCmpt extends LightningElement {
    @track showArticleModal = false
    @track showModalPopup = false
    clientThereinHeader
    clientThere
    nameOfClient
    selectedClientCode
    clientName
    clientCode
    currentPageReferenceState = {}
    ArticleDetailBackground = LOGOS + '/SelfHelp/Icons/ArticleDetailHeader.png'
    searchProgramIconLabel = SEARCH_PROGRAM_ICON
    //label_Testing_Program = Testing_Program;
    label_All = All;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state?.recordId
            this.language = currentPageReference.state?.language
            this.keyword = currentPageReference.state?.keyword
            this.clientCode = currentPageReference.state?.clientCode
            this.pageName = currentPageReference.attributes?.name

            console.log(this.clientCode)

            if (this.clientCode != '' && this.clientCode != null && this.clientCode != undefined && this.clientCode.toLowerCase() != 'all') {
                this.clientThereinHeader = true
                this.clientThere = true
                getClients({ clientCode: this.clientCode }).then(result => {
                    if (result.errorMsg) {
                        console.error(result.errorMsg)
                    } else {
                        this.clientName = result.selectedClient.Name
                        this.nameOfClient = this.clientName
                    }
                })
            }
        }
    }
    constructor() {
        super()
        //this.ArticleDetailBackground = LOGOS + '/SelfHelp/Icons/ArticleDetailHeader.png'
    }
    openArticleModal() {
        this.showArticleModal = true
        window.dispatchEvent(new CustomEvent('skiptohead'))
        document.body.style.overflow = 'hidden'
    }
    closeArticleModal() {
        this.showArticleModal = false
        document.body.style.overflow = 'auto'
        this.template.querySelector('.searchIconWrapper').focus();
        if (this.clientCode != '' && this.clientCode != null && this.clientCode != undefined && this.clientCode.toLowerCase() != 'all') {
            this.clientThere = true
            this.nameOfClient = this.clientName
        }
        else {
            this.clientThere = false
        }
    }
    openModalPopup() {
        this.showModalPopup = true
        this.showArticleModal = false
        document.body.style.overflow = 'hidden'
    }
    closeModalPopup() {
        this.showModalPopup = false
        this.timer = setTimeout(() => {
            this.template.querySelector('c-article-detail-page-modal').handleFocus()
        }, 100)
        this.showArticleModal = true
    }
    handleClientSelected(event) {
        //get client id and name from modalpopup 
        this.selectedClientCode = event.detail.clientCode
        this.nameOfClient = event.detail.clientName
        this.clientThere = true
        this.showArticleModal = true
        this.timer = setTimeout(() => {
            this.template.querySelector('c-article-detail-page-modal').handleFocus()
        }, 100)
    }

    handleRemoveClient() {
        this.clientThere = false
        this.showModalPopup = false
        this.showArticleModal = true
        this.timer = setTimeout(() => {
            this.template.querySelector('c-article-detail-page-modal').handleFocus()
        }, 100)
    }
    handleSearchKeyDown(event) {
        if (event.keyCode == 13) {
            event.preventDefault();
            this.openArticleModal();
        }
    }
}