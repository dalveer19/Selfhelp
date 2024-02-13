import { wire, LightningElement } from 'lwc';
//import LightningModal from 'lightning/modal';
import GetLanguage from '@salesforce/apex/shp_accountUtility.selfHelpLanguages';
import LOGOS from '@salesforce/resourceUrl/Self_help';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import Your_preferred_Language from '@salesforce/label/c.Your_preferred_Language';
import Language from '@salesforce/label/c.Language';
import Other_available_Languages from '@salesforce/label/c.Other_available_Languages';
import Apply from '@salesforce/label/c.Apply';
import Cancel from '@salesforce/label/c.Cancel';
import Close from '@salesforce/label/c.Close';

export default class shp_languageSelector extends NavigationMixin(LightningElement) {
    langArray = []
    language
    selectedLanguageBold
    selectedLanguage
    clientCode
    pageName
    keyword
    recordId
    langChange
    languagesLoading = true
    img
    i = 0
    labels = { Apply, Cancel, Other_available_Languages, Language, Your_preferred_Language }
    label_close = Close;


    //************************************************************* */

    // add all the elements inside modal which you want to make focusable
    focusableElements = 'button, div, [tabindex]:not([tabindex="-1"])';
    modal

    firstFocusableElement // get first element to be focused inside modal
    focusableContent
    lastFocusableElement  // get last element to be focused inside modal


    //firstFocusableElement.focus();

    //*************************************************************** */




    renderedCallback() {
        // To initially focus on the slds modal background as soon as the component loads
        if (this.i < 1) {
            try {
                this.template.querySelector('.closeButton').focus();
                this.i++;
            } catch (e) { }
        }
    }


    connectedCallback() {
        this.img = LOGOS + '/SelfHelp/Icons/Globe.png';
        //Adding Event listener for handling click 
        this.addEventListener('click', () => this.dispatchEvent(new CustomEvent('closelanguage')));
    }

    disconnectedCallback() {
        //Removing Event listener for handling click 
        this.removeEventListener('click', () => this.dispatchEvent(new CustomEvent('closelanguage')));
    }

    ignore(event) {
        event.stopPropagation();
        return false;
    }

    keyboardHandler(event) {
        if (event.keyCode == 27) {
            this.dispatchEvent(new CustomEvent('closelanguage'))
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.language = currentPageReference.state?.language || 'en_US';
            this.langChange = this.language
            this.recordId = currentPageReference.state?.recordId
            this.keyword = currentPageReference.state?.keyword
            this.clientCode = currentPageReference.state?.clientCode
            this.pageName = currentPageReference.attributes?.name;

            GetLanguage().then(result => {
                let langArray = result
                langArray.forEach(item => {
                    if (item.code == this.language) {
                        let label = item.display
                        this.selectedLanguageBold = label.includes(' ') ? label.substring(0, label.indexOf(' ')) : label
                        this.selectedLanguage = label.includes(' ') ? label.substring(label.indexOf(' ') + 1) : ''
                    } else {
                        this.langArray.push(item)
                    }
                })
                this.languagesLoading = false
            })
                .catch(error => {
                    this.languagesLoading = true
                    console.log('+++++++++', error)
                })
        }
    }

    handleClick(event) {
        this.langChange = event.target.dataset.id
        //this.handleSave(langChange)

        let arrayEle = this.template.querySelectorAll('.langBox')

        for (let i = 0; i < arrayEle.length; i++ ) {
            arrayEle[i].classList.remove('langBoxSelected')
        }

        this.template.querySelector(`[data-id="${this.langChange}"]`).classList.add('langBoxSelected')
    }

    handleLangClickKey(event) {
        if (event.keyCode === 13) {

            this.langChange = event.target.dataset.id
            //this.handleSave();
            let arrayEle = this.template.querySelectorAll('.langBox')

            for (let i = 0; i < arrayEle.length; i++ ) {
                arrayEle[i].classList.remove('langBoxSelected')
            }

            this.template.querySelector(`[data-id="${this.langChange}"]`).classList.add('langBoxSelected')
        }
    }

    handleSave() {
        //To show spinner while the document loads
        document.getElementsByClassName('siteforceSpinnerManager')[0].classList.remove('hideEl')
        //To replace language parameter in the current URL 
        var tempURL = window.location.href.toString()
        var href = new URL(tempURL);
        href.searchParams.set('language', this.langChange);
        window.location.assign(href.toString())
    }

    handleClose(event) {
        if (event) {
            this.dispatchEvent(new CustomEvent("closelanguage"));
        }
    }

    handleCloseKeyDown(event) {
        if (event.keyCode === 13) {
            this.handleClose(event);
        }
    }

    //Trap focus inside modal
    handleFocusOut(event) {
        var related = event.relatedTarget;
        var dataindexval = related.getAttribute('data-index')

        if (dataindexval == '0') {
            // If focus is leaving, bring it back to the modal
            this.template.querySelectorAll('.buttonCustom').forEach( item => item.focus())
        }
        else {
            if (dataindexval == '1') {
                // If focus is leaving, bring it back to the modal
                this.template.querySelector('.closeButton').focus();
            }
        }
    }
}