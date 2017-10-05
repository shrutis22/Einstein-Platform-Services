public without sharing class FindSentimentController {
    @RemoteAction
    public static SentimentAnalysisResponse findSentiment( String text ) {
        EinsteinAPI api = new EinsteinAPI();
        
        SentimentAnalysisResponse resp = api.findSentiment( text );
        
        return resp;
    }
}