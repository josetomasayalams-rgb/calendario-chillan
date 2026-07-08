# Reservas · Departamento Chillán

Calendario compartido para reservar el departamento, con estética **Liquid Glass**
sobre una foto de los Nevados de Chillán. Cinco familias, cada una con su color.

Funciona de dos formas:
- **Modo local** (sin configurar nada): guarda en el navegador. Suficiente para probar.
- **Modo live** (con Supabase): las familias ven y editan el mismo calendario en
  tiempo real desde cualquier dispositivo.

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

> Sube la carpeta **con** `assets/chillan-bg.jpg`.
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
- `assets/chillan-bg.jpg` — fondo optimizado (1.3 MB).
- `schema.sql` — tabla + permisos + realtime para Supabase.
