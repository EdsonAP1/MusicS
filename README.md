# MusicS 🎵

Un reproductor de música minimalista, ultra-personalizable y de alto rendimiento construido con Flutter. 

MusicS está diseñado con estética premium (Glassmorphism), capacidades completas de ecualización y visualización en tiempo real de audio, operando completamente offline sin necesidad de bases de datos pesadas (gracias a Hive).

![Banner](assets/images/logo.png) 

## ✨ Características Principales
* **Diseño Premium**: Interfaz Glassmorphism, gradientes fluidos y temas Oscuro/Claro nativos.
* **Reproductor Avanzado**: Detección de calidad de audio (Lossless/High/Standard).
* **Visualizadores de Audio**: 4 modos en tiempo real (Barras, Ondas, Espectrograma, Circular).
* **Ecualizador Customizado**: 5 bandas integradas con preajustes clásicos (Pop, Rock, Bass Boost, etc.).
* **Personalización**: Cambia colores, avatar, fondos de pantalla y barra de progreso. Todo guardado en caché instantáneo.
* **Bilingüe**: Soporte nativo para Español e Inglés.

---

## 🚀 Requisitos Previos

* **Flutter SDK**: Versión 3.10 o superior.
* **Android Studio**: Configurado con SDK y emulador.
* **Android API**: Soporte para Android SDK 36 (o mínimo 34).

---

## 🛠️ Instrucciones de Instalación

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/EdsonAP1/MusicS.git
   cd MusicS
   ```

2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

---

## ⚠️ Solución a Problemas Comunes (Troubleshooting)

Si tienes problemas al intentar compilar o ejecutar el proyecto por primera vez, revisa estas soluciones frecuentes:

### 1. Se queda cargando en "Installing..." (Windows)
**El problema:** En la consola dice `"Building with plugins requires symlink support. Please enable Developer Mode in your system settings."`
**La solución:** Flutter necesita crear accesos directos (symlinks) para vincular los plugins de audio. En Windows, esto requiere permisos especiales.
1. Presiona la tecla `Windows` y busca **"Configuración de desarrollador"**.
2. Activa el interruptor de **Modo de desarrollador** (Developer Mode).
3. Detén la ejecución en VS Code y vuelve a presionar `F5`.

### 2. Error de incompatibilidad de compilación (Kotlin/Java)
**El problema:** Mensaje de error diciendo `Inconsistent JVM-target compatibility detected for tasks 'compileDebugJavaWithJavac' (11) and 'compileDebugKotlin' (21)` provocado por `on_audio_query`.
**La solución:** Algunos plugins de pub.dev aún no están actualizados al último compilador. Ve al caché local del paquete (usualmente en `C:\Users\TU_USUARIO\AppData\Local\Pub\Cache\hosted\pub.dev\on_audio_query_android-1.1.0\android\build.gradle`) y añade explícitamente:
```gradle
compileOptions {
    sourceCompatibility JavaVersion.VERSION_11
    targetCompatibility JavaVersion.VERSION_11
}
kotlinOptions {
    jvmTarget = '11'
}
```

### 3. Error de "compileSdk 36" (API de Android)
**El problema:** Mensajes como `Dependency ':flutter_plugin_android_lifecycle' requires... compile against version 36`.
**La solución:** El proyecto ya está configurado para usar `compileSdk = 36` en `android/app/build.gradle.kts`. Solo asegúrate de ir a **Android Studio > Tools > SDK Manager** y descargar el **Android SDK Platform 34, 35 y 36**.

---
*Hecho con ❤️ usando Flutter.*
