%demo3.m


x=imread('farm.jpg');

load('db10.mat');
h=db10;

[ h0,h1,g0,g1 ] = orthonormalFilterBanks( h );

[ y00,y01,y10,y11 ] = analysis2d( h0,h1,x );

[ xhat ] = synthesis2d( g0,g1,y00,y01,y10,y11 );


 [m1,n1]=size(x);
max=x(1,1);

for i=1:m1
    for j=1:n1
    
        if x(i,j)>max 
            max=x(i,j);
        end
    end
end

L=double(max);           


figure(1)
subplot(221)
imshow(y00/L);
subplot(222)
imshow(y01);
subplot(223)
imshow(y10);
subplot(224)
imshow(y11);
figure(2)
subplot(211)
imshow(x);
subplot(212)
imshow(xhat);
