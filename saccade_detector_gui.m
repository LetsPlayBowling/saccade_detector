function varargout = saccade_detector_gui(varargin)
% SACCADE_DETECTOR_GUI MATLAB code for saccade_detector_gui.fig
%      SACCADE_DETECTOR_GUI, by itself, creates a new SACCADE_DETECTOR_GUI or raises the existing
%      singleton*.
%
%      H = SACCADE_DETECTOR_GUI returns the handle to a new SACCADE_DETECTOR_GUI or the handle to
%      the existing singleton*.
%
%      SACCADE_DETECTOR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SACCADE_DETECTOR_GUI.M with the given input arguments.
%
%      SACCADE_DETECTOR_GUI('Property','Value',...) creates a new SACCADE_DETECTOR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before saccade_detector_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to saccade_detector_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help saccade_detector_gui

% Last Modified by GUIDE v2.5 01-Nov-2019 22:15:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @saccade_detector_gui_OpeningFcn, ...
    'gui_OutputFcn',  @saccade_detector_gui_OutputFcn, ...
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


% --- Executes just before saccade_detector_gui is made visible.
function saccade_detector_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to saccade_detector_gui (see VARARGIN)

% Choose default command line output for saccade_detector_gui
handles.output = hObject;

% fill the current directory to the 'CurrentPathEditBar'
handles.cur_path_str = pwd;
set(handles.CurrentPathEditBar,'String',handles.cur_path_str);

cla(handles.plot_ax_2d);
cla(handles.plot_v_t);
cla(handles.plot_x_t);
cla(handles.plot_y_t);
set(handles.PromptMessageText1,'String','>>>> ...');
set(handles.PromptMessageText2,'String','>>>> ...');
set(handles.PromptMessageText3,'String','>>>> ...');

handles.saccade_info = [];
handles.velocity_xy = [];
handles.eyetrace = [];
handles.cut_eye_trace = [];

% default parameters
handles.fill_missing_data = false;
handles.smoothen = true;
handles.SamplingRate = 1000; % hz
handles.fix_vel_thres = 30; % degree/sec
handles.lambda = 5.5;
handles.combine_intv_thres = 20;% ms
handles.saccade_dur_thres = 5; % ms
handles.saccade_amp_thres = 0.2; % degree
handles.StartPoint = 1;
handles.textnnn = 'end';
set(handles.SamplingRate_EditBar,'String',num2str(handles.SamplingRate));
set(handles.fix_vel_thres_EditBar,'String',num2str(handles.fix_vel_thres));
set(handles.lambda_EditBar,'String',num2str(handles.lambda));
set(handles.combine_intv_thres_EditBar,'String',num2str(handles.combine_intv_thres));
set(handles.saccade_dur_thres_EditBar,'String',num2str(handles.saccade_dur_thres));
set(handles.saccade_amp_thres_EditBar,'String',num2str(handles.saccade_amp_thres));
set(handles.StartPoint_EditBar,'String',num2str(handles.StartPoint));
set(handles.EndPoint_EditBar,'String',handles.textnnn);

