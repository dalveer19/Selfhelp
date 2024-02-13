global without sharing  class TopCategoriesBatchClientScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        TopCategoriesBatchClient1 myBatch = new TopCategoriesBatchClient1();
        // Start the batch job
        Database.executeBatch(myBatch);
    }
}