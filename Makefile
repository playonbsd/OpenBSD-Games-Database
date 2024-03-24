.PHONY: stats

stats:
	stats/gen_stats.pl openbsd-games.db > stats/summary-stats.json
