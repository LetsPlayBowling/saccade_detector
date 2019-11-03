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
handles.SamplingRate = 1000; % hz
handles.fix_vel_thres = 30; % degree/sec
handles.lambda = 7;
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
parameters = struct('SamplingRate',handles.SamplingRate,...
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
handles.prompt_msg_line = '>>>> Clear all axes and loadeed data.';
guidata(hObject,handles);
update_prompt_msg(hObject, eventdata, handles);

% --- Executes on button press in ResetPara_Button.
function ResetPara_Button_Callback(hObject, eventdata, handles)
% hObject    handle to ResetPara_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SamplingRate = 1000; % hz
handles.fix_vel_thres = 30; % degree/sec
handles.lambda = 7;
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


function [saccade_info,velocity_xy] = saccade_detector(...
    eyetrace,...
    sampling_rate,...
    fix_vel_thres,...
    lambda,...
    combine_intv_thres,...
    saccade_dur_thres,...
    saccade_amp_thres)
% Written by Ray 2019 Oct. in Tm Yang Lab

% This function can detect saccadic eye-movement in this way:
% step1: compute eye velocity in each sampling point by a sliding window.
% step2: find relative static points whose velocity < fix_vel_thres, 
%        get the median value(MedianStaticVelocity) and std (StdStaticVelocity)
%        for computing the 'saccade_velocity_threshold'.
% step3: detect potential saccades by velocity. if the velocity is larger
%        than saccade_velocity_threshold (MedianStaticVelocity + lambda * StdStaticVelocity)
%        we can say the saccade is happening.
% step4: combine the saccades whose interval is shorter than combine_intv_thres
%        delete the saccades whose duration is shorter than saccade_dur_thres
%        delete the saccades whose ammplitude is smaller than saccade_amp_thres
% You can use this to detect either Saccades or Micro-saccades,
% by setting appropriate prameters. 
% Read the ref. paper for more info: 

% inputs£º7 variables as parameters 
% #1 eyetrace:a 2-column array, [Xpos, Ypos] (recommend unit: degree)
% #2 sampling_rate (recommend:1000Hz)
% #3 fixation velocity maximum threshold (recommend:30 degree/s)
% #4 lambda (recommend:7.5)
% #5 combine_intv_thres (recommend:20 ms)
% #6 saccade_dur_thres (recommend:5 ms)
% #7 saccade_amp_thres 

% ouputs: 2 variables
% #1 sac_info matrix:
% a 10-column array:
% number, startTime, endTime, peakVelocity, amplitude, direction,...
% startpoint(xpos),startpoint(ypos),endpoint(xpos),endpoint(ypos)
% #2 1-column array, eye velocity 


%% compute eye velocity
eyetrace_x = eyetrace(:,1);
eyetrace_y = eyetrace(:,2);
dt = 1000/sampling_rate;

velocity_x = zeros(length(eyetrace),1);
velocity_y = zeros(length(eyetrace),1);
velocity_xy = zeros(length(eyetrace),1);
for i = 3:length(eyetrace)-2
    % unit: degree/second
    velocity_x(i) = ...
        (eyetrace_x(i+2) + eyetrace_x(i+1) - ...
        eyetrace_x(i-1)  - eyetrace_x(i-2))/(6*dt) * 1000;
    velocity_y(i) = ...
        (eyetrace_y(i+2) + eyetrace_y(i+1) - ...
        eyetrace_y(i-1)  - eyetrace_y(i-2))/(6*dt) * 1000;
end
velocity_x(1) = velocity_x(3);
velocity_x(2) = velocity_x(3);
velocity_x(end-1) = velocity_x(end-2);
velocity_x(end) = velocity_x(end-2);
velocity_y(1) = velocity_y(3);
velocity_y(2) = velocity_y(3);
velocity_y(end-1) = velocity_y(end-2);
velocity_y(end) = velocity_y(end-2);
for i = 1:length(eyetrace)
    velocity_xy(i) = sqrt(velocity_x(i)^2 + velocity_y(i)^2);
end

%% find relative static points and compute its median value
MedianStaticVelocity = median(velocity_xy(velocity_xy < fix_vel_thres));
MedianStaticVelocity_array = ones(length(eyetrace),1) .* MedianStaticVelocity;

%% compute std by median and the velovity threshold 
StdStaticVelocity = sqrt(median((velocity_xy - MedianStaticVelocity_array).^2));
% Notice, this std is calculated by median istead of mean.
velocity_threshold = MedianStaticVelocity + (lambda * StdStaticVelocity);

%% find eye_velocity larger than threshold 
over_threshold_ind = find(velocity_xy >= velocity_threshold) ;
potential_Sac_m = findContinue(over_threshold_ind);


%% check each potential Saccades
% combine_intv_thres
% combine 2 potential saccades if the interval is smaller than the threshold,
% this is physiologically reasonable
% Saccade_dur_thres
% count it, if the potential saccade's dur is larger than this threshold
Sac_m = nan(size(potential_Sac_m,1),300); % expand each row in the matrix
combined_row_marker = zeros(size(potential_Sac_m,1),1);
for i =   1:size(potential_Sac_m,1)
    if i <= size(potential_Sac_m,1)-4
        cur_row_last_timepoint = potential_Sac_m(i,sum(~(isnan(potential_Sac_m(i,:)))));
        next1_row_first_timepoint = potential_Sac_m(i+1,1);
        next1_row_last_timepoint = potential_Sac_m(i+1,sum(~(isnan(potential_Sac_m(i+1,:)))));
        next2_row_first_timepoint = potential_Sac_m(i+2,1);
        next2_row_last_timepoint = potential_Sac_m(i+2,sum(~(isnan(potential_Sac_m(i+2,:)))));
        next3_row_first_timepoint = potential_Sac_m(i+3,1);
        next3_row_last_timepoint = potential_Sac_m(i+3,sum(~(isnan(potential_Sac_m(i+3,:)))));
        next4_row_first_timepoint = potential_Sac_m(i+4,1);
        intv1 = next1_row_first_timepoint - cur_row_last_timepoint;
        intv1_comparison = intv1 < combine_intv_thres;
        intv2 = next2_row_first_timepoint - next1_row_last_timepoint;
        intv2_comparison = intv2 < combine_intv_thres;
        intv3 = next3_row_first_timepoint - next2_row_last_timepoint;
        intv3_comparison = intv3 < combine_intv_thres;
        intv4 = next4_row_first_timepoint - next3_row_last_timepoint;
        intv4_comparison = intv4 < combine_intv_thres;
        if intv1_comparison && intv2_comparison  && intv3_comparison  && intv4_comparison 
            temp_cur_Sac = [potential_Sac_m(i,:), potential_Sac_m(i+1,:), potential_Sac_m(i+2,:), potential_Sac_m(i+3,:), potential_Sac_m(i+4,:)];
            cur_Sac = temp_cur_Sac;
            cur_Sac(isnan(cur_Sac)) = [];
            combined_row_marker([i+1,i+2,i+3,i+4]) = [1,1,1,1];
        elseif intv1_comparison && intv2_comparison  && intv3_comparison
            temp_cur_Sac = [potential_Sac_m(i,:), potential_Sac_m(i+1,:), potential_Sac_m(i+2,:), potential_Sac_m(i+3,:)];
            cur_Sac = temp_cur_Sac;
            cur_Sac(isnan(cur_Sac)) = [];
            combined_row_marker([i+1,i+2,i+3]) = [1,1,1];
        elseif intv1_comparison && intv2_comparison  
            temp_cur_Sac = [potential_Sac_m(i,:), potential_Sac_m(i+1,:), potential_Sac_m(i+2,:)];
            cur_Sac = temp_cur_Sac;
            cur_Sac(isnan(cur_Sac)) = []; 
            combined_row_marker([i+1,i+2]) = [1,1];
        elseif intv1_comparison 
            temp_cur_Sac = [potential_Sac_m(i,:), potential_Sac_m(i+1,:)];
            cur_Sac = temp_cur_Sac;
            cur_Sac(isnan(cur_Sac)) = [];
            combined_row_marker(i+1) = 1;
        elseif ~intv1_comparison
            cur_Sac = potential_Sac_m(i,:);
            cur_Sac(isnan(cur_Sac)) = [];
            if length(cur_Sac) < saccade_dur_thres
                cur_Sac = nan;
            end
        end
    elseif i <= size(potential_Sac_m,1)-3 % for the last 4th potential saccades 
        cur_row_last_timepoint = potential_Sac_m(i,sum(~(isnan(potential_Sac_m(i,:)))));
        next1_row_first_timepoint = potential_Sac_m(i+1,1);
        next1_row_last_timepoint = potential_Sac_m(i+1,sum(~(isnan(potential_Sac_m(i+1,:)))));
        next2_row_first_timepoint = potential_Sac_m(i+2,1);
        next2_row_last_timepoint = potential_Sac_m(i+2,sum(~(isnan(potential_Sac_m(i+2,:)))));
        next3_row_first_timepoint = potential_Sac_m(i+3,1);
        intv1 = next1_row_first_timepoint - cur_row_last_timepoint;
        intv1_comparison = intv1 < combine_intv_thres;
        intv2 = next2_row_first_timepoint - next1_row_last_timepoint;
        intv2_comparison = intv2 < combine_intv_thres;
        intv3 = next3_row_first_timepoint - next2_row_last_timepoint;
        intv3_comparison = intv3 < combine_intv_thres;
        if intv1_comparison && intv2_comparison  && intv3_comparison
            temp_cur_Sac = [potential_Sac_m(i,:), potential_Sac_m(i+1,:), potential_Sac_m(i+2,:), potential_Sac_m(i+3,:)];
            cur_Sac = temp_cur_Sac;
            cur_Sac(isnan(cur_Sac)) = [];
            combined_row_marker([i+1,i+2,i+3]) = [1,1,1];
        elseif intv1_comparison && intv2_comparison  
            temp_cur_Sac = [potential_Sac_m(i,:), potential_Sac_m(i+1,:), potential_Sac_m(i+2,:)];
            cur_Sac = temp_cur_Sac;
            cur_Sac(isnan(cur_Sac)) = []; 
            combined_row_marker([i+1,i+2]) = [1,1];
        elseif intv1_comparison 
            temp_cur_Sac = [potential_Sac_m(i,:), potential_Sac_m(i+1,:)];
            cur_Sac = temp_cur_Sac;
            combined_row_marker(i+1) = 1;
            cur_Sac(isnan(cur_Sac)) = [];
        elseif ~intv1_comparison
            cur_Sac = potential_Sac_m(i,:);
            cur_Sac(isnan(cur_Sac)) = [];
            if length(cur_Sac) < saccade_dur_thres
                cur_Sac = nan;
            end
        end         
    elseif i <= size(potential_Sac_m,1)-2
        cur_row_last_timepoint = potential_Sac_m(i,sum(~(isnan(potential_Sac_m(i,:)))));
        next1_row_first_timepoint = potential_Sac_m(i+1,1);
        next1_row_last_timepoint = potential_Sac_m(i+1,sum(~(isnan(potential_Sac_m(i+1,:)))));
        next2_row_first_timepoint = potential_Sac_m(i+2,1);
        intv1 = next1_row_first_timepoint - cur_row_last_timepoint;
        intv1_comparison = intv1 < combine_intv_thres;
        intv2 = next2_row_first_timepoint - next1_row_last_timepoint;
        intv2_comparison = intv2 < combine_intv_thres;
        if intv1_comparison && intv2_comparison  
            temp_cur_Sac = [potential_Sac_m(i,:), potential_Sac_m(i+1,:), potential_Sac_m(i+2,:)];
            cur_Sac = temp_cur_Sac;
            cur_Sac(isnan(cur_Sac)) = []; 
            combined_row_marker([i+1,i+2]) = [1,1];
        elseif intv1_comparison 
            temp_cur_Sac = [potential_Sac_m(i,:), potential_Sac_m(i+1,:)];
            cur_Sac = temp_cur_Sac;
            cur_Sac(isnan(cur_Sac)) = [];
            combined_row_marker(i+1) = 1;
        elseif ~intv1_comparison
            cur_Sac = potential_Sac_m(i,:);
            cur_Sac(isnan(cur_Sac)) = [];
            if length(cur_Sac) < saccade_dur_thres
                cur_Sac = nan;
            end
        end
    elseif i <= size(potential_Sac_m,1)-1
        cur_row_last_timepoint = potential_Sac_m(i,sum(~(isnan(potential_Sac_m(i,:)))));
        next1_row_first_timepoint = potential_Sac_m(i+1,1);
        intv1 = next1_row_first_timepoint - cur_row_last_timepoint;
        intv1_comparison = intv1 < combine_intv_thres;
        if intv1_comparison 
            temp_cur_Sac = [potential_Sac_m(i,:), potential_Sac_m(i+1,:)];
            cur_Sac = temp_cur_Sac;
            cur_Sac(isnan(cur_Sac)) = [];
            combined_row_marker(i+1) = 1;
        elseif ~intv1_comparison
            cur_Sac = potential_Sac_m(i,:);
            cur_Sac(isnan(cur_Sac)) = [];
            if length(cur_Sac) < saccade_dur_thres
                cur_Sac = nan;
            end
        end
    elseif i == size(potential_Sac_m,1)
        cur_Sac = potential_Sac_m(i,:);
        cur_Sac(isnan(cur_Sac)) = [];
        if length(cur_Sac) < saccade_dur_thres
                cur_Sac = nan;
        end
    end
    
    if combined_row_marker(i) ~= 1
       Sac_m(i,(1:length(cur_Sac))) = cur_Sac;
    end
    
end
Sac_m(isnan(Sac_m(:,1)),:) = [];

Sac_number = size(Sac_m,1);
saccade_info = nan(Sac_number,6); 
%6 columns: number, startTime, endTime, peakVelocity, amplitude, direction
% 7:8 start point position; 9:10 end point position
for i = 1:size(Sac_m,1)
    saccade_info(i,1) = i; % number
    saccade_info(i,2) = Sac_m(i,1); % startTime
    saccade_info(i,3) = Sac_m(i,sum(~isnan(Sac_m(i,:)))); % endTime
    saccade_info(i,4) = max(velocity_xy(saccade_info(i,2):saccade_info(i,3))); % peak velocity
    temp_Sac_startPos = [eyetrace(saccade_info(i,2),1), eyetrace(saccade_info(i,2),2)];
    temp_Sac_endPos = [eyetrace(saccade_info(i,3),1), eyetrace(saccade_info(i,3),2)];
    Sac_vector = temp_Sac_endPos - temp_Sac_startPos;
    saccade_info(i,5) = sqrt(Sac_vector(1)^2 + Sac_vector(2)^2); % amplitude
    [theta, ~] = cart2pol(Sac_vector(1),Sac_vector(2));
    saccade_info(i,6) = theta; % direction
    saccade_info(i,7:8) = temp_Sac_startPos;
    saccade_info(i,9:10) = temp_Sac_endPos; 
end
%% deleting those potential saccades whoose amplitues are too small
for i = 1:size(saccade_info,1)
    if saccade_info(i,5) < saccade_amp_thres
        saccade_info(i,:) = nan;
    end
end
temp = saccade_info(:,1);
saccade_info(isnan(temp),:) = [];
saccade_info(:,1) = 1:size(saccade_info,1);

function m = findContinue(X)
% this function need a column vector of integers as its input, 
% and returns a matrix containing continuous integers in each row  
% EXAMPLE: try this: 
% X = [1,3,5,6,12,13,14,15,23,33,34,35,36,37,39,40,55,56]';
% m = findContinue(X)
m = nan(length(X));
for i = 1:length(X)
    if i == 1
        current_row = 1;
        m(current_row,1) = X(i);
    elseif X(i)-X(i-1) == 1
        temp = isnan(m(current_row,:));
        temp2 = find(temp == 1);
        temp3 = temp2(1);
        m(current_row,temp3) = X(i);
    else
        current_row = current_row + 1;
        temp = isnan(m(current_row,:));
        temp2 = find(temp == 1);
        temp3 = temp2(1);
        m(current_row,temp3) = X(i);
    end
end
m(isnan(m(:,1)),:) = [];
m(:,sum(~ isnan(m),1) == 0) = [];


    
