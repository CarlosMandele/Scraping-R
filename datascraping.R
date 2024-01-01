#------------------------------------------------#
# DOWNLOAD, INSTALAÇÃO E ATIVAÇÃO DE BIBLIOTECAS #
#------------------------------------------------#

# Instalação de bibliotecas (atualização se já estiver instalada)
install.packages("rvest")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("scales")
install.packages("maps")
install.packages("mapproj")
install.packages("plotly")

# Ativação de bibliotecas
library(rvest)
library(ggplot2)
library(dplyr)
library(scales)
library(maps)
library(mapproj)
library(plotly)
library(data.table)

#-------------------------#
# CARREGANDO DADOS DA WEB #
#-------------------------#

# Carregando o código HTML da página Web 
le = read_html("https://en.wikipedia.org/w/index.php?title=List_of_U.S._states_and_territories_by_life_expectancy&ol-did=928537169")

# Filtrando o código HTML na variavel 'le' para manter apenas a tabela sobre as expectativas de vida
le = le %>% html_nodes("table") %>% .[[2]] %>% html_table(fill=T)
View(le)

#-------------------------#
# PROCESSAMENTO DOS DADOS #
#-------------------------#

# Seleção das colunas utilizadas
le = le[c(1,2,6,7)]
View(le)

# Renomeando as colunas ("life expectancy")
names(le)[c(3,4)] = c("caucasiano", "africano")
View(le)

# Convertendo colunas para formato numérico (valores ausentes codificados NA)
le$caucasiano <- as.numeric(le$caucasiano)
le$africano <- as.numeric(le$africano)
View(le)

# Cálculo das diferenças entre a esperança de vida caucasiana-americana e afro-americana
le$difer = le$caucasiano - le$africano
View(le)
#
states = map_data("state")

# Nova variável 'region' com nomes dos estados 
le$region = tolower(le$`State/Territory`)
View(le)

# Mesclando dados 'le' e 'states' no objeto 'states'
states = merge(states, le, by="region", all.x=T)

#-----------------------#
# VISUALIZAÇÃO DOS DADOS #
#-----------------------#

# Algumas configuração(se necessáro)
options(encoding="latin1")

# Visualização das expectativas de vida dos grupos étnicos afro-americanos
ggplot(states, aes(x = long, y = lat, group = group, fill = africano)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + labs(title="Esperança de vida do grupo étnico afro-americano") + coord_map()

# #
ggplot(states, aes(x = long, y = lat, group = group, fill = caucasiano)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="Gray") + labs(title="Esperança de vida do grupo étnico caucasiano-americano") + coord_map()

# Disparidades entre as expectativas de vida dos dois grupos étnicos
ggplot(states, aes(x = long, y = lat, group = group, fill = difer)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + labs(title="Diferenças na esperança de Vida dos grupos étnicos caucasianos e afro-americanos por estado nos EUA") + coord_map()

# Gerando um mapa interativo do mapa dos EUA com mensagem contextual para cada estado: Caucasianos-americanos
map_plot_caucasian = ggplot(states, aes(x = long, y = lat, group = group, fill = caucasiano)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + labs(title="Esperança de vida do grupo étnico caucasiano-americano") + coord_map()
ggplotly(map_plot_caucasian)

# #
map_plot_african = ggplot(states, aes(x = long, y = lat, group = group, fill = africano)) + geom_polygon(color = "white") + scale_fill_gradient(name = "Years", low = "#ffe8ee", high = "#c81f49", guide = "colorbar", na.value="#eeeeee") + labs(title="Esperança de vida do grupo étnico afro-americano") + coord_map()
ggplotly(map_plot_african)
