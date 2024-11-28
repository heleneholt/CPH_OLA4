######################################
### opgave 3 - Analyse af logfiler ###
######################################

library(stringr)
library(tidyverse)
library(ggplot2)

# indlæsning af log.tar / mappe med access.log-filer. 
logfiles <- list.files(path = "log (2)/", pattern = "access.log*", full.names = TRUE)
print(logfiles)

logdf <- do.call(rbind, lapply(logfiles, function(file) {
  data.frame(logdata = readLines(file), stringsAsFactors = FALSE)
}))

# Undersøgelse af data for at skabe rapport 

# umiddelbare interessante punkter

    # - optælling af aktive ip-adresser med plot
    # derefter plot af eks. top 5 mest aktive ip-adresser pr. dato eller aggrereret ned til pr. måned eller sådan
    # udtrækning af alle whois på aktive ip-adresser, herunder redegørelse af surveillance software (jetmon)
    # gruppering af 404 requests, herunder gruppering på whois og forklaring på hvorfor det en '404'
    # redegørelse for mistænksomme requests - tjek for mistænksomme requests og se om nogle har sc 200



        # udarbejdelse af rapport

# udtrækker IP-adresser, dato og whois fra access.log string.

logdf_2 <- logdf %>% mutate(
    ip_adresser = str_extract(logdata, "\\d+\\.\\d+\\.\\d+\\.\\d+"),
    dato = str_extract(logdata, "\\d{2}/[A-Za-z]{3}/\\d{4}"),
    whois = str_extract(logdata, "\"([^\"]+)\"$"),
    dato = as.Date(dato, format = "%d/%b/%Y") # Indsæt direkte i mutate
  )t

# Count af aktive ip-adresser 

    # vores definition på aktiv ip-adresse: en adresse som har lavet en form for request; herunder IKKE forsøg på request (sc 408) 
      # vi filtrerer derfor og laver en dataframe som kun indeholder IP-adresser med requests. (GET/POST/HEAD)

aktive.ipadresser = logdf_2[grepl("GET|POST|HEAD", logdf_2$logdata), ]

  ## ANTAL unikke ip-adresser pr. dato 
aktip.frekvens = aktive.ipadresser %>% 
  group_by(dato) %>% 
  summarise(unique.ip.adresses = n_distinct(ip_adresser)) 


  ## ANTAL requests pr. IP-adresse 
ip.adresse.count <- aktive.ipadresser %>%
  group_by( ip_adresser) %>% 
  summarise(count = n()) %>%
  arrange(desc(count))

  # plot af 4 mest aktive IP-adresse - begrundelse: vi ser at det KLART er disse IP-adresser der fremkommer mest. 

top.4.ip = ip.adresse.count[1:4, ]

ggplot(top.4.ip, aes(x = reorder(ip_adresser, count), y = count)) +
  geom_bar(stat = "identity", fill = "skyblue") + 
  labs(title = "Den mest aktive IP-Adresse er 192.0.102.40",
       x = "IP-adresser",
       y = "Frekvens af IP-Adresse forekomster i access.log") +
  theme_minimal()

  # hvilke slags requests - og whois - er disse IP-adresser?

    # udtrækker de top 4 ip-adresser; 

filterip = top.4.ip$ip_adresser

filter.ip.df = aktive.ipadresser %>% 
  filter(ip_adresser == filterip)

whois.top4ip = filter.ip.df %>% 
  distinct(whois, .keep_all = T)

# Key take aways fra disse top 4 iper's whois: 2 requests fra talmedos.com, 1 fra jetmon (survillance plugin til wordpress) og 4 fra users/fra nettet: ses da whois er en user-agent. 
  # andet kan ikke udtrækkes fra selve requesten, udover at der laves get og post requests samt head requests for jetmon. 

### gruppering af mistænklige requests.
  # ved mistænklige requests forstås folks forsøg på at bypass, og opnå kontrol/adgang til ting, som personen/useren ikke burde få kontrol eller adgang over.
  # et typisk forsøg, især på wordpress, er en get request på admin eller login, for at kunne få adgang til backend delen af hjememesiden. 

# I første omgang vælger vi derfor at finde alle mistænklige forsøg på adin og login requests.
adminforsøg = logdf_2[grepl("admin|login", logdf_2$logdata, ignore.case = TRUE), ]

  # som det fremstår er der mange forskellige forsøg på adminadgang (2706) - vi filtrerer derfor i første omgang de succesfulde requests fra: 

adminforsøg.failed = adminforsøg[!grepl(" 200 ", adminforsøg$logdata), ]

# vi har nu kun sc: 401 og 403 tilbage - som står for adgang nægtet og url eksisterer ikke? 

  # vi prøver nu at se om der er nogle IP-adresser som har prøvet flere gange at få adgang med adgang nægtet.

failedadmin.ipcount = adminforsøg.failed %>% 
  group_by(ip_adresser) %>% 
  summarise(count = n()) %>% 
  arrange(desc(count))

  # vi kigger især på frekvensen af forsøg i og med, at en 404 ikke nødvendigvis betyder at de forsøger at hacke ind med admin access, men derimod hvis de eksempelvis prøver at lokere sider med sensitiv data.
  # det kunne eksempelvis være en bot der er sat op til at gøre det, og dermed typisk en høj frekvens af request-forsøg. 

  # i stedet for 404 requests findes 401 og 403 requests. Disse requests betyder: unautharised og forbidden; ergo hvis de forsøger at få admin-access direkte - uden at lokere URL'er

adminforsøg.401.403 = adminforsøg.failed[grepl("401|403", adminforsøg.failed$logdata, ignore.case = TRUE), ]

# vi ser her direkte mistænkelige forsøg som ikke behøver at være i forlængelse af en anden betingelse, eks. frekvens af forsøg osv. 
  # det skal dog siges - at der kan yderligere opsættes parametre for mistænkelige forsøg, hvis man selv sidder med hjememesiden. - eksemepelvis hvis man godkender/bandlyser forskellige ip-adresser.
  # eksempelvis kan man godkende en medarbejders ip - så de ikke bliver logget som mistænkelige. dette kaldes at 'whiteliste', derudover er det modsatte at 'blackliste' - så uanset hvad der prøves på, får de ikke lov. 



    