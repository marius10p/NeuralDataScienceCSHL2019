%% 0 Init
%Obligatory (blank slate)
clear all
close all
clc

%Facultative (Biological sysem don't usually start as a blank slate, there are priors, set phylogenetically
%the idea is that all parameters that guide how the code we write is modified,
%should go here). Stuff like: Which baseline to use, how much pre-stimulus
%time, choices about the analysis you make that changes the entire
%analysis. Important: Put *all* of them here, at the beginning of the
%program, so you can modify them all here. You don't miss any hidden
%variable.
rng('Shuffle')
fRate = 1/10; %Rate at which each grating was presented
unit = 12; %This is a nice unit
binWidth = 10/1000; %Some reasonable bin width
set(0,'DefaultFigureWindowStyle','docked'); %Makes figures docked. Better for teaching
offSet = 50/1000; %Average neural response latency, determined by visual inspection
numOri = 8; %Unique number of orientations used. Domain knowledge

%Guiding idea: Everything that modifies how the script works is in one
%place, at the very beginning. 