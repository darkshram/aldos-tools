#!/bin/bash

# demo-temas-xfce4.sh - Demostración grabada con OSD de temas GTK+ en Xfce 4.20
# Uso: ./demo-temas-xfce4.sh [--test-osd]

set -euo pipefail

# ============================================================================
# CONFIGURACIÓN DE OSD Y TEMPORIZACIÓN - VERSIÓN DIDÁCTICA
# ============================================================================
# NOTA PEDAGÓGICA: El ojo humano necesita ~1.6s para percibir un cambio.
# Para una demostración educativa efectiva, se requieren tiempos mayores que
# permitan la observación consciente de detalles de temas GTK+.

# TIEMPOS PRINCIPALES (segundos) - FIJOS para predictibilidad
readonly TIEMPO_OBSERVACION=4.0          # 4 segundos por aplicación
readonly TIEMPO_TRANSICION=0.5           # Transición entre apps
readonly TIEMPO_OSD_APLICACION=4.5       # OSD visible mientras se observa
readonly TIEMPO_OSD_TRANSICION=5.0       # OSD de cambio de tema
readonly TIEMPO_REDIBUJO=1.5             # Redibujo tras cambio de tema
readonly TIEMPO_APERTURA_APPS=1.0        # Tiempo fijo para abrir cada app

# Configuración de AOSD_CAT
readonly FUENTE_OSD="Montserrat Black 32"
readonly COLOR_BORDE="orange"
readonly COLOR_SOMBRA="black"
readonly POS_X="50"
readonly OSD_OPACIDAD="300"
readonly OSD_FADE="300"
readonly OSD_TEXTO_GROSOR="2"
readonly OSD_BORDE_GROSOR="5"

# ============================================================================
# VARIABLES GLOBALES
# ============================================================================
FFMPEG_PID=""
COMPOSICION_ORIGINAL=""
OSD_PID=""
MODO_TEST_OSD=false

# Colores para mensajes
readonly COLOR_RESET='\033[0m'
readonly COLOR_ROJO='\033[1;31m'
readonly COLOR_VERDE='\033[1;32m'
readonly COLOR_AMARILLO='\033[1;33m'
readonly COLOR_AZUL='\033[1;34m'

# ============================================================================
# FUNCIONES AUXILIARES GENERALES
# ============================================================================

error() {
    echo -e "${COLOR_ROJO}[ERROR]${COLOR_RESET} $*" >&2
}

info() {
    echo -e "${COLOR_AZUL}[INFO]${COLOR_RESET} $*" >&2
}

exito() {
    echo -e "${COLOR_VERDE}[ÉXITO]${COLOR_RESET} $*" >&2
}

advertencia() {
    echo -e "${COLOR_AMARILLO}[ADVERTENCIA]${COLOR_RESET} $*" >&2
}

espera_aleatoria() {
    local min="${1:-0.5}"
    local max="${2:-1.5}"
    local delay
    delay=$(awk -v min="$min" -v max="$max" 'BEGIN{srand(); printf "%.2f", min+rand()*(max-min)}')
    sleep "$delay"
}

obtener_resolucion() {
    local resolucion_raw resolucion_ajustada ancho alto

    resolucion_raw=$(xdpyinfo 2>/dev/null | awk -F': ' '/dimensions:/{split($2, d, " "); print d[1]}')
    if [[ -z "$resolucion_raw" ]] || ! [[ "$resolucion_raw" =~ ^[0-9]+x[0-9]+$ ]]; then
        resolucion_raw=$(xrandr --current 2>/dev/null | grep '*' | head -1 | awk '{print $1}')
    fi

    if [[ ! "$resolucion_raw" =~ ^([0-9]+)x([0-9]+)$ ]]; then
        error "No se pudo obtener una resolución válida del sistema: '$resolucion_raw'"
        return 1
    fi

    ancho="${BASH_REMATCH[1]}"
    alto="${BASH_REMATCH[2]}"
    ancho_ajustado=$(( ancho - (ancho % 2) ))
    alto_ajustado=$(( alto - (alto % 2) ))
    resolucion_ajustada="${ancho_ajustado}x${alto_ajustada}"

    if [[ "$resolucion_raw" != "$resolucion_ajustada" ]]; then
        info "Resolución ajustada a dimensiones pares para H.264: $resolucion_raw -> $resolucion_ajustada"
    else
        info "Resolución detectada (ya es par): $resolucion_ajustada"
    fi

    echo "$resolucion_ajustada"
}

# ============================================================================
# FUNCIONES DE OSD CORREGIDAS
# ============================================================================

