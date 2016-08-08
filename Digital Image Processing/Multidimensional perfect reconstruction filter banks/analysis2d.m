function [ y00,y01,y10,y11 ] = analysis2d( h0,h1,x )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[m,n]=size(x);
for j=1:n
   
    Vcol = x(1:end,j);
   Vline = transpose(Vcol);
    
    

  
   [y0t,y1t]=analysis1d(h0,h1,Vline);
   for i=1:floor(m/2)
    
            y0(i,j)=y0t(i);
            y1(i,j)=y1t(i);
   end


end

[m_new,M]=size(y0);

for i=1:m_new
    
    V0line=y0(i,1:end);
    
    [y00t,y01t]=analysis1d(h0,h1,V0line);
   
        for j=1:floor(n/2)
        y00(i,j)=y00t(j);
        y01(i,j)=y01t(j);
    end
    
    V1line=y1(i,1:end);
    
    [y10t,y11t]=analysis1d(h0,h1,V1line);
   
    for j=1:floor(n/2) 
        y10(i,j)=y10t(j);
        y11(i,j)=y11t(j);
    end
end





