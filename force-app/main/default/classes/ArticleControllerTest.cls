@isTest
private class ArticleControllerTest {

    private class TestDataFactory {
        public Knowledge__kav createTestArticle(String title, Boolean isVisibleToPublic) {
            Id krecordType = [Select Name, Id, developerName From RecordType where sObjectType='Knowledge__kav' and isActive=true and developerName = 'Candidate' limit 1].id;
            Knowledge__kav testArticle = new Knowledge__kav(
                Title = title,
                Summary = 'Test Summary',
                UrlName = title.replaceAll('\\s+', ''),
                FAQ_Question__c = 'Test Question',
                FAQ_Answer__c = 'Test Answer',
                Candidate_s_Section__c = 'Test Section',
                Public_content__c = isVisibleToPublic,
                Language = 'en_US',
                recordtypeId = krecordType
            );
            insert testArticle;
            return testArticle;
        }
    }

    @isTest
    static void testGetKnowledgeDetails() {
        TestDataFactory factory = new TestDataFactory();
        Knowledge__kav testArticle = factory.createTestArticle('Test Article', true);
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        
        Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
        Account acc = new Account(name='TestkaAccount11', recordtypeId = recordType, Client_code__c = '2435',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
        insert acc;
                
        Linked_Client__c clients = new Linked_Client__c(Knowledge_Article__c = testArticle.Id, Client__c = acc.Id);
        insert clients;
        
            testArticle.Approval_status__c = 'Approved';
            updKAV.add(testArticle);
            kavIDs.add(testArticle.id);
        update updKAV;
        
        List<knowledge__kav> pubKAV = [SELECT Id, knowledgeArticleId FROM knowledge__kav WHERE Id IN :kavIDs];
        for (Knowledge__kav article : pubKAV) {
            kaIDs.add(article.knowledgeArticleId);
            KbManagement.PublishingService.publishArticle(article.knowledgeArticleId, false);
        }

        List<ArticleController.KnowledgeArticleWrapper> result = ArticleController.getKnowledgeDetails(testArticle.Id, 'en_US');

        System.assertEquals(1, result.size());
        ArticleController.KnowledgeArticleWrapper articleWrapper = result[0];

        System.assertEquals(testArticle.Id, articleWrapper.Id);
        System.assertEquals(testArticle.Title, articleWrapper.Title);
        System.assertEquals(testArticle.Summary, articleWrapper.Summary);
        System.assertEquals(testArticle.FAQ_Question__c, articleWrapper.Question);
        System.assertEquals(testArticle.FAQ_Answer__c, articleWrapper.Answer);
        System.assertEquals(testArticle.Candidate_s_Section__c, articleWrapper.Candidatesection);
        System.assertEquals(true, articleWrapper.isVisibleToPublic);
    }
    
    @istest
    static void testGetKnowledgeDetails1() {
        TestDataFactory factory = new TestDataFactory();
        Knowledge__kav testArticle = factory.createTestArticle('Test Article', true);
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        
        Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
        
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 3 ; i++) {
            testAccounts.add(new Account(name='TestkaAccountk' + i, recordtypeId = recordType, Client_code__c = 'code' + i,Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true));
        }
        insert testAccounts;
        
        List<Linked_Client__c> clients = new List<Linked_Client__c>();
        for (Account acc : testAccounts) {
            clients.add(new Linked_Client__c(Knowledge_Article__c = testArticle.Id, Client__c = acc.Id));
        }
        insert clients;
        
            testArticle.Approval_status__c = 'Approved';
            updKAV.add(testArticle);
            kavIDs.add(testArticle.id);
        update updKAV;
        
        List<knowledge__kav> pubKAV = [SELECT Id, knowledgeArticleId FROM knowledge__kav WHERE Id IN :kavIDs];
        for (Knowledge__kav article : pubKAV) {
            kaIDs.add(article.knowledgeArticleId);
            KbManagement.PublishingService.publishArticle(article.knowledgeArticleId, false);
        }

        List<ArticleController.KnowledgeArticleWrapper> result = ArticleController.getKnowledgeDetails(testArticle.Id, 'en_US');

        System.assertEquals(1, result.size());
        ArticleController.KnowledgeArticleWrapper articleWrapper = result[0];

        System.assertEquals(testArticle.Id, articleWrapper.Id);
        System.assertEquals(testArticle.Title, articleWrapper.Title);
        System.assertEquals(testArticle.Summary, articleWrapper.Summary);
        System.assertEquals(testArticle.FAQ_Question__c, articleWrapper.Question);
        System.assertEquals(testArticle.FAQ_Answer__c, articleWrapper.Answer);
        System.assertEquals(testArticle.Candidate_s_Section__c, articleWrapper.Candidatesection);
        System.assertEquals(true, articleWrapper.isVisibleToPublic);
    }
    
    @istest
    static void testGetKnowledgeArticleDetails() {
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        TestDataFactory factory = new TestDataFactory();
        Knowledge__kav testArticle = factory.createTestArticle('Test Article', true);
        Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
        Account acc = new Account(name='TestkaAccount11', recordtypeId = recordType, Client_code__c = '2435',Displays_in_Self_Help__c = true, Active__c = true,Is_external__c = true);
        insert acc;
                
        Linked_Client__c clients = new Linked_Client__c(Knowledge_Article__c = testArticle.Id, Client__c = acc.Id);
        insert clients;
        
        testArticle.Approval_status__c = 'Approved';
            updKAV.add(testArticle);
            kavIDs.add(testArticle.id);
        update updKAV;
        
        List<knowledge__kav> pubKAV = [SELECT Id, knowledgeArticleId FROM knowledge__kav WHERE Id IN :kavIDs];
        for (Knowledge__kav article : pubKAV) {
            kaIDs.add(article.knowledgeArticleId);
            KbManagement.PublishingService.publishArticle(article.knowledgeArticleId, false);
        }
        ArticleController.ArticleDetailsWrapper result = ArticleController.getKnowledgeArticleDetails(testArticle.Id, 'en_US');
        System.assertNotEquals(null, result);
        System.assertEquals('Test Summary', result.Summary);

    }
    
    @isTest
    static void getKnowledgeArticleDetailsTest() {
        TestDataFactory factory = new TestDataFactory();
        Knowledge__kav testArticle = factory.createTestArticle('Test Article', true);
        ArticleController.ArticleDetailsWrapper result = ArticleController.getKnowledgeArticleDetails(testArticle.Id, 'Invalid');
    }

}