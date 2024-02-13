import { LightningElement, wire } from 'lwc';
import getCats from '@salesforce/apex/DataCategoryController.getTopCategories';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import Browse_Top_Categories from '@salesforce/label/c.Browse_Top_Categories';
// Importing constants from constants JS helper
import { getConstants } from 'c/constantUtil';
import LOGOS from '@salesforce/resourceUrl/Self_help';
import Search_by_category from '@salesforce/label/c.Search_by_category';
//importing LMS
import CHANNEL from '@salesforce/messageChannel/shpMessageChannel__c';
import { MessageContext, subscribe } from 'lightning/messageService';


const CONSTANTS = getConstants();

export default class DataCategoriesFilter extends NavigationMixin(LightningElement) {
    categoriesList = [];
    labelBrowseTopCategories = Browse_Top_Categories
    label_SearchbyCategory = Search_by_category
    svg = LOGOS + '/SelfHelp/Icons/'
    svgImage


    constructor() {
        super()
        //this.svgImage = LOGOS + '/SelfHelp/Icons/Pictograms.png'
    }

    @wire(MessageContext)
    context

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
                if (this.clientCode && this.clientCode != CONSTANTS.All) {
                    this.getCategories(this.clientCode)
                }
                else {
                    this.getCategories(CONSTANTS.All)
                }
            }
        }
    }

    connectedCallback() {
        this.subscribeHandler()
        if (this.clientCode && this.clientCode != CONSTANTS.All) {
            this.getCategories(this.clientCode)
        }
        else {
            this.getCategories(CONSTANTS.All)
        }
    }

    getCategories(client) {
        getCats({ clientCode: client})
            .then(result => {
                console.log('66::::::::', result);
                const catNames = Object.keys(result);
                const catLabels = Object.values(result);
                this.categoriesList = catNames.map((name, index) => ({
                    name: name,
                    label: catLabels[index],
                    svgImage : this.getImageUrl(name)
                }));
                console.log('72::::::::', this.categoriesList);
            })
            .catch(error => {
                console.log(error)
            });
    }

    getImageUrl(categoryName) {
        console.log('83::::::::::',(LOGOS + '/SelfHelp/Icons/Pictograms.png'))
        return LOGOS + '/SelfHelp/Icons/' + categoryName + '.png';
    }

    handleCategoryClick(event) {
        let tempCategory = event.currentTarget.name
        console.log('temp', tempCategory)
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: CONSTANTS.searchResultsPage
            },
            state: {
                language: this.language,
                clientCode: this.clientCode,
                category: tempCategory,
                src: this.pageName
            }
        });
        // sessionStorage.clear()
        // sessionStorage.setItem('src', this.pageName)
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
        }
    }

    handleKeyPress(event) {
        if (event.key === 'Enter') {
            this.handleCategoryClick(event);
        }
    }

}