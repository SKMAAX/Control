clear

%% ADRCの1リンクマニピュレータの適用 積分型最適サーボとの比較

%% 物理パラメータ
% 減衰あり剛体振り子の運動方程式 ml^2/12 ddot(theta) = mgl sin(theta) → l/12 ddot(theta) =
% g sin(theta) + c_theta dot(theta) + f
M = 1;%[kg]
l = 1;%[m]
g = 9.8;
c_theta = 0.2;%減衰係数
I = M*l*l/12; %剛体振り子のイナーシャ

theta_ini = pi/4; dtheta_ini = 0; %初期状態

%% 線形近似した状態空間モデル
A=[0 1; -M*g*l/I -c_theta/I]; B=[0;1/I]; C=[1 0]; D=0; 
x0 = [theta_ini; dtheta_ini];
[n,~] = size(A); [~,m] = size(B); [p,~] = size(C);

%% 拡張状態方程式の定義
A_ex = [0 1 0; 0 0 1; 0 0 0 ];
B_ex = [0; B(2); 0];
C_ex = [1 0 0]; % 角度のみ観測
b_inv = 1/B(2); % 拡張状態を相殺させるにあたっての係数

%% 拡張状態オブザーバの極配置
% pole_exobs = [-5 -6 -7]*10;
% L_ex = place(A_ex',C_ex',pole_exobs)'; 

%% 拡張状態オブザーバの極配置 同一極に配置する場合
exobs_omega = 200; % ESOの極
c2 = 3*exobs_omega;
c1 = 3*exobs_omega^2;
c0 = exobs_omega^3;
L_ex = [c2;c1;c0]; 

kp = 20;% 適当なPゲイン
kd = 2;% 適当なDゲイン 


%% 積分型最適サーボ系設計
A_tilde=[A zeros(n,1); -C 0]; B_tilde=[B; 0];
Q_ctrl = diag([1e2, 1e2, 1e7]);
R_ctrl = 1;
F_ctrl = lqr(A_tilde, B_tilde, Q_ctrl, R_ctrl);
Kp = F_ctrl(1);
Kd = F_ctrl(2);
Ki = -F_ctrl(n+1);

%% シミュレーション実行
Tsim = 0.001;%シミュレーション時間間隔
out = sim('sim_ADRC_1link_arm');

%% 結果の描画
lw = 1;
FontSize = 18;
fig1 = figure;
subplot(2,1,1),plot(out.theta_ref.Time, out.theta_ref.Data,...
    out.theta.Time, out.theta.Data,...
    out.theta_opt.Time, out.theta_opt.Data,...
    'LineWidth',lw); grid on
graph_x1_1 = legend('\theta_{ref} ', '\theta ADRC', '\theta OptServo');
graph_x1_1.FontSize = FontSize;
set(graph_x1_1,'Location','NorthEast');
title('Position tracking','FontSize',FontSize)
ylabel('Angle[rad]','FontSize',FontSize)
xlabel('Time[s]','FontSize',FontSize)
subplot(2,1,2),plot(...
    out.f.Time, out.f.Data,...
    out.f_hat.Time, out.f_hat.Data,...
    'LineWidth',lw); grid on
graph_x1_2 = legend('f', 'estimated f');
graph_x1_2.FontSize = FontSize;
set(graph_x1_2,'Location','NorthEast');
title('Dynamics estimation','FontSize',FontSize)
ylabel('[rad/s^2]','FontSize',FontSize)
xlabel('Time[s]','FontSize',FontSize)
ylim([-200 200]);

saveas(gcf,'ADRC_1link_arm.png')
