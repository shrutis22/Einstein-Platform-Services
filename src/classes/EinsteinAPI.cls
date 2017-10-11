/**
 * This class is created to make requests to
 * various Einstein Endpoints.
 * 
 * @author      Shruti Sridharan
 * @since       10/08/2017
 * @revisions   N/A
 **/
public class EinsteinAPI {
    ////////////////////////
    //Einstein API Config //
    ////////////////////////
    public Einstein_API_Settings__c settings        {
        get {
            return Einstein_API_Settings__c.getInstance( UserInfo.getOrganizationId() );
        }
    } 
    public String tokenEndpoint                     {
        get {
            return settings.Token_Endpoint__c;
        }
    }
    public Decimal tokenExpirationSeconds           {
        get {
            return settings.Token_Expiration_Seconds__c;
        }
    }
    public String registeredEmail                   {
        get {
            return settings.Registered_Email__c;
        }
    }
    
    
    ////////////////////////////////
    // Einstein Vision API Config //
    ////////////////////////////////
    public String visionUploadDatasetEP             {
        get {
            return settings.Vision_Upload_Dataset_Endpoint__c;
        }
    }
    public String visionMyDatasetImage              {
        get {
            return settings.User_Uploaded_Vision_Dataset_Image__c;
        }
    }
    public String visionDatasetDetailsEP            {
        get {
            return settings.Vision_Dataset_Details_Endpoint__c;
        }
    }
    public String visionTrainDatasetEP              {
        get {
            return settings.Vision_Train_Dataset_Endpoint__c;
        }
    }
    public String visionDatasetTrainingStatusEP     {
        get {
            return settings.Vision_Dataset_Training_Status_Endpoint__c;
        }
    }
    public String visionUserPredictImage            {
        get {
            return settings.Vision_User_Predict_Image__c;
        }
    }
    public String predictVisionEndpoint             {
        get {
            return settings.Predict_Vision_Endpoint__c;
        }
    }
    
    /////////////////
    //Auth Methods //
    /////////////////
    /**
     * This method is created to make a call
     * to the Token Endpoint and get the token
     * which will help us to make request to
     * other Endpoints of Einstein Services.
     * 
     * @return  String  Returns the access token of the Org
     */
    public String getAccessToken() {        
        Document base64Content = [
            SELECT  Body
            FROM    Document
            WHERE   DeveloperName = 'einstein_platform_pem'
            LIMIT   1
        ];
        
        String keyContents  = base64Content.Body.tostring();
        keyContents         = keyContents.replace( '-----BEGIN RSA PRIVATE KEY-----', '' );
        keyContents         = keyContents.replace( '-----END RSA PRIVATE KEY-----', '' );
        keyContents         = keyContents.replace( '\n', '' );

        JWT jwt             = new JWT( 'RS256' );
        
        jwt.pkcs8           = keyContents; 
        jwt.iss             = 'developer.force.com';
        jwt.sub             = registeredEmail;
        jwt.aud             = tokenEndpoint;
        jwt.exp             = String.valueOf( tokenExpirationSeconds );
        String access_token = JWTBearerFlow.getAccessToken( tokenEndpoint, jwt );
        return access_token;
    }
    
    /**
     * This method is created to build
     * Http Requests.
     * 
     * @param   method          The method of the Http Call
     * @param   endpoint        The endpoint to which the Http Call has to be made
     * 
     * @return  HttpRequest     Instance of the HttpRequest class
     **/
    private HttpRequest buildRequest( String method, String endpoint ) {
        HttpRequest httpReq = new HttpRequest();
        
        httpReq.setMethod( method );
        httpReq.setEndpoint( endpoint );
        
        httpReq.setHeader( 'Authorization', 'Bearer ' + getAccessToken() );
        httpReq.setHeader( 'Cache-Control', 'no-cache' );
        httpReq.setHeader( 'Content-Type', HttpFormBuilder.GetContentType() );
        
        httpReq.setTimeout( 120000 );
        
        return httpReq;
    }
    
    ////////////////////////////////
    //Einstein Vision API Methods //
    ////////////////////////////////
    /**
     * This method is created to make a Http
     * POST Call to the Einstein Vision APIs to
     * upload the zip file into their server.
     * 
     * @return      DatasetUploadResponse      Status of the upload process
     **/
    public DatasetUploadResponse visionUploadDataset() {
        String endpoint = visionUploadDatasetEP;
        
        HttpRequest httpReq = buildRequest( 'POST', endpoint );
        
        System.debug( visionMyDatasetImage );
        
        String mutipartFormData = '';
        mutipartFormData += HttpFormBuilder.WriteBoundary();
        mutipartFormData += HttpFormBuilder.WriteBodyParameter( 'path', visionMyDatasetImage );
        mutipartFormData += HttpFormBuilder.WriteBoundary();
        mutipartFormData += HttpFormBuilder.WriteBodyParameter( 'type', 'image' );
        mutipartFormData += HttpFormBuilder.WriteBoundary( NULL );
        
        Blob formBlob = EncodingUtil.base64Decode( mutipartFormData );
        
        httpReq.setBodyAsBlob( formBlob );

        Http http = new Http();
        
        HTTPResponse httpRes = http.send( httpReq );
        
        DatasetUploadResponse resp = new DatasetUploadResponse();
        
        resp = ( DatasetUploadResponse ) JSON.deserialize( httpRes.getBody(), DatasetUploadResponse.class );
        
        return resp;
    }
    
