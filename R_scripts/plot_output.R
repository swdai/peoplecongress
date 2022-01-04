library(stargazer)

#Table 1: STM Evaluation Table

#Table 2: Topic Proportions 画表
topiccsv <- read.csv('./datasets/baiduin.csv')

#Topic Proportion的图
png('./plots/TopicProportion.png')
showtext_auto(enable = TRUE)
font_add('Songti', 'songti.ttc')
topicprop <- plot.STM(topic_model, type = 'summary', family = 'Songti', 
                      title = "表2:S省人大代表建议议题分布")
dev.off()

#Table 3: Summary statistics: research score, result, docindex
df_table3 <- opinres_new[, c("research_score", "result", "lgdocindex")]
table3 <- stargazer(df_table3, type = 'text', title = '表3: 描述性统计', out = './Tables/Table3.html', summary.stat = c('n', 'mean', 'sd', 'min', 'max'))

#Table 4: Regression Tables
#4, 7,8,9,16, 30显著
#no.space移除所有空行
table4 <- stargazer(top_glmfit, respons_glmfit, title = "表4: 回归分析表格", 
                    order = c('research_score', 'lgdocindex'), style = 'default', 
                    dep.var.labels = c('办理结果'), covariate.labels = c('建议调研程度', '建议关注度'), align = TRUE, no.space = TRUE, out = './Tables/Table4.html')

#统计主题4, 7, 8, 16, 30的承办单位
unitstat4 <- subset(opinres_new, Topic4 > 0.5 , select = c(建议编号, 承办单位名称, result))
unitstat4$topic <- '道路交通管理'
unitstat7 <- subset(opinres_new, Topic7 > 0.5 , select = c(建议编号, 承办单位名称, result))
unitstat7$topic <- '城市景观与旅游'
unitstat8 <- subset(opinres_new, Topic8 > 0.5, select = c(建议编号, 承办单位名称, result))
unitstat8$topic <- '轨道交通管理'
unitstat16 <- subset(opinres_new, Topic16 > 0.5, select = c(建议编号, 承办单位名称, result))
unitstat16$topic <- '教育'
unitstat30 <- subset(opinres_new, Topic30 > 0.5, select = c(建议编号, 承办单位名称, result))
unitstat30$topic <- '应急急救'
rej_df <- rbind(unitstat4, unitstat7, unitstat8, unitstat16, unitstat30)
write.csv(rej_df, './tables/Table5_ori.csv')
rej_rate <- rej_df %>% count(承办单位名称, sort = TRUE)
rej_rate$rate <- rep(0, length(rej_rate$承办单位名称))
for (i in rej_rate$承办单位名称) {
  rej_rate$rate[rej_rate$承办单位名称 == i] <- mean(rej_df$result[rej_df$承办单位名称 == i])
  
}
write.csv(rej_rate, './tables/Table5.csv')