calcular_posicion_y_osd() {
    local altura_pantalla
    local resolucion
    resolucion=$(xdpyinfo 2>/dev/null | awk -F': ' '/dimensions:/{split($2, d, " "); print d[1]}')
    
    if [[ -z "$resolucion" ]] || ! [[ "$resolucion" =~ ^([0-9]+)x([0-9]+)$ ]]; then
        resolucion=$(xrandr --current 2>/dev/null | grep '*' | head -1 | awk '{print $1}')
    fi
    
    if [[ "$resolucion" =~ ^([0-9]+)x([0-9]+)$ ]]; then
        altura_pantalla="${BASH_REMATCH[2]}"
        local pos_y_calculada=$((altura_pantalla / 3))
        echo "-${pos_y_calculada}"
    else
        advertencia "No se pudo obtener la altura de pantalla. Usando valor por defecto -540."
        echo "-540"
    fi
}

mostrar_osd_aplicacion() {
    local aplicacion="$1"
    local tema="$2"
    local mensaje=""
    
    # Verificar que aosd_cat esté disponible
    if ! command -v aosd_cat >/dev/null 2>&1; then
        advertencia "aosd_cat no está disponible. OSD no se mostrará."
        return 1
    fi
    
    case "$aplicacion" in
        "xfce4-about")
            mensaje="ℹ️  Acerca de Xfce\nVentana de diálogo con botones y controles GTK."
            ;;
        "thunar")
            mensaje="📁 Administrador de archivos\nIconos, paneles y colores de lista."
            ;;
        "mousepad")
            mensaje="📝 Editor de texto\nBarra de herramientas y área de edición."
            ;;
        *)
            mensaje="▶️  Demostrando tema: $tema"
            ;;
    esac
    
    local pos_y_dinamica
    pos_y_dinamica=$(calcular_posicion_y_osd)
    
    echo -e "$mensaje" | aosd_cat \
        -n "$FUENTE_OSD" \
        -u $(echo "$TIEMPO_OSD_APLICACION * 1000" | bc) \
        -o "$OSD_OPACIDAD" \
        -R "$COLOR_BORDE" \
        -S "$COLOR_SOMBRA" \
        -f "$OSD_FADE" \
        -x "$POS_X" -y "$pos_y_dinamica" \
        -t "$OSD_TEXTO_GROSOR" -e "$OSD_BORDE_GROSOR" &
    
    OSD_PID=$!
    sleep 0.1
    if ! kill -0 "$OSD_PID" 2>/dev/null; then
        advertencia "El OSD de aplicación pudo no mostrarse (aosd_cat falló silenciosamente)."
        OSD_PID=""
    fi
}

mostrar_osd_transicion() {
    local tema_siguiente="$1"
    local indice="$2"
    local total="$3"
    local mensaje="🎨  Cambiando a: $tema_siguiente\n($indice/$total)"
    
    # Verificar que aosd_cat esté disponible
    if ! command -v aosd_cat >/dev/null 2>&1; then
        advertencia "aosd_cat no está disponible. OSD no se mostrará."
        return 1
    fi
    
    local pos_y_dinamica
    pos_y_dinamica=$(calcular_posicion_y_osd)
    
    echo -e "$mensaje" | aosd_cat \
        -n "$FUENTE_OSD" \
        -u $(echo "$TIEMPO_OSD_TRANSICION * 1000" | bc) \
        -o "$OSD_OPACIDAD" \
        -R "$COLOR_BORDE" \
        -S "$COLOR_SOMBRA" \
        -f "$OSD_FADE" \
        -x "$POS_X" -y "$pos_y_dinamica" \
        -t "$OSD_TEXTO_GROSOR" -e "$OSD_BORDE_GROSOR" &
    
    OSD_PID=$!
    sleep 0.1
    if ! kill -0 "$OSD_PID" 2>/dev/null; then
        advertencia "El OSD de transición pudo no mostrarse (aosd_cat falló silenciosamente)."
        OSD_PID=""
    fi
}

rotar_foco_aplicaciones_fijo() {
    local tema="$1"
    
    enfocar_ventana "Acerca de Xfce" "title" 3
    mostrar_osd_aplicacion "xfce4-about" "$tema"
    sleep $TIEMPO_OBSERVACION
    
    sleep $TIEMPO_TRANSICION
    enfocar_ventana "Thunar" "class" 3
    mostrar_osd_aplicacion "thunar" "$tema"
    sleep $TIEMPO_OBSERVACION
    
    sleep $TIEMPO_TRANSICION
    enfocar_ventana "Mousepad" "class" 3
    mostrar_osd_aplicacion "mousepad" "$tema"
    sleep $TIEMPO_OBSERVACION
}

# ============================================================================
# FUNCIONES DE GESTIÓN DE VENTANAS (ACTUALIZADAS)
# ============================================================================

