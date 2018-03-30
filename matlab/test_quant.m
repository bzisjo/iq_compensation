close all
clear all
clc

% Choose how much amplitude and phase mismatch between local oscillator
% signals
ampl_mismatch_db = 0;  %[dB]
IQ_phase_mismatch = 0; %[degrees]


%% Some parameters
Fs2 = 16e6;
downrate = 200;
Fs = downrate * Fs2;
dT = 1/Fs;
RF_ampl = 2;
LOI_ampl = 1*10^(ampl_mismatch_db/20);
LOQ_ampl = 1;
RF_freq = 2.440e8;


%% Choose which sideband the LO downconverts

% For this sideband, output amplitude should be ~0 -jon
% LO_freq = RF_freq + 2.5e6;

% For this sideband, output amplitude should be ~1/2 - jon
LO_freq = RF_freq - 2.5e6;


%% Create a complex bandpass FIR filter
Hlp = fir1(28,1e6/(Fs2/2));     % Lowpass prototype
N = length(Hlp)-1;
Fbp = 2.5e6/(Fs2/2);                              % Desired frequency shift
j = complex(0,1);
Hbp = Hlp.*exp(j*Fbp*pi*(0:N));

% View frequency response of filter
% fvtool(Hbp)

% Generate some tone at RF
N = 1e6;
t = 0:dT:(N-1)*dT;
MSK = RF_ampl * sin(2*pi*RF_freq*t);

%% Create LO with amplitude and phase mismatch
LOI = LOI_ampl * sin(2*pi*LO_freq*t)+LOI_ampl;
LOQ = LOQ_ampl * sin(2*pi*LO_freq*t + IQ_phase_mismatch + 90*pi/180)+LOQ_ampl;

%% Downconvert with LO
IFI = LOI .* MSK;
IFQ = LOQ .* MSK;

% Remove high frequency mixing content
[b,a] = butter(5,40e6/(Fs/2));
IFI_filt = filter(b,a,IFI);
IFQ_filt = filter(b,a,IFQ);

% Downsample to 16 MHz before further processing
Iout_un = IFI_filt(1:downrate:end);
Qout_un = IFQ_filt(1:downrate:end);
t = t(1:downrate:end);

%% Quantize
Iout = round(6.5*Iout_un);
Qout = round(6.5*Qout_un);

% Iout = round(6.5*Iout_un-0.5);
% Qout = round(6.5*Qout_un-0.5);


%% Output to hex

Iout_file = Iout + 8;
Qout_file = Qout + 8;

I_hex = dec2hex(Iout_file);
Q_hex = dec2hex(Qout_file);

fileID = fopen('I_uns.txt','w');
fprintf(fileID,'%c\n',I_hex);  
fclose(fileID);

fileID = fopen('Q_uns.txt','w');
fprintf(fileID,'%c\n',Q_hex);  
fclose(fileID);


%% Apply matlab I/Q compensation algorithm
% https://www.mathworks.com/help/comm/ref/comm.iqimbalancecompensator-system-object.html
% M = 1e-3;
% x = zeros(1,length(Iout));
% y = zeros(1,length(Iout));
% w = zeros(1,length(Iout));
% 
% for ii = 1:length(Iout)
%     x(ii) = Iout(ii) + j*Qout(ii);
%     y(ii) = x(ii) + w(ii)*conj(x(ii));
%     
%     w(ii+1) = w(ii) - M*y(ii)^2;
% end
% 
% IFI_filt = real(y);
% IFQ_filt = imag(y);
% 
M = 1/512;
iy = zeros(1,length(Iout));
qy = zeros(1,length(Iout));
wr = zeros(1,length(Iout));
wj = zeros(1,length(Iout));

% for ii = 1:length(Iout)
%     iy(ii) = Iout(ii) + wr(ii)*Iout(ii) + wj(ii)*Qout(ii);
%     qy(ii) = Qout(ii) + wj(ii)*Iout(ii) - wr(ii)*Qout(ii);
%     
%     wr(ii+1) = wr(ii) - M*(iy(ii) + qy(ii))*(iy(ii)-qy(ii));
%     wj(ii+1) = wj(ii) - M*(2*iy(ii)*qy(ii));
% end

product1 = zeros(1,length(Iout));
product2 = zeros(1,length(Iout));
product3 = zeros(1,length(Iout));
product4 = zeros(1,length(Iout));
sum1 = zeros(1,length(Iout));
sum2 = zeros(1,length(Iout));
shifted1 = zeros(1,length(Iout));
shifted2 = zeros(1,length(Iout));
IplusQ = zeros(1,length(Iout));
IminusQ = zeros(1,length(Iout));
IQprod1 = zeros(1,length(Iout));
IQprod2 = zeros(1,length(Iout));

