import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getFeaturedArticles from '@salesforce/apex/FeatureArticleClass.getFeaturedArticles';
import FEATURED_ARTICLES from '@salesforce/label/c.Featured_articles';

import CHANNEL from '@salesforce/messageChannel/shpMessageChannel__c';
import { MessageContext, subscribe } from 'lightning/messageService';

// Import constants from util
import { getConstants } from 'c/constantUtil';
const CONSTANTS = getConstants();

export default class FeaturedArticlesDisplay extends NavigationMixin(LightningElement) {
    articles;
    index = 6;
    pageName
    featuredArticlesLoading = true
    label_Featured_articles = FEATURED_ARTICLES

    @wire(CurrentPageReference)
    getSearchWord(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state?.recordId;
            this.language = currentPageReference.state?.language || LANGUAGE.replace(/-/g, '_');
            console.log(this.language)
            this.clientCode = currentPageReference.state?.clientCode;
            this.pageName = currentPageReference.attributes?.name;
        }
    }

    @wire(MessageContext)
    context

    subscribeHandler() {
        console.log('ppppppppppp');
        subscribe(
            this.context,
            CHANNEL,
            (message) => { this.handleMessage(message) }
        )
    }

    //handles subscribe event from LMS
    handleMessage(message) {
        if (message) {
            console.log('------->>>>>>>>>>>>>>>>>', message);
            this.clientCode = message.clientCode.value
            if (this.clientCode && this.clientCode != CONSTANTS.All) {
                this.callFeaturedApex(this.clientCode, this.language)
            }
            else {
                this.callFeaturedApex(CONSTANTS.All, this.language)
            }
        }
    }

    connectedCallback() {
        this.subscribeHandler()
        if (this.clientCode && this.clientCode != CONSTANTS.All) {
            this.callFeaturedApex(this.clientCode, this.language)
        }
        else {
            this.callFeaturedApex(CONSTANTS.All, this.language)
        }
    }

    // make callout to apex and fetch featured articles based on client & language
    callFeaturedApex(client, language) {
        this.featuredArticlesLoading = true;
        console.log('++++++++', client, '++++++++', language)
        this.articles = []
        console.log('featured72');
        getFeaturedArticles({ client: client, language: language })
            .then(result => {
                console.log('featured74', result);
                // Truncate title to 50 characters and summary to 150 characters
                this.articles = result.map(article => ({
                    truncatedTitle: article.title.length > 60 ? article.title.slice(0, 60) + '...' : article.title,
                    truncatedSummary: article.summary ? (article.summary.length > 100 ? article.summary.slice(0, 100) + '...' : article.summary) : '',
                    recordId: article.recordId,
                    url:    window.location.origin + window.location.pathname + CONSTANTS.detailPageUrl + '?' + 'recordId=' + article.recordId + '&' +
                            (this.clientCode ? ('clientCode=' + this.clientCode + '&') : 'clientCode=All&') + 
                            (this.keyword ? ('keyword=' + encodeURIComponent(this.keyword)) + '&' : '') + 
                            (this.category ? ('category=' + encodeURIComponent(this.category)) + '&' : '') + 
                            (this.pageName ? ('src=' + this.pageName) : '')
                }));
                this.featuredArticlesLoading = false;
            })
            .catch(error => {
                this.featuredArticlesLoading = true;
                console.log(error)
            });
    }
    handleRecordClick(){
        document.querySelector('.siteforceSpinnerManager').classList.remove('hideEl')
    }
    handleRecordKeyPress(){
        if (event.keyCode === 13) {
            document.querySelector('.siteforceSpinnerManager').classList.remove('hideEl')
        }
    }

    // handle record click event 
    // handlerecordclick(event) {
    //     event.preventDefault()
    //     let recordid = event.target.name;
    //     if (this.clientCode && this.clientCode != CONSTANTS.All) {
    //         this[NavigationMixin.Navigate]({
    //             type: 'comm__namedPage',
    //             attributes: {
    //                 name: CONSTANTS.detailPage
    //             },
    //             state: {
    //                 recordId: recordid, // Set the recordId as a state parameter
    //                 clientCode: this.clientCode, // Set the clientCode as a state parameter
    //                 src: this.pageName // Set the current page name as a state parameter
    //             },
    //         });
    //     }
    //     else {
    //         this[NavigationMixin.Navigate]({
    //             type: 'comm__namedPage',
    //             attributes: {
    //                 name: CONSTANTS.detailPage
    //             },
    //             state: {
    //                 recordId: recordid, // Set the recordId as a state parameter
    //                 clientCode: CONSTANTS.All, // Set the clientCode as a state parameter
    //                 src: this.pageName // Set the current page name as a state parameter
    //             },
    //         });
    //     }
    //     //  sessionStorage.clear();
    //     //  sessionStorage.setItem('src', this.pageName);
    // }

    handleRecordClickKey(event){
        if(event.keyCode === 13){
            this.handlerecordclick(event);
        }
    }

}