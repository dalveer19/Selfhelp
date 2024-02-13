@isTest
public class TopCategoriesBatchAllSchedulerTest {

    @isTest
    static void testScheduler() {
        Test.startTest();
        String jobId = System.schedule('Test Top Categories Batch All Scheduler', '0 10 * * * ?', new TopCategoriesBatchAllScheduler());
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Job ID should not be null');

    }
}