% =========================================================================
% Script Name: run_animation.m
% Description: 3D Visualization of 9-DOF IMU Orientation from Simulink Data
% =========================================================================

% 1. Locate orientation data in MATLAB Workspace
if exist('out_orientation', 'var')
    simData = out_orientation;
elseif exist('out', 'var') && isprop(out, 'out_orientation')
    simData = out.out_orientation;
elseif exist('out', 'var') && isfield(out, 'out_orientation')
    simData = out.out_orientation;
elseif exist('out', 'var') && isprop(out, 'logsout') && out.logsout.hasElement('out_orientation')
    simData = out.logsout.get('out_orientation').Values;
else
    error('No simulation data found in workspace! Click the green RUN button in Simulink first.');
end

% 2. Extract time array and Euler angles matrix
if isa(simData, 'timeseries') || contains(class(simData), 'Timeseries')
    time = simData.Time;
    angles = squeeze(simData.Data);
else
    angles = simData;
    time = 1:size(angles, 1);
end

% 3. Auto-fix matrix orientation (Ensure dimensions are 3 x N)
if size(angles, 2) == 3 && size(angles, 1) ~= 3
    angles = angles';
end

% 4. Define 3D Box Geometry (Vertices and Faces)
V = [-1 -0.5 -0.2;  1 -0.5 -0.2;  1 0.5 -0.2; -1 0.5 -0.2; ...
     -1 -0.5  0.2;  1 -0.5  0.2;  1 0.5  0.2; -1 0.5  0.2];
F = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];

% 5. Create 3D Figure Window
fig = figure('Name', '3D IMU Attitude Visualizer', 'NumberTitle', 'off');
h = patch('Faces', F, 'Vertices', V, 'FaceColor', [0.2 0.6 1], 'FaceAlpha', 0.8);
axis equal; grid on; view(3);
xlim([-2 2]); ylim([-2 2]); zlim([-2 2]);
xlabel('X (Roll)'); ylabel('Y (Pitch)'); zlabel('Z (Yaw)');
title('Live 3D Orientation Animation');

% 6. Render Animation Frame by Frame
for i = 1:length(time)
    % Exit loop safely if user closes the figure window
    if ~isvalid(fig), break; end
    
    r = deg2rad(angles(1, i)); % Roll
    p = deg2rad(angles(2, i)); % Pitch
    y = deg2rad(angles(3, i)); % Yaw

    % ZYX Euler Rotation Matrix
    Rx = [1 0 0; 0 cos(r) -sin(r); 0 sin(r) cos(r)];
    Ry = [cos(p) 0 sin(p); 0 1 0; -sin(p) 0 cos(p)];
    Rz = [cos(y) -sin(y) 0; sin(y) cos(y) 0; 0 0 1];
    R  = Rz * Ry * Rx;

    % Rotate 3D vertices
    V_rot = (R * V')';
    set(h, 'Vertices', V_rot);
    drawnow limitrate;
    pause(0.01);
end