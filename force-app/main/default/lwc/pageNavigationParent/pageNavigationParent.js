import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';

import LOGOS from '@salesforce/resourceUrl/Self_help';
import FORM_FACTOR from "@salesforce/client/formFactor";
import getKnowledgeDetails from '@salesforce/apex/ArticleController.getKnowledgeDetails';
import getClients from '@salesforce/apex/SHP_SearchContainerController.getClients';
import getDataCategoryLabel from '@salesforce/apex/DataCategoryController.getDataCategoryLabel';
//importing LMS
import CHANNEL from '@salesforce/messageChannel/shpMessageChannel__c';
import { MessageContext, subscribe } from 'lightning/messageService';
// Importing constants from constants JS helper
import { getConstants } from 'c/constantUtil';
const CONSTANTS = getConstants();
//Custom Labels
import Close from '@salesforce/label/c.Close';
import Before_you_go from '@salesforce/label/c.Before_you_go';
import HelpHomePopUpMessage from '@salesforce/label/c.HelpHomePopUpMessage';
import Do_you_want_to_continue from '@salesforce/label/c.Do_you_want_to_continue';
import No from '@salesforce/label/c.No';
import Yes from '@salesforce/label/c.Yes';
import Help_home from '@salesforce/label/c.Help_home';
import Search_results from '@salesforce/label/c.Search_results';

export default class PageNavigationParent extends NavigationMixin(LightningElement) {

    @track pages = []
    currentPageName
    homePageName
    recordId
    language
    keyword
    clientCode
    src
    pageName
    clientName
    resultdata
    @track category
    @track categoryLabel
    showCrumbs = false
    @track showPopUp = false
    hikingImage = LOGOS + '/SelfHelp/Icons/Hikingimage.png';
    @track imageLoading = true
    url
    tempKeyword
    tempCategory =''
    @api parentClientCode
    i = 0

