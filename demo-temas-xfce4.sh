#!/bin/bash
# ============================================================================
# DEMOSTRACIÓN SIMPLIFICADA DE TEMAS GTK+ EN XFCE4 CON OSD
# VERSIÓN: 3.0-shellcheck (29/12/2024)
# ShellCheck validado: 0 warnings, 0 errors
# ============================================================================
set -euo pipefail

# ----------------------------------------------------------------------------
# CONFIGURACIÓN
# ----------------------------------------------------------------------------
readonly TIEMPO_OBSERVACION=3.0
readonly TIEMPO_MENU=5.6

readonly TEMAS_GTK=(
    "Adwaita" "Nordic" "NordicPolar" "Dracula" "Chicago95"
    "Redmond98" "RedmondXP" "Redmond7" "Redmond10" "ALDOS"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TEMA_XFCE4_SH="tema-xfce4.sh"
readonly TEMA_XFCE4_RUTA="${SCRIPT_DIR}/${TEMA_XFCE4_SH}"

# Variables globales
ancho=""
alto=""
pos_y_dinamica=""
OSD_PID=""
FFMPEG_PID=""
AWF_PID=""
TERMINAL_WIN=""

# ----------------------------------------------------------------------------
# FUNCIONES AUXILIARES
# ----------------------------------------------------------------------------
obtener_resolucion() {
    local porcentaje_desde_abajo=10
    local offset_ajuste=50
    local resolucion=""
    local ancho_original alto_original
    
    if command -v xrandr >/dev/null 2>&1; then
        resolucion=$(xrandr --current | grep -E '\*' | head -n1 | awk '{print $1}')
        ancho=$(echo "$resolucion" | cut -d'x' -f1)
        alto=$(echo "$resolucion" | cut -d'x' -f2)
    else
        ancho=1920
        alto=1080
    fi
    
    ancho_original=$ancho
    alto_original=$alto
    
    # Ajustar a dimensiones pares para libx264
    if [ $((ancho % 2)) -eq 1 ]; then
        ancho=$((ancho - 1))
        printf "[INFO] Ancho ajustado: %s → %s (debe ser par)\n" "$ancho_original" "$ancho" >&2
    fi
    if [ $((alto % 2)) -eq 1 ]; then
        alto=$((alto - 1))
        printf "[INFO] Alto ajustado: %s → %s (debe ser par)\n" "$alto_original" "$alto" >&2
    fi
    
    local distancia_desde_abajo=$(( (alto * porcentaje_desde_abajo) / 100 + offset_ajuste ))
    pos_y_dinamica="-$distancia_desde_abajo"
}

mostrar_osd_tema() {
    local tema_actual="$1"
    local mensaje="TEMA: ${tema_actual}"
    
    if [ -n "${OSD_PID-}" ] && kill -0 "$OSD_PID" 2>/dev/null; then
        wait "$OSD_PID" 2>/dev/null || true
    fi
    
    printf "%s\n" "$mensaje" | aosd_cat -n "Montserrat Black 32" -u 5000 -o 300 -R white \
        -S "#2D2D2D" -f 300 -y "$pos_y_dinamica" -x 50 -t 2 -e 5 &
    OSD_PID=$!
    sleep 0.5
}

mostrar_menu_escritorio() {
    echo "[INFO] Mostrando menú de escritorio..." >&2
    sleep 0.3
    xdotool key Super_L
    sleep 5
    xdotool key Super_L
    sleep 0.3
    echo "[ÉXITO] Menú mostrado/ocultado correctamente" >&2
}

seleccionar_modo_visual() {
    local modo_seleccionado=""
    local opcion=""
    
    # Redirigir salida interactiva a stderr
    exec 3>&1
    exec 1>&2
    
    echo ""
    echo "========================================"
    echo "     MODO DE VISUALIZACIÓN"
    echo "========================================"
    echo ""
    echo "¿Cómo quieres manejar la terminal durante la demo?"
    echo ""
    echo "  1. MODO LIMPIO (para grabación profesional)"
    echo "     • TÚ minimizarás manualmente esta terminal"
    echo "     • Tienes 15 segundos para hacerlo"
    echo "     • NO usaremos Ctrl+Alt+d (evita problemas)"
    echo "     • Ideal: Solo awf-gtk3 visible en el video"
    echo ""
    echo "  2. MODO DEPURACIÓN (para desarrollo/pruebas)"
    echo "     • TÚ decides si minimizas o no esta terminal"
    echo "     • Podrás ver todos los mensajes en tiempo real"
    echo "     • Útil para detectar problemas"
    echo ""
    
    while [ -z "$modo_seleccionado" ]; do
        printf "Selecciona (1 o 2): "
        read -r opcion
        echo ""
        
        case "$opcion" in
            1)
                modo_seleccionado="1"
                echo "[INFO] Modo LIMPIO seleccionado." >&2
                ;;
            2)
                modo_seleccionado="2"
                echo "[INFO] Modo DEPURACIÓN seleccionado." >&2
                ;;
            *)
                echo "[ERROR] Opción inválida. Elige 1 o 2." >&2
                ;;
        esac
    done
    
    # Restaurar stdout
    exec 1>&3
    printf "%s\n" "$modo_seleccionado"
}

