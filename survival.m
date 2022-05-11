function surv = survival(params, maturities, lamb, mu, D, sigma, company)
E = company.E;
V = company.V;
EV = company.EV;
%gr = company.gr;
%vr = company.vr;
rho = company.rho;
%sigma = company.sigma;

%----------------------------------

% %    Parameters
% %   ----------
% %  params = parameters estimated from the Vasicek model
%     lamb = the arrival rate of the Loss, it's from the Poisson distribution
%     mu = mean of the loss distribution
%     D = duration
%     company = is a dictionary where the following informations are stored:
%     E = level of equity
%     V = level of assets
%     EV = sensitivity of equity to cash assets
%     gr = growth opportunities, sensitive assets
%     vr = sensitive liabilities
%     rho = correlation between assets and interest rates
%     sigma = volatility of cash assets
% 
%     Returns an array with survival probabilities
%     -------
% 
%     %%%

r0 = params.r0;
theta = params.theta;
kappa = params.kappa;
eta = params.eta;

%mu is the mean for the exponential distribution for the Loss
%definition of a,b,c terms
%b = lamb* (exppdf(E,mu))* EV;
b = lamb/mu* (exp(-E/mu))* EV*V;

c = (b/(EV*V))* D;
a = lamb* (1-expcdf(E,mu))+b* log(V)-c* r0;

%definitions that go inside the bigger term H
    f1 = (b^2.* eta^2)/kappa^2 - (2.* b.* rho.* c.* eta^2)/kappa^3 - (2.* b.* rho.* c.* sigma.* eta)/kappa^2;
    f2 = - (b^2.* eta^2)/kappa^3 - (b^2.* rho.* sigma.* eta)/kappa^2;
    f3 = 1/3.*   ((b^2.* eta^2)/kappa^2 + (2.* b^2.* rho.* sigma.* eta)/kappa + b^2.* sigma^2);

    g1 = -(4.* b.* c.* eta^2)/kappa^3 - (2.* b^2.* eta^2)/kappa^4 - (2.* b^2.* rho.* sigma.* eta)/kappa^3;
    g2 = (b.* c.* eta^2)/kappa^2 + (b.* rho.* sigma.* c.* eta)/kappa;
    g3 = (c^2.* eta^2)/kappa^2;

    h1 = (2.* b.* c.* eta^2)/kappa^4 - (2.* b^2.* eta^2)/kappa^3 + (2.* b.* c.* eta^2)/kappa^4 + (2.* b^2.* eta^2)/kappa^4 + (2.* b.* c.* rho.* sigma.* eta)/kappa^3 + (2.* b^2.* rho.* sigma.* eta)/kappa^3;
    h2 = (c^2.* eta^2)/kappa^3 + (b^2.* eta^2)/kappa^3;
    h3 = (2.* b.* c.* eta^2)/kappa^4 - (2.* c^2.* eta^2)/kappa^3; %edited eta*2 in eta^2

    n = (1-exp(-kappa.* maturities))/kappa;

    H = -(theta/kappa - eta^2/kappa^2).*  (c.* maturities - c.* n - (b.* (maturities.^2))/2 + b/kappa.*  (maturities - n)) - ...
        (eta^2/(2.* kappa^2)).*  c.* exp(-kappa.* maturities).*  ((exp(kappa.* maturities) + exp(-kappa.* maturities)-2)/kappa) - ...
        b.* exp(-kappa.* maturities).*  ((exp(kappa.* maturities) - exp(-kappa.* maturities))/kappa^2 - 2.* maturities/kappa) - ... 
        (b.* sigma^2.* maturities.^2)/4 - (b.* rho.* sigma.* eta.* maturities.^2)/(2.* kappa) +- ((b.* rho.* sigma.* eta.* exp(-kappa.* maturities))/kappa^2).*  ((exp(kappa.* maturities)-1)/kappa - maturities) + ...
        maturities/2.*   (f1 + f2.* maturities + f3.* maturities.^2) + (maturities.* exp(-kappa.* maturities))/2.* (g1+g2.* maturities+g3.* exp(-kappa.* maturities)) + ...
        (kappa.* n)/2.*   (h1 + h3.* exp(-kappa.* maturities)) + h2/2.*   (1 - exp(-2.* kappa.* maturities));

        surv = exp(H - a.* maturities + b.* maturities * log(V) - ((c*(1-exp(-kappa.*maturities))./kappa)-(b.*maturities)/kappa + ((b*(1-exp(-kappa.*maturities)))/kappa)*r0)); %     surv = exp(H - a.* maturities + b.* maturities * log(V) - ((b+c).* n - b/kappa.*   maturities)* r0);
    

