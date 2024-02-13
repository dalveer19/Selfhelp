const getConstants = () => {
    return {
        All: 'All',
        homePage: 'Home',
        detailPage: 'Article_Details_Page__c',
        searchResultsPage: 'Article_Search_Results__c',
        searchAllPrograms: 'searchAllPrograms',
        iknow: 'iknow',
        detailPageUrl: 'article-details-page',
        searchResultsPageUrl: 'article-search-results',
        en_US : 'en_US',
        helpHome : 'Help home',
        searchResultslabel : 'Search Results',
        keyword : 'keyword',
        cookieConsent : 'CookieConsent',
        cookieConsentPolicy : 'CookieConsentPolicy',
        languagesList : ['en_US','ar_AE','ko','ja','en_GB','fr_CA','zh_CN'],// list of language codes to validate in knowledgeArticleSearchContainer cmp.
        title: 'Error',
        message: 'An error occurred while fetching the knowledge article details.',
        variant: 'error',
        small: 'Small',
        sitePathName : '/Selfhelp/s/'
    }

}

export { getConstants };