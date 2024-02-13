@isTest
public class shp_ContactUsTest {
    
    public class TestDataFactory {
        public Account_Info__c createAccountInfo() {
            
            Account_Info__c ai = new Account_Info__c();
            ai.Name = 'Test Account Info';
            ai.en_US__c = 'English US';
            ai.en_GB__c = 'English UK';
            ai.fr_CA__c = 'French Canadian';
            ai.ja__c = 'Japanese';
            ai.ko__c = 'Korean';
            ai.zh_CN__c = 'Simplified Chinese';
            insert ai;
            
            return ai;
        }
    }
        
        static testMethod void testGetKnowledgeSearchSuggestionResults1() {
        TestDataFactory testDataFactory = new TestDataFactory();
        Account_Info__c accountInfo = TestDataFactory.createAccountInfo();
            
            Account a = new Account();
            a.Name = 'Test Account';
            a.Client_code__c = '111';
            insert a;
            
            accountInfo.client__c = a.Id;
            update accountInfo;
            
            List<Account_Info__c> result = shp_ContactUs.getContactInfoUrl(a.Client_code__c, 'ja');
            System.assert(result != null);
        }
}