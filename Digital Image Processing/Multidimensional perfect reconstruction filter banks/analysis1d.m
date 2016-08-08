function [ y0,y1 ] = analysis1d( h0,h1,x )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
y0 = downsample( cconv(x,h0),2 );
y1 = downsample( cconv(x,h1),2 );


end




