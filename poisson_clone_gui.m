function varargout = poisson_clone_gui(varargin)
% POISSON_CLONE_GUI MATLAB code for poisson_clone_gui.fig
%      POISSON_CLONE_GUI, by itself, creates a new POISSON_CLONE_GUI or raises the existing
%      singleton*.
%
%      H = POISSON_CLONE_GUI returns the handle to a new POISSON_CLONE_GUI or the handle to
%      the existing singleton*.
%
%      POISSON_CLONE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POISSON_CLONE_GUI.M with the given input arguments.
%
%      POISSON_CLONE_GUI('Property','Value',...) creates a new POISSON_CLONE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before poisson_clone_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to poisson_clone_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help poisson_clone_gui

% Last Modified by GUIDE v2.5 02-May-2011 16:15:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @poisson_clone_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @poisson_clone_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function set_status(str)
global HANDLES;
set(HANDLES.status_text, 'String', str);

function [pos] = modal_area_position(handles, units)
if nargin == 1
  units = 'pixels';
end
set(handles.poisson_clone_figure, 'Units', units);
figpos = get(handles.poisson_clone_figure, 'Position');
set(handles.modal_panel, 'Units', units);
modal_panel_pos = get(handles.modal_panel, 'Position');
fig_x_dim = figpos(3);
fig_y_dim = figpos(4);
base_y = modal_panel_pos(4) + modal_panel_pos(2);
working_x_dim = fig_x_dim;
working_y_dim = fig_y_dim - base_y;
pos = [0, base_y, working_x_dim, working_y_dim];

% --- Executes just before poisson_clone_gui is made visible.
function poisson_clone_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to poisson_clone_gui (see VARARGIN)

% Choose default command line output for poisson_clone_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes poisson_clone_gui wait for user response (see UIRESUME)
% uiwait(handles.poisson_clone_figure);
global HANDLES; % to only be used in non-callback functions
global PROCESS;
HANDLES = handles;
PROCESS = poisson_clone_process();

set(handles.options_panel, 'Visible', 'off');
set(handles.result_panel, 'Visible', 'off');
set(handles.target_panel, 'Visible', 'off');
set(handles.source_panel, 'Visible', 'on');
set_status('Ready');


% --- Outputs from this function are returned to the command line.
function varargout = poisson_clone_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when poisson_clone_figure is resized.
function poisson_clone_figure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to poisson_clone_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
units = 'characters';
set(hObject, 'Units', units);
figpos = get(hObject, 'Position');
set(handles.status_text, 'Units', units);
set(handles.modal_panel, 'Units', units);
set(handles.status_text, 'Position', [0, 0, figpos(3), 1]);
set(handles.modal_panel, 'Position', [0, 1, figpos(3), 2]);
% make sure to call modal_area_position AFTER resizing the pre-modal area
modalpos = modal_area_position(handles, units);
set(handles.source_panel, 'Units', units);
set(handles.source_panel, 'Position', modalpos);
set(handles.target_panel, 'Units', units);
set(handles.target_panel, 'Position', modalpos);
set(handles.result_panel, 'Units', units);
set(handles.result_panel, 'Position', modalpos);
set(handles.options_panel, 'Units', units);
set(handles.options_panel, 'Position', modalpos);

% --- Executes when source_panel is resized.
function source_panel_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to source_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Units', 'characters');
pos = get(hObject, 'Position');
set(handles.browse_source_button, 'Units', 'characters');
set(handles.source_filename_text, 'Units', 'characters');
set(handles.select_source_button, 'Units', 'characters');
set(handles.source_axes, 'Units', 'characters');
set(handles.select_source_button, 'Position', [0, 0, 8, 1]);
set(handles.browse_source_button, 'Position', [8, 0, 8, 1]);
set(handles.source_filename_text, 'Position', [16, 0, pos(3) - 16, 1]);
set(handles.source_axes, 'Position', [0, 1, pos(3), pos(4)-1]);


% --- Executes on button press in browse_source_button.
function browse_source_button_Callback(hObject, eventdata, handles)
% hObject    handle to browse_source_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PROCESS;
set_status('Browsing for source image file...');
while 1
  home = pwd;
  if exist('./Images/Sources', 'file') == 7
    cd('./Images/Sources');
  end
  filterspec = {'*.jpg;*.jpeg', 'Jpeg (*.jpg)'; ...
    '*.png', 'Portable Network Graphics (*.png)'; ...
    '*.bmp', 'Bitmap (*.bmp)'};
  [fname, pname, ~] = uigetfile(filterspec, 'Source Image');
  cd(home);
  if isequal(fname, 0) || isequal(pname, 0)
    break;
  end
  PROCESS.source_filename = fullfile(pname, fname);
  PROCESS.source_image = imread(PROCESS.source_filename);
  ax = handles.source_axes;
  cla(ax);
  hold(ax, 'on');
  imshow(PROCESS.source_image, 'Parent', ax);
  set(handles.source_filename_text, 'String', PROCESS.source_filename);
  break;
