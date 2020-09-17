function Create_REVERB2MIX(REVERB_dir_name, REVERB2MIX_dir_name)
%
% Input variables:
%    WSJ_dir_name: string name of user's clean wsjcam0 corpus directory 
%                  (*Directory structure for wsjcam0 corpus has to be kept 
%                     as it is after obtaining it from LDC. 
%                    Otherwise this script does not work.)
%
%    REVERB_dir_name: string name of user's REVERB challenge corpus directory 
%                  (*Directory structure for wsjcam0 corpus has to be kept 
%                     as it is after obtaining it from LDC. 
%                    Otherwise this script does not work.)
%
% This function generates REVERB-2MIX dataset. The data will be stored under the 
% directory named "REVERB_2MIX".

rev_root=REVERB_dir_name;
revmix_root=REVERB2MIX_dir_name;
rev_conditions = {'real_far_room1','real_near_room1'};

sfreq = 16000;
nMic = 8;

for kk = 1:length(rev_conditions)
  et = read_revmix_scps(['scps_for_genreal/rev2mix/' rev_conditions{kk} '_et']);
  dt = read_revmix_scps(['scps_for_genreal/rev2mix/' rev_conditions{kk} '_dt']);
  K = keys(et{1});
  for ii = 1:length(K)
    akey = K{ii};
    x_et = addwav(readwav(et, akey, rev_root), readwav(dt, akey, rev_root));
    savewav(x_et, [revmix_root et{1}(akey)], sfreq);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%
function wavscp = readscp(scpfile)

fid = fopen(scpfile,'r');

keys = {};
values = {};
while (1)
  l = fgetl(fid);
  if ~ischar(l) break;end
  ll = strsplit0(l);
  keys{end+1} = ll{1};
  values{end+1} = ll{2};
end
fclose(fid);
  
wavscp = containers.Map(keys, values);

%%%%%%%%%%%%%%%%%%%%%%%%%
function scps = read_revmix_scps(scp)

scps={};
nMic=8;
for ii=1:nMic
 scps{ii} = readscp([scp '_ch' num2str(ii) '.scp']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%
function x = readwav(wavscps, akey, rootdir)

x = soundread([rootdir wavscps{1}(akey)]);
xlen = length(x);
for ii=2:length(wavscps)
  x = [x soundread([rootdir wavscps{ii}(akey)])];
end

function x = soundread(fname)
if exist('audioread')
  x = audioread(fname);
else
  x = wavread(fname);
end

%%%%%%%%%%%%%%%%%%%%%%%%%
function x_et = addwav(x_et, x_dt)
if length(x_et) > length(x_dt)
  x_et(1:length(x_dt),:) = x_et(1:length(x_dt),:) + x_dt;
else
  x_et = x_et + x_dt(1:length(x_et),:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%
function savewav(x, fname, sfreq)

fprintf(1,'Saving %s\n', fname);
path = fileparts(fname);
if isempty(dir(path))
  mkdir(path);
end
if exist('audiowrite')
  audiowrite(fname, x, sfreq);
else
  wavwrite(x, sfreq, fname);
end

%%%%%%%%%%%%%%%%%%%%%%%%%
function l=strsplit0(astr)

if exist('strsplit')
  l=strsplit(astr);
else
  l={};
  in=0;
  for ii=1:length(astr)
    if in == 0 & astr(ii) ~= ' '
       st = ii;
       in = 1;
    elseif in == 1 & astr(ii) == ' '
      l{end+1} = astr(st:ii-1);
      in = 0;
    end
  end

  if in == 1
      l{end+1} = astr(st:end);
  end
end
