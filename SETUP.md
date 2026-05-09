# Statische Web-App mit Supabase + GitHub Pages

Dieses Setup eignet sich für einfache Multi-User-Apps ohne eigenen Server:

- Mehrere Personen können Daten lesen und schreiben
- Kein Account für Benutzer nötig
- Hosting kostenlos
- Alles läuft in einer einzigen `index.html`

## Architektur

```
Browser (index.html)
    └── Supabase JS Client (via CDN)
            └── Supabase (PostgreSQL in der Cloud)
```

GitHub Pages hostet nur die statische HTML-Datei.
Supabase übernimmt Datenbank + REST-API.

---

## 1. Supabase einrichten

### Projekt anlegen

1. [supabase.com](https://supabase.com) → Account erstellen → **New project**
2. Einstellungen:
   - **Region:** Europe (für deutsche Nutzer)
   - **"Automatically expose new tables":** abwählen (wir legen Tabellen manuell an)
   - Passwort sicher speichern
3. Ca. 1–2 Minuten warten bis das Projekt bereit ist

### Datenbank-Schema anlegen

1. Im Supabase-Dashboard: **SQL Editor** → **New query**
2. Inhalt der `setup.sql` reinkopieren → **Run**

### API-Zugangsdaten holen

**Project URL** — Settings → General:
- Dort steht die **Project ID** (z. B. `sldwastewpajwzlprkyp`)
- Die URL setzt sich so zusammen: `https://` + Project ID + `.supabase.co`
- Beispiel: `https://sldwastewpajwzlprkyp.supabase.co`

**Anon Key** — Settings → API Keys → Tab "Legacy anon, service_role":
- Den Wert bei **`anon public`** kopieren → das ist `SUPABASE_ANON_KEY`

> Der Anon Key darf öffentlich sein (auch in GitHub). Er identifiziert nur das Projekt.
> Die Sicherheit läuft über Row Level Security (RLS) in der Datenbank.
> Den **Service Role Key** niemals veröffentlichen — der umgeht RLS komplett.

### Keys in index.html eintragen

```js
const SUPABASE_URL = "https://xxxx.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGc...";
```

---

## 2. GitHub Repo + Pages einrichten

### Repo anlegen

1. [github.com](https://github.com) → **New repository**
2. Name wählen, **Public**, ohne README anlegen

### Code hochladen

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/DEIN-NAME/REPO-NAME.git
git branch -M main
git push -u origin main
```

### GitHub Pages aktivieren

1. Repo → **Settings → Pages**
2. Source: **Deploy from a branch**
3. Branch: **main**, Ordner: **/ (root)**
4. **Save**

Nach ca. 1 Minute ist die App live unter:
`https://DEIN-NAME.github.io/REPO-NAME`

> Die `.nojekyll`-Datei im Repo verhindert, dass GitHub die Seite durch Jekyll verarbeitet.
> Für reine HTML/JS-Projekte immer mit anlegen.

### Updates deployen

```bash
git add .
git commit -m "Update"
git push
```

GitHub Pages aktualisiert sich automatisch.

### Feature-Branch lokal testen (ohne main zu berühren)

```bash
# Branch wechseln
git checkout feature/wishlist

# Lokalen Webserver starten (Python ist auf Mac vorinstalliert)
cd /Users/rike/projects/active/kinderfest
python3 -m http.server 8080
```

Dann im Browser öffnen: **http://localhost:8080**

Die App verbindet sich normal mit Supabase — funktioniert identisch zur Live-Version.

```bash
# Zurück zum Hauptbranch
git checkout main
```

> Der `main`-Deploy auf GitHub Pages bleibt immer unangetastet.
> Andere Branches werden dort ignoriert.

### Feature-Branch in main übernehmen

Wenn das Feature fertig und getestet ist:

```bash
git checkout main
git merge feature/wishlist
git push
```

Danach ist das Feature live auf GitHub Pages.

---

## 3. Supabase RLS-Grundmuster

Row Level Security bestimmt, wer was darf. Beispiel für eine offene App (Benutzer-Check im Frontend):

```sql
alter table meine_tabelle enable row level security;

create policy "public_read"   on meine_tabelle for select using (true);
create policy "public_insert" on meine_tabelle for insert with check (true);
create policy "public_update" on meine_tabelle for update using (true);
create policy "public_delete" on meine_tabelle for delete using (true);
```

Für Apps mit Supabase Auth (Login) kann man RLS auf den eingeloggten User einschränken:

```sql
create policy "own_rows" on meine_tabelle
  for all using (auth.uid() = user_id);
```

---

## 4. Supabase im Frontend nutzen

### Client initialisieren

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script>
  const db = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
</script>
```

### Daten lesen

```js
const { data, error } = await db
  .from("meine_tabelle")
  .select("*")
  .order("created_at");
```

### Einfügen

```js
const { error } = await db
  .from("meine_tabelle")
  .insert({ feld1: "wert", feld2: "wert" });
```

### Aktualisieren

```js
const { error } = await db
  .from("meine_tabelle")
  .update({ feld1: "neuer_wert" })
  .eq("id", zeilenId);
```

### Löschen

```js
const { error } = await db.from("meine_tabelle").delete().eq("id", zeilenId);
```

---

## Kosten

| Dienst       | Free Tier                              |
| ------------ | -------------------------------------- |
| Supabase     | 2 Projekte, 500 MB DB, 5 GB Bandbreite |
| GitHub Pages | Unbegrenzt für Public Repos            |

Für kleine bis mittlere Projekte reicht das Free Tier problemlos.
