all: json stats

.PHONY: json stats print-json print-stats
json:
	tools/gen_json.pl openbsd-games.db > openbsd-games.json

print-json:
	@tools/gen_json.pl openbsd-games.db | jq -C '.'

stats:
	stats/gen_stats.pl openbsd-games.db > stats/summary-stats.json

print-stats:
	@stats/gen_stats.pl openbsd-games.db | jq -C '.'
