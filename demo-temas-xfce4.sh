#!/bin/bash

# demo-temas-xfce4.sh - Demostración grabada de temas GTK+ en Xfce 4.20
# Requiere: ALDOS, simplescreenrecorder (atajo Ctrl+Shift+R) y tema-xfce4.sh

set -euo pipefail

# Colores para mensajes
readonly COLOR_RESET='\033[0m'
readonly COLOR_ROJO='\033[1;31m'
readonly COLOR_VERDE='\033[1;32m'
readonly COLOR_AMARILLO='\033[1;33m'
readonly COLOR_AZUL='\033[1;34m'

# Variables globales
FFMPEG_PID=""
COMPOSICION_ORIGINAL=""  # Para restaurar estado de composición

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

# Función para mensajes de error
error() {
    echo -e "${COLOR_ROJO}[ERROR]${COLOR_RESET} $*" >&2
}

# Función para mensajes informativos (a stderr para no interferir con capturas)
info() {
    echo -e "${COLOR_AZUL}[INFO]${COLOR_RESET} $*" >&2
}

# Función para mensajes de éxito (a stderr para no interferir con capturas)
exito() {
    echo -e "${COLOR_VERDE}[ÉXITO]${COLOR_RESET} $*" >&2
}

# Función para espera aleatoria entre min y max segundos (con decimales)
espera_aleatoria() {
    local min="${1:-0.5}"
    local max="${2:-1.5}"
    local delay
    
    # Generar número decimal aleatorio entre min y max
    delay=$(awk -v min="$min" -v max="$max" 'BEGIN{srand(); printf "%.2f", min+rand()*(max-min)}')
    sleep "$delay"
}

# Función para obtener resolución de pantalla ajustada a dimensiones pares
obtener_resolucion() {
    local resolucion_raw resolucion_ajustada ancho alto

    # 1. Detectar resolución (xdpyinfo es primario, xrandr es respaldo)
    resolucion_raw=$(xdpyinfo 2>/dev/null | awk -F': ' '/dimensions:/{split($2, d, " "); print d[1]}')
    if [[ -z "$resolucion_raw" ]] || ! [[ "$resolucion_raw" =~ ^[0-9]+x[0-9]+$ ]]; then
        resolucion_raw=$(xrandr --current 2>/dev/null | grep '*' | head -1 | awk '{print $1}')
    fi

    # Validación básica del formato
    if [[ ! "$resolucion_raw" =~ ^([0-9]+)x([0-9]+)$ ]]; then
        error "No se pudo obtener una resolución válida del sistema: '$resolucion_raw'"
        return 1
    fi

    # 2. Ajustar a dimensiones pares (requisito de H.264 YUV420)
    ancho="${BASH_REMATCH[1]}"
    alto="${BASH_REMATCH[2]}"
    ancho_ajustado=$(( ancho - (ancho % 2) ))
    alto_ajustado=$(( alto - (alto % 2) ))
    resolucion_ajustada="${ancho_ajustado}x${alto_ajustado}"

    # 3. Informar si hubo cambio (a stderr, para no contaminar la salida)
    if [[ "$resolucion_raw" != "$resolucion_ajustada" ]]; then
        info "Resolución ajustada a dimensiones pares para H.264: $resolucion_raw -> $resolucion_ajustada"
    else
        info "Resolución detectada (ya es par): $resolucion_ajustada"
    fi

    # 4. Devolver SOLO la resolución por stdout (sin mensajes, sin colores)
    echo "$resolucion_ajustada"
}

# Función para identificar la ventana desde la que se ejecuta este script
obtener_ventana_control() {
    local pid_actual="$$"
    local max_nivel=5
    local nivel=0
    local ventana=""
    local nombre_proceso=""

    info "Buscando ventana de control (PID actual: $$)..."
    
    while [[ $nivel -lt $max_nivel ]] && [[ -n "$pid_actual" ]] && [[ "$pid_actual" != "1" ]]; do
        # Buscar ventanas asociadas a este PID
        ventana=$(xdotool search --pid "$pid_actual" 2>/dev/null | head -1)
        if [[ -n "$ventana" ]]; then
            nombre_proceso=$(ps -o comm= -p "$pid_actual" 2>/dev/null | head -1)
            info "  Encontrada ventana para PID $pid_actual ($nombre_proceso): $ventana"
            echo "$ventana"
            return 0
        fi
        # Subir un nivel en la jerarquía de procesos
        pid_actual=$(ps -o ppid= -p "$pid_actual" 2>/dev/null | tr -d ' ')
        nivel=$((nivel + 1))
    done
    
    info "  No se pudo identificar ventana de control. Se cerrarán todas las ventanas coincidentes."
    echo ""
}