end
set_status('Ready');


% --- Executes when target_panel is resized.
function target_panel_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to target_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Units', 'characters');
pos = get(hObject, 'Position');
set(handles.browse_target_button, 'Units', 'characters');
set(handles.target_filename_text, 'Units', 'characters');
set(handles.select_target_button, 'Units', 'characters');
set(handles.select_target_button, 'Position', [0, 0, 8, 1]);
set(handles.browse_target_button, 'Position', [8, 0, 8, 1]);
set(handles.target_filename_text, 'Position', [16, 0, pos(3) - 16, 1]);

set(handles.source_angle_on_target_text, 'Units', 'characters');
set(handles.source_scale_on_target_text, 'Units', 'characters');
set(handles.source_angle_on_target_slider, 'Units', 'characters');
set(handles.source_scale_on_target_slider, 'Units', 'characters');
set(handles.source_flip_on_target_toggle, 'Units', 'characters');

set(handles.source_angle_on_target_text, 'Position', [pos(3)-8, pos(4)-2, 4, 1]);
set(handles.source_scale_on_target_text, 'Position', [pos(3)-4, pos(4)-2, 4, 1]);
set(handles.source_angle_on_target_slider, 'Position', [pos(3)-8, 3, 4, pos(4)-5]);
set(handles.source_scale_on_target_slider, 'Position', [pos(3)-4, 3, 4, pos(4)-5]);
set(handles.source_flip_on_target_toggle, 'Position', [pos(3)-8, 1, 8, 2]);

set(handles.target_axes, 'Units', 'characters');
set(handles.target_axes, 'Position', [0, 1, pos(3) - 8, pos(4)-1]);

% --- Executes on button press in browse_target_button.
function browse_target_button_Callback(hObject, eventdata, handles)
% hObject    handle to browse_target_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PROCESS;
set_status('Browsing for target image file...');
while 1
  home = pwd;
  if exist('./Images/Targets', 'file') == 7
    cd('./Images/Targets');
  end
  filterspec = {'*.jpg;*.jpeg', 'Jpeg (*.jpg)'; ...
    '*.png', 'Portable Network Graphics (*.png)'; ...
    '*.bmp', 'Bitmap (*.bmp)'};
  [fname, pname, ~] = uigetfile(filterspec, 'Target Image');
  cd(home);
  if isequal(fname, 0) || isequal(pname, 0)
    break;
  end
  PROCESS.target_filename = fullfile(pname, fname);
  PROCESS.target_image = imread(PROCESS.target_filename);
  ax = handles.target_axes;
  cla(ax);
  hold(ax, 'on');
  imshow(PROCESS.target_image, 'Parent', ax);
  set(handles.target_filename_text, 'String', PROCESS.target_filename);
  break;
end
set_status('Ready');

% --- Executes when selected object is changed in modal_panel.
function modal_panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in modal_panel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.OldValue, 'String')
  case 'Source'
    set(handles.source_panel, 'Visible', 'off');
  case 'Target'
    set(handles.target_panel, 'Visible', 'off');
  case 'Result'
    set(handles.result_panel, 'Visible', 'off');
  case 'Options'
    set(handles.options_panel, 'Visible', 'off');
end
switch get(eventdata.NewValue, 'String')
  case 'Source'
    set(handles.source_panel, 'Visible', 'on');
  case 'Target'
    set(handles.target_panel, 'Visible', 'on');
  case 'Result'
    set(handles.result_panel, 'Visible', 'on');
  case 'Options'
    set(handles.options_panel, 'Visible', 'on');
end

% --- Executes when result_panel is resized.
function result_panel_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to result_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Units', 'characters');
pos = get(hObject, 'Position');
set(handles.save_result_button, 'Units', 'characters');
set(handles.calculate_result_button, 'Units', 'characters');
set(handles.result_axes, 'Units', 'characters');
set(handles.calculate_result_button, 'Position', [0, 0, 12, 1]);
set(handles.save_result_button, 'Position', [12, 0, 6, 1]);
set(handles.result_axes, 'Position', [0, 1, pos(3), pos(4)-1]);


