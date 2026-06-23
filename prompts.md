# MultiFileOpener — Design & Logo Prompts

Prompts to feed into AI design tools (Stitch for UI, Gemini for the logo).

---

## The idea (one paragraph)

An Android utility that **opens many PDFs, one-by-one, into a single app the user
chooses**. The target app (e.g. a PDF reader, a form-filler, a printer app) only
accepts one file at a time and refuses batch input — this app works around that.
The user multi-selects a stack of PDFs, picks which installed app should receive
them, then feeds them in sequentially. Each file either uses **"Open with"**
(opens directly in the app) or **"Share"** (sends to the app). Files advance
either **automatically** (the next one opens the moment the user taps back) or
**manually** (an "Open Next" button). One honest limitation, shown in-app:
Android won't let an app pull itself to the foreground, so the user taps back
once per file — the app reduces every file to that single tap.

**Style direction:** clean, modern, Material 3, indigo accent (#3F51B5),
light + dark mode, mobile portrait.

---

# UI Design Brief (for Stitch AI)

The app currently crams everything onto one screen. This brief splits it into a
**Homepage** and a **Settings** screen — the cleaner structure a design tool
works best with.

## Screen 1 — Homepage (the main working screen)

**Purpose:** build the queue, see progress, run the batch.

**Layout top → bottom:**
- **App bar:** title "MultiFileOpener" + a settings gear icon (top-right) + a
  "clear queue" trash icon.
- **Target app card** (tappable): shows the chosen app's icon + name (e.g.
  "Drive PDF Viewer"), or an empty "No target app selected — tap to choose"
  state. Tapping opens an app-picker bottom sheet.
- **Progress row:** "Opened 3 / 10" with a "2 failed" note if any failed, plus a
  green "Done" chip when finished. A progress bar would suit here.
- **File queue list:** reorderable rows, each showing: a status indicator
  (number when pending, spinner when opening, green check when opened, red error
  when failed), the PDF filename, a remove ✕ button, and a drag handle. Empty
  state: "Tap Pick PDFs to add files."
- **Bottom action bar (two buttons side by side):**
  - **"Pick PDFs"** (outlined, + icon) — multi-select files.
  - **Primary button** (filled) — changes by state: **"Start"** → then
    **"Open Next (4 left)"** in manual mode → **"Restart"** when done.

**Homepage buttons list:**
1. Settings (gear icon) → opens Settings screen
2. Clear queue (trash icon)
3. Target app card (tap → app picker)
4. Per-file: Remove (✕) + Drag handle
5. Pick PDFs
6. Start / Open Next / Restart (primary)

## Screen 2 — Settings

**Purpose:** how files are handed off and how the queue advances. (Currently
these live inline on the home screen; moving them to Settings cleans up the
homepage.)

**Layout top → bottom:**
- **App bar:** "Settings" + back arrow.
- **Target app section:** same selectable app row (icon + name), "Change app"
  affordance, opens the app-picker sheet.
- **Handoff mode** — segmented control / two-option selector:
  - **"Open with"** (recommended) — opens the file directly in the app.
  - **"Share"** — sends the file to the app. Show a small caption under it:
    *"Share can't confirm the file was delivered — Open with is more reliable
    when supported."*
- **Advance mode** — segmented control:
  - **"Auto"** — next file opens when you return to the app.
  - **"Manual"** — you tap "Open Next" each time.
- **Info banner** (when Auto selected): *"After each file opens, switch back to
  this app and the next one opens automatically. Android can't do this fully
  hands-free."*

**Settings buttons list:**
1. Back arrow
2. Target app row (tap → app picker)
3. Handoff toggle: Open with / Share
4. Advance toggle: Auto / Manual

## Shared component — App Picker (bottom sheet)

A modal sheet titled "Choose target app", listing every installed app that can
open or receive a PDF, each as a row with the app's real icon + name. Tapping a
row selects it and closes the sheet.

---

# Logo Prompts (for Gemini)

## Concept: "Many → One" funnel

The app's whole idea is taking a **stack of files** and feeding them **one at a
time into a single app**. So the logo should show *multiple documents converging
into one point* — that's the unique, instantly-readable metaphor.

**Core image:** three or four overlapping PDF pages (fanned like a deck) on the
left, flowing rightward through a funnel / into a single arrow that points into
an app square. Indigo accent, rounded, modern app-icon style.

### Main prompt (copy-paste)

> A modern, minimalist mobile app icon for an app called "MultiFileOpener."
> Concept: several overlapping document/PDF pages on the left fanning out like a
> stack, converging and funneling into a single forward-pointing arrow on the
> right — symbolizing many files flowing one-by-one into one app. Flat vector
> style, Material 3 design language, rounded squircle icon shape, deep indigo
> (#3F51B5) and white with a soft purple gradient, subtle depth, clean negative
> space, no text, centered, crisp edges, app store quality. Solid light
> background.

### Variations to try

- **Funnel version:** *"…a wide funnel at the top receiving multiple sheets of
  paper, narrowing to release a single page at the bottom…"* — the clearest
  "batch in, one out" read.
- **Play-button version:** *"…a stack of PDF pages with a small play/triangle
  button overlapping the corner…"* — emphasizes the auto-open/sequential action.
- **Door/arrow version:** *"…multiple file icons sliding through a single open
  doorway…"* — emphasizes "into the app you choose."

### Tips for Gemini

- Add *"flat icon, no text, single centered subject, simple background"* if it
  over-decorates.
- Ask for *"a 1:1 square app icon"* so it returns the right aspect ratio.
- Match the indigo (#3F51B5) so the logo lines up with the app's existing indigo
  theme.
