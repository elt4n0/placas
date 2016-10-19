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

**MUY PRONTO** estará funcionando como servicio.
