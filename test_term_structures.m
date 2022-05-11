clear all
maturities = [0.5,1,2,3,5,7,10,20,30];
yields = [-0.00257, -0.00105,-0.00115,0.0090,0.0115,0.0213,0.0352,0.0377,0.0411]; 
params = VasicekOptim(maturities, yields);
term_structure_simulation;
yields_sim = SimPaths(:,:,1);

for n =1:size(yields_sim,1)
    try
        params(n) = VasicekOptim(maturities, yields_sim(n,:));
    catch
        params(n) = NaN;
    end
    params(n).r0 = yields_sim(n,1);
    vasicek_bondPrices(n,:) = UnitDiscBondVasicek(maturities,params(n));
    vasicek_yields(n,:)	= CalcDiscountBondYield(maturities,vasicek_bondPrices(n,:));
    real_bondPrices(n,:) = exp(-yields_sim(n,:).*maturities);
end
    
%import CDS and company data
List = readtable('DB.xlsx');
List(:,10) = [];


for n = 1:size(List,1)
    for k = 1:size(params,2)
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
params(k).theta	= params(k).theta* params(k).kappa;
g = NaN(size(List,1),size(maturities,2),size(params,2));
v = NaN(size(List,1),size(maturities,2),size(params,2));
ist = NaN(size(List,1),1,size(params,2));
cs = NaN(size(List,1),size(maturities,2),size(params,2));
end
end

for n = 1:size(List,1)
    for k = 1:size(params,2)
        [g(n,:,k),v(n,:,k),ist(n,1,k),cs(n,:,k)] = madan_unal(params(k), mu, lamb, y, D,sigma, ds(n),mrktMaturities,vasicek_bondPrices(k,:));
   
        ds(n).g(1,:,k) = g(n,:,k);
        ds(n).v(1,:,k) = v(n,:,k);
        ds(n).ist(1,1,k) = ist(n,1,k);
        ds(n).cs(1,:,k) = cs(n,:,k);
    end
end

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
     for k=1:size(params,2)
   
params0 = params;
aux(x0, params(k), ds(n),mrktMaturities,vasicek_bondPrices(k,:),ds(n).csmrkt)
ds = ds;

%x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub)
    try
        [x(n,:,k),fval,ds(n).exitflag(1,:,k),output] =  fmincon(@(x)aux(x, params0(k), ds(n),mrktMaturities,vasicek_bondPrices(k,:),ds(n).csmrkt), x0,[],[],[],[],LB,UB,[],options);
    catch
        x(n,:,k) = NaN;
    end

ds(n).mu(1,1,k) = x(n,1,k);
ds(n).lambd(1,1,k) = x(n,2,k);
ds(n).y(1,1,k) = x(n,3,k);
ds(n).D(1,1,k) = x(n,4,k);
ds(n).sigma(1,1,k) = x(n,5,k);

%params, very_good, cs_aa);
[ds(n).g(1,:,k),ds(n).v(1,:,k),ds(n).ist(1,1,k),ds(n).cs(1,:,k)]= madan_unal(params(k), x(n,1,k), x(n,2,k), x(n,3,k), x(n,4,k),x(n,5,k), ds(n),mrktMaturities,vasicek_bondPrices(k,:));
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
 end
 
 
%  %TODO: Table to finish


   a = zeros(size(List,1), 70);
  for n=1:size(List,1)
      for k=1:size(params,2)
  a(1:size(List,1),1:10) = reshape([ds.ist], size(List,1),10);
  a(1:size(List,1),11:10*2) = reshape([ds.mu], size(List,1),10);
  a(1:size(List,1),21:10*3) = reshape([ds.lambd], size(List,1),10);
  a(1:size(List,1),31:10*4) = reshape([ds.y], size(List,1),10);
  a(1:size(List,1),41:10*5) = reshape([ds.D], size(List,1),10);
  a(1:size(List,1),51:10*6) = reshape([ds.sigma], size(List,1),10);
   a(1:size(List,1),61:10*7) = 1./reshape([ds.lambd], size(List,1),10);
      end
  end
a = array2table(a);
a.firm = [ds.firm]';
a.rating = [ds.rating]'; 
a = movevars(a, 'firm', 'Before', 'a1');
a = movevars(a, 'rating', 'Before', 'a1');

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