% --- Executes on button press in save_result_button.
function save_result_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_result_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PROCESS;
if isempty(PROCESS.result_image)
  uiwait(msgbox('Haven''t calculated a result yet!'));
  return;
end
set_status('Browsing for save filename of result image.');
while 1
  home = pwd;
  if exist('./Images/Results', 'file') == 7
    cd('./Images/Results');
  end
  filterspec = {'*.jpg;*.jpeg', 'Jpeg (*.jpg)'; ...
    '*.png', 'Portable Network Graphics (*.png)'; ...
    '*.bmp', 'Bitmap (*.bmp)'};
  [fname, pname, ~] = uiputfile(filterspec, 'Save Seamless Cloning Result');
  if isequal(fname, 0) || isequal(pname, 0)
    break;
  end
  cd(home);
  savename = fullfile(pname, fname);
  imwrite(PROCESS.result_image, savename);
  
  if get(handles.option_save_vanilla_clone_check, 'Value')
    im = PROCESS.clone(0);
    [p, n, ext] = fileparts(savename);
    imwrite(im, fullfile(p, [n get(handles.option_save_vanilla_clone_extension_text, 'String') ext]));
  end
  break;
end
cd(home);
set_status('Ready');

% --- Executes on button press in select_source_button.
function select_source_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_source_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PROCESS;
if isempty(PROCESS.source_image)
  uiwait(msgbox('Select a source image before creating masks!'));
  return;
end
set_status('Selecting mask pixels.');
ax = handles.source_axes;
cla(ax);
imshow(PROCESS.source_image, 'Parent', ax);
draw = imfreehand(ax);
mask = draw.createMask();
delete(draw);
mbounds = bwboundaries(mask);
ijbounds = mbounds{1};
i = ijbounds(:,1);
j = ijbounds(:,2);
[row,col] = find(mask);
PROCESS.mask_ij_source_base = [min(row)-1 min(col)-1];
PROCESS.mask = mask(min(row)-1:max(row)+1,min(col)-1:max(col)+1);
plot(ax, j, i, 'Color', [0 0 0]);
set_status('Ready');


% --- Executes on button press in select_target_button.
function select_target_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_target_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PROCESS;
if isempty(PROCESS.target_image)
  uiwait(msgbox('Select a target image!'));
  return;
elseif isempty(PROCESS.source_image)
  uiwait(msgbox('You haven''t selected a source image yet!'));
  return;
elseif isempty(PROCESS.mask) || isempty(PROCESS.mask_ij_source_base)
  uiwait(msgbox('You haven''t selected a mask for the source yet!'));
  return;
end
set_status(['Selecting target cloning location. ' ...
  'First point determines center position of the mask, ' ...
  'second (optional) flips the image left/right if to the left of the first point, ' ...
  'third (optional) determines rotation relative to the X-axis, ' ...
  'fourth (optional) determines scaling relative to 1/10th the length of the target image diagonal.']);
ax = handles.target_axes;
cla(ax);
imshow(PROCESS.target_image, 'Parent', ax);
[jpts,ipts] = getpts(ax);
if length(ipts) >= 2
  PROCESS.source_flip_on_target = jpts(2) < jpts(1);
end
if length(ipts) >= 3
  theta = atan2(ipts(3) - ipts(2), jpts(3) - jpts(2));
  PROCESS.source_angle_on_target = theta;
else
  PROCESS.source_angle_on_target = 0;
end
if length(ipts) >= 4
  set(handles.poisson_clone_figure, 'Units', 'pixels');
  figpos = get(handles.poisson_clone_figure, 'Position');
  nrm = norm(figpos(3:4)) * 0.1;
  PROCESS.source_scale_on_target = norm([ipts(4) - ipts(3), jpts(4) - jpts(3)]) / nrm;
else
  PROCESS.source_scale_on_target = 1;
end
mask_center = [ipts(1) jpts(1)];
i = round(mask_center(1) - size(PROCESS.mask,1)/2);
j = round(mask_center(2) - size(PROCESS.mask,2)/2);
PROCESS.mask_ij_target_base = [i, j];
redraw_target(ax)
try
  redraw_target(ax);
catch exobj
  set_status('Could not place image. You probably put the mask somewhere you shouldn''t have.');
  pause(5);
  PROCESS.mask_ij_target_base = [];
  return;
end
set_status('Ready');

