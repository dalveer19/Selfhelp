import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

import getContactInfoUrl from '@salesforce/apex/shp_ContactUs.getContactInfoUrl';


import { MessageContext, subscribe } from 'lightning/messageService';
import CHANNEL from '@salesforce/messageChannel/shpMessageChannel__c';

import Contact_us from '@salesforce/label/c.Contact_us';
import Still_have_questions from '@salesforce/label/c.Still_have_questions';
import View_contact_information from '@salesforce/label/c.View_contact_information';
import If_you_don_t_find_what_you_re_looking_for from '@salesforce/label/c.If_you_don_t_find_what_you_re_looking_for';

import LOGOS from '@salesforce/resourceUrl/Self_help';

export default class shp_ContactUs extends LightningElement {

    label_Contact_us = Contact_us
    label_Still_have_questions = Still_have_questions
    label_View_contact_information = View_contact_information
    label_If_you_don_t_find_what_you_re_looking_for = If_you_don_t_find_what_you_re_looking_for

    svgImage = LOGOS + '/SelfHelp/Icons/NeedMore.png'
    display = true
    currentPageReferenceState = {}
    accounts

    constructor() {
        super()
        //this.svgImage = LOGOS + '/SelfHelp/Icons/NeedMore.png'
    }

    @wire(MessageContext)
    context

    connectedCallback() {
        this.subscribeHandler();
       // this.viewContactInformation();
    }

    subscribeHandler() {
        subscribe(
            this.context,
            CHANNEL,
            (message) => { this.handleMessage(message) }
        )
    }
    handleMessage(message) {
        if (message) {
            this.clientCode = message.clientCode.value
            console.log('51:::::::', this.clientCode)
            this.clientName = message.clientCode.label
            if (this.clientName != null && this.clientName != '' && this.clientName != undefined) {
                this.display = false;
            }
            else {
                this.display = true;
            }
        }
    }


    viewContactInformation() {
        this.subscribeHandler()
        console.log('62::::::', this.clientCode);
        getContactInfoUrl({ clientCode: this.clientCode, language: this.language })
            .then(result => {
                console.log('70:::::', result);
                if (result) {
                    console.log('70:::::', result);
                    const languageUrl = result[0][this.language + '__c'];
                    console.log('72:::::', languageUrl);
                    // Open the URL in a new tab
                    if(languageUrl){
                        window.location.href = languageUrl;
                    }
                }
            })
            .catch(error => {
                // Handle error
                console.error(error);
            });
    }


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log(currentPageReference)
            this.currentPageReferenceState = currentPageReference.state
            this.recordId = currentPageReference.state?.recordId
            this.language = currentPageReference.state?.language
            this.keyword = currentPageReference.state?.keyword
            this.clientCode = currentPageReference.state?.clientCode
            this.pageName = currentPageReference.attributes?.name
            // If client ID already in URL -> Get the client
            if (this.clientCode == null || this.clientCode == '' || this.clientCode == undefined || this.clientCode.toLowerCase() == 'all') {
                this.display = true
            } else {
                this.display = false;
            }
        }
    }

}