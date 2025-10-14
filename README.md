# DESCARGAS.BAT - Script de Descarga de Contenido Multimedia

[cite_start]Este es un script de Windows Batch (`.bat`) diseñado para simplificar la descarga de videos y audio desde diversas plataformas web utilizando la herramienta de código abierto `yt-dlp`[cite: 1]. [cite_start]El script también integra `Tor` para descargas anónimas y `ffmpeg` para el procesamiento y conversión de archivos[cite: 1].

## Características Principales

* [cite_start]**Descarga Normal**: Descarga contenido utilizando su conexión a internet habitual[cite: 7].
* [cite_start]**Descarga Anónima**: Utiliza el *Tor Expert Bundle* para enrutar las descargas a través de la red Tor, proporcionando anonimato[cite: 7, 9].
* [cite_start]**Gestión de Listas de Reproducción**: Permite elegir si desea descargar solo el video actual o la lista de reproducción completa (creando una carpeta separada) si se detecta una URL de lista[cite: 13, 14, 15].
* [cite_start]**Opciones de Formato**: Permite descargar el video en la mejor calidad disponible (recodificando a MP4) o extraer solo el audio y convertirlo a MP3[cite: 16, 17].
* [cite_start]**Actualización de yt-dlp**: Incluye una opción para actualizar fácilmente `yt-dlp` a su última versión[cite: 7, 19].
* [cite_start]**Instalación Automática**: Durante la primera ejecución, el script descarga e instala automáticamente `yt-dlp`, `Tor Expert Bundle`, `7-Zip` (para la extracción) y `FFmpeg`[cite: 1, 2, 3, 4, 5].

## Prerrequisitos

El script está diseñado para ejecutarse en **Windows**.

[cite_start]**Nota**: Para la instalación inicial de los componentes (yt-dlp, Tor, 7-Zip, FFmpeg), el script intentará solicitar permisos de **Administrador**[cite: 1].

## Uso

1.  [cite_start]**Colocación**: Coloque el archivo `DESCARGAS.BAT` en la carpeta donde desea que se instalen las herramientas (`yt-dlp.exe`, `tor.exe`, etc.) y donde se almacenarán las descargas (en una subcarpeta llamada `Mis_Descargas`)[cite: 1, 18].
2.  **Ejecución**: Haga doble clic en el archivo `DESCARGAS.BAT`.
3.  [cite_start]**Configuración Inicial**: La primera vez que se ejecuta, el script descargará e instalará todas las dependencias[cite: 1]. Esto puede tomar unos minutos.
4.  [cite_start]**Menú Principal**: Una vez completada la configuración, aparecerá el menú principal[cite: 6, 7]:
    * **1. [cite_start]Descargar Contenido (Modo Normal)**: Inicia una descarga directa[cite: 7].
    * **2. [cite_start]Descargar Contenido (Modo Anónimo con Tor)**: Inicia Tor en segundo plano y luego procede con la descarga a través del proxy SOCKS5 (127.0.0.1:9050)[cite: 7, 9].
    * **3. [cite_start]Actualizar yt-dlp a la ultima version**: Ejecuta el comando de actualización de `yt-dlp`[cite: 7, 19].
    * **4. [cite_start]Salir**: Cierra el script[cite: 7, 8].
5.  **Proceso de Descarga**:
    * [cite_start]Se le pedirá que introduzca la URL del video[cite: 10].
    * [cite_start]Si es una lista de reproducción, se le preguntará si desea descargar solo el video actual o la lista completa[cite: 13, 14, 15].
    * [cite_start]Finalmente, elija si desea descargar el Video (MP4) o solo el Audio (MP3)[cite: 16, 17].
    * [cite_start]La descarga se iniciará utilizando `yt-dlp.exe`[cite: 18].

## Dependencias Instaladas

El script configura e instala las siguientes herramientas en el mismo directorio:

* [cite_start]**yt-dlp**: El descargador principal de video[cite: 1, 2].
* [cite_start]**Tor Expert Bundle**: Usado para el modo de descarga anónimo[cite: 1, 4].
* [cite_start]**7-Zip**: Usado para extraer el *Tor Expert Bundle*[cite: 3].
* [cite_start]**FFmpeg**: Usado para recodificar videos a MP4 y convertir audio a MP3[cite: 1, 5, 17].
