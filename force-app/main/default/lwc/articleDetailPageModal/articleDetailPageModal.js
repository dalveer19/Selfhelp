import { LightningElement, wire, api } from 'lwc';
import Testing_Program from '@salesforce/label/c.Testing_Program';
import All from '@salesforce/label/c.all';
import Select_Program from '@salesforce/label/c.Select_Program';
import Change_program from '@salesforce/label/c.Change_program';
import Common_Help_Topics from '@salesforce/label/c.Common_Help_Topics';
import Search_topics_and_get_answers from '@salesforce/label/c.Search_topics_and_get_answers';
import I_want_to_search_across_all_programs from '@salesforce/label/c.I_want_to_search_across_all_programs';
import I_know_my_testing_program from '@salesforce/label/c.I_know_my_testing_program';
import OPENS_IN_NEW_WINDOW from '@salesforce/label/c.opens_in_new_window';
import Close from '@salesforce/label/c.Close';
import getCommonHelpTopics from '@salesforce/apex/CommonHelpTopics.getCommonHelpTopics';
import { CurrentPageReference } from 'lightning/navigation';
import { getConstants } from 'c/constantUtil';
const CONSTANTS = getConstants();

export default class ArticleDetailPageModal extends LightningElement {
    isDetailsPage = false
    //@api nameofclient
    @api clientThere
    showModal = false
    @api clientName
    @api idOfClient
    currentPageReferenceState = {}
    helpTopics = []
    clientCode
    selectedProgram
    modalContentLoading = true
    i = 0
    //label_Testing_Program = Testing_Program
    label_All = All
    label_Select_Program = Select_Program
    label_hyperlink = Change_program
    label_CommonHelpTopics = Common_Help_Topics
    label_I_want_to_search_across_all_programs = I_want_to_search_across_all_programs;
    label_I_know_my_testing_program = I_know_my_testing_program;
    label_Search_topics_and_get_answers = Search_topics_and_get_answers;
    label_Opens_In_New_Window = OPENS_IN_NEW_WINDOW
    label_close = Close;

    @wire(CurrentPageReference)
    currentPageReferenceHandler(currentPageReference) {
        if (currentPageReference) {
            // Use the currentPageReference to extract query parameters
            const state = currentPageReference.state;
            if (state.language) {
                const language = state.language;

                // Call your @wire method with the language parameter
                this.currentPageReferenceState = state;
            }
        }
    }

    renderedCallback() {
        // To initially focus on the slds modal background as soon as the component loads
        if (this.i < 1) {
            this.template.querySelector('.closeWrap').focus();
            this.i++;
        }
    }

    connectedCallback() {
        //Adding Event listener for handling click 
        this.addEventListener('click', () => this.dispatchEvent(new CustomEvent('closearticlesearchmodal')));
    }

    disconnectedCallback() {
        //Removing Event listener for handling click 
        this.removeEventListener('click', () => this.dispatchEvent(new CustomEvent('closearticlesearchmodal')));
    }

    ignore(event) {
        event.stopPropagation();
        return false;
    }

    keyboardHandler(event) {
        if (event.keyCode == 27) {
            this.handleCloseClick()
        }
    }

    get helpTopicsExist() {
        return this.helpTopics && this.helpTopics.length > 0;
    }

    @api handleFocus() {
        this.template.querySelectorAll('.modalOptions')[1].focus();
    }

    @wire(getCommonHelpTopics, { language: '$currentPageReferenceState.language' })
    wiredHelpTopics({ data, error }) {
        if (data) {
            this.helpTopics = data
            this.modalContentLoading = false
            console.log(this.helpTopics);
        } else if (error) {
            // Handle error if necessary
            this.modalContentLoading = true
            console.error(error)
        }
    }

    isSelectedProgramSearchAllPrograms() {
        return this.selectedProgram === CONSTANTS.searchAllPrograms;
    }

    handleCloseClick() {
        this.dispatchEvent(new CustomEvent('closearticlesearchmodal')) //notify the parent to close the modal
    }

    handleCloseKeyDown(event) {
        if (event.keyCode == 13) {
            this.handleCloseClick();
        }
    }


    //notify the parent to open client selection modal to open
    openModal(event) {
        this.dispatchEvent(new CustomEvent('openmodalpopup'))
    }

    handleProgramSelection(event) {
        if (event.type === 'click' && event.clientX !== 0 && event.clientY !== 0) {
            this.handleProgram(event)
        }
    }

    handleProgram(event) {
        this.selectedProgram = event.target.value;
        if (this.selectedProgram == CONSTANTS.iknow) {
            this.openModal()
            this.selectedProgram = CONSTANTS.searchAllPrograms;
        }
    }

    handleProgramSelectionKeydown(event) {
        if (event.keyCode === 13) {
            this.handleProgram(event);
        }
    }

    //Trap focus inside modal
    handleFocusOut(event) {
        const modal = this.template.querySelector(`[data-id="articleModal"]`);
        var related = event.relatedTarget;
        var dataindexval = related.getAttribute('data-index')

        if (dataindexval == '0') {
            // If focus is leaving, bring it back to the modal
            let ele = this.template.querySelectorAll('.pb1')[this.helpTopics.length - 1]
            let focusEle = ele.querySelector('.helpLink2') || ele.querySelector('.helpLink')
            focusEle.focus();
        }
        else {
            if (dataindexval == '1') {
                // If focus is leaving, bring it back to the modal
                this.template.querySelector('.closeWrap').focus();
            }
        }
    }
}