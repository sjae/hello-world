#SJ equtiy market monitoring

install.packages("dplyr")
install.packages("ggplot2")
install.packages("stringr")
# install.packages("reshape")

library(dplyr)
library(ggplot2)
library(stringr)
# library(reshape)

#데이터 파일 읽기
dde <- read.csv('data/KOR_ticker.csv',header = TRUE)
# dds <- read.csv('data/KOR_sector.csv',header = TRUE)

#DDE#########################################################################
dde <- dde %>% dplyr::select(-X,-총카운트,-게시물..일련번호)

#변수이름 바꾸기
dde <- rename(dde,"시가총액"="시가총액.원.")
dde <- rename(dde,"가격"="현재가.종가.")

#데이터형태 바꾸기
#dde <- mutate_if(dde,is.factor,as.numeric) #전체 Factor 초기회
dde$종목명 <- as.factor(dde$종목명)
dde$종목코드 <- as.factor(dde$종목코드)
dde$시장구분 <- as.factor(dde$시장구분)
dde$산업분류 <- as.factor(dde$산업분류)

dde$전일대비 <- as.numeric(dde$전일대비)
dde$주당배당금 <- as.numeric(dde$주당배당금)
dde$배당수익률 <- as.numeric(dde$배당수익률)
dde$시가총액 <- as.numeric(dde$시가총액)
dde$EPS <- as.numeric(dde$EPS)
dde$BPS <- as.numeric(dde$BPS)
dde$PER <- as.numeric(dde$PER)
dde$PBR <- as.numeric(dde$PBR)

#KEY값 일치 - 6자리로 메워주기
dde$종목코드 <- str_pad(dde$종목코드,6,side = c('left'),pad = "0")

#DDS#########################################################################
#dds %>% select(-X,ALL_MKT_VAL,-S_WGT,-CAL_WGT,-SEC_CD,-SEQ,-TOP60,-APT_SHR_CNT,-CAL_WGT,)
dds <- select(dds,IDX_CD,IDX_NM_KOR,CMP_CD,CMP_KOR,MKT_VAL,WGT)

#변수명 바꾸기
dds <- rename(dds,S_글로벌섹터 = IDX_CD)
dds <- rename(dds,S_WIC섹터 = IDX_NM_KOR)
dds <- rename(dds,S_종목코드 = CMP_CD)
dds <- rename(dds,S_종목명 = CMP_KOR)
dds <- rename(dds,S_시가총액 = MKT_VAL)
dds <- rename(dds,S_시총비중 = WGT)

#변수데이터 타입 바꾸기
dds$S_글로벌섹터 <- as.factor(dds$S_글로벌섹터)
dds$S_WIC섹터 <- as.factor(dds$S_WIC섹터)
dds$S_종목코드 <- as.factor(dds$S_종목코드)
dds$S_종목명 <- as.factor(dds$S_종목명)

dds$S_시가총액<- as.numeric(dds$S_시가총액)
dds$S_시총비중 <- as.numeric(dds$S_시총비중)

#KEY값 일치 - 6자리로 메워주기
dds$S_종목코드 <- str_pad(dds$S_종목코드,6,side = c('left'),pad="0")

#시총금액 십억화
dde <-  dde %>% mutate(시총 = 시가총액/1000000000000)
dds <-  dds %>% mutate(S_시총 = S_시가총액/1000000000000)

##현황그래프 그려보자

#섹터별 모니터링
# 
# mnt1 <- dde %>% group_by(시장구분,산업분류) %>% summarise(MktAvg = mean(시총))
# 
# mnt1 %>% filter(시장구분=="코스피") %>% 
#   arrange(desc(MktAvg)) %>% 
#   ggplot(aes(x=산업분류,y=MktAvg))+geom_bar(stat = "identity",fill="white",color="black" )
# 
# #의약섹터 시총 상위 5개 표시
# dde %>% filter(산업분류 == "의약품") %>% top_n(5,시총) %>% ggplot(aes(종목명,시총))+geom_bar(stat="identity")+coord_flip()
# 
# #섹터에 포함된 종목 시총 순으로 그리기
# dde %>% filter(산업분류=="의약품") %>% top_n(10,시총) %>% ggplot(aes(x=reorder(종목명,-시총),y=시총))+geom_col()

# 원하는 문자열 찾기 개념 연습용..
# KOR_ticker = KOR_ticker[!grepl('스팩', KOR_ticker[, '종목명']), ]  
# KOR_ticker = KOR_ticker[str_sub(KOR_ticker[, '종목코드'], -1, -1) == 0, ]

# select_if >> 변수의 형태만 특정하여 추출>>변수를 추출하는 거임


#상관성분석
#1)corplot
# corrplot::corrplot(method ="circle",order = "hclust",addrect = 4,insig="p-value", sig.level = 0.05, p.mat = res1$p) / res1$p 
# 
# > p 값구하기 >>p값으로 구성된 매트릭스 산출
# res1 <- corrplot::cor.mtest(td,conf.levle=.95)
# p 값을 구하고(cor.mtest), 리스트 형태에서 p 값만 뽑아내서 p.mat에 넣어버림.
#insign.level = 설정을 통해서 p값 유의성 산정기준을 설정함.
# corrplot(hh,method = "number",p.mat = cor.mtest(hh)[[1]],order = "hclust",addrect = 3, sig.level = 0.05)

#2)PerformannceAnaltics
#performance Analytics 패키지 사용해보기
# 예시
# chart.Correlation(td,histogram = TRUE,pch=19)

#7월 10일 연습한거 > 성공
# dde %>% select(시장구분,산업분류,종목명,시총) %>% group_by(시장구분) %>% mutate(m_avg=mean(시총)) %>% group_by(산업분류) %>% mutate(s_avg=mean(시총)) %>% top_n(3,시총) %>% arrange(산업분류)

#산업별 시총 순위 상위 10
# dde %>% select(시장구분,산업분류,시총) %>% group_by(산업분류) %>% summarise(mavg=mean(시총)) %>% top_n(10,mavg) %>% ggplot(aes(x=reorder(산업분류,-mavg),y=mavg))+geom_col()+geom_text(aes(label=paste(round(mavg,digit=1),"십억")),vjust=-0.3,size=4)

# #시장별 시총 크기 그리기: 주의점 ~~ scales="free" 라고해야지 잘 정리됨.. 
# dde %>% select(시장구분,종목명,시총) %>% group_by(시장구분) %>% top_n(5,시총) %>% arrange(desc(시총)) %>% ggplot(aes(x=reorder(종목명,-시총),y=시총))+geom_col()+facet_wrap(~시장구분, scales="free")+geom_text(aes(label=paste(round(시총,2),"조"),vjust=-0.5),size=3.5)
