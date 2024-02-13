@isTest
public class SHP_KnowledgeSearchResultsControllerTest {
 
    // TestDataFactory class to generate test data
    public class TestDataFactory {
        public List<knowledge__kav> createKnowledgeArticles(Integer count) {
            Id krecordType = [Select Name, Id, developerName From RecordType where sObjectType='Knowledge__kav' and isActive=true and developerName = 'Candidate' limit 1].id;
            List<knowledge__kav> articles = new List<knowledge__kav>();
            for (Integer i = 0; i < count; i++) {
                articles.add(new Knowledge__kav(
                    title = 'test' + i,
                    UrlName = 'tester---' + i,
                    Language = 'en_US',
                    Article_visiblity_for_candidate__c = true,
                    Applicable_to_all_clients__c = true, recordtypeId = krecordType
                ));
            }
            insert articles;
            return articles;
        }
        
        public List<knowledge__kav> createKnowledgeArticlesfalse(Integer count) {
            Id krecordType = [Select Name, Id, developerName From RecordType where sObjectType='Knowledge__kav' and isActive=true and developerName = 'Candidate' limit 1].id;
            List<knowledge__kav> articles = new List<knowledge__kav>();
            for (Integer i = 0; i < count; i++) {
                articles.add(new Knowledge__kav(
                    title = 'test' + i,
                    UrlName = 'tester--' + i,
                    Language = 'en_US',
                    Article_visiblity_for_candidate__c = true,
                    Applicable_to_all_clients__c = false, recordtypeId = krecordType
                ));
            }
            insert articles;
            System.debug('53::'+ [SELECT knowledgeArticleId FROM Knowledge__kav]);
            List<knowledge__kav> insertedArticles = [SELECT knowledgeArticleId,title,Language FROM Knowledge__kav];
            return insertedArticles;
        }
 
        public List<Linked_Client__c> createLinkedClients(List<knowledge__kav> articles, Account client) {
            List<Linked_Client__c> clients = new List<Linked_Client__c>();
            for (knowledge__kav article : articles) {
                clients.add(new Linked_Client__c(Knowledge_Article__c = article.Id, Client__c = client.Id));
            }
            insert clients;
            return clients;
        }
    }
 
    static testMethod void testGetKnowledgeSearchSuggestionResults1() {
        TestDataFactory testDataFactory = new TestDataFactory();
        List<knowledge__kav> articleList = TestDataFactory.createKnowledgeArticles(3);
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		system.debug(dcList);
        
        Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
        dataCategory.DataCategoryGroupName = 'Candidate';
        dataCategory.DataCategoryName = dcList[0];
        dataCategory.parentId = articleList[0].Id;
        insert dataCategory;
        
        Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
            Account acc = new Account(name='TestkaAccount', recordtypeId = recordType, Client_code__c = '111',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
          	insert acc;
			
			list<Linked_Client__c > clients =  new list<Linked_Client__c>();
            
 
        for (knowledge__kav k : articleList) {
            k.Approval_status__c = 'Approved';
            updKAV.add(k);
            kavIDs.add(k.id);
        }
        insert clients;
        update updKAV;
 
        List<knowledge__kav> pubKAV = [SELECT Id, knowledgeArticleId FROM knowledge__kav WHERE Id IN :kavIDs];
        for (Knowledge__kav article : pubKAV) {
            kaIDs.add(article.knowledgeArticleId);
            KbManagement.PublishingService.publishArticle(article.knowledgeArticleId, false);
        }
        
        System.debug(kaIDs);
 
        Id[] fixedSearchResults = new Id[3];
        fixedSearchResults[0] = kavIDs[0];
        fixedSearchResults[1] = kavIDs[1];
        fixedSearchResults[2] = kavIDs[2];
        Test.setFixedSearchResults(fixedSearchResults);
 
       // String sc = new String();
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper result = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', 'All', '', true);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper results = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', null, dataCategory.DataCategoryName);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultn = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', null, dataCategory.DataCategoryName, true);
        //SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultp = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', 'All', dataCategory.DataCategoryName );
        System.assert(result != null);
    }
 
