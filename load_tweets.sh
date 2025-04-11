#!/bin/sh

# list all of the files that will be loaded into the database
# for the first part of this assignment, we will only load a small test zip file with ~10000 tweets
# but we will write are code so that we can easily load an arbitrary number of files
files='
test-data.zip
'

echo 'load normalized'
for file in $files; do
    echo "Processing normalized file: $file"
    python3 load_tweets.py --db "postgresql://postgres:pass@localhost:6968/postgres" --inputs "$file"
done

echo 'load denormalized'
for file in $files; do
    echo "Processing denormalized file: $file"
    unzip -p "$file" | sed 's/\\u0000//g' | iconv -f utf-8 -t utf-8 -c | psql "postgresql://postgres:pass@localhost:6969" -c "COPY tweets_jsonb (data) FROM STDIN csv quote e'\x01' delimiter e'\x02';"
done

# Two common painpoints on assignment
# 1.) Looping over $files which only has a single file - makes next assignment easy
# 2.) by using a denormalized representaiton, we have no guarentees on data integrity (e.g. UNIQUE)
# and so it is very easy to add the same tweet twice into the database
# if you run the command twice
#
# docker compose exec -T pg_denormalized ./ run_tests.sh
#
# After you get denormalized working (^) comment it (lines 15-18 in this file) out so you dont add too much data breaking your test cases
#
# At some point - probs denormalized & is in a bad state - bring the db down and then `docker volume ls` `docker volume rm VOLUME_ID`
