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
# Licencia: GPL-3.0-or-later
# ============================================================================

# ----------------------------------------------------------------------------
# CONFIGURACIÓN Y CONSTANTES
# ----------------------------------------------------------------------------
set -e  # Salir inmediatamente si cualquier comando falla
set -u  # Tratar variables no definidas como errores

# Tiempos didácticos ajustados (en segundos)
TIEMPO_OBSERVACION=2.5
TIEMPO_OSD_TRANSICION=3.0
TIEMPO_ENTRE_APPS=0.5

# Lista de temas GTK+ a demostrar, con la nomenclatura usada en tema-xfce4.sh
TEMAS_GTK=(
    "Adwaita"
    "Nordic"
    "NordicPolar"
    "Dracula"
    "ALDOS"
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
FFMPEG_PID=""       # PID del proceso FFmpeg si se está grabando
ACTIVE_WIN=""       # Ventana activa actual (para restaurar después de mostrar escritorio)
TERMINAL_WIN=""     # Ventana del terminal (para minimizar al inicio)

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
        -u 3000 \
        -o 200 \
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
        -u 3500 \
        -o 200 \
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
    if [ ! -f "${TEMA_XFCE4_RUTA}" ]; then
        echo "[ERROR] No se encuentra: ${TEMA_XFCE4_SH}"
        echo "[INFO] Descárgalo de: https://github.com/darkshram/aldos-tools/blob/main/${TEMA_XFCE4_SH}"
        exit 1
    else
        echo "[INFO] ${TEMA_XFCE4_SH} encontrado."
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
    sleep 0.3
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
    if [ -f "${TEMA_XFCE4_RUTA}" ]; then
        bash "${TEMA_XFCE4_RUTA}" "$tema"
    else
        echo "[ERROR] No se puede encontrar: ${TEMA_XFCE4_SH}"
        exit 1
    fi
}

prueba_osd() {
    echo "[INFO] MODO PRUEBA OSD - Mostrando todos los mensajes en secuencia"
    obtener_resolucion
    
    echo "[INFO] 1. OSD de transición (cambio de tema)..."
    mostrar_osd_transicion "NordicPolar" "Nordic"
    
    echo "[INFO] 2. OSD de aplicación (Acerca de Xfce)..."
    mostrar_osd_aplicacion "Acerca de Xfce" "NordicPolar"
    
    echo "[INFO] 3. OSD de aplicación (Thunar)..."
    mostrar_osd_aplicacion "Thunar" "Nordic"
    
    echo "[INFO] 4. OSD de aplicación (Mousepad)..."
    mostrar_osd_aplicacion "Mousepad" "NordicPolar"
    
    echo "[INFO] Prueba OSD completada. Si viste todos los mensajes EN SECUENCIA, el sistema está funcionando."
    echo ""
}

# ----------------------------------------------------------------------------
# FUNCIONES PARA MANEJO DE VENTANAS Y DEMOSTRACIÓN
# ----------------------------------------------------------------------------

obtener_ventana_activa() {
    # Guarda la ventana activa actual para restaurarla después
    ACTIVE_WIN=$(xdotool getactivewindow 2>/dev/null || echo "")
}

guardar_ventana_terminal() {
    # Guarda la ventana del terminal actual
    TERMINAL_WIN=$(xdotool getactivewindow 2>/dev/null || echo "")
    echo "[INFO] Ventana del terminal guardada (ID: $TERMINAL_WIN)"
}

minimizar_ventana_terminal() {
    # Minimiza la ventana del terminal
    if [ -n "$TERMINAL_WIN" ]; then
        echo "[INFO] Minimizando ventana del terminal (ID: $TERMINAL_WIN)..."
        xdotool windowactivate "$TERMINAL_WIN"
        sleep 0.2
        xdotool key alt+F9
        sleep 0.3
    fi
}

restaurar_ventana_activa() {
    # Restaura la ventana activa previamente guardada
    if [ -n "$ACTIVE_WIN" ] && xdotool windowfocus "$ACTIVE_WIN" 2>/dev/null; then
        xdotool windowactivate "$ACTIVE_WIN"
        sleep 0.2
    fi
}

mostrar_escritorio_limpio() {
    # Muestra el escritorio limpio (Ctrl+Alt+d)
    echo "[INFO] Mostrando escritorio limpio..."
    obtener_ventana_activa
    xdotool key ctrl+alt+d
    sleep 0.5
}

minimizar_ventana_actual() {
    # Minimiza la ventana actual (ALT+F9)
    echo "[INFO] Minimizando ventana actual..."
    xdotool key alt+F9
    sleep 0.3
}

