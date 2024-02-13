public without sharing class shp_ContactUs {
    
    @AuraEnabled(cacheable=true)
    public static List<Account_Info__c> getContactInfoUrl(String clientCode, String language) {
        String languageField   = language + '__c';
        List<Account_Info__c> accounts = new List<Account_Info__c>();
        String codeFromUser = ' \'' + clientCode + '\'';

        String searchQuery =  ' Select  ' + 
                                 languageField + 
                               ' From Account_Info__c' +
                               ' WHERE client__r.Client_code__c = ';

        String sanitizedQuery = String.escapeSingleQuotes(searchQuery);
        String finalQuery = sanitizedQuery + codeFromUser;
        accounts = Database.query(finalQuery);
        System.debug(accounts);
        return accounts;
    }
}