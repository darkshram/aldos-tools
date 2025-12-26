#!/bin/bash

# demo-temas-xfce4.sh - Demostración grabada con OSD de temas GTK+ en Xfce 4.20
# Uso: ./demo-temas-xfce4.sh [--test-osd]

set -euo pipefail

# ============================================================================
# CONFIGURACIÓN DE OSD Y TEMPORIZACIÓN (segundos)
# ============================================================================
# NOTA SOBRE AOSD_CAT:
# aosd_cat es delicado. Los parámetros (-y, -x, -n) se probaron empíricamente.
# Modificarlos puede hacer que el OSD no se muestre o se coloque fuera de pantalla.
# Se recomienda NO alterar los valores a menos que se realicen pruebas exhaustivas.

# Tiempos fijos para la presentación
readonly TIEMPO_OBSERVACION=1.7
readonly TIEMPO_TRANSICION=0.3
readonly TIEMPO_OSD_APLICACION=2.0
readonly TIEMPO_OSD_TRANSICION=2.5
readonly TIEMPO_REDIBUJO=1.0

# Configuración de AOSD_CAT (usar Montserrat Black, probada y funcional)
readonly FUENTE_OSD="Montserrat Black 32"
readonly COLOR_BORDE="orange"
readonly COLOR_SOMBRA="black"
readonly POS_X="50"
# POS_Y se calculará dinámicamente basándose en la resolución de pantalla
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
# FUNCIONES AUXILIARES
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

# Función para calcular posición Y dinámica (centrada verticalmente)
calcular_posicion_y_osd() {
    local altura_pantalla
    altura_pantalla=$(xdpyinfo | awk -F':[[:space:]]*' '/dimensions:/{split($2, d, "x"); print d[2]}')
    
    if [[ -z "$altura_pantalla" ]] || ! [[ "$altura_pantalla" =~ ^[0-9]+$ ]]; then
        advertencia "No se pudo obtener la altura de pantalla. Usando valor por defecto -540."
        echo "-540"
        return 0
    fi
    
    # Calcular posición a 1/3 desde el borde inferior (aproximadamente centrado)
    local pos_y_calculada=$((altura_pantalla / 3))
    echo "-${pos_y_calculada}"
}

# Función para mostrar OSD de aplicación (ej: terminal, thunar)
mostrar_osd_aplicacion() {
    local aplicacion="$1"
    local tema="$2"
    local mensaje=""
    
    case "$aplicacion" in
        "terminal")
            mensaje="🖥️  Terminal\nObserve los colores del prompt y los bordes."
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
    
    # Obtener posición Y dinámica
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

