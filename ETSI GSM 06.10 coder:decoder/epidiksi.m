% epidiksi
clear all;
close all;

[so, Fs] = audioread('wishes8000.wav'); 

whole_bitstream=blanks(65000);


%frames = size / 160;
size = length(so);


%% Preprocessing

% Offset compensation
b1 = [1, -1];
a1 = [1, -32735*2^-15];
sof = filter(b1,a1,so);

% Pre-emphasis
b2 = [1, -28180*2^-15];
a2 = 1;
s = filter(b2,a2,sof);


%Coding
LARs = zeros(8*250, 1);
Resd = zeros(160*250, 1);
PrevFrmResd = 0;

for fr=1:250

    s0 = s( (fr-1)*160 + 1 : fr*160);
    [LARc, CurrFrmResd]=RPE_frame_ST_coder(s0, PrevFrmResd);
    LARs( (fr-1)*8 + 1 :fr*8 ) = LARc;
    Resd( (fr-1)*160 + 1 :fr*160 ) = CurrFrmResd;
    
end


%Decoding

for fr=1:250
    
    LARc = LARs( (fr-1)*8 + 1 :fr*8 );
    CurrFrmResd = Resd( (fr-1)*160 + 1 :fr*160 );
    [s0,CurrFrmResd] = RPE_frame_ST_decoder(LARc , CurrFrmResd);
    S( (fr-1)*160 + 1 : fr*160 ) = s0;
    
end

% De-emphasis
b3 = [1, 0];
a3 = [1, -28180*2^-15];
Sro = filter(b3,a3,S);