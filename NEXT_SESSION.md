# Next Session — Handoff (Stand 2026-06-11, Head 53a4cc8)

Kurzes Briefing für die nächste Arbeitssession (Codex / Claude / Mensch).

## Was zuletzt passiert ist

Zwei große Arbeitspakete, alles committed und verifiziert:

1. Warm-Theme-Migration (Creme/Blattgrün/Honig-Amber, Scanner-Look entfernt),
   Persistenz (`CollectionStore`, SharedPreferences), Catch-Reveal,
   Seen-Again-Mikro-Belohnung, 3 Mock-Szenen, echtes Dictionary,
   minimaler Review-Screen.
2. Session Summary (Finish session → Reward-Screen mit neu/bekannt-Split),
   Catch-Pop (easeOutBack), Doku- und Roadmap-Abgleich.

Details: `CHANGELOG.md`. Aktueller Fokus: `AGENTS.md` → "Current Product Focus".

## Zuerst tun (Pflicht)

```
flutter analyze
flutter test
```

Beides wurde zuletzt NICHT ausgeführt (kein Flutter SDK in der Agent-Sandbox).
Der Code wurde nur manuell + per Syntax-Checker geprüft. Etwaige Analyzer-
Findings oder Test-Fehler zuerst fixen, bevor neue Features entstehen.

## Danach, in dieser Reihenfolge

1. **Wort-Detail-Bottom-Sheet im Dictionary** — Wort (Indonesisch groß),
   Bedeutung, Kategorie, Spot-Infos. Schlicht halten (UI_SPEC §5).
2. **App-Icon / Branding** — Katze + AR-Ecken, warm, nicht kindisch.
3. **Catch-Moment weiter polieren** — nur subtile, performante Effekte.

Nicht bauen: Kamera, ML Kit, Cloud, Accounts, Spaced Repetition, Bottom-Nav.

## Nicht kaputt machen

- SharedPreferences-Keys `caughtIDs`, `seenCount`, `lastSeenAt` und die
  `CatchWord.id`-Werte (z. B. `cafe.coffee`) sind persistierte Daten —
  nie ohne Migration ändern.
- Warme Palette ist gelockt (`lib/app/app_theme.dart` = Quelle der Wahrheit,
  Doku in `DESIGN_SYSTEM.md`). Kein Indigo/Teal, kein Dark-HUD.
- Wörter speichern sofort beim Fang. Keine "Save"-Buttons einführen.
- Tests in `test/` nach Änderungen mitziehen.

## Architektur in 30 Sekunden

- `lib/app/` Theme + App-Shell · `lib/models/catch_word.dart` Wortmodell
- `lib/data/mock_catch_words.dart` Szenen + Icon-Mapping
- `lib/services/collection_store.dart` Persistenz (einzige Storage-Stelle)
- `lib/screens/` home, explore, session_summary, dictionary, review
- `lib/widgets/` catch_word_chip, collection_counter
- `lib/legacy/` alter Prototyp, nicht anfassen, nicht referenziert
