@isTest
public class TopCategoriesBatchClient1Test {
    
	@isTest
    static void testBatchExecution1() {
        
        top_categories__c dummySetting = new top_categories__c();
        dummySetting.Name = 'TopCategories';
        dummySetting.Categories_List__c = 'Scheduling;Payment';
        dummySetting.size__c = 10;
        insert dummySetting;      
        
        Id krecordType = [Select Name, Id, developerName From RecordType where sObjectType='Knowledge__kav' and isActive=true and developerName = 'Candidate' limit 1].id;
        List<knowledge__kav> articles = new List<knowledge__kav>();
        for (Integer i = 0; i < 2; i++) {
            articles.add(new Knowledge__kav(
                title = 'test' + i,
                UrlName = 'tester---' + i,
                Language = 'en_US',
                Article_visiblity_for_candidate__c = true, recordtypeId = krecordType
            ));
        }
        insert articles;
        
        Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
        Account acc = new Account(name='TestkaAccount11', recordtypeId = recordType, Client_code__c = '2435',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
        insert acc;
                
        List<Linked_Client__c> clients = new List<Linked_Client__c>();
        for (knowledge__kav article : articles) {
            clients.add(new Linked_Client__c(Knowledge_Article__c = article.Id, Client__c = acc.Id));
            system.debug(clients);
        }
        insert clients;
        
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        
        for (knowledge__kav k : articles) {
            k.Approval_status__c = 'Approved';
            updKAV.add(k);
            kavIDs.add(k.id);
        }
        update updKAV;
 
        List<knowledge__kav> pubKAV = [SELECT Id, knowledgeArticleId FROM knowledge__kav WHERE Id IN :kavIDs];
        for (Knowledge__kav article : pubKAV) {
            kaIDs.add(article.knowledgeArticleId);
            KbManagement.PublishingService.publishArticle(article.knowledgeArticleId, false);
        }
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		System.debug(dcList);
        
        List<Knowledge__DataCategorySelection> knowledgedataCategories = new List<Knowledge__DataCategorySelection>();
        for (Integer i = 0; i < articles.size(); i++) {
            knowledgedataCategories.add(new Knowledge__DataCategorySelection(
                DataCategoryGroupName = 'Candidate',
            	DataCategoryName = dcList[0],
            	parentId = articles[i].Id
            ));
        }
        insert knowledgedataCategories;
        
        Test.startTest();
        Database.executeBatch(new TopCategoriesBatchClient1());
        Test.stopTest();

        Top_categories__c setting = Top_categories__c.getOrgDefaults();
        System.assertEquals('Scheduling;Payment', setting.Categories_List__c);
    }
    
    @isTest
    static void testBatchExecution2() {
        
        top_categories__c dummySetting = new top_categories__c();
        dummySetting.Name = 'TopCategories';
        dummySetting.Categories_List__c = 'Scheduling;Payment';
        dummySetting.size__c = 10;
        insert dummySetting;      
        
        Id krecordType = [Select Name, Id, developerName From RecordType where sObjectType='Knowledge__kav' and isActive=true and developerName = 'Candidate' limit 1].id;
        List<knowledge__kav> articles = new List<knowledge__kav>();
        for (Integer i = 0; i < 2; i++) {
            articles.add(new Knowledge__kav(
                title = 'test' + i,
                UrlName = 'tester---' + i,
                Language = 'en_US',
                Article_visiblity_for_candidate__c = true, recordtypeId = krecordType,Applicable_to_all_clients__c = true
            ));
        }
        for (Integer i = 0; i < 2; i++) {
            articles.add(new Knowledge__kav(
                title = 'test' + i,
                UrlName = 'testerr---' + i,
                Language = 'en_US',
                Article_visiblity_for_candidate__c = true, recordtypeId = krecordType
            ));
        }
        insert articles;
        
        Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
        Account acc = new Account(name='TestkaAccountt41', recordtypeId = recordType, Client_code__c = '9876',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
        insert acc;
        
        List<Linked_Client__c> clients = new List<Linked_Client__c>();
        for (knowledge__kav article : articles) {
            clients.add(new Linked_Client__c(Knowledge_Article__c = article.Id, Client__c = acc.Id));
        }
        insert clients;
        
        Account acc2 = new Account(name='TestkaAccountt141', recordtypeId = recordType, Client_code__c = '3323',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
        insert acc2;
        
        List<Linked_Client__c> clients1 = new List<Linked_Client__c>();
        for (knowledge__kav article : articles) {
            clients1.add(new Linked_Client__c(Knowledge_Article__c = article.Id, Client__c = acc2.Id));
        }
        insert clients1;
        
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        
        for (knowledge__kav k : articles) {
            k.Approval_status__c = 'Approved';
            updKAV.add(k);
            kavIDs.add(k.id);
        }
        update updKAV;
 
        List<knowledge__kav> pubKAV = [SELECT Id, knowledgeArticleId FROM knowledge__kav WHERE Id IN :kavIDs];
        for (Knowledge__kav article : pubKAV) {
            kaIDs.add(article.knowledgeArticleId);
            KbManagement.PublishingService.publishArticle(article.knowledgeArticleId, false);
        }
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		System.debug(dcList);
        
        Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
        dataCategory.DataCategoryGroupName = 'Candidate';
        dataCategory.DataCategoryName = dcList[0];
        dataCategory.parentId = articles[0].Id;

        insert dataCategory;
        
        Account_info__c accinfo = new Account_info__c(client__c=acc.id, Top_categories__c='Scheduling;Payment');
        insert accinfo;
        
        Test.startTest();
        Database.executeBatch(new TopCategoriesBatchClient1());
        Test.stopTest();

        Top_categories__c setting = Top_categories__c.getOrgDefaults();
        System.assertEquals('Scheduling;Payment', setting.Categories_List__c);
    }
    
    @isTest
    static void testBatchExecution3() {
        
        top_categories__c dummySetting = new top_categories__c();
        dummySetting.Name = 'TopCategories';
        dummySetting.Categories_List__c = 'Payment';
        dummySetting.size__c = 10;
        insert dummySetting;      
        
        Id krecordType = [Select Name, Id, developerName From RecordType where sObjectType='Knowledge__kav' and isActive=true and developerName = 'Candidate' limit 1].id;
        List<knowledge__kav> articles = new List<knowledge__kav>();
        for (Integer i = 0; i < 50; i++) {
            articles.add(new Knowledge__kav(
                title = 'test' + i,
                UrlName = 'tester---' + i,
                Language = 'en_US',
                Article_visiblity_for_candidate__c = true, recordtypeId = krecordType
            ));
        }
        insert articles;
        
        Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
        Account acc1 = new Account(name='TestkaAccount71', recordtypeId = recordType, Client_code__c = '35y7',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
        insert acc1;
        
        List<Linked_Client__c> clients = new List<Linked_Client__c>();
        for (knowledge__kav article : articles) {
            clients.add(new Linked_Client__c(Knowledge_Article__c = article.Id, Client__c = acc1.Id));
        }
        insert clients;
        
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        
        for (knowledge__kav k : articles) {
            k.Approval_status__c = 'Approved';
            updKAV.add(k);
            kavIDs.add(k.id);
        }
        update updKAV;
 
        List<knowledge__kav> pubKAV = [SELECT Id, knowledgeArticleId FROM knowledge__kav WHERE Id IN :kavIDs];
        for (Knowledge__kav article : pubKAV) {
            kaIDs.add(article.knowledgeArticleId);
            KbManagement.PublishingService.publishArticle(article.knowledgeArticleId, false);
        }
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		System.debug(dcList);
        
        Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
        dataCategory.DataCategoryGroupName = 'Candidate';
        dataCategory.DataCategoryName = dcList[0];
        dataCategory.parentId = articles[0].Id;
        insert dataCategory;
        
        Account_info__c accinfo = new Account_info__c(client__c=acc1.id, Top_categories__c='Payment');
        insert accinfo;
        
        Test.startTest();
        Database.executeBatch(new TopCategoriesBatchClient1());
        Test.stopTest();

        Top_categories__c setting = Top_categories__c.getOrgDefaults();
        System.assertNotEquals('Scheduling;Payment', setting.Categories_List__c);
        System.assertEquals('Payment', setting.Categories_List__c);
    }
    
    @isTest
    static void testBatchExecution4() {
        
        TopCategoriesBatchClient1.isTestRunning = true;
        System.debug(TopCategoriesBatchClient1.isTestRunning);
        
        top_categories__c dummySetting = new top_categories__c();
        dummySetting.Name = 'TopCategories';
        dummySetting.Categories_List__c = 'Scheduling;Payment';
        dummySetting.size__c = 10;
        insert dummySetting;      
        
        Id krecordType = [Select Name, Id, developerName From RecordType where sObjectType='Knowledge__kav' and isActive=true and developerName = 'Candidate' limit 1].id;
        List<knowledge__kav> articles = new List<knowledge__kav>();
        for (Integer i = 0; i < 2; i++) {
            articles.add(new Knowledge__kav(
                title = 'test' + i,
                UrlName = 'tester---' + i,
                Language = 'en_US',
                Article_visiblity_for_candidate__c = true, recordtypeId = krecordType
            ));
        }
        insert articles;
        
        Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
        Account acc = new Account(name='TestkaAccount11', recordtypeId = recordType, Client_code__c = '2435',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
        insert acc;
                
        List<Linked_Client__c> clients = new List<Linked_Client__c>();
        for (knowledge__kav article : articles) {
            clients.add(new Linked_Client__c(Knowledge_Article__c = article.Id, Client__c = acc.Id));
            system.debug(clients);
        }
        insert clients;
        
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        
        for (knowledge__kav k : articles) {
            k.Approval_status__c = 'Approved';
            updKAV.add(k);
            kavIDs.add(k.id);
        }
        update updKAV;
 
        List<knowledge__kav> pubKAV = [SELECT Id, knowledgeArticleId FROM knowledge__kav WHERE Id IN :kavIDs];
        for (Knowledge__kav article : pubKAV) {
            kaIDs.add(article.knowledgeArticleId);
            KbManagement.PublishingService.publishArticle(article.knowledgeArticleId, false);
        }
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		System.debug(dcList);
        
        Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
        dataCategory.DataCategoryGroupName = 'Candidate';
        dataCategory.DataCategoryName = dcList[0];
        dataCategory.parentId = articles[0].Id;
        insert dataCategory;
                
        Test.startTest();
        Database.executeBatch(new TopCategoriesBatchClient1());
        Test.stopTest();

        Top_categories__c setting = Top_categories__c.getOrgDefaults();
        System.assertEquals('Scheduling;Payment', setting.Categories_List__c);
    }
    
    @isTest
    static void testBatchExecution5() {
        
        TopCategoriesBatchClient2.isTestRunning = true;
        System.debug(TopCategoriesBatchClient2.isTestRunning);
        
        top_categories__c dummySetting = new top_categories__c();
        dummySetting.Name = 'TopCategories';
        dummySetting.Categories_List__c = 'Scheduling;Payment';
        dummySetting.size__c = 10;
        insert dummySetting;
        
        Id krecordType = [Select Name, Id, developerName From RecordType where sObjectType='Knowledge__kav' and isActive=true and developerName = 'Candidate' limit 1].id;
        List<knowledge__kav> articles = new List<knowledge__kav>();
        for (Integer i = 0; i < 2; i++) {
            articles.add(new Knowledge__kav(
                title = 'test' + i,
                UrlName = 'tester---' + i,
                Language = 'en_US',
                Article_visiblity_for_candidate__c = true, recordtypeId = krecordType
            ));
        }
        insert articles;
        
        Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
        Account acc1 = new Account(name='TestkaAccount71', recordtypeId = recordType, Client_code__c = '35y7',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
        insert acc1;
        
        List<Linked_Client__c> clients = new List<Linked_Client__c>();
        for (knowledge__kav article : articles) {
            clients.add(new Linked_Client__c(Knowledge_Article__c = article.Id, Client__c = acc1.Id));
        }
        //insert clients;
        
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        
        for (knowledge__kav k : articles) {
            k.Approval_status__c = 'Approved';
            updKAV.add(k);
            kavIDs.add(k.id);
        }
        update updKAV;
 
        List<knowledge__kav> pubKAV = [SELECT Id, knowledgeArticleId FROM knowledge__kav WHERE Id IN :kavIDs];
        for (Knowledge__kav article : pubKAV) {
            kaIDs.add(article.knowledgeArticleId);
            KbManagement.PublishingService.publishArticle(article.knowledgeArticleId, false);
        }
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		System.debug(dcList);
        
        Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
        dataCategory.DataCategoryGroupName = 'Candidate';
        dataCategory.DataCategoryName = dcList[0];
        dataCategory.parentId = articles[0].Id;
        insert dataCategory;
        
        Account_info__c accinfo = new Account_info__c(client__c=acc1.id, Top_categories__c='Scheduling;Payment');
        insert accinfo;
        
        list<Id> articlesIdTest = new List<Id> ();
        articlesIdTest.add(acc1.Id);
        
        Map<Id, Set<Id>> clientArticlesMapTest = new Map<Id, Set<Id>>();
		//clientArticlesMapTest.put(articles[0].Id,articlesIdTest);
        List<String> childCategoriesTest = new List<String>();
        
        Test.startTest();
        Database.executeBatch(new TopCategoriesBatchClient2(clientArticlesMapTest,childCategoriesTest));
        Test.stopTest();

        // Perform assertions or queries to verify the batch results
        // For example, check if the custom setting has been updated correctly
        Top_categories__c setting = Top_categories__c.getOrgDefaults();
        System.assertEquals('Scheduling;Payment', setting.Categories_List__c);
                
    }
}