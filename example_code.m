% test saccade_detector function
% example code showing detecting results

% clear; close all; clc;

%% load example data
if ~exist('eyetrace','var')
    load('example_eyetrace.mat');
    % this example trace have a big saccade and several micro-saccades
end

%% set parameters
sampling_rate = 1000;
fix_vel_thres = 30;
lambda = 7;
combine_intv_thres = 20;
saccade_dur_thres = 5;
saccade_amp_thres = 0.2;

%% detect saccades
[saccade_info,velocity_xy] = saccade_detector(...
    eyetrace,...
    sampling_rate,...
    fix_vel_thres,...
    lambda,...
    combine_intv_thres,...
    saccade_dur_thres,...
    saccade_amp_thres);

%% plot detected results
f1 = figure('NumberTitle', 'off', 'Name', 'Example Data Detected Saccades Results');
set(f1,'Position',[450 350 800 350]);
subplot(3,3,[1,4,7])
% plot eye trace
temp_n = length(eyetrace);
color_change = round(linspace(1,255,temp_n));
color_data= [uint8([zeros(1,temp_n);color_change;color_change]); ...
    uint8(ones(1,temp_n))];
temp_h = plot(eyetrace(:,1),eyetrace(:,2),'LineWidth',2);
drawnow;
set(temp_h.Edge,'ColorBinding','interpolated', 'ColorData',color_data)
temp_half_scale_lim = max(abs(max(eyetrace(:),min(eyetrace(:)))));
xlim([-temp_half_scale_lim,temp_half_scale_lim]);
ylim([-temp_half_scale_lim,temp_half_scale_lim]);
hold on

eg_sac_eyetrace = cell(1,size(saccade_info,1));
for i = 1:length(eg_sac_eyetrace)
    eg_sac_eyetrace{i} = eyetrace(saccade_info(i,2):...
        saccade_info(i,3),:);
    plot(eg_sac_eyetrace{i}(:,1),eg_sac_eyetrace{i}(:,2),'-','LineWidth',1,...
        'color',[1 0.5 0]);
    hold on
end
xlabel('X Position');
ylabel('Y Position');
title('Eyetrace(DarkCyanToLightCyan) and Detected Saccades(Orange)')
hold off
clear temp* color*

% plot velocity vs time
subplot(3,3,2)
plot((1:length(velocity_xy)),velocity_xy,'Color',[0.2 0.6 0.2]);
ylabel('Velocity')

% plot eyetrace X position vs time
subplot(3,3,5)
plot((1:length(eyetrace(:,1))),eyetrace(:,1));
ylabel('X Position')
hold on
% plot detected saccades on 1d eyetrace X
for i = 1:length(eg_sac_eyetrace)
    plot((saccade_info(i,2):saccade_info(i,3)),...
        eyetrace(saccade_info(i,2):saccade_info(i,3),1),...
        'LineWidth',2,'Color',[1 0.5 0]);
    hold on
end
hold off

% plot eyetrace Y position vs time
subplot(3,3,8)
plot((1:length(eyetrace(:,2))),eyetrace(:,2));
xlabel('Time')
ylabel('Y Position')
hold on
% plot detected saccades on 1d eyetrace Y
for i = 1:length(eg_sac_eyetrace)
    plot((saccade_info(i,2):saccade_info(i,3)),...
        eyetrace(saccade_info(i,2):saccade_info(i,3),2),...
        'LineWidth',2,'Color',[1 0.5 0]);
    hold on
end

% plot main sequence of detected saccades
subplot(3,3,[3,6,9])
plot(saccade_info(:,5),saccade_info(:,4),'o','Color','m');
xlabel('Amplitude');
ylabel('Peak Velocity');
title('Main Sequence')