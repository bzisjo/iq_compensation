close all
clear all 
clc
tic

SNR_dB = 150; %[dB]
num_bits = 1000;

%% Parameters
Fs2 = 64e6;
dT2=1/Fs2;
downrate = 400;
Fs = downrate * Fs2;
Fs3 = Fs2/4;
dT = 1/Fs;
T = 0.5e-6;

% Filter Coefficients
var1 = 3;
var2 = 3;
var3 = 2;
var4 = 3;
var5 = 3;
var6 = 2;

% Other Variables
RF_ampl = 78e-3;
LO_freq_offset = 0e3;
adc_num_bits = 4;
LOQ_ampl = 1;
IQ_phase_mismatch = 0;
freq_shift = 500e3;
num_runs = 1; 
blocker_offset = 10e6;
LOI_ampl = 1;
cn = 8e-17;                  %white PN c value
LO_phase = 2*pi*rand;
adc_full_scale = 100e-3;
IF_freq = 2.5e6;
RF_freq = 2.44e9;
LO_freq = RF_freq - IF_freq + LO_freq_offset;

% Calculate noise power for this SNR
sig_power = (RF_ampl/2/sqrt(2))^2;
SNR_lin = 10^(SNR_dB/10);
noise_pow = sig_power/SNR_lin;  %in BW=2MHz
IF_noise_density = sqrt(noise_pow/2e6);

%% Generate Data and modulate as RF MSK
% Generate some random data
data = randi([0 1],num_bits,1);
% data = ones(1,num_bits);

%Convert data to +/- 1
data = data*2-1;
% Set tone spacing for fsk
% freq_shift = 500e3;

% Generate first cycle of RF
t = 0:1/Fs:T-1/Fs;
phase = 2*pi*(RF_freq+data(1)*freq_shift)*t;
phase_last = phase(end);

% Generate remaining modulated RF cycles
t = 1/Fs:1/Fs:T;
for x=2:1:length(data)
    % The phase of each cycle starts where the last one ended
    phase = [phase 2*pi*(RF_freq+data(x)*freq_shift)*t + phase_last];
    phase_last = phase(end);
end

% Scale amplitude to get desired power
MSK = RF_ampl * sin(phase);
t = 0:dT:(length(MSK)-1)*dT;


%% I/Q LO with imperfections (white PN, I/Q imbalance)
%% Generate Gaussian distro for white noise
w = randn(1,length(MSK));

%% Generate the white portion of phi(t)
s_phi = cumsum(sqrt(cn * dT) * w);

%% Create LO with phase noise
LOI = LOI_ampl * sin(2*pi*LO_freq*t + 2*pi*LO_freq*s_phi + LO_phase);
LOQ = LOQ_ampl * sin(2*pi*LO_freq*t + 2*pi*LO_freq*s_phi - (90+IQ_phase_mismatch)*pi/180 + LO_phase);

%% Downconvert, downsample, add noise, filter
IFI = LOI .* MSK;
IFQ = LOQ .* MSK;







% Remove high frequency mixing content
[b,a] = butter(1,40e6/(Fs/2));
IFI_filt = filter(b,a,IFI);
IFQ_filt = filter(b,a,IFQ);

% Downsample before further processing
IFI_filt = IFI_filt(1:downrate:end);
IFQ_filt = IFQ_filt(1:downrate:end);
t = t(1:downrate:end);

noise_power = IF_noise_density^2 * (Fs2/2);
IFI_noise = sqrt(noise_power) * randn(1,length(IFI_filt));
IFQ_noise = sqrt(noise_power) * randn(1,length(IFQ_filt));

% Assume 5MHz mixer pole
a = (5e6*2*pi)^1;
b = [1 5e6*2*pi];
IFI_filt = filter(b,a,IFI_filt + IFI_noise);
IFQ_filt = filter(b,a,IFQ_filt + IFQ_noise);







%% IIR Filter
gm = 64e-6;
Cs = 500e-15;
Ca = 3*Cs;
Cb = 2*Cs;
Cc = 3*Cs;
Cd = 2*Cs;
V1 = zeros(1,length(IFI_filt));
V2 = zeros(1,length(IFI_filt));
V3 = zeros(1,length(IFI_filt));
V4 = zeros(1,length(IFI_filt));

Vin = IFI_filt;

