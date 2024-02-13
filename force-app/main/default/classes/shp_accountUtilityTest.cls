@isTest
public class shp_accountUtilityTest {

    public class TestDataFactory {

        public Self_Help_Language__mdt createTestLanguage(String languageDisplay, String languageCode) {
            Self_Help_Language__mdt testLanguage = new Self_Help_Language__mdt(
                language_Display__c = languageDisplay,
                language__c = languageCode
            );
            //insert testLanguage;
            return testLanguage;
        }

        public Account createTestAccount(String accountName, String clientCode) {
            Account testAccount = new Account(
                Name = accountName,
                Client_code__c = clientCode
            );
            insert testAccount;
            return testAccount;
        }
    }

    @isTest
    public static void testGetLanguage() {
        TestDataFactory testDataFactory = new TestDataFactory();

        // Create a test Self_Help_Language__mdt record using the test data factory
        Self_Help_Language__mdt testLanguage = testDataFactory.createTestLanguage('English - United States', 'en_US');

        // Call the getLanguage method with the language code
        String languageDisplay = shp_accountUtility.getLanguage('en_US');
        // Try to get a language display label for an invalid language code
    Test.startTest();
    try {
        shp_accountUtility.getLanguage('xx');
        Test.stopTest();
        System.assert(false, 'An exception should be thrown for an invalid language code');
    } catch (AuraHandledException e) {
        Test.stopTest();
        System.assert(true, 'An exception was thrown as expected');
    }

        // Verify that the returned language display value matches the expected value
        System.assertEquals(testLanguage.language_Display__c, languageDisplay, 'Language display should match');
    }

    @isTest
    public static void testGetAccountId() {
        TestDataFactory testDataFactory = new TestDataFactory();

        // Create a test Account record using the test data factory
        Account testAccount = testDataFactory.createTestAccount('Test Account', '12');

        // Call the getAccountId method with the client code
        Id accountId = shp_accountUtility.getAccountId('12');

        // Verify that the returned account ID matches the expected value
        System.assertEquals(testAccount.Id, accountId, 'Account ID should match');
    }

    @isTest
    public static void testSelfHelpLanguages() {
        // Call the selfHelpLanguages method
        List<shp_accountUtility.langWrap> langList = shp_accountUtility.selfHelpLanguages();

        // Verify that the returned language list contains the expected values
        System.assertNotEquals(null, langList, 'Language list should not be null');
        System.assertNotEquals(0, langList.size(), 'Expected languages in the list');
    }
}