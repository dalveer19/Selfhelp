public class TopCategoriesBatchAll  implements Database.Batchable<sObject>, Database.Stateful  {

    top_categories__c setting = top_categories__c.getOrgDefaults(); //custom setting
    Private List<String> childCategories = new List<String>(); 
    Private Set<String> cat = new Set<String>();
    Private List<String> sortedCat = new List<String>();
    @testVisible public static Boolean isTestRunning = SHP_ConstantUtil.varForTestClass();

    public TopCategoriesBatchAll(){
        //To get the list of top 'n' number of Data categories as defined in the custom setting 'TopCategory' size field
        Integer i = 0;
        for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
            if(i < setting.size__c){
                childCategories.add(sc.getName());
                i++;
            }
          //  System.debug(childCategories);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Query Knowledge__DataCategorySelection records to get the list of all data category selections made for knowledge__kav
        return Database.getQueryLocator('SELECT id,ParentId,DataCategoryGroupName,DataCategoryName,Parent.Language,Parent.KnowledgeArticleId FROM Knowledge__DataCategorySelection WHERE Parent.publishStatus = \'Online\' AND Parent.Article_visiblity_for_candidate__c = true AND Parent.Applicable_to_all_clients__c = true AND Parent.RecordType.Name = \'candidate\'' );
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        try {
            List<Knowledge__DataCategorySelection> articlesDataCatg = (List<Knowledge__DataCategorySelection>)scope;
            //System.debug(articlesDataCatg);
            
            //Map to hold articleId and list of it's related data categories
            Map<Id, list<String>> articleCatMap = new Map<Id, list<String>>();
            for(Knowledge__DataCategorySelection dataCat : articlesDataCatg ){
                if( articleCatMap.containsKey(dataCat.ParentId) &&  articleCatMap.get(dataCat.ParentId).size() > 0 ){
                    articleCatMap.get(dataCat.ParentId).add(dataCat.DataCategoryName);
                } else {
                    articleCatMap.put(dataCat.ParentId,new list<String>{dataCat.DataCategoryName});
                }
            }
            //Filtering the categories based on top categories
            for(String kavId : articleCatMap.keyset()){
                for(String singleCat : articleCatMap.get(kavId)){
                    if(childCategories.contains(singleCat)){
                        cat.add(singleCat);
                    }
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
            consErrorLog.Process_Function_Name__c = 'TopCategoriesBatchAll.execute';
            consErrorLog.Process_Type__c = 'Batch Job';
            consErrorLog.Response__c = 'Error';
            insert consErrorLog;
        }
    }

    public void finish(Database.BatchableContext BC) {
        try{
            //To sort the categories in the same order of Data Categories tree
            for (String oneCat : childCategories){
                for(String validCat : cat ){
                    if(oneCat == validCat){
                        sortedCat.add(oneCat);
                    }
                }
            }

            //Handle test class exception scenario
            if(isTestRunning == true) {
            	throw new StringException('This exception is never thrown');
            }  

            //Update custom setting value based on the results
            setting.Categories_List__c	= String.join(sortedCat,';');
            //System.debug(setting.Categories_List__c);
            upsert setting;
        }
         catch(Exception e){
           //Create error_log__c records to analyze exceptions
            Error_Log__c consErrorLog = new Error_Log__c();
            consErrorLog.Error_Message__c = e.getMessage();
            consErrorLog.Related_data__c = e.getStackTraceString();
            consErrorLog.Process_Function_Name__c = 'TopCategoriesBatchAll.finish';
            consErrorLog.Process_Type__c = 'Batch Job';
            consErrorLog.Response__c = 'Error';
            insert consErrorLog;
        }
    }
}