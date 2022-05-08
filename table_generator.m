%% PARKINSON DRAWINGS PRACTICE:
% Generation of a feature table from images

clc;
clear;
close all;

%% LOADING AND ORGANIZING SPIRAL DRAWINGS
imagefiles_spiral_healthy = [dir("./synth_spirals/training/healthy/*.png"); dir("./synth_spirals/training/healthy/*.jpeg")];
n_spiral_healthy = length(imagefiles_spiral_healthy);

img_spiral_healthy = cell(n_spiral_healthy, 1);
subject_names_healthy_spiral = string(zeros(n_spiral_healthy, 1));
for img = 1:n_spiral_healthy
    curr = imagefiles_spiral_healthy(img).name;
    curr_img = imread("./synth_spirals/training/healthy/" + string(curr));

    curr_img = im2double(rgb2gray(curr_img));
    img_spiral_healthy{img} = curr_img;
    subject_names_healthy_spiral(img) = erase(imagefiles_spiral_healthy(img).name, [".png", ".jpeg"]);
end

imagefiles_spiral_parkinson = [dir("./synth_spirals/training/parkinson/*.png"); ...
    dir("./synth_spirals/training/parkinson/*.jpeg")];
n_spiral_parkinson = length(imagefiles_spiral_parkinson);

img_spiral_parkinson = cell(n_spiral_parkinson, 1);
subject_names_parkinson_spiral = string(zeros(n_spiral_healthy, 1));
for img = 1:n_spiral_parkinson
    curr = imagefiles_spiral_parkinson(img).name;
    curr_img = imread("./synth_spirals/training/parkinson/" + string(curr));

    curr_img = im2double(rgb2gray(curr_img));
    img_spiral_parkinson{img} = curr_img;
    subject_names_parkinson_spiral(img) = erase(imagefiles_spiral_healthy(img).name, [".png", ".jpeg"]) + "_PD";
end

%% GENERATE THE DATAFRAME

varTypes_spiral = ["string", "double", "double", "double",...
     "double", "double", "double", "double", "double",...
     "double", "double", "double"];
varNames_spiral = ["Subject_spiral", "Mean_spiral", "Std_spiral", ...
    "mean_stroke_width", "var_stroke_width", "HFP", "FF", "N_pixels_spiral",...
    "N_pruned_pixels", "SH_m1", "SH_m3", "SH_m4"];

df = table('Size', [n_spiral_healthy+n_spiral_parkinson, length(varNames_spiral)], ...
    'VariableTypes', varTypes_spiral, 'VariableNames', varNames_spiral);

df.Subject_spiral = [subject_names_healthy_spiral; subject_names_parkinson_spiral];

img_all_spiral = [img_spiral_healthy; img_spiral_parkinson];
for img = 1:length(img_all_spiral)

    df.Mean_spiral(img) = mean(mean(cell2mat(img_all_spiral(img))));
    df.Std_spiral(img) = std(cell2mat(img_all_spiral(img)), 0, 'all');
    [df.mean_stroke_width(img), df.var_stroke_width(img)] =...
        measure_stroke_width(img_all_spiral{img});
    [df.HFP(img), df.FF(img), df.N_pruned_pixels(img), df.N_pixels_spiral(img)] = ...
        spiral_transform(img_all_spiral{img}, 1);

    df.SH_m1(img) = compute_shape_moments(img_all_spiral{img}, 1);
    df.SH_m3(img) = compute_shape_moments(img_all_spiral{img}, 3);
    df.SH_m4(img) = compute_shape_moments(img_all_spiral{img}, 4);
end

df.Label(n_spiral_healthy+1:n_spiral_healthy+n_spiral_parkinson) = ones(1, n_spiral_parkinson);