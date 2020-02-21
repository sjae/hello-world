#Study 용 금융데이터 수집
#all rights reserved by http://henryquant.blogspot.com/ 
#알아서 활용하자

library(httr)
library(rvest)
library(stringr)
library(readr)
library(stringr)


# 최근 영업일 구하기
url = 'https://finance.naver.com/sise/sise_deposit.nhn'

biz_day = GET(url) %>%
  read_html(encoding = 'EUC-KR') %>%
  html_nodes(xpath =
               '//*[@id="type_1"]/div/ul[2]/li/span') %>%
  html_text() %>%
  str_match(('[0-9]+.[0-9]+.[0-9]+') ) %>%
  str_replace_all('\\.', '')

# 산업별 현황 OTP 발급
gen_otp_url =
  'http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx'

gen_otp_data = list(
  name = 'fileDown',
  filetype = 'csv',
  url = 'MKD/03/0303/03030103/mkd03030103',
  tp_cd = 'ALL',
  date = biz_day, # 최근영업일로 변경
  lang = 'ko',
  pagePath = '/contents/MKD/03/0303/03030103/MKD03030103.jsp')

otp = POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text()

# 산업별 현황 데이터 다운로드
down_url = 'http://file.krx.co.kr/download.jspx'

down_sector = POST(down_url, query = list(code = otp),
                   add_headers(referer = gen_otp_url)) %>%
  read_html() %>%
  html_text() %>%
  read_csv()

ifelse(dir.exists('data'), FALSE, dir.create('data'))
write.csv(down_sector, 'data/krx_sector.csv')

# 개별종목 지표 OTP 발급
gen_otp_url =
  'http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx'

gen_otp_data = list(
  name = 'fileDown',
  filetype = 'csv',
  url = "MKD/13/1302/13020401/mkd13020401",
  market_gubun = 'ALL',
  gubun = '1',
  schdate = biz_day, # 최근영업일로 변경
  pagePath = "/contents/MKD/13/1302/13020401/MKD13020401.jsp")

otp = POST(gen_otp_url, query = gen_otp_data) %>%
  read_html() %>%
  html_text()

# 개별종목 지표 데이터 다운로드
down_url = 'http://file.krx.co.kr/download.jspx'
down_ind = POST(down_url, query = list(code = otp),
                add_headers(referer = gen_otp_url)) %>%
  read_html() %>%
  html_text() %>%
  read_csv()

# 데이터 저장
write.csv(down_ind, 'data/krx_ind.csv')

#다운로드된 데이터 정리
#중복항목 찾고 데이터 쪼인

#각 테이블의 공통항목 찾기 >> intersect(names(down_sector), names(down_ind))
#공통 항목중 공통적으로 없는  데이터 찾기 >> setdiff(down_sector[, '종목명'], down_ind[ ,'종목명'])


#merge() 함수는 by를 기준으로 두 데이터를 하나로 합치며, 
#공통으로 존재하는 종목코드, 종목명을 기준으로 입력해줍니다. 
#또한 all 값을 TRUE로 설정하면 합집합을 반 환하고, 
#FALSE로 설정하면 교집합을 반환합니다. 
#공통으로 존재하는 항목을 원하므로 여기서는 FALSE를 입력합니다

KOR_ticker = merge(down_sector, down_ind,
                   by = intersect(names(down_sector),
                                  names(down_ind)),
                   all = FALSE)


#결과확인 테이블-정렬후 보기

KOR_ticker = KOR_ticker[order(-KOR_ticker['시가총액.원.']), ]
print(head(KOR_ticker))

#스팩과 우선주제거
#grepl() 함수를 통해 종목명에 ‘스팩’이 들어가는 종목을 찾고, 
#stringr 패키지의 str_sub() 함수를 통해 종목코드 끝이 0이 아닌 우선주 종목을
#찾을 수 있습니다.

KOR_ticker[grepl('스팩', KOR_ticker[, '종목명']), '종목명'] 
KOR_ticker[str_sub(KOR_ticker[, '종목코드'], -1, -1) != 0, '종목명']

KOR_ticker = KOR_ticker[!grepl('스팩', KOR_ticker[, '종목명']), ]  
KOR_ticker = KOR_ticker[str_sub(KOR_ticker[, '종목코드'], -1, -1) == 0, ]

#최종 결과 정리 및 저장
rownames(KOR_ticker) = NULL
write.csv(KOR_ticker, 'data/KOR_ticker.csv')