for ii = 1:length(Iout)
    
%     product1(ii) = wr(ii)*Iout(ii);
%     product2(ii) = wj(ii)*Qout(ii);
%     product3(ii) = wj(ii)*Iout(ii);
%     product4(ii) = wr(ii)*Qout(ii);
%     sum1(ii) = product1(ii) + product2(ii);
%     sum2(ii) = product3(ii) - product4(ii);
%     shifted1(ii) = floor(M*sum1(ii));
%     shifted2(ii) = floor(M*sum2(ii));
%     
%     iy(ii) = Iout(ii) + shifted1(ii);
%     qy(ii) = Qout(ii) + shifted2(ii);
    
    
    iy(ii) = Iout(ii) + floor(M*(wr(ii)*Iout(ii) + wj(ii)*Qout(ii)));
    qy(ii) = Qout(ii) + floor(M*(wj(ii)*Iout(ii) - wr(ii)*Qout(ii)));
    
%     IplusQ(ii) = iy(ii) + qy(ii);
%     IminusQ(ii) = iy(ii) - qy(ii);
%     IQprod1(ii) = IplusQ(ii) * IminusQ(ii);
%     IQprod2(ii) = 2 * iy(ii) * qy(ii);
%     
    wr(ii+1) = wr(ii) - IQprod1(ii);
    wj(ii+1) = wj(ii) - IQprod2(ii);
    if(ii < 5000)
        wr(ii+1) = wr(ii) - ((iy(ii) + qy(ii))*(iy(ii)-qy(ii)));
        wj(ii+1) = wj(ii) - ((2*iy(ii)*qy(ii)));
    else
        wr(ii+1) = wr(ii);
        wj(ii+1) = wj(ii);
    end
end

iyout = (iy)/6.5;
qyout = (qy)/6.5;

IFI_filt = iy;
IFQ_filt = qy;
%%
% Filter signal with complex bandpass filter    
Rcoeff = real(Hbp);
Icoeff = imag(Hbp);

x1 = conv(IFI_filt,Rcoeff,'same');
x2 = conv(IFQ_filt,Icoeff,'same');
Iout_final = x1 - x2;

x3 = conv(IFI_filt,Icoeff,'same');
x4 = conv(IFQ_filt,Rcoeff,'same');
Qout_final = x3 + x4;

% Plot the Q channel after the IQ compensation and filtering
figure;plot(Iout_final)
figure;plot(Qout_final)


%% Load output from modelsim
fileID = fopen('i_out_thread.dat','r');
iy_modelsim = fscanf(fileID,'%x');
fclose(fileID);
iy_modelsim = iy_modelsim - 8;

fileID = fopen('q_out_thread.dat','r');
qy_modelsim = fscanf(fileID,'%x');
fclose(fileID);
qy_modelsim = qy_modelsim - 8;

x1_modelsim = conv(iy_modelsim,Rcoeff,'same');
x2_modelsim = conv(qy_modelsim,Icoeff,'same');
Iout_modelsim = x1_modelsim - x2_modelsim;

x3_modelsim = conv(iy_modelsim,Icoeff,'same');
x4_modelsim = conv(qy_modelsim,Rcoeff,'same');
Qout_modelsim = x3_modelsim + x4_modelsim;
figure;plot(Iout_modelsim);

%% Another quant signal
N = 2^10;

Fs = 2^24;
dT = 1/Fs;
t = 0:dT:(N-1)*dT;

% For generating a complex sinusoidal input
% fin = 2^21;
% fin = 2981888;
fin=2e6;
ini = 0.8*cos(fin*2*pi*t) + 0.001*randn(1,N);
inq = -0.8*sin(fin*2*pi*t) + 0.001*randn(1,N);

% Need to convert to a digital value to send bits over teensy
ini(find(ini > 0.875)) = 0.875;
ini(find(ini < -1)) = -1;
bins = -1:(2/(2^4)):1; 

% signed
% bins2 = bins; 

% unsigned
bins2 = 0:16;

ini_q = bins2(discretize(ini,bins));

inq_q = bins2(discretize(inq,bins));
I_hex = dec2hex(ini_q);
Q_hex = dec2hex(inq_q);

fileID = fopen('I_uns.txt','w');
fprintf(fileID,'%c\n',I_hex);  
fclose(fileID);

fileID = fopen('Q_uns.txt','w');
fprintf(fileID,'%c\n',Q_hex);  
fclose(fileID);