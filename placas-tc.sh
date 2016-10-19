#/bin/bash
#
# Acá se ponen las placas de la muerte
#

FFMPEG="ffmpeg"		# Path al bin del ffmpeg

PLACAS_IN="/media/placas-in"	# Ruta de placas previas al video
PLACAS_OUT="/media/placas-out"	# Ruta de placas posteriores al video
LAYERS="/media/layers"					# Overlays del video

INV="/media/videos"				# Ruta de watchfolder
OUTV="/media/videoscplacas" 	# Ruta de videos terminados

LOG="/var/log/placastc"			# Logfile

# Opciones de transcoder:
OPTSIN="-y -hwaccel auto -threads 8"	# Opciones de entrada
CV="libx264"							# Codec de video
BRV="5M"								# Bitrate de video
CA="aac"								# Codec de Audio
BRA="128k"								# Bitrate de Audio
FILTER="yadif" 	 						# Filtros extra
FMT="mp4"								# Formato de salida

# Funciones
function loguear {
	echo "$(date +'%H:%M:%S') $1" >> "$LOG"
}

# Contar placas
cntin=$(find "$PLACAS_IN" -maxdepth 1 -name '*.mxf' 2>/dev/null | wc -l)
cntout=$(find "$PLACAS_OUT" -maxdepth 1 -name '*.mxf' 2>/dev/null | wc -l)
cntlay=$(find "$LAYERS" -maxdepth 1 -name '*.png' 2>/dev/null  | wc -l)

if [ "$cntin" = "0" ] && [ "$cntout" = "0" ] && [ "$cntlay" = "0" ]; then
	loguear "ERROR: Se intentó ejecutar, pero no se encontraron ni placas ni overlays."
	echo "ERROR: No se encontraron placas ni overlays."
	exit 1
fi

# Inicio de ejecución
loguear "Se inicia ejecución con $PLACAS_IN placas de entrada, $PLACAS_OUT de salida y $LAYERS overlays."

##### Prueba:
# ffmpeg = """" & sCurrentDirectory & "ffmpeg\bin\ffmpeg.exe"" -y -hwaccel auto -threads 8 -i """ & objArgs(0) & """ -i auxmedia\CDA-Logo-Abajo-Derecha-20.png -i auxmedia\IN.MXF -i auxmedia\OUT.MXF -c:v mpeg2video -b:v 50M -filter_complex ""[0:0][1:0] overlay [vc]; [2:0][2:1][2:2][vc][0:1][0:2][3:0][3:1][3:2] concat=n=3:v=1:a=2 [v] [a1] [a2]"" -map ""[v]"" -map ""[a1]"" -map ""[a2]"" -f mxf """ & sCurrentDirectory & "CONVERTIDOS\" & basename & "_CDA.mxf"""

PLACAS_IN_STR=""
PLACAS_OUT_STR=""
LAYERS_STR=""
FILTRO=""
vconcat="[0:0]"			# Stream de video. Por defecto, [0:0], si hay overlays cambia.
al=1
OUTVS=""
OUTAS1="0:1"
OUTAS2="0:2"