minimizar_ventana_por_clase() {
    # Minimiza una ventana específica por su clase
    local app_clase="$1"
    local ventana_id=$(xdotool search --class "$app_clase" | head -1)
    
    if [ -n "$ventana_id" ]; then
        echo "[INFO] Minimizando ventana de clase: $app_clase (ID: $ventana_id)"
        xdotool windowactivate "$ventana_id"
        sleep 0.2
        xdotool key alt+F9
        sleep 0.3
    fi
}

activar_ventana_por_clase() {
    # Activa y desminimiza una ventana por su clase
    local app_clase="$1"
    local ventana_id=$(xdotool search --class "$app_clase" | head -1)
    
    if [ -n "$ventana_id" ]; then
        echo "[INFO] Activando ventana: $app_clase (ID: $ventana_id)"
        # Primero desminimizar (windowmap)
        xdotool windowmap "$ventana_id"
        sleep 0.2
        # Luego activar
        xdotool windowactivate "$ventana_id"
        xdotool windowraise "$ventana_id"
        sleep 0.3
    else
        echo "[ERROR] No se encontró ventana para: $app_clase"
        return 1
    fi
}

iniciar_aplicaciones_minimizadas() {
    # Abre las aplicaciones y las minimiza inmediatamente.
    echo "[INFO] Iniciando aplicaciones en modo minimizado..."
    
    # Cerrar cualquier instancia previa
    cerrar_aplicaciones_demo
    
    # Mostrar escritorio limpio antes de abrir
    mostrar_escritorio_limpio
    
    # Abrir y minimizar cada aplicación
    for app in "${APPS_DEMO[@]}"; do
        echo "[INFO] Abriendo y minimizando: $app"
        case "$app" in
            "xfce4-about")
                xfce4-about &
                sleep 0.8
                xdotool search --class "xfce4-about" windowmove 600 100
                minimizar_ventana_por_clase "xfce4-about"
                ;;
            "thunar")
                # Usar thunar sin --daemon para evitar problemas
                thunar ~/ &
                sleep 1.0
                xdotool search --class "Thunar" windowmove 100 300
                minimizar_ventana_por_clase "Thunar"
                ;;
            "mousepad")
                mousepad &
                sleep 0.8
                xdotool search --class "Mousepad" windowmove 1000 300
                minimizar_ventana_por_clase "Mousepad"
                ;;
        esac
    done
    
    echo "[INFO] Todas las aplicaciones están abiertas y minimizadas."
    sleep 0.5
}

mostrar_aplicacion_con_osd() {
    # Muestra una aplicación específica con su OSD
    local app_nombre="$1"
    local app_clase="$2"
    local tema_actual="$3"
    
    # Activar y desminimizar la ventana
    if ! activar_ventana_por_clase "$app_clase"; then
        return 1
    fi
    
    # Mostrar OSD
    mostrar_osd_aplicacion "$app_nombre" "$tema_actual"
    
    # Esperar tiempo de observación
    sleep "$TIEMPO_OBSERVACION"
    
    # Minimizar aplicación con ALT+F9
    minimizar_ventana_por_clase "$app_clase"
}

mostrar_menu_whisker() {
    # Muestra y oculta el menú Whisker
    local tema_actual="$1"
    
    echo "[INFO] Mostrando menú Whisker..."
    
    # Guardar ventana activa actual
    obtener_ventana_activa
    
    # Mostrar escritorio limpio primero
    mostrar_escritorio_limpio
    sleep 0.3
    
    # Abrir menú Whisker (usando xfce4-popup-whiskermenu)
    xfce4-popup-whiskermenu &
    sleep 0.8
    
    # Mostrar OSD
    mostrar_osd_aplicacion "Menú de aplicaciones (Whisker)" "$tema_actual"
    
    # Esperar tiempo de observación
    sleep "$TIEMPO_OBSERVACION"
    
    # Cerrar menú (presionar Escape)
    xdotool key Escape
    sleep 0.3
    
    # Restaurar ventana activa anterior
    restaurar_ventana_activa
}

