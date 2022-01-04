mypacs <- c('stm', 'tidyverse', 'sysfonts', 'showtextdb', 'showtext')
lapply(mypacs, library, character.only = TRUE)
sink('./Logs/stmlog.txt')
#set.seed(243)
#从stm_optimization.R中获得K的结果
stmK <- 30

#estimate topic model
topic_model <- stm(text_dfm, K= stmK, init.type = 'Spectral', data = opinion, verbose = FALSE, seed = 243)

#找出每一个topic的Highest prob words和对应的文本
topic_aggrelist <- c(rep('', stmK))
topic_list <- labelTopics(topic_model, n = 7)
for (i in 1:stmK) { 
  topic_aggrelist[i] <- findThoughts(topic_model, texts = opinion$正文, n = 5, topics = i)$docs[[1]]
  cat("Topic", i, topic_aggrelist[i])
}

#Draw the topic proportions
png('./Plots/TopicProportion.png')
showtext_auto(enable = TRUE)
font_add('Songti', 'songti.ttc')
topicprop <- plot.STM(topic_model, type = 'summary', family = 'Songti')
dev.off()
#改用ggplot实现
#ggsave('./Plots/topicprop.png', plot = topicprop)


#找出每一个文本的topic distribution, 新建df为topic_prob
topic_gammatd <- tidy(topic_model, matrix = 'gamma')
#读取百度指数的数据，合并到topic_problist
baiduincsv <- read.csv("./Datasets/baiduin.csv")[, 1:3]
topic_problist <- merge(topic_gammatd, baiduincsv, by = 'topic')
write_csv(topic_problist, './Datasets/topic_problist.csv')
#创建新变量docindex：topic的最高关注度*topic gamma
topic_problist$topdocindex <- topic_problist$gamma * topic_problist$maxattention
#如果包含1%含量及以上的topic，就加入计算
#for (i in 1:max(topic_problist$document)) {
  #if (topic_problist$gamma[i] < 0.01) {
    #topic_problist$topdocindex[i] <- 0
  #}
#}

#make.dt 也可以做到
topic_gammadt <- make.dt(topic_model)
for (m in 1:max(topic_problist$document)) {
  topic_gammadt$docindex[topic_gammadt$docnum == m] <- sum(topic_problist$topdocindex[topic_problist$document == m])
}
source('./R scripts/Truncate.R')

#Topic 3是执法(虐待动物，互联网盗版网站/色情，家电），Topic 24是监管（民用无人机等等）
#Tidy 回来
td_pct <- tidy(topic_model)

#返回到opinion dataset里
#topic_problistpremerge <- subset(topic_problist, select = c(document, docindex))
opinion_premerge <- subset(opinion, select = c("建议编号", "advice_research_score.建议调研程度.15."))
names(opinion_premerge)[which(names(opinion_premerge) == "advice_research_score.建议调研程度.15.")] <- "research_score"
opinion_gammatable <- merge(opinion_premerge, topic_gammadt, by.x = "建议编号", by.y = "docnum")
#opinion_gammatable$docindex <- rep('', length(opinion_gammatable$建议编号))
#for (i in 1:length(opinion_gammatable$建议编号)) {
 # opinion_gammatable$docindex[i] <- topic_problist$docindex[topic_problist$document == i]
#}
#opinion_gammabaidu <- merge(opinion_gammatable, topic_problistpremerge, by.x = "建议编号", by.y = "document")
#opinion_gammabaidu <- opinion_gammabaidu[unique(opinion_gammabaidu$建议编号), ]
write_csv(opinion_gammatable, './Datasets/opinion_gammabaidu.csv')

sink()
##topic_model <- stm(text_dfm, K=50, init.type = 'LDA', verbose = FALSE, seed = 243)
##init.type = 'LDA',

