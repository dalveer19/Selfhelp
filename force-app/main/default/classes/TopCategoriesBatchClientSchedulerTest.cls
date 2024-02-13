@isTest
public class TopCategoriesBatchClientSchedulerTest {

    @isTest
    static void schedulerTest() {
        Test.startTest();
        String jobId = System.schedule('Test Top Categories Batch Client Scheduler', '0 10 * * * ?', new TopCategoriesBatchClientScheduler());
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Job ID should not be null');

       // CronTrigger cronTrigger = [SELECT Id, State FROM CronTrigger WHERE Id = :jobId LIMIT 1];
       // System.assertEquals('WAITING', cronTrigger.State, 'Job should be in WAITING state');

    }
}