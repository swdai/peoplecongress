library(stargazer)
library(aod)
require(mfx)
#sink('./Logs/log_OLSestimation.txt')
#opinres_new <- read.csv('./Datasets/opinres_integrated.csv')

#议题分布假设 OLS
top_olsfit <- lm (result ~ research_score + Topic2 + Topic3 + Topic4 + Topic5 + Topic6 + Topic7 + Topic8 +
  Topic9 + Topic10 + Topic11 + Topic12 + Topic13 + Topic14 + Topic15 + Topic16 + Topic17 + Topic18 + Topic19 + Topic20 + Topic21 + Topic22 + Topic23 + Topic24 + Topic25 + Topic26 + Topic27 + Topic28 + Topic29 + Topic30, data = opinres_new)

#Probit Fit
top_glmfit <- glm (result ~ research_score + Topic2 + Topic3 + Topic4 + Topic5 + Topic6 + Topic7 + Topic8 + 
                     Topic9 + Topic10 + Topic11 + Topic12 + Topic13 + Topic14 + Topic15 + Topic16 + Topic17 + Topic18 + Topic19 + Topic20 + Topic21 + Topic22 + Topic23 + Topic24  + Topic25 + Topic26 + Topic27 + Topic28 + Topic29 + Topic30, data = opinres_new, family = binomial(link = 'probit'))

#对所有议题进行waldtest
testwald <- wald.test(Sigma = vcov(top_glmfit), b = coef(top_glmfit), Terms = 2:31)

#tablglmfit <- stargazer(top_glmfit, type = 'html', title = '基于OLS与Probit的线性概率回归分析', out = './test.html')

#公共回应性假设
opinres_new$lgdocindex <- log(opinres_new$docindex)
respons_olsfit <- lm (result ~ lgdocindex + research_score, data = opinres_new)
respons_glmfit <- glm (result ~ lgdocindex + research_score, data = opinres_new, family = binomial(link = 'probit'))
summary(respons_glmfit)
#Reporting partial effects at the average(PEA)
respons_newfit <- probitmfx(result ~ lgdocindex + research_score, data = opinres_new)


#sink()