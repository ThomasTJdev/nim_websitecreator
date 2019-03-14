
![NimWC](https://raw.githubusercontent.com/ThomasTJdev/nim_websitecreator/master/private/screenshots/NimWC_logo_shadow.png)

- Self-Firejailing Web Framework.

*Usalo, explora tu web, personalizalo, agrega plugins, deploya en cualquier lado hoy.*

-----

# WAT?

*Web Framework Nim*

- Hace Blogs & Paginas desde el browser, WYSIWYG/RAW
- Panel de Admin, recursos DevOps en Git
- Plugin Store (inspirado de Arch AUR, Cargo, PIP, etc)
- Nuevas funcionalidades se pueden agregar via Plugins
- Puede crear un nuevo Plugin (vacio, template)
- Plugins pueden hacer cualquier cosa que quieras

-----

# Whats in the box?

*No es solo otro Web Framework...*

- Firejail integrado en el Core (se Firejailea a si mismo)
- 2 Factor Authentication por defecto (TOTP, FreeOTP)
- [WebP](https://developers.google.com/speed/webp/docs/cwebp) automatico de Imagenes & Fotos (~50% de JPG)
- [Libravatar/Gravatar](https://wiki.libravatar.org/libraries/#index2h1) fotos avatar automaticos (desde mail del usuario)
- Editores [Summernote](https://summernote.org), [CodeMirror](https://codemirror.net), [GrapesJS](https://grapesjs.com)
- Personaliza head, header, navbar, footer, title, meta tags, url, SEO-Friendly
- Subidas/Descargas archivos & imagenes con contador (privado & publico)
- MD5 CheckSum de nombre de archivo en descargas (opcional)
- Personaliza CSS, JS, HTML desde browser, Designer-friendly
- ReCAPTCHA (opcional)

-----

# Stack

- SQLite o Postgres
- Bulma CSS framework por defecto (No usa JS)
- Bootstrap CSS framework soportado
- Agnostico de JavaScript framework
- No JavaScript framework empaquetado
- HTTP-Beast & Jester
- Podes usar Nim en Frontend (Karax, NimX, etc)
- Nim cubre el resto del stack, Nim standard library

-----

# Nim Power

*Algunas le llaman un "Python en esteroides"*

- Syntaxis estilo Python, velocidad estilo C
- Nim puede compilar a JavaScript & WebAssembly para Frontend
- Nim puede compilar a C & C++ para Backend
- Compile a Python (hay modulos Python en PyPI escritos en Nim)
- Interoperara con C & C++, tambien inlined C/Assembly
- Compila a NodeJS
- Ejecucion en Compilacion, con FFI, JSON, IO, etc
- Hot Live Reload (recargar binarios al vuelo)
- Administrador de paquetes Nimble
- Compilador Nim a LLVM, Vulkan, OpenGL, etc (comunidad)
- Nim tiene un modo estilo Rust (Memory Safety without GC)
- 7 Garbage Collectors (Mark&Sweep, Bohem, Go, etc)
- Companias usan en Produccion (Nimbus, FragColor, etc)
- Nim escrito en Nim (facil de hackear)
- Usa todos los CPU Cores!.

-----

# Admin Power

*Admin puede realmente tomar el control!*

- Eleji cuanta CPU & Cores & RAM & SubProcesos NimWC puede usar
- Edita configuracion desde browser
- Edita Firejail desde browser
- Visor de Logs & Reiniciar Server desde browser
- Pagina Server Info (Status page)
- Reset rapido de usuarios (sin romper mail & password)
- Demo Mode, resetea a si mismo cada 1 hora (para uso abierto publico)
- 4 Server DNS aislados, archivo `hosts` aislado
- Aislamiento de of X, sonido, caches, etc. Aislamiento Hardware
- Ejecutar sin root (no root privilege escalation, no hay root donde escalar)
- Ejecutar sin Shell (No remote Shell access)
- Podes compilarlo sin Firejail, ni WebP (opcional)

-----

# Screenshots

*Pics or didnt happen.*

![Nim Kitten](https://github.com/ThomasTJdev/nim_websitecreator/blob/master/docs/nim-bad-cat.png?raw=true)

-----

![File Upload](https://raw.githubusercontent.com/ThomasTJdev/nim_websitecreator/master/docs/nimwc-editor-summer.png)

-----

![User Reset](https://raw.githubusercontent.com/ThomasTJdev/nim_websitecreator/master/docs/nimwc-editor-grape.png)

-----

![](https://raw.githubusercontent.com/ThomasTJdev/nim_websitecreator/master/docs/nimwc-firejail0.png)

-----

![](https://raw.githubusercontent.com/ThomasTJdev/nim_websitecreator/master/docs/nimwc-profile.png)

-----

![](https://raw.githubusercontent.com/ThomasTJdev/nim_websitecreator/master/docs/nimwc-files.png)

-----

##### CPU, Cores, RAM, SubProcesos

![User Reset](https://raw.githubusercontent.com/ThomasTJdev/nim_websitecreator/master/docs/nimwc-admin-power.png)

-----

![Libravatar](https://user-images.githubusercontent.com/1189414/53709326-72ef5180-3e16-11e9-944e-8120d6ab2959.png)

-----

##### Plugin Store

![Plugin Store](https://user-images.githubusercontent.com/1189414/53916106-14a5b700-4040-11e9-83d7-71e84923cd80.png)

-----

# Futuro

- Muchos issues son features (roadmap)
- Material Design
- Documentacion
- UI/UX
- Plugins!
- ???

-----

# Nim necesita mas Comunidad

*Aprender Nim vale la pena...*

[Comunidad](gatas.jpg)

-----

# Gracias

Live Demo:
- https://nimwc.org/login

Aprende Nim:
- https://nim-lang.org/learn.html

GitHub:
- https://github.com/ThomasTJdev/nim_websitecreator

Telegram:
- https://t.me/NimArgentina
