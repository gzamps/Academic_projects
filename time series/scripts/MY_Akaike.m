

clear all
close all

xV=load('eruption2006.dat');
xV=xV(1:299);

i=1;
length= length(xV);


%%% Part 3 - Akaike Information Criterion %%%
%Calculate AIC for ARMA(0,0) - ARMA(9,9)
AIC = zeros(1, 10);
for MA=1:10,
    [~,~,~,~,AIC(MA+1), ~, ~] = fitARMA(xV, 0, MA, 3);
end
figure(i), plot(AIC(2:11), 'b.-')
hold on
AIC = zeros(1, 10);
for MA=1:10,
    [~,~,~,~,AIC(MA+1), ~, ~] = fitARMA(xV, 1, MA, 3);
end
figure(i), plot(AIC(2:11), 'r.-')
AIC = zeros(1, 10);
for MA=1:10,
    [~,~,~,~,AIC(MA+1), ~, ~] = fitARMA(xV, 2, MA, 3);
end
figure(i), plot(AIC(2:11), 'k.-')
title('AIC for different AR and MA order values')
xlabel('MA order')
ylabel('AIC value')
legend('AR order 0', 'AR order 1', 'AR order 2')
i = i+1;
