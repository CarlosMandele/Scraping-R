#-----------------------------------------------------------#
# TELECHARGEMENT, INSTALLATION ET ACTIVATION DES LIBRAIRIES #
#-----------------------------------------------------------#

# Installation des librairies (mise-a-jour si d�j� install�es)
install.packages("rvest")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("scales")
install.packages("maps")
install.packages("mapproj")
install.packages("plotly")

# Activation des librairies
library(rvest)
library(ggplot2)
library(dplyr)
library(scales)
library(maps)
library(mapproj)
library(plotly)
library(data.table)

#-----------------------------------------#
# CHARGEMENT DES DONNEES DEPUIS WIKIPEDIA #
#-----------------------------------------#

# Chargement du code HTML de la page Internet dans un objet nomme 'le' avec la  fonction 'read_html()' 
le = read_html("https://en.wikipedia.org/w/index.php?title=List_of_U.S._states_and_territories_by_life_expectancy&ol-did=928537169")

# Filtrage du code HTML dans 'le' afin de ne conserver que la table sur les esp�rances de vie
le = le %>% html_nodes("table") %>% .[[2]] %>% html_table(fill=T)
View(le)

#-------------------------#
# PREPARATION DES DONNEES #
#-------------------------#

# S�lection des colonnes utilis�es
le = le[c(1,2,6,7)]
View(le)

# Renommage des colonnes ('le' = life expectancy)
names(le)[c(3,4)] = c("caucasiano", "africano")
View(le)

# Conversion des colonnes au format num�rique (valeurs manquantes cod�es NA)
le$caucasiano <- as.numeric(le$caucasiano)
le$africano <- as.numeric(le$africano)
View(le)

# Calcul des diff�rences entre esp�rance de vie Caucasienne-Am�ricaine et Afro-Am�ricaine 
le$difer = le$caucasiano - le$africano
View(le)

# Chargement de la liste des �tats des USA dans un objet 'states'
states = map_data("state")

# Cr�ation d'une nouvelle variable 'region' avec des noms des �tats 
le$region = tolower(le$`State/Territory`)
View(le)

# Fusion des donn�es de 'le' avec celles des �tats-Unis dans l'objet 'states'
states = merge(states, le, by="region", all.x=T)

#---------------------------------------------------#
# AFFICHAGE DES DONNEES SUR LA CARTE DES ETATS-UNIS #
#---------------------------------------------------#

# Affichage des caract�res accentu�s dans les cartes
options(encoding="latin1")

# Affichage des esp�rance de vie du groupe ethnique Afro-Am�ricains
ggplot(states, aes(x = long, y = lat, group = group, fill = africano)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + labs(title="Esperança de vida do grupo étnico afro-americano") + coord_map()

# Affichage des esp�rance de vie du groupe ethnique Caucasien-Am�ricains
ggplot(states, aes(x = long, y = lat, group = group, fill = caucasiano)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="Gray") + labs(title="Esperança de vida do grupo étnico caucasiano-americano") + coord_map()

# Affichage des disparit�s entre les esp�rances de vie des deux groupes ethniques
ggplot(states, aes(x = long, y = lat, group = group, fill = difer)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + labs(title="Diferenças na esperança de Vida dos grupos étnicos caucasianos e afro-americanos por estado nos EUA") + coord_map()

# Affichage d'une carte interactive des USA map avec message contextuel pour chaque �tat : Caucasien-Am�ricains
map_plot_caucasian = ggplot(states, aes(x = long, y = lat, group = group, fill = caucasiano)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + labs(title="Esperança de vida do grupo étnico caucasiano-americano") + coord_map()
ggplotly(map_plot_caucasian)

# # Affichage d'une carte interactive des USA map avec message contextuel pour chaque �tat : Afro-Am�ricains
map_plot_african = ggplot(states, aes(x = long, y = lat, group = group, fill = africano)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + labs(title="Esperança de vida do grupo étnico afro-americano") + coord_map()
ggplotly(map_plot_african)
