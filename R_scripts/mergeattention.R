#让结合百度指数的文本分数和政府回应数据集merge
library(rio)
#opinres <- read.csv('./Datasets/Opinres.csv')
opinnew <- read.csv('./Datasets/opinion_gammabaidu.csv')
responses <- read.csv('./Datasets/Respons.csv')
respons_main <- responses[responses$主办或会办 == '主办', c(2:6)]
opinres_new <- merge(opinnew, respons_main, by = '建议编号' )
names(opinres_new)[which(names(opinres_new) == "正文.x")] <- "opinion_text"
names(opinres_new)[which(names(opinres_new) == "正文.y")] <- "response_text"
names(opinres_new)[which(names(opinres_new) == "advice_research_score.建议调研程度.15.")] <- "research_score"
opinres_new$result <- rep(NA, length(opinres_new$建议编号))
opinres_new$result[opinres_new$办理结果 == '解决采纳' | opinres_new$办理结果 == '计划解决' | opinres_new$办理结果 ==  '正在解决' ] <- 1
opinres_new$result[opinres_new$办理结果 == '留作参考' ] <- 0

write.csv(opinres_new, './Datasets/opinres_integrated.csv')