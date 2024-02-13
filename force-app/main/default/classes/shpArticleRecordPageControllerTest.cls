@isTest
public class shpArticleRecordPageControllerTest {
    
    @isTest
    public static shpArticleRecordPageController.KnowledgeRecordWrapper getKnowledgeRecordTest() {
        Knowledge__kav testArticle = new Knowledge__kav();
        testArticle.Title = 'Test Article';
        testArticle.UrlName = 'Test-1';
        testArticle.Article_visiblity_for_candidate__c = true;
        testArticle.feature_article__c = true;
        testArticle.Applicable_to_all_clients__c = true;
        insert testArticle;
        
        testArticle.Approval_status__c = 'Approved';
        ID kavID = testArticle.id;
        update testArticle;
        
        shpArticleRecordPageController.KnowledgeRecordWrapper result = shpArticleRecordPageController.getKnowledgeRecord(testArticle.Id);
        System.assertNotEquals(null, result);
        return result;
    }
    
    @isTest
    public static String updateKnowledgeRecordTest1() {
        Knowledge__kav testArticle = new Knowledge__kav();
        testArticle.Title = 'Test Article';
        testArticle.UrlName = 'Test-1';
        testArticle.Article_visiblity_for_candidate__c = true;
        testArticle.feature_article__c = true;
        testArticle.Applicable_to_all_clients__c = true;
        insert testArticle;
        
        testArticle.Approval_status__c = 'Approved';
        ID kavID = testArticle.id;
        update testArticle;
        
        String result = shpArticleRecordPageController.updateKnowledgeRecord(true, true, true, testArticle.Id, true);
        System.assertEquals(null, result);
        return result;
    }
    
    @isTest
    public static String updateKnowledgeRecordTest2() {
        Knowledge__kav testArticle = new Knowledge__kav();
        testArticle.Title = 'Test Article';
        testArticle.UrlName = 'Test-1';
        testArticle.Article_visiblity_for_candidate__c = true;
        testArticle.feature_article__c = true;
        testArticle.Applicable_to_all_clients__c = true;
        insert testArticle;
        
        testArticle.Approval_status__c = 'Approved';
        ID kavID = testArticle.id;
        update testArticle;
        
        String result = shpArticleRecordPageController.updateKnowledgeRecord(true, false, true, testArticle.Id, true);
        System.assertNotEquals(null, result);
        return result;
    }
}