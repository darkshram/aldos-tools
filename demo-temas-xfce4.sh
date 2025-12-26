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

# Variable global para el PID de ffmpeg
FFMPEG_PID=""

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

# Función para mensajes de error
error() {
    echo -e "${COLOR_ROJO}[ERROR]${COLOR_RESET} $*" >&2
}

# Función para mensajes informativos
info() {
    echo -e "${COLOR_AZUL}[INFO]${COLOR_RESET} $*"
}

# Función para mensajes de éxito
exito() {
    echo -e "${COLOR_VERDE}[ÉXITO]${COLOR_RESET} $*"
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

# Función para cerrar aplicaciones usando Alt+F4 (comportamiento natural)
cerrar_aplicaciones() {
    local tema="$1"
    
    info "Cerrando aplicaciones del tema $tema (Alt+F4)..."
    
    # Esperar un momento para asegurar que las ventanas estén listas
    espera_aleatoria 0.2 0.4
    
    # Cerrar xfce4-terminal específica del tema (por título)
    xdotool search --name "Terminal - Tema $tema" windowactivate --sync key --clearmodifiers alt+F4 2>/dev/null || true
    
    # Cerrar Thunar (por clase)
    xdotool search --class "Thunar" windowactivate --sync key --clearmodifiers alt+F4 2>/dev/null || true
    
    # Cerrar Mousepad (por clase)
    xdotool search --class "Mousepad" windowactivate --sync key --clearmodifiers alt+F4 2>/dev/null || true
    
    # Respaldo con pkill para casos donde Alt+F4 no funcione
    pkill -f "xfce4-terminal.*Tema $tema" 2>/dev/null || true
    pkill -f "thunar" 2>/dev/null || true
    pkill -f "mousepad" 2>/dev/null || true
    
    # Esperar a que se cierren completamente
    espera_aleatoria 0.3 0.6
}

# Función para enfocar una ventana (placeholder para futura modularización)
enfocar_ventana() {
    # TODO: Implementar lógica para enfocar ventana específica
    # Esta función servirá como punto de partida para la fase de modularización
    echo "Función enfocar_ventana() - Pendiente de implementación"
}

# ============================================================================
# FUNCIONES DE GRABACIÓN
# ============================================================================

# Función para grabar con ffmpeg (alternativa opcional)
iniciar_grabacion_ffmpeg() {
    # Usar el directorio estándar de vídeos del usuario (portable)
    local dir_videos
    dir_videos="$(xdg-user-dir VIDEOS 2>/dev/null || echo "$HOME/Videos")"
    mkdir -p "$dir_videos"
    
    local archivo="$dir_videos/demo-temas-$(date +%Y%m%d-%H%M%S).mp4"
    info "Grabando con ffmpeg en: $archivo"
    
    # Obtener resolución de la pantalla de manera robusta
    local resolucion
    resolucion=$(xdpyinfo | awk -F': ' '/dimensions:/{split($2, d, " "); print d[1]}')
    
    # Validar el formato (debe ser 'ANCHOxALTO')
    if [[ -z "$resolucion" ]] || ! [[ "$resolucion" =~ ^[0-9]+x[0-9]+$ ]]; then
        error "No se pudo detectar una resolución de pantalla válida. Se obtuvo: '$resolucion'"
        return 1
    fi
    info "Resolución detectada: $resolucion"
    
    # Iniciar grabación en segundo plano
    ffmpeg -video_size "$resolucion" -framerate 30 -f x11grab -i :0.0+0,0 \
           -c:v libx264 -preset ultrafast -crf 28 -pix_fmt yuv420p \
           "$archivo" 2>/dev/null &
    
    FFMPEG_PID=$!
    sleep 2
    
    if kill -0 "$FFMPEG_PID" 2>/dev/null; then
        exito "Grabación con ffmpeg iniciada (PID: $FFMPEG_PID)"
        echo "$archivo" > /tmp/ffmpeg_output.txt
    else
        error "Fallo al iniciar ffmpeg"
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
    
    # Lista de temas a demostrar (en orden)
    local temas=("Adwaita" "Nordic" "NordicPolar" "Dracula" "ALDOS")
    info "Temas a demostrar: ${temas[*]}"
    espera_aleatoria 1.0 2.0
    
    # Preguntar por método de grabación
    echo ""
    echo "Selecciona el método de grabación:"
    echo "1) simplescreenrecorder (Ctrl+Shift+R)"
    echo "2) ffmpeg (requiere instalación)"
    echo -n "Opción [1/2]: "
    read -r opcion
    
    local usar_ffmpeg=false
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
        *)
            info "Usando simplescreenrecorder."
            ;;
    esac
    
    # Iniciar grabación
    if $usar_ffmpeg; then
        iniciar_grabacion_ffmpeg
    else
        iniciar_grabacion_ssr
    fi
    
    # Bucle por cada tema
    for tema in "${temas[@]}"; do
        echo ""
        info "=== DEMOSTRANDO TEMA: $tema ==="
        demo_tema "$tema"
    done
    
    # Cerrar aplicaciones del último tema
    if [[ -n "$tema_anterior" ]]; then
        cerrar_aplicaciones "$tema_anterior"
    fi
    
    # Detener grabación
    if $usar_ffmpeg; then
        detener_grabacion_ffmpeg
    else
        detener_grabacion_ssr
    fi
    
    echo ""
    exito "Demostración completada."
    
    if $usar_ffmpeg; then
        info "El video se guardó en el directorio estándar de vídeos del usuario."
    else
        info "El video se guardó en la ubicación configurada en simplescreenrecorder."
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
