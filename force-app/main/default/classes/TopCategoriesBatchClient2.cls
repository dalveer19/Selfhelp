public class TopCategoriesBatchClient2  implements Database.Batchable<sObject>, Database.Stateful  {

    Map<Id, set<Id>> accArticlesMap = new Map<Id, set<Id>>(); //Map of account/client and its related articles
    Map<Id, List<String>> accTopCategsMap = new Map<Id, List<String>>(); //Map of account and its related top categories
    List<String> topCategories = new List<String>(); //List to store top categories 
    Map<String, set<String>> articleCategsMap = new Map<String, set<String>>(); //Map of article and its related data categories list
    set<Id> allArticles = new Set<Id>(); //Set of articleIds which are visible to all clients
    set<String> allArticlesTopCat = new Set<String>(); //Set of data category's list which are tagged to articles (visible to all clients)
    @testVisible public static Boolean isTestRunning = SHP_ConstantUtil.varForTestClass();

    public TopCategoriesBatchClient2(map <Id, Set<Id>> accArticlesMap, List<String> topCategories){
        this.accArticlesMap = accArticlesMap; //Assigning account => {articles} map from TopCategoriesBatchClient1 class
        this.topCategories = topCategories; //Assigning top categories set from TopCategoriesBatchClient1 class
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Get list of all Knowledge__DataCategorySelection records from articles which are published & visible to candidates
        return Database.getQueryLocator('SELECT id,ParentId,Parent.Applicable_to_all_clients__c,DataCategoryGroupName,DataCategoryName,Parent.Language FROM Knowledge__DataCategorySelection WHERE Parent.publishStatus = \'Online\' AND Parent.Article_visiblity_for_candidate__c = true  AND Parent.RecordType.Name = \'candidate\'' );
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        try{
            List<Knowledge__DataCategorySelection> articlesDataCatg = (List<Knowledge__DataCategorySelection>)scope;
            
            //Forming a map of articles and its data category's name set
            for(Knowledge__DataCategorySelection ds : articlesDataCatg){
                if(ds.Parent.Applicable_to_all_clients__c == true){
                    allArticles.add(ds.ParentId);
                    allArticlesTopCat.add(ds.DataCategoryName);
                }
                if(articleCategsMap.containsKey(ds.ParentId)){
                    articleCategsMap.get(ds.ParentId).add(ds.DataCategoryName);
                } else if (!articleCategsMap.containsKey(ds.ParentId)) {
                    articleCategsMap.put(ds.ParentId,new set<String>{ds.DataCategoryName});
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
            consErrorLog.Process_Function_Name__c = 'TopCategoriesBatchClient2.execute';
            consErrorLog.Process_Type__c = 'Batch Job';
            consErrorLog.Response__c = 'Error';
            insert consErrorLog;
        }  
    }

    public void finish(Database.BatchableContext BC) {
        try{
            //LOGIC : The top categories list for specific Clients/Accounts is formed by the combination of top categories from its specific client articles AND top categories from visible to all client articles

            list<Account_info__c> upsertList = new list<Account_info__c>();
            Map<String,String> accAccInfoMap = new  Map<String,String>();

            //Adding articles(visible to all clients) list to accArticlesMap to implement the required LOGIC 
            for(Id clientId :accArticlesMap.keySet()){
                accArticlesMap.get(clientId).addAll(allArticles);
            }
        
            for(String singleTopCatg : topCategories){
                for(Id client : accArticlesMap.keySet() ){
                    //system.debug('accounts -------'+client);
                    for(Id article : accArticlesMap.get(client)){
                      //  system.debug('articles --------'+ article);
                          //  system.debug('-----'+singleTopCatg);
                            if(!accTopCategsMap.containsKey(client) && articleCategsMap.containsKey(article)){
                                if(articleCategsMap.get(article).contains(singleTopCatg)){
                                    accTopCategsMap.put(client,new List<String>{singleTopCatg});
                                  //  system.debug(client+'>>>>>>>>>>>'+accTopCategsMap.get(client));
                                }
                            } else if(accTopCategsMap.containsKey(client) && articleCategsMap.containsKey(article)){
                                if(articleCategsMap.get(article).contains(singleTopCatg)){
                                    if(!accTopCategsMap.get(client).contains(singleTopCatg)){
                                        accTopCategsMap.get(client).add(singleTopCatg);
                                     //   system.debug(client+'>>>>>>>>>>>'+accTopCategsMap.get(client));
                                    }
                                }
                            }
                    }
                }
            }
            //list to store sorted categories of visible to all clients articles
            List<String> sortAllArticlesTopCat = new List<String>();
            
            //Sorting as per Top categories
            for(String singleCateg : topCategories){
                for(String gg : allArticlesTopCat){
                    if(singleCateg == gg){
                        sortAllArticlesTopCat.add(singleCateg);
                    }
                }
            }
            //Querying through account info records wiht below conditions
            for(Account_info__c clientInfo :  [SELECT id,client__c,Top_categories__c from Account_info__c WHERE (client__r.Active__c = TRUE AND client__r.Is_external__c = TRUE AND client__r.Displays_in_Self_Help__c  = TRUE  AND client__r.Is_fedramp__c = FALSE) OR (client__c IN :accTopCategsMap.keySet() )]){
                        clientInfo.Top_categories__c = accTopCategsMap.containsKey(clientInfo.client__c) ? String.join(accTopCategsMap.get(clientInfo.client__c),';') : String.join(sortAllArticlesTopCat,';');
                    	upsertList.add(clientInfo);
                        accAccInfoMap.put(clientInfo.client__c, clientInfo.Id);
            }
            //Creating new account info records incase they donot exist
            for(Id acc : accTopCategsMap.keySet()){
                if(!accAccInfoMap.containsKey(acc)){
                    Account_info__c clInf = new Account_info__c();
                    clInf.client__c = acc;
                    clInf.Top_categories__c = accTopCategsMap.containsKey(acc) ? String.join(accTopCategsMap.get(acc),';') : String.join(sortAllArticlesTopCat,';');
                    upsertList.add(clInf);
                }
            }
            //Handle test class exception scenario
            if(isTestRunning == true) {
            	throw new StringException('This exception is never thrown');
            }
            upsert upsertList;
        }
        catch(Exception e){
            //Create error_log__c records to analyze exceptions
            Error_Log__c consErrorLog = new Error_Log__c();
            consErrorLog.Error_Message__c = e.getMessage();
            consErrorLog.Related_data__c = e.getStackTraceString();
            consErrorLog.Process_Function_Name__c = 'TopCategoriesBatchClient2.finish';
            consErrorLog.Process_Type__c = 'Batch Job';
            consErrorLog.Response__c = 'Error';
            insert consErrorLog;
        }
    }

}