# Script de insersión de placas y overlays usando FFMpeg

Este script permite automatizar la concatenación de videos, insertado segmentos al principio y al final de un video de entrada. También se aplican overlays sobre el video de entrada, para agregar por ejemplo una marca de agua.

## Uso
1. Copiar placas-tc.conf a /etc
2. Editarlo para establecer valores de los parámetros
  * FFMPEG: Ruta del ffmpeg, u otro conversor. (default: ffmpeg)
  * PLACAS_IN: Ruta de placas previas al video
  * PLACAS_OUT: Ruta de placas posteriores al video
  * LAYERS: Ruta de overlays del video
  * INV: Ruta de watchfolder
  * OUTV: Ruta de videos terminados 
  * LOG: Logfile
3. Ejecutar "placas-tc-manual.sh {Archivo de entrada}" para generar un nuevo video con los parametros establecidos, sus overlays y placas.

## Formatos

Las placas de entrada y salida deberán estar, de momento, en formato 'mxf'.
Los layers a sobreponer deberán estar en formato 'png', y ya que no se utilizan coordenadas, se recomienda que tengan el mismo tamaño que el video de entrada, y transparencia.

**Se recuerda que en linux, las extensiones son case sensitive, por lo tanto un archivo extension 'MXF' o 'PNG' no será reconocido.**

## Orden de placas y overlays

Las placas se ponen en orden alfabético de nombre de archivo. Se recomienda que se depositen en sus carpetas con orden numerado. EJ:

1_PLACA1.mxf
2_PLACA2.mxf
**MUY PRONTO** estará funcionando como servicio.
