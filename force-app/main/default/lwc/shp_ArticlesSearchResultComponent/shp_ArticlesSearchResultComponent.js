import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
//importing apex classes
import getKnowledgeSearchSuggestionResults from '@salesforce/apex/SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults';
import getCategorySpecificArticles from '@salesforce/apex/SHP_KnowledgeSearchResultsController.getCategorySpecificArticles';
import getClients from '@salesforce/apex/SHP_SearchContainerController.getClients';
import getDataCategoryLabel from '@salesforce/apex/DataCategoryController.getDataCategoryLabel';
//importing custom labels
import results_for from '@salesforce/label/c.results_for';
import view_more from '@salesforce/label/c.view_more';
import labelShowing from '@salesforce/label/c.Showing';
import labelof from '@salesforce/label/c.of';
import Here_s_what_we_found from '@salesforce/label/c.Here_s_what_we_found';
import We_re_sorry_but_we_couldn_t_find from '@salesforce/label/c.We_re_sorry_but_we_couldn_t_find';
import Here_are_a_few_things_you_can_try from '@salesforce/label/c.Here_are_a_few_things_you_can_try';
import Review_the_Spelling_of_your_search_terms from '@salesforce/label/c.Review_the_Spelling_of_your_search_terms';
import Try_using_fewer_different_or_more_general_keywords from '@salesforce/label/c.Try_using_fewer_different_or_more_general_keywords';
import Couldnt_Find_Any_Results_For_Category from '@salesforce/label/c.Couldnt_Find_Any_Results_For_Category';
import and from '@salesforce/label/c.and';

//importing LMS
import CHANNEL from '@salesforce/messageChannel/shpMessageChannel__c';
import { MessageContext, subscribe } from 'lightning/messageService';
// Importing constants from constants JS helper
import { getConstants } from 'c/constantUtil';
const CONSTANTS = getConstants();

export default class Shp_ArticlesSearchResultComponent extends NavigationMixin(LightningElement) {

    // Labels
    label_resultsdisplay = results_for
    label_viewmore = view_more
    label_showing = labelShowing
    label_of = labelof
    label_resultsfor = results_for
    label_Hereswhatwefound = Here_s_what_we_found
    label_We_re_sorry_but_we_couldn_t_find = We_re_sorry_but_we_couldn_t_find
    label_Here_are_a_few_things_you_can_try = Here_are_a_few_things_you_can_try
    label_Review_the_Spelling_of_your_search_terms = Review_the_Spelling_of_your_search_terms
    label_Try_using_fewer_different_or_more_general_keywords = Try_using_fewer_different_or_more_general_keywords
    label_Couldnt_Find_Any_Results_For_Category = Couldnt_Find_Any_Results_For_Category
    label_and = and

    // Variables
    isResultsLoading = true
    hasError = false
    hasCategoryError = false
    recordId
    language
    keyword
    clientCode
    clientName
    pageName
    dataCategoriesList = []
    additionalInfoRequired = true
    @track articlesToDisplay = []
    pageSize = 5
    pageNumber = 1
    searchResultMap = new Map()
    showViewMoreOption = false
    @track articlesResultLength
    @track articlesToDisplayLength
    isCategorySearch = false
    isCategorySearchResults = false

