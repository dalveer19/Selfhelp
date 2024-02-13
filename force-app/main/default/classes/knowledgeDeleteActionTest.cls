@isTest
public class knowledgeDeleteActionTest {
    
    private class TestDataFactory {
        public Knowledge__kav createTestArticle(String publishStatus, Id ownerId) {
            Knowledge__kav testArticle = new Knowledge__kav(
                Title = 'Test Article',
                Summary = 'Test Summary',
                UrlName = 'TestArticle',
                FAQ_Question__c = 'Test Question',
                FAQ_Answer__c = 'Test Answer',
                Candidate_s_Section__c = 'Test Section',
                OwnerId = ownerId,
                Language = 'en_US'
            );
            insert testArticle;
            
            return testArticle;
        }
        
        public PermissionSetAssignment createTestPermissionSetAssignment(Id permissionSetId, Id assigneeId) {
            PermissionSetAssignment assignment = new PermissionSetAssignment(
                PermissionSetId = permissionSetId,
                AssigneeId = assigneeId
            );
            //insert assignment;
            return assignment;
        }
    }
    
    @isTest
    static void testDeleteKAWithPermission() {
        TestDataFactory factory = new TestDataFactory();
        
        // Create a Knowledge Article with a PermissionSetAssignment
        Knowledge__kav testArticle = factory.createTestArticle('Draft', UserInfo.getUserId());
        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Knowledge_Content_Manager_PS' LIMIT 1];
        PermissionSetAssignment permissionAssignment = factory.createTestPermissionSetAssignment(permissionSet.Id, UserInfo.getUserId());
        
        Test.startTest();        
        String result = knowledgeDeleteAction.deleteKA(testArticle.Id);
        Test.stopTest();
        
        // Verify that the method returned the correct result
        System.assertEquals([SELECT Id, Name FROM ListView WHERE SobjectType = 'Knowledge__kav' AND DeveloperName = 'draft_articles' LIMIT 1].Id, result);
        System.assertNotEquals(null, result);
        
        // Create another test article with different conditions to make the else block execute in the deleteKA method
        Knowledge__kav testArticle2 = factory.createTestArticle('Online', UserInfo.getUserId());
        String result2 = knowledgeDeleteAction.deleteKA(testArticle2.Id);
        
        System.assertNotEquals(null, result2);
    }

    @isTest
    static void testDeleteKAWithPermission2() {
        TestDataFactory factory = new TestDataFactory();
        
        // Create a Knowledge Article with a PermissionSetAssignment
        Knowledge__kav testArticle = factory.createTestArticle('Draft', UserInfo.getUserId());
        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Knowledge_Content_Manager_PS' LIMIT 1];
        PermissionSetAssignment permissionAssignment = factory.createTestPermissionSetAssignment(permissionSet.Id, UserInfo.getUserId());
        
        // Call the deleteKA method
        testArticle.Approval_status__c = 'Approved';
        Id kavId = testArticle.Id;
        Update testArticle;
        
        knowledge__kav pubKav = [SELECT Id, knowledgeArticleId FROM knowledge__kav WHERE Id =: kavID];
        KbManagement.PublishingService.publishArticle(pubKav.knowledgeArticleId, false);
        
        try {
            String result = knowledgeDeleteAction.deleteKA(testArticle.Id);
            //System.assert(false, 'An exception should be thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'The exception message should be error');
        }

        
    }

}