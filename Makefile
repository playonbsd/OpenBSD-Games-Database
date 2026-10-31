HTML_SPLIT =	[:punct:] [:digit:] Aa Bb Cc Dd Ee Ff Gg Hh Ii Jj Kk Ll Mm Nn Oo Pp Qq Rr Ss Tt Uu Vv Ww Xx Yy Zz

all: csv html json stats

.PHONY: check csv diff html json print-csv print-html print-json print-stats stats

check:
	@echo "Checking if all Id's are unique (compare that count is same)..."
	@if [[ $$(grep -E '^Id[[:blank:]]' openbsd-games.db | wc -l) -gt \
		$$(grep -E '^Id[[:blank:]]' openbsd-games.db | sort | uniq | wc -l) ]] ; then \
		echo "\tPlease fix: Non-unique Id lines identified."; \
	fi
	@echo "Checking for trailing whitespace..."
	@if $$(grep -Eq '[[:space:]]$$' openbsd-games.db); then \
		echo "\tPlease fix: trailing whitespace found in openbsd-games.db"; \
	fi
	@echo "Checking for proper tab separation between key and value..."
	@if $$(grep -Eq "^[[:print:]]+\t* " openbsd-games.db); then \
		echo "\tPlease fix: key-value separation must be only TAB, not space"; \
	fi

csv:
	tools/gen_csv.pl openbsd-games.db > openbsd-games.csv

print-csv:
	tools/gen_csv.pl openbsd-games.db

html:
	#skip full table for size reasons; consumers can put it together from the rest
	#tools/gen_html_table.pl openbsd-games.db > html-tables/full.txt
	tools/gen_html_table.pl -h openbsd-games.db > html-tables/header.txt
.for split in ${HTML_SPLIT}
	tools/gen_html_table.pl -s '^[${split}]' openbsd-games.db > html-tables/${split:C/[[:punct:]]//g}.txt
.endfor

print-html:
	tools/gen_html_table.pl openbsd-games.db

json:
	#single-line openbsd-games.json updates blow up repo size
	#tools/gen_json.pl openbsd-games.db > openbsd-games.json
	tools/gen_json.pl openbsd-games.db | jq '.' \
		> openbsd-games-formatted.json

print-json:
	@tools/gen_json.pl openbsd-games.db | jq -C '.'

stats:
	#single-line summary-stats.json updates blow up repo size
	#stats/gen_stats.pl openbsd-games.db > stats/summary-stats.json
	stats/gen_stats.pl openbsd-games.db | jq '.' \
		> stats/summary-stats-formatted.json

print-stats:
	@stats/gen_stats.pl openbsd-games.db | jq -C '.'

diff:
	@git diff -- . ':(exclude)openbsd-games.json' ':(exclude)stats/summary-stats.json'
