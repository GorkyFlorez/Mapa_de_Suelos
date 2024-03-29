# Llamando las librerias de Leaflet
library(png)  
library(broom)
library(tidyverse)
library(leaflet)#Libreria para graficar mapas interactivos
library(leaflet.extras)
library(leaflet.providers)
library(leafem)
library(htmlwidgets)#Para guardar el mapa
library(sp)
library(sf)#Manejo de informacion espacial
library(readxl)#Para leer archivos excel
library(mapview)#Para visualizacion de datos espaciales
library(RColorBrewer) #Paleta de Colores
library(viridis)
library(Rgb)
library(ggplot2)#Para distintos graficos incluso mapas
library(raster)#Para leer archivos raster
library(tidyverse)
library(rmarkdown)

#Defino todos mis varibles con la info de los shp
Distritos         <- st_read ("Data/Catastro_Distritos.shp")
Centro_Pobla      <- st_read ("Data/CP.shp") 
Especies          <- st_read ("Data/Inventario_de_Especies.shp") 
Suelos            <- st_read ("Data/Tipo_de_Suelo.shp")     

Distritos_utm         <- st_transform(Distritos  ,       crs = st_crs("+proj=longlat +datum=WGS84 +no_defs"))
Centro_Pobla_utm      <- st_transform(Centro_Pobla   ,   crs = st_crs("+proj=longlat +datum=WGS84 +no_defs"))
Especies_utm          <- st_transform(Especies  ,        crs = st_crs("+proj=longlat +datum=WGS84 +no_defs"))
Suelos_utm            <- st_transform(Suelos  , crs = st_crs("+proj=longlat +datum=WGS84 +no_defs"))

#Definiendo el Logo
m="https://images.vexels.com/media/users/3/143561/isolated/preview/afa3aa927b63061e3b0222b7dab9cdbf-ubicaci--n-n--utica-norte-flecha-vintage-by-vexels.png"


#Plotear los datos
plot(st_geometry(Distritos_utm ), lty=1,lwd=2)
plot(st_geometry(Centro_Pobla_utm ), col ="blue",fill= T, lty=1,lwd=2, add = T)
plot(st_geometry(Especies_utm ),col = "green", lty=1,lwd=2,add =T)

#Numero de Zonales
n_Suelos = Suelos_utm$DESCRIPCIO %>% unique()%>% length()

#Numero de cada zonal


#Paleta de colores de Zonales del Distrito de Comas
#Primero creamos el vector con los colores en este caso es un vector con 14 filas y 1 columna
colores_zonal = c('#fdae61','#a6d96a','#8dd3c7','#ffffb3','#ffffb3','#fb8072','#80b1d3','#fdb462','#b3de69','#fccde5')
#Tenemos para crear la paleta de colores "colorFactor" si la data es texto y "colorNumeric" si la data es double
pal2 = colorFactor(colores_zonal, domain = Comunidad_Nativa_utm$comunidad)
pal_colores <- colorFactor(palette = "viridis", domain = Suelos_utm$DESCRIPCIO)
#Popup
#Creamos el popup de los centros medicos con la data de los shp originales
popup_minsa = paste0("<b>","INSTITUCIÓN : ","</b>",as.character(minsa$Institucio),
                     "<br>","<b>","NOMBRE : ","</b>", as.character(minsa$Nombre),
                     "<br>","<b>","CLASIFICACION : ","</b>", as.character(minsa$Clasificac),
                     "<br>","<b>","TIPO : ","</b>", as.character(minsa$Tipo),
                     "<br>","<b>","DIRECCION : ","</b>", as.character(minsa$Direccion))

#Creamos el popup de las comisarias con la data de los shp originales
popup_comisarias = paste0("<b>","DISTRITO : ","</b>",as.character(comisarias$dist),
                          "<br>","<b>","COMISARIA : ","</b>", as.character(comisarias$nombre),
                          "<br>","<b>","ESTADO : ","</b>", as.character(comisarias$estado),
                          "<br>","<b>","ZONAL : ","</b>", as.character(comisarias$observacio))
#Mapa