# Función para precargar GTK3 y reducir latencia al lanzar aplicaciones
precargar_gtk3() {
    if command -v gtk3-demo >/dev/null 2>&1; then
        LD_BIND_NOW=1 gtk3-demo --version >/dev/null 2>&1 &
        local pid=$!
        sleep 0.5
        kill "$pid" 2>/dev/null || true
    fi
    LD_BIND_NOW=1 gsettings list-schemas >/dev/null 2>&1
    espera_aleatoria 0.2 0.4
}

# Función para precalentar sudo y pkcon
precalentar_sudo_pkcon() {
    info "Precalentando sudo y pkcon..."
    
    # Precargar sudo (actualizar timestamp)
    if command -v sudo >/dev/null 2>&1; then
        sudo -v
        if [[ $? -eq 0 ]]; then
            info "sudo precargado correctamente."
        fi
    fi
    
    # Precargar pkcon (ejecutar una operación inocua)
    if command -v pkcon >/dev/null 2>&1; then
        pkcon get-updates 2>/dev/null || true
        info "pkcon precargado."
    fi
    
    # También precargar gsettings que usa tema-xfce4.sh
    if command -v gsettings >/dev/null 2>&1; then
        gsettings list-schemas >/dev/null 2>&1 || true
    fi
    
    exito "Precalentamiento completado."
    espera_aleatoria 0.5 1.0
}

# Función para gestionar composición de xfwm4
gestionar_composicion() {
    # Obtener estado actual
    if command -v xfconf-query >/dev/null 2>&1; then
        COMPOSICION_ORIGINAL=$(xfconf-query -c xfwm4 -p /general/use_compositing 2>/dev/null || echo "true")
        if [[ "$COMPOSICION_ORIGINAL" == "true" ]]; then
            info "Composición de xfwm4 actualmente ACTIVADA."
            
            echo ""
            echo "Con composición activa, algunos temas complejos (ej. Vince Luice) pueden causar"
            echo "que ventanas con decoraciones de cliente (Firefox, etc.) cambien de tamaño."
            echo ""
            echo -n "¿Deshabilitar temporalmente la composición para esta demostración? [s/N]: "
            read -r respuesta
            
            if [[ "${respuesta,,}" == "s"* ]]; then
                info "Deshabilitando composición de xfwm4..."
                xfconf-query -c xfwm4 -p /general/use_compositing -s false
                exito "Composición deshabilitada. Se restaurará al finalizar."
                # Capturar señal para restaurar al salir
                trap 'restaurar_composicion' EXIT INT TERM
            else
                info "Composición se mantendrá activa. Puede haber problemas con grabación o redimensionamiento."
            fi
        else
            info "Composición de xfwm4 ya está DESACTIVADA."
        fi
    else
        info "xfconf-query no disponible. No se puede gestionar composición."
    fi
    echo ""
}

# Función para restaurar composición original
restaurar_composicion() {
    if [[ -n "$COMPOSICION_ORIGINAL" ]] && command -v xfconf-query >/dev/null 2>&1; then
        info "Restaurando composición de xfwm4 a estado original ($COMPOSICION_ORIGINAL)..."
        xfconf-query -c xfwm4 -p /general/use_compositing -s "$COMPOSICION_ORIGINAL" 2>/dev/null || true
    fi
}

