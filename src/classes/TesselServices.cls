@RestResource( urlMapping = '/tesselservices/*' )
global class TesselServices {
    public static final String MODEL_ID = 'INSERT MODEL ID HERE';
    
    @HttpPost
    global static String upload() {
        RestRequest req     = RestContext.request;
        RestResponse res    = Restcontext.response;
        
        Blob picture        = req.requestBody;
        
        ContentVersion conVersion   = new ContentVersion();
        conVersion.Title            = 'Content Version' + System.now().getTime();
        conVersion.PathOnClient     = 'file_' + Datetime.now().getTime() + '.jpg';
        conVersion.VersionData      = picture;
        conVersion.Origin           = 'H';
        INSERT conVersion;
        
        ContentDistribution cd              = new ContentDistribution();
        cd.Name                             = 'Content Dist ' + System.now().getTime();
        cd.ContentVersionId                 = conVersion.Id;
        cd.PreferencesAllowOriginalDownload = TRUE;
        cd.PreferencesAllowPDFDownload      = TRUE;
        cd.PreferencesAllowViewInBrowser    = TRUE;
        INSERT cd;
        
        List<ContentDistribution> conDist = new List<ContentDistribution>();
        conDist = [
            SELECT  ContentDownloadUrl
            FROM    ContentDistribution
            WHERE   Id = :cd.Id
        ];
        
        return conDist[0].ContentDownloadUrl;
    }    
    
    @HttpGet
    global static PredictionResponse authenticate() {        
        EinsteinAPI api = new EinsteinAPI();
        
        PredictionResponse resp = api.predictImage( MODEL_ID, EncodingUtil.urlDecode( RestContext.request.params.get( 'img' ), 'UTF-8' ) );
        
        return resp;
    }
}
