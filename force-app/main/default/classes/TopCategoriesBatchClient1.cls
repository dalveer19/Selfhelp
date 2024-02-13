public class TopCategoriesBatchClient1  implements Database.Batchable<sObject>, Database.Stateful  {

    top_categories__c setting = top_categories__c.getOrgDefaults(); //custom setting
    Private List<String> childCategories = new List<String>(); //List to store top categories from schema
    Map<Id, set<Id>> accArticlesMap = new Map<Id, set<Id>>();  //Map to store accountId and its related articleIds
    @testVisible public static Boolean isTestRunning = SHP_ConstantUtil.varForTestClass();

    public TopCategoriesBatchClient1(){
        //To get the list of top 'n' number of Data categories as defined in the custom setting 'TopCategory' size field
        Integer i = 0;
        for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
            if(i < setting.size__c){
                childCategories.add(sc.getName());
                i++;
            }
        }   
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Querying linked clients based on below conditions
        return Database.getQueryLocator('select id,Knowledge_Article__c,Knowledge_Article__r.Title,Client__c,Client__r.Name from Linked_Client__c WHERE Knowledge_Article__r.publishStatus = \'Online\' AND Knowledge_Article__r.Article_visiblity_for_candidate__c = true AND client__r.Active__c = TRUE AND client__r.Is_external__c = TRUE AND client__r.Displays_in_Self_Help__c  = TRUE  AND client__r.Is_fedramp__c = FALSE AND Knowledge_Article__r.RecordType.Name = \'Candidate\'');
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        try{
            Set<Id> accounts = new Set<Id>();
            List<Linked_Client__c> linkedClients = (List<Linked_Client__c>)scope;
            
            //Forming map of accountId and articleIds from linked client records
            for(Linked_Client__c lc : linkedClients){
                if(!accArticlesMap.containsKey(lc.Client__c)){
                    accArticlesMap.put(lc.Client__c,new set<Id>{lc.Knowledge_Article__c});
                }
                if(accArticlesMap.containsKey(lc.Client__c)){
                    accArticlesMap.get(lc.Client__c).add(lc.Knowledge_Article__c);
                }
            }
            //Handle test class exception scenario
            if(isTestRunning == true) {
            	throw new StringException('This exception is never thrown');
        }
        }
        catch(Exception e){
            //Create error_log__c records to analyze exceptions
            Error_Log__c consErrorLog = new Error_Log__c();
            consErrorLog.Error_Message__c = e.getMessage();
            consErrorLog.Related_data__c = e.getStackTraceString();
            consErrorLog.Process_Function_Name__c = 'TopCategoriesBatchClient1.execute';
            consErrorLog.Process_Type__c = 'Batch Job';
            consErrorLog.Response__c = 'Error';
            insert consErrorLog;
        }
    }

    public void finish(Database.BatchableContext BC) {
        //Calling another batch class 
        Database.executeBatch(new TopCategoriesBatchClient2(accArticlesMap, childCategories));
    }
}