% Simulation of an ARMA process. 
% 1. Generation of a time series from a given ARMA process
% 2. Autocorrelation and partial autocorrelation 
% 3. Fit of a ARMA model.
% 4. Prediction error statistic for the ARMA model.
% 5. Multi-step predictions from a given target point with the ARMA model.
clear all
close all



rooV = [0.4+0.3*i 0.4-0.3*i 0.6 0.8]';
%phi0= 0;
%thetaV = [-5 0.4];
%n = 1000;
sdnoise = 0;
maxtau = 100;
Tmax = 10;
proptest = 0.3;
alpha = 0.05;

tmpV = poly(rooV);
%phiV = [phi0; -tmpV(2:length(rooV)+1)'];
%pgen = length(phiV)-1;
%qgen = length(thetaV);
% 1. Generation of a time series from a given ARMA process
xV=load('eruption2006.dat');
xV500 = xV(1:501);
n=length(xV);
xV=load('eruption2006.dat');
figno = 1;
figure(figno)
clf
plot(xV,'.-')
hold on
xlabel('t')
ylabel('x(t)')
%title(sprintf('ARMA(%d,%d), time history',pgen,qgen))


figno = figno + 1;
figure(figno)
clf
plot(xV500,'.-')
hold on
xlabel('t')
ylabel('x(t)')





% 2. Autocorrelation and partial autocorrelation 
% 2a. Autocorrelation
[acM] = autocorrelation(xV, maxtau);
zalpha = norminv(1-alpha/2);
autlim = zalpha/sqrt(n);
figno = figno + 1;
figure(figno)
clf
hold on
for ii=1:maxtau
    plot(acM(ii+1,1)*[1 1],[0 acM(ii+1,2)],'b','linewidth',1.5)
end
plot([0 maxtau+1],[0 0],'k','linewidth',1.5)
plot([0 maxtau+1],autlim*[1 1],'--c','linewidth',1.5)
plot([0 maxtau+1],-autlim*[1 1],'--c','linewidth',1.5)
xlabel('\tau')
ylabel('r(\tau)')
%title(sprintf('ARMA(%d,%d), autocorrelation',pgen,qgen))


% 2a. Autocorrelation of small 
[acM500] = autocorrelation(xV500, maxtau);
zalpha = norminv(1-alpha/2);
autlim = zalpha/sqrt(n);
figno = figno + 1;
figure(figno)
clf
hold on
for ii=1:maxtau
    plot(acM500(ii+1,1)*[1 1],[0 acM500(ii+1,2)],'b','linewidth',1.5)
end
plot([0 maxtau+1],[0 0],'k','linewidth',1.5)
plot([0 maxtau+1],autlim*[1 1],'--c','linewidth',1.5)
plot([0 maxtau+1],-autlim*[1 1],'--c','linewidth',1.5)
xlabel('\tau')
ylabel('r(\tau)')


% 2b. Partial autocorrelation
display = 1;
pacfV = parautocor(xV,maxtau);
figno = figno + 1;
figure(figno)
clf
hold on
for ii=1:maxtau
    plot(acM(ii+1,1)*[1 1],[0 pacfV(ii)],'b','linewidth',1.5)
end
plot([0 maxtau+1],[0 0],'k','linewidth',1.5)
plot([0 maxtau+1],autlim*[1 1],'--c','linewidth',1.5)
plot([0 maxtau+1],-autlim*[1 1],'--c','linewidth',1.5)
xlabel('\tau')
ylabel('\phi_{\tau,\tau}')
title(sprintf('ARMA(%d,%d), partial autocorrelation',1,1))


% 2b. Partial autocorrelation
display = 1;
pacfV500 = parautocor(xV500,maxtau);
figno = figno + 1;
figure(figno)
clf
hold on
for ii=1:maxtau
    plot(acM(ii+1,1)*[1 1],[0 pacfV500(ii)],'b','linewidth',1.5)
end
plot([0 maxtau+1],[0 0],'k','linewidth',1.5)
plot([0 maxtau+1],autlim*[1 1],'--c','linewidth',1.5)
plot([0 maxtau+1],-autlim*[1 1],'--c','linewidth',1.5)
xlabel('\tau')
ylabel('\phi_{\tau,\tau}')
title(sprintf('ARMA(%d,%d), partial autocorrelation',1,1))


%[fnnM,mdistV,sddistV] = falsenearest(xV,1,20,10,0,'false nearest');

%[hV,pV,QV,xautV] = portmanteauLB(acM(:,2) ,20 , 0.05, 'portmanteau');
[hV,pV,QV,xautV] = portmanteauLB(xV,20 , 0.05, 'portmanteau');

[mutM] = mutualinformation(xV, 10)

t_mut = 1;
m=7;
%Tmax = (m-1)*t_mut;
Tmax = 10
[fnnM,mdistV,sddistV] = falsenearest(xV,1,10,10,0,'fnn')

t_mut = 1;
m=5;
%Tmax = (m-1)*t_mut;
Tmax =10;




nrmseV = localfitnrmse(xV,t_mut,m,Tmax ,50,0,'nrmse')
[nrmseV,preM] = localpredictnrmse(xV,10,1,m,Tmax,200,1,'prediction')

n1 =10
q=1
p=1
nnei=5
%[preV] = predictARMAmultistep(xV,n1,p,q,Tmax,'example');
[preV] = linearpredictmultistep(xV,5686,m,20,'example');
[preV1] = localpredictmultistep(xV,5686,1,m,20,nnei,q,'example');
%{

% 4. Prediction error statistic for the ARMA model.
nlast = proptest*n;
tittxt = sprintf('ARMA(%d,%d), %%test=%1.2f, prediction error',p,q,proptest);
figno = figno + 1;
figure(figno);
clf
[nrmseV,preM] = predictARMAnrmse(xV,p,q,Tmax,nlast,'example');
figno = figno + 1;
figure(figno);
clf
plot([n-nlast+1:n]',xV(n-nlast+1:n),'.-')
hold on
plot([n-nlast+1:n]',preM(:,1),'.-r')
if Tmax>1
    plot([n-nlast+1:n]',preM(:,2),'.-c')
	if Tmax>2
        plot([n-nlast+1:n]',preM(:,3),'.-k')
    end
end
switch Tmax
    case 1
        legend('true','T=1','Location','Best')
    case 2
        legend('true','T=1','T=2','Location','Best')
    otherwise
        legend('true','T=1','T=2','T=3','Location','Best')
end
% 5. Multi-step predictions from a given target point with the ARMA model.
n1 = n-Tmax;
figno = figno + 1;
figure(figno);
clf
[preV] = predictARMAmultistep(xV,n1,p,q,Tmax,'example');
%}
