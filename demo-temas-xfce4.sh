#!/bin/bash
# ============================================================================
# DEMOSTRACIÓN DE TEMAS GTK+ EN XFCE4 CON OSD (On-Screen Display)
# ============================================================================
# 
# Este guion demuestra la aplicación de temas GTK+ en Xfce4, mostrando
# cambios en tiempo real con aplicaciones de ejemplo y OSD informativo.
#
# Autor: Joel Barrios Dueñas
# Proyecto: ALDOS - Alcance Libre
# Licencia: GPL v3 o posterior
# ============================================================================

# ----------------------------------------------------------------------------
# CONFIGURACIÓN Y CONSTANTES
# ----------------------------------------------------------------------------
set -e  # Salir inmediatamente si cualquier comando falla
set -u  # Tratar variables no definidas como errores

# Tiempos didácticos fijos (en segundos)
TIEMPO_OBSERVACION=4.0
TIEMPO_OSD_TRANSICION=5.0

# Lista de temas GTK+ a demostrar
TEMAS_GTK=(
    "Adwaita"
    "Adwaita-dark"
    "HighContrast"
    "HighContrastInverse"
)

# Aplicaciones de demostración (se abren y cierran para mostrar el tema)
APPS_DEMO=(
    "xfce4-about"
    "thunar"
    "mousepad"
)

# Rutas y nombres
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NOMBRE="$(basename "$0")"
TEMA_XFCE4_SH="tema-xfce4.sh"
TEMA_XFCE4_RUTA="${SCRIPT_DIR}/${TEMA_XFCE4_SH}"

# Variables globales
ancho=""            # Ancho de pantalla detectado
alto=""             # Alto de pantalla detectado
pos_y_dinamica=""   # Posición Y dinámica para OSD (negativa desde el fondo)
OSD_PID=""          # PID del último OSD mostrado (para posible terminación)

# ----------------------------------------------------------------------------
# FUNCIONES AUXILIARES Y DE CONFIGURACIÓN
# ----------------------------------------------------------------------------

obtener_resolucion() {
    # Obtiene la resolución de pantalla primaria y calcula la posición Y para OSD.
    # CONFIGURACIÓN: Ajusta estos valores para cambiar la posición vertical del OSD.
    local porcentaje_desde_abajo=10   # Porcentaje desde el borde inferior (ej: 10 para 10%)
    local offset_ajuste=50            # Ajuste adicional en píxeles (compensa la altura del OSD)

    local resolucion
    if command -v xrandr &>/dev/null; then
        resolucion=$(xrandr --current | grep -E "\*" | head -n1 | awk '{print $1}')
        ancho=$(echo "$resolucion" | cut -d'x' -f1)
        alto=$(echo "$resolucion" | cut -d'x' -f2)
    else
        # Fallback: usar valores por defecto (1920x1080)
        ancho=1920
        alto=1080
    fi
    
    # Calcular posición Y negativa: (alto * porcentaje/100) + offset
    local distancia_desde_abajo=$(( (alto * porcentaje_desde_abajo) / 100 + offset_ajuste ))
    
    # Posición Y debe ser NEGATIVA para aosd_cat (coordenadas desde el fondo)
    pos_y_dinamica="-$distancia_desde_abajo"
    
    # [DEBUG] Información útil para pruebas
    if [ "${MODO_PRUEBA_OSD:-0}" = "1" ] || [ "${DEBUG:-0}" = "1" ]; then
        echo "[DEBUG] Resolución detectada: ${ancho}x${alto}" >&2
        echo "[DEBUG] Cálculo: (${alto} * ${porcentaje_desde_abajo}%)/100 + ${offset_ajuste} = ${distancia_desde_abajo}px desde abajo" >&2
        echo "[DEBUG] Posición Y final para aosd_cat: ${pos_y_dinamica}" >&2
    fi
}

mostrar_osd_aplicacion() {
    local nombre_app="$1"
    local tema_actual="$2"
    local mensaje="APLICACIÓN: ${nombre_app} | TEMA: ${tema_actual}"
    
    # Limpiar OSD previo si existe
    if [ -n "${OSD_PID:-}" ] && kill -0 "$OSD_PID" 2>/dev/null; then
        wait "$OSD_PID" 2>/dev/null || true
    fi
    
    # Mostrar nuevo OSD y capturar su PID
    echo "$mensaje" | aosd_cat \
        -n "Montserrat Black 32" \
        -u 4500 \
        -o 300 \
        -R white \
        -S "#2D2D2D" \
        -f 300 \
        -y "$pos_y_dinamica" \
        -x 50 \
        -t 2 \
        -e 5 &
    
    OSD_PID=$!
    # ESPERAR a que este OSD termine completamente antes de continuar
    wait "$OSD_PID" 2>/dev/null || true
}

