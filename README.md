# OpenBSD-Games-Database

Repository of the database of (initially primarily commercial/proprietary) games that run on OpenBSD.

## How to Use

Note: This may be subject to change in the future, so be sure to check regularly for updates to this README.md before working on the repository.

At this point, the primary database is a text file `openbsd-games.db`. See below for its required format. Other output like `openbsd-games.json` is created from `openbsd-games.db` at this point, using make(1).

To update the generated files after editing `openbsd-games.db`:

```
$ make
```

This runs targets *json* and *stats*.

Other make(1) targets:

* print-json
* print-stats

## Dependencies

The following is needed to run the make(1) targets:

* Perl 5.36
* [Perl JSON module](https://metacpan.org/pod/JSON)
* [jq](https://jqlang.github.io/jq/)

## Upcoming Changes

The following fields are **deprecated** and **will soon be removed - adjust your scripts!**

* `Cover`

The following parts will soon be changed:

* `Setup` will be renamed (likely to `Helper` or `Assistant`). It will be changed to a list and any custom setup instructions will be moved to `Hints`.
* `Dev` will be expanded to `Developer` and `Pub` to `Publisher`
* A new field `Id` for the sorting logic will be added, to drop the leading article.
* Need for alphabetical orderin `openbsd-games.db` will be removed (scripts/users need to sort by `Id` once implemented).

## Format of openbsd-games.db

**Important Notes**:

* TABS are currently **mandatory** where listed below!!
* Entries are ordered alphabetically (by `Game<TAB>Name`)

Currently **17** lines per entry, **in the following order**:

1. *Game*: string, leading "A " or "The " treated specially for alphabetic ordering. **This line signals a new entry has started.**
2. *Cover*: path to cover art image file (`.png`, `.jpg`)
3. *Engine*: string of valid engine entry
4. *Setup*: string (package, command, text)
5. *Runtime*: string; should correspond to an executable in packages
6. *Store*: strings of URLs, whitespace-separated
7. *Hints*: string
8. *Genre*: strings, comma-separated
9. *Tags*: strings, comma-separated
10. *Year*: integer (release year)
11. *Dev*: string (developer), comma-separated
12. *Pub*: string (publisher), comma-separated
13. *Version*: version number/string
14. *Status*: numerical status with date when tested on -current in parentheses (doesn't apply to upstream bugs that have nothing to do with the OpenBSD platform); note highest numerical description reached applies
 * 0 = doesn't run
 * 1 = game launches (not enough information to comment meaningfully on status beyond launching the game)
 * 2 = major bugs: potentially game-breaking, making finishing the game impossible or a chore; noticeably degrading the enjoyment compared to running the game on other platforms
 * 3 = medium-impact bugs: noticeable, but not game-breaking
 * 4 = minor bugs: barely noticeable, or not relevant to core game
 * 5 = completable: game can be played through until the credits roll, without major bugs (category 2); doesn't (necessarily) include optional side content, DLC, optional multiplayer, achievements etc.
 * 6 = 100%: the complete game including optional content like DLC, side quests, multiplayer can be enjoyed
15. *Added*: date (ISO 8601 format) when the entry was added (EPOCH when the information is not available)
16. *Updated*: date (ISO 8601 format) when the entry was last updated
17. *IgdbId*: id of the game in the [IGDB](https://www.igdb.com) database 

...

## Exports

Planned:
- [x] json
- [x] csv
- [ ] html table
- [ ] text table
- [ ] gemini/gemtext export

## Future Directions

- [ ] switch to sqlite3 as primary database
- [ ] web interface to rearrange the table data interactively (e.g. Shiny Web App)
- [ ] publish updated releases for easy integration and consumption
- [x] license decision
- [ ] script/form to assist in adding/editing entries
