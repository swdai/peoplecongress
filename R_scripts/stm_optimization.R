library(stm)

#search K process
stmKopti <- c(10, 15, 20, 25, 30, 35, 40)
out <- ''
dfopti <- searchK(text_stmdoc, text_stmvocab, stmKopti, data = text_stmmeta)
dfopti_df <- dfopti$results #优化的结果，class为df
#用base R画图
png('./Plots/dfoptiplot.png')
dfoptiplot <- plot(dfopti)
dev.off()

#用ggplot画图
#residual plot
plot_resi <- ggplot(data = dfopti_df, aes(x = as.numeric(K), y= as.numeric(residual))) +
  geom_line() +
  xlab('主题数量（K）')  +
  ylab('残差') +
  ggtitle('图1: 主题模型的残差分析') +
  theme(text = element_text(family='Songti', size = 16))
ggsave('./Plots/plot_resi.png', plot = plot_resi)
#held-out likelihood plot
plot_held <- ggplot(data = dfopti_df, aes(x = as.numeric(K), y= as.numeric(heldout))) +
  geom_line() +
  xlab('主题数量（K）')  +
  ylab('Held-out likelihood') +
  ggtitle('图2: 主题模型的交叉验证（held-out likelihood)') +
  theme(text = element_text(family='Songti', size = 16))
ggsave('./Plots/plot_held.png', plot = plot_held)
#semantic coherence plot
plot_semcoh <- ggplot(data = dfopti_df, aes(x = as.numeric(K), y= as.numeric(semcoh))) +
  geom_line() +
  xlab('主题数量（K）')  +
  ylab('语义连贯性') +
  ggtitle('图3: 主题模型的语义连贯性') +
  theme(text = element_text(family='Songti', size = 16))
ggsave('./Plots/plot_semcoh.png', plot = plot_semcoh)

#save(dfoptiplot, file = './Plots/dfoptiplot.png')
#write_csv(dfopti_df, './Datasets/optimizationresults.csv')

#查看范围内每一个K下的结果
sink('./stmoptimization_log.txt')
for (i in 10:30) {
  topic_model <- stm(text_dfm, K= i, init.type = 'Spectral', verbose = FALSE, seed = 243)
  #td_pct <- tidy(topic_model)
  outtemp <- capture.output(summary(topic_model))
  cat('\n\n', outtemp)
}
sink()
