function SelectTarget(wavscp_dir,enh1_dir,enh2_dir,REVERB_dir,out_dir)
%
% A sample matlab code, SelectTarget.m, for selecting enhanced signals to be evaluated.
% You can use the code, for example, as:
%
% >> wavscp_dir = './REVERB_2MIX/scps/';
% >> enh1_dir = 'path_to_enh1_dir';
% >> enh2_dir = 'path_to_enh2_dir';
% >> REVERB_dir = 'path_to_REVERB_Challenge_dataset_dir';
% >> out_dir = 'path_to_output_dir';
% >> SelectTarget(wavscp_dir, enh1_dir, enh2_dir, REVERB_dir_name, output_dir);
%
% wavscp_dir: a path to the scp files
% enh1_dir and enh2_dir: pathes to directories of the two enhanced signals
% REVERB_dir : a path to your REVERB Challenge dataset directory
% out_dir :  a path to a directory that stores selected enhanced signals
%
% It is assumed that each signal is located under enh1_dir, enh2_dir, REVERB_dir, and out_dir 
% according to the relative pathes specified in the scp files.
%
% The code assumes that the enhanced signals and the original signal are exactly time aligned. 
% In addition, to improve the accuracy of selection, it is recommeneded to denoise and 
% dereverberate the original signals in the REVERB Eval set in advance using a similar algorithm 
% as one that you use to obtain the enhanced signals from REVERB-2MIX.
%

wavscp_dir=addslash(wavscp_dir);
enh1_dir=addslash(enh1_dir);
enh2_dir=addslash(enh2_dir);
REVERB_dir=addslash(REVERB_dir);
out_dir=addslash(out_dir);

scp={'RealData_et_for_8ch_near_room1_wav.scp',...
     'RealData_et_for_8ch_far_room1_wav.scp',...
     'SimData_et_for_8ch_near_room1_wav.scp',...
     'SimData_et_for_8ch_far_room1_wav.scp',...
     'SimData_et_for_8ch_near_room2_wav.scp',...
     'SimData_et_for_8ch_far_room2_wav.scp',...
     'SimData_et_for_8ch_near_room3_wav.scp',...
     'SimData_et_for_8ch_far_room3_wav.scp'};

for ii=1:length(scp)

  fid=fopen([wavscp_dir scp{ii}]);
  while (1)
    ll=fgetl(fid);
    if ~ischar(ll) break;end

    l=strsplit(ll);

    enh1=wavread_gen([enh1_dir l{2}]);
    enh2=wavread_gen([enh2_dir l{2}]);
    orig=wavread_gen([REVERB_dir l{2}]);

    enh=Select(enh1,enh2,orig);

    outfile=[out_dir l{2}];
    outd=fileparts(outfile);
    d=dir(outd);

    if isempty(d) mkdir(outd);end
    wavwrite_gen(enh,16000,outfile);

  end
end

%%%%%%%%%%%%%
function z=Select(enh1,enh2,orig)

nSig=2;
len=min([length(enh1) length(enh2) length(orig)]);

y=[enh1(1:len,1) enh2(1:len,1)];
x=orig(1:len,1);

for nn=1:nSig
  xycor(nn)=sum(x.*y(:,nn))/sqrt(sum(x.^2)*sum(y(:,nn).^2));
end

[a,b]=max(xycor);
if b==1 z=enh1;else z=enh2;end

%%%%
function dirname=addslash(dirname)

if dirname(end) ~= '/' 
  dirname(end+1)='/';
end

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
