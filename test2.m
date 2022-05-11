clear all

%Create mrktMaturities vector (taus) for our yield curve
mrktMaturities = [0.5,1,2,3,5,7,10,20,30];

%Create mrktYield vector for such maturities
mrktYields = [-0.00257, -0.00105,-0.00115,0.0090,0.0115,0.0213,0.0352,0.0377,0.0411]; 

% mrktYields = mrktYields.*(1+rand(1,9)); %try this to simulate an
% increase in interest rates and see what happens to credit spreads

params = VasicekOptim(mrktMaturities, mrktYields);
vasicek_bondPrices = UnitDiscBondVasicek(mrktMaturities,params);
vasicek_yields	= CalcDiscountBondYield(mrktMaturities,vasicek_bondPrices);
real_bondPrices = exp(-mrktYields.*mrktMaturities);
figure(1)
subplot(1,2,1)
plot(mrktMaturities, real_bondPrices, 'o', 'MarkerFaceColor', 'r')
hold on
plot(mrktMaturities, vasicek_bondPrices, '-b')
xlabel('Maturities')
ylabel('Prices')
title('Real bond prices Vs Estimated')
legend('Real bond price','Estimated bond price')
subplot(1,2,2)
plot(mrktMaturities, mrktYields, 'o', 'MarkerFaceColor', 'r')
hold on 
plot(mrktMaturities, vasicek_yields, '-b')
xlabel('Maturities')
ylabel('Yields')
title('US term structure Vs Estimated')
legend('US term structure', 'Estimated term structure')

%import CDS and company data
List = readtable('DB.xlsx');
List(:,10) = [];


for n = 1:size(List,1)
ds(n).firm = List.Company(n);
ds(n).rating = List.CreditRating(n);
ds(n).V = List.Current_Assets(n)/1000;
ds(n).EV = 1; 
%very_good.vr = 1;
%very_good.gr = 0.05;
%very_good.vr = 1;
%very_good.E = very_good.V+very_good.gr-very_good.vr 
ds(n).E= List.Equity(n)/1000;
ds(n).rho = 0;
ds(n).csmrkt = table2array(List(n,7:end));


lamb = 0.01; %arrival rate of the loss 
mu = 0.5; %mean loss level
y = 0.55; %rate of recovery
D = 1; %duration
sigma = 0.01; % volatility of assets 
%notes:		Considers the short-term risk-free interest rate dynamics
%				(in the risk-neutral measure!!)
%				to be described by the following stochastic equation:
%				[dr = kappa*(theta - r0)*dt + eta*dZ].
%				See Hull's Options Futures and Other Derivatives v6
%				Equation 23.6
%				Some bond pricing formulas use the alternative notation:
%				[dr = (alpha - beta*r0)*dt + eta*dZ]
%				We must be aware of these instances and work around them when 
%				calculating our prices!! Transformation is:
%				alpha	= kappa*theta
%				beta	= kappa	params.r0		= pars(1);
params.theta	= params.theta* params.kappa;
g = [];
v = [];
ist = [];
cs = [];
[ds(n).g,ds(n).v,ds(n).ist,ds(n).cs] = madan_unal(params, mu, lamb, y, D,sigma, ds(n),mrktMaturities,vasicek_bondPrices);
end

%fun = @(x) madan_unal(params,mu, lamb, y, D , very_good).cs - cs_aa;

fun = @(x) aux(x, params, ds,mrktMaturities,ds.mrktcs);

x0=[mu,lamb,y,D,sigma]; 
LB=[0,0,0,-6,0]; %[0,0,0,-10,0]
UB=[1,1,0.5,6,1]; %[1,1,0.5,10,1]
options = optimset('fmincon');
   %     options.TolFun		= 1e-6;
    %   options.MaxFunEvals = 4*800;
    %       options.TolX = 1e-20;
     %   options.MaxIter = 12000;

%x0 = [1,1,1,1];
 count = 1;
for n=1:size(List,1)
   
params0 = params;
aux(x0, params, ds(n),mrktMaturities,vasicek_bondPrices,ds(n).csmrkt)
ds = ds;

%x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub)

[x,fval,ds(n).exitflag,output] =  fmincon(@(x)aux(x, params0, ds(n),mrktMaturities,vasicek_bondPrices,ds(n).csmrkt), x0,[],[],[],[],LB,UB,[],options);

ds(n).mu = x(1);
ds(n).lambd = x(2);
ds(n).y = x(3);
ds(n).D = x(4);
ds(n).sigma = x(5);

%params, very_good, cs_aa);
[ds(n).g,ds(n).v,ds(n).ist,ds(n).cs]= madan_unal(params, x(1), x(2), x(3), x(4),x(5), ds(n),mrktMaturities,vasicek_bondPrices);
count = count+1
%  figure(n+1);
%  plot(mrktMaturities, ds(n).csmrkt, 'o', 'MarkerFaceColor', 'r');
%  hold on
%  plot(mrktMaturities, ds(n).cs, '-b');
%  xlabel('Maturities');
%  ylabel('CDS');
%  title({['Real CDS Vs Estimated for ', ds(n).firm{1}];...
%      [' Credit Rating = ', ds(n).rating{1}]
%      ['\mu = ',num2str(ds(n).mu),' \lambda = ',num2str(ds(n).lambd), ' y = ',num2str(ds(n).y ), ' D = ',num2str(ds(n).D), ' \sigma = ',num2str(ds(n).sigma)]});
%  legend('Real CDS','Estimated CDS');
% ds(n).figure = figure(n+1);

end

