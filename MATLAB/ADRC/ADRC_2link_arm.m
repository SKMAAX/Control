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
theta1_ini = -0.5; theta2_ini = 2; % 円を描かせる場合はこっちの初期値

%% 拡張状態方程式の定義
A1_ex = [0 1 0; 0 0 1; 0 0 0 ];
B1_ex = [0; 1/M_0(1,1); 0];
% B1_ex = [0; 1; 0];
C1_ex = [1 0 0]; % 角度のみ観測
b1_inv = M_0(1,1); % 拡張状態を相殺させるにあたっての係数

A2_ex = [0 1 0; 0 0 1; 0 0 0 ];
B2_ex = [0; 1/M_0(2,2); 0];
% B2_ex = [0; 1; 0];
C2_ex = [1 0 0]; % 角度のみ観測
b2_inv = M_0(2,2); % 拡張状態を相殺させるにあたっての係数

%% 拡張状態オブザーバの極配置
% 同一極に配置する
exobs_omega1 = 200; % ESOの重極 第1関節
L1_ex = [3*exobs_omega1;3*exobs_omega1^2;exobs_omega1^3]; 
exobs_omega2 = 200;  % ESOの重極 第2関節
L2_ex = [3*exobs_omega2;3*exobs_omega2^2;exobs_omega2^3]; 

kp1 = 30; % Pゲイン 第1関節
kd1 = 10; % Dゲイン 第1関節
kp2 = 30; % Pゲイン 第2関節
kd2 = 10; % Dゲイン 第2関節 

%% シミュレーション実行
Tsim = 0.001;%シミュレーション時間間隔
Tend = 10;
% out = sim('sim_ADRC_2link_arm');  % ステップ角度指令はこっち
out = sim('sim_ADRC_2link_arm_circle');  % 円を描かせる場合はこっち

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
title('ADRC Angle Tracking')
ylabel('Angle[rad]')
xlabel('Time[s]')
% ylim([-0.2 1.8]);