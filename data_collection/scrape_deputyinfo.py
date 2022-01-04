from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.support.select import Select
import pandas as pd
import requests
import re
import time

from requests.models import HTTPError

def gethtml(html): #通过requests获取html
    try:
        genpage = requests.get(html)
        genpage.encoding = 'gb18030'
    except HTTPError as e:
        print("Website doesn't exist")
    else: 
        return genpage.text

def getpage(driver): #打开目录页，遍历所有代表的内部编号
    i = 1
    pn = 0 #页码
    while i > 0:
        pn += 1  
        try:
            print(pn)
            sel = driver.find_element_by_xpath("//select[@class='style7' and @id='listpager_input']")
            sel.click()
            time.sleep(3)
            Select(sel).select_by_value("{}".format(pn)) #进入下一页
            time.sleep(5)
            listurl = driver.find_elements_by_xpath("//a[@class='showMenu greyb14']")
            for a in listurl:
                url = re.findall('idleaf=\d+', a.get_attribute('rel'))[0] #用正则表达式匹配代表信息页面的url
                url1 = "http://odbapp.eastday.com/shrdweb/dbxx_detail.aspx?" + url
                urls.append(url1)
        except:
            print(len(urls))
            i = 0

def accesshtml(url): #Receive delegate number; extract info from the specific page 在代表页内提取信息
    html = gethtml(url)
    soup1 = BeautifulSoup(html, "lxml")
    delinfo = soup1.find_all("div",{"class":"rightbg3 grey18"}) #findAll returns a list, takeout the tags
    #print(delinfo)
    #process out the 代表信息xx
    listitem =[]
    listitem.append(url)
    delname =  soup1.find_all("div",{"class":"rightcon4 blueb30 lh32 fl"})[0].string.strip()
    listitem.append(delname)
    for a in delinfo:
        a = str(a.string)
        delitem = a.split('：')[1].strip()
        #print(delitem)
        listitem.append(delitem)
    dataset.append(listitem)
    #print(dataset) 

def csvoutput(dataset): #用pandas输出到csv文件中
    df_columns = ["HTML", "姓名", "代表编号", "党派", "民族", "代表团", "工作单位和职务", "工作单位地址", "工作单位邮编"]
    df = pd.DataFrame.from_records(dataset, columns=df_columns)
    print (df)
    df.to_csv("./DeputyInfo2018.csv", index = False)

if __name__ == "__main__":
    urls = []
    dataset = []
    html = 'http://odbapp.eastday.com/shrdweb/dbxx.aspx'
    driver = webdriver.Safari()
    driver.get(html)
    getpage(driver)
    for url in urls:
        accesshtml(url)
    csvoutput(dataset)
    
    
    
