clear; clc; close all
%% Load data
imds = imageDatastore('orig_PD_drawings',...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

% Data split (70/30)
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.7,'randomized');

% show a sample
numTrainImages = numel(imdsTrain.Labels);
idx = randperm(numTrainImages,16);
figure
for i = 1:16
    subplot(4,4,i)
    I = readimage(imdsTrain,idx(i));
    imshow(I)
end
%% Load and condition net
net = alexnet;

inputSize = net.Layers(1).InputSize;

% replace final layers
layersTransfer = net.Layers(1:end-3);

numClasses = numel(categories(imdsTrain.Labels));

% speed up last layers' training
layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

% data augmentation with translation, rotation and reflection enabled,
% avoids overfitting. The augmenter automatically resizes the images to the
% required size.

rotationRange = [-90 90];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandRotation', rotationRange);

augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
    'DataAugmentation',imageAugmenter);

augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);

options = trainingOptions('sgdm', ...
    'MiniBatchSize', 15, ...
    'MaxEpochs',50, ...
    'InitialLearnRate',1e-4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',2, ...
    'Verbose',false, ...
    'Plots','training-progress');

%% Train the net
netTransfer = trainNetwork(augimdsTrain,layers,options);

%% Evaluate performance
[YPred,scores] = classify(netTransfer,augimdsValidation);
idx = randperm(numel(imdsValidation.Files),4);
figure
for i = 1:4
    subplot(2,2,i)
    I = readimage(imdsValidation,idx(i));
    imshow(I)
    label = YPred(idx(i));
    title(string(label));
end

YValidation = imdsValidation.Labels;
accuracy = mean(YPred == YValidation);

labP = YValidation == "pd"; labP = labP(11:end);
labN = YValidation == "nc"; labN = labN(1:10);
predP = YPred == "pd"; predP = predP(11:end);
predN = YPred == "nc"; predN = predN(1:10);

TP = sum(labP&predP);
TN = sum(labN&predN);

FP = sum(~(labP&predP));
FN = sum(~(predN&labN));

Sp = TN / (TN + FP);
Se = TP / (TP + FN);