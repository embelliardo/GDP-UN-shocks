%% data loading and preparation
clear; clc

[GDP quarter] = xlsread('data\GDPC1.xls','A12:B296'); %quarterly data from 01/47 to 01/18
UN = xlsread('data\UNRATE.xls','B12:B855');           %montly data from 01/48 to 04/18

% consider the series from 01/48, and transform UN in quarterly data
% averaging over 4 months: 1Q = avg from 01 to 03
%                          2Q = avg from 04 to 06 and so on...

GDP = GDP(5:end); % start from 1/48

for i = 1:ceil(length(UN)/3)              %transform in quarterly data
    q_UN(i) = mean(UN(3*i-2:min(3*i,length(UN)))); 
end

q_UN = (q_UN(1:end-1))';   % last obs is 2Q 2018 and has to be removed


% log transformation of the data
y = log(GDP);

for i = 1:length(y)-1
delta_y(i) = (y(i+1) - y(i))*100;
end

delta_y = delta_y';
u = q_UN(2:end);
data = [delta_y u];

quarter = quarter(6:end);
quarter= datenum(quarter,'dd/mm/yyyy');

% plotting the data
figure
plot(quarter,[data(:,1) data(:,2)]);
legend('GDP growth','UN rate')
title('GDP Growth and Unemployment Rate series')
datetick('x','yy','keeplimits')
grid on
print('plots\figure1','-dpng')

clearvars -except data;

%% 1) VAR estimation
VAR_coeff = VarEst(data,4);

%% 2) WOLD representation
WOLD = WoldEst(data,4,40);

%%
%plot the impulse response functions
x=linspace(0,39,40);

figure
subplot(2,2,1)
plot(x, [squeeze(WOLD(1,1,:)) cumsum(squeeze(WOLD(1,1,:)))],'LineWidth',1.50);
title('IRF of a GDP shock on GDP')
legend({'marginal','cumulative'},'Location','southeast')
legend('boxoff')
grid on

subplot(2,2,2)
plot(x, [squeeze(WOLD(1,2,:)) cumsum(squeeze(WOLD(1,2,:)))],'LineWidth',1.50);
title('IRF of a UN shock on GDP')
%legend('marginal effect','cumulative effect')
grid on

subplot(2,2,3)
plot(x, squeeze(WOLD(2,1,:)),'LineWidth',1.50);
title('IRF of a GDP shock on UN')

grid on

subplot(2,2,4)
plot(x, squeeze(WOLD(2,2,:)),'LineWidth',1.50);
title('IRF of a UN shock on UN')
grid on
print('plots\figure2','-dpng')

%% 2) Bootstrap IRF
B_boot=bootstrap(data,4,40,1000);

%%
%quantiles of the marginal IRFs
Q16 = quantile(B_boot, 0.16, 4); % 0.16 quantile along the 4th dimension
Q84 = quantile(B_boot, 0.84, 4);

%quantiles of the cumulative IRFs
Qsum16 = quantile(cumsum(B_boot,3), 0.16, 4);
Qsum84 = quantile(cumsum(B_boot,3), 0.84, 4);

%plot IRFs
figure 
subplot(2,2,1)
plot(x,cumsum(squeeze(WOLD(1,1,:))),'r',x, squeeze(Qsum16(1,1,:)), 'k--',... 
x,squeeze(Qsum84(1,1,:)),'k--','LineWidth',1.5);
title('Cumulative IRF of a GDP shock on GDP','FontSize',7)

subplot(2,2,2)
plot(x,cumsum(squeeze(WOLD(1,2,:))),'r',x, squeeze(Qsum16(1,2,:)), 'k--',... 
x,squeeze(Qsum84(1,2,:)),'k--','LineWidth',1.5);
title('Cumulative IRF of a UN shock on GDP','FontSize',7)

subplot(2,2,3)
plot(x,squeeze(WOLD(2,1,:)),'r',x, squeeze(Q16(2,1,:)), 'k--',... 
x,squeeze(Q84(2,1,:)),'k--','LineWidth',1.5);
title('IRF of a GDP shock on UN','FontSize',7)

subplot(2,2,4)
plot(x,squeeze(WOLD(2,2,:)),'r',x, squeeze(Q16(2,2,:)), 'k--',... 
x,squeeze(Q84(2,2,:)),'k--','LineWidth',1.5);
title('IRF of a UN shock on UN','FontSize',7)
print('plots\figure3','-dpng')

