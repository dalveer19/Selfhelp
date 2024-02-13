import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getKnowledgeSearchSuggestionResults from '@salesforce/apex/SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults';
import Search_keywords_questions_and_more from '@salesforce/label/c.Search_keywords_questions_and_more';
import Search_help_and_support from '@salesforce/label/c.Search_help_and_support';
import view_all from '@salesforce/label/c.View_all';
import results from '@salesforce/label/c.Results';
import CLEAR_SEARCH from '@salesforce/label/c.clear_search';
import LANGUAGE from '@salesforce/i18n/lang';
import Search from '@salesforce/label/c.Search';
import FORM_FACTOR from '@salesforce/client/formFactor';
import CHANNEL from '@salesforce/messageChannel/shpMessageChannel__c';
import { MessageContext, subscribe } from 'lightning/messageService';

// Import constants from util
import { getConstants } from 'c/constantUtil';
const CONSTANTS = getConstants();

export default class SearchBarWithSuggestionsChildV1 extends NavigationMixin(LightningElement) {
    options
    iconName = 'utility:Account'
    iconTitle = 'Knowledge'
    required
    timer
    searchbarplaceholder = FORM_FACTOR == 'Small' ? Search : Search_keywords_questions_and_more
    selectedValue = ''
    comboboxIsOpen = false
    isValueSelected = false
    cancelBlur = false
    highlightCounter = null
    focussedOnce = false
    viewAllLabel = view_all
    resultsLabel = results
    clearsearchlabel = CLEAR_SEARCH
    @track keyword = ''
    language
    suggestionOptions = []
    showViewAllOption = false;
    @track clientCode
    localKeyWord = ''
    @track viewAllClass = ''
    @track focusedOption = ''
    category
    categoryKey
    url = window.location.origin + window.location.pathname + '?'
    get viewAllAria() {
        return this.viewAllLabel + this.size + this.resultsLabel
    }

    // To make clientCode reactive 
    @api get clientCodeFromParent() {
        return this.clientCode
    }
    set clientCodeFromParent(value) {
        this.clientCode = value;
    }