# Función para cerrar TODAS las ventanas de aplicaciones de demostración (VERSIÓN MEJORADA)
cerrar_aplicaciones() {
    local tema="$1"
    info "Cerrando aplicaciones del tema $tema..."
    
    # Identificar ventana de control (desde donde se ejecuta este script)
    local ventana_control
    ventana_control=$(obtener_ventana_control)
    
    # Pausa crucial para que las ventanas estén listas
    espera_aleatoria 0.8 1.2
    
    # 1. Cerrar terminales de demostración (excluyendo la ventana de control si se identificó)
    local ventanas_terminal
    ventanas_terminal=$(xdotool search --onlyvisible --class "Xfce4-terminal" --name "Terminal - Tema $tema" 2>/dev/null || true)
    if [[ -n "$ventanas_terminal" ]]; then
        while IFS= read -r ventana_id; do
            if [[ -n "$ventana_control" ]] && [[ "$ventana_id" == "$ventana_control" ]]; then
                info "  Saltando ventana de control del guión (ID: $ventana_id)."
                continue
            fi
            xdotool windowactivate --sync "$ventana_id"
            espera_aleatoria 0.1 0.3
            xdotool windowclose "$ventana_id"
            info "  Ventana 'Terminal - Tema $tema' cerrada (ID: $ventana_id)."
            espera_aleatoria 0.1 0.2
        done <<< "$ventanas_terminal"
    fi
    
    # 2. Cerrar todas las ventanas de Thunar
    local ventanas_thunar
    ventanas_thunar=$(xdotool search --onlyvisible --class "Thunar" 2>/dev/null || true)
    if [[ -n "$ventanas_thunar" ]]; then
        while IFS= read -r ventana_id; do
            xdotool windowactivate --sync "$ventana_id"
            espera_aleatoria 0.1 0.3
            xdotool windowclose "$ventana_id"
            info "  Ventana 'Thunar' cerrada (ID: $ventana_id)."
            espera_aleatoria 0.1 0.2
        done <<< "$ventanas_thunar"
    fi
    
    # 3. Cerrar todas las ventanas de Mousepad
    local ventanas_mousepad
    ventanas_mousepad=$(xdotool search --onlyvisible --class "Mousepad" 2>/dev/null || true)
    if [[ -n "$ventanas_mousepad" ]]; then
        while IFS= read -r ventana_id; do
            xdotool windowactivate --sync "$ventana_id"
            espera_aleatoria 0.1 0.3
            xdotool windowclose "$ventana_id"
            info "  Ventana 'Mousepad' cerrada (ID: $ventana_id)."
            espera_aleatoria 0.1 0.2
        done <<< "$ventanas_mousepad"
    fi
    
    # Pausa final para asegurar el cierre completo
    espera_aleatoria 0.5 0.8
}

# Función para enfocar una ventana (para futura modularización)
enfocar_ventana() {
    local criterio="$1"
    local tipo="${2:-"title"}"
    local timeout="${3:-10}"
    local start_time=$(date +%s)
    local ventana_id=""
    
    while [[ -z "$ventana_id" ]] && (( $(date +%s) - start_time < timeout )); do
        case $tipo in
            "title") ventana_id=$(xdotool search --onlyvisible --name "$criterio" 2>/dev/null | head -1) ;;
            "class") ventana_id=$(xdotool search --onlyvisible --class "$criterio" 2>/dev/null | head -1) ;;
            "classname") ventana_id=$(xdotool search --onlyvisible --classname "$criterio" 2>/dev/null | head -1) ;;
        esac
        
        if [[ -n "$ventana_id" ]]; then
            xdotool windowactivate --sync "$ventana_id" 2>/dev/null
            xdotool windowfocus --sync "$ventana_id" 2>/dev/null
            
            local active_win=$(xdotool getactivewindow 2>/dev/null)
            if [[ "$active_win" == "$ventana_id" ]]; then
                return 0
            fi
        fi
        sleep 0.3
    done
    return 1
}

# ============================================================================
# FUNCIONES DE GRABACIÓN
# ============================================================================

# Función para grabar con ffmpeg (alternativa opcional)
iniciar_grabacion_ffmpeg() {
    # Usar el directorio estándar de vídeos del usuario
    local dir_videos
    dir_videos="$(xdg-user-dir VIDEOS 2>/dev/null || echo "$HOME/Videos")"
    mkdir -p "$dir_videos"
    
    local archivo="$dir_videos/demo-temas-$(date +%Y%m%d-%H%M%S).mp4"
    info "Grabando con ffmpeg en: $archivo"
    
    # Obtener resolución ajustada a pares
    local resolucion
    resolucion=$(obtener_resolucion) || return 1
    
    # Validación explícita del formato antes de usar
    if [[ ! "$resolucion" =~ ^[0-9]+x[0-9]+$ ]]; then
        error "Resolución obtenida tiene formato inválido: '$resolucion'"
        return 1
    fi
    
    info "Resolución final para grabación: $resolucion"
    
    # Iniciar grabación en segundo plano. 
    # Asegurar que LD_BIND_NOW no esté establecido para este proceso.
    # Redirigir stderr a un archivo de log para diagnóstico.
    LD_BIND_NOW= ffmpeg \
        -video_size "$resolucion" \
        -framerate 30 \
        -f x11grab \
        -i :0.0+0,0 \
        -c:v libx264 \
        -preset ultrafast \
        -crf 28 \
        -pix_fmt yuv420p \
        "$archivo" 2>/tmp/ffmpeg_error.log &
    
    FFMPEG_PID=$!
    sleep 2 # Dar tiempo a que ffmpeg se inicie
    
    # Verificar si el proceso se está ejecutando
    if kill -0 "$FFMPEG_PID" 2>/dev/null; then
        exito "Grabación con ffmpeg iniciada (PID: $FFMPEG_PID)"
        echo "$archivo" > /tmp/ffmpeg_output.txt
        # Mostrar primeras líneas de log en caso de advertencias
        if [[ -s /tmp/ffmpeg_error.log ]]; then
            info "Log de ffmpeg (primeras líneas):"
            head -5 /tmp/ffmpeg_error.log >&2
        fi
    else
        error "Fallo al iniciar ffmpeg. Consultar /tmp/ffmpeg_error.log:"
        [[ -f /tmp/ffmpeg_error.log ]] && cat /tmp/ffmpeg_error.log >&2
        return 1
    fi
}

