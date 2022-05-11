# 2F_hazard_rate
This repository contains code for the implementation of a **credit risk model which estimates the probability of default** given credit spreads and the term structure of default-free interest rates as input.

## The model
The model places in the finance literature as an hybrid approach to credit risk estimation. The seminal paper from Dilip Madan and Haluk Unal gives it the name of *"A Two-Factor Hazard Rate Model for Pricing Risky Debt and the Term Structure of Credit Spreads"*[^1].
In this approach the likelihood of default is captured by the firm's non-interest sensitive assets and default-free interest rate. This is the reason why it is an hybrid approach as it reconciles two sides of the literature: structural approaches, where default is a function of the company's balance sheet; hazard rate approaches, where default is an exogenous unpredictable event.

## Implementation
The code in this repository is a first attempt to implement the model on empirical data. 
- We have a sample of rated firms with their credit spreads, assets and equity values used as inputs of the model. 
- We also have a sovereign interest rate term structure which is fundamental. 

The probability of default is assumed as the probability of losses exceeding the firm's equity. The equity itself is modeled as composed of both cash and interest sensistive assets less liabilities. It is straightforward that the two-factor risk driving credit spreads are the value of cash assets and the level of stochastic default-free interest rates.

<img src="https://latex.codecogs.com/png.image?\dpi{110}\bg{white}h(V(t),&space;r(t))&space;\simeq&space;h(V_{0},&space;r_{0})&space;-&space;\lambda&space;f(E_{0})&space;V_{0}&space;(\Delta&space;lnV)&space;-&space;\lambda&space;f(E_{0})&space;(g_{r}&space;-&space;\overset{-}{v}_{r})&space;(\Delta&space;r)" title="https://latex.codecogs.com/png.image?\dpi{110}\bg{white}h(V(t), r(t)) \simeq h(V_{0}, r_{0}) - \lambda f(E_{0}) V_{0} (\Delta lnV) - \lambda f(E_{0}) (g_{r} - \overset{-}{v}_{r}) (\Delta r)" />

By calibrating the parameters on credit spreads term structures the model can be readily implemented and gives an overview of the structural determinants of default.
To model interest rates the one-factor short-rate model of Vasicek[^2] was used.

<img src="https://latex.codecogs.com/png.image?\dpi{110}\bg{white}p(t,&space;\tau)&space;=&space;exp(A(\tau)-N(\tau)r(t))" title="https://latex.codecogs.com/png.image?\dpi{110}\bg{white}p(t, \tau) = exp(A(\tau)-N(\tau)r(t))" />

The output of the two-factor hazard rate is the istant probability of default itself, the credit spread and the corporate bond price term structures. Other interesting outputs are the loss level, the arrival rate of the loss, the rate of recovery, the duration gap and the volatility of cash assets. Here it is shown the hazard rate or the probability of default, which as expected increases at the worst ratings.

<image src="https://user-images.githubusercontent.com/104139268/167718499-d5dc01c6-79ed-48d7-a6a2-72b8bf333f72.png" alt="hazard rate" width="500"/>

## Interesting results
As the model was implemented on empirical data, interesting results emerged. First, the model was able to capture, during the Covid period, an increase in the likelihood of default for hospitality, transport, and retail companies. 

<image src="https://user-images.githubusercontent.com/104139268/167718356-02d7eb3a-2991-4c49-869b-ab4e950c809a.png" alt="covid effect" width="500"/>

Second, simulating term structures it is found that an inverted yield curves is more likely to increase the probability of default for low-rated companies.

<image src="https://user-images.githubusercontent.com/104139268/167718285-692305fe-ddaf-44f0-8856-5ddbac6ca6ff.png" alt="term structures" width="500"/>
<image src="https://user-images.githubusercontent.com/104139268/167718314-d02e28b7-3da1-4fc7-9b9f-1effbf25b831.png" alt="term structures effect" width="500"/>

## The code
The code reported is a collection of Matlab files and functions used to calibrate the model. Every sheet comes with a description.
The file `DB.xlsx` is the model input with company names, ratings, assets, equity values and CDS term structures.
The term structure needs to be updated in the main Matlab sheet discussed below.
The script `test2.m` is the main sheet where all the computation is done. You just need to run that in order to have the model outputs. The code creates a dictionary where all the variables/outputs are stored by company.

## Improvements
The model is in closed form and this makes it very handy its application. On the theoretical side it should take into account also coupons paid by the company on its debt and also it needs CDS data to be calibrated on. 
On the computational side it is very fast however the optimization is not always succesful, the last run has an `Exitflag = 1` for 109 observations over 139.
The model can be improved with different optimization options (here it is used a non-linear optimization function `fmincon` with the Levenberg-Marquardt algorithm)




[^1]: Madan, D. and Unal, H. (2000). A two-factor hazard rate model for pricing risky debt and the term structure of credit spreads. Journal of Financial and Quantitative analysis, pages 43–65. 

[^2]: Vasicek, O. (1977). An equilibrium characterization of the term structure. Journal of ﬁnancial economics, 5(2):177–188.

