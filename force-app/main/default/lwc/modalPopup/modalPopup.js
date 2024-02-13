// .....................................................................................................................................
//     Change LOG
// .....................................................................................................................................
//     Date             Version              Author                          Summary of Changes 
// ................   ............      .....................    .......................................................................
//    20-10-2023           1.0             R.Dharshini                Completion of functionality
//    25-10-2023           1.1             Swagata Dasgupta           Code Review and functionality update
// ..................................................................................................................................... 

// Import necessary modules and components
import { LightningElement, wire, api, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getClients from '@salesforce/apex/SHP_SearchContainerController.getClients';
import CHANNEL from '@salesforce/messageChannel/shpMessageChannel__c';
import { MessageContext, publish } from 'lightning/messageService';
import LOGOS from '@salesforce/resourceUrl/Self_help';
import DeviceSize from "@salesforce/client/formFactor";


// Import various labels for internationalization
import Search_and_select_your_testing_program from '@salesforce/label/c.Search_and_select_your_testing_program';
import This_will_help_us_get_you_the_most_accurate_results from '@salesforce/label/c.This_will_help_us_get_you_the_most_accurate_results';
import Begin_typing_program_name_or_acronym from '@salesforce/label/c.Search';
import get_assistance from '@salesforce/label/c.get_assistance';
import Close from '@salesforce/label/c.Close';
import Search from '@salesforce/label/c.Search';
import SELECTED_PROGRAM from '@salesforce/label/c.SELECTED_PROGRAM';
import Help_and_support_is_in_progress from '@salesforce/label/c.Help_and_support_is_in_progress';
import Oops_No_results_found from '@salesforce/label/c.Oops_No_results_found';
import Please_consider_the_following_search_tips from '@salesforce/label/c.Please_consider_the_following_search_tips';
import I_know_my_testing_program from '@salesforce/label/c.I_know_my_testing_program';
import Try_typing_the_acronym_or_long_name_of_your_testing_program from '@salesforce/label/c.Try_typing_the_acronym_or_long_name_of_your_testing_program';
import Review_your_spelling_and_spacing from '@salesforce/label/c.Review_your_spelling_and_spacing';
import Remove from '@salesforce/label/c.Remove';
import Great from '@salesforce/label/c.Great';
import CLEAR_SEARCH from '@salesforce/label/c.clear_search';
import REMOVE_SELECTED_PROGRAM from '@salesforce/label/c.Remove_Selected_Program';
import modalPopup_banner_message from '@salesforce/label/c.modalPopup_banner_message';

// Import constants from util
import { getConstants } from 'c/constantUtil';
const CONSTANTS = getConstants();

// Define and export the LWC component
export default class ModalPopUp extends NavigationMixin(LightningElement) {

    @track keyword = ''
    @track categoryName = ''

    // Expose API properties for external use
    @api currentPageReferenceState = {}
    @api clientNameFromContainer
    @api clientPresent
    @api 
    get searchWord() {
        return this.keyword
    }
    set searchWord(value) {
        this.keyword = value
    }
    @api 
    get catName(){
        return this.categoryName
    }
    set catName(value){
        this.categoryName = value
    }

    @track showCross

    // Initialize label variables with imported label values
    label_Search_and_select_your_testing_program = Search_and_select_your_testing_program;
    label_This_will_help_us_get_you_the_most_accurate_results = This_will_help_us_get_you_the_most_accurate_results;
    label_Begin_typing_program_name_or_acronym = Begin_typing_program_name_or_acronym;
    label_getassistance = get_assistance;
    label_close = Close;
    label_Search = Search;
    label_SELECTED_PROGRAM = SELECTED_PROGRAM;
    label_Help_and_support_is_in_progress = Help_and_support_is_in_progress;
    //label_Testing_Program = Testing_Program;
    label_Oops_No_results_found = Oops_No_results_found;
    label_Please_consider_the_following_search_tips = Please_consider_the_following_search_tips;
    label_Try_typing_the_acronym_or_long_name_of_your_testing_program = Try_typing_the_acronym_or_long_name_of_your_testing_program;
    label_Review_your_spelling_and_spacing = Review_your_spelling_and_spacing;
    label_Remove = Remove;
    label_Great = Great;
    label_I_know_my_testing_program = I_know_my_testing_program;
    clearsearchlabel = CLEAR_SEARCH
    removeSelectedProgramLabel = REMOVE_SELECTED_PROGRAM
    label_modalPopup_banner_message = modalPopup_banner_message

    // Define component properties and variables
    searchQuery = ''
    clients = []
    filteredClients = []
    isClientThere = true
    clientName
    clientCode
    clientLogo
    clientsLoading = true
    hasError = false
    modalBackground;
    urlKeyword
    i = 0

    constructor() {
        super();
        if (DeviceSize == 'Small') {
            this.modalBackground = LOGOS + '/SelfHelp/Icons/clientSelectionModalMobile.png';
        } else {
            this.modalBackground = LOGOS + '/SelfHelp/Icons/clientSelectionModal.png';

        }
    }

    // Wire the MessageContext from the Lightning Message Service
    @wire(MessageContext)
    context

    renderedCallback() {
        // To initially focus on the slds modal background as soon as the component loads
        if (this.i < 2) {
            setTimeout(() => {
                this.template.querySelector('.closeButton').focus();
                this.i++;
                window.dispatchEvent(new CustomEvent('clientstab'))
            }, 100)
        }
    }

    // Executed when the component is connected to the DOM
    connectedCallback() {
        getClients({ clientCode: null }).then(result => {
            if (result.errorMsg) {
                this.hasError = true
            }
            else {
                this.clients = result.allClientsList
                this.filterClients()
            }
        })
            .catch(error => console.error(error))
        //Adding Event listener for handling click 
        this.addEventListener('click', () => this.dispatchEvent(new CustomEvent('closemodal')));

    }

    disconnectedCallback() {
        //Removing Event listener for handling click 
        this.removeEventListener('click', () => this.dispatchEvent(new CustomEvent('closemodal')));
    }

    ignore(event) {
        event.stopPropagation();
        return false;
    }

    keyboardHandler(event) {
        if (event.keyCode == 27) {
            this.dispatchEvent(new CustomEvent('closemodal'))
        }
    }

    // Handle the search input change event
    handleSearch(event) {
        this.searchQuery = event.target.value
        this.filterClients()
        //To show/hide clear button in the search bar
        if (this.searchQuery.length > 0) {
            this.showCross = true
        } else {
            this.showCross = false
        }
    }

    //To handle input clear
    handleInputClear() {
        this.searchQuery = ''
        this.showCross = false
        this.filterClients()
        this.template.querySelector('.slds-input.searchInput').focus();
    }
    handleInputClearOnKeyPress() {
        if (event.key === 'Enter') {
            this.handleInputClear(event);
        }
    }

    // Filter the list of clients based on the search query
    filterClients() {
        const query = this.searchQuery.toLowerCase();
        this.filteredClients = this.clients.filter(client => {
            if (client.Name && client.Name.toLowerCase().includes(this.searchQuery.toLowerCase())) {
                return client;
            } else if (client.Client_code__c && client.Client_code__c.includes(this.searchQuery)) {
                return client;
            }
        })
        if (this.filteredClients.length <= 0) {
            this.hasError = true
        } else {
            this.hasError = false
        }
        this.clientsLoading = false
    }

    // Handle the close button click event
    handleCloseClick() {
        //window.dispatchEvent(new CustomEvent('skiptohead'))
        this.dispatchEvent(new CustomEvent('resetprogram'))
        this.dispatchEvent(new CustomEvent('closemodal'))
        console.log('close modal')
    }

    // Publish a message using the Lightning Message Service
    publishHandler() {
        if (this.keyword && this.keyword.length < 2) {
            const urlState = JSON.parse(JSON.stringify(this.currentPageReferenceState))
            this.keyword = urlState.keyword
        }
        let message = {
            clientCode: {
                value: this.clientCode,
                label: this.clientName
            },
            keyword: this.keyword,
            category: this.categoryName
        }
        console.log('messagemessagemessage', message)
        publish(this.context, CHANNEL, message)
    }

    // Handle the "Remove" button click event
    handleRemoveClick() {
        if (window.location.pathname.includes(CONSTANTS.detailPageUrl)) {
            //   this.dispatchEvent(new CustomEvent('removeclient'))
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: CONSTANTS.homePage
                },
                state: {
                    // recordId: tempid,
                    language: this.language,
                    clientCode: CONSTANTS.All,
                    //keyword: this.keyword
                }
            })
            document.body.style.overflow = 'auto'
        }
        else {
            this.clientCode = CONSTANTS.All
            const urlState = JSON.parse(JSON.stringify(this.currentPageReferenceState))
            let state = {}
            if (this.keyword && this.keyword.length < 2) {
                urlState.keyword ? state['keyword'] = urlState.keyword : ''
            } else {
                urlState.keyword ? state['keyword'] = encodeURIComponent(this.keyword) : ''
            }
            urlState.language ? state['language'] = urlState.language : ''
            urlState.category ? state['category'] = encodeURIComponent(urlState.category) : ''
            urlState.src ? state['src'] = urlState.src : ''
            state['clientCode'] = this.clientCode
            let url = '?'
            //To form encoded URL from state Object 
            for (let key in state) {
                if (state.hasOwnProperty(key)) {
                    url += `${key}=${state[key]}&`
                }
            }
            url = url.slice(0, -1)

            window.history.pushState(state, '', url)
            this.dispatchEvent(new CustomEvent('removeclient', {
                detail: {
                    keyword: this.keyword && this.keyword.length >= 3 ? this.keyword : ''
                }
            }))
            window.dispatchEvent(new CustomEvent('skiptohead'))
            this.publishHandler()
        }


    }

    // Handle a client item click event
    handleClientClick(event) {
        this.clientCode = event.currentTarget.dataset.clientCode;
        this.clientName = event.currentTarget.dataset.clientName;
        this.clientLogo = event.currentTarget.dataset.value;
        //  Handle client selection logic for - article-details-page
        if (window.location.pathname.includes(CONSTANTS.detailPageUrl)) {
            // this.fireSelectionEvent()
            if (this.clientNameFromContainer != this.clientName) {
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: CONSTANTS.homePage
                    },
                    state: {
                        // recordId: tempid,
                        language: this.language,
                        clientCode: this.clientCode,
                        //keyword: this.keyword
                    }
                })
                document.body.style.overflow = 'auto'
                // this.handleCloseClick()
            }
            else {
                // this.fireSelectionEvent()
                this.handleCloseClick()
            }
        }
        //  Handle client selection logic for - article-search-results
        else if (window.location.pathname.includes(CONSTANTS.searchResultsPageUrl)) {
            const urlState = JSON.parse(JSON.stringify(this.currentPageReferenceState))
            console.log(this.currentPageReferenceState)
            console.log(this.clientCode)
            urlState.clientCode = this.clientCode;
            let state = {}
            urlState.clientCode ? state['clientCode'] = urlState.clientCode : ''
            if (this.keyword && this.keyword.length < 2) {
                urlState.keyword ? state['keyword'] = urlState.keyword : ''
            } else {
                urlState.keyword ? state['keyword'] = encodeURIComponent(this.keyword) : ''
            }
            urlState.language ? state['language'] = urlState.language : ''
            urlState.category ? state['category'] = encodeURIComponent(urlState.category) : ''
            urlState.src ? state['src'] = urlState.src : ''
            // const url = '?' + new URLSearchParams(state).toString()
            let url = '?'
            //To form encoded URL from state Object 
            for (let key in state) {
                if (state.hasOwnProperty(key)) {
                    url += `${key}=${state[key]}&`
                }
            }
            url = url.slice(0, -1)
            console.log('url', state)
            window.history.pushState(state, '', url)
            this.fireSelectionEvent()
            this.handleCloseClick()
            this.publishHandler()
        }

        //  Handle client selection logic for other pages
        else {
            const urlState = JSON.parse(JSON.stringify(this.currentPageReferenceState))
            urlState.clientCode = this.clientCode;
            let state = {}
            urlState.clientCode ? state['clientCode'] = urlState.clientCode : ''
            if (this.keyword && this.keyword.length < 2) {
                urlState.keyword ? state['keyword'] = urlState.keyword : ''
            } else {
                urlState.keyword ? state['keyword'] = encodeURIComponent(this.keyword) : ''
            }
            urlState.language ? state['language'] = urlState.language : ''
            urlState.category ? state['category'] = encodeURIComponent(urlState.category) : ''
            urlState.src ? state['src'] = urlState.src : ''
            //const url = '?' + new URLSearchParams(state).toString()
            let url = '?'
            //To form encoded URL from state Object 
            for (let key in state) {
                if (state.hasOwnProperty(key)) {
                    url += `${key}=${state[key]}&`
                }
            }
            url = url.slice(0, -1)
            window.history.pushState(state, '', url)
            this.fireSelectionEvent()
            this.handleCloseClick()
            this.publishHandler()
        }
    }
    fireSelectionEvent() {
        this.dispatchEvent(new CustomEvent('sendclient', {
            detail: {
                clientCode: this.clientCode,
                clientName: this.clientName,
                clientLogo: this.clientLogo,
                keyword: this.keyword && this.keyword.length >= 3 ? this.keyword : ''
            }
        }))
    }
    handleKeyPress(event) {
        if (event.key === 'Enter') {
            this.handleClientClick(event);
        }
    }


    //Trap focus inside modal
    handleFocusOut(event) {
        var related = event.relatedTarget;
        var dataindexval = related.getAttribute('data-index')


        if (dataindexval == '0') {
            // If focus is leaving, bring it back to the modal
            this.template.querySelectorAll('.clientName')[this.filteredClients.length - 1].focus();
        }
        else {
            if (dataindexval == '1') {
                // If focus is leaving, bring it back to the modal
                this.template.querySelector('.closeButton').focus();
            }
        }
    }
}