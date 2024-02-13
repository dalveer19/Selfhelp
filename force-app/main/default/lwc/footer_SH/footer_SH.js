import { LightningElement, track, wire } from 'lwc';
import LOGOS from '@salesforce/resourceUrl/Self_help';
import DeviceSize from "@salesforce/client/formFactor";
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

import getFooterLinks from '@salesforce/apex/shp_FooterLinksController.getFooterLinks';

import Deliver_in_demand_label from '@salesforce/label/c.Deliver_in_demand_certification_exams_and_unleash_opportunity'
import Help_and_support from '@salesforce/label/c.Help_and_support'
import Scheduling from '@salesforce/label/c.Scheduling'
import Payment from '@salesforce/label/c.Payment'
import FOOTER_BG_ALT_TEXT from '@salesforce/label/c.footer_background_image'
import This_website_uses from '@salesforce/label/c.This_website_uses'
import cookies from '@salesforce/label/c.cookies'
import Cookies_preferences from '@salesforce/label/c.Cookies_preferences'
import PEARSON from '@salesforce/label/c.pearsonvue_com';
import PEARSON_LOGO_FOOTER from '@salesforce/label/c.Pearson_Logo';

import Copyright_Statement from '@salesforce/label/c.Copyright_Statement';
import Suffix_of_this_website_uses from '@salesforce/label/c.Suffix_of_this_website_uses';
import Cookies_Link from '@salesforce/label/c.Cookies_Link';

import GetLanguage from '@salesforce/apex/shp_accountUtility.getLanguage';

import FooterLink1 from '@salesforce/label/c.FooterLink1';
import Account_Login from '@salesforce/label/c.Account_Login';
import Test_Day_Preparation from '@salesforce/label/c.Test_Day_Preparation';
import Test_Day from '@salesforce/label/c.Test_Day';
import OPENS_IN_NEW_WINDOW from '@salesforce/label/c.opens_in_new_window';
import Exam_Results from '@salesforce/label/c.Exam_Results';
import Accommodations from '@salesforce/label/c.Accommodations';

// Import constants from util
import { getConstants } from 'c/constantUtil';
const CONSTANTS = getConstants();

//importing LMS
import CHANNEL from '@salesforce/messageChannel/shpMessageChannel__c';
import { MessageContext, subscribe } from 'lightning/messageService';

export default class Footer_SH extends NavigationMixin(LightningElement) {

    pearsonLogoFooter = PEARSON_LOGO_FOOTER
    footerBGAltTextLabel = FOOTER_BG_ALT_TEXT
    label_Opens_In_New_Window = OPENS_IN_NEW_WINDOW
    @track svgImage = LOGOS + '/SelfHelp/Icons/Hero_img.png';
    pearsonLogo
    cookiesIcon
    keyword
    recordId
    language
    clientCode
    @track left_bg = LOGOS + '/SelfHelp/Icons/left_bg.png';
    showLang
    selectedLanguage
    labels = {
        Scheduling, Deliver_in_demand_label, Help_and_support, Payment,
        This_website_uses, cookies, Cookies_preferences,
        FooterLink1, Account_Login, Copyright_Statement, Suffix_of_this_website_uses, Cookies_Link,
        Test_Day_Preparation, Test_Day, Exam_Results, Accommodations
    }
    linksColumn1 = []
    linksColumn2 = []
    linksColumn3 = []
    footerLinksLoading = true
    @track showSvgImage = false
    category

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state?.recordId;
            this.language = currentPageReference.state?.language;
            this.keyword = currentPageReference.state?.keyword;
            this.clientCode = currentPageReference.state?.clientCode;
            this.pageName = currentPageReference.attributes?.name;
            this.category = currentPageReference.attributes?.category;
            console.log('-----------', this.pageName)
            if (this.language) {
                GetLanguage({ langCode: this.language }).then(result =>
                    this.selectedLanguage = result
                ).then(() => {
                    this.getFooterLinksMethod(this.language)
                })
                    .catch(error => console.log(error))
            }
            //To render footer image based on the page
            if (this.pageName == CONSTANTS.searchResultsPage) {
                this.svgImage = LOGOS + '/SelfHelp/Icons/Hero_Search_Result.png';
            }
            this.showSvgImage = (this.pageName == CONSTANTS.detailPage || (this.clientCode && this.clientCode.toString().toLowerCase() != 'all' && this.pageName == 'Home' )) ? false : true;
        }
        console.log('100:', currentPageReference)
    }

    @wire(MessageContext)
    context

    connectedCallback() {
        this.subscribeHandler()
    }

    subscribeHandler() {
        subscribe(
            this.context,
            CHANNEL,
            (message) => { this.handleMessage(message) }
        )
    }

    handleMessage(message) {
        if (message && message.clientCode && message.clientCode.value.toString().toLowerCase() == 'all' && this.pageName == 'Home' ) {
            this.showSvgImage = true
        } else if(this.pageName == 'Home') {
            this.showSvgImage = false
        }
        
        if (message.clientCode) {
            this.clientCode = message.clientCode.value
        }
    }

    getFooterLinksMethod(language) {
        getFooterLinks({ language: language }).then(result => {
            if (!result.errorMsg) {
                result.forEach(item => {
                    if (item.columnNumber == 1) {
                        this.linksColumn1.push(item);
                    }
                    if (item.columnNumber == 2) {
                        this.linksColumn2.push(item);
                    }
                    if (item.columnNumber == 3) {
                        this.linksColumn3.push(item);
                    }
                })
            }
            console.log(this.linksColumn1)
            console.log(this.linksColumn2)
            console.log(this.linksColumn3)
            this.footerLinksLoading = false
        })
    }

    homeHandler() {
        window.location.href = PEARSON;
    }

    handlePearsonLogoKeyPress(event) {
        console.log("key pearson logo")
        if (event.keyCode === 13) {
            this.homeHandler();
        }
    }

    /*  showCookiesCustomizeModalChild = false
        cookiesModalChildHandler(event) {
            event.preventDefault()
            this.showCookiesCustomizeModalChild = true
        }
        handleCookieConsent() {
            this.showCookiesCustomizeModalChild = false
        } */

    handleLang() {
        this.showLang = true
        document.body.style.overflow = 'hidden'
    }

    

    handleCloseLang() {
        this.showLang = false
        document.body.style.overflow = 'auto'
        //to remove language selector accessibility focus trap
        window.dispatchEvent(new CustomEvent('langSlctrTabRemove'))
        let langSelectorIcon = this.template.querySelectorAll('.languageButton')
        for (let i = 0; i < langSelectorIcon.length; i++) {
            langSelectorIcon[i].focus()
        }
    }

    handleDataCatClick(event) {
        console.log('map184', this.clientCode)
        const dataCatsMap = new Map([[Account_Login, "Account_Login"], [Scheduling, "Scheduling"], [Payment, "Payment"], [Test_Day_Preparation, "Test_Day_Preparation"], [Test_Day, "Test_Day"], [Exam_Results, "Exam_Results"], [Accommodations, "Accommodations"]])
        console.log('tempmap', dataCatsMap)
        let tempCategory = event.currentTarget.name
        console.log('temp', tempCategory)
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: CONSTANTS.searchResultsPage
            },
            state: {
                language: this.language,
                clientCode: this.clientCode,
                category: dataCatsMap.get(tempCategory),
                src: this.pageName
            }
        })
            .then(url => {
                window.location.assign(url)
            });
    }
}