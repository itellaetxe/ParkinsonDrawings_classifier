%% PARKINSON DRAWINGS PRACTICE:
% Generation of a feature table from images

clc;
clear;
close all;

%% LOADING AND ORGANIZING WAVE DRAWINGS
imagefiles_wave_healthy = dir("./data/wave/training/healthy/*.png");
n_wave_healthy = length(imagefiles_wave_healthy);

img_wave_healthy = cell(n_wave_healthy, 1);
subject_names_healthy_wave = string(zeros(n_wave_healthy, 1));
for img = 1:n_wave_healthy
    curr = imagefiles_wave_healthy(img).name;
    curr_img = imread("./data/wave/training/healthy/" + string(curr));

    curr_img = im2double(rgb2gray(curr_img));
    img_wave_healthy{img} = curr_img;
    subject_names_healthy_wave(img) = erase(imagefiles_wave_healthy(img).name, ".png");
end

imagefiles_wave_parkinson = dir("./data/wave/training/parkinson/*.png");
n_wave_parkinson = length(imagefiles_wave_parkinson);

img_wave_parkinson = cell(n_wave_parkinson, 1);
subject_names_parkinson_wave = string(zeros(n_wave_healthy, 1));
for img = 1:n_wave_parkinson
    curr = imagefiles_wave_parkinson(img).name;
    curr_img = imread("./data/wave/training/parkinson/" + string(curr));

    curr_img = im2double(rgb2gray(curr_img));
    img_wave_parkinson{img} = curr_img;
    subject_names_parkinson_wave(img) = erase(imagefiles_wave_healthy(img).name, ".png") + "p";
end

%% LOADING AND ORGANIZING SPIRAL DRAWINGS
imagefiles_spiral_healthy = dir("./data/spiral/training/healthy/*.png");
n_spiral_healthy = length(imagefiles_spiral_healthy);

img_spiral_healthy = cell(n_spiral_healthy, 1);
subject_names_healthy_spiral = string(zeros(n_spiral_healthy, 1));
for img = 1:n_wave_healthy
    curr = imagefiles_spiral_healthy(img).name;
    curr_img = imread("./data/spiral/training/healthy/" + string(curr));

    curr_img = im2double(rgb2gray(curr_img));
    img_spiral_healthy{img} = curr_img;
    subject_names_healthy_spiral(img) = erase(imagefiles_spiral_healthy(img).name, ".png");
end

imagefiles_spiral_parkinson = dir("./data/spiral/training/parkinson/*.png");
n_spiral_parkinson = length(imagefiles_spiral_parkinson);

img_spiral_parkinson = cell(n_spiral_parkinson, 1);
subject_names_parkinson_spiral = string(zeros(n_spiral_healthy, 1));
for img = 1:n_spiral_parkinson
    curr = imagefiles_spiral_parkinson(img).name;
    curr_img = imread("./data/spiral/training/parkinson/" + string(curr));

    curr_img = im2double(rgb2gray(curr_img));
    img_spiral_parkinson{img} = curr_img;
    subject_names_parkinson_spiral(img) = erase(imagefiles_spiral_healthy(img).name, ".png") + "p";
end

%% GENERATING THE TABLE

varTypes_wave = ["string", "double", "double", "double", "double"];
varNames_wave = ["Subject_wave", "Mean_wave", "Std_wave", "Num_px_path_wave", "Rang_eq_wave"];
varTypes_spiral = ["string", "double", "double", "double", "double"];
varNames_spiral = ["Subject_spiral", "Mean_spiral", "Std_spiral", "Num_px_path_spiral", "Rang_eq_spiral"];
df = table('Size', [n_wave_parkinson+n_wave_healthy, length([varNames_wave, varNames_spiral])], ...
    'VariableTypes', [varTypes_wave, varTypes_spiral], 'VariableNames', [varNames_wave, varNames_spiral]);

df.Subject_wave = [subject_names_healthy_wave; subject_names_parkinson_wave];
df.Subject_spiral = [subject_names_healthy_spiral; subject_names_parkinson_spiral];

img_all_wave = [img_wave_healthy; img_wave_parkinson];
img_all_spiral = [img_spiral_healthy; img_spiral_parkinson];
for img = 1:length(img_all_wave)
    df.Mean_wave(img) = mean(mean(cell2mat(img_all_wave(img))));
    df.Std_wave(img) = std(cell2mat(img_all_wave(img)), 0, 'all');
%     df.Num_px_path_wave(img) = 0; ...

    df.Mean_spiral(img) = mean(mean(cell2mat(img_all_spiral(img))));
    df.Std_spiral(img) = std(cell2mat(img_all_spiral(img)), 0, 'all');
%     df.Num_px_path_spiral(img) = 0; ...
end

df.Label(n_wave_healthy+1:n_wave_healthy+n_wave_parkinson) = ones(1, n_wave_parkinson);