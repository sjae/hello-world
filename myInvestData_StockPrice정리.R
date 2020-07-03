library(stringr)
library(xts)
library(magrittr)

#티커가 저장된 csv 파일을 불러온 후 티커를 6자리로 맞춰줍니다.
KOR_ticker = read.csv('data/KOR_ticker.csv', row.names = 1)
KOR_ticker$'종목코드' =
  str_pad(KOR_ticker$'종목코드', 6, side = c('left'), pad = '0')

#리스트인 price_list를 생성합니다.
price_list = list()

#for loop 구문을 이용해 종목별 가격 데이터를 불러온 후 
#as.xts()를 통해 시계열 형태로 데이터를 변경하고 리스트에 저장합니다

for (i in 1 : nrow(KOR_ticker)) {
  
  name = KOR_ticker[i, '종목코드']
  price_list[[i]] =
    read.csv(paste0('data/KOR_price/', name,
                    '_price.csv'),row.names = 1) %>%
    as.xts()
  
}

#do.call() 함수를 통해 리스트를 열 형태로 묶습니다.
#간혹 결측치가 발생할 수 있으므로, na.locf() 함수를 통해 결측치에는 전일 데이터를 사용합니다.
#행 이름을 각 종목의 티커로 변경합니다.

price_list = do.call(cbind, price_list) %>% na.locf()
colnames(price_list) = KOR_ticker$'종목코드'

#확인 head(price_list[, 1:5])

write.csv(data.frame(price_list), 'data/KOR_price.csv')
