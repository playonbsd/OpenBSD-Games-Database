all: stats

.PHONY: stats print-stats
stats:
	stats/gen_stats.pl openbsd-games.db > stats/summary-stats.json

print-stats:
	stats/gen_stats.pl openbsd-games.db | jq -C '.' | less -R
