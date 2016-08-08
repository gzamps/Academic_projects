function [s0, CurrFrmResd]=RPE_frame_ST_decoder(LARc, CurrFrmResd) 

A = [ 20 20 20 20 13.637 15 8.334 8.824 ];
B = [ 0 0 4 -5 0.184 -3.5 -0.666 -2.235 ];

LAR = zeros(8, 1);
for i=1:8
    LAR(i) = ( LARc(i) - B(i) )/ A(i);
end

%reflection coeffs from LAR
ri=zeros(8,1);

for i=1:8

    if (abs(LAR(i)) < 0.675 )
        ri(i) = LAR(i);  
    elseif ( abs(LAR(i)) >= 0.675 && abs(LAR(i)) < 1.225)
        ri(i) = sign(LAR(i)) * (0.5*abs(LAR(i)) + 0.337500);
    elseif ( abs(LAR(i)) >= 1.225 && abs(LAR(i)) <= 1.625  )
        ri(i) = sign(LAR(i)) * (0.125*abs(LAR(i)) + 0.796875);
    end
    
end

wn = rc2poly(ri);

s0 = filter(1,wn,CurrFrmResd);