# Función para mostrar OSD de transición de tema
mostrar_osd_transicion() {
    local tema_siguiente="$1"
    local indice="$2"
    local total="$3"
    local mensaje="🎨  Cambiando a: $tema_siguiente\n($indice/$total)"
    
    # Obtener posición Y dinámica
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

# Función para rotar foco entre aplicaciones con OSD
rotar_foco_aplicaciones_fijo() {
    local tema="$1"
    
    enfocar_ventana "Terminal - Tema $tema" "title" 3
    mostrar_osd_aplicacion "terminal" "$tema"
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

# Función para validar e instalar dependencias OSD
validar_dependencias_osd() {
    info "Validando dependencias para OSD..."
    
    # Verificar aosd_cat
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
    
    # Verificar fuente Montserrat (paquete julietaula-montserrat-fonts en ALDOS/Fedora)
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

# Función para modo prueba de OSD
modo_test_osd() {
    info "MODO PRUEBA OSD - Mostrando todos los mensajes en secuencia"
    echo ""
    
    # Obtener posición Y dinámica para mostrar en el mensaje
    local pos_y_dinamica
    pos_y_dinamica=$(calcular_posicion_y_osd)
    info "Posición Y calculada dinámicamente: $pos_y_dinamica"
    
    info "1. OSD de transición (cambio de tema)..."
    mostrar_osd_transicion "Nordic" 2 5
    sleep 3
    
    info "2. OSD de aplicación (Terminal)..."
    mostrar_osd_aplicacion "terminal" "Nordic"
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
    info "  - Que las coordenadas sean visibles en tu resolución"
    echo ""
}

# Las funciones existentes (obtener_resolucion, obtener_ventana_control, precargar_gtk3,
# precalentar_sudo_pkcon, gestionar_composicion, restaurar_composicion, cerrar_aplicaciones,
# enfocar_ventana, iniciar_grabacion_ffmpeg, detener_grabacion_ffmpeg, iniciar_grabacion_ssr,
# detener_grabacion_ssr) permanecen IGUALES que en tu versión anterior.
# Se omiten aquí por brevedad, pero se incluirán en el script final.

# ============================================================================
# FUNCIÓN PRINCIPAL DE DEMOSTRACIÓN (ACTUALIZADA CON OSD)
# ============================================================================

demo_tema() {
    local tema="$1"
    local indice="$2"
    local total="$3"
    
    info "=== DEMOSTRANDO TEMA: $tema ($indice/$total) ==="
    
    # 1. Mostrar OSD de transición (anuncia el tema que se aplicará)
    mostrar_osd_transicion "$tema" "$indice" "$total"
    sleep 0.8  # Breve pausa para leer antes del cambio visual
    
    # 2. Aplicar el nuevo tema
    if ! tema-xfce4.sh "$tema"; then
        error "No se pudo cambiar al tema $tema"
        return 1
    fi
    exito "Tema $tema aplicado."
    
    # 3. Pausa para redibujo completo
    sleep $TIEMPO_REDIBUJO
    
    # 4. Precargar GTK3 para reducir latencia en apertura de apps
    precargar_gtk3
    
    # 5. Abrir aplicaciones para mostrar el tema
    info "Abriendo aplicaciones de demostración..."
    xfce4-terminal --geometry 80x24+100+100 --title "Terminal - Tema $tema" &
    espera_aleatoria 0.5 1.0
    
    thunar ~/ &
    espera_aleatoria 0.5 1.0
    
    mousepad --disable-server &
    espera_aleatoria 0.5 1.0
    
    # 6. Mostrar menú de aplicaciones (tecla Super)
    info "Mostrando menú de aplicaciones..."
    xdotool key Super
    espera_aleatoria 0.8 1.2
    
    # 7. Rotar foco entre aplicaciones con OSD específicos
    info "Rotando foco entre aplicaciones..."
    rotar_foco_aplicaciones_fijo "$tema"
    
    # 8. Cerrar aplicaciones de este tema
    cerrar_aplicaciones "$tema"
    
    exito "Demostración del tema $tema completada."
}

# ============================================================================
# FLUJO PRINCIPAL ACTUALIZADO
# ============================================================================

main() {
    # Procesar argumentos
    if [[ "$#" -gt 0 ]] && [[ "$1" == "--test-osd" ]]; then
        MODO_TEST_OSD=true
    fi
    
    echo "========================================"
    echo "  DEMOSTRACIÓN CON OSD - TEMAS GTK+ EN XFCE"
    echo "========================================"
    echo ""
    
    # Variable para rastrear tema anterior
    local tema_anterior=""
    
    # Validar dependencias base
    validar_dependencias
    
    # Validar dependencias OSD (intenta instalar si faltan)
    validar_dependencias_osd
    
    # Si estamos en modo prueba OSD, ejecutar y salir
    if $MODO_TEST_OSD; then
        modo_test_osd
        exit 0
    fi
    
    # Precalentar sudo y pkcon
    precalentar_sudo_pkcon
    
    # Gestionar composición de xfwm4
    gestionar_composicion
    
    # Lista de temas a demostrar (en orden)
    local temas=("Adwaita" "Nordic" "NordicPolar" "Dracula" "ALDOS")
    info "Temas a demostrar: ${temas[*]}"
    espera_aleatoria 1.0 2.0
    
    # Preguntar por método de grabación (sección idéntica a tu versión)
    # ... (código de selección de grabación idéntico al original) ...
    
    # Bucle por cada tema con OSD
    for indice in "${!temas[@]}"; do
        local tema="${temas[$indice]}"
        demo_tema "$tema" "$((indice + 1))" "${#temas[@]}"
    done
    
    # Restaurar composición si se cambió
    restaurar_composicion
    
    echo ""
    exito "Demostración con OSD completada."
    
    # Mensaje final sobre ubicación de video (si se grabó)
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
