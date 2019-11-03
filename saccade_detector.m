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
end

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
end


    
