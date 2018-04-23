close all
clear all
clc

% Choose how much amplitude and phase mismatch between local oscillator
% signals
ampl_mismatch_db = 20;  %[dB]
IQ_phase_mismatch = 40; %[degrees]

%% Some parameters
Fs2 = 16e6;
downrate = 600;
Fs = downrate * Fs2;
dT = 1/Fs;
RF_ampl = 2;
LOI_ampl = 1*10^(ampl_mismatch_db/20);
LOQ_ampl = 1;

IF_freq = 2.5e6;
RF_freq = 2.440e9;
RFimage_freq = RF_freq - 2 * IF_freq;
LO_freq = RF_freq - IF_freq; % Low-side injection: LO < RF


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
IMG = RF_ampl * sin(2*pi*RFimage_freq*t);


%% 2-Sided FFT for checking purposes
% X=fft(MSK+IMG);
% X_shift=fftshift(X);
% N=length(MSK);
% w=fftshift((0:N-1)/N*2*pi);
% w(1:N/2)=w(1:N/2)-2*pi;
% f=Fs/(2*pi)*w;
% plot(f, abs(X_shift))
%% Create LO with amplitude and phase mismatch
LOI = LOI_ampl * sin(2*pi*LO_freq*t)+LOI_ampl;
LOQ = LOQ_ampl * sin(2*pi*LO_freq*t + IQ_phase_mismatch*pi/180 - 90*pi/180)+LOQ_ampl;

%% Downconvert with LO
IFI = LOI .* MSK;
IFQ = LOQ .* MSK;

IFIimage = LOI .* IMG;
IFQimage = LOQ .* IMG;

% Remove high frequency mixing content
[b,a] = butter(5,40e6/(Fs/2));
IFI_filt = filter(b,a,IFI);
IFQ_filt = filter(b,a,IFQ);
IFIimage_filt = filter(b,a,IFIimage);
IFQimage_filt = filter(b,a,IFQimage);

% Downsample to 16 MHz before further processing
Iout = IFI_filt(1:downrate:end);
Qout = IFQ_filt(1:downrate:end);
Iimage = IFIimage_filt(1:downrate:end);
Qimage = IFQimage_filt(1:downrate:end);
t = t(1:downrate:end);

%% 2-Sided FFT for checking purposes
% X=fft(Iout);
% X_shift=fftshift(X);
% N=length(Iout);
% w=fftshift((0:N-1)/N*2*pi);
% w(1:N/2)=w(1:N/2)-2*pi;
% f=Fs2/(2*pi)*w;
% plot(f, abs(X_shift))

%% Apply matlab I/Q compensation algorithm
% https://www.mathworks.com/help/comm/ref/comm.iqimbalancecompensator-system-object.html
M = 1/100;
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
% xim = zeros(1,length(Iout));
% yim = zeros(1,length(Iout));
% wim = zeros(1,length(Iout));
% 
% for ii = 1:length(Iout)
%     xim(ii) = Iimage(ii) + j*Qimage(ii);
%     yim(ii) = xim(ii) + wim(ii)*conj(xim(ii));
%     
%     wim(ii+1) = wim(ii) - M*yim(ii)^2;
% end
% 
% Iout = real(y);
% Qout = imag(y);
% 
% Iimage = real(y);
% Qimage = imag(y);

iy = zeros(1,length(Iout));
qy = zeros(1,length(Iout));
wr = zeros(1,length(Iout));
wj = zeros(1,length(Iout));

for ii = 1:length(Iout)
    iy(ii) = Iout(ii) + wr(ii)*Iout(ii) + wj(ii)*Qout(ii);
    qy(ii) = Qout(ii) + wj(ii)*Iout(ii) - wr(ii)*Qout(ii);
    
    wr(ii+1) = wr(ii) - M*(iy(ii) + qy(ii))*(iy(ii)-qy(ii));
    wj(ii+1) = wj(ii) - M*(2*iy(ii)*qy(ii));
end

Iout = iy;
Qout = qy;

iyim = zeros(1,length(Iout));
qyim = zeros(1,length(Iout));
wrim = zeros(1,length(Iout));
wjim = zeros(1,length(Iout));

for ii = 1:length(Iout)
    iyim(ii) = Iimage(ii) + wrim(ii)*Iimage(ii) + wjim(ii)*Qimage(ii);
    qyim(ii) = Qimage(ii) + wjim(ii)*Qimage(ii) - wrim(ii)*Qimage(ii);
    
    wrim(ii+1) = wrim(ii) - M*(iyim(ii) + qyim(ii))*(iyim(ii)-qyim(ii));
    wjim(ii+1) = wjim(ii) - M*(2*iyim(ii)*qyim(ii));
end

Iimage = iyim;
Qimage = qyim;

%%
% Filter signal with complex bandpass filter    
Rcoeff = real(Hbp);
Icoeff = imag(Hbp);

% Actual signal
x1 = conv(Iout,Rcoeff,'same');
x2 = conv(Qout,Icoeff,'same');

x3 = conv(Iout,Icoeff,'same');
x4 = conv(Qout,Rcoeff,'same');

Iout_rej = x1 + x2;
Qout_rej = x3 - x4;

% Image signal
x1im = conv(Iimage,Rcoeff,'same');
x2im = conv(Qimage,Icoeff,'same');

x3im = conv(Iimage,Icoeff,'same');
x4im = conv(Qimage,Rcoeff,'same');

Iimage_rej = x1im + x2im;
Qimage_rej = x3im - x4im;


% Plot the Q channel after the IQ compensation and filtering
subplot(411);plot(Iout_rej);title("Iout")
subplot(412);plot(Qout);title("Qout")

subplot(413);plot(Iimage_rej);title("Iimage")
subplot(414);plot(Qimage_rej);title("Qimage")

% figure;
% subplot(211);plot(wr);title('wr');
% subplot(212);plot(wj);title('wj');
% 
% figure;
% subplot(211);plot(wrim);title('wr_image');
% subplot(212);plot(wjim);title('wj_image');