M<-leaflet() %>%
  addControl(html = "<p><strong><em>Mapa de tipo de Suelo de Madre de Dios</em></strong></p>",
             position = "topright")%>%
  addLogo(m,url = "https://images.vexels.com/media/users/3/143561/isolated/preview/afa3aa927b63061e3b0222b7dab9cdbf-ubicaci--n-n--utica-norte-flecha-vintage-by-vexels.png",
          position = "topleft",
          offset.x = 50,
          offset.y = 10,
          width = 100,
          height = 100)%>%
  #Cargamos el Poligono del limite distrital de Comas
  addPolygons(data= Distritos_utm  ,
              color = "#444444",
              weight = 2,
              fillOpacity = 0.05,
              fillColor = 1,
              group = "Limite Distrital")%>%
  #Cargamos el poligno del limite de las zonasles del distrito de Comas
  addPolygons(data= Suelos_utm,
              color = pal_colores(Suelos_utm$DESCRIPCIO),
              fillOpacity = 0.5,
              label = Suelos_utm$DESCRIPCIO,
              group = "Zonales")%>%
  #Cargamos los centros de atencion medica, como circulos
  addCircles(data = Centro_Pobla_utm,
             color = "blue",
             radius =10,
             weight = 5,
             opacity = 1,
             fill = T,
             fillColor = "blue",
             fillOpacity = 1,
             group = "Centro Poblados") %>%
  #Cargamos las comisarias como circulos
  addCircles(data = Especies_utm ,
             color = "red",
             radius = 10,
             weight = 5,
             opacity = 1,
             fill = T,
             fillColor = "red",
             fillOpacity = 1,
             group = "Comisarias") %>%
  
  #addSearchFeatures()
  #addSearchFeatures(options = searchFeaturesOptions())%>%
  #Fubcion que me permite buscar ubicacion de algun lugar a partir de OSM
  #addSearchOSM()%>%
  #addSearchFeatures(options = searchFeaturesOptions())%>%
  #Esat funcion nos permite crear herramienta sde graficos y pder estimar areas y longitudes de estos
  addDrawToolbar(targetGroup = "Graficos",
                 editOptions = editToolbarOptions(selectedPathOptions = selectedPathOptions()))%>%
  
  #addMeasure-permite crear lineas y poligonos, con dato de perimtero y area
  addMeasure(position = "topleft",
             primaryLengthUnit = "meters",
             primaryAreaUnit = "sqmeters",
             activeColor = "#3D535D",
             completedColor = "#7D4479")%>%
  #Esta funcion nos permite obtener las areas y longitudes de poligonos y polilineas de una manera diferenciada,
  #te etiqueta los datos en el mapa web
  addMeasurePathToolbar(options = measurePathOptions(showOnHover = F,
                                                     showDistances = F,
                                                     showArea = T,
                                                     minPixelDistance = 400))%>%
  addLegend(position = "bottomright", pal = pal_colores, values = Suelos_utm$DESCRIPCIO, title= "Suelos ", opacity = 0.5)%>%
  
  #Agregamos una barra de escala, lo agregamos posterior a la leyenda de las zonales para ubicarla encima de la leyenda de zonales
  addScaleBar(position = "bottomright",options = scaleBarOptions(maxWidth = 100,
                                                                 metric = TRUE,
                                                                 imperial = TRUE,
                                                                 updateWhenIdle = TRUE))%>%
  addLegend(position = "bottomleft", colors="blue", labels = "Especies Forestales", opacity = 1)%>%
  addLegend(position = "bottomleft", colors="red", labels = "Centros Poblados", opacity = 1)%>%
  
  #Con esta funcion pemitimos el control de las capas del mapa web
  addLayersControl(baseGroups = c("Satellite", "OSM"),
                   overlayGroups = c("Suelos_utm","Centro_Pobla_utm","Distritos_utm","Especies_utm"),
                   position = "topright",
                   options = layersControlOptions(collapsed = T))%>%
  
  #Con esta funcion nos permite
  addProviderTiles(providers$Esri.WorldImagery, group = "Satellite")%>%
  addProviderTiles(providers$OpenStreetMap, group = "OSM")%>%
  addMiniMap(tiles = providers$Esri.WorldImagery,
           toggleDisplay = TRUE)%>%
  addSearchFeatures(targetGroups = "Centro_Pobla_utm")


# Gardar el mapa

htmlwidgets::saveWidget(M, "Mapa de Suelo de Madre de Dios.html")
saveWidget ( M , file = "index.html" )



