function Generate_dtData(WSJ_dir_name,save_dir)
%
% Input variables:
%    WSJ_dir_name: string name of user's WSJCAM0 directory
%    save_dir: string name where user would like to save 
%               noisy reverberant WSJCAM0       
%
% This function generates noisy reverberant WSJCAM0
% based on the room impulse responses (RIRs), noise,
% with the same structure as original corpus, 
% Specifically, this function generates development test set.
%

data_amount=zeros(1,3);

% Parameters related to acoustic conditions
SNRdB=20;

% List of WSJ speech data
flistjam1='etc/audio_si_dt5a.lst';
flistjam2='etc/audio_si_dt5b.lst';
flist1='etc/audio_si_et_1.lst';
flist2='etc/audio_si_et_2.lst';

%
% List of noise
%
num_NOISEvar=3;
noise_sim1='./NOISE/Noise_SimRoom1';
noise_sim2='./NOISE/Noise_SimRoom2';
noise_sim3='./NOISE/Noise_SimRoom3';

% Make parent directories

if save_dir(end)=='/';
    save_dir_near=[save_dir,'REVERB_WSJCAM0_et/data/near_test/'];
    save_dir_far=[save_dir,'REVERB_WSJCAM0_et/data/far_test/'];
    save_dir_cln=[save_dir,'REVERB_WSJCAM0_et/data/cln_test/'];
else
    save_dir_near=[save_dir,'/REVERB_WSJCAM0_et/data/near_test/'];  
    save_dir_far=[save_dir,'/REVERB_WSJCAM0_et/data/far_test/'];
    save_dir_cln=[save_dir,'/REVERB_WSJCAM0_et/data/cln_test/'];
end
mkdir([save_dir_near]);
mkdir([save_dir_far]);
mkdir([save_dir_cln]);

%
% Start generating noisy reverberant data with creating new directories
%

mic_idx=['A';'B';'C';'D';'E';'F';'G';'H'];
num_RIRvar=3;

for i=1:2 % i=1 corresponds to "near" and i=2 to "far"

    name_rule=[1; 2; 3; 4; 5; 6; 7; 8];
    
    if i==1
        RIR_sim1='./RIR/RIR_SimRoom1_near_AnglB.wav'; % RT:0.25
        RIR_sim2='./RIR/RIR_SimRoom2_near_AnglB.wav';   % RT:0.5
        RIR_sim3='./RIR/RIR_SimRoom3_near_AnglB.wav';   % RT:0.7
        save_dir_i=save_dir_near;
    elseif i==2
        % List of RIRs
        RIR_sim1='./RIR/RIR_SimRoom1_far_AnglB.wav'; % RIR_Ermtg_short_near_AnglA.wav
        RIR_sim2='./RIR/RIR_SimRoom2_far_AnglB.wav';   % RT:0.5
        RIR_sim3='./RIR/RIR_SimRoom3_far_AnglB.wav';        
        save_dir_i=save_dir_far;
    end

    if i==1
        RIR_jam1='./RIR/RIR_SimRoom1_near_AnglA.wav'; % RT:0.25
        RIR_jam2='./RIR/RIR_SimRoom2_near_AnglA.wav';   % RT:0.5
        RIR_jam3='./RIR/RIR_SimRoom3_near_AnglA.wav';   % RT:0.7
%        save_dir_i=save_dir_near;
    elseif i==2
        % List of RIRs
        RIR_jam1='./RIR/RIR_SimRoom1_far_AnglA.wav'; % RIR_Ermtg_short_near_AnglA.wav
        RIR_jam2='./RIR/RIR_SimRoom2_far_AnglA.wav';   % RT:0.5
        RIR_jam3='./RIR/RIR_SimRoom3_far_AnglA.wav'; 
