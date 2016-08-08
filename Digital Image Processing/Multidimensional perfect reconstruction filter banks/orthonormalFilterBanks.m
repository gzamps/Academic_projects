function [ h0,h1,g0,g1 ] = orthonormalFilterBanks( h )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


 h0=h;
 for i=1:20
     h1(i)=((-1)^i)*h0(i);
     g1(i)=((-1)^(i+1))*h0(i);
     g0(i)=((-1)^i)*h1(i);
end
