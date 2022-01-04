Packages <- c('quanteda','jiebaRD', 'jiebaR', 'tidytext', 'tidyverse')
lapply(Packages, library, character.only = TRUE)
opinion <- read.csv('./Datasets/Opinion.csv')
#seginstru是分词器
seginstru <- worker(user = './PCT_textprep/PCT_userdict.txt', stop_word = './PCT_textprep/PCT_stopword.txt', bylines = TRUE) 

#引入text
#opinres <- read.csv('./Datasets/opinres_integrated.csv')
#opinres <- subset(opinres, select = c('opinion_text', "result", "research_score"))
#opinres <- opinres[1:6, ]
## 这里需要屏蔽掉其他东西吗？节省算力？
#opinres$textseged <- rep(NA, 6)
#head(opinres)

#Tokenization
text_corpus <- opinion %>% corpus(docid_field = "建议编号", text_field = "正文", meta = list())
#summary(text_corpus)
text_tokens <- text_corpus %>% 
  segment(jiebar = seginstru) %>% 
  #lapply(., function(x){ifelse(is.numeric(x)==FALSE, x, '')}) %>% 
  as.tokens %>% 
  tokens(remove_numbers = TRUE) %>% 
  tokens_select(pattern = "[:digit:]+-[:digit:]+", selection = "remove", valuetype = "regex")
text_dfm <-dfm(text_tokens)
text_stm <- convert(text_dfm, to = "stm")
text_stmdoc <- text_stm$documents
text_stmvocab <- text_stm$vocab
text_stmmeta <- text_stm$meta

#A tidy approach
#Converting dfm object into native stm object
#?stm



