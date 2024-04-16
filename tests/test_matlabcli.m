% test the relevant parsing of matlab commands for cli
% 240410 - 

% what does our plugin have a problem with?
clear;
close all;
workspace;

A = magic(5);

disp("hello");

%% new section
fprintf("test a print statement with dot continuation %s",...
    "here!\n");

%% another 
fprintf("test integer format: %i\n",5); 
fprintf("\n");


