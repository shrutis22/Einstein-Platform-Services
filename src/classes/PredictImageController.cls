/**
 * This class is created to make a
 * playground to try out Vision APIs
 * and predict an image.
 * 
 * @author      Shruti Sridharan
 * @since       30/08/2017
 * @revisions   N/A
 **/
public class PredictImageController {
    public List<Trained_Models__c> trainedModels     { get; set; }
    
    public class Response {
        public Boolean status;
        public Id dsId;
    }
    
    public PredictImageController() {
        trainedModels = new List<Trained_Models__c>();
        
        trainedModels = [
            SELECT  Name
                    ,Model_Id__c
                    ,Type__c
            FROM    Trained_Models__c
            WHERE   Type__c = 'Vision'
        ];
    }
    
    /**
     * This method is created to upload
     * a zip file from a downloadable link
     * to the server for creating a dataset
     * when the 'Create' button is clicked.
     **/
    @RemoteAction
    public static DatasetUploadResponse uploadMyDataset() {
        EinsteinAPI api = new EinsteinAPI();
        
        DatasetUploadResponse datasetUploadResp = api.visionUploadDataset();
        
        return datasetUploadResp;
    }
    
    /**
     * This method is written to get the status
     * of the upload of the CSV file into their
     * server.
     * 
     * @param       datasetId       The Id of the dataset that was created after uploading the Image zip file
     **/
    @RemoteAction
    public static DatasetDetailsResponse getDatasetDetails( String datasetId ) {
        EinsteinAPI api = new EinsteinAPI();
        
        DatasetDetailsResponse datasetDetailsResp = api.getVisionDatasetDetails( datasetId );
        
        return datasetDetailsResp;
    }
    
    /**
     * This method is written to start 
     * training the AI when the 'Train'
     * button is clicked.
     * 
     * @param       datasetId       The Id of the dataset that was created after uploading the zip file
     **/
    @RemoteAction
    public static TrainDatasetResponse trainDataset( String datasetId ) {
        EinsteinAPI api = new EinsteinAPI();
        
        TrainDatasetResponse trainDatasetResp = api.trainVisionDataset( datasetId );
        
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
        
        Object resp = api.getVisionDatasetTrainingStatus( modelId );
        
        return resp;
    }
    
    @RemoteAction
    public static PredictionResponse predictImage( String modelId ) {
        EinsteinAPI api = new EinsteinAPI();
        
        PredictionResponse predictionResp = api.predictImage( modelId );
        
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
        
        settings.Vision_Model_Id__c = modelId;
        
        UPDATE settings;
    }
    
    /**
     * This method is created to save the
     * download url of the image uploded 
     * into the google drive.
     * 
     * @param       downloadUrl     The url from which we can download the zip file containing images
     **/
    @RemoteAction
    public static void saveDownloadUrl( String downloadUrl ) {
        Einstein_API_Settings__c settings = Einstein_API_Settings__c.getInstance( UserInfo.getOrganizationId() );

        settings.User_Uploaded_Vision_Dataset_Image__c = downloadUrl;
        
        UPDATE settings;
    }
    
    /**
     * This method is created to save the
     * download url of the image uploded 
     * for predicting,into the google drive.
     * 
     * @param       downloadUrl     The url from which we can download the image file
     **/
    @RemoteAction
    public static void saveUserUplodedImgDownloadUrl( String downloadUrl ) {
        Einstein_API_Settings__c settings = Einstein_API_Settings__c.getInstance( UserInfo.getOrganizationId() );
        
        settings.Vision_User_Predict_Image__c = downloadUrl;

        UPDATE settings;
    }
    
    @RemoteAction
    public static Response uploadVisionDataset() {
        Vision_Dataset__c visionDS = new Vision_Dataset__c();
        
        visionDS.Name = 'Vision DS - ' + System.now().getTime();
        
        try {
            INSERT visionDS;
            
            Response resp   = new Response();
            resp.status     = TRUE;
            resp.dsId       = visionDS.Id;
            
            return resp;
        }
        catch( Exception ex ) {
            Response resp   = new Response();
            resp.status     = FALSE;
            
            return resp;
        }
    }
    
    @RemoteAction
    public static Response uploadVisionSample() {
        Vision_Sample__c visionSample = new Vision_Sample__c();
        
        visionSample.Name = 'Vision Sample - ' + System.now().getTime();
        
        try {
            INSERT visionSample;
            
            Response resp   = new Response();
            resp.status     = TRUE;
            resp.dsId       = visionSample.Id;
            
            return resp;
        }
        catch( Exception ex ) {
            Response resp   = new Response();
            resp.status     = FALSE;
            
            return resp;
        }
    }
    
    @RemoteAction
    public static String getDownloadUrl( Id einsteinDSId ) {
        List<ContentDocumentLink> conDocLink = new List<ContentDocumentLink>();
        
        conDocLink = [
            SELECT  ContentDocumentId
            FROM    ContentDocumentLink
            WHERE   LinkedEntityId = :einsteinDSId
            ORDER BY SystemModStamp DESC
        ];
        
        if( !conDocLink.isEmpty() ) {
            List<ContentVersion> conVersion = new List<ContentVersion>();
            conVersion = [
                SELECT  Id
                FROM    ContentVersion
                WHERE   ContentDocumentId = :conDocLink[0].ContentDocumentId
            ];
            
            if( !conVersion.isEmpty() ) {
                ContentDistribution cd              = new ContentDistribution();
                cd.Name                             = 'Content Dist ' + System.now().getTime();
                cd.ContentVersionId                 = conVersion[0].Id;
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
            
            return NULL;
        }
        
        return NULL;
    }
}