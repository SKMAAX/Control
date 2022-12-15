clear
close all

%% 物理パラメータ
M1 = 1; % [kg]
M2 = 1; % [kg]
l1 = 0.5; % [m]
l2 = 0.5; % [m]
L1 = 1; % [m]
L2 = 1; % [m] 運動方程式には使わないが、アニメーションで使う

g = 9.8;
c1 = 0.5; % 減衰係数
c2 = 0.5; % 減衰係数

I1 = M1*l1^2;
I2 = M2*l2^2;

M_0 = [I1+I2+M1*l1^2+M2*L1^2+M2*l2^2 I2+M2*l2^2; I2+M2*l2^2 I2+M2*l2^2]; % cos(theta2)によらない部分
M_cth2 = [2*M2*L1*l2 M2*L1*l2; M2*L1*l2 0]; % cos(theta2)がかかる部分

theta1_ini = 0; dtheta1_ini = 0; %初期状態
theta2_ini = 0; dtheta2_ini = 0; %初期状態

%% PIDゲインの設定
kp_1=100;kd_1=20;ki_1=0.1;kp_2=100;kd_2=20;ki_2=0.1;

%% シミュレーション実行
Tsim = 0.001;%シミュレーション時間間隔
Tend = 10;
% out = sim('sim_ADRC_2link_arm');  % ステップ角度指令はこっち
out = sim('sim_CTM_2link_arm'); 

%% 結果の描画
lw = 1;
width = 600;
hight = 400;
fig1 = figure('Position',[100 100 width hight]);
plot(out.theta1_ref.Time, out.theta1_ref.Data,...
    out.theta1.Time, out.theta1.Data,...
    out.theta2_ref.Time, out.theta2_ref.Data,...
    out.theta2.Time, out.theta2.Data,...
    'LineWidth',lw); grid on
graph_x1_1 = legend('\theta_{1 ref}', '\theta_1', '\theta_{2 ref}', '\theta_2');
set(graph_x1_1,'Location','NorthEast');
title('CTM Angle Tracking')
ylabel('Angle[rad]')
xlabel('Time[s]')
ylim([-0.2 2.0]);