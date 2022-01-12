## Planning Ahead or Fire-alarm: Unbundling Policy Influence of Deputies in Local People’s Congresses

This repository stores the replication procedures used in the local People's Congress project. Due to confidentiality requirements, this repo only publishes the data I collected from government websites (Jan, 2021). To replicate result, run './R_scripts/Workflow.R'. 

## Project description
### Data collection (in Python)
1. Used BeautifulSoup to scrape all the published opinions made by representatives in Shanghai's People's Congress from 2018-2021;
2. Used Selenium to collect the biographical information of representatives within Shanghai's People's Congress.

### Text cleaning (in R)
1. Constructed a dedicated stopword dictionary based on "Baidu Chinese stopwords";
2. Used Quanteda and JiebaR to tokenize the opinion texts.

### LDA modeling (in R)
1. Used the stm package to find the optimal K for LDA models;
2. Used the stm package to estimate a LDA model for the opinion text corpus.

### Regression analysis (in R)
1. Used the probit model to estimate the relationship between topics and the probability of opinion being accepted by the local government.