mostrar_osd_transicion() {
    local tema_anterior="$1"
    local tema_nuevo="$2"
    local mensaje="CAMBIANDO TEMA: ${tema_anterior} → ${tema_nuevo}"
    
    # Limpiar OSD previo si existe
    if [ -n "${OSD_PID:-}" ] && kill -0 "$OSD_PID" 2>/dev/null; then
        wait "$OSD_PID" 2>/dev/null || true
    fi
    
    # Mostrar nuevo OSD y capturar su PID
    echo "$mensaje" | aosd_cat \
        -n "Montserrat Black 32" \
        -u 5000 \
        -o 300 \
        -R white \
        -S "#2D2D2D" \
        -f 300 \
        -y "$pos_y_dinamica" \
        -x 50 \
        -t 2 \
        -e 5 &
    
    OSD_PID=$!
    # ESPERAR a que este OSD termine completamente antes de continuar
    wait "$OSD_PID" 2>/dev/null || true
}

validar_dependencias() {
    # Valida que todas las dependencias estén instaladas.
    echo "========================================"
    echo "  DEMOSTRACIÓN CON OSD - TEMAS GTK+ EN XFCE"
    echo "========================================"
    echo ""
    
    local faltantes=()
    
    # Dependencias principales
    for cmd in simplescreenrecorder xdotool; do
        if ! command -v "$cmd" &>/dev/null; then
            faltantes+=("$cmd")
        else
            echo "[INFO] $cmd encontrado."
        fi
    done
    
    # Dependencia crítica: tema-xfce4.sh
    if [ ! -f "$TEMA_XFCE4_RUTA" ]; then
        echo "[ERROR] No se encuentra: $TEMA_XFCE4_SH"
        echo "[INFO] Descárgalo de: https://github.com/darkshram/aldos-tools/blob/main/$TEMA_XFCE4_SH"
        exit 1
    else
        echo "[INFO] $TEMA_XFCE4_SH encontrado."
    fi
    
    # Verificar si hay faltantes
    if [ ${#faltantes[@]} -gt 0 ]; then
        echo "[ERROR] Faltan dependencias: ${faltantes[*]}"
        echo "[INFO] Instala con: sudo dnf install ${faltantes[*]}"
        exit 1
    fi
    
    echo "[ÉXITO] Todas las dependencias están satisfechas."
    echo ""
}

validar_dependencias_osd() {
    # Valida dependencias específicas para OSD.
    echo "[INFO] Validando dependencias para OSD..."
    
    if ! command -v aosd_cat &>/dev/null; then
        echo "[ERROR] aosd_cat no está instalado."
        echo "[INFO] Instala con: sudo dnf install aosd-cat"
        exit 1
    fi
    
    # Verificar fuente Montserrat (opcional pero recomendado)
    local fuente_ruta="/usr/share/fonts/julietaula-montserrat/Montserrat-Black.ttf"
    if [ ! -f "$fuente_ruta" ]; then
        echo "[ADVERTENCIA] Fuente Montserrat no encontrada en: $fuente_ruta"
        echo "[INFO] El OSD usará una fuente alternativa."
    else
        echo "[INFO] Fuente Montserrat verificada."
    fi
    
    echo "[ÉXITO] Dependencias OSD validadas."
    echo ""
}

precalentar_sudo_pkcon() {
    # Precalienta sudo y pkcon para evitar prompts durante la demostración.
    # Esto asegura que los cambios de tema ocurran sin interrupciones.
    echo "[INFO] Precalentando sudo y pkcon..."
    sudo -v
    if command -v pkcon &>/dev/null; then
        pkcon refresh force &>/dev/null || true
    fi
    echo "[ÉXITO] Precalentamiento completado."
    echo ""
}

cerrar_aplicaciones_demo() {
    # Cierra todas las aplicaciones de demostración que puedan estar abiertas.
    for app in "${APPS_DEMO[@]}"; do
        pkill -x "$app" 2>/dev/null || true
    done
    sleep 0.5
}

mostrar_cabecera_tema() {
    # Muestra una cabecera informativa para cada tema.
    local tema="$1"
    local indice="$2"
    local total="$3"
    
    clear
    echo "========================================"
    echo "  DEMOSTRACIÓN DE TEMAS GTK+ EN XFCE4"
    echo "========================================"
    echo ""
    echo "Tema ${indice}/${total}: $(echo "$tema" | tr '-' ' ')"
    echo "Aplicando y observando cambios..."
    echo ""
    echo "Aplicaciones de demostración:"
    echo "  1. xfce4-about (Acerca de Xfce)"
    echo "  2. thunar (Gestor de archivos)"
    echo "  3. mousepad (Editor de texto)"
    echo ""
    echo "Presiona Ctrl+C para interrumpir la demostración."
    echo ""
}

aplicar_tema() {
    # Aplica un tema GTK+ usando tema-xfce4.sh
    local tema="$1"
    
    echo "[INFO] Aplicando tema: $tema"
    if [ -f "$TEMA_XFCE4_RUTA" ]; then
        bash "$TEMA_XFCE4_RUTA" "$tema"
    else
        echo "[ERROR] No se puede encontrar: $TEMA_XFCE4_SH"
        exit 1
    fi
}

abrir_aplicaciones_demo() {
    # Abre las aplicaciones de demostración en posiciones específicas.
    
    # 1. xfce4-about (centro superior)
    echo "[INFO] Abriendo: xfce4-about"
    xfce4-about &
    sleep 0.5
    xdotool search --class "xfce4-about" windowmove 600 100 &
    
    # 2. thunar (centro izquierda)
    echo "[INFO] Abriendo: thunar"
    thunar &
    sleep 0.5
    xdotool search --class "Thunar" windowmove 100 300 &
    
    # 3. mousepad (centro derecha)
    echo "[INFO] Abriendo: mousepad"
    mousepad &
    sleep 0.5
    xdotool search --class "Mousepad" windowmove 1000 300 &
    
    # Esperar a que todas las aplicaciones estén listas
    sleep 1.5
}

rotar_foco_aplicaciones() {
    # Rota el foco entre las aplicaciones de demostración.
    for app_class in "xfce4-about" "Thunar" "Mousepad"; do
        echo "[INFO] Rotando foco a: $app_class"
        xdotool search --class "$app_class" windowactivate
        sleep 0.5
    done
}

prueba_osd() {
    echo "[INFO] MODO PRUEBA OSD - Mostrando todos los mensajes en secuencia"
    obtener_resolucion
    
    echo "[INFO] 1. OSD de transición (cambio de tema)..."
    mostrar_osd_transicion "Adwaita" "Adwaita-dark"
    
    echo "[INFO] 2. OSD de aplicación (Acerca de Xfce)..."
    mostrar_osd_aplicacion "Acerca de Xfce" "Adwaita"
    
    echo "[INFO] 3. OSD de aplicación (Thunar)..."
    mostrar_osd_aplicacion "Thunar" "Adwaita-dark"
    
    echo "[INFO] 4. OSD de aplicación (Mousepad)..."
    mostrar_osd_aplicacion "Mousepad" "Adwaita"
    
    echo "[INFO] Prueba OSD completada. Si viste todos los mensajes EN SECUENCIA, el sistema está funcionando."
    echo ""
}

mostrar_menu_grabacion() {
    # Muestra el menú de opciones de grabación.
    clear
    echo "========================================"
    echo "  DEMOSTRACIÓN CON OSD - TEMAS GTK+ EN XFCE"
    echo "========================================"
    echo ""
    echo "Selecciona el modo de grabación:"
    echo ""
    echo "  1. Grabar con FFmpeg (recomendado para video final)"
    echo "  2. Grabar con SimpleScreenRecorder (interfaz gráfica)"
    echo "  3. No grabar (solo demostración)"
    echo "  4. Salir"
    echo ""
    echo -n "Tu elección [1-4]: "
}

grabar_ffmpeg() {
    # Inicia grabación con FFmpeg en segundo plano.
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local archivo_salida="demo-temas-${timestamp}.mp4"
    
    echo "[INFO] Iniciando grabación con FFmpeg..."
    echo "[INFO] El video se guardará como: $archivo_salida"
    echo "[INFO] Presiona 'q' en la terminal de FFmpeg para finalizar la grabación."
    echo ""
    
    ffmpeg -f x11grab -video_size "${ancho}x${alto}" -framerate 30 -i :0.0 \
           -vcodec libx264 -preset fast -pix_fmt yuv420p \
           "$archivo_salida" 2>/dev/null &
    
    FFMPEG_PID=$!
    echo "[INFO] FFmpeg iniciado (PID: $FFMPEG_PID)"
    sleep 2
}

detener_ffmpeg() {
    # Detiene la grabación de FFmpeg.
    if [ -n "${FFMPEG_PID:-}" ]; then
        echo "[INFO] Deteniendo FFmpeg (PID: $FFMPEG_PID)..."
        kill -INT "$FFMPEG_PID" 2>/dev/null || true
        wait "$FFMPEG_PID" 2>/dev/null || true
        echo "[ÉXITO] Grabación finalizada."
    fi
}

ejecutar_demostracion() {
    # Función principal que ejecuta la demostración completa.
    local modo_grabacion="$1"
    
    # Precalentar sudo/pkcon para evitar prompts
    precalentar_sudo_pkcon
    
    # Cerrar aplicaciones previas
    cerrar_aplicaciones_demo
    
    # Obtener resolución para OSD y grabación
    obtener_resolucion
    
    # Iniciar grabación si se seleccionó
    if [ "$modo_grabacion" = "1" ]; then
        grabar_ffmpeg
        echo "[INFO] La grabación ha comenzado. Iniciando demostración en 3 segundos..."
        sleep 3
    elif [ "$modo_grabacion" = "2" ]; then
        echo "[INFO] Modo SimpleScreenRecorder seleccionado."
        echo "[INFO] Inicia la grabación manualmente con Ctrl+Shift+R antes de continuar."
        echo -n "[INFO] Presiona Enter cuando estés listo para comenzar la demostración... "
        read -r
    fi
    
    # Ejecutar ciclo de temas
    local total_temas=${#TEMAS_GTK[@]}
    
    for ((i=0; i<total_temas; i++)); do
        tema_actual="${TEMAS_GTK[$i]}"
        indice=$((i+1))
        
        # Mostrar cabecera
        mostrar_cabecera_tema "$tema_actual" "$indice" "$total_temas"
        
        # Aplicar tema (excepto en el primer ciclo, asumiendo tema por defecto ya aplicado)
        if [ $i -gt 0 ]; then
            tema_anterior="${TEMAS_GTK[$((i-1))]}"
            
            # Mostrar OSD de transición
            echo "[INFO] Transición: $tema_anterior → $tema_actual"
            mostrar_osd_transicion "$tema_anterior" "$tema_actual"
            
            # Aplicar nuevo tema
            aplicar_tema "$tema_actual"
            
            # Esperar tiempo de transición OSD
            sleep "$TIEMPO_OSD_TRANSICION"
        else
            # Primer tema: aplicar sin transición previa
            aplicar_tema "$tema_actual"
        fi
        
        # Cerrar y abrir aplicaciones para mostrar el nuevo tema
        cerrar_aplicaciones_demo
        abrir_aplicaciones_demo
        
        # Mostrar OSD para cada aplicación
        for app in "${APPS_DEMO[@]}"; do
            case "$app" in
                "xfce4-about")
                    mostrar_osd_aplicacion "Acerca de Xfce" "$tema_actual"
                    ;;
                "thunar")
                    mostrar_osd_aplicacion "Thunar" "$tema_actual"
                    ;;
                "mousepad")
                    mostrar_osd_aplicacion "Mousepad" "$tema_actual"
                    ;;
            esac
            sleep 1
        done
        
        # Rotar foco entre aplicaciones
        rotar_foco_aplicaciones
        
        # Tiempo de observación
        echo "[INFO] Observando tema durante ${TIEMPO_OBSERVACION}s..."
        sleep "$TIEMPO_OBSERVACION"
        
        # Cerrar aplicaciones para el próximo tema
        if [ $i -lt $((total_temas-1)) ]; then
            cerrar_aplicaciones_demo
        fi
    done
    
    # Finalizar grabación si se inició
    if [ "$modo_grabacion" = "1" ]; then
        detener_ffmpeg
    fi
    
    # Cerrar aplicaciones finales
    cerrar_aplicaciones_demo
    
    echo ""
    echo "[ÉXITO] Demostración completada."
    if [ "$modo_grabacion" = "1" ]; then
        echo "[INFO] Video guardado en: $(pwd)/demo-temas-*.mp4"
    fi
    echo ""
}