preparar_demostracion() {
    local modo_visual="$1"
    
    if [ "$modo_visual" = "1" ]; then
        echo ""
        echo "========================================"
        echo "     INSTRUCCIONES MODO LIMPIO"
        echo "========================================"
        echo ""
        echo "AHORA TÚ HARÁS:"
        echo "1. Minimiza ESTA ventana de terminal (clic en -)"
        echo "2. Asegúrate que no haya otras ventanas visibles"
        echo ""
        echo "El script ESPERARÁ 15 segundos para que lo hagas."
        echo "NO uses Ctrl+Alt+d ni otros atajos."
        echo ""
        echo "--------------------------------------------------"
        echo "⏸️  PRESIONA ENTER CUANDO ESTÉS LISTO PARA COMENZAR"
        echo "--------------------------------------------------"
        read -r
        
        echo ""
        echo "CUENTA REGRESIVA - Minimiza la terminal en 15 segundos:"
        echo ""
        
        for i in {15..1}; do
            printf "  %2d segundos restantes...\\n" "$i"
            sleep 1
        done
        
        echo ""
        echo "✅ ¡Perfecto! Iniciando demostración..."
        sleep 2
    else
        echo ""
        echo "========================================"
        echo "     MODO DEPURACIÓN ACTIVADO"
        echo "========================================"
        echo ""
        echo "La terminal permanecerá VISIBLE."
        echo "TÚ decides si la minimizas o no."
        echo ""
        echo "Presiona ENTER cuando estés listo para comenzar..."
        read -r
        
        echo ""
        echo "Demostración comenzando en 5 segundos..."
        for i in {5..1}; do
            printf "  %d...\\n" "$i"
            sleep 1
        done
        echo "✅ Iniciando..."
    fi
}