obtener_ventana_control() {
    local pid_actual="$$"
    local max_nivel=5
    local nivel=0
    local ventana=""
    local nombre_proceso=""

    info "Buscando ventana de control (PID actual: $$)..."
    
    while [[ $nivel -lt $max_nivel ]] && [[ -n "$pid_actual" ]] && [[ "$pid_actual" != "1" ]]; do
        ventana=$(xdotool search --pid "$pid_actual" 2>/dev/null | head -1)
        if [[ -n "$ventana" ]]; then
            nombre_proceso=$(ps -o comm= -p "$pid_actual" 2>/dev/null | head -1)
            info "  Encontrada ventana para PID $pid_actual ($nombre_proceso): $ventana"
            echo "$ventana"
            return 0
        fi
        pid_actual=$(ps -o ppid= -p "$pid_actual" 2>/dev/null | tr -d ' ')
        nivel=$((nivel + 1))
    done
    
    info "  No se pudo identificar ventana de control. Se cerrarán todas las ventanas coincidentes."
    echo ""
}

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

cerrar_aplicaciones() {
    local tema="$1"
    info "Cerrando aplicaciones del tema $tema..."
    
    local ventana_control
    ventana_control=$(obtener_ventana_control)
    
    espera_aleatoria 0.8 1.2
    
    # Cerrar xfce4-about
    local ventanas_about
    ventanas_about=$(xdotool search --onlyvisible --class "Xfce4-about" 2>/dev/null || true)
    if [[ -n "$ventanas_about" ]]; then
        while IFS= read -r ventana_id; do
            if [[ -n "$ventana_control" ]] && [[ "$ventana_id" == "$ventana_control" ]]; then
                info "  Saltando ventana de control del guión (ID: $ventana_id)."
                continue
            fi
            xdotool windowactivate --sync "$ventana_id"
            espera_aleatoria 0.1 0.3
            xdotool windowclose "$ventana_id"
            info "  Ventana 'Acerca de Xfce' cerrada (ID: $ventana_id)."
            espera_aleatoria 0.1 0.2
        done <<< "$ventanas_about"
    fi
    
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
    
    espera_aleatoria 0.5 0.8
}

# ============================================================================
# FUNCIONES DE DEMOSTRACIÓN PRINCIPAL (ACTUALIZADAS)
# ============================================================================

demo_tema() {
    local tema="$1"
    local indice="$2"
    local total="$3"
    
    info "=== DEMOSTRANDO TEMA: $tema ($indice/$total) ==="
    
    mostrar_osd_transicion "$tema" "$indice" "$total"
    sleep 0.8
    
    if ! tema-xfce4.sh "$tema"; then
        error "No se pudo cambiar al tema $tema"
        return 1
    fi
    exito "Tema $tema aplicado."
    
    sleep $TIEMPO_REDIBUJO
    
    precargar_gtk3
    
    info "Abriendo aplicaciones de demostración..."
    xfce4-about &
    sleep $TIEMPO_APERTURA_APPS
    
    thunar ~/ &
    sleep $TIEMPO_APERTURA_APPS
    
    mousepad --disable-server &
    sleep $TIEMPO_APERTURA_APPS
    
    info "Mostrando menú de aplicaciones..."
    xdotool key Super
    espera_aleatoria 0.8 1.2
    
    info "Rotando foco entre aplicaciones..."
    rotar_foco_aplicaciones_fijo "$tema"
    
    cerrar_aplicaciones "$tema"
    
    exito "Demostración del tema $tema completada."
}

# ============================================================================
# FUNCIONES DE VALIDACIÓN E INSTALACIÓN
# ============================================================================

