@isTest
public class SHP_ConstantUtilTest {

     static TestMethod void testGetTopCategories() {
        // Prepare test data
        String sObjectName = 'KnowledgeArticleVersion';
        String categoryName = 'Candidate';

        List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();

        DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
        pair1.setSobject(sObjectName);
        pair1.setDataCategoryGroupName(categoryName);
        pairs.add(pair1);
        List<Schema.DataCategory> subCats = new List<Schema.DataCategory>();

        List<Schema.DescribeDataCategoryGroupStructureResult>results = Schema.describeDataCategoryGroupStructures(pairs, false);
                  for(Schema.DescribeDataCategoryGroupStructureResult r : results){
                      Schema.DataCategory[] topCategories = r.getTopCategories();
                      for(Schema.DataCategory c : topCategories){
                         subCats = c.getChildCategories();
                      }
                  }    
        
        Test.startTest();
        // Call the method to test
        List<Schema.DataCategory> result = SHP_ConstantUtil.GetTopCategories(sObjectName, categoryName);
        Test.stopTest();

        // Perform assertions
        System.assertEquals(subCats.size(), result.size(), 'The results are fine');
    }
    
    @istest
    static void varForTestClassTest(){
        Test.startTest();
        Boolean b = SHP_ConstantUtil.varForTestClass();
        Test.stopTest();
        System.assertEquals(false,b);
    } 
}