db = table([ds.firm]',[ds.rating]',[ds.ist]',[ds.mu]',[ds.lambd]',[ds.y]',[ds.D]',[ds.sigma]',[ds.exitflag]', 1./[ds.lambd]');
db_estimates = table([ds.g]',[ds.v]',[ds.cs]', [ds.csmrkt]');
disp(['Exitflags == 1 are: ' num2str(sum(db.Var9==1))])
figure(2)
subplot(2,4,1)
plot(db.Var3)
subplot(2,4,2)
plot(db.Var4)
subplot(2,4,3)
plot(db.Var5)
subplot(2,4,4)
plot(db.Var6)
subplot(2,4,5)
plot(db.Var7)
subplot(2,4,6)
plot(db.Var8)
subplot(2,4,7)
plot(db.Var10)
%plot some firms credit spreads representative of every rating class
 i = [3, 6, 10, 27, 36, 57, 95, 112, 123, 127, 132, 134, 136]
 figure(6)
 n=10
% for n=1:4
% subplot(2,2,n)
 plot(mrktMaturities, ds(i(n)).csmrkt, 'o', 'MarkerFaceColor', 'r');
 hold on
 plot(mrktMaturities, ds(i(n)).cs, '-b');
 xlabel('Maturities');
 ylabel('CDS');
 title({['Real CDS Vs Estimated for ', ds(i(n)).firm{1}];...
 [' Credit Rating = ', ds(i(n)).rating{1}]
 ['\mu = ',num2str(ds(i(n)).mu),' \lambda = ',num2str(ds(i(n)).lambd), ' y = ',num2str(ds(i(n)).y ), ' D = ',num2str(ds(i(n)).D), ' \sigma = ',num2str(ds(i(n)).sigma)]});
 legend('Real CDS','Estimated CDS')
 %end
% figure(4)
% j=1
% for n=5:8
% subplot(2,2,j)
% plot(mrktMaturities, ds(i(n)).csmrkt, 'o', 'MarkerFaceColor', 'r');
% hold on
% plot(mrktMaturities, ds(i(n)).cs, '-b');
% xlabel('Maturities');
% ylabel('CDS');
% title({['Real CDS Vs Estimated for ', ds(i(n)).firm{1}];...
% [' Credit Rating = ', ds(i(n)).rating{1}]
% ['\mu = ',num2str(ds(i(n)).mu),' \lambda = ',num2str(ds(i(n)).lambd), ' y = ',num2str(ds(i(n)).y ), ' D = ',num2str(ds(i(n)).D), ' \sigma = ',num2str(ds(i(n)).sigma)]});
% legend('Real CDS','Estimated CDS')
% j=j+1
% end
% figure(5)
% j=1
% for n=9:12
% subplot(2,2,j)
% plot(mrktMaturities, ds(i(n)).csmrkt, 'o', 'MarkerFaceColor', 'r');
% hold on
% plot(mrktMaturities, ds(i(n)).cs, '-b');
% xlabel('Maturities');
% ylabel('CDS');
% title({['Real CDS Vs Estimated for ', ds(i(n)).firm{1}];...
% [' Credit Rating = ', ds(i(n)).rating{1}]
% ['\mu = ',num2str(ds(i(n)).mu),' \lambda = ',num2str(ds(i(n)).lambd), ' y = ',num2str(ds(i(n)).y ), ' D = ',num2str(ds(i(n)).D), ' \sigma = ',num2str(ds(i(n)).sigma)]});
% legend('Real CDS','Estimated CDS')
% j=j+1;
% end
% figure(6)
% j=1
% for n=13
% subplot(2,2,j)
% plot(mrktMaturities, ds(i(n)).csmrkt, 'o', 'MarkerFaceColor', 'r');
% hold on
% plot(mrktMaturities, ds(i(n)).cs, '-b');
% xlabel('Maturities');
% ylabel('CDS');
% title({['Real CDS Vs Estimated for ', ds(i(n)).firm{1}];...
% [' Credit Rating = ', ds(i(n)).rating{1}]
% ['\mu = ',num2str(ds(i(n)).mu),' \lambda = ',num2str(ds(i(n)).lambd), ' y = ',num2str(ds(i(n)).y ), ' D = ',num2str(ds(i(n)).D), ' \sigma = ',num2str(ds(i(n)).sigma)]});
% legend('Real CDS','Estimated CDS')
% j=j+1;
% end
%mean_square_error = zeros(1,numel(ds));
%for n=1:numel(ds)
%    mean_square_error(n)=((sum(ds(n).csmrkt-ds(n).cs)^2)/numel(ds(1).cs));
%end
% Create axes
% axes1 = axes('Parent',figure1);
% hold(axes1,'on');
% 
% % Create multiple lines using matrix input to plot
% plot1 = plot(mrktMaturities,[cs;cs_aa],'MarkerFaceColor','auto','Marker','square');
% set(plot1(1),'DisplayName','CS estimated yield curve');
% set(plot1(2),'DisplayName','Market cs');
% 
% % Create ylabel
% ylabel({'Yields'});
% 
% % Create xlabel
% xlabel({'Maturities'});
% 
% % Create title
% title({'cs'});
% 
% box(axes1,'on');
% hold(axes1,'off');
% % Create legend
% legend1 = legend(axes1,'show');
% set(legend1,'Location','northwest');


function err=aux(x, params, very_good,mrktMaturities,vasicek_bondPrices,cs_aa)
mu=x(1);
lamb=x(2);
y=x(3);
D=x(4) ;
sigma=x(5);
[g,v,ist,cs]=madan_unal(params,mu, lamb, y, D ,sigma, very_good,mrktMaturities,vasicek_bondPrices);
%err=sum(100*((cs-cs_aa)./cs_aa).^2);
err=sum((cs_aa-cs).^2);
end