validar_dependencias() {
    local faltan=()

    if [[ ! -f /etc/aldos-release ]] && [[ ! -f /etc/fedora-release ]]; then
        error "Este guión está diseñado para ejecutarse en ALDOS (basado en Fedora)."
        faltan+=("sistema_aldos")
    fi

    if ! command -v simplescreenrecorder >/dev/null 2>&1; then
        error "simplescreenrecorder no está instalado."
        faltan+=("simplescreenrecorder")
    else
        info "simplescreenrecorder encontrado."
    fi

    info "Asegúrate de que simplescreenrecorder tenga el atajo Ctrl+Shift+R para iniciar/detener grabación."

    if ! command -v tema-xfce4.sh >/dev/null 2>&1; then
        error "tema-xfce4.sh no está instalado en ~/.local/bin o no está en PATH."
        faltan+=("tema-xfce4.sh")
    else
        info "tema-xfce4.sh encontrado."
    fi

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

validar_dependencias_osd() {
    info "Validando dependencias para OSD..."
    
    if ! command -v aosd_cat >/dev/null 2>&1; then
        info "Instalando aosd_cat..."
        if command -v pkcon >/dev/null 2>&1; then
            pkcon -y install aosd_cat || { error "No se pudo instalar aosd_cat"; return 1; }
        elif command -v yum >/dev/null 2>&1; then
            sudo yum -y install aosd_cat || { error "No se pudo instalar aosd_cat"; return 1; }
        else
            error "No se encontró gestor de paquetes para instalar aosd_cat"
            return 1
        fi
    fi
    
    local ruta_fuente="/usr/share/fonts/julietaula-montserrat/Montserrat-Black.ttf"
    if [[ ! -f "$ruta_fuente" ]]; then
        info "Instalando fuentes Montserrat..."
        if command -v pkcon >/dev/null 2>&1; then
            pkcon -y install julietaula-montserrat-fonts || { 
                advertencia "No se pudo instalar julietaula-montserrat-fonts. El OSD usará fuente por defecto."
                return 0
            }
        elif command -v yum >/dev/null 2>&1; then
            sudo yum -y install julietaula-montserrat-fonts || {
                advertencia "No se pudo instalar julietaula-montserrat-fonts. El OSD usará fuente por defecto."
                return 0
            }
        else
            advertencia "No se encontró gestor de paquetes. El OSD usará fuente por defecto."
            return 0
        fi
    fi
    
    exito "Dependencias OSD validadas."
}

modo_test_osd() {
    info "MODO PRUEBA OSD - Mostrando todos los mensajes en secuencia"
    echo ""
    
    local pos_y_dinamica
    pos_y_dinamica=$(calcular_posicion_y_osd)
    info "Posición Y calculada dinámicamente: $pos_y_dinamica"
    
    info "1. OSD de transición (cambio de tema)..."
    mostrar_osd_transicion "Nordic" 2 5
    sleep 3
    
    info "2. OSD de aplicación (Acerca de Xfce)..."
    mostrar_osd_aplicacion "xfce4-about" "Nordic"
    sleep 2.5
    
    info "3. OSD de aplicación (Thunar)..."
    mostrar_osd_aplicacion "thunar" "Nordic"
    sleep 2.5
    
    info "4. OSD de aplicación (Mousepad)..."
    mostrar_osd_aplicacion "mousepad" "Nordic"
    sleep 2.5
    
    info "Prueba OSD completada. Si viste todos los mensajes, el sistema está funcionando."
    echo ""
    info "Si algún mensaje no apareció, verifica:"
    info "  - Que aosd_cat esté instalado (comando: which aosd_cat)"
    info "  - Que la fuente Montserrat esté instalada (archivo: /usr/share/fonts/julietaula-montserrat/Montserrat-Black.ttf)"
    echo ""
}

# ============================================================================
# FUNCIONES EXISTENTES (se mantienen igual)
# ============================================================================
# Las funciones precargar_gtk3, precalentar_sudo_pkcon, gestionar_composicion,
# restaurar_composicion, iniciar_grabacion_ffmpeg, detener_grabacion_ffmpeg,
# iniciar_grabacion_ssr, detener_grabacion_ssr se mantienen idénticas a tu
# versión anterior y se omiten aquí por brevedad. Deben incluirse en el script final.

# ============================================================================
# FLUJO PRINCIPAL
# ============================================================================

main() {
    if [[ "$#" -gt 0 ]] && [[ "$1" == "--test-osd" ]]; then
        MODO_TEST_OSD=true
    fi
    
    echo "========================================"
    echo "  DEMOSTRACIÓN CON OSD - TEMAS GTK+ EN XFCE"
    echo "========================================"
    echo ""
    
    local tema_anterior=""
    
    validar_dependencias
    
    validar_dependencias_osd
    
    if $MODO_TEST_OSD; then
        modo_test_osd
        exit 0
    fi
    
    precalentar_sudo_pkcon
    
    gestionar_composicion
    
    local temas=("Adwaita" "Nordic" "NordicPolar" "Dracula" "ALDOS")
    info "Temas a demostrar: ${temas[*]}"
    espera_aleatoria 1.0 2.0
    
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
    
    for indice in "${!temas[@]}"; do
        local tema="${temas[$indice]}"
        demo_tema "$tema" "$((indice + 1))" "${#temas[@]}"
    done
    
    restaurar_composicion
    
    echo ""
    exito "Demostración con OSD completada."
    
    if ! ${no_grabar:-false}; then
        if ${usar_ffmpeg:-false}; then
            info "El video se guardó en el directorio estándar de vídeos del usuario."
        else
            info "El video se guardó en la ubicación configurada en simplescreenrecorder."
        fi
    fi
}

# ============================================================================
# EJECUCIÓN PRINCIPAL
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