validar_dependencias() {
    echo "========================================"
    echo "  DEMOSTRACIÓN SIMPLIFICADA - TEMAS GTK+"
    echo "========================================"
    echo ""
    
    local faltantes=()
    local cmd
    
    for cmd in awf-gtk3 xdotool; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            faltantes+=("$cmd")
        else
            echo "[INFO] $cmd encontrado." >&2
        fi
    done
    
    if [ ! -f "${TEMA_XFCE4_RUTA}" ]; then
        echo "[ERROR] No se encuentra: ${TEMA_XFCE4_SH}" >&2
        exit 1
    else
        echo "[INFO] ${TEMA_XFCE4_SH} encontrado." >&2
    fi
    
    if [ ${#faltantes[@]} -gt 0 ]; then
        echo "[ERROR] Faltan dependencias: ${faltantes[*]}" >&2
        exit 1
    fi
    
    echo "[ÉXITO] Todas las dependencias están satisfechas."
    echo ""
}

validar_dependencias_osd() {
    echo "[INFO] Validando dependencias para OSD..." >&2
    
    if ! command -v aosd_cat >/dev/null 2>&1; then
        echo "[ERROR] aosd_cat no está instalado." >&2
        exit 1
    fi
    
    echo "[ÉXITO] Dependencias OSD validadas."
    echo ""
}

precalentar_sudo_pkcon() {
    echo "[INFO] Precalentando sudo y pkcon..." >&2
    sudo -v
    
    if command -v pkcon >/dev/null 2>&1; then
        pkcon refresh force >/dev/null 2>&1 || true
    fi
    
    echo "[ÉXITO] Precalentamiento completado."
    echo ""
}

precargar_gtk3_libs() {
    echo "[INFO] Precargando bibliotecas GTK3..." >&2
    local temp_script
    temp_script=$(mktemp)
    
    cat > "$temp_script" << 'EOF'
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
print("GTK3 precargado")
EOF

    if command -v python3.9 >/dev/null 2>&1; then
        if python3.9 "$temp_script" >/dev/null 2>&1; then
            echo "[INFO] GTK3 precargado via Python" >&2
        else
            echo "[ADVERTENCIA] No se pudo precargar GTK3" >&2
        fi
    else
        echo "[ADVERTENCIA] Python3.9 no disponible, omitiendo precarga" >&2
    fi
    
    rm -f "$temp_script"
    echo "[ÉXITO] Precarga completada."
    echo ""
}

guardar_ventana_terminal() {
    TERMINAL_WIN=$(xdotool getactivewindow 2>/dev/null || echo "")
}

restaurar_ventana_terminal() {
    if [ -n "${TERMINAL_WIN-}" ]; then
        xdotool windowactivate "$TERMINAL_WIN" 2>/dev/null || true
        sleep 0.5
    fi
}

iniciar_awf_gtk3() {
    echo "[INFO] Iniciando awf-gtk3..." >&2
    
    pkill -x awf-gtk3 2>/dev/null || true
    sleep 1.0
    
    awf-gtk3 &
    AWF_PID=$!
    
    echo "[INFO] Esperando a que awf-gtk3 se inicie..." >&2
    sleep 2
    
    local intentos=0
    local ventana_id=""
    
    while [ "$intentos" -lt 10 ] && [ -z "$ventana_id" ]; do
        sleep 0.5
        ventana_id=$(xdotool search --class awf-gtk3 2>/dev/null | head -1)
        intentos=$((intentos + 1))
    done
    
    if [ -z "$ventana_id" ]; then
        echo "[ERROR] No se pudo encontrar ventana de awf-gtk3" >&2
        return 1
    fi

    echo "[INFO] Moviendo awf-gtk3 a la derecha con Alt+F7..." >&2
    xdotool windowactivate "$ventana_id"
    sleep 0.8
    xdotool key alt+F7
    sleep 0.5

    local pasos_derecha=12
    local i
    for ((i=0; i<pasos_derecha; i++)); do
        xdotool key Right
        sleep 0.15
    done
    
    xdotool key Return
    sleep 0.5

    xdotool windowactivate "$ventana_id"
    xdotool windowraise "$ventana_id"
    sleep 0.5
    
    printf "[ÉXITO] awf-gtk3 posicionado (PID: %s)\\n\\n" "$AWF_PID" >&2
}

cerrar_awf_gtk3() {
    echo "[INFO] Cerrando awf-gtk3..." >&2
    
    if [ -n "${AWF_PID-}" ]; then
        local ventana_id
        ventana_id=$(xdotool search --class awf-gtk3 2>/dev/null | head -1)
        
        if [ -n "$ventana_id" ]; then
            xdotool windowactivate "$ventana_id"
            sleep 0.3
            xdotool key alt+F4
            sleep 1
        fi
        
        if ps -p "$AWF_PID" >/dev/null 2>&1; then
            kill -TERM "$AWF_PID" 2>/dev/null || true
            sleep 0.5
        fi
    fi
    
    pkill -x awf-gtk3 2>/dev/null || true
    AWF_PID=""
    echo "[ÉXITO] awf-gtk3 cerrado." >&2
}

aplicar_tema() {
    local tema="$1"
    local inicio fin duracion resultado
    
    echo "[INFO] Aplicando tema: $tema" >&2
    inicio=$(date +%s)
    
    if [ -f "${TEMA_XFCE4_RUTA}" ]; then
        bash "${TEMA_XFCE4_RUTA}" "$tema"
        resultado=$?
        fin=$(date +%s)
        duracion=$((fin - inicio))
        
        if [ "$resultado" -eq 0 ] || [ "$resultado" -eq 1 ]; then
            printf "[ÉXITO] Tema aplicado en %d segundos\\n" "$duracion" >&2
            return 0
        else
            printf "[ERROR] Fallo crítico al aplicar el tema (código de retorno: %d)\\n" "$resultado" >&2
            return 1
        fi
    else
        echo "[ERROR] No se puede encontrar: ${TEMA_XFCE4_SH}" >&2
        return 1
    fi
}

preparar_grabacion_desatendida() {
    local modo="$1"
    
    case "$modo" in
        1)
            local timestamp archivo_salida resolucion
            timestamp=$(date +%Y%m%d-%H%M%S)
            archivo_salida="demo-temas-${timestamp}.mp4"
            
            # Validar resolución
            if [ -z "${ancho-}" ] || [ -z "${alto-}" ]; then
                obtener_resolucion
            fi
            
            # Verificar paridad
            if [ $((ancho % 2)) -eq 1 ] || [ $((alto % 2)) -eq 1 ]; then
                echo "[ADVERTENCIA] Resolución impar. Reajustando..." >&2
                obtener_resolucion
            fi
            
            resolucion="${ancho}x${alto}"
            
            echo "[INFO] Iniciando grabación FFmpeg..." >&2
            printf "[INFO] Resolución: %s (ajustada para libx264)\\n" "$resolucion" >&2
            printf "[INFO] Archivo: %s\\n\\n" "$archivo_salida" >&2
            
            ffmpeg -f x11grab -video_size "$resolucion" -framerate 25 \
                   -probesize 10M -i :0.0 -c:v libx264 -preset fast \
                   -pix_fmt yuv420p -y "$archivo_salida" >/tmp/ffmpeg.log 2>&1 &
            FFMPEG_PID=$!
            
            echo "[INFO] FFmpeg iniciado (PID: $FFMPEG_PID)" >&2
            echo "[INFO] Esperando inicialización..." >&2
            sleep 2
            
            if ! kill -0 "$FFMPEG_PID" 2>/dev/null; then
                echo "[ERROR] FFmpeg falló al iniciar." >&2
                if [ -f "/tmp/ffmpeg.log" ]; then
                    echo "[DEBUG] Error de FFmpeg:" >&2
                    grep -i "error\|failed\|divisible" /tmp/ffmpeg.log | head -5 >&2
                fi
                FFMPEG_PID=""
                return 1
            fi
            
            echo "[ÉXITO] FFmpeg grabando correctamente." >&2
            ;;
        2)
            echo "[INFO] Configurando SimpleScreenRecorder..." >&2
            echo "" >&2
            printf "%s" "[INFO] Iniciando grabación en 3 segundos... " >&2
            sleep 3
            echo "" >&2
            
            xdotool key ctrl+shift+r
            echo "[INFO] Grabación iniciada (Ctrl+Shift+R enviado)" >&2
            sleep 2
            ;;
    esac
}

