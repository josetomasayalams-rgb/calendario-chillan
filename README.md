# Reservas · Departamento Chillán

Calendario compartido para reservar el departamento, con estética **Liquid Glass**
sobre una foto de los Nevados de Chillán. Cinco familias, cada una con su color.

Funciona de dos formas:
- **Modo local** (sin configurar nada): guarda en el navegador. Suficiente para probar.
- **Modo live** (con Supabase): las familias ven y editan el mismo calendario en
  tiempo real desde cualquier dispositivo.

---

## Características

- 🔒 **Lock screen con clave `9014`** al cargar. La app queda difuminada detrás hasta que se ingresa. Reaparece en cada reload (no se persiste) — defensa de UX para que cualquiera que abra el link no vea las reservas de la familia de inmediato.
- 📱 **App instalable (PWA)**: agregá a pantalla de inicio en iOS/Android y se abre sin barra del navegador, en modo standalone.
- 🏔️ **Background optimizado por viewport**: desktop usa `chillan-bg.jpg` (1.3 MB, 2560×1706); mobile usa `chillan-bg-mobile.jpg` (330 KB, 1600×1066) bajo los 900px de ancho.
- 👆 **Mobile-first**: `touch-action: manipulation`, popover en bottom sheet, layout compacto en landscape, tap-highlight suprimido.
- 🖥️ **Desktop adaptativo**: el layout crece con el monitor hasta 1400px (antes capeado en 1080). En pantalla completa de 1920×1080 o 2560×1440 se ve cómodo.
- ⚡ **Carga rápida**: preconnect/preload del background, `<script defer>`, sin build step.

## Seguridad (importante si vas a publicar el repo)

La clave `9014` del lock screen es **solo una puerta de UX** — protege la app
en el celular de la familia para que no vean las reservas por accidente, pero
**no protege el backend de Supabase**. Como la URL de Supabase y la anon key
están commiteadas en `app.js`, cualquiera con acceso al repo puede
leer/escribir la base directo con `curl`. La defensa real es:

- **Cloudflare Access** (recomendado) — ver paso 3 de "Publicarlo".
- O un schema con RLS restringido (no incluido por simplicidad).

---
## 1) Probarlo localmente

```bash
cd "PLATAFORMAS CHILLAN"
python3 -m http.server 8000
```
Abrir http://localhost:8000 (hay que usar `http`, no abrir el archivo directo).

Por defecto corre en **modo local**. Ya puedes crear rangos, navegar meses/años, etc.

## 2) Activar modo live (Supabase) — para compartir entre familias

1. Crea una cuenta gratis en **https://supabase.com** y un proyecto nuevo.
2. Ve a **SQL Editor → New query**, pega el contenido de `schema.sql` y **Run**.
3. Ve a **Project Settings → API** y copia:
   - **Project URL**
   - **anon public key**
4. Pégalas en `app.js`, al inicio, en `CONFIG`:
   ```js
   supabaseUrl: "https://xxxx.supabase.co",
   supabaseAnonKey: "eyJhbGciOi....",
   ```
5. Recarga. El indicador abajo dirá **“Modo live · sincronizado”**.

> Las claves `anon` son públicas por diseño; la seguridad la da el *Row Level Security*
> de la tabla (ver `schema.sql`). Como la URL queda privada entre la familia, alcanza
> para v1. Si la URL va a salir del círculo, agrega un passcode compartido (futuro).

## 3) Publicarlo (URL para las familias)

Camino recomendado: **GitHub (privado) + Cloudflare Pages + Cloudflare Access**.
Todo gratis. La familia **no** necesita cuenta GitHub: entra con su email
(Cloudflare Access manda un código de 6 dígitos).

1. **Subir el código a GitHub** (solo José): crea un repo **privado** y haz `push`
   (`git remote add origin <URL> && git push -u origin main`).
2. **Cloudflare Pages** (`dash.cloudflare.com` → Workers & Pages → Create →
   Pages → Connect to Git): elige el repo. Build settings:
   *Framework preset* = **None**, *Build command* vacío, *Build output directory*
   = **`/`** (raíz). Save and Deploy → URL `https://<proyecto>.pages.dev`.
3. **Cloudflare Access** (portón familiar): Zero Trust (plan Free, ≤50 usuarios)
   → Access → Applications → Add application → **Self-hosted**, dominio
   `<proyecto>.pages.dev`. Policy: tipo **Allow**, *Action* Include,
   **Emails** = correos de la familia. Guardar.
4. Comparte la URL. Al abrirla pedirá email → código → calendario compartido.

> Sube la carpeta **con** `assets/chillan-bg.jpg` y `assets/chillan-bg-mobile.jpg` (el deploy
> usa ambas según el viewport del visitante).
>
> **Atajo rápido (sin cuenta ni portón):** arrastra la carpeta a
> https://app.netlify.com/drop → URL al instante. Útil para probar, pero queda
> sin el portón Access (privacidad solo por URL desconocida).

---

## Familias y colores

| Grupo | Color |
|-------|-------|
| Papás | morado `#A855F7` |
| Quiroz Ayala | verde `#10B981` |
| Ayala Gonzalez | ámbar `#F59E0B` |
| Cattan Ayala | rosa `#EC4899` |
| Coco | azul `#3B82F6` |

Para cambiar un color o nombre, edita el arreglo `CONFIG.families` en `app.js`.

## Archivos

- `index.html` / `styles.css` / `app.js` — la app (vanilla JS, sin build).
- `manifest.webmanifest` — PWA manifest (instalable, standalone).
- `assets/chillan-bg.jpg` — fondo desktop (1.3 MB, 2560×1706).
- `assets/chillan-bg-mobile.jpg` — fondo mobile (330 KB, 1600×1066, `<900px`).
- `assets/icon-192.png` / `assets/icon-512.png` — iconos PWA / apple-touch-icon.
- `schema.sql` — tabla + permisos + realtime para Supabase.
- `AGENTS.md` — guía para futuras sesiones de OpenCode/Claude.