    /**
     * This method is created to make a 
     * GET call and get the status
     * of the dataset upload process.
     * 
     * @param       datasetId                   The Id of the Dataset that was created
     * 
     * @return      DatasetDetailsResponse      Status of the upload process
     **/
    public DatasetDetailsResponse getVisionDatasetDetails( String datasetId ) {
        String endpoint = visionDatasetDetailsEP.replace( '#DSID#', datasetId );
        
        HttpRequest httpReq = buildRequest( 'GET', endpoint );
        
        Http http = new Http();
        
        HTTPResponse httpRes = http.send( httpReq );
        
        DatasetDetailsResponse resp = new DatasetDetailsResponse();
        
        resp = ( DatasetDetailsResponse ) JSON.deserialize( httpRes.getBody(), DatasetDetailsResponse.class );
        
        return resp;
    }
    
    /**
     * This method is created to make a POST
     * Http call to create a model and start
     * training the AI.
     * 
     * @param       datasetId               The Id of te Dataset that was created.
     * 
     * @return      TrainDatasetResponse    Status of the training process
     **/
    public TrainDatasetResponse trainVisionDataset( String datasetId ) {
        String endpoint = visionTrainDatasetEP;
        
        HttpRequest httpReq = buildRequest( 'POST', endpoint );
        
        String mutipartFormData = '';
        mutipartFormData += HttpFormBuilder.WriteBoundary();
        mutipartFormData += HttpFormBuilder.WriteBodyParameter( 'name', 'Predict Image Model - ' + DateTime.now().getTime() );
        mutipartFormData += HttpFormBuilder.WriteBoundary();
        mutipartFormData += HttpFormBuilder.WriteBodyParameter( 'datasetId', String.valueOf( datasetId ) );
        mutipartFormData += HttpFormBuilder.WriteBoundary( NULL );
        
        Blob formBlob = EncodingUtil.base64Decode( mutipartFormData );
        
        httpReq.setBodyAsBlob( formBlob );

        Http http = new Http();
        
        HTTPResponse httpRes = http.send( httpReq );
        
        TrainDatasetResponse resp = new TrainDatasetResponse();
        
        resp = ( TrainDatasetResponse ) JSON.deserialize( httpRes.getBody(), TrainDatasetResponse.class );
        
        return resp;
    }
    
    /**
     * This method is created to make a GET
     * call to get the training status of 
     * the Dataset.
     * 
     * @param       modelId     Id of the model that was created
     * 
     * @return      Object      Status of the training process
     **/
    public Object getVisionDatasetTrainingStatus( String modelId ) {
        String endpoint = visionDatasetTrainingStatusEP.replace( '#MODELID#', modelId );
        
        HttpRequest httpReq = buildRequest( 'GET', endpoint );
        
        Http http = new Http();
        
        HTTPResponse httpRes = http.send( httpReq );
        
        VisionTrainingStatusResponse respTrainingStatus     = new VisionTrainingStatusResponse();
        TrainDatasetResponse respTrainDataset               = new TrainDatasetResponse();
        
        try {
            respTrainingStatus = ( VisionTrainingStatusResponse ) JSON.deserialize( httpRes.getBody(), VisionTrainingStatusResponse.class );

            return respTrainingStatus;
        }
        catch( Exception ex ) {
            respTrainDataset = ( TrainDatasetResponse ) JSON.deserialize( httpRes.getBody(), TrainDatasetResponse.class );

            return respTrainDataset;
        }
    }
    
    /**
     * This method is created to make a 
     * POST call to predict the uploaded
     * Image and identify the Label.
     * 
     * @param       modelId             The Id of the model that was created
     * 
     * @return      PredictionResponse  Image analysed from the given block of text
     **/
    public PredictionResponse predictImage( String modelId ) {
        String endpoint = predictVisionEndpoint;
        
        HttpRequest httpReq = buildRequest( 'POST', endpoint );
        
        String mutipartFormData = '';
        mutipartFormData += HttpFormBuilder.WriteBoundary();
        mutipartFormData += HttpFormBuilder.WriteBodyParameter( 'modelId', modelId );
        mutipartFormData += HttpFormBuilder.WriteBoundary();
        mutipartFormData += HttpFormBuilder.WriteBodyParameter( 'sampleLocation', visionUserPredictImage );
        mutipartFormData += HttpFormBuilder.WriteBoundary( NULL );
        
        Blob formBlob = EncodingUtil.base64Decode( mutipartFormData );
        
        httpReq.setBodyAsBlob( formBlob );

        Http http = new Http();
        
        HTTPResponse httpRes = http.send( httpReq );
        
        PredictionResponse resp = new PredictionResponse();
        
        resp = ( PredictionResponse ) JSON.deserialize( httpRes.getBody(), PredictionResponse.class );
        
        return resp;
    }
    
    public PredictionResponse predictImage( String modelId, String imgUrl ) {
        String endpoint = predictVisionEndpoint;
        
        HttpRequest httpReq = buildRequest( 'POST', endpoint );
        
        String mutipartFormData = '';
        mutipartFormData += HttpFormBuilder.WriteBoundary();
        mutipartFormData += HttpFormBuilder.WriteBodyParameter( 'modelId', modelId );
        mutipartFormData += HttpFormBuilder.WriteBoundary();
        mutipartFormData += HttpFormBuilder.WriteBodyParameter( 'sampleLocation', imgUrl );
        mutipartFormData += HttpFormBuilder.WriteBoundary( NULL );
        
        Blob formBlob = EncodingUtil.base64Decode( mutipartFormData );
        
        httpReq.setBodyAsBlob( formBlob );

        Http http = new Http();
        
        HTTPResponse httpRes = http.send( httpReq );
        
        PredictionResponse resp = new PredictionResponse();
        
        resp = ( PredictionResponse ) JSON.deserialize( httpRes.getBody(), PredictionResponse.class );
        
        return resp;
    }
}