@isTest
public class CommonHelpTopicsTest{

 public class TestDataFactory {
 
 public Common_help_topics__c createCommonHelpTopic(String label, String url, String language, String order, Boolean openNewTab) {
        Common_help_topics__c commonHelpTopic = new Common_help_topics__c(
            Label__c = label,
            Url__c = url,
            Language__c = language,
            Order__c = order,
            Open_New_tab__c = openNewTab
        );
        insert commonHelpTopic;
        return commonHelpTopic;
    }
}

 
    @isTest
    public static void testGetCommonHelpTopics() {
        
        TestDataFactory testDataFactory = new TestDataFactory();
        // Create test data using Test Data Factory
        Common_help_topics__c commonHelpTopic1 = TestDataFactory.createCommonHelpTopic('Test Topic', 'https://www.example.com/test', 'en_US', '1', false);
        Common_help_topics__c commonHelpTopic2 = TestDataFactory.createCommonHelpTopic('Test Topic 2', 'https://www.example.com/test2', 'en_US', '2', true);
 
        // Call the method to be tested
        List<CommonHelpTopics.CommonWrapper> result = CommonHelpTopics.getCommonHelpTopics('en_US');
 
        // Verify the results
        System.assertEquals(2, result.size(), 'Expected two records to be returned');
        CommonHelpTopics.CommonWrapper commonWrapper = result[0];
        System.assertEquals('Test Topic', commonWrapper.label);
        System.assertEquals('https://www.example.com/test', commonWrapper.url);
        System.assertEquals('en_US', commonWrapper.language);
        System.assertEquals('1', commonWrapper.order);
        System.assertEquals('_self', commonWrapper.target);
        CommonHelpTopics.CommonWrapper commonWrapper2 = result[1];
        System.assertEquals('Test Topic 2', commonWrapper2.label);
        System.assertEquals('https://www.example.com/test2', commonWrapper2.url);
        System.assertEquals('en_US', commonWrapper2.language);
        System.assertEquals('2', commonWrapper2.order);
        System.assertEquals('_blank', commonWrapper2.target);
    }
}