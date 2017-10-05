/**
 * This class is created to expose
 * various Einstein Services as web services
 * so that the same can be invoked from
 * JavaScript buttons.
 * 
 * @author      Shruti Sridharan
 * @since       10/08/2017
 * @revisions   N/A
 **/
global class EinsteinServices {
    /**
     * This method calls the Einstein Sentiment 
     * API class to find the Sentiment of a block 
     * of text.
     * @return  SentimentAnalysisResponse   Returns an instance of SentimentAnalysisResponse class
     * 
     * @param   text                        The text whose Sentiment has to be analysed
     */
    webservice static SentimentAnalysisResponse findSentiment( String text ) {
        EinsteinAPI api = new EinsteinAPI();
        
        SentimentAnalysisResponse resp = api.findSentiment( text );
        
        return resp;
    }
}