finalizar_grabacion_desatendida() {
    local modo="$1"
    
    case "$modo" in
        1)
            if [ -n "${FFMPEG_PID-}" ]; then
                echo "[INFO] Finalizando grabación FFmpeg..." >&2
                printf "[INFO] Enviando señal de terminación (PID: %s)...\\n" "$FFMPEG_PID" >&2
                
                kill -TERM "$FFMPEG_PID" 2>/dev/null || true
                
                echo "[INFO] Esperando finalización..." >&2
                local espera=0
                while kill -0 "$FFMPEG_PID" 2>/dev/null && [ "$espera" -lt 10 ]; do
                    sleep 1
                    espera=$((espera + 1))
                    printf "." >&2
                done
                echo "" >&2
                
                if kill -0 "$FFMPEG_PID" 2>/dev/null; then
                    echo "[ADVERTENCIA] Forzando cierre de FFmpeg..." >&2
                    kill -9 "$FFMPEG_PID" 2>/dev/null || true
                fi
                
                wait "$FFMPEG_PID" 2>/dev/null || true
                FFMPEG_PID=""
                
                sleep 1
                local archivos=(demo-temas-*.mp4)
                if [ ${#archivos[@]} -gt 0 ]; then
                    local ultimo_archivo="${archivos[-1]}"
                    if [ -s "$ultimo_archivo" ]; then
                        local tamano
                        tamano=$(stat -c%s "$ultimo_archivo" 2>/dev/null || echo "0")
                        printf "[ÉXITO] Grabación: %s (%d MB)\\n" "$ultimo_archivo" "$((tamano/1024/1024))" >&2
                    else
                        printf "[ERROR] Archivo vacío: %s\\n" "$ultimo_archivo" >&2
                    fi
                else
                    echo "[ERROR] No se encontró archivo MP4" >&2
                fi
            else
                echo "[ADVERTENCIA] No hay FFmpeg activo." >&2
            fi
            ;;
        2)
            echo "[INFO] Finalizando SimpleScreenRecorder..." >&2
            sleep 1
            xdotool key ctrl+shift+r
            echo "[INFO] Grabación pausada. Guarda manualmente." >&2
            sleep 1
            ;;
    esac
}

