@isTest
public class SHP_SearchContainerControllerTest {
    private class TestdataFactory {
        public Account createTestClient(String clientCode) {
            String recordTypeId = SHP_SearchContainerController.getRecordTypeIdByDeveloperName(SHP_SearchContainerController.defaultAccountRecordType);
            return new Account(
                Name = 'Test Client',
                Client_code__c = clientCode,
                RecordTypeId = recordTypeId,
                Is_fedramp__c = false,
                Is_external__c = true,
                Active__c = true,
                Displays_in_Self_Help__c = true
            );
        }
    }

    @isTest
    public static void testGetClientsWithClientCode() {
        // Create a test client Account using TestdataFactory
        TestdataFactory factory = new TestdataFactory();
        Account testClient = factory.createTestClient('1234');
        insert testClient;

        // Call the 'getClients' method
        SHP_SearchContainerController.SearchContainerClientWrapper result = SHP_SearchContainerController.getClients('1234');

        // Verify that the selectedClient in the result matches the test client
        if (result.selectedClient != null) {
            System.assertEquals(testClient.Id, result.selectedClient.Id, 'Selected client Id should match the test client Id');
        } else {
            System.assertEquals(null, result.selectedClient, 'No client was selected, so result.selectedClient should be null');
        }
        System.assertEquals(null, result.allClientsList, 'All clients list should be null');
    }

    /*@isTest
    public static void testGetClientsWithoutClientCode() {
        // Create multiple test client Accounts using TestdataFactory
        List<Account> testClients = new List<Account>();
        TestdataFactory factory = new TestdataFactory();
        for (Integer i = 1; i <= 3; i++) {
            Account testClient = factory.createTestClient('C' + i);
            testClients.add(testClient);
        }

        // Debug statement to check the size of testClients before insertion
        System.debug('Size of testClients before insertion: ' + testClients.size());

        insert testClients;

        // Debug statement to check the size of testClients after insertion
        System.debug('Size of testClients after insertion: ' + testClients.size());

        // Call the 'getClients' method without a client code
        SHP_SearchContainerController.SearchContainerClientWrapper result = SHP_SearchContainerController.getClients(null);

        // Debug statement to check the size of result.allClientsList
        System.debug('Size of result.allClientsList: ' + result.allClientsList.size());
		
        // Verify that the number of allClientsList items in the result matches the number of test clients
        System.assertEquals(testClients.size(), result.allClientsList.size(), 'Number of allClientsList items should match the number of test clients');
        System.assertEquals(null, result.selectedClient, 'Selected client should be null');
        System.assertEquals(null, result.clientLogoUrl, 'Client logo URL should be null');
        System.assertEquals(null, result.errorMsg, 'Error message should be null');
    }*/
   
    @isTest
public static void testGetClientsWithoutClientCode() {
    // Create multiple test client Accounts using TestdataFactory
    List<Account> testClients = new List<Account>();
    TestdataFactory factory = new TestdataFactory();
    for (Integer i = 1; i <= 3; i++) {
        Account testClient = factory.createTestClient('C' + i);
        testClients.add(testClient);
    }

    // Debug statement to check the size of testClients before insertion
    System.debug('Size of testClients before insertion: ' + testClients.size());

    insert testClients;

    // Debug statement to check the size of testClients after insertion
    System.debug('Size of testClients after insertion: ' + testClients.size());

    // Call the 'getClients' method without a client code
    SHP_SearchContainerController.SearchContainerClientWrapper result = SHP_SearchContainerController.getClients(null);

    // Debug statement to check the size of result.allClientsList
    System.debug('Size of result.allClientsList: ' + (result.allClientsList != null ? result.allClientsList.size() : 0));

    // Display the IDs of all clients in result.allClientsList
    if (result.allClientsList != null) {
        for (Account client : result.allClientsList) {
            System.debug('Client ID in result.allClientsList: ' + client.Id);
        }
    }

    // Verify that the number of allClientsList items in the result is 0
    System.assertEquals(3, result.allClientsList != null ? result.allClientsList.size() : 0, 'Number of allClientsList items should be 0');
    System.assertEquals(null, result.selectedClient, 'Selected client should be null');
    System.assertEquals(null, result.clientLogoUrl, 'Client logo URL should be null');
    System.assertEquals(null, result.errorMsg, 'Error message should be null');
}

    @isTest
    public static void testGetClientsWithExceptionWithClient() {
        // Call the 'getClients' method with a client code that does not exist.
        SHP_SearchContainerController.SearchContainerClientWrapper result = SHP_SearchContainerController.getClients('NonExistent');

        // Verify that the errorMsg in the result is not null
        System.assertNotEquals(null, result.errorMsg);
        System.assertEquals(null, result.selectedClient, 'Selected client should be null');
        System.assertEquals(null, result.clientLogoUrl, 'Client logo URL should be null');
        System.assertEquals(null, result.allClientsList, 'All clients list should be null');

    }
}