%        save_dir_i=save_dir_far;
    end


    fcount=1;    
    rcount=1;
    ncount=1;

    prev_fname='dummy';

    for nlist=1:2
        % Open file list
        eval(['fid=fopen(flist',num2str(nlist),',''r'');']);
        eval(['fidjam=fopen(flistjam',num2str(nlist),',''r'');']);

        while 1

            % Set data file name
            fname=fgetl(fid);
            if ~ischar(fname);
                break;
            end

            fnamejam=fgetl(fidjam);
            if ~ischar(fnamejam);
                fclose(fidjam);
                eval(['fidjam=fopen(flistjam',num2str(nlist),',''r'');']);
                fnamejam=fgetl(fidjam);
            end

            idx1=find(fname=='/');  
            % Make directory if there isn't any
            if ~strcmp(prev_fname,fname(1:idx1(end)))
                mkdir([save_dir_i fname(1:idx1(end))])
   	        if i==1;mkdir([save_dir_cln,fname(1:idx1(end))]);end% make directory for clean wav files
            end
            prev_fname=fname(1:idx1(end));

            % load (sphere format) speech signal 
            x=read_sphere([WSJ_dir_name,'/data/', fname]);
            x=x/(2^15);  % conversion from short-int to float

            xjam=read_sphere([WSJ_dir_name,'/data/', fnamejam]);
            xjam=xjam/(2^15);  % conversion from short-int to float
        
            % load RIR and noise for "THIS" utterance
            eval(['RIR=wavread_gen(RIR_sim',num2str(rcount),');']);
            eval(['NOISE=wavread_gen([noise_sim',num2str(rcount),',''_',num2str(ncount),'.wav'']);']);

            eval(['RIRjam=wavread_gen(RIR_jam',num2str(rcount),');']);

            % Generate 8ch noisy reverberant data        
            [y]=gen_obs_mix(x,RIR,xjam,RIRjam,NOISE,SNRdB,name_rule(1));

            % save reverberant speech y
            y=y/4; % common normalization to all the data to prevent clipping
                   % denominator was decided experimentally

            data_amount(1,rcount)=data_amount(1,rcount)+length(y);

            if 0 
                for ch=1:8 
                  eval(['wavwrite_gen(y(:,',num2str(name_rule(ch)),'),16000,''',save_dir_i fname,'_ch',num2str(ch),'.wav'');'])
                end
            else % save all 8ch data to a single wav file
                wavwrite_gen(y(:,name_rule),16000,[save_dir_i fname '_ch' num2str(1) '.wav']);
            end
            display(['sentence ',num2str(fcount),' (out of 1088) finished! Saved under ',save_dir_i,' (Evaluation test set)'])

            % save clean speech x
            if i==1;
                eval(['wavwrite_gen(x,16000,''',save_dir_cln fname,'.wav'');']);
                display(['sentence ',num2str(fcount),' (out of 1088) finished! Saved under ',save_dir_cln,' (Corresponding clean data)'])
            end

            % rotine to cyclically switch RIRs and noise, utterance by utterance 
            rcount=rcount+1;
            if rcount>num_RIRvar;rcount=1;ncount=ncount+1;name_rule=circshift(name_rule,-1);end
            if ncount>10;ncount=1;end
           
            fcount=fcount+1;
        end
        fclose(fid);
        fclose(fidjam);
    end
end


%%%%
function [y,M]=gen_obs_mix(x,RIR,xjam,RIR_jam,NOISE,SNRdB,ref_ch)
% function to generate noisy reverberant data

x=x';
xjam=xjam';

% calculate direct+early reflection signal for calculating SNR
[val,delay]=max(RIR(:,ref_ch));
before_impulse=floor(16000*0.001);
after_impulse=floor(16000*0.05);
RIR_direct=RIR(delay-before_impulse:delay+after_impulse,ref_ch);
direct_signal=fconv(x,RIR_direct);

% obtain reverberant speech
for ch=1:8
    r1=fconv(x,RIR(:,ch));
    rjam=fconv(xjam,RIR_jam(:,ch));
    if length(r1)>=length(rjam) rjam(end+(1:length(r1)-length(rjam)),1)=0;
    else rjam(length(r1)+1:end)=[];end

    r1tmp(:,ch,1)=r1;
    r1tmp(:,ch,2)=rjam;
    rev_y(:,ch)=r1+rjam;
end

% normalize noise data according to the prefixed SNR value
NOISE=NOISE(1:size(rev_y,1),:);
NOISE_ref=NOISE(:,ref_ch);

iPn = diag(1./mean(NOISE_ref.^2,1));
Px = diag(mean(direct_signal.^2,1));
Msnr = sqrt(10^(-SNRdB/10)*iPn*Px);
scaled_NOISE = NOISE*Msnr;
y = rev_y + scaled_NOISE;
y = y(delay:end,:);
r1tmp=r1tmp(delay:end,:,:);

%%%%
function [x]=read_sphere(fname)
% The function to read a sphere data using NIST w_decode, h_strip.

    tmpfile=['tmp.pcm' num2str(rand(1,1))];
    unix(['./sphere_to_wave.csh ',fname,'.wv1 ' tmpfile]);
    %fd=fopen(tmpfile,'rb',endi);
    fd=fopen(tmpfile,'rb');
    x=fread(fd,[1,inf],'short');
    fclose(fd);
    delete(tmpfile);

%%%%
function [y]=fconv(x, h)
%FCONV Fast Convolution
%   [y] = FCONV(x, h) convolves x and h, and normalizes the output  
%         to +-1.
%
%      x = input vector
%      h = input vector
% 
%      See also CONV
%
%   NOTES:
%
%   1) I have a short article explaining what a convolution is.  It
%      is available at http://stevem.us/fconv.html.
%
%
%Version 1.0
%Coded by: Stephen G. McGovern, 2003-2004.
%
%Copyright (c) 2003, Stephen McGovern
%All rights reserved.
%
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%POSSIBILITY OF SUCH DAMAGE.

Ly=length(x)+length(h)-1;  % 
Ly2=pow2(nextpow2(Ly));    % Find smallest power of 2 that is > Ly
X=fft(x, Ly2);		   % Fast Fourier transform
H=fft(h, Ly2);	           % Fast Fourier transform
Y=X.*H;        	           % 
y=real(ifft(Y, Ly2));      % Inverse fast Fourier transform
y=y(1:1:Ly);               % Take just the first N elements

%%%%
function [y]=wavread_gen(fname)

if exist('wavread')
  y=wavread(fname);
else
  y=audioread(fname);
end

%%%%
function [y]=wavwrite_gen(x,sfreq,fname)

if exist('wavwrite')
  wavwrite(x,sfreq,fname);
else
  audiowrite(fname,x,sfreq);
end
