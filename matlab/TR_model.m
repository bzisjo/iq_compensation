close all
clear all 
clc
tic

%SNR_dB = 150; %[dB]
num_bits = 8016/8;

%% Parameters
Fs2 = 64e6;
dT2=1/Fs2;
downrate = 400;
Fs = downrate * Fs2;
Fs3 = Fs2/4;
dT = 1/Fs3;
T = 0.5e-6;

% Other Variables
RF_ampl = 80e-3;
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


%% Timing recovery algorithm for MSK
e = zeros(1,num_bits);
e_lpf = zeros(1,num_bits);
y1_ar = zeros(1,num_bits);
y2_ar = zeros(1,num_bits);

e_v = zeros(1,num_bits);
e_lpf_v = zeros(1,num_bits);
y1_ar_v = zeros(1,num_bits);
y2_ar_v = zeros(1,num_bits);

m = round(T/dT);
tau = 0*ones(1,num_bits);
sample_points = zeros(1,num_bits);

I_file = fopen('I_1.txt','r');
Q_file = fopen('Q_1.txt','r');

I_hex = cell2mat(textscan(I_file, '%c'));
Q_hex = cell2mat(textscan(Q_file, '%c'));

I = hex2dec(I_hex);
Q = hex2dec(Q_hex);

%conversion from hex
for k = 1:length(I)
    if (I(k) > 7)
        I(k) = I(k) - 16;
    end
    if (Q(k) > 7)
        Q(k) = Q(k) - 16;
    end
end


for k = 2:(num_bits-2)
   
    %% Begin Error Detector
    % ---------------
    % Same error detector as used in matlab, gnuradio, and the book
    x1 = I(m*k + tau(k) - 1) + 1i*Q(m*k + tau(k) - 1);
    x2 = I(m*(k-1) + tau(k) - 1) + 1i*Q(m*(k-1) + tau(k) - 1);
    x3 = I(m*k + tau(k) + 1) + 1i*Q(m*k + tau(k) + 1);
    x4 = I(m*(k-1) + tau(k) + 1) + 1i*Q(m*(k-1) + tau(k) + 1);
    
    y1 = real(x1^2 * (conj(x2))^2);
    y2 = real(x3^2 * (conj(x4))^2);
    
    y1_ar(k) = y1;
    y2_ar(k) = y2;
    e(k) = y1 - y2;
    
    %{
    i_1 = I(m*k + tau(k) - 1);
    q_1 = Q(m*k + tau(k) - 1);
        
    i_2 = I(m*(k-1) + tau(k) - 1);
    q_2 = Q(m*(k-1) + tau(k) - 1);
        
    i_3 = I(m*k + tau(k) + 1);
    q_3 = Q(m*k + tau(k) + 1);

    i_4 = I(m*(k-1) + tau(k) + 1);
    q_4 = Q(m*(k-1) + tau(k) + 1);
    
    y1_v = (i_1*i_1 - q_1*q_1)  * (i_2*i_2 - q_2*q_2) + 4*(i_1*q_1*i_2*q_2);
    y2_v = (i_3*i_3 - q_3*q_3)  * (i_4*i_4 - q_4*q_4) + 4*(i_3*q_3*i_4*q_4);
    
    
    y1_ar_v(k) = y1_v;
    y2_ar_v(k) = y2_v;
    e_v(k) = y1_v - y2_v;
    
    %}
    %% End Error Detector
    % ---------------
    
    % Low pass filter on the error signal
    % I made these values up 
    % Lower filter frequency means less noise/ripple
    % But it takes longer to lock
    % Will also affect jitter tolerance
    %e_lpf(k) = e(k)*0.05 + e_lpf(k-1)*0.95;
    filter = 0.05;
    e_lpf(k) = e(k)*filter + e_lpf(k-1)*(1-filter);
    %e_lpf_v(k) = e_v(k)*0.05 + e_lpf_v(k-1)*0.95;
    
    
    % This is my shoddy feedback attempt to drive the error signal to zero
    % When the error signal grows beyond some bound, update tau
    % Tau is the sampling point from 1-8
    % Fs=16M and data rate = 2M, so there are eight samples per symbol
    % The below tries to choose tau during each symbol for the lowest error
    
    threshold = 170;%0.2*(2^(4*4-1));
    update_period = 5;
    %if(rem(k,10)==0)
    if(rem(k,update_period)==0)
        if(e_lpf(k) > threshold)
            tau(k+1) = tau(k) + 1;
        elseif(e_lpf(k) < -1*threshold)
            tau(k+1) = tau(k) - 1;
        else
            tau(k+1) = tau(k);
        end
    else
        tau(k+1) = tau(k);
    end
    
    
    % Deal with rollover
    if(tau(k+1) > 8)
        tau(k+1) = 1;
    end
    if(tau(k+1) < 1)
        tau(k+1) = 8;
    end
end

max(abs(e_lpf))
tau(1000)
plot(tau/max(tau), 'b')
hold on;
%title('Sampling Phase Estimate');
%figure
plot(e_lpf/max(abs(e_lpf)), 'r')
%title('Filtered Error Signal');

%plot(y1_ar(1:30));
%hold on;
%plot(y2_ar(1:30));
%{
plot(y1_ar);
hold on;
plot(y1_ar_v);
hold off;

figure;
plot(y2_ar);
hold on;
plot(y2_ar_v);
hold off;
%}
%plot(linspace(1,length(e),length(e))*8, e);
%hold on;
%plot(e_all);
%hold off;

figure;
plot(e_lpf/2401);

toc
