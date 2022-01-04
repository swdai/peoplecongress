from bs4 import BeautifulSoup
import pandas as pd
import requests
import re

from requests.models import HTTPError

def gethtml(htmlget): #通过requests获取html
    try:
        genpage = requests.get(htmlget)
        genpage.encoding = 'gb18030'
    except:
        print("Website doesn't exist")
    else: 
        return genpage.text

def getpage(year, pn): #打开目录页，获取所有代表建议的url，输出一个url的列表
    html1 = "http://www.spcsc.sh.cn/n1939/n3802/n{}/index{}.html".format(year, pn) #上海市信访局信息公开网站
    soup_opinpage = BeautifulSoup(gethtml(html1), "lxml") 
    listurl = soup_opinpage.find_all("a", {"class": "blue14a", "target": "_blank"})
    #print(listurl)
    i = 0
    for a in listurl:
        i += 1
        opinresunit = a.parent.find_next("td").string
        #output url
        a = str(a)
        try:
            url = re.findall('http://www.spcsc.sh.cn\S*.html', a)[0] 
        except:
            errorlist.append(("获取意见页面失败",html1,i))
        '''except:
            print(html1)
            url = re.findall('http://www.spcsc.sh.cn\S*index K207.html', a)[0]'''
        #url = "http://wsxf.sh.gov.cn/xf_swldxx/areaSearch/hfxd_info.aspx?" + str(url.join(url1.group(1,2)))
        resunitset[url] = opinresunit
        if year == 4720:
            yeardict[url] = 2018 #2018年总共有60页代表建议
        elif year == 5971:
            yeardict[url] = 2019 #2019年总共有47页代表建议
        elif year == 7202:
            yeardict[url] = 2020 #2019年总共有47页代表建议
        urls.append(url)
        

def yearpagematch(year):
    if year == 4720:
        prange = list(range(0,60)) #2018年总共有60页代表建议
    elif year == 5971:
        prange = list(range(0,47)) #2019年总共有47页代表建议
    elif year == 7202:
        prange = list(range(0,82)) #2020年第三次总共有82页代表建议
    prange[0] = ''
    return prange

def getallurl():
    for year in yearlist:
        for pn in yearpagematch(year):
            getpage(year,pn)
    #output URLs with deputy name, opinion title, and the response unit

def getopins():
    for url in urls:
        try:
            accesshtml(url)
        except:
            errorlist.append(("爬取错误", url, yeardict[url]))

def accesshtml(html): #获取网页内信访信件内容等
    soup_opin = BeautifulSoup(gethtml(html), "lxml")
    opintitle = soup_opin.find("h1", {"class": "blue30"}).string.strip()
    opindel = soup_opin.find("p", {"class":"gray14"}).string.strip()
    opincon = soup_opin.find("div", {"class":"dbjycnt gray16"}).children
    opincontent = ''
    for opin in opincon:
        opin = opin.string.strip()
        opincontent += opin 
    opinlist = {}
    opinlist["HTML"] = html
    opinlist["意见标题"] = opintitle
    opinlist["代表"] = opindel
    opinlist["意见内容"] = opincontent
    dataset[html] = opinlist
    #print(dataset) 
    #把每一个条目里的信息再打印一遍

def saveresunit():
    for url in urls:
        try:
            dataset[url]["处理单位"] = resunitset[url]
            dataset[url]["年份"] = yeardict[url]
        except:
            errorlist.append(("保存处理单位错误",url))

def csvoutput(dataset): #用pandas输出到csv文件中
    dforigin = list(dataset.values())
    df = pd.DataFrame(dforigin)
    df.to_csv("./意见汇总.csv", index = False)

def erroroutput(errorlist):
    df = pd.DataFrame(errorlist)
    df.to_csv("./Errorlist.csv", index = False)

