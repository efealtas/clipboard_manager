# Clipboard Manager

An offline, cross-platform clipboard manager desktop app built with Flutter Desktop. The app automatically logs copied text snippets, allows searching and tagging, and saves data locally using SQLite. It features a clean and responsive UI with dark and light themes that persist across app launches.

---

## Features

- **Clipboard History Tracking:** Automatically records every copied text entry.
- **Searchable History:** Quickly find previous clipboard items with fuzzy search.
- **Tagging & Pinning:** Organize clipboard entries with tags and pin favorites to avoid deletion.
- **Persistent Local Storage:** All clipboard data is saved locally in a SQLite database for offline access.
- **Theme Switcher:** Toggle between dark and light mode with your preference saved and applied on app launch.
- **Auto Cleanup:** Optional removal of old clipboard entries after a configurable period.
- **System Tray Support:** Minimize app to system tray and access it quickly with a hotkey.

---

## Screenshots

_Add screenshots here showing light and dark mode UI, search, and tagging features._

![Screenshot 2025-06-19 at 2.36.11 PM.png](../../../../var/folders/fr/rh9yy3wn0vl7tt565qrbh2180000gn/T/TemporaryItems/NSIRD_screencaptureui_EEuaih/Screenshot%202025-06-19%20at%202.36.11%E2%80%AFPM.png)

### How It Works

The app listens for clipboard changes and saves new text snippets to a local SQLite database. 
The UI allows users to view their clipboard history, search entries. 
The theme toggle button switches the app between dark and light modes, saving the preference locally so that the chosen theme is applied every time the app launches.