    static testMethod void testGetKnowledgeSearchSuggestionResults2() {
          TestDataFactory testDataFactory = new TestDataFactory();
           List<knowledge__kav> articleList = TestDataFactory.createKnowledgeArticles(3);
            list<id> kavIDs = new list<id> ();
            list<id> kaIDs = new list<id> ();
            list<knowledge__kav> updKAV = new list<knowledge__kav>();
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		system.debug(dcList);
        
        Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
        dataCategory.DataCategoryGroupName = 'Candidate';
        dataCategory.DataCategoryName = dcList[0];
        dataCategory.parentId = articleList[0].Id;
        insert dataCategory;
        
           /* for(integer i = 0; i < 3; i++){
            articleList.add(new Knowledge__kav(title='test'+i,UrlName='tester--'+i,
            Language = 'en_US',
            Article_visiblity_for_candidate__c = true,
            Applicable_to_all_clients__c = true));
            }
        	insert articleList;*/
            for(knowledge__kav k : articleList){
                k.Approval_status__c='Approved';
                updKAV.add(k);
                kavIDs.add(k.id);
            }
            update updKAV;
            list<knowledge__kav> pubKAV = new list<knowledge__kav>([select id, knowledgeArticleId from knowledge__kav where id in : kavIDs]);
            for(Knowledge__kav article: pubKAV) {
                kaIDs.add(article.knowledgeArticleId);
                KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
            }
        Id [] fixedSearchResults= new Id[3];
        fixedSearchResults[0] = kavIDs[0];
        fixedSearchResults[1] = kavIDs[1];
        fixedSearchResults[2] = kavIDs[2];
       Test.setFixedSearchResults(fixedSearchResults);
        List<String> sc = New List<String>();
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper result = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '', '', true);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper results = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', null, ''); 
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultn = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '111', dataCategory.DataCategoryName, true);
        System.assert(result != null);
    }
    
    static testMethod void testGetKnowledgeSearchSuggestionResults3() {
        TestDataFactory testDataFactory = new TestDataFactory();
           list<knowledge__kav> articleList = new list<knowledge__kav>();                       
            list<id> kavIDs = new list<id> ();
            list<id> kaIDs = new list<id> ();
            list<knowledge__kav> updKAV = new list<knowledge__kav>();
           /* for(integer i = 0; i < 3; i++){
            articleList.add(new Knowledge__kav(title='test'+i,UrlName='tester--'+i,
            Language = 'en_US',
            Article_visiblity_for_candidate__c = true,
            Applicable_to_all_clients__c = true));
            }
        	insert articleList;*/
            for(knowledge__kav k : articleList){
                k.Approval_status__c='Approved';
                updKAV.add(k);
                kavIDs.add(k.id);
            }
            update updKAV;
            list<knowledge__kav> pubKAV = new list<knowledge__kav>([select id, knowledgeArticleId from knowledge__kav where id in : kavIDs]);
            for(Knowledge__kav article: pubKAV) {
                kaIDs.add(article.knowledgeArticleId);
                KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
            }
        List<String> sc = New List<String>();
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper result = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '', '', true);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper results = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', '', '');
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultn = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '', 'Registration_scheduling', true);
        System.assert(result != null);
    }
    static testMethod void testGetKnowledgeSearchSuggestionResults4() {
          TestDataFactory testDataFactory = new TestDataFactory();
         	List<knowledge__kav> articleListClient = TestDataFactory.createKnowledgeArticles(3);
            list<id> kavIDsClient = new list<id> ();
            list<id> kaIDsClient = new list<id> ();
            list<knowledge__kav> updKAVClient = new list<knowledge__kav>();
            
			Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
            Account acc = new Account(name='TestkaAccount', recordtypeId = recordType, Client_code__c = '111',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
          	insert acc;
			
			list<Linked_Client__c > clients =  new list<Linked_Client__c>();
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		system.debug(dcList);
            
            Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
            dataCategory.DataCategoryGroupName = 'Candidate';
            dataCategory.DataCategoryName = dcList[0];
            dataCategory.parentId = articleListClient[0].Id;
            insert dataCategory;
        
            for(knowledge__kav k : articleListClient){
                k.Approval_status__c='Approved';
                updKAVClient.add(k);
                kavIDsClient.add(k.id);
				clients.add(new Linked_Client__c(Knowledge_Article__c = k.id, Client__c = acc.id));
            }
			insert clients;
            update updKAVClient;
            
            list<knowledge__kav> pubKAVClient = new list<knowledge__kav>([select id, knowledgeArticleId from knowledge__kav where id in : kavIDsClient]);   
            for(Knowledge__kav article: pubKAVClient) {
                kaIDsClient.add(article.knowledgeArticleId);
                KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
            }
        
        Id [] fixedSearchResults= new Id[3];
       fixedSearchResults[0] = kavIDsClient[0];
        fixedSearchResults[1] = kavIDsClient[1];
        fixedSearchResults[2] = kavIDsClient[2];
       Test.setFixedSearchResults(fixedSearchResults);
        
        List<String> sc = New List<String>();
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper result = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '111', '', true);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper results = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', '111', dataCategory.DataCategoryName);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultn = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '111', 'Registration_scheduling', true);
        System.assert(result != null);
    }
    static testMethod void testGetKnowledgeSearchSuggestionResults5() {
           TestDataFactory testDataFactory = new TestDataFactory();
        List<knowledge__kav> articleListClient = TestDataFactory.createKnowledgeArticlesfalse(3);
            list<id> kavIDsClient = new list<id> ();
            list<id> kaIDsClient = new list<id> ();
            list<knowledge__kav> updKAVClient = new list<knowledge__kav>();
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		system.debug(dcList);
            
        	Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
            dataCategory.DataCategoryGroupName = 'Candidate';
            dataCategory.DataCategoryName = dcList[0];
            dataCategory.parentId = articleListClient[0].Id;
            insert dataCategory;
        
			Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
            Account acc = new Account(name='TestkaAccount', recordtypeId = recordType, Client_code__c = '111',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
          	insert acc;
			
			list<Linked_Client__c > clients =  new list<Linked_Client__c>();
            
            for(knowledge__kav k : articleListClient){
                k.Approval_status__c='Approved';
                updKAVClient.add(k);
                kavIDsClient.add(k.id);
				clients.add(new Linked_Client__c(Knowledge_Article__c = k.id, Client__c = acc.id));
            }
			insert clients;
            update updKAVClient;
            
            list<knowledge__kav> pubKAVClient = new list<knowledge__kav>([select id, knowledgeArticleId from knowledge__kav where id in : kavIDsClient]);   
            for(Knowledge__kav article: pubKAVClient) {
                kaIDsClient.add(article.knowledgeArticleId);
                KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
            }
        
        // Create test data for Knowledge__DataCategorySelection
    /*List<Knowledge__DataCategorySelection> dataCategories = new List<Knowledge__DataCategorySelection>();

    // Assuming articleListClient has at least one record with MasterVersionId
    Id masterVersionId = articleListClient[0].MasterVersionId;

    // Create a data category with a matching ParentId
    Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
    dataCategory.ParentId = masterVersionId;
    dataCategory.DataCategoryName = 'TestCategory';
    dataCategory.DataCategoryGroupName = 'TestGroup';
    // Add any other necessary fields for your test
    dataCategories.add(dataCategory);

    // Insert data categories
    insert dataCategories;*/

        
        Id [] fixedSearchResults= new Id[3];
       fixedSearchResults[0] = kavIDsClient[0];
        fixedSearchResults[1] = kavIDsClient[1];
        fixedSearchResults[2] = kavIDsClient[2];
       Test.setFixedSearchResults(fixedSearchResults);
        
        List<String> sc = New List<String>();
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper result = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '111', '', true);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper results = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', '111', dataCategory.DataCategoryName);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultn = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '111', 'Registration_scheduling', true);
        System.assert(result != null);
        
    }
    static testMethod void testGetKnowledgeSearchSuggestionResults6() {
           TestDataFactory testDataFactory = new TestDataFactory();
        List<knowledge__kav> articleListClient = TestDataFactory.createKnowledgeArticles(3);
            list<id> kavIDsClient = new list<id> ();
            list<id> kaIDsClient = new list<id> ();
            list<knowledge__kav> updKAVClient = new list<knowledge__kav>();
            
			Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
            Account acc = new Account(name='TestkaAccount', recordtypeId = recordType, Client_code__c = '111',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
          	insert acc;
			
			list<Linked_Client__c > clients =  new list<Linked_Client__c>();
            
            for(knowledge__kav k : articleListClient){
                k.Approval_status__c='Approved';
                updKAVClient.add(k);
                kavIDsClient.add(k.id);
				clients.add(new Linked_Client__c(Knowledge_Article__c = k.id, Client__c = acc.id));
            }
			insert clients;
            update updKAVClient;
            
            list<knowledge__kav> pubKAVClient = new list<knowledge__kav>([select id, knowledgeArticleId from knowledge__kav where id in : kavIDsClient]);   
            for(Knowledge__kav article: pubKAVClient) {
                kaIDsClient.add(article.knowledgeArticleId);
                KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
            }
        
        Id [] fixedSearchResults= new Id[3];
       fixedSearchResults[0] = kavIDsClient[0];
        fixedSearchResults[1] = kavIDsClient[1];
        fixedSearchResults[2] = kavIDsClient[2];
       Test.setFixedSearchResults(fixedSearchResults);
        
        List<String> sc = New List<String>();
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper result = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '111', '', false);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper results = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', '', '');
       SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultn = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '111', 'Registration_scheduling', false);
        System.assert(result != null);
    }
    static testMethod void testGetKnowledgeSearchSuggestionResults7() {
           TestDataFactory testDataFactory = new TestDataFactory();
        List<knowledge__kav> articleListClient = TestDataFactory.createKnowledgeArticles(3);
            list<id> kavIDsClient = new list<id> ();
            list<id> kaIDsClient = new list<id> ();
            list<knowledge__kav> updKAVClient = new list<knowledge__kav>();
            
			Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
            Account acc = new Account(name='TestkaAccount', recordtypeId = recordType, Client_code__c = '111', Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
          	insert acc;
			
			list<Linked_Client__c > clients =  new list<Linked_Client__c>();    
            for(knowledge__kav k : articleListClient){
                k.Approval_status__c='Approved';
                updKAVClient.add(k);
                kavIDsClient.add(k.id);
				clients.add(new Linked_Client__c(Knowledge_Article__c = k.id, Client__c = acc.id));
            }
			insert clients;
            update updKAVClient;
            
            list<knowledge__kav> pubKAVClient = new list<knowledge__kav>([select id, knowledgeArticleId from knowledge__kav where id in : kavIDsClient]);   
            for(Knowledge__kav article: pubKAVClient) {
                kaIDsClient.add(article.knowledgeArticleId);
                KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
            }
        
        Id [] fixedSearchResults= new Id[3];
       fixedSearchResults[0] = kavIDsClient[0];
        fixedSearchResults[1] = kavIDsClient[1];
        fixedSearchResults[2] = kavIDsClient[2];
       Test.setFixedSearchResults(fixedSearchResults);
        
        List<String> sc = New List<String>();
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper result = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '111', '', false);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper results = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', '', '');
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultn = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '111', 'Registration_scheduling', false);
        System.assert(result != null);
    }
    
    static testMethod void testGetKnowledgeSearchSuggestionResults8() {
           TestDataFactory testDataFactory = new TestDataFactory();
        List<knowledge__kav> articleList = TestDataFactory.createKnowledgeArticles(3);                      
            list<id> kavIDs = new list<id> ();
            list<id> kaIDs = new list<id> ();
            list<knowledge__kav> updKAV = new list<knowledge__kav>();
            for(knowledge__kav k : articleList){
                k.Approval_status__c='Approved';
                updKAV.add(k);
                kavIDs.add(k.id);
            }
            update updKAV;
            list<knowledge__kav> pubKAV = new list<knowledge__kav>([select id, knowledgeArticleId from knowledge__kav where id in : kavIDs]);
            for(Knowledge__kav article: pubKAV) {
                kaIDs.add(article.knowledgeArticleId);
                KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
            }
        Id [] fixedSearchResults= new Id[3];
       fixedSearchResults[0] = kavIDs[0];
        fixedSearchResults[1] = kavIDs[1];
        fixedSearchResults[2] = kavIDs[2];
       Test.setFixedSearchResults(fixedSearchResults);
        
        List<String> sc = New List<String>();
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper result = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '', '', false);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper results = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', '', '');
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultn = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '', 'Registration_scheduling', false);
        System.assert(result != null);
    }
    static testMethod void testGetDataCategoriesFilter() {
        // Test the getDataCategoriesFilter method
        List<SHP_KnowledgeSearchResultsController.dataCategoriesFilterWrapper> dataCategories = SHP_KnowledgeSearchResultsController.getDataCategoriesFilter();
        System.assert(dataCategories != null);
         }
   
    static testMethod void testGetKnowledgeSearchSuggestionResults10() {
           TestDataFactory testDataFactory = new TestDataFactory();
        List<knowledge__kav> articleListClient = TestDataFactory.createKnowledgeArticlesfalse(3);
        List<knowledge__kav> articleListClient1 = TestDataFactory.createKnowledgeArticles(3);
            list<id> kavIDsClient = new list<id> ();
            list<id> kaIDsClient = new list<id> ();
            list<knowledge__kav> updKAVClient = new list<knowledge__kav>();
            
			Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
            Account acc = new Account(name='TestkaAccount', recordtypeId = recordType, Client_code__c = '111',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
          	insert acc;
        
        // Create test data for Knowledge__DataCategorySelection
    List<Knowledge__DataCategorySelection> dataCategories = new List<Knowledge__DataCategorySelection>();
    // Assuming articleList has at least one record with MasterVersionId
    Id knowledgeArticleId = articleListClient[0].Id;
        System.debug('44::'+ articleListClient[0].Id);
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		system.debug(dcList);
 
    // Create a data category with a matching ParentId
    Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
    dataCategory.ParentId = knowledgeArticleId;
    dataCategory.DataCategoryName = dcList[0];
    dataCategory.DataCategoryGroupName = 'Candidate';
        
    Knowledge__DataCategorySelection dataCategory1 = new Knowledge__DataCategorySelection();
    dataCategory1.ParentId = articleListClient1[0].Id;
    dataCategory1.DataCategoryName = dcList[0];
    dataCategory1.DataCategoryGroupName = 'Candidate';
    // Add any other necessary fields for your test
    dataCategories.add(dataCategory);
    dataCategories.add(dataCategory1);
        
        
 
    // Insert data categories
    insert dataCategories;
        Linked_Client__c lctest = new Linked_Client__c(Knowledge_Article__c = articleListClient[0].Id, Client__c = acc.Id);
        insert lctest;
        for(knowledge__kav k : articleListClient){
                k.Approval_status__c='Approved';
                updKAVClient.add(k);
                kavIDsClient.add(k.id);
				//clients.add(new Linked_Client__c(Knowledge_Article__c = k.id, Client__c = acc.id));
            }
        for(knowledge__kav k : articleListClient1){
                k.Approval_status__c='Approved';
                updKAVClient.add(k);
                kavIDsClient.add(k.id);
				//clients.add(new Linked_Client__c(Knowledge_Article__c = k.id, Client__c = acc.id));
            }
        
			
			/*list<Linked_Client__c > clients =  new list<Linked_Client__c>();
            
            for(knowledge__kav k : articleListClient){
                k.Approval_status__c='Approved';
                updKAVClient.add(k);
                kavIDsClient.add(k.id);
				clients.add(new Linked_Client__c(Knowledge_Article__c = k.id, Client__c = acc.id));
            }
            for(knowledge__kav k : articleListClient1){
                k.Approval_status__c='Approved';
                updKAVClient.add(k);
                kavIDsClient.add(k.id);
            }
			insert clients;*/
            update updKAVClient;
            
            list<knowledge__kav> pubKAVClient = new list<knowledge__kav>([select id, knowledgeArticleId from knowledge__kav where id in : kavIDsClient]);   
            for(Knowledge__kav article: pubKAVClient) {
                kaIDsClient.add(article.knowledgeArticleId);
                KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
            }
        
        Id [] fixedSearchResults= new Id[3];
       fixedSearchResults[0] = kavIDsClient[0];
        fixedSearchResults[1] = kavIDsClient[1];
        fixedSearchResults[2] = kavIDsClient[2];
       Test.setFixedSearchResults(fixedSearchResults);
        
        List<String> sc = New List<String>();
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper result = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '111', '', true);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper results = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', '', '');
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultn = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '111', 'Registration_scheduling', true);
        System.assert(result != null);
    }
    
    static testMethod void testGetKnowledgeSearchSuggestionResults9() {
    TestDataFactory testDataFactory = new TestDataFactory();
    List<knowledge__kav> articleList = TestDataFactory.createKnowledgeArticles(3);
 
    list<id> kavIDsClient = new list<id> ();
    list<id> kaIDsClient = new list<id> ();
    list<knowledge__kav> updKAVClient = new list<knowledge__kav>();
            
    Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
    Account acc = new Account(name='TestkaAccount', recordtypeId = recordType, Client_code__c = '111',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
    insert acc;
            
        
    // Create test data for Knowledge__DataCategorySelection
    List<Knowledge__DataCategorySelection> dataCategories = new List<Knowledge__DataCategorySelection>();
    System.debug('88'+ articleList[0]);
    // Assuming articleList has at least one record with MasterVersionId
    Id masterVersionId = articleList[0].Id;
        
      list<string> dcList = new list<string>();       
	  for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		system.debug(dcList);
 
    // Create a data category with a matching ParentId
    Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
    dataCategory.ParentId = masterVersionId;
    dataCategory.DataCategoryName = dcList[0];
    dataCategory.DataCategoryGroupName = 'Candidate';
        
    Knowledge__DataCategorySelection dataCategory1 = new Knowledge__DataCategorySelection();
    dataCategory1.ParentId = articleList[1].Id;
    dataCategory1.DataCategoryName = dcList[0];
    dataCategory1.DataCategoryGroupName = 'Candidate';
    // Add any other necessary fields for your test
    dataCategories.add(dataCategory);
    dataCategories.add(dataCategory1);
        
        
 
    // Insert data categories
    insert dataCategories;
        Linked_Client__c lctest = new Linked_Client__c(Knowledge_Article__c = articleList[1].Id, Client__c = acc.Id);
        insert lctest;
        
        for(knowledge__kav k : articleList){
                k.Approval_status__c='Approved';
                updKAVClient.add(k);
                kavIDsClient.add(k.id);
				//clients.add(new Linked_Client__c(Knowledge_Article__c = k.id, Client__c = acc.id));
            }
        
        
 
    List<Id> kavIDs = new List<Id>();
    List<Id> kaIDs = new List<Id>();
    List<knowledge__kav> updKAV = new List<knowledge__kav>();
 
    for (knowledge__kav k : articleList) {
        k.Approval_status__c = 'Approved';
        updKAV.add(k);
        kavIDs.add(k.Id);
    }
    update updKAV;
 
    List<knowledge__kav> pubKAV = [SELECT Id, knowledgeArticleId FROM knowledge__kav WHERE Id IN :kavIDs];
    for (Knowledge__kav article : pubKAV) {
        kaIDs.add(article.knowledgeArticleId);
        KbManagement.PublishingService.publishArticle(article.knowledgeArticleId, false);
    }
 
    Id[] fixedSearchResults = new Id[3];
    fixedSearchResults[0] = kavIDs[0];
    fixedSearchResults[1] = kavIDs[1];
    fixedSearchResults[2] = kavIDs[2];
    Test.setFixedSearchResults(fixedSearchResults);
 
    List<String> sc = new List<String>();
    SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper result = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '', '', true);
 SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper results = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', '', '');
    SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultn = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '', 'Registration_scheduling', true);
        // Add assertions for the data category logic
    System.assert(result != null);
    //System.assertEquals(1, result.searchResultsList[0].dataCategoriesList.size());
   // System.assertEquals('TestCategory', result.dataCategoriesList[0].dcName);
    // Add more assertions as needed
}
    static testMethod void testGetKnowledgeSearchSuggestionResults11() {
        TestDataFactory testDataFactory = new TestDataFactory();
        List<knowledge__kav> articleList = TestDataFactory.createKnowledgeArticles(3);
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
 
        for (knowledge__kav k : articleList) {
            k.Approval_status__c = 'Approved';
            updKAV.add(k);
            kavIDs.add(k.id);
        }
        update updKAV;
 
        List<knowledge__kav> pubKAV = [SELECT Id, knowledgeArticleId FROM knowledge__kav WHERE Id IN :kavIDs];
        for (Knowledge__kav article : pubKAV) {
            kaIDs.add(article.knowledgeArticleId);
           // KbManagement.PublishingService.publishArticle(article.knowledgeArticleId, false);
        }
 
        Id[] fixedSearchResults = new Id[3];
        fixedSearchResults[0] = kavIDs[0];
        fixedSearchResults[1] = kavIDs[1];
        fixedSearchResults[2] = kavIDs[2];
       // Test.setFixedSearchResults(fixedSearchResults);
 
        List<String> sc = new List<String>();
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper result = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', 'All', '', true);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper results = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', '', '');
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultn = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', 'All', 'Registration_scheduling', true);
        System.assert(result != null);
    }
    static testMethod void testGetKnowledgeSearchSuggestionResults12() {
           TestDataFactory testDataFactory = new TestDataFactory();
        List<knowledge__kav> articleListClient = TestDataFactory.createKnowledgeArticlesfalse(3);
            list<id> kavIDsClient = new list<id> ();
            list<id> kaIDsClient = new list<id> ();
            list<knowledge__kav> updKAVClient = new list<knowledge__kav>();
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		system.debug(dcList);
            
        	Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
            dataCategory.DataCategoryGroupName = 'Candidate';
            dataCategory.DataCategoryName = dcList[0];
            dataCategory.parentId = articleListClient[0].Id;
            insert dataCategory;
        
			Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
            Account acc = new Account(name='TestkaAccount', recordtypeId = recordType, Client_code__c = '111',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
          	insert acc;
			
			list<Linked_Client__c > clients =  new list<Linked_Client__c>();
            
            for(knowledge__kav k : articleListClient){
                k.Approval_status__c='Approved';
                updKAVClient.add(k);
                kavIDsClient.add(k.id);
				clients.add(new Linked_Client__c(Knowledge_Article__c = k.id, Client__c = acc.id));
            }
			insert clients;
            update updKAVClient;
            
            list<knowledge__kav> pubKAVClient = new list<knowledge__kav>([select id, knowledgeArticleId from knowledge__kav where id in : kavIDsClient]);   
            for(Knowledge__kav article: pubKAVClient) {
                kaIDsClient.add(article.knowledgeArticleId);
                KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
            }
       
        
        Id [] fixedSearchResults= new Id[3];
       fixedSearchResults[0] = kavIDsClient[0];
        fixedSearchResults[1] = kavIDsClient[1];
        fixedSearchResults[2] = kavIDsClient[2];
       Test.setFixedSearchResults(fixedSearchResults);
        
        List<String> sc = New List<String>();
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper result = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '111', '', false);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper results = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', '111', dataCategory.DataCategoryName);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultn = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', '111', 'Registration_scheduling', false);
        System.assert(result != null);
        
    }
    
    static testMethod void testGetKnowledgeSearchSuggestionResults13() {
        TestDataFactory testDataFactory = new TestDataFactory();
        List<knowledge__kav> articleList = TestDataFactory.createKnowledgeArticles(3);
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		system.debug(dcList);
        
        Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
        dataCategory.DataCategoryGroupName = 'Candidate';
        dataCategory.DataCategoryName = dcList[0];
        dataCategory.parentId = articleList[0].Id;
        insert dataCategory;
        
        Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
            Account acc = new Account(name='TestkaAccount', recordtypeId = recordType, Client_code__c = '111',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
          	insert acc;
			
			list<Linked_Client__c > clients =  new list<Linked_Client__c>();
            
 
        for (knowledge__kav k : articleList) {
            k.Approval_status__c = 'Approved';
            updKAV.add(k);
            kavIDs.add(k.id);
        }
        insert clients;
        update updKAV;
 
        List<knowledge__kav> pubKAV = [SELECT Id, knowledgeArticleId FROM knowledge__kav WHERE Id IN :kavIDs];
        for (Knowledge__kav article : pubKAV) {
            kaIDs.add(article.knowledgeArticleId);
            KbManagement.PublishingService.publishArticle(article.knowledgeArticleId, false);
        }
        
        System.debug(kaIDs);
 
        Id[] fixedSearchResults = new Id[3];
        fixedSearchResults[0] = kavIDs[0];
        fixedSearchResults[1] = kavIDs[1];
        fixedSearchResults[2] = kavIDs[2];
        Test.setFixedSearchResults(fixedSearchResults);
 
       // String sc = new String();
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper result = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', 'All', '', true);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper results = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', 'All', dataCategory.DataCategoryName);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultn = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', 'All', dataCategory.DataCategoryName, true);
        //SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultp = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', 'All', dataCategory.DataCategoryName );
        System.assert(result != null);
    }
    
    static testMethod void testGetKnowledgeSearchSuggestionResults14() {
        TestDataFactory testDataFactory = new TestDataFactory();
        List<knowledge__kav> articleList = TestDataFactory.createKnowledgeArticles(3);
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		system.debug(dcList);
        
        Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
        dataCategory.DataCategoryGroupName = 'Candidate';
        dataCategory.DataCategoryName = dcList[0];
        dataCategory.parentId = articleList[0].Id;
        insert dataCategory;
        
        Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
            Account acc = new Account(name='TestkaAccount', recordtypeId = recordType, Client_code__c = '111',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
          	insert acc;
			
			list<Linked_Client__c > clients =  new list<Linked_Client__c>();
            
 
        for (knowledge__kav k : articleList) {
            k.Approval_status__c = 'Approved';
            updKAV.add(k);
            kavIDs.add(k.id);
        }
        insert clients;
        update updKAV;
 
        List<knowledge__kav> pubKAV = [SELECT Id, knowledgeArticleId FROM knowledge__kav WHERE Id IN :kavIDs];
        for (Knowledge__kav article : pubKAV) {
            kaIDs.add(article.knowledgeArticleId);
            KbManagement.PublishingService.publishArticle(article.knowledgeArticleId, false);
        }
        
        System.debug(kaIDs);
 
        Id[] fixedSearchResults = new Id[3];
        fixedSearchResults[0] = kavIDs[0];
        fixedSearchResults[1] = kavIDs[1];
        fixedSearchResults[2] = kavIDs[2];
        Test.setFixedSearchResults(fixedSearchResults);
 
       // String sc = new String();
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper result = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', 'All', '', null);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper results = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', 'All', dataCategory.DataCategoryName);
        SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultn = SHP_KnowledgeSearchResultsController.getKnowledgeSearchSuggestionResults('Test', 'en_US', 'All', dataCategory.DataCategoryName, true);
        //SHP_KnowledgeSearchResultsController.searchSuggestionsKnowledgeWrapper resultp = SHP_KnowledgeSearchResultsController.getCategorySpecificArticles('en_US', 'All', dataCategory.DataCategoryName );
        System.assert(result != null);
    }
    }