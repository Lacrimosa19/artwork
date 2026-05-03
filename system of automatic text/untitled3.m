%% 105mm 榴弹炮 - 弹道轨迹动图模拟
% 本脚本生成一个包含空气阻力效应的真实弹道动画

clear; clc; close all;

%% 1. 物理参数设置
% 火炮参数 (基于105mm M1/M2 榴弹炮数据)
gun.caliber = 0.105;        % 口径 [m]
gun.muzzle_velocity = 472;  % 初速 [m/s]
gun.mass = 14.97;           % 弹丸质量 [kg]

% 环境参数
env.g = 9.80665;            % 重力加速度 [m/s^2]
env.rho = 1.225;            % 空气密度 [kg/m^3] (海平面15°C)

% 空气阻力参数
Cd = 0.35;                  % 阻力系数 (经验值)
A = pi * (gun.caliber/2)^2; % 截面积 [m^2]

% 射击条件
elevation_deg = 25;         % 仰角 [度] (可修改测试不同角度)
elevation_rad = deg2rad(elevation_deg);

%% 2. 数值解算弹道轨迹
% 状态变量: [x; y; vx; vy]
initial_state = [0; 0;
                 gun.muzzle_velocity * cos(elevation_rad);
                 gun.muzzle_velocity * sin(elevation_rad)];

% 仿真参数
dt = 0.02;                  % 时间步长 [s]
t = 0:dt:60;                % 时间向量 (最大60秒)
n_steps = length(t);

% 预分配存储
states = zeros(4, n_steps);
states(:,1) = initial_state;

% RK4积分
for i = 1:n_steps-1
    states(:,i+1) = rk4_step(states(:,i), dt, @(s) ballistic_ode(s, gun, env, Cd, A));
    
    % 落地终止条件
    if states(2, i+1) <= 0
        % 精确插值落地位置
        y1 = states(2, i);
        y2 = states(2, i+1);
        alpha = y1 / (y1 - y2);
        states(1, i+1) = states(1, i) + alpha * (states(1, i+1) - states(1, i));
        states(2, i+1) = 0;
        states = states(:, 1:i+1);
        t = t(1:i+1);
        break;
    end
end

% 提取轨迹数据
x_traj = states(1, :);
y_traj = states(2, :);
vx = states(3, :);
vy = states(4, :);
v = sqrt(vx.^2 + vy.^2);

% 弹着点信息
impact_range = x_traj(end);
impact_time = t(end);
max_height = max(y_traj);

%% 3. 创建动图
% 创建图形窗口
fig = figure('Position', [100, 100, 1100, 600], 'Color', 'white');

% 主图: 弹道轨迹
ax1 = subplot(1,2,1);
hold(ax1, 'on');
grid(ax1, 'on');
axis equal;
xlim([0, impact_range * 1.05]);
ylim([0, max_height * 1.1]);
xlabel(ax1, '射程 (m)');
ylabel(ax1, '高度 (m)');
title(ax1, sprintf('105mm 榴弹炮弹道轨迹 (仰角 = %d°)', elevation_deg));

% 绘制背景: 地面线
plot(ax1, [0, impact_range*1.05], [0, 0], 'k-', 'LineWidth', 2);

% 绘制完整弹道 (灰色半透明)
plot(ax1, x_traj, y_traj, 'b--', 'LineWidth', 1.5, 'Color', [0.5, 0.5, 0.5]);

% 炮弹对象 (红色圆点)
bullet = plot(ax1, 0, 0, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r');

% 弹着点标记 (绿色星号)
impact_marker = plot(ax1, impact_range, 0, 'g*', 'MarkerSize', 15, 'LineWidth', 2);

% 添加风玫瑰 (风向指示)
theta_wind = 0; % 假设风向
wind_arrow = annotation('textarrow', [0.15, 0.18], [0.85, 0.82], ...
    'String', '风向 →', 'FontSize', 10, 'Color', 'b');

% 副图: 速度与高度变化
ax2 = subplot(1,2,2);
hold(ax2, 'on');
grid(ax2, 'on');
yyaxis(ax2, 'left');
h1 = plot(ax2, t, v, 'r-', 'LineWidth', 2);
ylabel(ax2, '速度 (m/s)');
ylim([0, gun.muzzle_velocity * 1.1]);

yyaxis(ax2, 'right');
h2 = plot(ax2, t, y_traj, 'b-', 'LineWidth', 2);
ylabel(ax2, '高度 (m)');
ylim([0, max_height * 1.1]);

xlabel(ax2, '飞行时间 (s)');
title(ax2, '速度与高度随时间变化');
legend([h1, h2], {'速度', '高度'}, 'Location', 'best');

% 信息文本框
info_box = annotation('textbox', [0.55, 0.05, 0.4, 0.12], ...
    'String', sprintf('当前时间: 0.00 s\n射程: 0 m\n高度: 0 m'), ...
    'FontSize', 10, 'BackgroundColor', [0.95, 0.95, 0.95], ...
    'EdgeColor', 'k');

%% 4. 生成动画帧并保存为GIF
% GIF保存参数
gif_filename = 'howitzer_trajectory.gif';
delay_time = 0.05;  % 帧间隔 (秒)

% 动画循环
fprintf('正在生成动画...\n');
for i = 1:5:length(t)  % 步进5帧，保持动画流畅
    % 更新炮弹位置
    set(bullet, 'XData', x_traj(i), 'YData', y_traj(i));
    
    % 更新信息文本框
    current_time = t(i);
    current_range = x_traj(i);
    current_height = y_traj(i);
    current_velocity = v(i);
    
    set(info_box, 'String', sprintf(...
        '飞行时间: %.2f s\n射程: %.0f m\n高度: %.0f m\n速度: %.0f m/s', ...
        current_time, current_range, current_height, current_velocity));
    
    % 刷新图形
    drawnow;
    
    % 捕获当前帧为图像
    frame = getframe(fig);
    img = frame2im(frame);
    [img_idx, map] = rgb2ind(img, 256);
    
    % 写入GIF
    if i == 1
        imwrite(img_idx, map, gif_filename, 'gif', ...
            'LoopCount', Inf, 'DelayTime', delay_time);
    else
        imwrite(img_idx, map, gif_filename, 'gif', ...
            'WriteMode', 'append', 'DelayTime', delay_time);
    end
end

fprintf('动画已保存为: %s\n', gif_filename);
fprintf('弹着点信息:\n');
fprintf('  射程: %.0f m (%.2f km)\n', impact_range, impact_range/1000);
fprintf('  飞行时间: %.2f s\n', impact_time);
fprintf('  最大高度: %.0f m\n', max_height);

%% ==================== 局部函数 ====================

function dstate = ballistic_ode(state, gun, env, Cd, A)
    % 弹道微分方程 (包含空气阻力)
    vx = state(3);
    vy = state(4);
    v = sqrt(vx^2 + vy^2);
    
    if v < 0.1
        ax = 0;
        ay = -env.g;
    else
        drag_acc = 0.5 * env.rho * Cd * A * v^2 / gun.mass;
        ax = -drag_acc * (vx / v);
        ay = -env.g - drag_acc * (vy / v);
    end
    
    dstate = [vx; vy; ax; ay];
end

function next_state = rk4_step(state, dt, f)
    % 4阶Runge-Kutta积分器
    k1 = f(state);
    k2 = f(state + 0.5*dt*k1);
    k3 = f(state + 0.5*dt*k2);
    k4 = f(state + dt*k3);
    next_state = state + dt * (k1 + 2*k2 + 2*k3 + k4) / 6;
end