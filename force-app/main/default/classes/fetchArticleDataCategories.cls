public without sharing  class fetchArticleDataCategories  {

    @AuraEnabled
    public static resultsWrapper getKnowledgeDataCategories(String recordId){
        Id tempKnowledgeId = [Select KnowledgeArticleId From Knowledge__kav where id=: recordId].KnowledgeArticleId;
        List<Knowledge__DataCategorySelection> dataCategories = [SELECT Id, ParentId, DataCategoryName,Parent.IsMasterLanguage,Parent.KnowledgeArticleId FROM Knowledge__DataCategorySelection WHERE Parent.KnowledgeArticleId =: tempKnowledgeId and Parent.PublishStatus ='online'];
        List<Knowledge__DataCategorySelection> dataCategoriesLabels = [SELECT Id, ParentId, toLabel(DataCategoryName) FROM Knowledge__DataCategorySelection WHERE Parent.KnowledgeArticleId =: tempKnowledgeId and Parent.PublishStatus ='online'];
        Map<String,String> dataCategoriesMap = new Map<String,String>();
        for(Knowledge__DataCategorySelection dc1 : dataCategories){
            for(Knowledge__DataCategorySelection dc2 : dataCategoriesLabels){
                if(dc1.Id == dc2.Id){
                    dataCategoriesMap.put(dc1.DataCategoryName,dc2.DataCategoryName);
                }
            }
        }
        resultsWrapper rw = new resultsWrapper();
        rw.dataCategoriesList = new List<dcWrapper>();
        for(Knowledge__DataCategorySelection kdcs : dataCategories){
            dcWrapper dcw = new dcWrapper();
            dcw.dcName = kdcs.DataCategoryName;
            dcw.dcLabel = dataCategoriesMap.get(kdcs.DataCategoryName);
            rw.dataCategoriesList.add(dcw);
        }
        System.debug(rw);
        return rw;

    }

    public class resultsWrapper{
        @AuraEnabled public List<dcWrapper> dataCategoriesList; 
    }
    public class dcWrapper{
        @AuraEnabled public String dcLabel;
        @AuraEnabled public String dcName;
    }
}