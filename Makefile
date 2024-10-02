all: csv json stats

.PHONY: check csv print-csv json stats print-json print-stats diff

check:
	echo "Checking if all Id's are unique..."
	grep -E "^Id[[:blank:]]" *.db | wc -l
	grep -E "^Id[[:blank:]]" *.db | sort | uniq | wc -l

csv:
	tools/gen_csv.pl openbsd-games.db > openbsd-games.csv

print-csv:
	tools/gen_csv.pl openbsd-games.db

json:
	tools/gen_json.pl openbsd-games.db > openbsd-games.json
	tools/gen_json.pl openbsd-games.db | jq '.' \
		> openbsd-games-formatted.json

print-json:
	@tools/gen_json.pl openbsd-games.db | jq -C '.'

stats:
	stats/gen_stats.pl openbsd-games.db > stats/summary-stats.json
	stats/gen_stats.pl openbsd-games.db | jq '.' \
		> stats/summary-stats-formatted.json

print-stats:
	@stats/gen_stats.pl openbsd-games.db | jq -C '.'

diff:
	@git diff -- . ':(exclude)openbsd-games.json' ':(exclude)stats/summary-stats.json'