main() {
    # Función principal del guion.
    
    # Validar argumentos
    if [ $# -eq 1 ] && [ "$1" = "--test-osd" ]; then
        validar_dependencias
        validar_dependencias_osd
        prueba_osd
        exit 0
    fi
    
    # Validar dependencias
    validar_dependencias
    validar_dependencias_osd
    
    # Obtener resolución para OSD
    obtener_resolucion
    
    # Menú principal
    while true; do
        mostrar_menu_grabacion
        read -r opcion
        
        case "$opcion" in
            1)
                echo "[INFO] Modo FFmpeg seleccionado."
                ejecutar_demostracion "1"
                break
                ;;
            2)
                echo "[INFO] Modo SimpleScreenRecorder seleccionado."
                ejecutar_demostracion "2"
                break
                ;;
            3)
                echo "[INFO] Modo sin grabación seleccionado."
                ejecutar_demostracion "3"
                break
                ;;
            4)
                echo "[INFO] Saliendo."
                exit 0
                ;;
            *)
                echo "[ERROR] Opción inválida. Intenta de nuevo."
                sleep 1
                ;;
        esac
    done
    
    exit 0
}

# ----------------------------------------------------------------------------
# EJECUCIÓN PRINCIPAL
# ----------------------------------------------------------------------------
main "$@"