    @track size = 0;
    pageName
    @track showCross = false

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
        if (message.clientCode.value) {
            this.clientCode = message.clientCode.value
        }
    }

    // exposing api method to call apex when needed
    @api callApex(clientCode) {
        this.suggestionOptions = []
        this.clientCode = clientCode
        //this.keyword = this.localKeyWord
        if (this.clientCode && this.clientCode.toLowerCase() != 'all') {
            this.callSuggestionsApex(clientCode);
        }
        else {
            this.callSuggestionsApex(null);
        }
    }

    //To set keyword from parent container
    @api setKeyword(keyword) {
        this.keyword = keyword
        this.showCross = this.keyword ? true : false
    }

    connectedCallback() {
        this.subscribeHandler()
        if (this.keyword) {
            this.callApex(this.clientCode)
        }
    }

    //logic to handle Matching keywords in suggestions
    renderedCallback() {
        if (this.keyword.length >= 3 && this.suggestionOptions.length > 0) {
            // Inserting the bold suggestions into HTML
            let boldSuggestions = this.boldMatchingWords(this.keyword, this.suggestionOptions)

            this.template.querySelectorAll('.suggestionOption').forEach((item, index) => {
                item.innerHTML = boldSuggestions[index]
            })
            
            //Extra logic to show partial word matches when nothing is highlighted in the suggestions
            /*let boldWords = this.keyword.split(/(\s+)/).filter(e => e.trim().length > 0);
              this.template.querySelectorAll('.suggestionOption').forEach(item => {
                  // Forming a proxy from the values of split keyword array
                  let iterator = boldWords.values();
                  if (item.title == item.innerHTML) {
                      let boldSuggestion = item.innerHTML
                      // Iterating through the different values of proxy and forming highlighted suggestions
                      for (let value of iterator) {
                          if (!boldSuggestion.includes('<b>') || !boldSuggestion.includes('</b>')) {
                              boldSuggestion = boldSuggestion.replace(new RegExp(`(${value})`, 'gi'), '<b>$1</b>');
                          }
                      }
                      item.innerHTML = boldSuggestion
                  }
              }) */
        }
    }

    //Logic to make matching words in suggestions bold
    boldMatchingWords(input, suggestions) {
        let inputWords = input.split(' ');
        return suggestions.map(suggestion => {
            let suggestionWords = suggestion.label.split(' ');
            for (let i = 0; i < suggestionWords.length; i++) {
                for (let j = 0; j < inputWords.length; j++) {
                    if (suggestionWords[i].toLowerCase() === inputWords[j].toLowerCase()) {
                        suggestionWords[i] = `<b>${suggestionWords[i].replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</b>`;
                    }
                }
                if ((suggestionWords[i].includes('<') || suggestionWords[i].includes('>')) && (!suggestionWords[i].includes('<b>') || !suggestionWords[i].includes('</b>'))) {
                    suggestionWords[i] = `${suggestionWords[i].replaceAll('<', '&lt;').replaceAll('>', '&gt;')}`;
                }
            }
            return suggestionWords.join(' ');
        });
    }

    // Method which makes the callout to apex & returns us a list of matching knowledge articles
    async callSuggestionsApex(clientParamId) {
        this.size = 0
        this.showViewAllOption = false;
        this.suggestionOptions = []
        if (this.keyword.length >= 3) {
            await getKnowledgeSearchSuggestionResults({ searchKey: this.keyword, language: this.language, categoryName: this.category, clientCode: clientParamId, additionalInfoRequired: false })
                .then(suggestionResult => {
                    console.log('suggestionResultsuggestionResult', suggestionResult.searchResultsList.length);
                    if (!suggestionResult.errorMsg && this.keyword.length >= 3) {
                        this.suggestionOptions = suggestionResult.searchResultsList.map(item => {
                            return {
                                label: item.searchResult.Title,
                                value: item.searchResult.Id
                            }
                        })
                        this.size = suggestionResult.searchResultsList.length;
                        this.suggestionOptions = this.suggestionOptions.splice(0, 5)


                        if (this.size > 5) {
                            this.showViewAllOption = true;
                            this.viewAllClass = 'slds-listbox__item  slds-listbox__option slds-listbox__option_plain'
                        } else {
                            this.showViewAllOption = false;
                            this.viewAllClass = ''
                        }
                    } else {
                        console.error(suggestionResult.errorMsg)
                    }
                })
                .catch(error => console.log(error))
        }
    }

    get tempOptions() {
        let options = this.suggestionOptions;
        return this.highLightOption(options);
    }

    //This method handles the search input event & sets a timer to call the Apex method after 100ms of inactivity in typing.
    handleSearchInput(event) {
        this.keyword = event.target.value
        this.showCross = this.keyword ? true : false
        this.suggestionOptions = []
        if (event.key != 'Enter' && event.key != 'ArrowDown' && event.key != 'ArrowUp' && event.key != 'PageDown' && event.key != 'PageUp' && event.key != 'Home' && event.key != 'End' && this.keyword) {
            window.clearTimeout(this.timer)
            this.timer = setTimeout(() => {
                if (this.keyword.length >= 3) {
                    if (this.clientCode && this.clientCode.toLowerCase() != 'all') {
                        this.callSuggestionsApex(this.clientCode);
                    }
                    else {
                        this.callSuggestionsApex(null);
                    }
                } else {
                    this.suggestionOptions = []
                }
            }, 100)
        }
    }

    //This method highlights an option in the suggestion list.
    highLightOption(options) {
        let classes = "slds-media slds-listbox__option slds-listbox__option_plain slds-media_small"

        return options.map((option, index) => {
            let cs = classes
            let focused = ""
            if (index === this.highlightCounter) {
                cs = classes + " slds-has-focus";
                focused = "yes";
            }
            return { classes: cs, focused, ...option };
        })
    }

    get selectedLabel() {
        let index = this.suggestionOptions.findIndex(item => item.value == this.selectedValue)
        return this.suggestionOptions[index].label
    }

    // to handle comboboxContainerClasses
    get comboboxContainerClass() {
        let classes = 'slds-combobox_container'
        if (this.selectedValue != '' && this.comboboxIsOpen == false) {
            classes += ' slds-has-selection'
        }
        return classes
    }

    // To handle comboboxClasses
    get comboboxClass() {
        let classes = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click'
        if (this.comboboxIsOpen) {
            classes += ' slds-is-open'
        }
        return classes
    }

    // to handle inputClasses
    get inputClass() {
        let classes = 'slds-input slds-combobox__input'
        if (this.comboboxIsOpen) {
            classes += ' slds-has-focus'
        }
        if (this.selectedValue != '' && this.comboboxIsOpen) {
            classes += ' slds-combobox__input-value'
        }
        return classes
    }

    fireChange(value) {
        if (this.selectedValue != '') {
            this.comboboxIsOpen = false
            this.cancelBlur = false
            this.handlerecordclick();
        }
    }

    // Handle select event from modal
    handleSelect(event) {
        this.comboboxIsOpen = false
        this.cancelBlur = false
        this.selectedValue = event.currentTarget.dataset.value;
        this.updateUrl()
        // window.location.assign(this.url)

        if (this.selectedValue != '') {
            this.isValueSelected = true
            this.fireChange(this.selectedValue)
        } else {
            this.isValueSelected = false
        }
    }

    // Different fucntions based on browser events
    focusCombobox() {
        this.focussedOnce = true
        this.comboboxIsOpen = true
        this.highlightCounter = null
    }

    // To handle out of focus event of search bar
    blurCombobox() {
        if (this.pageName == CONSTANTS.searchResultsPage) {
            if (this.keyword.length >= 3) {
                this.dispatchEvent(new CustomEvent('keywordchange', { detail: this.keyword }))
            }
        }
        if (!this.cancelBlur) {
            this.comboboxIsOpen = false
        }
        this.highlightCounter = null
    }

    handleDropdownMouseDown() {
        this.cancelBlur = true
    }

    handleDropdownMouseUp() {
        this.cancelBlur = false
    }

    //To update the current url based on the available state paramters in the url
    updateUrl() {
        if (this.pageName == CONSTANTS.detailPage) {
            this.url = this.url + (this.selectedValue ? ('recordId=' + this.selectedValue + '&') : '')
        }
        this.url = this.url + (this.clientCode ? ('clientCode=' + this.clientCode + '&') : '') + (this.keyword ? ('keyword=' + encodeURIComponent(this.keyword)) + '&' : '') + (this.category ? ('category=' + encodeURIComponent(this.category)) + '&' : '') + (this.language ? ('language=' + this.language) : '') + '&' + (this.pageName ? ('src=' + this.pageName) : '')
    }

    handleEnter(event) {
        if (event.keyCode == 13) {
            this.handleViewAll();
        }
    }

    // Function to handle the action when 'View All' is clicked
    handleViewAll() {
        // Update URL only when not on article detail page as 
        if (this.pageName != CONSTANTS.detailPage) {  //to prevent pushing of url when on article detail page
            this.updateUrl()
        }

        if (this.pageName == CONSTANTS.searchResultsPage) {
            //to show spinner, we are removing the hideEl class from Salesforce standard spinner block
            document.querySelector('.siteforceSpinnerManager').classList.remove('hideEl')
            window.location.assign(this.url)
        } else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: CONSTANTS.searchResultsPage
                },
                state: {
                    language: this.language,
                    clientCode: this.clientCode,
                    keyword: this.keyword,
                    category: this.category,
                    src: this.pageName
                }
            })
        }
        /* sessionStorage.clear()
         sessionStorage.setItem('src', this.pageName)*/
    }

    // Function to handle the action when a record is clicked
    handlerecordclick() {
        // Navigate to the 'Article_Details_Page__c' page with the selectedValue, clientCode, and language as state parameters
        if (this.pageName == CONSTANTS.detailPage) {
            //to show spinner, we are removing the hideEl class
            document.querySelector('.siteforceSpinnerManager').classList.remove('hideEl')
            window.location.assign(this.url)
        } else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: CONSTANTS.detailPage
                },
                state: {
                    recordId: this.selectedValue,
                    clientCode: this.clientCode,
                    language: this.language,
                    keyword: this.categoryKey,
                    category: this.category,
                    src: this.pageName
                }
            })
        }
        /* sessionStorage.clear()
         sessionStorage.setItem('src', this.pageName)*/
    }

    // Function to handle key down events
    handleKeyDown(event) {
        // If 'Escape' key is pressed, toggle comboboxIsOpen and reset highlightCounter
        if (event.key == "Escape") {
            this.comboboxIsOpen = !this.comboboxIsOpen;
            this.highlightCounter = null;
        }
        // If 'Enter' key is pressed and keyword length is more than 3 characters
        if (event.key == "Enter" && this.keyword.length >= 3) {
            if (this.comboboxIsOpen && this.highlightCounter !== null) {
                if (this.highlightCounter == this.tempOptions.length) {
                    this.handleViewAll();
                }
                this.selectedValue = this.tempOptions[this.highlightCounter].value;
                this.isValueSelected = true
                this.updateUrl();

                this.fireChange(this.selectedValue)
            }
            //Call handleViewAll function
            else {
                this.blurCombobox();
                this.handleViewAll();
            }
        }

        // If 'ArrowDown' or 'PageDown' key is pressed, open combobox and increment highlightCounter
        if (event.key === "ArrowDown" || event.key === "PageDown") {
            this.comboboxIsOpen = true;
            this.highlightCounter = this.highlightCounter === null ? 0 : this.highlightCounter + 1;
        }
        // If 'ArrowUp' or 'PageUp' key is pressed, open combobox and decrement highlightCounter
        else if (event.key === "ArrowUp" || event.key === "PageUp") {
            this.comboboxIsOpen = true;
            this.highlightCounter = this.highlightCounter === null || this.highlightCounter === 0 ? this.tempOptions.length : this.highlightCounter - 1;
        }
        // If 'ArrowDown' or 'ArrowUp' key is pressed, wrap around highlightCounter within tempOptions length + 1
        if (event.key === "ArrowDown" || event.key === "ArrowUp") {
            this.highlightCounter = Math.abs(this.highlightCounter) % (this.tempOptions.length + 1);
        }
        // If 'Home' key is pressed, set highlightCounter to first option
        if (event.key === "Home") {
            this.highlightCounter = 0;
        }
        // If 'End' key is pressed, set highlightCounter to last option + 1
        else if (event.key === "End") {
            this.highlightCounter = this.tempOptions.length;
        }
        if (this.highlightCounter == this.tempOptions.length) {
            this.viewAllClass = this.viewAllClass + ' slds-has-focus'
        } else {
            this.viewAllClass = this.viewAllClass.replace('slds-has-focus', '')
        }
        if (this.highlightCounter >= 0) {
            this.focusedOption = this.suggestionOptions && this.highlightCounter != this.suggestionOptions.length ? this.suggestionOptions[this.highlightCounter].value : this.viewAllLabel
        }
    }

    //To get the current page reference
    @wire(CurrentPageReference)
    getSearchWord(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state?.recordId;
            if (!this.language) {
                this.language = currentPageReference.state?.language || LANGUAGE.replace(/-/g, '_'); //To get the user's language when there is no language param in the URL
            }
            if (!this.clientCode) {
                this.clientCode = currentPageReference.state?.clientCode || CONSTANTS.All; //To default clientCode as "All" when there is no clientCode param in the URL
            }
            if (currentPageReference.state.category) {
                this.category = currentPageReference.state?.category || ''
            }
            const holder = currentPageReference.state?.keyword;
            const pageName = currentPageReference.attributes?.name;
            this.pageName = pageName;
            this.categoryKey = holder;
            if (holder && this.pageName != CONSTANTS.detailPage) {
                this.keyword = holder;
                this.showCross = true
            }
            //For rendering placeholder based on the page & form factor
            if (pageName == CONSTANTS.detailPage && FORM_FACTOR == 'Small') {
                this.keyword = ''
                if (this.clientCode.toLowerCase() != 'all') {
                    this.searchbarplaceholder = Search
                } else {
                    this.searchbarplaceholder = Search_help_and_support;
                }
            }
        }
    }

    // To clear input data in the search bar, along with suggestions
    clearInputHandler(event) {
        this.keyword = '';
        this.showCross = false;
        this.suggestionOptions = [];
        this.template.querySelector('.searchBoxComponent .slds-input').focus();
        // this.dispatchEvent(new CustomEvent('keywordchange', { detail: this.keyword }))
    }
    clearInputHandlerOnEnterPress(event) {
        if (event.key === 'Enter') {
            this.clearInputHandler(event);
        }
    }
}