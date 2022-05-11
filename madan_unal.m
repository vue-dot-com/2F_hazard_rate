
function [g,v,ist,cs] = madan_unal(params, mu, lamb, y, D,sigma, company,mrktMaturities,vasicek_bondPrices)
%%%
% This function provides the various findings of Madan Unal model. If you call this function.cs fitted on real 
% cs curve you are going to estimate parameters like lamb, mu, y, D.
% params = parameters estimated form the vasicek model
% mu = mean of the loss distribution
% lamb = arrival rate of the loss 
% y = rate of recovery
% D = duration
% vasicek = estimated Vasicek bond prices
% yields = estimate yields from the Vasicek model (risk free rates)
% company = a structure that contains Equity (E), Value of cash assets (V), sensitiblity of Equity
% to changes in cash assets (EV), growth opportunities or interest rate
% sensitive assets (gr), interest rate sensistive liabilities (vr), correlation 
%between assets and interest rates (rho), volatility of cash assets (sigma) 
%%%
%VasicekOptim;
g = survival(params, mrktMaturities, lamb,mu, D,sigma, company);

v = prisky(y, vasicek_bondPrices, g);

[ist,cs] = credit_spread(params, lamb,sigma,y, mrktMaturities, mu, D, company, g);



end