    //Labels
    labelClose = Close
    labelBeforeYouGo = Before_you_go
    labelHelpHomePopUpMessage = HelpHomePopUpMessage
    labelDoyouwanttocontinue = Do_you_want_to_continue
    labelNo = No
    labelYes = Yes
    labelHelpHome = Help_home
    labelSearchResults = Search_results


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state?.recordId
            this.language = currentPageReference.state?.language || 'en_US'
            this.keyword = currentPageReference.state?.keyword || ''
            this.clientCode = currentPageReference.state?.clientCode || CONSTANTS.All
            this.category = currentPageReference.state?.category || ''
            this.pageName = currentPageReference.attributes?.name
            this.src = currentPageReference.state?.src || ''
            
        }
        console.log("24::", currentPageReference)
    }

    @wire(MessageContext)
    context

    async connectedCallback() {
        //this.src = sessionStorage.getItem("src")
        this.subscribeHandler()
        if(this.category != ''){
            await this.getCategoryLabel(this.category)
        }
        else{
            if (this.parentClientCode) {
                this.clientCode = this.parentClientCode
                this.generateBreadcrumbs(this.clientCode, this.category)
            } else {
                this.generateBreadcrumbs(this.clientCode, this.category)
            }
        }
        //Adding event listener for opening modal on click 
        this.addEventListener('click', () => this.handleCloseClick());

    }

    disconnectedCallback() {
        //Removing event listener for closing modal on click
        this.removeEventListener('click', () => this.handleCloseClick());

    }

    renderedCallback() {
        try {
            this.template.querySelector('.closeButton').focus();
            window.dispatchEvent(new CustomEvent('breadcrumbtab'))
        } catch (e) {
            console.log(e)
        }
    }

    //handler to stop event propogation 
    ignore(event) {
        event.stopPropagation();
        return false;
    }

    //Handle ESCAPE key press on the DOM
    keyboardHandler(event) {
        if (event.keyCode == 27) {
            this.handleCloseClick()
        }
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
            if (message.clientCode.value) {
                this.clientCode = message.clientCode.value
                this.clientName = message.clientCode.label
            }
            // if (message.keyword) {
            //     this.keyword = message.keyword
            // }
        }
        console.log('24b',message)
        this.generateBreadcrumbs(this.clientCode, this.category)
    }

    getCategoryLabel(dataCatName){
        getDataCategoryLabel({ dataCategoryName: dataCatName })
            .then(result => {
                this.categoryLabel = result
        }).then(() => {
            if (this.parentClientCode) {
                this.clientCode = this.parentClientCode
                this.generateBreadcrumbs(this.clientCode, this.category)
            } else {
                this.generateBreadcrumbs(this.clientCode, this.category)
            }
        })
        .catch(error => {
            console.error(error);
        })
    }

    generateBreadcrumbs(clientValue, categoryValue) {
        console.log('24key',this.keyword)
        this.showCrumbs = false;
        this.pages = []
        this.tempCategory=''

        if (clientValue == null || clientValue == undefined || clientValue == '' || clientValue.toLowerCase() == 'all') {
            this.tempCategory = this.categoryLabel
            this.pages = [{ name: CONSTANTS.homePage, label: this.labelHelpHome, url: window.location.origin + basePath }];
            if (this.pageName == CONSTANTS.homePage) {
                this.pages = []
                this.currentPageName = ''
            }
            if (this.src == CONSTANTS.homePage) {
                if (this.pageName == CONSTANTS.searchResultsPage) {
                    if (this.tempCategory) {
                        if (this.keyword) {
                            if (this.labelSearchResults.length > 20) {
                                this.currentPageName = this.labelSearchResults.slice(0, 20) + '...'
                            }
                            else {
                                this.currentPageName = this.labelSearchResults
                            }
                            this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                            if (FORM_FACTOR == CONSTANTS.small) {
                                if (this.tempCategory.length > 4) {
                                    this.tempCategory = this.tempCategory.slice(0, 4) + '...'
                                }
                            }
                            else {
                                if (this.tempCategory.length > 20) {
                                    this.tempCategory = this.tempCategory.slice(0, 20) + '...'
                                }
                            }
                            this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                        }
                        else {
                            if (FORM_FACTOR == CONSTANTS.small) {
                                if (this.tempCategory.length > 4) {
                                    this.currentPageName = this.tempCategory.slice(0, 4) + '...'
                                }
                                else{
                                    this.currentPageName = this.tempCategory
                                }
                            }
                            else {
                                if (this.tempCategory.length > 20) {
                                    this.currentPageName = this.tempCategory.slice(0, 20) + '...'
                                }
                                else{
                                    this.currentPageName = this.tempCategory
                                }
                            }
                        }
                    }
                    else {
                        if (this.labelSearchResults.length > 20) {
                            this.currentPageName = this.labelSearchResults.slice(0, 20) + '...'
                        }
                        else {
                            this.currentPageName = this.labelSearchResults
                        }
                    }
                }
                else if (this.pageName == CONSTANTS.homePage) {
                    this.pages = []

                    this.currentPageName = ''
                }
                else {
                    if (this.pageName == CONSTANTS.detailPage) {
                        this.getArticleTitle()
                    }
                }
            }

            else if (this.src == CONSTANTS.searchResultsPage) {
                if (this.pageName == CONSTANTS.searchResultsPage) {
                    if (this.tempCategory) {
                        if (this.keyword) {
                            if (this.labelSearchResults.length > 20) {
                                this.currentPageName = this.labelSearchResults.slice(0, 20) + '...'
                            }
                            else {
                                this.currentPageName = this.labelSearchResults
                            }
                            this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                            if (FORM_FACTOR == CONSTANTS.small) {
                                if (this.tempCategory.length > 4) {
                                    this.tempCategory = this.tempCategory.slice(0, 4) + '...'
                                }
                            }
                            else {
                                if (this.tempCategory.length > 20) {
                                    this.tempCategory = this.tempCategory.slice(0, 20) + '...'
                                }
                            }
                            this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                        }
                        else {
                            if (FORM_FACTOR == CONSTANTS.small) {
                                if (this.tempCategory.length > 4) {
                                    this.currentPageName = this.tempCategory.slice(0, 4) + '...'
                                }
                                else{
                                    this.currentPageName = this.tempCategory
                                }
                            }
                            else {
                                if (this.tempCategory.length > 20) {
                                    this.currentPageName = this.tempCategory.slice(0, 20) + '...'
                                }
                                else{
                                    this.currentPageName = this.tempCategory
                                }
                            }
                        }
                    }
                    else {
                        if (this.labelSearchResults.length > 20) {
                            this.currentPageName = this.labelSearchResults.slice(0, 20) + '...'
                        }
                        else {
                            this.currentPageName = this.labelSearchResults
                        }
                    }
                }
                else if (this.pageName == CONSTANTS.homePage) {
                    this.pages = []
                }
                else {
                    if (this.pageName == CONSTANTS.detailPage) {
                        if (this.tempCategory) {
                            if (this.keyword) {
                                if (FORM_FACTOR == CONSTANTS.small) {
                                    if (this.tempCategory.length > 4) {
                                        this.tempCategory = this.tempCategory.slice(0, 4) + '...'
                                    }
                                    this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                                    this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                    this.updateUrl(this.keyword, this.language, clientValue, categoryValue, this.src,'searchresultsurl')
                                    this.pages.push({ name: CONSTANTS.searchResultsPage, label: this.labelSearchResults.slice(0, 4) + '...', url: window.location.origin + basePath + '/article-search-results' + this.url });
                                }
                                else {
                                    if (this.tempCategory.length > 20) {
                                        this.tempCategory = this.tempCategory.slice(0, 20) + '...'
                                    }
                                    this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                                    this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                    this.updateUrl(this.keyword, this.language, clientValue, categoryValue, this.src,'searchresultsurl')
                                    this.pages.push({ name: CONSTANTS.searchResultsPage, label: this.labelSearchResults, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                }
                                this.getArticleTitle()
                            }
                            else {
                                this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                                if (FORM_FACTOR == CONSTANTS.small) {
                                    if (this.tempCategory.length > 4) {
                                        this.tempCategory = this.tempCategory.slice(0, 4) + '...'
                                    }
                                }
                                else {
                                    if (this.tempCategory.length > 20) {
                                        this.tempCategory = this.tempCategory.slice(0, 20) + '...'
                                    }
                                }
                                this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                this.getArticleTitle()
                            }
                        }
                        else {
                            if (FORM_FACTOR == CONSTANTS.small) {
                                this.updateUrl(this.keyword, this.language, clientValue, categoryValue, this.src,'searchresultsurl')
                                this.pages.push({ name: CONSTANTS.searchResultsPage, label: this.labelSearchResults.slice(0, 4) + '...', url: window.location.origin + basePath + '/article-search-results' + this.url });
                            }
                            else {
                                this.updateUrl(this.keyword, this.language, clientValue, categoryValue, this.src,'searchresultsurl')
                                this.pages.push({ name: CONSTANTS.searchResultsPage, label: this.labelSearchResults, url: window.location.origin + basePath + '/article-search-results' + this.url });
                            }
                            this.getArticleTitle()
                        }
                    }
                }
            }
            else {
                if (this.src == CONSTANTS.detailPage) {
                    if (this.pageName == CONSTANTS.searchResultsPage) {
                        if (this.tempCategory) {
                            if (this.keyword) {
                                if (this.labelSearchResults.length > 20) {
                                    this.currentPageName = this.labelSearchResults.slice(0, 20) + '...'
                                }
                                else {
                                    this.currentPageName = this.labelSearchResults
                                }
                                this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                                if (FORM_FACTOR == CONSTANTS.small) {
                                    if (this.tempCategory.length > 4) {
                                        this.tempCategory = this.tempCategory.slice(0, 4) + '...'
                                    }
                                }
                                else {
                                    if (this.tempCategory.length > 20) {
                                        this.tempCategory = this.tempCategory.slice(0, 20) + '...'
                                    }
                                }
                                this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                            }
                            else {
                                if (this.tempCategory > 20) {
                                    this.currentPageName = this.tempCategory.slice(0, 20) + '...'
                                }
                                else {
                                    this.currentPageName = this.tempCategory
                                }
                            }
                        }
                        else {
                            if (this.labelSearchResults.length > 20) {
                                this.currentPageName = this.labelSearchResults.slice(0, 20) + '...'
                            }
                            else {
                                this.currentPageName = this.labelSearchResults
                            }
                        }

                    }
                    else if (this.pageName == CONSTANTS.homePage) {
                        this.pages = []
                    }
                    else {
                        if (this.pageName == CONSTANTS.detailPage) {
                            if (this.tempCategory) {
                                this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                                if (FORM_FACTOR == CONSTANTS.small) {
                                    if (this.tempCategory.length > 4) {
                                        this.tempCategory = this.tempCategory.slice(0, 4) + '...'
                                    }
                                }
                                else {
                                    if (this.tempCategory.length > 20) {
                                        this.tempCategory = this.tempCategory.slice(0, 20) + '...'
                                    }
                                }
                                this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                this.getArticleTitle()
                            }
                            else {
                                this.getArticleTitle()
                            }
                        }
                    }
                }
            }
        }
        else {
            if (clientValue != '' && clientValue.toLowerCase() != 'all') {
                this.tempCategory = this.categoryLabel
                this.pages = [{ name: CONSTANTS.homePage, label: this.labelHelpHome, url: window.location.origin + basePath }];
                getClients({ clientCode: clientValue }).then(result => {
                    if (result.errorMsg) {
                        console.error(result.errorMsg)
                    } else {
                        this.clientName = result.selectedClient.Name
                        if (this.pageName == CONSTANTS.homePage) {
                            if (this.clientName.length > 20) {
                                this.currentPageName = this.clientName.slice(0, 20) + '...'
                            }
                            else {
                                this.currentPageName = this.clientName
                            }
                        }
                        if (this.src == CONSTANTS.homePage) {
                            if (this.pageName == CONSTANTS.searchResultsPage) {
                                if (this.tempCategory) {
                                    if (this.keyword) {
                                        if (this.labelSearchResults.length > 20) {
                                            this.currentPageName = this.labelSearchResults.slice(0, 20) + '...'
                                        }
                                        else {
                                            this.currentPageName = this.labelSearchResults
                                        }
                                        if (FORM_FACTOR == CONSTANTS.small) {
                                            if (this.clientName.length > 4) {
                                                this.clientName = this.clientName.slice(0, 4) + '...'
                                            }
                                        }
                                        else {
                                            if (this.clientName.length > 20) {
                                                this.clientName = this.clientName.slice(0, 20) + '...'
                                            }
                                        }
                                        this.tempKeyword = ''
                                        this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                        this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                        this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                                        if (FORM_FACTOR == CONSTANTS.small) {
                                            if (this.tempCategory.length > 4) {
                                                this.tempCategory = this.tempCategory.slice(0, 4) + '...'
                                            }
                                        }
                                        else {
                                            if (this.tempCategory.length > 20) {
                                                this.tempCategory = this.tempCategory.slice(0, 20) + '...'
                                            }
                                        }
                                        this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                    }
                                    else {
                                        if (this.labelSearchResults.length > 20) {
                                            this.currentPageName = this.tempCategory.slice(0, 20) + '...'
                                        }
                                        else {
                                            this.currentPageName = this.tempCategory
                                        }
                                        if (FORM_FACTOR == CONSTANTS.small) {
                                            if (this.clientName.length > 4) {
                                                this.clientName = this.clientName.slice(0, 4) + '...'
                                            }
                                        }
                                        else {
                                            if (this.clientName.length > 20) {
                                                this.clientName = this.clientName.slice(0, 20) + '...'
                                            }
                                        }
                                        this.tempKeyword = ''
                                        this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                        this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                    }
                                }
                                else {
                                    if (this.labelSearchResults.length > 20) {
                                        this.currentPageName = this.labelSearchResults.slice(0, 20) + '...'
                                    }
                                    else {
                                        this.currentPageName = this.labelSearchResults
                                    }
                                    if (FORM_FACTOR == CONSTANTS.small) {
                                        if (this.clientName.length > 4) {
                                            this.clientName = this.clientName.slice(0, 4) + '...'
                                        }
                                    }
                                    else {
                                        if (this.clientName.length > 20) {
                                            this.clientName = this.clientName.slice(0, 20) + '...'
                                        }
                                    }
                                    this.tempKeyword = ''
                                    this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                    this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                }
                            }
                            else if (this.pageName == CONSTANTS.homePage) {
                                if (this.clientName.length > 20) {
                                    this.currentPageName = this.clientName.slice(0, 20) + '...'
                                }
                                else {
                                    this.currentPageName = this.clientName
                                }
                            }
                            else {
                                if (this.pageName == CONSTANTS.detailPage) {
                                    if (this.tempCategory) {
                                        if (FORM_FACTOR == CONSTANTS.small) {
                                            if (this.clientName.length > 4) {
                                                this.clientName = this.clientName.slice(0, 4) + '...'
                                            }
                                        }
                                        else {
                                            if (this.clientName.length > 20) {
                                                this.clientName = this.clientName.slice(0, 20) + '...'
                                            }
                                        }
                                        this.tempKeyword = ''
                                        this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                        this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                        this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                                        if (FORM_FACTOR == CONSTANTS.small) {
                                            if (this.tempCategory.length > 4) {
                                                this.tempCategory = this.tempCategory.slice(0, 4) + '...'
                                            }
                                        }
                                        else {
                                            if (this.tempCategory.length > 20) {
                                                this.tempCategory = this.tempCategory.slice(0, 20) + '...'
                                            }
                                        }
                                        this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                        this.getArticleTitle()
                                    }
                                    else {
                                        if (FORM_FACTOR == CONSTANTS.small) {
                                            if (this.clientName.length > 4) {
                                                this.clientName = this.clientName.slice(0, 4) + '...'
                                            }
                                        }
                                        else {
                                            if (this.clientName.length > 20) {
                                                this.clientName = this.clientName.slice(0, 20) + '...'
                                            }
                                        }
                                        this.tempKeyword = ''
                                        this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                        this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                        this.getArticleTitle()
                                    }
                                }
                            }
                        }
                        else if (this.src == CONSTANTS.searchResultsPage) {
                            if (this.pageName == CONSTANTS.searchResultsPage) { 
                                if(this.tempCategory){
                                    if(this.keyword){
                                        if (FORM_FACTOR == CONSTANTS.small) {
                                            if (this.clientName.length > 4) {
                                                this.clientName = this.clientName.slice(0, 4) + '...'
                                            }
                                        }
                                        else {
                                            if (this.clientName.length > 20) {
                                                this.clientName = this.clientName.slice(0, 20) + '...'
                                            }
                                            // else {
                                            //     this.clientName = this.clientName
                                            // }
                                        }
                                        this.tempKeyword = ''
                                        this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                        this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                        this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                                        if (FORM_FACTOR == CONSTANTS.small) {
                                            if (this.tempCategory.length > 4) {
                                                this.tempCategory = this.tempCategory.slice(0, 4) + '...'
                                            }
                                        }
                                        else {
                                            if (this.tempCategory.length > 20) {
                                                this.tempCategory = this.tempCategory.slice(0, 20) + '...'
                                            }
                                        }
                                        this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                        if (this.labelSearchResults.length > 20) {
                                            this.currentPageName = this.labelSearchResults.slice(0, 20) + '...'
                                        }
                                        else {
                                            this.currentPageName = this.labelSearchResults
                                        }
                                    }
                                    else{
                                        if (FORM_FACTOR == CONSTANTS.small) {
                                            if (this.clientName.length > 4) {
                                                this.clientName = this.clientName.slice(0, 4) + '...'
                                            }
                                        }
                                        else {
                                            if (this.clientName.length > 20) {
                                                this.clientName = this.clientName.slice(0, 20) + '...'
                                            }
                                        }
                                        this.tempKeyword = ''
                                        this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                        this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                        if (FORM_FACTOR == CONSTANTS.small) {
                                            if (this.tempCategory.length > 4) {
                                                this.currentPageName = this.tempCategory.slice(0, 4) + '...'
                                            }
                                            else{
                                                this.currentPageName = this.tempCategory
                                            }
                                        }
                                        else {
                                            if (this.tempCategory.length > 20) {
                                                this.currentPageName = this.tempCategory.slice(0, 20) + '...'
                                            }
                                            else{
                                                this.currentPageName = this.tempCategory
                                            }
                                        }
                                    }
                                }
                                else{
                                    if (FORM_FACTOR == CONSTANTS.small) {
                                        if (this.clientName.length > 4) {
                                            this.clientName = this.clientName.slice(0, 4) + '...'
                                        }
                                    }
                                    else {
                                        if (this.clientName.length > 20) {
                                            this.clientName = this.clientName.slice(0, 20) + '...'
                                        }
                                        // else {
                                        //     this.clientName = this.clientName
                                        // }
                                    }
                                    this.tempKeyword = ''
                                    this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                    this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                    if (this.labelSearchResults.length > 20) {
                                        this.currentPageName = this.labelSearchResults.slice(0, 20) + '...'
                                    }
                                    else {
                                        this.currentPageName = this.labelSearchResults
                                    }
                                }
                            }
                            else if (this.pageName == CONSTANTS.homePage) {
                                if (this.clientName.length > 20) {
                                    this.currentPageName = this.clientName.slice(0, 20) + '...'
                                }
                                else {
                                    this.currentPageName = this.clientName
                                }
                            }
                            else {
                                if (this.pageName == CONSTANTS.detailPage) {
                                    if(this.tempCategory){
                                        if(this.keyword){
                                            if (FORM_FACTOR == CONSTANTS.small) {
                                                if (this.clientName.length > 4) {
                                                    this.clientName = this.clientName.slice(0, 4) + '...'
                                                }
                                                let truncatedSearchResultsLabel = this.labelSearchResults.slice(0, 4) + '...'
                                                if (this.clientName) {
                                                    this.tempKeyword = ''
                                                    this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                                    this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                                }
                                                if (this.tempCategory.length > 4) {
                                                    this.tempCategory = this.tempCategory.slice(0, 4) + '...'
                                                }
                                                this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                                                this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                                if (truncatedSearchResultsLabel) {
                                                    this.updateUrl(this.keyword, this.language, clientValue, categoryValue, this.src,'searchresultsurl')
                                                    this.pages.push({ name: CONSTANTS.searchResultsPage, label: truncatedSearchResultsLabel, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                                }
                                            }
                                            else {
                                                if (this.clientName.length > 20) {
                                                    this.clientName = this.clientName.slice(0, 20) + '...'
                                                }
                                                if (this.clientName) {
                                                    this.tempKeyword = ''
                                                    this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                                    this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                                }
                                                if (this.tempCategory.length > 20) {
                                                    this.tempCategory = this.tempCategory.slice(0, 20) + '...'
                                                }
                                                this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                                                this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                                if (this.labelSearchResults) {
                                                    this.updateUrl(this.keyword, this.language, clientValue, categoryValue, this.src,'searchresultsurl')
                                                    this.pages.push({ name: CONSTANTS.searchResultsPage, label: this.labelSearchResults, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                                }
                                                // this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + url },
                                                // { name: CONSTANTS.searchResultsPage, label: this.labelSearchResults, url: window.location.origin + basePath + '/article-search-results' + url });
                                            }
                                            this.getArticleTitle()
                                        }
                                        else{
                                            if (FORM_FACTOR == CONSTANTS.small) {
                                                if (this.clientName.length > 4) {
                                                    this.clientName = this.clientName.slice(0, 4) + '...'
                                                }
                                                if (this.clientName) {
                                                    this.tempKeyword = ''
                                                    this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                                    this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                                }
                                                if (this.tempCategory.length > 4) {
                                                    this.tempCategory = this.tempCategory.slice(0, 4) + '...'
                                                }
                                                this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                                                this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                            }
                                            else {
                                                if (this.clientName.length > 20) {
                                                    this.clientName = this.clientName.slice(0, 20) + '...'
                                                }
                                                if (this.clientName) {
                                                    this.tempKeyword = ''
                                                    this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                                    this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                                }
                                                if (this.tempCategory.length > 20) {
                                                    this.tempCategory = this.tempCategory.slice(0, 20) + '...'
                                                }
                                                this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                                                this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                                // this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + url },
                                                // { name: CONSTANTS.searchResultsPage, label: this.labelSearchResults, url: window.location.origin + basePath + '/article-search-results' + url });
                                            }
                                            this.getArticleTitle()
                                        }
                                    }
                                    else{
                                        if (FORM_FACTOR == CONSTANTS.small) {
                                            if (this.clientName.length > 4) {
                                                this.clientName = this.clientName.slice(0, 4) + '...'
                                            }
                                            let truncatedSearchResultsLabel = this.labelSearchResults.slice(0, 4) + '...'
                                            if (this.clientName) {
                                                this.tempKeyword = ''
                                                this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                                this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                            }
                                            if (truncatedSearchResultsLabel) {
                                                this.updateUrl(this.keyword, this.language, clientValue, categoryValue, this.src,'searchresultsurl')
                                                this.pages.push({ name: CONSTANTS.searchResultsPage, label: truncatedSearchResultsLabel, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                            }
                                        }
                                        else {
                                            if (this.clientName.length > 20) {
                                                this.clientName = this.clientName.slice(0, 20) + '...'
                                            }
                                            if (this.clientName) {
                                                this.tempKeyword = ''
                                                this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                                this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                            }
                                            if (this.labelSearchResults) {
                                                this.updateUrl(this.keyword, this.language, clientValue, categoryValue, this.src,'searchresultsurl')
                                                this.pages.push({ name: CONSTANTS.searchResultsPage, label: this.labelSearchResults, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                            }
                                            // this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + url },
                                            // { name: CONSTANTS.searchResultsPage, label: this.labelSearchResults, url: window.location.origin + basePath + '/article-search-results' + url });
                                        }
                                        this.getArticleTitle()
                                    }
                                }
                            }
                        }
                        else {
                            if (this.src == CONSTANTS.detailPage) {
                                if (this.pageName == CONSTANTS.searchResultsPage) {
                                    if(this.tempCategory){
                                        if(this.keyword){
                                            if (FORM_FACTOR == CONSTANTS.small) {
                                                if (this.clientName.length > 4) {
                                                    this.clientName = this.clientName.slice(0, 4) + '...'
                                                }
                                            }
                                            this.tempKeyword = ''
                                            this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                            this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                            this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                                            if (FORM_FACTOR == CONSTANTS.small) {
                                                if (this.tempCategory.length > 4) {
                                                    this.tempCategory = this.tempCategory.slice(0, 4) + '...'
                                                }
                                            }
                                            else {
                                                if (this.tempCategory.length > 20) {
                                                    this.tempCategory = this.tempCategory.slice(0, 20) + '...'
                                                }
                                            }
                                            this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                            if (this.labelSearchResults.length > 20) {
                                                this.currentPageName = this.labelSearchResults.slice(0, 20) + '...'
                                            }
                                            else {
                                                this.currentPageName = this.labelSearchResults
                                            }
                                        }
                                        else{
                                            if (FORM_FACTOR == CONSTANTS.small) {
                                                if (this.clientName.length > 4) {
                                                    this.clientName = this.clientName.slice(0, 4) + '...'
                                                }
                                            }
                                            this.tempKeyword = ''
                                            this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                            this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                            if (FORM_FACTOR == CONSTANTS.small) {
                                                if (this.tempCategory.length > 4) {
                                                    this.currentPageName = this.tempCategory.slice(0, 4) + '...'
                                                }
                                                else{
                                                    this.currentPageName = this.tempCategory
                                                }
                                            }
                                            else {
                                                if (this.tempCategory.length > 20) {
                                                    this.currentPageName = this.tempCategory.slice(0, 20) + '...'
                                                }
                                                else{
                                                    this.currentPageName = this.tempCategory
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        if (FORM_FACTOR == CONSTANTS.small) {
                                            if (this.clientName.length > 4) {
                                                this.clientName = this.clientName.slice(0, 4) + '...'
                                            }
                                        }
                                        this.tempKeyword = ''
                                        this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                        this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                        if (this.labelSearchResults.length > 20) {
                                            this.currentPageName = this.labelSearchResults.slice(0, 20) + '...'
                                        }
                                        else {
                                            this.currentPageName = this.labelSearchResults
                                        }
                                    }
                                }
                                else if (this.pageName == CONSTANTS.homePage) {
                                    if (this.clientName.length > 20) {
                                        this.currentPageName = this.clientName.slice(0, 20) + '...'
                                    }
                                    else {
                                        this.currentPageName = this.clientName
                                    }
                                }
                                else {
                                    if (this.pageName == CONSTANTS.detailPage) {
                                        if(this.tempCategory){
                                            if (FORM_FACTOR == CONSTANTS.small) {
                                                if (this.clientName.length > 4) {
                                                    this.clientName = this.clientName.slice(0, 4) + '...'
                                                }
                                            }
                                            else {
                                                if (this.clientName.length > 20) {
                                                    this.clientName = this.clientName.slice(0, 20) + '...'
                                                }
                                            }
                                            this.tempKeyword = ''
                                            this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                            this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                            this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'categoryPageUrl')
                                            if (FORM_FACTOR == CONSTANTS.small) {
                                                if (this.tempCategory.length > 4) {
                                                    this.tempCategory = this.tempCategory.slice(0, 4) + '...'
                                                }
                                            }
                                            else {
                                                if (this.tempCategory.length > 20) {
                                                    this.tempCategory = this.tempCategory.slice(0, 20) + '...'
                                                }
                                            }
                                            this.pages.push({ name: this.tempCategory, label: this.tempCategory, url: window.location.origin + basePath + '/article-search-results' + this.url });
                                            this.getArticleTitle()
                                        }
                                        else{
                                            if (FORM_FACTOR == CONSTANTS.small) {
                                                if (this.clientName.length > 4) {
                                                    this.clientName = this.clientName.slice(0, 4) + '...'
                                                }
                                            }
                                            else {
                                                if (this.clientName.length > 20) {
                                                    this.clientName = this.clientName.slice(0, 20) + '...'
                                                }
                                            }
                                            this.tempKeyword = ''
                                            this.updateUrl(this.tempKeyword, this.language, clientValue, categoryValue, this.src,'clientHomeurl')
                                            this.pages.push({ name: this.clientName, label: this.clientName, url: window.location.origin + basePath + this.url });
                                            this.getArticleTitle()
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
        this.showCrumbs = true;
    }

    getArticleTitle() {
        getKnowledgeDetails({ recordId: this.recordId, language: this.language })
            .then(result => {
                if (result) {
                    this.resultdata = result;
                    if (this.resultdata[0].Title && this.resultdata[0].Title.length > 20) {
                        this.currentPageName = this.resultdata[0].Title.slice(0, 20) + '...'
                    }
                    else {
                        this.currentPageName = this.resultdata[0].Title
                    }
                }
            })
            .catch(error => {
                this.currentPageName = ''
                console.error(error);
            });
    }

    openHelpHomePopUP(event) {
        let tempPageName = event.currentTarget.name
        if (tempPageName == CONSTANTS.homePage && this.clientCode.toLowerCase() != 'all') {
            event.preventDefault();
            this.showPopUp = true
        } else {
            document.getElementsByClassName('siteforceSpinnerManager')[0].classList.remove('hideEl')
        }
        document.body.style.overflow = 'hidden'
        this.imageLoading = false;
        // setTimeout(() => {
        //     this.imageLoading = false;
        //     console.log('image', this.imageLoading)
        // }, 3000)

    }

    constructor() {
        super();
    }

    updateUrl(localKeyword, localLanguage, localClientCode, localCategory, localsrc, pageurl) {
        if(pageurl == 'clientHomeurl'){
            this.url = '?'
            this.url = this.url + (localClientCode ? ('clientCode=' + localClientCode + '&') : '') + (localLanguage ? ('language=' + localLanguage + '&') : '') + (localsrc ? 'src=' + localsrc : '')
        }
        else if(pageurl == 'categoryPageUrl'){
            this.url = '?'
            this.url = this.url + (localClientCode ? ('clientCode=' + localClientCode + '&') : '') + (localLanguage ? ('language=' + localLanguage + '&') : '') + (localCategory ? ('category=' + encodeURIComponent(localCategory) + '&') : '') + (localsrc ? 'src=' + localsrc : '')
        }
        else{
            if(pageurl == 'searchresultsurl'){
                this.url = '?'
                this.url = this.url + (localClientCode ? ('clientCode=' + localClientCode + '&') : '') + (localKeyword ? 'keyword=' + encodeURIComponent(localKeyword) + '&' : '') + (localCategory ? ('category=' + encodeURIComponent(localCategory) + '&') : '') + (localLanguage ? ('language=' + localLanguage + '&') : '') + (localsrc ? 'src=' + localsrc : '')
            }
        }
    }

    handleCloseClick() {
        //this.dispatchEvent(new CustomEvent('closemodal'))
        this.showPopUp = false
        let selectIcon = this.template.querySelector('.slds-breadcrumb__item')
        selectIcon.focus()
        document.body.style.overflow = 'auto'
    }

    handleNoButtonClick() {
        this.showPopUp = false
        let selectIcon = this.template.querySelector('.slds-breadcrumb__item')
        selectIcon.focus()
        document.body.style.overflow = 'auto'
    }

    handleYesButtonClick() {
        document.getElementsByClassName('siteforceSpinnerManager')[0].classList.remove('hideEl')
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: CONSTANTS.homePage
            },
            state: {
                language: this.language,
            }
        })
            .then(url => {
                window.location.assign(url)
            });
    }

    //Trap focus inside modal
    handleFocusOut(event) {
        const modal = this.template.querySelector('.customModal');
        var related = event.relatedTarget;
        var dataindexval = related.getAttribute('data-index')
        console.log('modal 501', modal)
        console.log('modal 502', related)
        console.log('modal 505', related.getAttribute('data-index'))

        if (dataindexval == '0') {
            // If focus is leaving, bring it back to the modal
            this.template.querySelector('.yesButton').focus();
        }
        else {
            if (dataindexval == '1') {
                // If focus is leaving, bring it back to the modal
                this.template.querySelector('.closeButton').focus();
            }
        }
    }


}