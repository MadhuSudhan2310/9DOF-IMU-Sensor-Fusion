% =========================================================================
% Script Name: load_data.m
% Description: Loads VIBDATA.CSV and creates Simulink-compatible 
%              timeseries vectors for Accel, Gyro, and Mag inputs.
% =========================================================================

% 1. Check if dataset exists in directory
csvFileName = 'imu_data.CSV';
if ~exist(csvFileName, 'file')
    error('File "%s" not found in current folder! Make sure it is in your working directory.', csvFileName);
end

% 2. Load raw numeric matrix from CSV
fprintf('Loading sensor data from %s...\n', csvFileName);
sensor_data = readmatrix(csvFileName);

% 3. Set sampling parameters (100 Hz sampling rate, dt = 0.01s)
dt = 0.01; 
N = size(sensor_data, 1);
t = (0:N-1)' * dt;

% 4. Create 3-axis Timeseries objects for Simulink From Workspace blocks
% Accelerometer Data (Columns 1-3)
accel_ts = timeseries(sensor_data(:, 1:3), t);
accel_ts.Name = 'Accelerometer_Data';

% Gyroscope Data (Columns 4-6)
gyro_ts = timeseries(sensor_data(:, 4:6), t);
gyro_ts.Name = 'Gyroscope_Data';

% Magnetometer Data (Columns 7-9 or fallback default vector)
if size(sensor_data, 2) >= 9
    mag_ts = timeseries(sensor_data(:, 7:9), t);
else
    % Default magnetic field vector [Mx, My, Mz] if CSV only has 6 axes
    mag_ts = timeseries(repmat([20, 0, 45], N, 1), t);
end
mag_ts.Name = 'Magnetometer_Data';

% 5. Assign variables to MATLAB Base Workspace
assignin('base', 'accel_ts', accel_ts);
assignin('base', 'gyro_ts', gyro_ts);
assignin('base', 'mag_ts', mag_ts);

fprintf('Success! Variables [accel_ts, gyro_ts, mag_ts] loaded into workspace.\n');