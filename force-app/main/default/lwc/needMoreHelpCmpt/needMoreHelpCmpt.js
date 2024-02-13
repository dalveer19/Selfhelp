import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

import { MessageContext, subscribe } from 'lightning/messageService';
import CHANNEL from '@salesforce/messageChannel/shpMessageChannel__c';

import Select_testing_program from '@salesforce/label/c.Select_testing_program';
import We_recommend_selecting_your_testing_program_first from '@salesforce/label/c.We_recommend_selecting_your_testing_program_first';
import Let_s_get_you_answers from '@salesforce/label/c.Let_s_get_you_answers';
import If_you_don_t_find_what_you_re_looking_for from '@salesforce/label/c.If_you_don_t_find_what_you_re_looking_for';
import Need_More_Help from '@salesforce/label/c.Need_More_Help';
import phonenumber from '@salesforce/label/c.phonenumber';
import email_clientname_com from '@salesforce/label/c.email_clientname_com';
//import You_can_reach_out_directly_to_your_testing_program from '@salesforce/label/c.You_can_reach_out_directly_to_your_testing_program';

import LOGOS from '@salesforce/resourceUrl/Self_help';

export default class NeedMoreHelpCmpt extends LightningElement {

    label_Need_More_Help = Need_More_Help
    label_Let_s_get_you_answers = Let_s_get_you_answers
    label_We_recommend_selecting_your_testing_program_first = We_recommend_selecting_your_testing_program_first
    label_If_you_don_t_find_what_you_re_looking_for = If_you_don_t_find_what_you_re_looking_for
    label_Select_testing_program = Select_testing_program
    label_phonenumber = phonenumber
    label_emailclientnamecom = email_clientname_com
  //  label_You_can_reach_out_directly_to_your_testing_program = You_can_reach_out_directly_to_your_testing_program

    svgImage = LOGOS + '/SelfHelp/Icons/NeedMore.png'
    display = true
    showModal = false
    currentPageReferenceState = {}
    keyword

    constructor() {
        super()
       
       // this.svgImage = LOGOS + '/SelfHelp/Icons/NeedMore.png'
    }

    @wire(MessageContext)
    context

    connectedCallback() {
        this.subscribeHandler();
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
            this.clientName = message.clientCode.label
            if (this.clientName != null && this.clientName != '' && this.clientName != undefined) {
                this.display = false;
            }
            else{
                this.display = true;
            }
        }
    }

    selectTestingProgram() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
        let langSelectorIcon = this.template.querySelector('.testProgramBtn')
        langSelectorIcon.focus()
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
            console.log('49:::::::', this.clientCode);
            // If client ID already in URL -> Get the client
            console.log('61::::', this.keyword);
            if (this.clientCode == null || this.clientCode == '' || this.clientCode == undefined || this.clientCode.toLowerCase() == 'all') {
                this.display = true
            } else {
                this.display = false;
            }
        }
    }

}