// .....................................................................................................................................
//     Change LOG
// .....................................................................................................................................
//     Date             Version              Author                          Summary of Changes 
// ................   ............      .....................    .......................................................................
//    20-10-2023           1.0             Hana Anwar                 Completion of functionality
//    17-11-2023           1.1             Swagata Dasgupta           Code Review 
// ..................................................................................................................................... 

// Import necessary modules and components
import { LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import LOGOS from '@salesforce/resourceUrl/Self_help';
// import getKnowledgeDetails from '@salesforce/apex/ArticleController.getKnowledgeDetails';
import getKnowledgeArticleDetails from '@salesforce/apex/ArticleController.getKnowledgeArticleDetails';
import getKnowledgeDataCategories from '@salesforce/apex/fetchArticleDataCategories.getKnowledgeDataCategories';
import GetLanguage from '@salesforce/apex/shp_accountUtility.selfHelpLanguages';

//Import Custom Labels
import label_None from '@salesforce/label/c.label_None';
import Tags from '@salesforce/label/c.Tags';
import The_article_has_not_been_published_in_this_language from '@salesforce/label/c.The_article_has_not_been_published_in_this_language';
import alternative_language from '@salesforce/label/c.alternative_language';
import from_the_following_options from '@salesforce/label/c.from_the_following_options';
import Please_select_an from '@salesforce/label/c.Please_select_an';

// Import various labels for internationalization
import Date_Posted from '@salesforce/label/c.Date_Posted';
import LANG from '@salesforce/i18n/lang'

// Importing constants from constants JS helper
import { getConstants } from 'c/constantUtil';
const CONSTANTS = getConstants();

// Define and export the LWC component
export default class KnowledgeArticleDetails extends NavigationMixin(LightningElement) {

    // Define component properties and variables
    resultdata={};
    recordId;
    keyword;
    language;
    clientCode;
    clientName;
    ArticleDetailBackground = LOGOS + '/SelfHelp/Icons/ArticleDetailHeader.png';
    tags = []
    sortedTags = []
    havingTags = false

    // Initialize label variables with imported label values
    label_Date = Date_Posted
    labelNone = label_None
    label_Tags = Tags
    label_Please_select_an = Please_select_an
    label_The_article_has_not_been_published_in_this_language = The_article_has_not_been_published_in_this_language;
    label_alternative_language = alternative_language;
    label_from_the_following_options = from_the_following_options;
    publishedDate

    invalidLangError = false
    showArticleDetails = false
    isLoading = true
    validLanguages = []
    validLangsToShow = []
    showLangModal=false

    // Wire the CurrentPageReference  from the Lightning Message Service
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state?.recordId;
            this.language = currentPageReference.state?.language;
            this.clientCode = currentPageReference.state?.clientCode;
        }
    }

    // Executed when the component is connected to the DOM
    connectedCallback() {
        this.fetchKnowledgeArticleDetails()
        this.fetchDataCategories()
    }

    // Fetch knowledge article details using Apex method
    fetchKnowledgeArticleDetails() {
        getKnowledgeArticleDetails({ recordId: this.recordId, language: this.language }).then(result => {
            if(result){
                if(result.invalidLangError){
                    this.validLanguages = [...result.validLanguages]
                    GetLanguage().then(result => {
                        result.forEach(item => {
                            if(this.validLanguages.indexOf(item.code)!=-1){
                                this.validLangsToShow.push(item.display);
                            }
                        })
                        this.invalidLangError = true
                        this.isLoading = false
                    })
                }
                else{
                    console.log(result)
                    this.resultdata = result
                    // Handle Clients List
                    let clientsList = result.clients
                    this.clientName = clientsList.join(' ; ')
                    //Logic to handle International date formats based on language
                    let pubDT = result.LastPublishedDate
                    let pubDate = pubDT.substr(0, pubDT.indexOf('T'))
                    let dateOptions = { year: "numeric", month: "long", day: "numeric" }
                    this.publishedDate = new Intl.DateTimeFormat(LANG, dateOptions).format(new Date(pubDate))
                    this.showArticleDetails = true
                    this.isLoading = false
                }
            }
        })
    }

    // Fetch data categories using Apex method
    fetchDataCategories() {
        getKnowledgeDataCategories({ recordId: this.recordId })
            .then(result => {
                if (result) {
                    console.log('Result :', result)
                    let tagNames = result.dataCategoriesList.map(dataCategories => dataCategories.dcLabel);
                    //Sorting alphabetical order in asc. & case insensitive 
                    tagNames = tagNames.slice().sort((a, b) => {
                        return a.localeCompare(b, undefined, { sensitivity: 'base' });
                    });
                    for (let i = 0; i < tagNames.length; i++) {
                        if (tagNames[i].length > 35) {
                            this.tags.push(tagNames[i].slice(0, 35) + '....')
                            console.log('Tags : ', this.tags)
                            this.havingTags = true
                        }
                        else {
                            this.tags.push(tagNames[i])
                            this.havingTags = true
                        }
                    }
                }
                else {
                    this.havingTags = false
                }
            })
            .catch(error => {
                this.havingTags = false
                console.error(error);
            })
    }

    //Handle error
    handleError() {
        const event = new ShowToastEvent({
            title: CONSTANTS.title,
            message: CONSTANTS.message,
            variant: CONSTANTS.variant,
        });
        this.dispatchEvent(event);
    }
    constructor() {
        super()
        //this.ArticleDetailBackground = LOGOS + '/SelfHelp/Icons/ArticleDetailHeader.png'
    }
    openLanguageModal(){
        event.preventDefault();
        this.showLangModal = true
        document.body.style.overflow = 'hidden'
    }
    handleCloseLang(){
        this.showLangModal = false
        document.body.style.overflow = 'auto'
        //To focus on button
        let langSelector = this.template.querySelector('.altLangBtn')
        langSelector.focus()
    }
}