detener_grabacion_ffmpeg() {
    if [[ -n "$FFMPEG_PID" ]] && kill -0 "$FFMPEG_PID" 2>/dev/null; then
        info "Deteniendo grabación ffmpeg (PID: $FFMPEG_PID)..."
        kill -INT "$FFMPEG_PID"
        wait "$FFMPEG_PID" 2>/dev/null || true
        exito "Grabación ffmpeg detenida."
        
        local archivo
        archivo=$(cat /tmp/ffmpeg_output.txt 2>/dev/null || echo "desconocido")
        info "Video guardado en: $archivo"
    fi
}

# Iniciar la grabación de pantalla con SimpleScreenRecorder
iniciar_grabacion_ssr() {
    info "Iniciando la grabación en 5 segundos... Prepárate."
    for i in {5..1}; do
        echo -n "$i... "
        sleep 1
    done
    echo "¡Grabando!"
    
    info "Activando atajo de teclado para iniciar grabación (Ctrl+Shift+R)."
    xdotool key ctrl+shift+r
    if [[ $? -eq 0 ]]; then
        exito "Grabación iniciada (asumiendo que el atajo está configurado)."
        espera_aleatoria 0.5 1.0
    else
        error "No se pudo simular el atajo."
        exit 1
    fi
}

# Detener la grabación de pantalla con SimpleScreenRecorder
detener_grabacion_ssr() {
    info "Deteniendo la grabación (Ctrl+Shift+R)..."
    xdotool key ctrl+shift+r
    exito "Grabación detenida."
    espera_aleatoria 0.5 1.0
}

# ============================================================================
# FUNCIÓN PRINCIPAL DE DEMOSTRACIÓN
# ============================================================================

# Cambiar tema y mostrar aplicaciones
demo_tema() {
    local tema="$1"
    info "Cambiando al tema: $tema"
    
    # Primero cerrar cualquier ventana residual del tema anterior
    if [[ -n "${tema_anterior:-}" ]]; then
        cerrar_aplicaciones "$tema_anterior"
    fi
    
    # Aplicar el nuevo tema
    if ! tema-xfce4.sh "$tema"; then
        error "No se pudo cambiar al tema $tema"
        return 1
    fi
    
    exito "Tema $tema aplicado."
    espera_aleatoria 1.0 2.0
    
    # Precargar GTK3 para reducir latencia
    precargar_gtk3
    
    # Abrir aplicaciones para mostrar el tema
    info "Abriendo aplicaciones de demostración..."
    
    # Abrir terminal con título específico
    xfce4-terminal --geometry 80x24+100+100 --title "Terminal - Tema $tema" &
    local pid_terminal=$!
    espera_aleatoria 0.5 1.0
    
    # Abrir Thunar
    thunar ~/ &
    local pid_thunar=$!
    espera_aleatoria 0.5 1.0
    
    # Abrir Mousepad
    mousepad --disable-server &
    local pid_mousepad=$!
    espera_aleatoria 0.5 1.0
    
    # Simular apertura del menú de aplicaciones (tecla Super/Win)
    info "Mostrando menú de aplicaciones..."
    xdotool key Super
    espera_aleatoria 0.8 1.2
    
    # Esperar un poco para que las aplicaciones se muestren
    info "Mostrando aplicaciones..."
    espera_aleatoria 3.0 4.0
    
    # Guardar tema actual para el próximo ciclo
    tema_anterior="$tema"
}

# ============================================================================
# VALIDACIONES Y FLUJO PRINCIPAL
# ============================================================================