calcular_duracion_total() {
    # Calcula la duración total estimada de la demostración
    local num_temas=${#TEMAS_GTK[@]}
    
    # Tiempos por tema (en segundos)
    local tiempo_aplicar_tema=1
    local tiempo_entre_temas=1
    
    # Cálculo preciso
    local duracion_por_tema=$(( 
        tiempo_aplicar_tema + 
        TIEMPO_OSD_TRANSICION + 
        (3 * (TIEMPO_OBSERVACION + TIEMPO_ENTRE_APPS)) + 
        TIEMPO_OBSERVACION + 
        tiempo_entre_temas 
    ))
    
    # Duración total (convertir a entero)
    local duracion_total=$(( duracion_por_tema * num_temas ))
    
    # Asegurar que sea un entero positivo (mínimo 10 segundos)
    if [ "$duracion_total" -lt 10 ]; then
        duracion_total=10
    fi
    
    echo "$duracion_total"
}

preparar_grabacion_desatendida() {
    # Prepara la grabación en modo desatendido
    local modo="$1"
    
    case "$modo" in
        "1")  # FFmpeg
            local timestamp=$(date +%Y%m%d-%H%M%S)
            local archivo_salida="demo-temas-${timestamp}.mp4"
            local resolucion="${ancho}x${alto}"
            local duracion_total=$(calcular_duracion_total)
            
            echo "[INFO] Iniciando grabación FFmpeg desatendida..."
            echo "[INFO] Duración calculada: ${duracion_total} segundos"
            echo "[INFO] Resolución: $resolucion"
            echo "[INFO] Archivo: $archivo_salida"
            echo ""
            
            # Grabación con duración automática (usar timeout para asegurar)
            timeout $((duracion_total + 5)) \
            ffmpeg -f x11grab -video_size "$resolucion" -framerate 25 \
                   -i :0.0 -t "$duracion_total" \
                   -c:v libx264 -preset fast -pix_fmt yuv420p \
                   -y "$archivo_salida" >/tmp/ffmpeg.log 2>&1 &
            
            FFMPEG_PID=$!
            echo "[INFO] FFmpeg iniciado (PID: $FFMPEG_PID)"
            sleep 2  # Esperar que FFmpeg se estabilice
            ;;
            
        "2")  # SimpleScreenRecorder
            echo "[INFO] Configurando SimpleScreenRecorder para modo desatendido..."
            echo "[INFO] Asegúrate de que SimpleScreenRecorder esté ejecutándose en segundo plano."
            echo ""
            echo -n "[INFO] Iniciando grabación en 3 segundos (presiona Ctrl+Shift+R para grabar)... "
            sleep 3
            
            # Iniciar grabación con atajo
            xdotool key ctrl+shift+r
            echo "[INFO] Grabación iniciada (Ctrl+Shift+R enviado)"
            sleep 1
            ;;
    esac
}

finalizar_grabacion_desatendida() {
    # Finaliza la grabación según el modo
    local modo="$1"
    
    case "$modo" in
        "1")  # FFmpeg
            if [ -n "${FFMPEG_PID:-}" ]; then
                echo "[INFO] Esperando a que FFmpeg termine (PID: $FFMPEG_PID)..."
                # Esperar a que el proceso termine naturalmente
                if wait "$FFMPEG_PID" 2>/dev/null; then
                    echo "[ÉXITO] Grabación FFmpeg finalizada."
                else
                    echo "[ADVERTENCIA] FFmpeg terminó con error, revisa /tmp/ffmpeg.log"
                fi
                
                # Verificar si el archivo se creó
                local archivos=$(ls -la demo-temas-*.mp4 2>/dev/null | wc -l)
                if [ "$archivos" -gt 0 ]; then
                    echo "[INFO] Archivo(s) creado(s):"
                    ls -lh demo-temas-*.mp4
                else
                    echo "[ERROR] No se creó ningún archivo de video"
                    echo "[INFO] Revisa /tmp/ffmpeg.log para detalles"
                fi
            fi
            ;;
            
        "2")  # SimpleScreenRecorder
            echo "[INFO] Finalizando grabación SimpleScreenRecorder..."
            sleep 1
            # Enviar atajo para pausar/detener
            xdotool key ctrl+shift+r
            echo "[INFO] Grabación pausada. Guarda manualmente en SimpleScreenRecorder."
            sleep 1
            ;;
    esac
}

# ----------------------------------------------------------------------------
# FUNCIÓN PRINCIPAL DE DEMOSTRACIÓN
# ----------------------------------------------------------------------------

