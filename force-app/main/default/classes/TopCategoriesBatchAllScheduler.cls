global without sharing  class TopCategoriesBatchAllScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        TopCategoriesBatchAll myBatch = new TopCategoriesBatchAll();
        // Start the batch job
        Database.executeBatch(myBatch);
        System.debug('Job is Running');
    }
}