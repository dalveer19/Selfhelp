import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getClients from '@salesforce/apex/SHP_SearchContainerController.getClients';

import Isguest from '@salesforce/user/isGuest';
import UserLanguage from '@salesforce/i18n/lang';

import Hi_How_can_we_help from '@salesforce/label/c.Hi_How_can_we_help';
import Search_topics_and_get_answers from '@salesforce/label/c.Search_topics_and_get_answers';
import I_want_to_search_across_all_programs from '@salesforce/label/c.I_want_to_search_across_all_programs';
import I_know_my_testing_program from '@salesforce/label/c.I_know_my_testing_program';
import Change_program from '@salesforce/label/c.Change_program';
import Testing_Program from '@salesforce/label/c.Testing_Program';
import All from '@salesforce/label/c.all';
import Select_Program from '@salesforce/label/c.Select_Program';
import LogoURL from '@salesforce/label/c.LogoURL';
import LOGOS from '@salesforce/resourceUrl/Self_help';
import { getConstants } from 'c/constantUtil';
const CONSTANTS = getConstants();


export default class KnowledgeArticleSearchContainer extends LightningElement {
    showModal = false;
    selectedProgram = CONSTANTS.searchAllPrograms;
    clientCode;
    right_bg;
    recordId
    language
    keyword
    pageName
    clientName;
    clientLogo;
    currentPageReferenceState = {}
    clientBackground;
    logoUrlString

    isClientThere = false;
    label_Hi_How_can_we_help = Hi_How_can_we_help;
    label_Search_topics_and_get_answers = Search_topics_and_get_answers;
    label_I_want_to_search_across_all_programs = I_want_to_search_across_all_programs;
    label_I_know_my_testing_program = I_know_my_testing_program;
    label_hyperlink = Change_program;
    //label_Testing_Program = Testing_Program;
    label_All = All;
    label_Select_Program = Select_Program;
    labelUrl = LogoURL;


    constructor() {
        super()
        this.clientBackground = LOGOS + '/SelfHelp/Icons/clientSelectionVector.png';
    }

    connectedCallback() {
        document.body.style.overflow = 'auto'
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.currentPageReferenceState = currentPageReference.state
            this.recordId = currentPageReference.state?.recordId
            this.language = this.languageCheck(currentPageReference)
            this.keyword = currentPageReference.state?.keyword
            this.clientCode = currentPageReference.state?.clientCode
            this.pageName = currentPageReference.attributes?.name

            // If client ID already in URL -> Get the client details
            if (this.clientCode && this.clientCode != CONSTANTS.All) {
                this.isClientThere = true
                getClients({ clientCode: this.clientCode }).then(result => {
                    //console.log('resultresultresultresult', result)
                    if (result.errorMsg) {
                        console.error(result.errorMsg)

                        //to show spinner, we are removing the hideEl class from Salesforce standard spinner block
                        document.querySelector('.siteforceSpinnerManager').classList.remove('hideEl')

                        // STARTS ---------- To remove clientCode from the URL & reload the entire page
                        const newUrl = new URL(location.href);
                        newUrl.searchParams.delete('clientCode');
                        window.location.assign(newUrl.href);
                        //  ENDS ------------ To remove clientCode from the URL & reload the entire page

                        this.isClientThere = false;

                    } else {
                        this.isClientThere = true
                        this.clientLogo = result.clientLogoUrl ? result.clientLogoUrl : ''
                        //this.clientLogo = result.selectedClient.Logo__c ? result.selectedClient.Logo__c : ''
                        this.clientName = result.selectedClient.Name
                    }
                })
                    .catch(error => {
                        this.isClientThere = false;
                        console.log('error', error);
                    })
            } else {
                this.isClientThere = false;
            }
        }
    }

    keyboardHandler() {
        this.showModal = false
    }

    openModal() {
        this.showModal = true;
        document.body.style.overflow = 'hidden'
    }

    openModalRadio(event) {
        if (event.keyCode === 13) {
            this.openModal()
        }
    }

    closeModal() {
        this.showModal = false;
        this.selectedProgram = CONSTANTS.searchAllPrograms;
        document.body.style.overflow = 'auto'
        if (this.template.querySelector('.changePro')) {
            this.template.querySelector('.changePro').focus();
        } else if (this.template.querySelectorAll('.searchRadio')) {
            this.template.querySelectorAll('.searchRadio')[1].focus();
        }
    }

    handleProgramSelection(event) {
        //To confirm if the event is a real click & not arrow buttons click
        if (event.type === 'click' && event.clientX !== 0 && event.clientY !== 0) {
            this.openModal()
            //this.showModal = true
        }
        this.selectedProgram = event.target.value;
        if (this.selectedProgram !== CONSTANTS.iknow) {
            this.closeModal();
            this.selectedProgram = CONSTANTS.searchAllPrograms;
        }
    }

    get isSelectedProgramSearchAllPrograms() {
        return this.selectedProgram === CONSTANTS.searchAllPrograms;
    }

    resetProgram() {
        this.selectedProgram = CONSTANTS.searchAllPrograms;
    }

    handleRemoveClient() {
        this.clientCode = CONSTANTS.All
        this.selectedProgram = CONSTANTS.searchAllPrograms;
        this.isClientThere = false;
        this.closeModal();
        setTimeout(() => {
            this.template.querySelector('.searchRadio').focus();
        }, 100)
    }

    handleClientSelected(event) {
        this.clientCode = event.detail.clientCode;
        this.clientName = event.detail.clientName;
        getClients({ clientCode: this.clientCode }).then(result => {
            //console.log('resultresultresultresult', result)
            if (result.errorMsg) {
                console.error(result.errorMsg)
            } else {
                this.clientLogo = result.clientLogoUrl ? result.clientLogoUrl : ''
            }
        })
            .catch(error => {
                console.log('error', error);
            })
        //this.clientLogo = event.detail.clientLogo;
        if (this.clientCode && this.clientCode != CONSTANTS.All) {
            this.isClientThere = true
            this.template.querySelector('c-search-Bar-With-Suggestions-Child-V1').callApex(this.clientCode)
            setTimeout(() => {
                this.template.querySelector('.changePro').focus();
            }, 100)
        } else {
            this.isClientThere = false
        }
        this.dispatchEvent(new CustomEvent('sendclient', {
            detail: { clientName: this.clientName }
        }));

    }

    renderedCallback() {
        this.right_bg = LOGOS + '/SelfHelp/Icons/right_bg.png';
    }

    // To handle the page translations as per guest & logged in user's language
    languageCheck(currentPageReference) {
        //Check if language parameter is in URL & matches with the avialable languages
        if (currentPageReference.state?.language && CONSTANTS.languagesList.includes(currentPageReference.state?.language)) {
            return currentPageReference.state?.language
        }
        //Logic if language parameter is not in the URL
        else {
            let lang = Isguest ? 'en_US' : (CONSTANTS.languagesList.includes(UserLanguage) ? UserLanguage : 'en_US')

            //to replace the language parameter in URL
            var tempURL = window.location.href.toString()
            var href = new URL(tempURL);
            href.searchParams.set('language', lang);
            window.location.assign(href.toString())
        }
    }

}