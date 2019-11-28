%% Initial code environment.
clear;clc;dbstop if error
feasible_solutions = load('feasible_solutions.mat');
feasible_solutions = feasible_solutions.partion;
table_huff_ac_default = load('table_huff_ac_default.mat');
table_huff_ac_default = table_huff_ac_default.table_huff_ac;
addpath(genpath(pwd));
payload = 10000;
rng(0,'twister');
secret = round(rand(1,payload)*1);
num_slt_pks = 10;
%% Set the parameters.
img_name = 'Boat_70.jpg';
stego_name = 'stego.jpg';
%% Test.
[fi,run_time_embed] = embed(img_name, secret, feasible_solutions, num_slt_pks);
[secret_extracted, run_time_rst] = extract(stego_name, payload, table_huff_ac_default);
cover = imread(img_name);
stego = imread(stego_name);
is_lossless = isequal(cover, stego);
if is_lossless
    fprintf('The visual quality of stego image is lossless!\n');
end
is_extracted = isequal(secret,secret_extracted);
if is_extracted
    fprintf('The secret messages are extracted correctly!\n');
end

