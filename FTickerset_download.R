library(rvest)
library(httr)
library(dplyr)
library(jsonlite)

#ticker_list data set 생성########################################################
#download()함수를 통해 데이터셋을 생성함

download <- function() {
  data <- list()                                          #1. 전체 내용이 최종적으로 담기게 될 empty list 생성
  
  
  for (i in 0:1) {                                        #2. (i=0 코스피) (i=1 코스닥) 리스트에 각각 담고 나중에 do.call rbind로 합칠 예정
    
    ticker <- list()                                      #1) 페이지별 정보가 바로 이 리스트에 담기게 됨
    url <-                                                #(1) 코스피/코스닥 종목리스트 첫 페이지 url           
      paste0('https://finance.naver.com/sise/',
             'sise_market_sum.nhn?sosok=',i,'&page=1')
    
    down_table = GET(url) 
    
    #(2) 최종 페이지 번호 찾아주기
    navi.final <-
      read_html(down_table, encoding = "EUC-KR") %>%
      html_nodes(., ".pgRR") %>%
      html_nodes(., "a") %>%
      html_attr(.,"href") %>%                             #여기에 번호가 숨겨져 있음
      strsplit(., "=") %>%                                #번호만 뽑아내는 작업
      unlist() %>% 
      tail(., 1) %>%
      as.numeric()
    
    
    for (j in 1:navi.final) {                             #3. 알아낸 최종번호로 페이지별 정보를 크롤링하기
      
      # 각 페이지에 해당하는 url 생성
      url <- paste0(
        'https://finance.naver.com/sise/',
        'sise_market_sum.nhn?sosok=',i,"&page=",j)
      down_table <- GET(url)
      
      Sys.setlocale("LC_ALL", "English")
      # 한글 오류 방지를 위해 영어로 로케일 언어 변경
      
      table <- read_html(down_table, encoding = "EUC-KR") %>%
        html_table(fill = TRUE)
      table <- table[[2]] # 원하는 테이블 추출
      
      Sys.setlocale("LC_ALL", "Korean")
      # 한글을 읽기위해 로케일 언어 재변경
      
      table[, ncol(table)] = NULL # 토론식 부분 삭제
      table <- na.omit(table) # 빈 행 삭제
      
      # 6자리 티커만 추출
      symbol <- read_html(down_table, encoding = "EUC-KR") %>%
        html_nodes(., "tbody") %>%
        html_nodes(., "td") %>%
        html_nodes(., "a") %>%
        html_attr(., "href")
      
      symbol <- sapply(symbol, function(x) {
        substr(x, nchar(x) - 5, nchar(x)) 
      }) %>% unique() #sapply: 배열데이터 계산
      
      # 테이블에 티커 넣어준 후, 테이블 정리
      table$N = symbol
      colnames(table)[1] = "종목코드"
      
      rownames(table) = NULL
      ticker[[j]] = table #페이지별 테이블을 ticker 리스트에 담아줌
      
      Sys.sleep(0.5) # 페이지 당 0.5초의 슬립 적용
    }
    
    # do.call을 통해 리스트를 데이터 프레임으로 묶기
    ticker = do.call(rbind, ticker)     #4. ticker 리스트에는 개별 cart마다 코스닥 or 코스피 페이지별 테이블이 담겨 있음. 그것을 하나로 합치는 것임
    data[[i + 1]] = ticker              #5. 첫째 cart에는 코스피 페이지별 테이블이 모두 합쳐진 data.frame이, 두 번째는 코스닥 자료가 들어감
  }
  
  # 코스피와 코스닥 테이블 묶기
  data <- do.call(rbind, data)          #6. 두 data.frame을 묶어줌
  assign("ticker_list", data, .GlobalEnv) #7. 최종결과물을 저장함
}



#find_tikcer함수 생성########################################################
#활용: find_ticker("삼성전자") >> 종목코드와 이름 추출

find_ticker <- 
  function(name) {
    search_result <- ticker_list[grepl(name, ticker_list$종목명, fixed = T), 1:2]
    print(search_result)
  }

