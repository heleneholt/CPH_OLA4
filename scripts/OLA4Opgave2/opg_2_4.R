#############
### OLA 4 ###
#############

### Opgave 2.4 – Scrape & SQL med Miljødata. ###

# indlæs nødvendige pakker
library(httr)
library(rvest)
library(tidyverse)

# HC ANDERSEN BOULEVARD

url_1 <- "https://envs2.au.dk/Luftdata/Presentation/table/Copenhagen/HCAB"
resraw <- GET(url = url_1)
resraw$status_code

mycookie <- resraw$cookies
cookie_string <- paste(mycookie$name, mycookie$value, sep = "=", collapse = "; ")

hhc <- content(resraw, as="text")

csrf_token <- read_html(hhc) %>% 
  html_node("input[name='__RequestVerificationToken']") %>% 
  html_attr("value")

body <- list(
  `__RequestVerificationToken` = csrf_token
)

url_2 <- "https://envs2.au.dk/Luftdata/Presentation/table/MainTable/Copenhagen/HCAB"
resraw2 <- POST(url = url_2)

# Definer headers som en karaktervektor uden ekstra kommaer
headers <- c(
  "accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
  "accept-encoding" = "gzip, deflate, br",
  "accept-language" = "da-DK,da;q=0.9,en-US;q=0.8,en;q=0.7",
  "cookie" = cookie_string,
  "referer" = "https://envs.au.dk/",
  "user-agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
)

# Brug add_headers korrekt
response <- POST(url_2, body = body, encode = "form", add_headers(headers))


# Kontroller om anmodningen lykkedes
if (status_code(response) == 200) {
  cat("Anmodning lykkedes. Henter data...\n")
  
  # Få HTML-indholdet af svar
  content_html <- content(response, as = "text")
  
  # Brug rvest til at parse HTML og finde tabellen
  page <- read_html(content_html)
  
  # Find tabellen og hent data
  table_København2 <- page %>% html_node("table") %>% html_table()
  
  # Udskriv tabellen
  print(table_København2)
} else {
  stop("Anmodning fejlede med status: ", status_code(response))
}


# RISØ

url_3 <- "https://envs2.au.dk/Luftdata/Presentation/table/Rural/RISOE"
resraw3 <- GET(url = url_3)
resraw3$status_code

mycookie_riseo <- resraw3$cookies
cookie_string_risoe <- paste(mycookie_riseo$name, mycookie_riseo$value, sep = "=", collapse = "; ")

hhc3 <- content(resraw3, as="text")

csrf_token_risoe <- read_html(hhc3) %>% 
  html_node("input[name='__RequestVerificationToken']") %>% 
  html_attr("value")

body3 <- list(
  `__RequestVerificationToken` = csrf_token_risoe
)

url_4 <- "https://envs2.au.dk/Luftdata/Presentation/table/MainTable/Rural/RISOE"
resraw4 <- POST(url = url_4)

headers_risoe <- c(
  "accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
  "accept-encoding" = "gzip, deflate, br, zstd",
  "accept-language" = "da-DK,da;q=0.9,en-US;q=0.8,en;q=0.7",
  "cookie" = cookie_string_risoe,
  "referer" = "https://envs2.au.dk/Luftdata/Presentation/table/Rural/RISOE",
  "user-agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
)

# Send POST-anmodningen
response_risoe <- POST(url_4, body = body3, encode = "form", add_headers(.headers = headers_risoe))

# Kontroller om anmodningen lykkedes
if (status_code(response_risoe) == 200) {
  cat("Anmodning lykkedes. Henter data...\n")
  
  # Få HTML-indholdet af svar
  content_html <- content(response_risoe, as = "text")
  
  # Brug rvest til at parse HTML og finde tabellen
  page <- read_html(content_html)
  
  # Find tabellen og hent data
  table_Risoe2 <- page %>% html_node("table") %>% html_table()
  
  print(table_Risoe2)
} else {
  stop("Anmodning fejlede med status: ", status_code(response_risoe))
}


