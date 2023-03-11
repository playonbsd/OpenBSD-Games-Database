# OpenBSD-Games-Database

Repository of the database of (initially primarily commercial/proprietary) games that run on OpenBSD.

## How to Use

Note: This may be subject to change in the future, so be sure to check regularly for updates to this README.md before working on the repository.

At this point, the primary database is a text file `openbsd-games.db`. See below for its required format.

## Format of openbsd-games.db

**Important Notes**:

* TABS are currently MANDATORY where listed below!!
* Entries are ordered alphabetically (by `Game<TAB>Name`)

Currently **17** lines per entry, **in the following order**:

1. *Game*: string, leading "A " or "The " treated specially for alphabetic ordering
2. *Cover*: path to cover art image file (`.png`, `.jpg`)
3. *Engine*: string of valid engine entry
4. *Setup*: string (package, command, text)
5. *Runtime*: string; should correspond to an executable in packages
6. *Store*: strings of URLs, whitespace-separated
7. *Hints*: string
8. *Genre*: strings, comma-separated
9. *Tags*: strings, comma-separated
10. *Year*: integer (release year)
11. *Dev*: string (developer)
12. *Pub*: string (publisher)
13. *Version*: version number/string
14. *Status*: string of valid status with date when tested on -current in parentheses
15. *Added*: date (ISO 8601 format) when the entry was added (EPOCH when the information is not available)
16. *Updated*: date (ISO 8601 format) when the entry was last updated
17. *IgdbId*: id of the game in the [IGDB](https://www.igdb.com) database 

...

## Exports

Planned:
- [ ] json
- [ ] csv
- [ ] html table
- [ ] text table
- [ ] gemini/gemtext export

## Future Directions

- [ ] switch to sqlite3 as primary database
- [ ] web interface to rearrange the table data interactively (e.g. Shiny Web App)
- [ ] publish updated releases for easy integration and consumption
- [ ] license decision
- [ ] script/form to assist in adding/editing entries
