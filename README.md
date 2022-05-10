# 2F_hazard_rate
This repository contains code for the implementation of a credit risk model which estimates the probability of default given credit spreads and the term structure of default-free interest rates as input.

## The model
The model places in the finance literature as an hybrid approach to credit risk estimation. The seminal paper from Dilip Madan and Haluk Unal gives it the name of "A Two-Factor Hazard Rate Model for Pricing Risky Debt and the Term Structure of Credit Spreads"[^1].
In this approach the likelihood of default is captured by the firm's non-interest sensitive assets and default-free interest rate. This is the reason why it is an hybrid approach as it reconciles two sides of the literature: structural approaches, where default is a function of the company's balance sheet; hazard rate approaches, where default is an exogenous unpredictable event.

## Implementation
The code in this repository is a first attempt to implement the model on empirical data. We have a sample of rated firms with their credit spreads, assets and equity values used as inputs of the model. We also have a sovereign interest rate term structure which is fundamental. 
The probability of default is assumed as the probability of losses exceeding the firm's equity. The equity itself is modeled as composed of both cash and interest sensistive assets less liabilities. It is straightforward that the two-factor risk driving credit spreads are the value of cash assets and the level of stochasting default-free interest rates.
By calibrating the parameters on credit spreads term structures the model can be readily implemented and gives an overview of the structural determinants of default.
To model interest rates the one-factor short-rate model of Vasicek[^2] was used.
The output of the two-factor hazard rate is an the istant probability of default itself, the credit spread and the corporate bond price term structures. Other interesting outputs are the loss level, the arrival rate of the loss, the rate of recovery, the duration gap and the volatility of cash assets.
![image](https://user-images.githubusercontent.com/104139268/167718499-d5dc01c6-79ed-48d7-a6a2-72b8bf333f72.png)


## Interesting results
As the model was implemented on empirical data, interesting results emerged. First, the model was able to capture, during the Covid period, an increase in the likelihood of default for hospitality, transport, and retail companies. 
![image](https://user-images.githubusercontent.com/104139268/167718356-02d7eb3a-2991-4c49-869b-ab4e950c809a.png)

Second, simulating term structures it is found that an inverted yield curves is more likely to increase the probability of default for low-rated companies.

![image](https://user-images.githubusercontent.com/104139268/167718285-692305fe-ddaf-44f0-8856-5ddbac6ca6ff.png) 
![image](https://user-images.githubusercontent.com/104139268/167718314-d02e28b7-3da1-4fc7-9b9f-1effbf25b831.png)




[^1]: Madan, D. and Unal, H. (2000). A two-factor hazard rate model for pricing risky debt and the term structure of credit spreads. Journal of Financial and Quantitative analysis, pages 43–65. 

[^2]: Vasicek, O. (1977). An equilibrium characterization of the term structure. Journal of ﬁnancial economics, 5(2):177–188.