if [ "$cntlay" != "0" ]; then
	for i in "$LAYERS"/*.png; do
		LAYERS_STR="$LAYERS_STR -i \"$i\""
		if [ $al = 1 ]; then
			FILTRO="$FILTRO[0:0][1:0] overlay [vo$al]"
		else
			FILTRO="$FILTRO; [vo$((al-1))][$al:0] overlay [vo$al]"
			vconcat="[vo$al]"
			OUTVS="[vo$al]"
		fi
		((al++))
	done
fi

echo $cntin

if [ "$cntin" != "0" ] || [ "$cntout" != "0" ]; then 		# Verificar si hay placas para poner
	concant=1		# Cantidad de archivos a concatenar. Empieza en 1 y crece.
	ain=$al
	if [ "$FILTRO" != "" ]; then
		FILTRO="$FILTRO; "
	fi
	
	if [ "$cntin" != "0" ]; then 		# Si hay placas de adelante
		for i in "$PLACAS_IN"/*.mxf; do
			PLACAS_IN_STR="$PLACAS_IN_STR -i \"$i\""
			FILTRO="$FILTRO[$ain:0][$ain:1][$ain:2]"
			((ain++))
			((concant++))
		done
	fi

	FILTRO="$FILTRO$vconcat[0:1][0:2]"

	if [ "$cntout" != "0" ]; then		# Si hay placas de atrás
		for i in "$PLACAS_OUT"/*.mxf; do
			PLACAS_OUT_STR="$PLACAS_OUT_STR -i \"$i\""
			FILTRO="$FILTRO [$ain:0][$ain:1][$ain:2]"
			((ain++))
			((concant++))
		done
	fi
	
	FILTRO="$FILTRO concat=n=$concant:v=1:a=2 [v] [a1] [a2]"
	OUTVS="[v]"
	OUTAS1="[a1]"
	OUTAS2="[a2]"
fi

FFSTRING="$FFMPEG $OPTSIN -i INVID $LAYERS_STR $PLACAS_IN_STR $_PLACAS_OUT_STR -c:v $CV -b:v $BRV -c:a $CA -b:a $BRA -filter_complex \"$FILTRO\" -map '$OUTVS' -map '$OUTAS1' -map '$OUTAS2' $OUTV/ARCHIVO.$FMT" # Armar el string que se va a usar para transcodear

echo $FFSTRING

# while :; do


        # if [ "$cnt" != "0" ]; then
        # cnt=$(find "$indir" -maxdepth 1 -cmin +0,25 -name '*.mxf' | wc -l)
        # if [ "$cnt" != "0" ]; then
                # for i in "$indir"/*.mxf; do

                        # ID=$(basename "$i" .mxf)
                        # cnt2=$(find "$outdir/done" -maxdepth 1 -name "*${ID}*" | wc -l)

                        # if [ "$cnt2" = "0" ]; then
                        # set -x
                                # loguear "[$servicio] Nuevo Archivo Encontrado: $i"
                                # GETRES=$(/usr/local/bin/ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height,width "$i")
                                # duracion_total=$(/usr/bin/printf '%.0f' "$(/usr/local/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$i")")
                                # eval "$GETRES"
                                # RES=${streams_stream_0_width}x${streams_stream_0_height}
                                # aspect=${ID:(-3)}
                                # loguear "[$servicio][$ID] Resolución: $RES"
                                # loguear "[$servicio][$ID] Duración en segundos (redondeada): $duracion_total"
                                # segmento=$((duracion_total/numnodes))
                                # if [ "$currentnode" != "$numnodes" ]; then menost="-t $segmento "; else menost=""; fi

                                # inicio=$(((currentnode - 1) * segmento))
								# read -n 1
                                # Transcodificacion HD
                                # if [[ "$RES" == "1920x1080" ]]; then
                                        # loguear "[$servicio][$ID] Transcodificando video HD"
                                        # loguear "[$servicio][$ID][Ejecución] ffmpeg $OPSIN -ss $inicio ${menost}-i $i $OPSH264 $OPSCOD $outdir/${ID}.part${currentnode}.mp4"
                                        # ERROR="$(/usr/local/bin/ffmpeg $OPSIN -ss $inicio ${menost}-i "$i" $OPSH264 $OPSCOD "$outdir"/"${ID}.part${currentnode}".mp4 2>&1)"

                                # Transcodificacion SD
                                # elif [[ "$aspect" == "4x3" ]]; then
                                        # loguear "[$servicio][$ID] Transcodificando video SD 4:3"
                                        # loguear "[$servicio][$ID][Ejecución] ffmpeg $OPSIN -ss $inicio ${menost}-i $i $OPSH264 -vf \"crop=720:576:0:32,scale=720:480\" $OPSC$
                                        # ERROR="$(/usr/local/bin/ffmpeg $OPSIN -ss $inicio ${menost}-i "$i" $OPSH264 -vf "crop=720:576:0:32,scale=720:480" $OPSCOD -aspect )";

                                # Transcodificacion SD
                                # elif [[ "$aspect" == "ANA" ]]; then
                                        # loguear "[$servicio][$ID] Transcodificando video SD Anamorfico"
                                        # loguear "[$servicio][$ID][Ejecución] ffmpeg $OPSIN -ss $inicio ${menost}-i $i $OPSH264 -vf \"crop=720:576:0:32,scale=720:408\" $OPSC$
                                        # ERROR="$(/usr/local/bin/ffmpeg $OPSIN -ss $inicio ${menost}-i "$i" $OPSH264 -vf "crop=720:576:0:32,scale=720:408" $OPSCOD -aspect 16)";
                                # else
                                # Transcodificacion Letterbox
                                        # loguear "[$servicio][$ID] Transcodificando video SD Letterbox"
                                        # loguear "[$servicio][$ID][Ejecución] ffmpeg $OPSIN -ss $inicio ${menost}-i $i $OPSH264 -vf \"crop=720:576:0:32,crop=720:438,scale=72
                                        # ERROR="$(/usr/local/bin/ffmpeg $OPSIN -ss $inicio ${menost}-i "$i" $OPSH264 -vf "crop=720:576:0:32,crop=720:438,scale=720:408" $OPSC$)";
                                # fi
                                # STATE="$?"
								
								# if [ "$STATE" = "0" ]; then
                                        # loguear "[$servicio][$ID][Ejecución] Completado"
                                        # PARTSIZE="$(wc -c <"$outdir"/"${ID}.part${currentnode}".mp4)"
                                        # if [ "$PARTSIZE" -le 10000000 ]; then
                                                # loguear "[$servicio][$ID][ERROR] Parte demasiado chica, probablemente incompleta. ($PARTSIZE). Rehaciendo..."
                                                # loguear "$(rm -v "$outdir"/"${ID}.part${currentnode}".mp4 2>&1)"
                                        # else
                                                # loguear "$(mv -v "$outdir"/"${ID}.part${currentnode}".mp4 "$outdir"/done/"${ID}.part${currentnode}".mp4 2>&1)"
                                        # fi
                                # else
                                        # loguear "[$servicio][$ID][ERROR] FFMpeg devolvió un error: $ERROR"
                                        # loguear "$(rm -v "$outdir"/"${ID}.part${currentnode}".mp4 2>&1)"
                                # fi

                        # fi
                # done
        # fi
# done