    categoryName=''
    categoryLabel
    isClientThere = false;


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state?.recordId
            this.language = currentPageReference.state?.language || 'en_US'
            this.keyword = currentPageReference.state?.keyword || ''
            this.pageName = currentPageReference.attributes?.name
            this.categoryName = currentPageReference.state?.category || ''
            this.clientCode = currentPageReference.state?.clientCode || CONSTANTS.All
            if (this.clientCode && this.clientCode.toLowerCase() != 'all') {
                this.isClientThere = true
                getClients({ clientCode: this.clientCode }).then(result => {
                    if (result.errorMsg) {
                        console.error(result.errorMsg)
                    } else {
                        this.clientName = result.selectedClient.Name
                    }
                })
            } else {
                this.isClientThere = false;
            }
        }
    }

    @wire(MessageContext)
    context

    connectedCallback() {
        this.subscribeHandler()
        if(!this.articlesResultLength && this.keyword!=''){
            if(this.categoryName==''){
                this.isCategorySearch = false
                this.isCategorySearchResults = false
            }
            else{
                this.isCategorySearch = true
                this.isCategorySearchResults = true
            }
            this.loadKnowledgeArticles(this.keyword, this.language, this.clientCode, this.categoryName, this.additionalInfoRequired)
        }
        else if(this.keyword=='' && this.categoryName!=''){
            this.isCategorySearch = true
            this.isCategorySearchResults = false
            this.loadCategorySpecificArticles(this.language, this.clientCode, this.categoryName)
        }
    }

    renderedCallback(){
        
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
            this.pageNumber = 1
            this.pageSize = 5
            if(message.clientCode.value){
                this.clientCode = message.clientCode.value
                if (this.clientCode && this.clientCode.toLowerCase() != 'all') {
                    this.isClientThere = true
                    this.clientName = message.clientCode.label
                }
                else{
                    this.isClientThere = false
                }
            }
            if(this.categoryName!=''){
                if(this.keyword=='' && message.keyword!=''){
                    this.isCategorySearch = true
                    this.isCategorySearchResults = false
                    this.loadCategorySpecificArticles(this.language, this.clientCode, this.categoryName)
                }
                else if(this.keyword!='' && message.keyword!=''){
                    this.isCategorySearch = true
                    this.isCategorySearchResults = true
                    this.keyword = message.keyword
                    this.loadKnowledgeArticles(this.keyword, this.language, this.clientCode, this.categoryName, this.additionalInfoRequired)
                }else{
                    this.loadCategorySpecificArticles(this.language, this.clientCode, this.categoryName)
                }
            }
            else{
                this.isCategorySearch = false
                this.isCategorySearchResults = false
                this.keyword = message.keyword
                this.loadKnowledgeArticles(this.keyword, this.language, this.clientCode, this.categoryName, this.additionalInfoRequired)
            }
        }
        
    }

    async  loadKnowledgeArticles(keyword, language, clientCode, categoryName, additionalInfoRequired) {
        console.log('LOADING loadKnowledgeArticles')
        this.isResultsLoading = true
        this.searchResultMap = new Map()
        let localclientCode = clientCode
        if (clientCode.toLowerCase() == 'all' || !clientCode) {
            localclientCode = null
        }
        if (keyword && keyword.length >= 3) {
          await  getKnowledgeSearchSuggestionResults({ searchKey: keyword, language: language, clientCode: localclientCode, categoryName: categoryName, additionalInfoRequired: additionalInfoRequired }).then(result => {
                if (result.searchResultsList && result.searchResultsList.length > 0) {
                    result.searchResultsList.forEach(wrapper => {
                        // let dataCategoriesListString = ''
                        let clientName = ''
                        let searchResult = {}
                        let articleId = ''
                        if (wrapper.searchResult) {
                            searchResult = wrapper.searchResult
                            articleId = wrapper.searchResult.Id
                            if (searchResult.Title && searchResult.Title.length > 60) {
                                searchResult.Title = searchResult.Title.slice(0, 60) + '...'
                            }
                            if (searchResult.Summary && searchResult.Summary.length > 250) {
                                searchResult.Summary = searchResult.Summary.slice(0, 250) + '...'
                            }
                        }
                        // if (wrapper.dataCategoriesList.length == 1) {
                        //     dataCategoriesListString = wrapper.dataCategoriesList[0].dcLabel
                        // }
                        // if (wrapper.dataCategoriesList.length > 1) {
                        //     let dataCategoriesLabelList = wrapper.dataCategoriesList.map(dataCategories => dataCategories.dcLabel)
                        //     dataCategoriesListString = dataCategoriesLabelList.slice(0, -1).join('; ') + ' ; ' + dataCategoriesLabelList.slice(-1)
                        // }
                        if (wrapper.clientName) {
                            clientName = wrapper.clientName
                        }
                        let transformedWrapper = {
                            searchResult: searchResult,
                            // dataCategoriesListString: dataCategoriesListString,
                            clientName: clientName,
                            url: window.location.origin + CONSTANTS.sitePathName + CONSTANTS.detailPageUrl + '?' + 'recordId=' + articleId + '&' +
                                (this.clientCode ? ('clientCode=' + this.clientCode + '&') : 'clientCode=All&') + 
                                (this.keyword ? ('keyword=' + encodeURIComponent(this.keyword)) + '&' : '') + 
                                (this.categoryName ? ('category=' + encodeURIComponent(this.categoryName)) + '&' : '') + 
                                (this.pageName ? ('src=' + this.pageName) : '')
                        }
                        this.searchResultMap.set(articleId, transformedWrapper)
                    })
                    this.articlesResultLength = this.searchResultMap.size
                    this.getArticlesToShow()
                } else {
                    this.hasError = true
                }
            })
        }
        else {
            this.hasError = true
        }
        this.isResultsLoading = false
    }

    async loadCategorySpecificArticles(language, clientCode, categoryName){
        console.log('LOADING loadCategorySpecificArticles')
        this.isResultsLoading = true
        this.searchResultMap = new Map()
        let localclientCode = clientCode
        if (clientCode.toLowerCase() == 'all' || !clientCode) {
            localclientCode = null
        }
        await getCategorySpecificArticles({language: language, clientCode: localclientCode, categoryName: categoryName}).then(result=>{
            console.log('Result---->')
            console.log(result)
            if(result.searchResultsList && result.searchResultsList.length > 0){
                result.searchResultsList.forEach(wrapper => {
                    // let dataCategoriesListString = ''
                    let clientName = ''
                    let searchResult = {}
                    let articleId = ''
                    if (wrapper.searchResult) {
                        searchResult = wrapper.searchResult
                        articleId = wrapper.searchResult.Id
                        if (searchResult.Title && searchResult.Title.length > 60) {
                            searchResult.Title = searchResult.Title.slice(0, 60) + '...'
                        }
                        if (searchResult.Summary && searchResult.Summary.length > 250) {
                            searchResult.Summary = searchResult.Summary.slice(0, 250) + '...'
                        }
                    }
                    // if (wrapper.dataCategoriesList.length == 1) {
                    //     dataCategoriesListString = wrapper.dataCategoriesList[0].dcLabel
                    // }
                    // if (wrapper.dataCategoriesList.length > 1) {
                    //     let dataCategoriesLabelList = wrapper.dataCategoriesList.map(dataCategories => dataCategories.dcLabel)
                    //     dataCategoriesListString = dataCategoriesLabelList.slice(0, -1).join('; ') + ' ; ' + dataCategoriesLabelList.slice(-1)
                    // }
                    if (wrapper.clientName) {
                        clientName = wrapper.clientName
                    }
                    let transformedWrapper = {
                        searchResult: searchResult,
                        // dataCategoriesListString: '',
                        clientName: clientName,
                        url: window.location.origin + CONSTANTS.sitePathName + CONSTANTS.detailPageUrl + '?' + 'recordId=' + articleId + '&' +
                                (this.clientCode ? ('clientCode=' + this.clientCode + '&') : 'clientCode=All&') + 
                                (this.keyword ? ('keyword=' + encodeURIComponent(this.keyword)) + '&' : '') + 
                                (this.categoryName ? ('category=' + encodeURIComponent(this.categoryName)) + '&' : '') + 
                                (this.pageName ? ('src=' + this.pageName) : '')
                    }
                    this.searchResultMap.set(articleId, transformedWrapper)
                })
                this.articlesResultLength = this.searchResultMap.size
                this.getArticlesToShow()
            }
            else{
                this.hasCategoryError = true
                if(this.categoryName != ''){
                    this.getCategoryLabel(this.categoryName)
                }
                console.log('catError ' + this.hasCategoryError)
            }
            this.isResultsLoading = false
        })
    }

    get hasAnyError(){
        if(this.hasCategoryError || this.hasError){
            return true
        }else{
            return false
        }
    }

    getCategoryLabel(dataCatName){
        getDataCategoryLabel({ dataCategoryName: dataCatName })
            .then(result => {
                this.categoryLabel = result
        })
        .catch(error => {
            console.error(error);
        })
    }

    getArticlesToShow() {
        this.articlesToDisplay = [];
        const startIndex = (this.pageNumber - 1) * this.pageSize
        const endIndex = startIndex + this.pageSize
        let currentIndex = 0
        for (const [key, value] of this.searchResultMap) {
            if (currentIndex < endIndex) {
                this.articlesToDisplay.push({ key, value })
            }
            currentIndex++
        }
        this.showViewMoreOption = this.articlesToDisplay.length < this.searchResultMap.size
        this.articlesToDisplayLength = this.articlesToDisplay.length
        this.hasError = false
        this.hasCategoryError = false
        this.isResultsLoading = false
    }

    handleViewMore() {
        this.pageNumber++
        this.getArticlesToShow();

        //focus first of newly loaded articles/categories
        setTimeout(() => {
            let articleTitles = this.template.querySelectorAll('.articleTitle');
            let focusIndex = (this.pageNumber - 1) * this.pageSize;
            console.log('after handle viewmore---------' + focusIndex + articleTitles.length);
            let articleTitleToFocus = articleTitles[focusIndex];
            articleTitleToFocus.focus();
        }, "100");
    }

    handleRecordClick(){
        document.querySelector('.siteforceSpinnerManager').classList.remove('hideEl')
    }
    handleRecordKeyPress(){
        if (event.keyCode === 13) {
            document.querySelector('.siteforceSpinnerManager').classList.remove('hideEl')
        }
    }
    // handleRecordClick(event) {
    //     let tempid = event.currentTarget.name
    //     if (!this.clientCode || this.clientCode.toLowerCase() == 'all') {
    //         this.clientCode = 'all'
    //     }
    //     this[NavigationMixin.Navigate]({
    //         type: 'comm__namedPage',
    //         attributes: {
    //             name: 'Article_Details_Page__c'
    //         },
    //         state: {
    //             recordId: tempid,
    //             language: this.language,
    //             clientCode: this.clientCode,
    //             keyword: this.keyword,
    //             category: this.categoryName,
    //             src: this.pageName
    //         }
    //     })
    // }

    updateUrl() {
        let url = '?'
        url = url +
            (this.recordId ? ('recordId=' + this.recordId + '&') : '') +
            (this.clientCode ? ('clientCode=' + this.clientCode + '&') : '') +
            (this.keyword ? 'keyword=' + encodeURIComponent(this.keyword) + '&' : '') +
            (this.categoryName ? 'category=' + this.categoryName + '&' : '') +
            (this.language ? 'language=' + this.language + '&' : '') +
            (this.pageName ? 'src=' + this.pageName : '')
        window.history.pushState({}, '', url)
    }

    // handleRecordKeyPress(event){
    //     if (event.keyCode === 13) {
    //         this.handleRecordClick(event);
    //     }
    // }

    handleViewMoreKeyPress(event){
        if (event.keyCode === 13) {         
            this.handleViewMore();
        }
    }
}