% make logo area object's  X Y axes visible
logo_img = imread('RaysLogo.bmp');
handles.logo_image = image(handles.logo_area,logo_img);
handles.logo_area.XAxis.Visible = 'off';
handles.logo_area.YAxis.Visible = 'off';

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes saccade_detector_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = saccade_detector_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in ChooseEyeData.
function ChooseEyeData_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseEyeData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try 
[file,handles.path] = uigetfile('','Choose TrialRecord file');
handles.cur_path_str = [handles.path,'\',file];
handles.CurrentPathEditBar.String = handles.cur_path_str;
handles.eyetrace = get_var_via_load(handles.cur_path_str);
handles.cut_eye_trace = handles.eyetrace;
CheckDataResult = CheckInputData(hObject,eventdata,handles);
if CheckDataResult
    handles.prompt_msg_line = ['>>>> TrialRecord file "',file, '" is loaded.'];
    guidata(hObject,handles);
    update_prompt_msg(hObject, eventdata, handles);
    handles.prompt_msg_line = ('>>>> Ploting eyetrace points...');
    guidata(hObject,handles);
    update_prompt_msg(hObject, eventdata, handles);
    plot_eyetrace_period(hObject,eventdata,handles);
    guidata(hObject,handles);
end
catch ME %#ok<NASGU>
    handles.cur_path_str = pwd;
    set(handles.CurrentPathEditBar,'String',handles.cur_path_str);
    handles.prompt_msg_line = '>>>> Error: Please load appropriate data.';
    guidata(hObject,handles);
    update_prompt_msg(hObject, eventdata, handles);
end



function StartPoint_EditBar_Callback(hObject, eventdata, handles)
% hObject    handle to StartPoint_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartPoint_EditBar as text
%        str2double(get(hObject,'String')) returns contents of StartPoint_EditBar as a double
if handles.eyetrace
    StartPoint = str2double(handles.StartPoint_EditBar.String);
    if StartPoint < 1 || StartPoint > (size(handles.eyetrace,1) - 10)
        handles.prompt_msg_line = '>>>> ERROR: Invalid StartPoint number.';
        guidata(hObject,handles);
        update_prompt_msg(hObject, eventdata, handles);
    else
        handles.prompt_msg_line = ...
            ['>>>> Set Cutting StartPoint value to ', handles.StartPoint_EditBar.String,'.'];
        guidata(hObject,handles);
        update_prompt_msg(hObject, eventdata, handles);
        handles.StartPoint = round(StartPoint);
        guidata(hObject,handles);
        plot_eyetrace_period(hObject,eventdata,handles)
        cla(handles.plot_v_t);
    end
else
    set(handles.StartPoint_EditBar,'String','1');
    handles.prompt_msg_line = '>>>> ERROR: Please load data firstly.';
    guidata(hObject,handles);
    update_prompt_msg(hObject, eventdata, handles);
end

% --- Executes during object creation, after setting all properties.
function StartPoint_EditBar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartPoint_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EndPoint_EditBar_Callback(hObject, eventdata, handles)
% hObject    handle to textnnn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textnnn as text
%        str2double(get(hObject,'String')) returns contents of textnnn as a double
if handles.eyetrace
    EndPoint = str2double(get(hObject,'String'));
    if EndPoint <= handles.StartPoint || EndPoint > size(handles.eyetrace,1)
        handles.prompt_msg_line = '>>>> ERROR: Invalid EndPoint number.';
        guidata(hObject,handles);
        update_prompt_msg(hObject, eventdata, handles);
    else
        handles.prompt_msg_line = ...
            ['>>>> Set Cutting EndPoint value to ',get(hObject,'String'),'.'];
        guidata(hObject,handles);
        update_prompt_msg(hObject, eventdata, handles);
        handles.textnnn = round(EndPoint);
        guidata(hObject,handles);
        plot_eyetrace_period(hObject,eventdata,handles)
        cla(handles.plot_v_t);
    end
else
    set(handles.textnnn,'String','end');
    handles.prompt_msg_line = '>>>> ERROR: Please load data firstly.';
    guidata(hObject,handles);
    update_prompt_msg(hObject, eventdata, handles);
end

    

% --- Executes during object creation, after setting all properties.
function textnnn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textnnn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SamplingRate_EditBar_Callback(hObject, eventdata, handles)
% hObject    handle to SamplingRate_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SamplingRate_EditBar as text
%        str2double(get(hObject,'String')) returns contents of SamplingRate_EditBar as a double
handles.SamplingRate = str2double(handles.SamplingRate_EditBar.String);
handles.prompt_msg_line = ...
    ['>>>> Set SamplingRate value to ', handles.SamplingRate_EditBar.String,'.'];
guidata(hObject,handles);
update_prompt_msg(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function SamplingRate_EditBar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SamplingRate_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fix_vel_thres_EditBar_Callback(hObject, eventdata, handles)
% hObject    handle to fix_vel_thres_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fix_vel_thres_EditBar as text
%        str2double(get(hObject,'String')) returns contents of fix_vel_thres_EditBar as a double
handles.fix_vel_thres = str2double(handles.fix_vel_thres_EditBar.String);
handles.prompt_msg_line = ...
    ['>>>> Set fix_vel_thres value to ', handles.fix_vel_thres_EditBar.String,'.'];
guidata(hObject,handles);
update_prompt_msg(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function fix_vel_thres_EditBar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fix_vel_thres_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lambda_EditBar_Callback(hObject, eventdata, handles)
% hObject    handle to lambda_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lambda_EditBar as text
%        str2double(get(hObject,'String')) returns contents of lambda_EditBar as a double
handles.lambda = str2double(handles.lambda_EditBar.String);
handles.prompt_msg_line = ...
    ['>>>> Set lambda value to ', handles.lambda_EditBar.String,'.'];
guidata(hObject,handles);
update_prompt_msg(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function lambda_EditBar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lambda_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function combine_intv_thres_EditBar_Callback(hObject, eventdata, handles)
% hObject    handle to combine_intv_thres_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of combine_intv_thres_EditBar as text
%        str2double(get(hObject,'String')) returns contents of combine_intv_thres_EditBar as a double
handles.combine_intv_thres = str2double(handles.combine_intv_thres_EditBar.String);
handles.prompt_msg_line = ...
    ['>>>> Set combine_intv_thres value to ', handles.combine_intv_thres_EditBar.String,'.'];
guidata(hObject,handles);
update_prompt_msg(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function combine_intv_thres_EditBar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to combine_intv_thres_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function saccade_dur_thres_EditBar_Callback(hObject, eventdata, handles)
% hObject    handle to saccade_dur_thres_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of saccade_dur_thres_EditBar as text
%        str2double(get(hObject,'String')) returns contents of saccade_dur_thres_EditBar as a double
handles.saccade_dur_thres = str2double(handles.saccade_dur_thres_EditBar.String);
handles.prompt_msg_line = ...
    ['>>>> Set saccade_dur_thres value to ', handles.saccade_dur_thres_EditBar.String,'.'];
guidata(hObject,handles);
update_prompt_msg(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function saccade_dur_thres_EditBar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saccade_dur_thres_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function saccade_amp_thres_EditBar_Callback(hObject, eventdata, handles)
% hObject    handle to saccade_amp_thres_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of saccade_amp_thres_EditBar as text
%        str2double(get(hObject,'String')) returns contents of saccade_amp_thres_EditBar as a double
handles.saccade_amp_thres = str2double(handles.saccade_amp_thres_EditBar.String);
handles.prompt_msg_line = ...
    ['>>>> Set saccade_amp_thres value to ', handles.saccade_amp_thres_EditBar.String,'.'];
guidata(hObject,handles);
update_prompt_msg(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function saccade_amp_thres_EditBar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saccade_amp_thres_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Save_Button.
function Save_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = pwd;
parameters = struct(...
    'fill_missing_data', handles.fill_missing_data,...
    'smoothen', handles.smoothen,...
    'SamplingRate',handles.SamplingRate,...
    'fix_vel_thres',handles.fix_vel_thres,...
    'lambda',handles.lambda,...
    'combine_intv_thres',handles.combine_intv_thres,...
    'saccade_dur_thres',handles.saccade_dur_thres,...
    'saccade_amp_thres',handles.saccade_amp_thres);
detection_results = struct('saccade_info',handles.saccade_info,'parameters',parameters);
save([path,'\detection_results.mat'],'detection_results');
handles.prompt_msg_line = ...
    ('>>>> Save detection results and parameters in whole data.');
guidata(hObject,handles);
update_prompt_msg(hObject, eventdata, handles);

% --- Executes on button press in Clear_Button.
function Clear_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.plot_ax_2d);
cla(handles.plot_v_t);
cla(handles.plot_x_t);
cla(handles.plot_y_t);
handles.eyetrace = [];
handles.cut_eye_trace = [];
handles.saccade_info = [];
% fill the current directory to the 'CurrentPathEditBar'
handles.cur_path_str = pwd;
set(handles.CurrentPathEditBar,'String',handles.cur_path_str);
set(handles.StartPoint_EditBar,'String','1');
set(handles.EndPoint_EditBar,'String','end');
handles.prompt_msg_line = '>>>> Clear all axes and loaded data.';
guidata(hObject,handles);
update_prompt_msg(hObject, eventdata, handles);

% --- Executes on button press in ResetPara_Button.
function ResetPara_Button_Callback(hObject, eventdata, handles)
% hObject    handle to ResetPara_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.fill_missing_data = false;
handles.smoothen = true;
handles.SamplingRate = 1000; % hz
handles.fix_vel_thres = 30; % degree/sec
handles.lambda = 5.5;
handles.combine_intv_thres = 20;% ms
handles.saccade_dur_thres = 5; % ms
handles.saccade_amp_thres = 0.2; % degree
set(handles.SamplingRate_EditBar,'String',num2str(handles.SamplingRate));
set(handles.fix_vel_thres_EditBar,'String',num2str(handles.fix_vel_thres));
set(handles.lambda_EditBar,'String',num2str(handles.lambda));
set(handles.combine_intv_thres_EditBar,'String',num2str(handles.combine_intv_thres));
set(handles.saccade_dur_thres_EditBar,'String',num2str(handles.saccade_dur_thres));
set(handles.saccade_amp_thres_EditBar,'String',num2str(handles.saccade_amp_thres));
handles.prompt_msg_line = '>>>> Reset all parameters to default values.';
guidata(hObject,handles);
update_prompt_msg(hObject, eventdata, handles);


function CurrentPathEditBar_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentPathEditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CurrentPathEditBar as text
handles.cur_path_str = handles.CurrentPathEditBar.String;

% --- Executes during object creation, after setting all properties.
function CurrentPathEditBar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentPathEditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in detect_plot_Button.
function detect_plot_Button_Callback(hObject, eventdata, handles)
% hObject    handle to detect_plot_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.prompt_msg_line = '>>>> Detecting Saccades ...';
guidata(hObject,handles);
update_prompt_msg(hObject, eventdata, handles);
if isempty(handles.eyetrace)
    handles.prompt_msg_line = '>>>> Error: Please load data firstly.';
    guidata(hObject,handles);
    update_prompt_msg(hObject, eventdata, handles);
else
    [startPoint,endPoint,handles.cut_eye_trace] = CutEyetrace(handles);
    [handles.saccade_info,handles.velocity_xy] = DetectSaccade(handles);
    plotEyeTraceAndSac(handles,startPoint,endPoint);
    handles.prompt_msg_line = '>>>> Detection is done.';
    guidata(hObject,handles);
    update_prompt_msg(hObject, eventdata, handles);
end



function plotEyeTraceAndSac(handles,startPoint,endPoint)
% % plot eye trace
% temp_n = length(handles.cut_eye_trace);
% color_change = round(linspace(1,255,temp_n));
% color_data= [uint8([zeros(1,temp_n);color_change;color_change]); ...
%     uint8(ones(1,temp_n))];
% temp_h = plot(handles.plot_ax_2d,...
%     handles.cut_eye_trace(:,1),handles.cut_eye_trace(:,2),'LineWidth',2);
% drawnow;
% set(temp_h.Edge,'ColorBinding','interpolated', 'ColorData',color_data);
% hold(handles.plot_ax_2d,'on');
% temp_half_scale_lim = max(abs(max(handles.cut_eye_trace(:),min(handles.cut_eye_trace(:)))));
% set(handles.plot_ax_2d,'XLim',[-temp_half_scale_lim,temp_half_scale_lim]);
% set(handles.plot_ax_2d,'YLim',[-temp_half_scale_lim,temp_half_scale_lim]);
PlotPeriodEyeTrace(handles,startPoint,endPoint)
% plot detected saccades during cue1 in example trial
temp_cut_eyetrace = handles.eyetrace(startPoint:endPoint,:);
temp_saccade_info = ...
    saccade_detector(temp_cut_eyetrace,...
    handles.fill_missing_data,...
    handles.smoothen,...
    handles.SamplingRate,...
    handles.fix_vel_thres,...
    handles.lambda,...
    handles.combine_intv_thres,...
    handles.saccade_dur_thres,...
    handles.saccade_amp_thres);
temp_sac_eyetrace = cell(1,size(temp_saccade_info,1));
for i = 1:length(temp_sac_eyetrace)
    temp_sac_eyetrace{i} = temp_cut_eyetrace(temp_saccade_info(i,2):...
        temp_saccade_info(i,3),:);
    plot(handles.plot_ax_2d,...
        temp_sac_eyetrace{i}(:,1),temp_sac_eyetrace{i}(:,2),'-','LineWidth',1,...
        'color',[1 0.5 0]);
    hold(handles.plot_ax_2d,'on');
end
hold(handles.plot_ax_2d,'off');
% plot velocity vs time
plot(handles.plot_v_t,...
    (startPoint:endPoint),handles.velocity_xy(startPoint:endPoint),'Color',[0.2 0.6 0.2]);
hold(handles.plot_v_t,'off');
set(handles.plot_v_t,'XLim',[startPoint,endPoint]);
% plot detected saccades on 1d eyetrace X and 1d eyetrace Y
for i = 1:size(temp_saccade_info,1)
    % x
    plot(handles.plot_x_t,...
        ((temp_saccade_info(i,2)+startPoint):(temp_saccade_info(i,3)+startPoint)),...
        temp_cut_eyetrace(temp_saccade_info(i,2):temp_saccade_info(i,3),1),...
        'LineWidth',2,'Color',[1 0.2 0]);
    hold(handles.plot_x_t,'on');
    % y
    plot(handles.plot_y_t,...
        ((temp_saccade_info(i,2)+startPoint):(temp_saccade_info(i,3)+startPoint)),...
       temp_cut_eyetrace(temp_saccade_info(i,2):temp_saccade_info(i,3),2),...
        'LineWidth',2,'Color',[1 0.2 0]);
    hold(handles.plot_y_t,'on');
end
set(handles.plot_x_t,'XLim',[startPoint,endPoint]);
set(handles.plot_y_t,'XLim',[startPoint,endPoint]);


function PlotPeriodEyeTrace(handles,startPoint,endPoint)
cla(handles.plot_ax_2d);
cla(handles.plot_v_t);
cla(handles.plot_x_t);
cla(handles.plot_y_t);
cut_eye_trace = handles.eyetrace(startPoint:endPoint,:);
axes_2d = handles.plot_ax_2d;
axes_x = handles.plot_x_t;
axes_y = handles.plot_y_t;
plot(axes_2d,cut_eye_trace(:,1),cut_eye_trace(:,2),'.','LineWidth',2);
temp_half_scale_lim = max(abs(max(cut_eye_trace(:),min(cut_eye_trace(:)))));
set(axes_2d,'XLim',[-temp_half_scale_lim,temp_half_scale_lim]);
set(axes_2d,'YLim',[-temp_half_scale_lim,temp_half_scale_lim]);
plot(axes_x,(startPoint:endPoint),cut_eye_trace(:,1),'LineWidth',1.5,'Color',[0 0.3 0.6]);
plot(axes_y,(startPoint:endPoint),cut_eye_trace(:,2),'LineWidth',1.5,'Color',[0 0.3 0.6]);
set(axes_x,'XLim',[startPoint,endPoint]);
set(axes_y,'XLim',[startPoint,endPoint]);


function update_prompt_msg(hObject, eventdata, handles)
% hObject    handle to PlotAreaHeightEdit (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
last_1st_str = handles.PromptMessageText3.String;
last_2nd_str = handles.PromptMessageText2.String;
new_str = handles.prompt_msg_line;
set(handles.PromptMessageText3,'String', new_str);
set(handles.PromptMessageText2,'String', last_1st_str);
set(handles.PromptMessageText1,'String', last_2nd_str);
guidata(hObject, handles);

function val = get_var_via_load(filepath)
if exist(filepath,'file') == 2
    var_struct = load(filepath);
    name_cell = fieldnames(var_struct);
    val = getfield(var_struct,char(name_cell));
elseif  exist(filepath,'file') == 0
    msgbox('Non-exist file!','Error','Error');
end

function plot_eyetrace_period(hObject,eventdata,handles)
% truncate the data to selected period
hold(handles.plot_ax_2d,'off');
hold(handles.plot_x_t,'off');
hold(handles.plot_y_t,'off');
[startPoint,endPoint,cut_eye_trace] = CutEyetrace(handles);
axes_2d = handles.plot_ax_2d;
axes_x = handles.plot_x_t;
axes_y = handles.plot_y_t;
plot(axes_2d,cut_eye_trace(:,1),cut_eye_trace(:,2),'.','LineWidth',2);
temp_half_scale_lim = max(abs(max(cut_eye_trace(:),min(cut_eye_trace(:)))));
set(axes_2d,'XLim',[-temp_half_scale_lim,temp_half_scale_lim]);
set(axes_2d,'YLim',[-temp_half_scale_lim,temp_half_scale_lim]);
plot(axes_x,(startPoint:endPoint),cut_eye_trace(:,1),'LineWidth',1.5,'Color',[0 0.3 0.6]);
plot(axes_y,(startPoint:endPoint),cut_eye_trace(:,2),'LineWidth',1.5,'Color',[0 0.3 0.6]);
set(axes_x,'XLim',[startPoint,endPoint]);
set(axes_y,'XLim',[startPoint,endPoint]);
handles.prompt_msg_line = '>>>> Eyetrace plotting done.';
hold(handles.plot_x_t,'on');
hold(handles.plot_y_t,'on');
hold(handles.plot_ax_2d,'on');
guidata(hObject,handles);
update_prompt_msg(hObject, eventdata, handles);


function [startPoint,endPoint,cut_eye_trace] = CutEyetrace(handles)
eye_trace_data = handles.eyetrace;
startPoint = str2double(handles.StartPoint_EditBar.String);
endPoint = handles.EndPoint_EditBar.String;
if strcmp(endPoint,'end')
    endPoint = size(eye_trace_data,1);
else
    endPoint = handles.textnnn;
end
cut_eye_trace = eye_trace_data(startPoint:endPoint,:);


function CheckDataResult = CheckInputData(hObject,eventdata,handles)
dataSize_row = size(handles.eyetrace,1);
dataSize_column = size(handles.eyetrace,2);
if ~isa(handles.eyetrace,'double') || dataSize_row < 10 || dataSize_column ~= 2
    CheckDataResult = false;
    handles.prompt_msg_line = ">>>> ERROR: Invalid input data! Please choose a 'double' array with size n(>10)*2";
    guidata(hObject,handles);
    update_prompt_msg(hObject, eventdata, handles);
else
    CheckDataResult = true;
end

function [saccade_info,velocity_xy]...
    = DetectSaccade(handles)
[saccade_info,velocity_xy] = saccade_detector(...
    handles.eyetrace,...
    handles.fill_missing_data,...
    handles.smoothen,...
    handles.SamplingRate,...
    handles.fix_vel_thres,...
    handles.lambda,...
    handles.combine_intv_thres,...
    handles.saccade_dur_thres,...
    handles.saccade_amp_thres);


% --- Executes during object creation, after setting all properties.
function EndPoint_EditBar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EndPoint_EditBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
