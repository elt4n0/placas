#/bin/bash
#
# Este script queda ejecutado como un servicio.
# Busca constantemente nuevos videos en un watchfolder, y al encontrar uno
# realiza la inserción de placas y overlays.
#

# Cargar configuración
source /etc/placas-tc.conf

# Funciones
function loguear {
echo "$(date +'%H:%M:%S') $1" >> "$LOG"
}

# Contar placas
cntin=$(find "$PLACAS_IN" -maxdepth 1 -name '*.mxf' 2>/dev/null | wc -l)
cntout=$(find "$PLACAS_OUT" -maxdepth 1 -name '*.mxf' 2>/dev/null | wc -l)
cntlay=$(find "$LAYERS" -maxdepth 1 -name '*.png' 2>/dev/null  | wc -l)


if [ "$cntin" = "0" ] && [ "$cntout" = "0" ] && [ "$cntlay" = "0" ]; then
	loguear "ERROR: Se intentó iniciar servicio, pero no se encontraron ni placas ni overlays."
	echo "ERROR: No se encontraron placas ni overlays."
	exit 1
fi

# Inicio de ejecucin
loguear "--- INICIO DE SERVICIO ---"
loguear "Se inicia ejecución con $cntin placas de entrada, $cntout de salida y $cntlay overlays."

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
		fi
		vconcat="[vo$al]"
		OUTVS="[vo$al]"
		((al++))
	done
fi

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
			FILTRO="$FILTRO[$ain:0][$ain:1][$ain:2]"
			((ain++))
			((concant++))
		done
	fi
	
	FILTRO="$FILTRO concat=n=$concant:v=1:a=2 [v] [a1] [a2]"
	OUTVS="[v]"
	OUTAS1="[a1]"
	OUTAS2="[a2]"
fi

FFSTRING1="$FFMPEG $OPTSIN -i"
FFSTRING2="$LAYERS_STR $PLACAS_IN_STR $PLACAS_OUT_STR -c:v $CV -b:v $BRV -c:a $CA -b:a $BRA -filter_complex \"$FILTRO\" -map '$OUTVS' -map '$OUTAS1' -map '$OUTAS2' $OUTV/$ARGFNAME.$FMT"

while :; do
    invidcnt=$(find "$INV" -maxdepth 1 -cmin +0.25 -name '*.mxf' | wc -l)
	if [ "$invidcnt" != "0" ]; then
		
		for cvideo in "$INV"/*.mxf; do
			loguear "Archivo $cvideo recibido"
			echo "Archivo $cvideo recibido"
			FFSTRING="$FFSTRING1 $cvideo $FFSTRING2"
			loguear "Ejecución: $FFSTRING"
			echo "Ejecución: $FFSTRING"
			eval $FFSTRING
			loguear "Ejecución finalizada para $cvideo."
			mv $cvideo $OUTOV
		done
  
	fi
done
