#!/bin/bash
# ============================================================================
# DEMOSTRACIÓN SIMPLIFICADA DE TEMAS GTK+ EN XFCE4 CON OSD
# ============================================================================
# 
# Este guion demuestra la aplicación de temas GTK+ en Xfce4 usando awf-gtk3,
# mostrando cambios en tiempo real con OSD informativo.
#
# Autor: Joel Barrios Dueñas
# Proyecto: ALDOS - Alcance Libre
# Licencia: GPL-3.0-or-later
# ============================================================================

# ----------------------------------------------------------------------------
# CONFIGURACIÓN Y CONSTANTES
# ----------------------------------------------------------------------------
set -e
set -u

TIEMPO_OBSERVACION=6.0

TEMAS_GTK=(
    "Adwaita" "Nordic" "NordicPolar" "Dracula" "Chicago95"
    "Redmond98" "RedmondXP" "Redmond7" "Redmond10" "ALDOS"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMA_XFCE4_SH="tema-xfce4.sh"
TEMA_XFCE4_RUTA="${SCRIPT_DIR}/${TEMA_XFCE4_SH}"

# Variables globales
ancho="" alto="" pos_y_dinamica="" OSD_PID="" FFMPEG_PID="" AWF_PID="" TERMINAL_WIN=""

# ----------------------------------------------------------------------------
# FUNCIONES AUXILIARES
# ----------------------------------------------------------------------------
obtener_resolucion() {
    local porcentaje_desde_abajo=10 offset_ajuste=50 resolucion
    if command -v xrandr &>/dev/null; then
        resolucion=$(xrandr --current | grep -E "\*" | head -n1 | awk '{print $1}')
        ancho=$(echo "$resolucion" | cut -d'x' -f1)
        alto=$(echo "$resolucion" | cut -d'x' -f2)
    else
        ancho=1920 alto=1080
    fi
    local distancia_desde_abajo=$(( (alto * porcentaje_desde_abajo) / 100 + offset_ajuste ))
    pos_y_dinamica="-$distancia_desde_abajo"
}

mostrar_osd_tema() {
    local tema_actual="$1" mensaje="TEMA: ${tema_actual}"
    if [ -n "${OSD_PID:-}" ] && kill -0 "$OSD_PID" 2>/dev/null; then wait "$OSD_PID" 2>/dev/null || true; fi
    echo "$mensaje" | aosd_cat -n "Montserrat Black 32" -u 5000 -o 300 -R white -S "#2D2D2D" -f 300 -y "$pos_y_dinamica" -x 50 -t 2 -e 5 &
    OSD_PID=$!
    sleep 0.5
}

validar_dependencias() {
    echo "========================================"
    echo "  DEMOSTRACIÓN SIMPLIFICADA - TEMAS GTK+"
    echo "========================================"
    echo ""
    local faltantes=()
    for cmd in awf-gtk3 xdotool; do
        if ! command -v "$cmd" &>/dev/null; then faltantes+=("$cmd")
        else echo "[INFO] $cmd encontrado."; fi
    done
    if [ ! -f "${TEMA_XFCE4_RUTA}" ]; then
        echo "[ERROR] No se encuentra: ${TEMA_XFCE4_SH}"
        exit 1
    else echo "[INFO] ${TEMA_XFCE4_SH} encontrado."; fi
    if [ ${#faltantes[@]} -gt 0 ]; then
        echo "[ERROR] Faltan dependencias: ${faltantes[*]}"; exit 1
    fi
    echo "[ÉXITO] Todas las dependencias están satisfechas."; echo ""
}

validar_dependencias_osd() {
    echo "[INFO] Validando dependencias para OSD..."
    if ! command -v aosd_cat &>/dev/null; then
        echo "[ERROR] aosd_cat no está instalado."; exit 1
    fi
    echo "[ÉXITO] Dependencias OSD validadas."; echo ""
}

precalentar_sudo_pkcon() {
    echo "[INFO] Precalentando sudo y pkcon..."; sudo -v
    if command -v pkcon &>/dev/null; then pkcon refresh force &>/dev/null || true; fi
    echo "[ÉXITO] Precalentamiento completado."; echo ""
}

precargar_gtk3_libs() {
    echo "[INFO] Precargando bibliotecas GTK3..."
    local temp_script=$(mktemp)
    cat > "$temp_script" << 'EOF'
import gi; gi.require_version('Gtk', '3.0'); from gi.repository import Gtk; print("GTK3 precargado")
EOF
    if command -v python3 &>/dev/null; then
        python3 "$temp_script" &>/dev/null && echo "[INFO] GTK3 precargado via Python" || echo "[ADVERTENCIA] No se pudo precargar GTK3"
    else echo "[ADVERTENCIA] Python3 no disponible, omitiendo precarga"; fi
    rm -f "$temp_script"; echo "[ÉXITO] Precarga completada."; echo ""
}

guardar_ventana_terminal() { TERMINAL_WIN=$(xdotool getactivewindow 2>/dev/null || echo ""); }
restaurar_ventana_terminal() { if [ -n "$TERMINAL_WIN" ]; then xdotool windowactivate "$TERMINAL_WIN" 2>/dev/null || true; sleep 0.5; fi; }

# FUNCIÓN MODIFICADA: Ahora mueve la ventana con Alt+F7 + flechas
iniciar_awf_gtk3() {
    echo "[INFO] Iniciando awf-gtk3..."
    pkill -x "awf-gtk3" 2>/dev/null || true; sleep 0.5
    awf-gtk3 & AWF_PID=$!
    echo "[INFO] Esperando a que awf-gtk3 se inicie..."
    local intentos=0 ventana_id=""
    while [ $intentos -lt 15 ] && [ -z "$ventana_id" ]; do
        sleep 0.5; ventana_id=$(xdotool search --class "awf-gtk3" 2>/dev/null | head -1); intentos=$((intentos + 1))
    done
    if [ -z "$ventana_id" ]; then echo "[ERROR] No se pudo encontrar ventana de awf-gtk3"; return 1; fi

    # Mover ventana a la derecha usando Alt+F7 (ataque Xfce para mover)
    echo "[INFO] Moviendo awf-gtk3 a la derecha con Alt+F7..."
    xdotool windowactivate "$ventana_id"; sleep 0.8
    xdotool key alt+F7; sleep 0.5  # Entra en modo mover ventana

    # Enviar múltiples flechas derecha para desplazar
    local pasos_derecha=12  # Ajusta este número según cuánto quieras moverla
    for ((i=0; i<pasos_derecha; i++)); do
        xdotool key Right; sleep 0.15  # Pausa necesaria entre teclas
    done
    xdotool key Return; sleep 0.5  # Sale del modo mover

    # Asegurar que está activa
    xdotool windowactivate "$ventana_id"; xdotool windowraise "$ventana_id"; sleep 0.5
    echo "[ÉXITO] awf-gtk3 posicionado (PID: $AWF_PID)"; echo ""
}

cerrar_awf_gtk3() {
    echo "[INFO] Cerrando awf-gtk3..."
    if [ -n "$AWF_PID" ]; then
        local ventana_id=$(xdotool search --class "awf-gtk3" 2>/dev/null | head -1)
        if [ -n "$ventana_id" ]; then xdotool windowactivate "$ventana_id"; sleep 0.3; xdotool key alt+F4; sleep 1; fi
        if ps -p "$AWF_PID" > /dev/null 2>&1; then kill -TERM "$AWF_PID" 2>/dev/null || true; sleep 0.5; fi
    fi
    pkill -x "awf-gtk3" 2>/dev/null || true
    echo "[ÉXITO] awf-gtk3 cerrado."
}

aplicar_tema() {
    local tema="$1"
    local inicio fin duracion resultado
    
    echo "[INFO] Aplicando tema: $tema"
    inicio=$(date +%s)
    
    if [ -f "${TEMA_XFCE4_RUTA}" ]; then
        bash "${TEMA_XFCE4_RUTA}" "$tema"
        resultado=$?
        fin=$(date +%s)
        duracion=$((fin - inicio))
        
        if [ $resultado -eq 0 ]; then
            echo "[ÉXITO] Tema aplicado en ${duracion} segundos"
            return 0
        else
            echo "[ERROR] No se pudo aplicar el tema (código: $resultado)"
            return 1
        fi
    else
        echo "[ERROR] No se puede encontrar: ${TEMA_XFCE4_SH}"
        return 1
    fi
}

# ----------------------------------------------------------------------------
# FUNCIONES DE GRABACIÓN
# ----------------------------------------------------------------------------
calcular_duracion_total() {
    local num_temas=${#TEMAS_GTK[@]} tiempo_por_tema=$((TIEMPO_OBSERVACION + 3))
    local duracion_total=$((tiempo_por_tema * num_temas))
    if [ "$duracion_total" -lt 10 ]; then duracion_total=10; fi
    echo "$duracion_total"
}
preparar_grabacion_desatendida() {
    local modo="$1"
    case "$modo" in
        "1")  # FFmpeg
            local timestamp=$(date +%Y%m%d-%H%M%S) archivo_salida="demo-temas-${timestamp}.mp4"
            local resolucion="${ancho}x${alto}" duracion_total=$(calcular_duracion_total)
            echo "[INFO] Iniciando grabación FFmpeg..."; echo "[INFO] Duración: ${duracion_total}s"; echo "[INFO] Archivo: ${archivo_salida}"; echo ""
            ffmpeg -f x11grab -video_size "$resolucion" -framerate 25 -i :0.0 -t "$duracion_total" -c:v libx264 -preset fast -pix_fmt yuv420p -y "$archivo_salida" >/tmp/ffmpeg.log 2>&1 &
            FFMPEG_PID=$!; echo "[INFO] FFmpeg iniciado (PID: $FFMPEG_PID)"; sleep 3;;
        "2")  # SimpleScreenRecorder
            echo "[INFO] Configurando SimpleScreenRecorder..."; echo ""; echo -n "[INFO] Iniciando grabación en 3 segundos... "; sleep 3
            xdotool key ctrl+shift+r; echo "[INFO] Grabación iniciada (Ctrl+Shift+R enviado)"; sleep 2;;
    esac
}
finalizar_grabacion_desatendida() {
    local modo="$1"
    case "$modo" in
        "1") if [ -n "${FFMPEG_PID:-}" ]; then echo "[INFO] Esperando a que FFmpeg termine..."; wait "$FFMPEG_PID" 2>/dev/null || true; echo "[ÉXITO] Grabación FFmpeg finalizada."; fi;;
        "2") echo "[INFO] Finalizando grabación SimpleScreenRecorder..."; sleep 1; xdotool key ctrl+shift+r; echo "[INFO] Grabación pausada. Guarda manualmente."; sleep 1;;
    esac
}

