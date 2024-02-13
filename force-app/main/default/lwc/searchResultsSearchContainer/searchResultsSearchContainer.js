import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getClients from '@salesforce/apex/SHP_SearchContainerController.getClients';
import getDataCategoryLabel from '@salesforce/apex/DataCategoryController.getDataCategoryLabel';
import Change_program from '@salesforce/label/c.Change_program';
import Testing_Program from '@salesforce/label/c.Testing_Program';
import All from '@salesforce/label/c.all';
import Select_Program from '@salesforce/label/c.Select_Program';
import LOGOS from '@salesforce/resourceUrl/Self_help';
import I_want_to_search_across_all_programs from '@salesforce/label/c.I_want_to_search_across_all_programs';
import I_know_my_testing_program from '@salesforce/label/c.I_know_my_testing_program';

import { MessageContext, publish, subscribe } from 'lightning/messageService';
import CHANNEL from '@salesforce/messageChannel/shpMessageChannel__c';

import { getConstants } from 'c/constantUtil';
const CONSTANTS = getConstants();



export default class SearchResultsSearchContainer extends LightningElement {
    @track searchResultsImage
    showModal = false;
    clientCode;
    recordId
    language
    keyword
    urlKeyword
    pageName
    clientName;
    currentPageReferenceState = {}
    selectedProgram
    clientSelected = null
    validKeyword
    categoryName
    categoryLabel

    isClientThere = false;
    label_hyperlink = Change_program;
    label_Testing_Program = Testing_Program;
    label_All = All;
    label_Select_Program = Select_Program;
    label_I_want_to_search_across_all_programs = I_want_to_search_across_all_programs;
    label_I_know_my_testing_program = I_know_my_testing_program;

    constructor() {
        super()
        this.searchResultsImage = LOGOS + '/SelfHelp/Icons/search_results.png';
    }


    @wire(MessageContext)
    context

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.currentPageReferenceState = currentPageReference.state
            this.recordId = currentPageReference.state?.recordId
            this.language = currentPageReference.state?.language
            this.keyword = currentPageReference.state?.keyword || ''
            this.urlKeyword = currentPageReference.state?.keyword
            this.clientCode = currentPageReference.state?.clientCode
            this.pageName = currentPageReference.attributes?.name
            this.categoryName = currentPageReference.state?.category
            if (this.clientCode && this.clientCode.toLowerCase() != 'all') {
                this.isClientThere = true
                getClients({ clientCode: this.clientCode }).then(result => {
                    if (result.errorMsg) {
                        console.error(result.errorMsg)
                    } else {
                        this.clientLogo = result.selectedClient.Logo__c ? result.selectedClient.Logo__c : ''
                        this.clientName = result.selectedClient.Name
                    }
                })
            } else {
                this.isClientThere = false;
            }
        }
    }

    async connectedCallback() {
        this.subscribeHandler();
        if (this.categoryName != '') {
            await this.getCategoryLabel(this.categoryName)
            console.log('data cat label93', this.categoryLabel)
        }
        document.body.style.overflow = 'auto'
    }

    publishHandler() {
        let message = {
            clientCode: {
                value: this.clientCode,
                label: this.clientName
            }
        }
        publish(this.context, CHANNEL, message)
    }

    subscribeHandler() {
        subscribe(
            this.context,
            CHANNEL,
            (message) => { this.handleMessage(message) }
        )
    }

    handleMessage(message) {
        if (message.clientCode.value) {
            this.clientCode = message.clientCode.value
            this.clientName = message.clientCode.label
            // console.log(this.clientName);
            if (this.clientName) {
                this.isClientThere = true;
            }
        }
    }

    handleKeywordChange(event) {
        this.keyword = event.detail.toString();
    }

    getCategoryLabel(dataCatName) {
        getDataCategoryLabel({ dataCategoryName: dataCatName })
            .then(result => {
                this.categoryLabel = result
                //Below custom event to handle title of the page for accessibility
                if(this.categoryLabel){
                window.dispatchEvent(new CustomEvent('category',{detail:this.categoryLabel}))
                console.log('event dispatched')
                }
            })
            .catch(error => {
                console.error(error);
            })
        console.log('data cat label156', this.categoryLabel)
    }

    closeModal() {
        this.showModal = false;
        document.body.style.overflow = 'auto'
        if(this.categoryName && this.pageName == CONSTANTS.searchResultsPage && !this.urlKeyword){
        this.template.querySelector('c-search-Bar-With-Suggestions-Child-V1').setKeyword('')
        }
        if (this.isClientThere == false) {
            this.template.querySelector('[data-id="AllPrograms"]').checked = true;
        }
        if (this.template.querySelector('.changeLink')) {
            this.template.querySelector('.changeLink').focus();
        } else if (this.template.querySelectorAll('.searchRadio')) {
            this.template.querySelectorAll('.searchRadio')[1].focus();
        }
    }

    isSelectedProgramSearchAllPrograms() {
        return this.selectedProgram === CONSTANTS.searchAllPrograms;
    }

    handleProgramSelection(event) {
        //To confirm if the event is a real click & not arrow buttons click
        if (event.type === 'click' && event.clientX !== 0 && event.clientY !== 0) {
            this.openModal()
        }
        this.selectedProgram = event.target.value;
        if (this.selectedProgram !== CONSTANTS.iknow) {
            this.closeModal();
            this.selectedProgram = CONSTANTS.searchAllPrograms;
        }
    }

    openModal() {
        this.showModal = true;
        this.selectedProgram !== CONSTANTS.iknow
        document.body.style.overflow = 'hidden'
       // this.template.querySelector('[data-id="iknow"]').checked = true;
    }

    openModalRadio(event) {
        if (event.keyCode === 13) {
            this.openModal();
        }
    }

    handleRemoveClient() {
        this.isClientThere = false;
        this.clientName = ''
        setTimeout(() => {
            if (this.template.querySelector('.searchRadio')) {
                this.template.querySelector('.searchRadio').focus();
            }
        }, 100)
        this.template.querySelector('c-search-Bar-With-Suggestions-Child-V1').callApex(null)
        // to pass keyword from the last successful search
        this.template.querySelector('c-search-Bar-With-Suggestions-Child-V1').setKeyword(this.keyword)
        this.closeModal();
        document.body.style.overflow = 'auto'

    }

    handleClientSelected(event) {

        this.clientCode = event.detail.clientCode;
        this.clientName = event.detail.clientName;
        this.clientLogo = event.detail.clientLogo;
        // to pass keyword from the last successful search
        this.keyword = event.detail.keyword.length >= 3 ? event.detail.keyword : this.keyword
        this.validKeyword = this.keyword
        this.template.querySelector('c-search-Bar-With-Suggestions-Child-V1').setKeyword(this.validKeyword)

        if (this.clientCode != '' && this.clientCode != null && this.clientCode != undefined) {
            this.isClientThere = true
            this.template.querySelector('c-search-Bar-With-Suggestions-Child-V1').callApex(this.clientCode)
            setTimeout(() => {
                this.template.querySelector('.changeLink').focus();
            }, 100)
        } else {
            this.isClientThere = false
        }
        const sendClientName = new CustomEvent('sendclient', {
            detail: { clientName: this.clientName }
        });
        window.dispatchEvent(sendClientName);
    }

}