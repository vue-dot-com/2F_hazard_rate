function v = prisky(y, p_riskfree, company_survival)

%%Parameters
%-------------- 
% y = the rate of recovery
% p_riskfree = the price of the risk free bond in Vasicek (defined as theoreticalprice)
% company_survival = the survival probability g that we have estimated with
% the function survival

% Returns a price for the risky bond
%-------------- 

v = y.*p_riskfree + p_riskfree.*(1-y).*company_survival;