def adhoccleansing(): #根据纠错后的特定html进行修改
    html = '''
    <div>
	一、案由（背景）</div>
<div>
	1、地下空间是上海特大城市的重要战略资源，地下空间开发规模巨大、投资巨大、建设与管理面临挑战。截止到2018年，全市地下空间建筑面积已达到6000余万平米，近三年年均增长超过500万平米。随着城市交通、市政基础设施规划建设需求激增，大量超大、超深、超长、环境极为复杂的工程不断涌现，建设风险突出。同时，既有地下空间网络化贯通，老旧建筑新增地下车库，废弃地下室改造与利用，地下管廊建设等新需求旺盛，地下空间已成为城市建设与更新的引擎，亟待详细的顶层规划引导。</div>
<div>
	2、《上海2005年地下空间概念规划》对促进地下空间合理利用和有序发展具有积极作用。&ldquo;概念规划&rdquo;首次提出构建&ldquo;地下上海&rdquo;的目标，明确了地下空间纵向使用分层导则（浅、中、深三层），规划了近期（2007年前）与远期目标（2010年前），有利促进了人民广场、世博园区等一批重大区域地下空间开发，为后续出台的《上海市地下空间规划建设条例》（2013年）、《上海市地下建设用地使用权出让规定》（2018年）奠定了基础。</div>
<div>
	3、目前《上海地下空间规划专项》编制存在的问题与挑战：</div>
<div>
	（1）适应高质量发展要求的&ldquo;专项规划&rdquo;顶层设计不足：面对上海市现有的地下空间开发量，在党和国家倡导的&ldquo;城市精细化管理&rdquo;，&ldquo;人民城市人民建、人民城市为人民&rdquo;等理念指引下，仅有的概念规划难以支撑新一轮的发展需求，尤其是深层开发（40米-60米、60米-100米）、网络型开发、既有建筑下地下空间开发缺乏系统的顶层设计。因此亟待在城市总规基础上，加快编制《上海市地下空间专项规划》。</div>
<div>
	（2）在&ldquo;上海2035&rdquo;城市总规颁布时，就同步启动编制《上海市地下空间专项规划》，但截至目前仍未颁布。根据调研，&ldquo;上海2035&rdquo;城市总规颁布后，市政府相关部门就提出：坚持&ldquo;一张蓝图&rdquo;干到底，以&ldquo;上海2035&rdquo;专项规划大纲为指引，会同专业管理部门编制系列专项规划，其中就明确由市规划资源局和市住建委联合编制《上海市地下空间专项规划》。&ldquo;上海2035&rdquo;总规颁布实施已经有数年，但&ldquo;地下空间专项规划&rdquo;迟迟未正式颁布。</div>
<div>
	（3）&ldquo;十四五&ldquo;规划的部分分项规划和重点区域规划，亟待地下空间专项规划的指导，具有紧迫性。目前上海已启动&rdquo;十四五&ldquo;规划编制工作，其中包含轨道交通等专项规划、以及临港新片区和虹桥商务区等重点区域规划，这些领域或重点区域都将进行大规模的地下空间开发，需要从专项规划层面系统考虑各类地下空间的衔接与协同，发挥《上海市地下空间专项规划》的指导与引领作用。</div>
<div>
	二、国内其他省市的情况</div>
<div>
	目前我国部分省市已经陆续出台或正在编制地下空间专项规划，包括：</div>
<div>
	1) 《深圳经济特区地下空间发展规划》（2000年、2006年、2010年纳入总规设地下空间专章）</div>
<div>
	2) 《武汉市地下空间综合专项规划（2014-2020）》</div>
<div>
	3) 《合肥市地下空间开发利用规划(2013&mdash;2020)》</div>
<div>
	4) 《宁波市中心城地下空间（人防）专项规划（2013-2020）》</div>
<div>
	5) 《昆明城市地下空间开发利用专项规划2014-2030》</div>
<div>
	6) 《杭州市地下空间开发近期建设规划(2016-2020年)》</div>
<div>
	&nbsp; &nbsp; &nbsp; &nbsp; 《济宁市城市地下空间专项规划（2013-2020）》</div>
<div>
	7) 《苏州地下空间专项规划2018-2035》（2019年）等。</div>
<div>
	总体而言，相关省市编制《地下空间专项规划》的经验值得借鉴。</div>
<div>
	&nbsp;</div>
<div>
	三、建议</div>
<div>
	&nbsp; 从&ldquo;人民城市人民建、人民城市为人民&rdquo;的理念出发，从城市高质量发展、精细化管理、可持续发展的角度出发，从地下工程不可逆或改建地下工程代价巨大的角度出发，高质量编制《上海市地下空间专项规划》意义重大，且具有紧迫性。具体建议如下：</div>
<div>
	（1）进一步广泛听取意见，确保《专项规划》的编制质量。首先应充分听取市民群众的建议，以确保规划方案汇集民智，体现人民城市人民建、体现以人为本的理念；同时规划地下空间涉及自然资源、住建、交通、水利、人防等多个管理部门，且需要从规划、设计、施工、运维等全生命期考虑，协调地上与地下关系，因此在专项规划编制期间，应广泛征求不同领域管理部门、行业单位、专家的意见，以确保专项规划的科学性与可实施性。</div>
<div>
	（2）《专项规划》应关注的重点内容。应重点关注深层地下空间开发、网络化拓建、既有建筑下地下空间开发等内容。这些领域符合上海城市资源开发的战略需求，对进一步提升地下空间开发利用综合效能、优化城市地下空间的功能设施（特别是城市更新中关切老百姓切身利益的民生设施），希望能在在地下空间专项规划中统筹考虑。</div>
<div>
	（3）加强不同规划之间的协同，发挥《专项规划》对&ldquo;十四五&rdquo;规划的支撑作用。地下空间专项规划应与城市总体规划、重点区域规划、相关专项规划协同；要切实发挥《地下空间专项规划》对上海特大城市新一轮地下空间开发的指导与支撑作用，以加快形成地下空间立体化、网络化、集约化开发利用的新格局。</div>
                </div>
			</div>
'''
    soup_clean = BeautifulSoup(html, "lxml")
    cleancon = soup_clean.findAll("div")
    cleancontent = ''
    for clean in cleancon:
        clean = clean.string.strip()
        cleancontent += clean 
    print(cleancontent)

def adhocresunit(): 
    getallurl()
    df = pd.read_csv('./ErrorCorrection.csv', usecols = ['HTML']) #读取content一列
    df_list = df.values.tolist()
    newdict = {}
    for url in df_list:
        try:
            url = url[0]
            newdict[url] = [url, resunitset[url]]
        except:
            print(url)
    df = pd.DataFrame.from_dict(newdict, orient='index')
    df.to_csv("./resunit_Maintenance.csv", index=False)

def run():
    getallurl()
    getopins()
    saveresunit()
    csvoutput(dataset)
    erroroutput(errorlist)

if __name__ == "__main__":
    yearlist = [7202, 5971, 4720] #7202是2020年，5971是2019年，4720是2018年
    urls = []
    dataset = {}
    resunitset = {}
    errorlist = []
    yeardict = {}
    #test()
    #run()
    #adhocresunit()
    adhoccleansing()

    



