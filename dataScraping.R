#-------------------------------------------------#
# DOWNLOAD, INSTALAÇÃO E ATIVAÇÃO DAS BIBLIOTECAS #
#-------------------------------------------------#

# Instalação de bibliotecas
install.packages("rvest")
library(rvest)
# 
install.packages("ggplot2")
install.packages("dplyr")
install.packages("scales")
install.packages("maps")
install.packages("mapproj")
install.packages("plotly")

# Ativação de bibliotecas
library(ggplot2)
library(dplyr)
library(scales)
library(maps)
library(mapproj)
library(plotly)

#--------------------------------#
# CARREGANDO OS DADOS DA PAGINA WEB #
#--------------------------------#

# Carregando o código HTML da página Web em um objeto
# https://en.wikipedia.org/w/index.php?title=List_of_U.S._states_and_territories_by_life_expectancy&ol-did=928537169
#
filURL <- read_html("https://en.wikipedia.org/w/index.php?title=List_of_U.S._states_and_territories_by_life_expectancy&ol-did=928537169#")

# Filtrar o código HTML em "filURL" mantendo apenas a tabela sobre a expectativa de vida
filURL <- filURL %>% html_nodes("table") %>% .[[2]] %>% html_table(fill=TRUE)
View(filURL)

#-------------------------#
# Extração e processamento dos dados #
#-------------------------#

# Seleção das colunas
filURL = filURL[c(1,2,6,7)]
View(filURL)

# Renomeando colunas ('filURL' = life expectancy)
names(filURL)[c(3,4)] = c("Caucasiano", "Africano")
View(filURL)

# Convertendo colunas para type numérico (valores ausentes codificados NA)
filURL$Caucasiano <- as.numeric(filURL$Caucasiano)
filURL$Africano <- as.numeric(filURL$Africano)
View(filURL)

# Calcul des diff�rences entre esp�rance de vie Caucasienne-Am�ricaine et Afro-Am�ricaine 
le$le_diff = le$le_caucasian - le$le_african
View(le)

# Chargement de la liste des �tats des USA dans un objet 'states'
states = map_data("state")

# Cr�ation d'une nouvelle variable 'region' avec des noms des �tats 
le$region = tolower(le$`State/federal district/territory`)
View(le)

# Fusion des donn�es de 'le' avec celles des �tats-Unis dans l'objet 'states'
states = merge(states, le, by="region", all.x=T)

#---------------------------------------------------#
# AFFICHAGE DES DONNEES SUR LA CARTE DES ETATS-UNIS #
#---------------------------------------------------#

# Affichage des caract�res accentu�s dans les cartes
options(encoding="latin1")

# Affichage des esp�rance de vie du groupe ethnique Afro-Am�ricains
ggplot(states, aes(x = long, y = lat, group = group, fill = le_african)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + labs(title="Esp?rance de vie du groupe ethnique Afro-Am?ricain") + coord_map()

# Affichage des esp�rance de vie du groupe ethnique Caucasien-Am�ricains
ggplot(states, aes(x = long, y = lat, group = group, fill = le_caucasian)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="Gray") + labs(title="Esp?rance de vie du groupe ethnique Caucasien-Am?ricain") + coord_map()

# Affichage des disparit�s entre les esp�rances de vie des deux groupes ethniques
ggplot(states, aes(x = long, y = lat, group = group, fill = le_diff)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + labs(title="Diff?rences dans l'esp?rance de vie des groupes ethniques \nCaucasien et Afro-Am?ricain par ?tat aux USA") + coord_map()

# Affichage d'une carte interactive des USA map avec message contextuel pour chaque �tat : Caucasien-Am�ricains
map_plot_caucasian = ggplot(states, aes(x = long, y = lat, group = group, fill = le_caucasian)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + labs(title="Esp?rance de vie du groupe ethnique Caucasien-Am?ricain") + coord_map()
ggplotly(map_plot_caucasian)

# # Affichage d'une carte interactive des USA map avec message contextuel pour chaque �tat : Afro-Am�ricains
map_plot_african = ggplot(states, aes(x = long, y = lat, group = group, fill = le_african)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + labs(title="Esp?rance de vie du groupe ethnique Afro-Am?ricain") + coord_map()
ggplotly(map_plot_african)