// .....................................................................................................................................
//     Change LOG
// .....................................................................................................................................
//     Date             Version              Author                          Summary of Changes 
// ................   ............      .....................    .......................................................................
//    17-10-2023           1.0             Swagata Dasgupta           Completion of functionality
//    26-10-2023           1.1             Swagata Dasgupta           Code Review and functionality update
//    06-11-2023           2               Swagata Dasgupta           Changing accountId to Client_code__c
// ..................................................................................................................................... 

/**
 * @description Controller class for the search container functionality related to the 'Client' Account record type.
 */
public without sharing class SHP_SearchContainerController {
    // Default record type name for the Account objects
    public static String defaultAccountRecordType = 'Client';

    /**
    *@description Wrapper class to hold the selected client, list of all clients, and error message
    */
    public class SearchContainerClientWrapper {
        @AuraEnabled public Account selectedClient;
        @AuraEnabled public String clientLogoUrl;
        @AuraEnabled public List<Account> allClientsList;
        @AuraEnabled public String errorMsg;
    }
    /**
     * @description Method to fetch either a selected client or all clients based on the provided clientId. 
     * @param clientCode - The ID of the client Account to retrieve (optional).
     * @return SearchContainerClientWrapper - The wrapper containing the selected client, list of all clients, or error message.
     */
    @AuraEnabled(cacheable=true)
    public static searchContainerClientWrapper getClients(String clientCode) { 
        SearchContainerClientWrapper searchContainerClientWrapper = new SearchContainerClientWrapper();
        String clientRecordTypeId = getRecordTypeIdByDeveloperName(defaultAccountRecordType); 
        // Fetch the selected client if the clientId is provided
        if(clientCode!=null){
            try{
                searchContainerClientWrapper.selectedClient =   [   
                                                                    SELECT Id, Client_code__c, Name, Logo__c, RecordType.Name 
                                                                    FROM Account 
                                                                    WHERE RecordTypeId = :clientRecordTypeId 
                                                                    AND Is_fedramp__c = false 
                                                                    AND Client_code__c = :clientCode 
                                                                    AND Is_external__c = TRUE 
                                                                    AND Active__c  = TRUE 
                                                                    AND Displays_in_Self_Help__c  = TRUE 
                                                                    LIMIT 1
                                                                ];
                searchContainerClientWrapper.clientLogoUrl = string.format(Label.LogoURL, new List<String>{clientCode});
            }catch(Exception e){
                // Capture any exceptions that occur during the query and provide a meaningful error message
                searchContainerClientWrapper.errorMsg = 'Error occurred: ' + e.getMessage();
                //System.debug('Error: ' + searchContainerClientWrapper.errorMsg);
            }
            return searchContainerClientWrapper;
        }
        // Fetch all clients if clientId is not provided
        else{
            try{
                searchContainerClientWrapper.allClientsList = [
                                                                SELECT Id, Client_code__c, Name, Logo__c, RecordType.Name 
                                                                FROM Account 
                                                                WHERE RecordTypeId = :clientRecordTypeId 
                                                                AND Is_fedramp__c = false 
                                                                AND Client_code__c != null 
                                                                AND Is_external__c = TRUE 
                                                                AND Active__c  = TRUE  
                                                                AND Displays_in_Self_Help__c  = TRUE                                                             
                                                                ORDER BY Name
                                                            ];
            }
            catch(Exception e){
                // Capture any exceptions that occur during the query and provide a meaningful error message
                searchContainerClientWrapper.errorMsg = 'Error occurred: ' + e.getMessage();
                //System.debug('Error: ' + searchContainerClientWrapper.errorMsg);
            }
            return searchContainerClientWrapper;
        }
    }
    /**
     * @description Method to fetch the Record Type ID based on the developer name provided.
     * @param developerName - The developer name of the Record Type.
     * @return Id - The ID of the Record Type based on the provided developer name.
     */
    public static Id getRecordTypeIdByDeveloperName(String developerName) {
        Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosByDeveloperName();
        if (recordTypeInfoMap.containsKey(developerName)) {
            return recordTypeInfoMap.get(developerName).getRecordTypeId();
        }
        return null;
    }

}