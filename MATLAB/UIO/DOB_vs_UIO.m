clear
close all

%% 物理パラメータの設定
J = 1;
c_th = 0.1;
k = 1;

%% 連続時間＆離散時間の状態空間モデルの設定
Ac = [0 1;-c_th/J -k/J ];
Bc = [0;1/J];
Ec = [0;1/J]; % 外乱の係数行列は入力と同じ。マッチング条件を満たす。
C = [1 0];
% C = [0 1]; %% 速度観測ではこのUIOは構成できない
Dc = 0;
T = 0.001;
[A, B, ~, D] = c2dm(Ac,Bc, C, Dc, T);
[~, E, ~, ~] = c2dm(Ac,Ec, C, Dc, T);

%% シングルレートのUIO構成条件のチェック
%rank([eye(2); eye(2)*(A-E*inv((eye(2)*E)'*(eye(2)*E))*(eye(2)*E)'*eye(2)*A)]) %こっちはランク2なのでOK
%rank([[0 1]; [0 1]*(A-E*inv(([0 1]*E)'*([0 1]*E))*([0 1]*E)'* [0 1]*A)]) %こっちはランク1なのでNG
%rank([[1 0]; [1 0]*(A-E*inv(([1 0]*E)'*([1 0]*E))*([1 0]*E)'* [1 0]*A)]) %こっちはランク1なのでNG

%% 未知入力オブザーバの設計
i = 0.5; %(0<i<1)の範囲で設定する
[A_til, B_til, C_til, D_til] = c2dm(Ac,Bc, C, Dc, T*i);
[~, E_til, ~, ~] = c2dm(Ac,Ec, C, Dc, T*i);

invCE_til = inv(C*E_til);

L1 = E * invCE_til;
pole_uio = [0.9 0.8];
L2 = place((A - L1*C*A_til)', C', pole_uio)';
L3 = invCE_til * (C*A_til*C') * inv(C*C');
% L3=0;
A_hat = A - L1*C*A_til - L2*C;
B_hat = B - L1*C*B_til;

%% ダブルレートのUIO構成条件のチェック
%rank([[0 1]; [0 1]*(A-E*inv([0 1]*E_til)*[0 1]*A_til)]) %こっちはランク1なのでNG
%rank([[1 0]; [1 0]*(A-E*inv([1 0]*E_til)*[1 0]*A_til)]) %こっちはランク2なのでOK

%% 外乱オブザーバ 
A_dob = [A E;0 0 1]; B_dob = [B;0]; C_dob = [C 0]; D_dob=0; % 離散時間の拡大系
pole_dob = [0.9 0.8 0.7];
L_dob = place(A_dob', C_dob', pole_dob)';

%% シミュレーション実行
x0 = [0.1;0.1];
out = sim('sim_DOB_vs_UIO');

%% 結果の描画
lw = 1;
fig1 = figure;
subplot(2,1,1),plot(out.x.Time, out.d.Data,...
    out.d_hat_dob.Time, out.d_hat_dob.Data,...
    out.d_hat_uio.Time, out.d_hat_uio.Data,...
    'LineWidth',lw); grid on
graph_x1_1 = legend('d','DOB d', 'UIO d');
set(graph_x1_1,'Location','NorthEast');
title('Disturbance Estimation')
ylabel('d')
ylim([-0.2 1.2]);
subplot(2,1,2),plot(...
    out.dob_error_d.Time, out.dob_error_d.Data,...
    out.uio_error_d.Time, out.uio_error_d.Data,...
    'LineWidth',lw); grid on
graph_x1_2 = legend('DOB error d', 'UIO error d');
set(graph_x1_2,'Location','NorthEast');
ylabel('Estimation error of d')
ylim([-0.2 1.2]);
xlabel('Time[s]')


fig2=figure;
subplot(2,1,1),plot(out.x.Time, out.x.Data(:,1),...
    out.x_hat_dob.Time, out.x_hat_dob.Data(:,1),...
    out.x_hat_uio.Time, out.x_hat_uio.Data(:,1),...
    'LineWidth',lw); grid on
graph_x2_1 = legend('x','DOB x', 'UIO x');
set(graph_x2_1,'Location','NorthEast');
title('Position Estimation')
ylabel('x')
subplot(2,1,2),plot(...
    out.dob_error1.Time, out.dob_error1.Data,...
    out.uio_error1.Time, out.uio_error1.Data,...
    'LineWidth',lw); grid on
graph_x2_2 = legend('DOB error x', 'UIO error x');
set(graph_x2_2,'Location','NorthEast');
ylabel('Estimation error of x')
xlabel('Time[s]')

fig3=figure;
subplot(2,1,1),plot(out.x.Time, out.x.Data(:,2),...
    out.x_hat_dob.Time, out.x_hat_dob.Data(:,2),...
    out.x_hat_uio.Time, out.x_hat_uio.Data(:,2),...
    'LineWidth',lw); grid on
graph_x3_1 = legend('v','DOB v', 'UIO v');
set(graph_x3_1,'Location','NorthEast');
title('Velocity Estimation')
ylabel('v')
subplot(2,1,2),plot(...
    out.dob_error2.Time, out.dob_error2.Data,...
    out.uio_error2.Time, out.uio_error2.Data,...
    'LineWidth',lw); grid on
graph_x3_2 = legend('DOB error v', 'UIO error v');
set(graph_x3_2,'Location','NorthEast');
ylabel('Estimation error of v')
xlabel('Time[s]')
