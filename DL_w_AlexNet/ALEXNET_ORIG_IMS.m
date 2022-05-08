% clear; clc; close all
%% Load data
rng('default')

imdsTrain = imageDatastore('./orig_PD_drawings/train_orig', ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

imdsValidation = imageDatastore('./orig_PD_drawings/test_orig', ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

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
    'InitialLearnRate',5e-5, ...
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

ACC = (TN+TP)/(TP+TN+FP+FN);
scores = scores(:,2); % second column corresponds to PD probability
[X, Y, T, AUC] = perfcurve(YValidation == "pd", scores, 1);

figure; 
plot(xx,yy, 'LineWidth', 2, 'Color', 'b');
text(0.6, 0.5, ['Synth+Original image results', newline,...
    'AUC = ', num2str(au),...
    newline, 'Sp. = ', num2str(sp), ...
    newline,'Se. = ', num2str(se), ...
    newline,'Acc. =', num2str(acc)], 'Color', 'b')

hold on
plot(X,Y, 'LineWidth', 2, 'Color', 'r');
text(0.2, 0.5, ['Original results', newline,...
    'AUC = ', num2str(AUC),...
    newline, 'Sp. = ', num2str(Sp), ...
    newline,'Se. = ', num2str(Se), ...
    newline,'Acc. =', num2str(ACC)], 'Color', 'r')

title("Receiver Operating Curves for AlexNet")
xlabel('1-Specificity')
ylabel('Sensitivity')