# ----------------------------------------------------------------------------
# FUNCIÓN PRINCIPAL DE DEMOSTRACIÓN - FLUJO MODIFICADO
# ----------------------------------------------------------------------------
ejecutar_demostracion() {
    local modo_grabacion="$1"
    guardar_ventana_terminal
    precalentar_sudo_pkcon; precargar_gtk3_libs; obtener_resolucion
    if ! iniciar_awf_gtk3; then echo "[ERROR] No se pudo iniciar awf-gtk3."; restaurar_ventana_terminal; exit 1; fi
    if [ "$modo_grabacion" = "1" ] || [ "$modo_grabacion" = "2" ]; then preparar_grabacion_desatendida "$modo_grabacion"; sleep 2; fi

    local total_temas=${#TEMAS_GTK[@]}
    echo ""; echo "========================================"; echo "  INICIANDO DEMOSTRACIÓN DE ${total_temas} TEMAS"; echo "========================================"; echo ""
    for ((i=0; i<total_temas; i++)); do
        tema_actual="${TEMAS_GTK[$i]}"; indice=$((i+1))
        echo "[TEMA ${indice}/${total_temas}] ${tema_actual}"; echo "----------------------------------------"
        # 1. APLICAR TEMA PRIMERO
        if aplicar_tema "$tema_actual"; then
            # 2. LUEGO MOSTRAR OSD
            mostrar_osd_tema "$tema_actual"
            # 3. FINALMENTE ESPERAR TIEMPO DE OBSERVACIÓN
            echo "[INFO] Observando tema durante ${TIEMPO_OBSERVACION} segundos..."; sleep "$TIEMPO_OBSERVACION"
        else echo "[ADVERTENCIA] Continuando con el siguiente tema..."; sleep 2; fi
        echo ""
    done
    if [ "$modo_grabacion" = "1" ] || [ "$modo_grabacion" = "2" ]; then finalizar_grabacion_desatendida "$modo_grabacion"; fi
    cerrar_awf_gtk3; restaurar_ventana_terminal
    echo ""; echo "[ÉXITO] Demostración completada. Tema final: ALDOS"; echo ""
}

# ----------------------------------------------------------------------------
# MENÚ Y EJECUCIÓN
# ----------------------------------------------------------------------------
mostrar_menu_grabacion() {
    clear; echo "========================================"; echo "  DEMOSTRACIÓN SIMPLIFICADA - TEMAS GTK+"; echo "========================================"; echo ""
    echo "Este guion mostrará ${#TEMAS_GTK[@]} temas usando awf-gtk3."
    echo "La ventana se moverá a la derecha (Alt+F7). OSD se muestra tras aplicar tema."; echo ""
    echo "Selecciona el modo:"; echo ""
    echo "  1. Grabar con FFmpeg (MODO DESATENDIDO)"; echo "  2. Grabar con SimpleScreenRecorder"; echo "  3. No grabar (solo demostración)"; echo "  4. Salir"; echo ""
    echo -n "Tu elección [1-4]: "
}
main() {
    if [ $# -eq 1 ] && [ "$1" = "--test-osd" ]; then validar_dependencias; validar_dependencias_osd; obtener_resolucion; mostrar_osd_tema "Prueba OSD"; exit 0; fi
    validar_dependencias; validar_dependencias_osd; obtener_resolucion
    while true; do
        mostrar_menu_grabacion; read -r opcion
        case "$opcion" in 1) echo "[INFO] Modo FFmpeg."; ejecutar_demostracion "1"; break;; 2) echo "[INFO] Modo SimpleScreenRecorder."; ejecutar_demostracion "2"; break;; 3) echo "[INFO] Modo sin grabación."; ejecutar_demostracion "3"; break;; 4) echo "[INFO] Saliendo."; exit 0;; *) echo "[ERROR] Opción inválida."; sleep 1;; esac
    done
    exit 0
}
main "$@"