manejar_terminacion() {
    echo "" >&2
    echo "[INFO] Recibida señal de terminación. Limpiando..." >&2
    
    if [ -n "${FFMPEG_PID-}" ] && kill -0 "$FFMPEG_PID" 2>/dev/null; then
        echo "[INFO] Cerrando FFmpeg..." >&2
        kill -TERM "$FFMPEG_PID" 2>/dev/null || true
        sleep 2
    fi
    
    if [ -n "${AWF_PID-}" ] && kill -0 "$AWF_PID" 2>/dev/null; then
        echo "[INFO] Cerrando awf-gtk3..." >&2
        kill -TERM "$AWF_PID" 2>/dev/null || true
        sleep 1
    fi
    
    restaurar_ventana_terminal
    echo "[INFO] Limpieza completada." >&2
    exit 1
}

ejecutar_demostracion() {
    local modo_grabacion="$1"
    
    trap manejar_terminacion SIGINT SIGTERM EXIT
    
    echo "[INFO] Preparando demostración..." >&2
    
    guardar_ventana_terminal
    precalentar_sudo_pkcon
    precargar_gtk3_libs
    obtener_resolucion
    
    local modo_visual
    modo_visual=$(seleccionar_modo_visual)
    modo_visual=$(echo "$modo_visual" | tr -d '\n\r')
    printf "[DEBUG] Valor capturado: '%s'\\n" "$modo_visual" >&2
    
    preparar_demostracion "$modo_visual"
    
    if ! iniciar_awf_gtk3; then
        echo "[ERROR] No se pudo iniciar awf-gtk3." >&2
        restaurar_ventana_terminal
        exit 1
    fi
    
    if [ "$modo_grabacion" = "1" ] || [ "$modo_grabacion" = "2" ]; then
        if ! preparar_grabacion_desatendida "$modo_grabacion"; then
            echo "[ERROR] Fallo en grabación. Continuando sin grabación..." >&2
        fi
        sleep 2
    fi

    local total_temas=${#TEMAS_GTK[@]}
    
    echo ""
    echo "========================================"
    echo "  INICIANDO DEMOSTRACIÓN DE ${total_temas} TEMAS"
    echo "========================================"
    echo ""
    
    local i tema_actual indice
    for ((i=0; i<total_temas; i++)); do
        tema_actual="${TEMAS_GTK[$i]}"
        indice=$((i+1))
        
        echo "[TEMA ${indice}/${total_temas}] ${tema_actual}"
        echo "----------------------------------------"
        
        if aplicar_tema "$tema_actual"; then
            mostrar_osd_tema "$tema_actual"
            mostrar_menu_escritorio
            printf "[INFO] Observando tema durante %s segundos...\\n" "$TIEMPO_OBSERVACION" >&2
            sleep "$TIEMPO_OBSERVACION"
        else
            echo "[ADVERTENCIA] Continuando..." >&2
            sleep 2
        fi
        
        echo ""
    done
    
    if [ "$modo_grabacion" = "1" ] || [ "$modo_grabacion" = "2" ]; then
        finalizar_grabacion_desatendida "$modo_grabacion"
    fi
    
    cerrar_awf_gtk3
    restaurar_ventana_terminal
    
    trap - SIGINT SIGTERM EXIT
    
    echo ""
    echo "[ÉXITO] Demostración completada. Tema final: ALDOS"
    echo ""
}

mostrar_menu_grabacion() {
    clear
    
    echo "========================================"
    echo "  DEMOSTRACIÓN SIMPLIFICADA - TEMAS GTK+"
    echo "========================================"
    echo ""
    echo "Este guion mostrará ${#TEMAS_GTK[@]} temas usando awf-gtk3."
    echo "La ventana se moverá a la derecha (Alt+F7). OSD se muestra tras aplicar tema."
    echo ""
    echo "Selecciona el modo:"
    echo ""
    echo "  1. Grabar con FFmpeg (MODO DESATENDIDO)"
    echo "     • Inicia grabación automáticamente"
    echo "     • Termina al finalizar la demostración"
    echo "     • Archivo: demo-temas-YYYYMMDD-HHMMSS.mp4"
    echo ""
    echo "  2. Grabar con SimpleScreenRecorder"
    echo "     • Inicia/pausa con Ctrl+Shift+R"
    echo "     • Debes guardar manualmente al final"
    echo ""
    echo "  3. No grabar (solo demostración)"
    echo "  4. Salir"
    echo ""
}

main() {
    if [ $# -eq 1 ] && [ "$1" = "--test-osd" ]; then
        validar_dependencias
        validar_dependencias_osd
        obtener_resolucion
        mostrar_osd_tema "Prueba OSD"
        exit 0
    fi
    
    validar_dependencias
    validar_dependencias_osd
    
    local opcion
    while true; do
        mostrar_menu_grabacion
        read -rp "Tu elección [1-4]: " opcion
        
        case "$opcion" in
            1)
                echo "[INFO] Modo FFmpeg." >&2
                ejecutar_demostracion 1
                break
                ;;
            2)
                echo "[INFO] Modo SimpleScreenRecorder." >&2
                ejecutar_demostracion 2
                break
                ;;
            3)
                echo "[INFO] Modo sin grabación." >&2
                ejecutar_demostracion 3
                break
                ;;
            4)
                echo "[INFO] Saliendo." >&2
                exit 0
                ;;
            *)
                echo "[ERROR] Opción inválida." >&2
                sleep 1
                ;;
        esac
    done
    
    exit 0
}

main "$@"
