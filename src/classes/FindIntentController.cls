/**
 * This class is created to make a
 * playground to try out Intent APIs
 * and predict a block of text.
 * 
 * @author      Shruti Sridharan
 * @since       30/08/2017
 * @revisions   N/A
 **/
public class FindIntentController {
    /**
     * This method is created to upload
     * a CSV file from a downloadable link
     * to the server for creating a dataset
     * when the 'Create' button is clicked.
     **/
    @RemoteAction
    public static DatasetUploadResponse uploadDataset() {
        EinsteinAPI api = new EinsteinAPI();
        
        DatasetUploadResponse datasetUploadResp = api.uploadDataset();
        
        return datasetUploadResp;
    }
    
    /**
     * This method is created to upload
     * a CSV file from a downloadable link
     * which is uploaded by a User to the 
     * server for creating a dataset when
     * the 'Create' button is clicked.
     **/
    @RemoteAction
    public static DatasetUploadResponse uploadMyDataset() {
        EinsteinAPI api = new EinsteinAPI();
        
        DatasetUploadResponse datasetUploadResp = api.uploadMyDataset();
        
        return datasetUploadResp;
    }
    
    /**
     * This method is written to get the status
     * of the upload of the CSV file into their
     * server.
     * 
     * @param       datasetId       The Id of the dataset that was created after uploading the CSV file
     **/
    @RemoteAction
    public static DatasetDetailsResponse getDatasetDetails( String datasetId ) {
        EinsteinAPI api = new EinsteinAPI();
        
        DatasetDetailsResponse datasetDetailsResp = api.getDatasetDetails( datasetId );
        
        return datasetDetailsResp;
    }
    
    /**
     * This method is written to start 
     * training the AI when the 'Train'
     * button is clicked.
     * 
     * @param       datasetId       The Id of the dataset that was created after uploading the CSV file
     **/
    @RemoteAction
    public static TrainDatasetResponse trainDataset( String datasetId ) {
        EinsteinAPI api = new EinsteinAPI();
        
        TrainDatasetResponse trainDatasetResp = api.trainDataset( datasetId );
        
        return trainDatasetResp;
    }
    
    /**
     * This method is created to get
     * the status of the training process
     * 
     * @param       modelId         The Id of the model that was created
     **/
    @RemoteAction
    public static Object getDatasetTrainingStatus( String modelId ) {
        EinsteinAPI api = new EinsteinAPI();
        
        Object resp = api.getDatasetTrainingStatus( modelId );
        
        return resp;
    }
    
    /**
     * This method is written to identify
     * the intent in a given block of text.
     * 
     * @param       modelId         The Id of the model that was created
     * @param       textToPredict   The text that has to be predicted
     **/
    @RemoteAction
    public static PredictionResponse predictIntent( String modelId, String textToPredict ) {
        EinsteinAPI api = new EinsteinAPI();
        
        PredictionResponse predictionResp = api.predictIntent( modelId, textToPredict );
        
        return predictionResp;
    }
    
    /**
     * This method is created to save
     * the Model Id into 'Einstein_API_Settings__c'
     * Custom Settings.
     * 
     * @param       modelId     The Id of the model
     **/
    @RemoteAction
    public static void saveModelId( String modelId ) {
        Einstein_API_Settings__c settings = Einstein_API_Settings__c.getInstance( UserInfo.getOrganizationId() );
        
        settings.Intent_Model_Id__c = modelId;
        
        UPDATE settings;
    }
    
    @RemoteAction
    public static void saveDownloadUrl( String downloadUrl ) {
        Einstein_API_Settings__c settings = Einstein_API_Settings__c.getInstance( UserInfo.getOrganizationId() );
        
        settings.User_Uploaded_Intent_Dataset_CSV__c = downloadUrl;
        
        UPDATE settings;
    }
    
    public static String accessToken {
        get {
            Google_Settings__c settings = Google_Settings__c.getOrgDefaults();
            
            Auth.JWT jwt = new Auth.JWT();
            jwt.setAud( settings.Token_Endpoint__c );
            jwt.setIss( settings.Service_Account_Id__c );
            jwt.setAdditionalClaims( new Map<String, Object>{ 'scope' => settings.Scopes__c } );
    
            Auth.JWS jws = new Auth.JWS( jwt, 'GDriveForSalesforce' );
    
            Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange( settings.Token_Endpoint__c, jws );
    
            return bearer.getAccessToken();
        }
    }
}