%% 3)Identification of structural shocks
% identify a shock that is the only one affecting TFP in the
% long run( SUPPLY SHOCK)

[~,Sigma,~,~] = VarEst(data,4);     % var/covar matrix of residuals

phi = sum(WOLD,3);

theta = chol(phi*Sigma*phi','lower');


B0 = inv(theta)*phi;

% identification of shocks
[~,~,eps,~] = VarEst(data,4);   % residuals
struct_eps = B0*eps';           % in this case the supply shock is the 
                                %1st row of struct_eps

for i = 1:40
B_str(:,:,i) = WOLD(:,:,i)*inv(B0);  %structural IRF
end


%% IRF bootstrap
Struct_Boot= struct_bootstrap(data,4,40,1000);

%%
%plot the IRF of GDP and UN to supply and demand shocks
%quantiles of the marginal IRFs
Q16_s = quantile(Struct_Boot, 0.16, 4); % 0.16 quantile along the 4th dimension
Q84_s = quantile(Struct_Boot, 0.84, 4);

%quantiles of the cumulative IRFs
Qsum16_s = quantile(cumsum(Struct_Boot,3), 0.16, 4);
Qsum84_s = quantile(cumsum(Struct_Boot,3), 0.84, 4);

figure
subplot(2,2,1)
plot(x,cumsum(squeeze(B_str(1,1,:))),x, squeeze(Qsum16_s(1,1,:)), 'k--',... 
x,squeeze(Qsum84_s(1,1,:)),'k--','LineWidth',1.5);
title('IRF of a supply shock on GDP','FontSize',7)

subplot(2,2,2)
plot(x,squeeze(B_str(2,1,:)),x, squeeze(Q16_s(2,1,:)),'k--',...
x,squeeze(Q84_s(2,1,:)),'k--','LineWidth',1.5);
title('IRF of a supply shock on UN','FontSize',7)

subplot(2,2,3)
plot(x,-cumsum(squeeze(B_str(1,2,:))),x, squeeze(-Qsum16_s(1,2,:)), 'k--',... 
x,squeeze(-Qsum84_s(1,2,:)),'k--','LineWidth',1.5);
title("IRF of a demand shock on GDP",'FontSize',7)

subplot(2,2,4)
plot(x,squeeze(-B_str(2,2,:)),x, squeeze(-Q16_s(2,2,:)),'k--',...
x,squeeze(-Q84_s(2,2,:)),'k--','LineWidth',1.5);
title('IRF of a demand shock on UN','FontSize',7)

print('plots\figure4','-dpng')

%% 4) Plot and correlation of structural shocks

figure
subplot(2,1,1)
plot([struct_eps(1,:)],'r')
title('Aggregate supply shock')
subplot(2,1,2)
plot([struct_eps(2,:)],'b')
title('Aggregate demand shock')
print('plots\figure5','-dpng')

%correlation
str_corr = corr(struct_eps(1,:)',struct_eps(2,:)');

%% 5) Variance explained by supply shock (horizon 1,8,40)

% variance at horizon 1 due to supply shock
var_gdp_1_supply = B_str(1,1,1)^2;
var_un_1_supply = B_str(2,1,1).^2;

%variance at horizon 1 due to any shock
var_gdp_1 = sum(B_str(1,:,1).^2);
var_un_1 = sum(B_str(2,:,1).^2);

%percentage of variance of GDP and UN explained by the aggregate supply shock
perc_var_1 = [(var_gdp_1_supply/var_gdp_1) (var_un_1_supply/var_un_1)];


%%
% variance at horizon 8 due to supply shock
var_gdp_8=[0 0]; var_un_8=[0 0];
sumB_supp=cumsum(B_str,3);
for i=1:8
    var_gdp_8=var_gdp_8+sumB_supp(1,:,i).^2;
    var_un_8=var_un_8+B_str(2,:,i).^2;
end

perc_var_8 = [(var_gdp_8(1)/sum(var_gdp_8)) (var_un_8(1)/sum(var_un_8))];

%%
% variance at horizon 40 due to supply shock
var_gdp_40=[0 0]; var_un_40=[0 0];

for i=1:40
    var_gdp_40=var_gdp_40+sumB_supp(1,:,i).^2;
    var_un_40=var_un_40+B_str(2,:,i).^2;
end

perc_var_40 = [(var_gdp_40(1)/sum(var_gdp_40)) (var_un_40(1)/sum(var_un_40))];
