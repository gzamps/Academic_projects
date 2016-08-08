function [ xhat ] = synthesis1d( g0,g1,y0,y1 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


y0_up=upsample(y0,2);
y1_up=upsample(y1,2);




y0s =  cconv(y0_up,g0);
y1s =  cconv(y1_up,g1);



xhat = y0s + y1s;



end
