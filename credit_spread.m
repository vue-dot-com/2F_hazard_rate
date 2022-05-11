function [cs_instant, cs_term] = credit_spread(params, lamb,sigma,y, maturities, mu, D, company, g)
E = company.E;
V = company.V;
EV = company.EV;
%gr = company.gr;
%vr = company.vr;
rho = company.rho;
%sigma = company.sigma;

r0 = params.r0;
theta = params.theta;
kappa = params.kappa;
eta = params.eta;

%b = lamb.* (exppdf(E,mu)).* EV;
%c = - b/EV.* D;
%a = lamb.* (1-expcdf(E,mu))+b.* log(V)-c.* r0;
b = lamb/mu* (exp(-E/mu))* EV*V;
c = (b./(EV*V))* D;
a = lamb* (1-expcdf(E,mu))+b.* log(V)-c.* r0;
cs_instant = a - b .* log(V) + c.*r0 + ...
         1/kappa^2 * (b.*theta + eta.*b*rho.*c*(1-sigma) + eta^2 .*c) + ...
         1/kappa^3 * (eta* b.^2 *rho - eta^2*b.^2 - eta^2*b - eta^2.*b.*c*(1-rho)) + ... %deleted - eta^2*b because it was repeated
         1/kappa^4 * (eta^2 * b.^2);
     
cs_term = -log(y+(1-y).*g)./ maturities;   % cs_term = (-(log(v) ./ maturities) - yields);
end

 
     

