function [ xhat ] = synthesis2d( g0,g1,y00,y01,y10,y11 )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
        
      % arxizei h synthesi


[s1,s2]=size(y00);
for i=1:s1;
    
    V00_line=y00(i,1:end);
    V01_line=y01(i,1:end);
    
    V10_line=y10(i,1:end);
    V11_line=y11(i,1:end);
    
    x0t=synthesis1d(g0,g1,V00_line,V01_line);
    x1t=synthesis1d(g0,g1,V10_line,V11_line);
    for j=1:2*s2
        x0(i,j)=x0t(j);
        x1(i,j)=x1t(j);
    end
    
end
[m1,n1]=size(x0);


for j=1:n1
    
    V0_line=transpose(x0(1:end,j));
    V1_line=transpose(x1(1:end,j));
    
    xhat_t=synthesis1d(g0,g1,V0_line,V1_line);
    for i=1:length(xhat_t)
        xhat(i,j)=xhat_t(i);
        
    end
    
    
end

[m2,n2]=size(xhat);
max=xhat(1,1);

for i=1:m2
    for j=1:n2
    
        if xhat(i,j)>max 
            max=xhat(i,j);
        end
    end
end

L=double(max);

for i=1:m2
    for j=1:n2
    
        xhat(i,j)=xhat(i,j)/(L-20);
        
        end
end



end