# Validaciones
validar_dependencias() {
    local faltan=()

    # Verificar que estamos en ALDOS
    if [[ ! -f /etc/aldos-release ]] && [[ ! -f /etc/fedora-release ]]; then
        error "Este guión está diseñado para ejecutarse en ALDOS (basado en Fedora)."
        faltan+=("sistema_aldos")
    fi

    # Verificar la existencia de simplescreenrecorder
    if ! command -v simplescreenrecorder >/dev/null 2>&1; then
        error "simplescreenrecorder no está instalado."
        faltan+=("simplescreenrecorder")
    else
        info "simplescreenrecorder encontrado."
    fi

    # Verificar que el atajo de teclado está configurado
    info "Asegúrate de que simplescreenrecorder tenga el atajo Ctrl+Shift+R para iniciar/detener grabación."

    # Verificar la existencia de tema-xfce4.sh
    if ! command -v tema-xfce4.sh >/dev/null 2>&1; then
        error "tema-xfce4.sh no está instalado en ~/.local/bin o no está en PATH."
        faltan+=("tema-xfce4.sh")
    else
        info "tema-xfce4.sh encontrado."
    fi

    # Verificar xdotool para simular atajos de teclado
    if ! command -v xdotool >/dev/null 2>&1; then
        error "xdotool no está instalado. Es necesario para simular atajos de teclado."
        faltan+=("xdotool")
    else
        info "xdotool encontrado."
    fi

    if [[ ${#faltan[@]} -gt 0 ]]; then
        error "Faltan dependencias: ${faltan[*]}"
        exit 1
    fi
    exito "Todas las dependencias están satisfechas."
}

main() {
    echo "========================================"
    echo "  DEMOSTRACIÓN DE TEMAS GTK+ EN XFCE"
    echo "========================================"
    echo ""
    
    # Variable para rastrear tema anterior
    local tema_anterior=""
    
    validar_dependencias
    
    # Precalentar sudo y pkcon
    precalentar_sudo_pkcon
    
    # Gestionar composición de xfwm4
    gestionar_composicion
    
    # Lista de temas a demostrar (en orden)
    local temas=("Adwaita" "Nordic" "NordicPolar" "Dracula" "ALDOS")
    info "Temas a demostrar: ${temas[*]}"
    espera_aleatoria 1.0 2.0
    
    # Preguntar por método de grabación
    echo ""
    echo "Selecciona el método de grabación:"
    echo "1) simplescreenrecorder (Ctrl+Shift+R) - Grabación con atajo"
    echo "2) ffmpeg - Grabación directa con codificación H.264"
    echo "3) No grabar (solo demostración) - Para pruebas o grabación externa"
    echo ""
    echo "Nota: La función de grabación nativa de VirtualBox es inestable."
    echo "      Para grabación confiable, use ffmpeg o simplescreenrecorder."
    echo ""
    echo -n "Opción [1/2/3]: "
    read -r opcion
    
    local usar_ffmpeg=false
    local no_grabar=false
    
    case "$opcion" in
        2)
            if command -v ffmpeg >/dev/null 2>&1; then
                usar_ffmpeg=true
                info "Usando ffmpeg para grabación."
            else
                error "ffmpeg no está instalado. Usando simplescreenrecorder."
                usar_ffmpeg=false
            fi
            ;;
        3)
            no_grabar=true
            info "Modo sin grabación. Solo demostración."
            echo ""
            info "Nota: Si planeas grabar esta demostración con VirtualBox, ten en cuenta"
            info "      que su función de grabación puede ser inestable entre versiones."
            ;;
        *)
            info "Usando simplescreenrecorder."
            ;;
    esac
    
    # Iniciar grabación (si no es modo "no grabar")
    if ! $no_grabar; then
        if $usar_ffmpeg; then
            iniciar_grabacion_ffmpeg || exit 1
        else
            iniciar_grabacion_ssr
        fi
    else
        info "Iniciando demostración sin grabación en 3 segundos..."
        sleep 3
    fi
    
    # Bucle por cada tema
    for tema in "${temas[@]}"; do
        echo ""
        info "=== DEMOSTRANDO TEMA: $tema ==="
        demo_tema "$tema"
    done
    
    # Cerrar aplicaciones del último tema
    if [[ -n "${tema_anterior:-}" ]]; then
        cerrar_aplicaciones "$tema_anterior"
    fi
    
    # Detener grabación (si no es modo "no grabar")
    if ! $no_grabar; then
        if $usar_ffmpeg; then
            detener_grabacion_ffmpeg
        else
            detener_grabacion_ssr
        fi
    fi
    
    # Restaurar composición si se cambió
    restaurar_composicion
    
    echo ""
    exito "Demostración completada."
    
    if ! $no_grabar; then
        if $usar_ffmpeg; then
            info "El video se guardó en el directorio estándar de vídeos del usuario."
        else
            info "El video se guardó en la ubicación configurada en simplescreenrecorder."
        fi
    fi
    
    info "Tema restaurado a ALDOS (predeterminado)."
}

# ============================================================================
# EJECUCIÓN PRINCIPAL
# ============================================================================

# Ejecutar main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