function redraw_target(ax)
global PROCESS;
R = PROCESS.clone(0);
cla(ax);
imshow(R, 'Parent', ax);

% --- Executes on button press in calculate_result_button.
function calculate_result_button_Callback(hObject, eventdata, handles)
% hObject    handle to calculate_result_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PROCESS;
if isempty(PROCESS.source_image) || isempty(PROCESS.mask) || isempty(PROCESS.mask_ij_source_base) ...
    || isempty(PROCESS.target_image) || isempty(PROCESS.mask_ij_target_base)
  uiwait(msgbox('Go back and finish setting up!'));
  return;
end
set_status('Calculating cloning...');
PROCESS.poisson_clone(1);
ax = handles.result_axes;
hold(ax, 'on');
cla(ax);
imshow(PROCESS.result_image, 'Parent', ax);
set_status('Ready');


% --- Executes on button press in option_save_seamless_clone_check.
function option_save_seamless_clone_check_Callback(hObject, eventdata, handles)
% hObject    handle to option_save_seamless_clone_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of option_save_seamless_clone_check


% --- Executes on button press in option_save_vanilla_clone_check.
function option_save_vanilla_clone_check_Callback(hObject, eventdata, handles)
% hObject    handle to option_save_vanilla_clone_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of option_save_vanilla_clone_check



function option_save_vanilla_clone_extension_text_Callback(hObject, eventdata, handles)
% hObject    handle to option_save_vanilla_clone_extension_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of option_save_vanilla_clone_extension_text as text
%        str2double(get(hObject,'String')) returns contents of option_save_vanilla_clone_extension_text as a double


% --- Executes during object creation, after setting all properties.
function option_save_vanilla_clone_extension_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to option_save_vanilla_clone_extension_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function source_angle_on_target_text_Callback(hObject, eventdata, handles)
% hObject    handle to source_angle_on_target_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of source_angle_on_target_text as text
%        str2double(get(hObject,'String')) returns contents of source_angle_on_target_text as a double


% --- Executes during object creation, after setting all properties.
function source_angle_on_target_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source_angle_on_target_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function source_scale_on_target_text_Callback(hObject, eventdata, handles)
% hObject    handle to source_scale_on_target_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of source_scale_on_target_text as text
%        str2double(get(hObject,'String')) returns contents of source_scale_on_target_text as a double


% --- Executes during object creation, after setting all properties.
function source_scale_on_target_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source_scale_on_target_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in source_flip_on_target_toggle.
function source_flip_on_target_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to source_flip_on_target_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of source_flip_on_target_toggle
global PROCESS;
PROCESS.source_flip_on_target = get(hObject,'Value');
if ~isempty(PROCESS.mask) && ~isempty(PROCESS.mask_ij_target_base) && ~isempty(PROCESS.source_image) && ~isempty(PROCESS.target_image)
  try
    redraw_target(handles.target_axes);
  catch
    uiwait(msgbox('Ooops!'));
  end
end

% --- Executes on slider movement.
function source_angle_on_target_slider_Callback(hObject, eventdata, handles)
% hObject    handle to source_angle_on_target_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global PROCESS;
ang = get(hObject,'Value') / (get(hObject,'Max') - get(hObject,'Min')) * 2 * pi;
PROCESS.source_angle_on_target = ang;
set(handles.source_angle_on_target_text, 'String', num2str(round(radtodeg(ang))));
if ~isempty(PROCESS.mask) && ~isempty(PROCESS.mask_ij_target_base) && ~isempty(PROCESS.source_image) && ~isempty(PROCESS.target_image)
  try
    redraw_target(handles.target_axes);
  catch
    uiwait(msgbox('Ooops!'));
  end
end

% --- Executes during object creation, after setting all properties.
function source_angle_on_target_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source_angle_on_target_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function source_scale_on_target_slider_Callback(hObject, eventdata, handles)
% hObject    handle to source_scale_on_target_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global PROCESS;
scl = get(hObject,'Value') / (get(hObject,'Max') - get(hObject,'Min')) * 5;
PROCESS.source_scale_on_target = scl;
set(handles.source_scale_on_target_text, 'String', num2str(scl));
if ~isempty(PROCESS.mask) && ~isempty(PROCESS.mask_ij_target_base) && ~isempty(PROCESS.source_image) && ~isempty(PROCESS.target_image)
  try
    redraw_target(handles.target_axes);
  catch
    uiwait(msgbox('Ooops!'));
  end
end

% --- Executes during object creation, after setting all properties.
function source_scale_on_target_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source_scale_on_target_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
