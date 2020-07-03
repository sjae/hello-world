#SJ equtiy market monitoring

install.packages("dplyr")
install.packages("ggplot2")

# install.packages("reshape")

library(dplyr)
library(ggplot2)

# library(reshape)

#데이터 파일 읽기
dde <- read.csv('data/KOR_ticker.csv',header = TRUE)
dds <- read.csv('data/KOR_sector.csv',header = TRUE)

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
dde <-  dde %>% mutate(시총 = 시가총액/1000000000)
dds <-  dds %>% mutate(S_시총 = S_시가총액/1000000000)

##현황그래프 그려보자

#섹터별 모니터링

mnt1 <- dde %>% group_by(시장구분,산업분류) %>% summarise(MktAvg = mean(시총))

mnt1 %>% filter(시장구분=="코스피") %>% 
  arrange(desc(MktAvg)) %>% 
  ggplot(aes(x=산업분류,y=MktAvg))+geom_bar(stat = "identity",fill="white",color="black" )

#의약섹터 시총 상위 5개 표시
dde %>% filter(산업분류 == "의약품") %>% top_n(5,시총) %>% ggplot(aes(종목명,시총))+geom_bar(stat="identity")+coord_flip()

#섹터에 포함된 종목 시총 순으로 그리기
dde %>% filter(산업분류=="의약품") %>% top_n(10,시총) %>% ggplot(aes(x=reorder(종목명,-시총),y=시총))+geom_col()