for kk = 2:length(IFI_filt)
    % 1st stage, 2 complex conj pole IIR
    V1(kk) = (Ca*V1(kk-1) + gm*dT2*Vin(kk) - Cs*V2(kk-1)) / (Ca + Cs);
    
    V2(kk) = (Cb*V2(kk-1) + Cs*V1(kk-1)) / (Cb + Cs);
    
    % 2nd stage, 2 complex conj pole IIR
    V3(kk) = (Cc*V3(kk-1) + gm*dT2*V2(kk) - Cs*V4(kk-1)) / (Cc + Cs);
    
    V4(kk) = (Cd*V4(kk-1) + Cs*V3(kk-1)) / (Cd + Cs);
    
end
IFI_filt = V4;
%%%%%

%% IIR Filter
gm = 64e-6;
Cs = 500e-15;
Ca = 3*Cs;
Cb = 2*Cs;
Cc = 3*Cs;
Cd = 2*Cs;
V1 = zeros(1,length(IFI_filt));
V2 = zeros(1,length(IFI_filt));
V3 = zeros(1,length(IFI_filt));
V4 = zeros(1,length(IFI_filt));

Vin = IFQ_filt;

for kk = 2:length(IFQ_filt)
    % 1st stage, 2 complex conj pole IIR
    V1(kk) = (Ca*V1(kk-1) + gm*dT2*Vin(kk) - Cs*V2(kk-1)) / (Ca + Cs);
    
    V2(kk) = (Cb*V2(kk-1) + Cs*V1(kk-1)) / (Cb + Cs);
    
    % 2nd stage, 2 complex conj pole IIR
    V3(kk) = (Cc*V3(kk-1) + gm*dT2*V2(kk) - Cs*V4(kk-1)) / (Cc + Cs);
    
    V4(kk) = (Cd*V4(kk-1) + Cs*V3(kk-1)) / (Cd + Cs);
    
end
IFQ_filt = V4;







% Fake some filtering using floating point, skip ADC
coeff = fir1(63,[1e6/(Fs2/2) 4e6/(Fs2/2)]);
% Decimation filtering, m=4
IFI_filt_dig = conv(coeff,IFI_filt);
IFI_filt_dig = IFI_filt_dig(1:4:end);
IFQ_filt_dig = conv(coeff,IFQ_filt);
IFQ_filt_dig = IFQ_filt_dig(1:4:end);





%% Implement Matched Filter
% Templates
dT = 1/Fs3;
tt = 0:dT:T-dT;
template1Q = 0.042*sin(2*pi*((IF_freq-500e3)*tt));
template1I = 0.042*cos(2*pi*((IF_freq-500e3)*tt));
template2Q = 0.042*sin(2*pi*((IF_freq+500e3)*tt));
template2I = 0.042*cos(2*pi*((IF_freq+500e3)*tt));

% Matched Filter 1
I1 = conv(IFI_filt_dig,template1I);
Q1 = conv(IFI_filt_dig,template1Q);
I1 = I1(0.5*T/dT:end-0.5*T/dT);
Q1 = Q1(0.5*T/dT:end-0.5*T/dT);
mf1 = sqrt(I1.^2 + Q1.^2);

% Matched Filter 2
I2 = conv(IFI_filt_dig,template2I);
Q2 = conv(IFI_filt_dig,template2Q);
I2 = I2(0.5*T/dT:end-0.5*T/dT);
Q2 = Q2(0.5*T/dT:end-0.5*T/dT);
mf2 = sqrt(I2.^2 + Q2.^2);

% Output is difference between matched filters
MF_output = mf1 - mf2;






%% Timing recovery algorithm for MSK
e = zeros(1,num_bits);
e_lpf = zeros(1,num_bits);
m = round(T/dT);
tau = ones(1,num_bits);
sample_points = zeros(1,num_bits);

I = IFI_filt_dig/max(IFI_filt_dig);
Q = IFQ_filt_dig/max(IFQ_filt_dig);


I_test = round(I.*7);
Q_test = round(Q.*7);

%conversion to hex
for k = 1:length(I_test)
    if (I_test(k) < 0)
        I_test(k) = I_test(k) + 16;
    end
    if (Q_test(k) < 0)
        Q_test(k) = Q_test(k) + 16;
    end
end

I_hex = dec2hex(I_test);
Q_hex = dec2hex(Q_test);

fileID = fopen('I_1.txt','w');
fprintf(fileID,'%c',I_hex);  
fclose(fileID);

fileID = fopen('Q_1.txt','w');
fprintf(fileID,'%c',Q_hex);  
fclose(fileID);

toc
