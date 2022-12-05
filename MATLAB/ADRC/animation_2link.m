close all
% あらかじめADRC_2link_arm.mを実行しておく。
% ワークスペースに展開されたtheta1、theta2等々からアニメーションを描画
% ↓を参考にしました。
% https://fumikirinobouken.hatenablog.com/entry/2018/10/16/174553

hight = 300; % プロットするfigureの縦幅
width = 300; % プロットするfigureの横幅

sizen= 512; % rgb2ind()の関数でRGBイメージをインデックス付きイメージに変換する…らしい(よくわからん)。
            % ただ、gifにアニメーションとして保存するサイズに対してこのsizeが小さいと"権限がない"
            % とかのエラーがでる。そうなったらこのsizeを大きくしてみよう。

delaytime = 0.1; % 画像の更新間隔[s]         


% プロット＆保存 %%%%%%%%%%%%%%%

h = figure('Position',[100 100 width hight]);
axis tight manual % this ensures that getframe() returns a consistent size
filename = '2link_Animation.gif'; % 保存する名前
theta1 = out.theta1.Data;
theta2 = out.theta2.Data;
theta1_ref = out.theta1_ref.Data;
theta2_ref = out.theta2_ref.Data;
dec_size = uint32((length(out.theta1.Data)-1)/100); % アニメーションのデータレート
x1 = L1*sin(theta1);   
y1 = L1*cos(theta1); 
x2 = L2*sin(theta1+theta2);
y2 = L2*cos(theta1+theta2); 
x_ref = L1*sin(theta1_ref) + L2*sin(theta1_ref+theta2_ref);
y_ref = L1*cos(theta1_ref) + L2*cos(theta1_ref+theta2_ref); 
t = 0:Tsim:Tend;

for n = 1:dec_size
    % plot
    i = n*dec_size; % アニメーション用に間引いたデータの添え字
    plot([0,x1(i)],[0,y1(i)],'b-', 'LineWidth', 3) % 第1関節の描画
    hold on
    plot([x1(i),x1(i)+x2(i)],[y1(i),y1(i)+y2(i)],'g-', 'LineWidth', 3) % 第2関節の描画
    hold on
    plot(x_ref(i),y_ref(i),'ro', 'LineWidth', 2) % 手先指令位置の描画
    hold off
    txt = text(-1, -1, '', 'FontSize', 16); 
    txt.String = sprintf('t =  %0.1f [s]', t(i)); % 時刻を表示
    title('ADRC 2-Link Manipulator Animation')
%     if t(i)>=7
%         dist_txt = text(-1, -1.5, '', 'FontSize', 16); 
%         dist_txt.String = sprintf('disturbance'); % 時刻を表示
%     end
    ylabel('Position[m]')
    xlabel('Position[m]')
    ylim([-2 2])
    xlim([-2 2])
    drawnow % figureを更新する
    
    % Capture the plot as an image
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,sizen);
    % Write to the GIF File
    if n == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',delaytime);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',delaytime);
    end
end