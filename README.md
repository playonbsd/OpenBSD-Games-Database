# OpenBSD-Games-Database

Repository of the database of (initially primarily commercial/proprietary) games that run on OpenBSD.

## How to Use

Note: This may be subject to change in the future, so be sure to check regularly for updates to this README.md before working on the repository.

At this point, the primary database is a text file `openbsd-games.db`. See below for its required format.

## Format of openbsd-games.db

**Important Notes**:

* TABS are currently MANDATORY where listed below!!
* Entries are ordered alphabetically (by `Game<TAB>Name`)
* Currently **14** lines per entry, **in the following order**:
** Game
** Cover
** Engine
** Setup
** Runtime
** Store
** Hints
** Genre
** Tags
** Year
** Dev
** Pub
** Version
** Status

...

## Exports

Planned:
- [ ] json
- [ ] html table
- [ ] text table

## Future Directions

- [ ] switch to sqlite3 as primary database
- [ ] web interface to rearrange the table data interactively (e.g. Shiny Web App)
- [ ] publish updated releases for easy integration and consumption
- [ ] license decision
- [ ] script/form to assist in adding/editing entries
