var PredictImage = {
    variables : {
        datasetId   	: null,
        modelId     	: null,
        picker      	: null,
        config      	: null,
        uploadLocation 	: -1
    },
    helpers : {
        showProgress : function( statusMsg, friendlyMsg ) {
            $( "#mdlHeader" ).html( statusMsg );
            
            $( "#statusMsg" ).html( friendlyMsg );
            
            $( "#mdlSpinner" ).show();
            
            $( "#btnClose" ).prop( "disabled", true );
            
            $( "#mdlStatus" ).show();
            
            $( "#mdlBackDrop" ).show();
        },
        showCompletion : function( statusMsg, friendlyMsg ) {
            $( "#mdlHeader" ).html( statusMsg );
            
            $( "#statusMsg" ).html( friendlyMsg );
            
            $( "#mdlSpinner" ).hide();
            
            $( "#btnClose" ).prop( "disabled", false );
            
            $( "#mdlStatus" ).show();
            
            $( "#mdlBackDrop" ).show();
        },
        enableButton : function( btnId, isEnabled ) {
            if( isEnabled ) {
                $( "#" + btnId ).prop( "disabled", false );
            }
            else {
                $( "#" + btnId ).prop( "disabled", true );
            }
        },
        showUploadContentModal : function( url ) {
            $( "#mdlVisionDatasetUploader" ).show();
            
            $( "#iframeDSUploader" ).attr( "src", url );
        },
        hideUploadModal : function( enableButtons ) {
            if( enableButtons ) {
                if( PredictImage.variables.uploadLocation === 1 ) {
                    PredictImage.helpers.enableButton( "btnUploadMyDS", true );
                }
                else if( PredictImage.variables.uploadLocation === 2 ) {
                    PredictImage.helpers.enableButton( "btnPredictExistModel", true );
                }
                else if( PredictImage.variables.uploadLocation === 3 ) {
                    PredictImage.helpers.enableButton( "btnPredictImg", true );
                }
            }
            
            $( "#iframeDSUploader" ).attr( "src", null );
            
            $( "#mdlVisionDatasetUploader" ).hide();
        }
    },
    actions : {
        uploadMyDataset : function() {
            PredictImageController.uploadMyDataset(
                function( result, event ) {
                    PredictImage.variables.datasetId = result.id;
                    
                    PredictImage.helpers.showProgress( result.statusMsg, "The Image is being uploaded to create the Dataset. Please wait..." );
                    
                    PredictImage.actions.getDatasetDetails();
                }
            );
        },
        getDatasetDetails : function() {
            window.setTimeout( 
                function() {
                    PredictImageController.getDatasetDetails(
                        PredictImage.variables.datasetId,
                        function( result, event ) {
                            if( result.statusMsg !== "SUCCEEDED" ) {
                                PredictImage.actions.getDatasetDetails();
                                
                                PredictImage.helpers.showProgress( result.statusMsg, "The Dataset is being uploaded. Please wait..." );
                            }
                            else {
                                PredictImage.helpers.showCompletion( result.statusMsg, "The Dataset has been created successfully. Now please hit the Start Training button." );
                                
                                PredictImage.helpers.enableButton( "btnTrainDS", true );
                            }
                        }
                    );
                },
                1000
            );
        },
        trainDataset : function() {
            PredictImageController.trainDataset(
                PredictImage.variables.datasetId,
                function( result, event ) {
                    PredictImage.variables.modelId = result.modelId;
                    
                    PredictImageController.saveModelId(
                        PredictImage.variables.modelId,
                        function( result, event ) { }
                    );
                    
                    PredictImage.helpers.showProgress( result.status, "A Model has been created from the Dataset. The Training process will start shortly." );
                    
                    PredictImage.helpers.enableButton( "btnClose", false );
                    
                    PredictImage.actions.getDatasetTrainingStatus();
                }
            );
        },
        getDatasetTrainingStatus : function() {
            window.setTimeout( 
                function() {
                    PredictImageController.getDatasetTrainingStatus(
                        PredictImage.variables.modelId,
                        function( result, event ) {
                            if( result.status !== "SUCCEEDED" ) {
                                PredictImage.actions.getDatasetTrainingStatus();
                                
                                PredictImage.helpers.showProgress( result.status, "The Training process has started. This might take few minutes to complete. So you have enough time to grab some caffeine." );
                            }
                            else {
                                PredictImage.helpers.showCompletion( result.status, "The Training process has been completed successfully. You can now try out the Prediction." );
                                
                                PredictImage.helpers.enableButton( "btnPredictImg", true );
                                
                                PredictImage.helpers.enableButton( "btnSaveModel", true );
                            }
                        }
                    );
                },
                1000
            );
        },
        predictImage : function() {
            PredictImageController.predictImage(
                PredictImage.variables.modelId,
                function( result, event ) {
                    var largest = 0;
                    var position = 0;
                    for( var i = 0; i < result.probabilities.length; i++ ) {
                        if( largest <= result.probabilities[i].probability ) {
                            largest = result.probabilities[i].probability;
                            position = i;
                        }
                    }
                    
                    PredictImage.helpers.showCompletion( "PREDICTION RESULTS", "Einstein predicted the entity in the image as - <strong>" + result.probabilities[position].label + "</strong>." );
                    
                    if( PredictImage.variables.uploadLocation === 1 ) {
	                    PredictImage.helpers.enableButton( "btnUploadMyDS", true );
                    }
                    else if( PredictImage.variables.uploadLocation === 2 ) {
                        PredictImage.helpers.enableButton( "btnPredictExistModel", true );
                    }
                    else if( PredictImage.variables.uploadLocation === 3 ) {
                        PredictImage.helpers.enableButton( "btnPredictImg", true );
                    }
                }
            );
        },
        closeModal : function() {
            $( "#mdlStatus" ).hide();
            $( "#mdlBackDrop" ).hide();
        },
        getExisitingModels : function() {
            PredictImageController.getExisitingModels(
                function( result, event ) {
                    
                }
            );
        },
        uploadVisionDataset : function() {
            PredictImageController.uploadVisionDataset(
                function( result, event ) {
                    if( result.status ) {
                        var url =  PredictImage.variables.config.visionUploaderLink + "?dsid=" + result.data;
                        
                        PredictImage.helpers.showUploadContentModal( url );
                        
                        PredictImage.actions.getDownloadUrl( result.data );
                    }
                }
            );
        },
        uploadVisionSample : function() {
            PredictImageController.uploadVisionSample(
                function( result, event ) {
                    if( result.status ) {
                        var url =  PredictImage.variables.config.visionUploaderLink + "?dsid=" + result.data;
                        
                        PredictImage.helpers.showUploadContentModal( url );
                        
                        PredictImage.actions.getDownloadUrl( result.data );
                    }
                }
            );
        },
        getDownloadUrl : function( dsId ) {
            window.setTimeout(
                function() {
                    PredictImageController.getDownloadUrl( 
                        dsId,
                        function( result, event ) {
                            if( result === null ) {
                                PredictImage.actions.getDownloadUrl( dsId );
                            }
                            else {
                                if( PredictImage.variables.uploadLocation === 1 ) {
                                    PredictImageController.saveDownloadUrl(
                                        result,
                                        function( result, event ) {
                                            PredictImage.helpers.hideUploadModal( false );
                                            
                                            PredictImage.actions.uploadMyDataset();
                                        }
                                    );
                                }
                                else if( PredictImage.variables.uploadLocation > 1 ) {
                                    PredictImageController.saveUserUplodedImgDownloadUrl(
                                        result,
                                        function( result, event ) {
                                            PredictImage.helpers.hideUploadModal( false );
                                            
                                            PredictImage.actions.predictImage();
                                        }
                                    );
                                }
                            }
                        },
                        {
                            escape : false
                        }
                    );
                }
                ,1000
            );
        },
        loadSettings : function() {
            var userEmail = prompt( "Please specify the email address that you used for signing up Einstein Platform Services:" );
            
            if( userEmail !== null ) {
                PredictImageController.loadSettings(
                    userEmail,
                    function( result, event ) {
                        alert( result.data );
                        
                        if( result.status ) {
                            location.reload();
                        }
                    }
                );
            }
            else {
                alert( "Sorry! The settings can be created only after you specify a valid Email Id." );
            }
        },
        saveTrainedModel : function() {
            var modelName = prompt( "Specify a Name for your Model(eg: Mountains vs Beaches):" );
            
            if( modelName !== null ) {
                PredictImageController.saveTrainedModel(
                    modelName,
                    function( result, event ) {
                        if( !result.status ) {
                            alert( result.data );
                        }
                        else {
                            var $option = $( "<option/>" ).attr( "value", PredictImage.variables.modelId ).html( modelName );
                            
                            $( "#slctModel" ).append( $option );
                        }
                    }
                );
            }
        },
        handleExistingModelChange : function() {
            if( $( "#slctModel" ).val() !== "0" ) {
                PredictImage.helpers.enableButton( "btnPredictExistModel", true );
            }
            else {
                PredictImage.helpers.enableButton( "btnPredictExistModel", false );
            }
        }
    },
    eventHandlers : {
        uploadMyDataset : function() {
            PredictImage.actions.uploadMyDataset();
        },
        getDatasetDetails : function() {
            PredictImage.actions.getDatasetDetails();
        },
        trainDataset : function() {
            PredictImage.actions.trainDataset();
        },
        getDatasetTrainingStatus : function() {
            PredictImage.actions.getDatasetTrainingStatus();
        },
        closeModal : function() {
            PredictImage.actions.closeModal();
        },
        getExisitingModels : function() {
            PredictImage.actions.getExisitingModels();
        },
        uploadVisionDataset : function() {
            PredictImage.actions.uploadVisionDataset();
        },
        uploadVisionSample : function() {
            PredictImage.actions.uploadVisionSample();
        },
        loadSettings : function() {
            PredictImage.actions.loadSettings();
        },
        saveTrainedModel : function() {
            PredictImage.actions.saveTrainedModel();
        },
        handleExistingModelChange : function() {
            PredictImage.actions.handleExistingModelChange();
        }
    },
    init : function( config ) {
        PredictImage.variables.config = config;
        
         $( "#btnUploadMyDS" ).click(
            function() {
                PredictImage.variables.uploadLocation = 1;
                
                PredictImage.helpers.enableButton( "btnUploadMyDS", false );
                
                PredictImage.eventHandlers.uploadVisionDataset();
            }
        );
        
        $( "#btnTrainDS" ).click(
            function() {
                PredictImage.helpers.enableButton( "btnTrainDS", false );
                
                PredictImage.eventHandlers.trainDataset();
            }
        );
        
        $( "#btnPredictExistModel" ).click(
            function() {
                PredictImage.variables.modelId = $( "#slctModel" ).val();
            
                PredictImage.variables.uploadLocation = 2;
                
                PredictImage.helpers.enableButton( "btnPredictExistModel", false );
                
                PredictImage.eventHandlers.uploadVisionSample();
            }
        );
        
        $( "#btnPredictImg" ).click(
            function() {
                PredictImage.variables.uploadLocation = 3;
                
                PredictImage.helpers.enableButton( "btnPredictImg", false );
                
                PredictImage.eventHandlers.uploadVisionSample();
            }
        );
        
        $( "#btnClose" ).click(
            function() {
                PredictImage.eventHandlers.closeModal();
            }
        );
        
        $( "#btnVisionDSUploderClose" ).click(
            function() {
                PredictImage.helpers.hideUploadModal( true );
            }
        );
        
        $( "#btnLoadSettings" ).click(
            function() {
                PredictImage.eventHandlers.loadSettings();
            }
        );
        
        $( "#btnSaveModel" ).click(
            function() {
                PredictImage.eventHandlers.saveTrainedModel();
            }
        );
        
        $( "#slctModel" ).on(
            "change",
            function() {
                PredictImage.eventHandlers.handleExistingModelChange();
            }
        );
    }
};