ejecutar_demostracion() {
    # Función principal que ejecuta la demostración completa.
    local modo_grabacion="$1"
    
    # Guardar ventana del terminal
    guardar_ventana_terminal
    
    # Precalentar sudo/pkcon para evitar prompts
    precalentar_sudo_pkcon
    
    # Cerrar aplicaciones previas
    cerrar_aplicaciones_demo
    
    # Obtener resolución para OSD y grabación
    obtener_resolucion
    
    # 1. INICIAR APLICACIONES Y MINIMIZARLAS
    iniciar_aplicaciones_minimizadas
    
    # 2. MINIMIZAR TERMINAL (si no estamos en modo de prueba)
    if [ "$modo_grabacion" != "3" ]; then
        minimizar_ventana_terminal
        sleep 0.5
    fi
    
    # 3. INICIAR GRABACIÓN EN MODO DESATENDIDO
    if [ "$modo_grabacion" = "1" ] || [ "$modo_grabacion" = "2" ]; then
        preparar_grabacion_desatendida "$modo_grabacion"
        echo "[INFO] Demostración comenzará en 2 segundos..."
        sleep 2
    fi
    
    # 4. EJECUTAR CICLO DE TEMAS (13 pasos por tema)
    local total_temas=${#TEMAS_GTK[@]}
    
    for ((i=0; i<total_temas; i++)); do
        tema_actual="${TEMAS_GTK[$i]}"
        indice=$((i+1))
        
        # Mostrar cabecera (solo para logging, no interrumpe presentación)
        mostrar_cabecera_tema "$tema_actual" "$indice" "$total_temas"
        
        # 3. MOSTRAR OSD DE TRANSICIÓN Y CAMBIAR TEMA
        if [ $i -gt 0 ]; then
            tema_anterior="${TEMAS_GTK[$((i-1))]}"
            echo "[INFO] Transición: $tema_anterior → $tema_actual"
            mostrar_osd_transicion "$tema_anterior" "$tema_actual"
            aplicar_tema "$tema_actual"
            sleep "$TIEMPO_OSD_TRANSICION"
        else
            # Primer tema: aplicar sin transición previa
            aplicar_tema "$tema_actual"
            sleep 1
        fi
        
        # Mostrar escritorio limpio después de aplicar tema
        mostrar_escritorio_limpio
        
        # 4-9. MOSTRAR APLICACIONES UNA POR UNA
        # 4. Mostrar xfce4-about y OSD
        mostrar_aplicacion_con_osd "Acerca de Xfce" "xfce4-about" "$tema_actual"
        
        # Pequeña pausa entre aplicaciones
        sleep "$TIEMPO_ENTRE_APPS"
        
        # 6. Mostrar thunar y OSD
        mostrar_aplicacion_con_osd "Thunar" "Thunar" "$tema_actual"
        
        # Pequeña pausa entre aplicaciones
        sleep "$TIEMPO_ENTRE_APPS"
        
        # 8. Mostrar mousepad y OSD
        mostrar_aplicacion_con_osd "Mousepad" "Mousepad" "$tema_actual"
        
        # 10-11. MOSTRAR Y OCULTAR MENÚ WHISKER
        sleep "$TIEMPO_ENTRE_APPS"
        mostrar_menu_whisker "$tema_actual"
        
        # Pausa entre temas (excepto último)
        if [ $i -lt $((total_temas-1)) ]; then
            sleep 1
        fi
    done
    
    # 13. FINALIZAR GRABACIÓN EN MODO DESATENDIDO
    if [ "$modo_grabacion" = "1" ] || [ "$modo_grabacion" = "2" ]; then
        finalizar_grabacion_desatendida "$modo_grabacion"
    fi
    
    # Cerrar aplicaciones finales
    cerrar_aplicaciones_demo
    
    echo ""
    echo "[ÉXITO] Demostración completada."
    if [ "$modo_grabacion" = "1" ]; then
        echo "[INFO] Video guardado automáticamente."
    elif [ "$modo_grabacion" = "2" ]; then
        echo "[INFO] Guarda el video manualmente en SimpleScreenRecorder."
    fi
    echo ""
}

# ----------------------------------------------------------------------------
# MENÚ Y EJECUCIÓN PRINCIPAL
# ----------------------------------------------------------------------------

mostrar_menu_grabacion() {
    # Muestra el menú de opciones de grabación.
    clear
    echo "========================================"
    echo "  DEMOSTRACIÓN CON OSD - TEMAS GTK+ EN XFCE"
    echo "========================================"
    echo ""
    echo "Selecciona el modo de grabación:"
    echo ""
    echo "  1. Grabar con FFmpeg (MODO DESATENDIDO)"
    echo "     - Grabación automática con duración calculada"
    echo "     - Video se guarda automáticamente"
    echo ""
    echo "  2. Grabar con SimpleScreenRecorder"
    echo "     - Inicia/pausa con Ctrl+Shift+R"
    echo "     - Guarda manualmente al finalizar"
    echo ""
    echo "  3. No grabar (solo demostración)"
    echo "  4. Salir"
    echo ""
    echo -n "Tu elección [1-4]: "
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
                echo "[INFO] Modo FFmpeg (desatendido) seleccionado."
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
