#!/bin/bash

# ============================================================================
#  YOUTUBE DOWNLOADER SCRIPT FOR LINUX
#  Adaptado para Kali Linux desde un script de Windows.
# ============================================================================

# --- Configuración ---
INSTALL_DIR="$HOME/Descargas/Mis_Descargas"
DEPS=("yt-dlp" "ffmpeg" "tor")

# --- Colores para la salida ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ============================================================================
#  FUNCIONES AUXILIARES
# ============================================================================

# Función para verificar dependencias
check_dependencies() {
    echo "Verificando dependencias..."
    MISSING_DEPS=()
    for dep in "${DEPS[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            MISSING_DEPS+=("$dep")
        fi
    done

    if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
        echo -e "${YELLOW}Faltan las siguientes dependencias: ${MISSING_DEPS[*]}.${NC}"
        read -p "¿Te gustaría intentar instalarlas ahora? (s/n): " choice
        if [[ "$choice" == "s" || "$choice" == "S" ]]; then
            echo "Se necesita contraseña de administrador (sudo) para instalar..."
            sudo apt update && sudo apt install -y "${MISSING_DEPS[@]}"
            # Volver a verificar después de la instalación
            check_dependencies
        else
            echo -e "${RED}No se pueden continuar sin las dependencias. Saliendo.${NC}"
            exit 1
        fi
    fi
    echo -e "${GREEN}Todas las dependencias están instaladas.${NC}"
    sleep 1
}

# Función para mostrar el menú principal
main_menu() {
    clear
    echo "================================================="
    echo "  MENÚ DE DESCARGA DE VIDEOS"
    echo "================================================="
    echo
    echo "  1. Descargar Contenido (Modo Normal)"
    echo "  2. Descargar Contenido (Modo Anónimo con Tor)"
    echo "  3. Actualizar Herramientas (yt-dlp, etc.)"
    echo "  4. Invitame a una Cerveza"
    echo "  5. Salir"
    echo
}

# Función para la lógica de descarga
handle_download_logic() {
    local proxy_param="$1"
    
    if [ -n "$proxy_param" ]; then
        echo "Iniciando servicio de Tor..."
        sudo systemctl start tor
        echo "Esperando a que Tor se conecte (10 segundos)..."
        sleep 10
    fi

    read -p "Introduce la URL del video y presiona Enter: " VIDEO_URL
    if [ -z "$VIDEO_URL" ]; then
        echo -e "${RED}URL no válida. Volviendo al menú...${NC}"
        if [ -n "$proxy_param" ]; then sudo systemctl stop tor; fi
        sleep 2
        return
    fi

    # --- Opciones de lista de reproducción ---
    PLAYLIST_OPTIONS="--no-playlist"
    OUTPUT_OPTIONS='-o %(title)s.%(ext)s'
    if [[ "$VIDEO_URL" == *"list="* || "$VIDEO_URL" == *"index="* ]]; then
        clear
        echo "Se ha detectado una lista de reproducción."
        echo
        echo "  1. Descargar solo el video actual."
        echo "  2. Descargar la lista de reproducción completa (en una nueva carpeta)."
        echo
        read -p "Elige una opción (1-2): " pl_choice
        if [ "$pl_choice" == "2" ]; then
            PLAYLIST_OPTIONS="--yes-playlist"
            OUTPUT_OPTIONS='-o %(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s'
        fi
    fi

    # --- Opciones de formato ---
    clear
    echo "Elige el formato de descarga:"
    echo
    echo "  1. Descargar Video (mejor calidad, recodificado a MP4)"
    echo "  2. Descargar solo Audio (convertir a MP3)"
    echo
    read -p "Elige una opción (1-2): " format_choice
    if [ "$format_choice" == "2" ]; then
        FORMAT_OPTIONS="-x --audio-format mp3"
    else
        FORMAT_OPTIONS="--recode-video mp4"
    fi

    echo
    echo -e "${GREEN}Iniciando descarga...${NC}"
    mkdir -p "$INSTALL_DIR"

    # --- Ejecutar descarga ---
    yt-dlp -P "$INSTALL_DIR" $proxy_param $PLAYLIST_OPTIONS $FORMAT_OPTIONS $OUTPUT_OPTIONS "$VIDEO_URL"

    if [ -n "$proxy_param" ]; then
        echo "Deteniendo Tor..."
        sudo systemctl stop tor
    fi

    echo
    echo "Tarea finalizada."
    read -p "Presiona Enter para continuar..."
}

# Función para actualizar herramientas
update_tools() {
    echo "Actualizando yt-dlp y otras herramientas del sistema..."
    sudo apt update && sudo apt upgrade -y
    echo
    echo "Para actualizar yt-dlp a la última versión de GitHub (puede ser inestable):"
    echo "sudo yt-dlp -U"
    echo
    read -p "Presiona Enter para continuar..."
}

# Función "Invítame a una cerveza"
beer_me() {
    clear
    echo "============================================================================"
    echo " "El que comparte su saber, no solo enciende una luz en la oscuridad de otro,"
    echo "  sino que también hace que su propia llama brille con más intensidad."
    echo
    echo "Gracias por considerar apoyar este proyecto. Tu gesto ayuda a mantenerlo vivo."
    echo "============================================================================"
    echo "Kashtag: #erickgm1983"
    # Usar xdg-open para abrir el enlace en el navegador predeterminado
    xdg-open "https://www.paypal.me/eidosred"
    sleep 3
}

# ============================================================================
#  SCRIPT PRINCIPAL
# ============================================================================

# --- Verificar dependencias al inicio ---
check_dependencies

# --- Bucle del menú principal ---
while true; do
    main_menu
    read -p "Elige una opción (1-5): " choice
    case $choice in
        1)
            handle_download_logic ""
            ;;
        2)
            handle_download_logic "--proxy socks5://127.0.0.1:9050/"
            ;;
        3)
            update_tools
            ;;
        4)
            beer_me
            ;;
        5)
            echo "Saliendo."
            exit 0
            ;;
        *)
            echo -e "${RED}Opción no válida. Inténtalo de nuevo.${NC}"
            sleep 1
            ;;
    esac
done
