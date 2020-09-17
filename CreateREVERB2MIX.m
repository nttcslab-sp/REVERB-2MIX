function CreateREVERB2MIX(WSJ_dir, REVERB_dir)
%
% Input variables:
%    WSJ_dir: string name of user's clean wsjcam0 corpus directory 
%             (*Directory structure for wsjcam0 corpus has to be kept 
%               as it is after obtaining it from LDC. 
%               Otherwise this script does not work.)
%
%    REVERB_dir: string name of user's REVERB challenge corpus directory 
%                (*Directory structure for wsjcam0 corpus has to be kept 
%                  as it is after obtaining it from LDC. 
%                  Otherwise this script does not work.)
%
% This function generates REVERB-2MIX dataset. The data will be stored under the 
% directory named "REVERB_2MIX".

WSJ_dir=addslash(WSJ_dir);
REVERB_dir=addslash(REVERB_dir);

REVERB2MIX_dir = './REVERB_2MIX/';

display(['Name of directory for original WSJCAM0: ',WSJ_dir])
display(['Name of directory for original REVERB: ',REVERB_dir])

orig_Generate_dir=[REVERB_dir '/reverb_tools_for_Generate_SimData/'];
create_link(orig_Generate_dir,'sphere_to_wave.csh');
create_link(orig_Generate_dir,'read_sphere.m');
create_link(orig_Generate_dir,'NOISE');
create_link(orig_Generate_dir,'RIR');
create_link(orig_Generate_dir,'bin');
create_link(orig_Generate_dir,'etc');

%Generate_realDataMix_et(REVERB_dir, REVERB2MIX_dir);
%Generate_simuDataMix_et(WSJ_dir, REVERB2MIX_dir);

%%%%
function create_link(rootdir, fname)

d=dir(fname);
if ~isempty(d) system(['rm -i ' fname]);end
%system(['ln -s ' rootdir fname ' .']);

%%%%
function dirname=addslash(dirname)

if dirname(end) ~= '/' 
  dirname(end+1)='/';
end
