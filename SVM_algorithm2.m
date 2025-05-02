%=== Data Set path and image library ===================================== 
datasetpathTrain='INSERT_PATH_TO_IMAGE_TRAINING_DATABASE';
datasetpathTest='INSERT_PATH_TO_IMAGE_TESTING_DATABASE';
imdsTrain = imageDatastore(datasetpathTrain, ...
            'IncludeSubfolders',true, ...
            'LabelSource','foldernames');
imdsTest = imageDatastore(datasetpathTest, ...
           'IncludeSubfolders',true, ...
           'LabelSource','foldernames');

%=== Bag of Features generation ===========================================
bag = bagOfFeatures(imdsTrain, 'StrongestFeatures', 0.7, 'GridStep', [32 32], 'BlockWidth', [64 96 128],'UseParallel', true);

%=== Set options and train the classifier =================================
opts = templateSVM('BoxConstraint',4,'KernelFunction','gaussian', 'KernelScale', 'auto', 'Solver', 'smo');
categoryClassifier = trainImageCategoryClassifier(imdsTrain,bag, 'LearnerOptions', opts, 'UseParallel', true);

%=== Test the classifier with tetsing data to check everything is fine =====
confMatrixTrain = evaluate(categoryClassifier, imdsTrain);

%=== Test the classifing with the test data set and measure accuracy ======
confMatrixTest = evaluate(categoryClassifier,imdsTest);

%=== Save results for further use =========================================
save('SVM_Results')