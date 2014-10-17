% % Tom Crossland and Masood
function [] = runPoisson(sFile,tFile,resultFile)
warning('OFF', 'MATLAB:MKDIR:DirectoryExists');
mkdir('./Images');
mkdir('./Images/Sources');
mkdir('./Images/Targets');
mkdir('./Images/Masks');
mkdir('./Images/Results');
warning('ON', 'MATLAB:MKDIR:DirectoryExists');
if nargin == 0
  imageExtensionsFilter = { ...
    '*.jpg;*.jpeg', 'JPG (*.jpg,*.jpeg)'; ...
    '*.png', 'Portable Network Graphics (*.png)'; ...
    '*.bmp', 'Bitmaps (*.bmp)'};
  
  home = pwd;
  while 1
    cd(home);
    cd './Images/Sources';
    [sfname, spname, ~] = uigetfile(imageExtensionsFilter, 'Source File');
    if isequal(sfname, 0)
      return;
    end
    cd '../Targets';
    [tfname, tpname, ~] = uigetfile(imageExtensionsFilter, 'Target File');
    if isequal(tfname, 0)
      continue;
    end
    cd '../Results';
    [rfname, rpname, ~] = uiputfile(imageExtensionsFilter, 'Result File');
    if isequal(rfname, 0)
      continue;
    end
    break;
  end
  cd '../../';
  
  sFile = fullfile(spname, sfname);
  tFile = fullfile(tpname, tfname);
  resultFile = fullfile(rpname, rfname);
else
  sFile = fullfile('./Images/Sources/', sFile);
  tFile = fullfile('./Images/Targets/', tFile);
end

%Perform selective cut
[source,mask,target,Px,Py,maskedSource,maskedTarget] = selectiveCut(sFile,tFile);

cd('./Images/Masks/');
[~, name, ext] = fileparts(sFile);
imwrite(mask,[name '-mask' ext]);
imwrite(maskedSource,[name '-maskedSource' ext]);
imwrite(maskedTarget,[name '-maskedTarget' ext]);
cd('../../');

%Convert source, mask, and target into double matrices
S = im2double(source);
M = im2double(mask);
T = im2double(target);

%Get the pre-seamless cloning image
fullT = imread(tFile);

[beforeImage] = createBeforeImg(source,mask,fullT,Px,Py,resultFile);
cd('./Images/Results');
[~, name, ext] = fileparts(resultFile);
imwrite(beforeImage,[name '-before' ext]);
cd('../..');

%Perform seamless cloning on significant patch
solR = poissonClone(S(:,:,1),M,T(:,:,1));
solG = poissonClone(S(:,:,2),M,T(:,:,2));
solB = poissonClone(S(:,:,3),M,T(:,:,3));

%Get the post-seamless cloning image
[m n] = size(solR);
fullT(Py:Py+m-1,Px:Px+n-1,1) = uint8(255*solR);
fullT(Py:Py+m-1,Px:Px+n-1,2) = uint8(255*solG);
fullT(Py:Py+m-1,Px:Px+n-1,3) = uint8(255*solB);

%Save post-seamless cloning image
imwrite(fullT,resultFile);
imshow(fullT)