# ANHOLT

# URL til API-endpointet

url_5 <- "https://envs2.au.dk/Luftdata/Presentation/table/Rural/ANHO"
resraw5 <- GET(url = url_5)
resraw5$status_code

mycookie_anholt <- resraw5$cookies
cookie_string_anholt <- paste(mycookie_anholt$name, mycookie_anholt$value, sep = "=", collapse = "; ")

hhc5 <- content(resraw5, as="text")

csrf_token_anholt <- read_html(hhc5) %>% 
  html_node("input[name='__RequestVerificationToken']") %>% 
  html_attr("value")

body5 <- list(
  `__RequestVerificationToken` = csrf_token_anholt
)

url_6 <- "https://envs2.au.dk/Luftdata/Presentation/table/MainTable/Rural/ANHO"
resraw6 <- POST(url = url_6)

headers_anholt <- c(
  "accept" = "*/*",
  "accept-encoding" = "gzip, deflate, br, zstd",
  "accept-language" = "da-DK,da;q=0.9,en-US;q=0.8,en;q=0.7",
  "cookie" = cookie_string_anholt,
  "referer" = "https://envs2.au.dk/Luftdata/Presentation/table/Rural/ANHO",
  "user-agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
)

# Send POST-anmodningen
response_anholt <- POST(url_6, body = body5, encode = "form", add_headers(.headers = headers_anholt))

# Kontroller om anmodningen lykkedes
if (status_code(response_anholt) == 200) {
  cat("Anmodning lykkedes. Henter data...\n")
  
  # Få HTML-indholdet af svar
  content_html <- content(response_anholt, as = "text")
  
  # Brug rvest til at parse HTML og finde tabellen
  page <- read_html(content_html)
  
  # Find tabellen og hent data
  table_Anholt2 <- page %>% html_node("table") %>% html_table()
  
  # Udskriv tabellen
  print(table_Anholt2)
} else {
  stop("Anmodning fejlede med status: ", status_code(response_anholt))
}


# ÅRHUS BANEGÅRDSGADE

url_7 <- "https://envs2.au.dk/Luftdata/Presentation/table/Aarhus/AARH3"
resraw7 <- GET(url = url_7)
resraw7$status_code

mycookie_aarhus <- resraw7$cookies
cookie_string_aarhus <- paste(mycookie_aarhus$name, mycookie_aarhus$value, sep = "=", collapse = "; ")

hhc6 <- content(resraw7, as="text")

csrf_token_aarhus <- read_html(hhc6) %>% 
  html_node("input[name='__RequestVerificationToken']") %>% 
  html_attr("value")

body6 <- list(
  `__RequestVerificationToken` = csrf_token_aarhus
)

url_8 <- "https://envs2.au.dk/Luftdata/Presentation/table/MainTable/Aarhus/AARH3"
resraw8 <- POST(url = url_8)

headers_aarhus <- c(
  "accept" = "*/*",
  "accept-encoding" = "gzip, deflate, br, zstd",
  "accept-language" = "da-DK,da;q=0.9,en-US;q=0.8,en;q=0.7",
  "cookie" = cookie_string_aarhus,
  "referer" = "https://envs2.au.dk/Luftdata/Presentation/table/Aarhus/AARH3",
  "user-agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
)

# Send POST-anmodningen
response_aarhus <- POST(url_8, body = body6, encode = "form", add_headers(.headers = headers_aarhus))

# Kontroller om anmodningen lykkedes
if (status_code(response_aarhus) == 200) {
  cat("Anmodning lykkedes. Henter data...\n")
  
  # Få HTML-indholdet af svar
  content_html <- content(response_aarhus, as = "text")
  
  # Brug rvest til at parse HTML og finde tabellen
  page <- read_html(content_html)
  
  # Find tabellen og hent data
  table_Aarhus2 <- page %>% html_node("table") %>% html_table()
  
  # Udskriv tabellen
  print(table_Aarhus2)
} else {
  stop("Anmodning fejlede med status: ", status_code(response_aarhus))
}



