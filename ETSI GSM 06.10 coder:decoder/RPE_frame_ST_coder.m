function [LARc, CurrFrmResd]=RPE_frame_ST_coder(s0, PrevFrmResd)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


A = [ 20 20 20 20 13.637 15 8.334 8.824 ];
B = [ 0 0 4 -5 0.184 -3.5 -0.666 -2.235 ];                
minLARc = [ -32 -32 -16 -16 -8 -8 -4 -4 ];
maxLARc = [ 31 31 15 15 7 7 3 3 ];

%calculation of polynomial coeffs 
rs=zeros(1,9);

for k=1:9
    for j=k:160
        rs(k) = rs(k) + s0(j)*s0(j - k + 1);
   end
end
    
rsmat = rs(1:8);
R = toeplitz(rsmat);
rsn = rs(2:end);
rsn = transpose(rsn);
w = R\rsn;
%w= inv(R)*rsn;
wn = [1; -w];

%polynomial to reflection coeffs 
ri = poly2rc(wn);

%reflection to LAR
LAR = zeros(8, 1);
for i=1:8
    if (abs(ri(i)) < 0.675 )
        LAR(i) = ri(i);  
    elseif (abs(ri(i)) >= 0.675 && abs(ri(i)) < 0.950)
        LAR(i) = sign(ri(i)) * (2*abs(ri(i)) - 0.675);
    elseif (abs(ri(i)) >= 0.950 && abs(ri(i)) <= 1 )
        LAR(i) = sign(ri(i)) * (8*abs(ri(i)) - 6.375);
    end
end

%quantization of LAR
LARc = zeros(8, 1);
for i=1:8
    LARc(i) = round( A(i)*LAR(i) + B(i) + sign( A(i)*LAR(i) + B(i) ) *0.5 );
    if (LARc(i) > maxLARc(i))
        LARc(i) = maxLARc(i);
    end
    if (LARc(i) < minLARc(i))
        LARc(i) = minLARc(i);
    end

end 

%LAR from LARc
i_LAR=zeros(8,1);
i_ri=zeros(8,1);
for i=1:8
    i_LAR(i) = ( LARc(i) - B(i) )/ A(i); 
end


for i=1:8
    
    if ( abs(i_LAR(i)) < 0.675 )
        i_ri(i) = i_LAR(i);  
    elseif ( abs(i_LAR(i)) >= 0.675 && abs( i_LAR(i)) < 1.225)
        i_ri(i) = sign(i_LAR(i)) * (0.5*abs(i_LAR(i)) + 0.337500);
    elseif ( abs(i_LAR(i)) >= 1.225 && abs(i_LAR(i)) <= 1.625 )
        i_ri(i) = sign(i_LAR(i)) * (0.125*abs(i_LAR(i)) + 0.796875);
    end

end


i_w = rc2poly(i_ri);
i_wn = i_w(2:end)*(-1);
dfilt = filter(i_wn,1,s0);
CurrFrmResd = s0 - dfilt;

end