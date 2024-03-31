all: csv json stats

.PHONY: csv print-csv json stats print-json print-stats

csv:
	tools/gen_csv.pl openbsd-games.db > openbsd-games.csv

print-csv:
	tools/gen_csv.pl openbsd-games.db | less

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
