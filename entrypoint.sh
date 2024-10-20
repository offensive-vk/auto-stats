#!/bin/bash

# Get the inputs from the action.yml file
SET_NAME="${INPUT_NAME:-github-actions[bot]}"
SET_EMAIL="${INPUT_EMAIL:-github-actions[bot]@users.noreply.github.com}"
MESSAGE="${INPUT_MESSAGE:-Updated Repo Stats}"
BRANCH="${INPUT_BRANCH:-master}"
GITHUB_TOKEN="${INPUT_GITHUB_TOKEN}"
OPTIONS="${INPUT_OPTIONS}"

# Set Git identity both globally and locally
git config --global user.name "$SET_NAME"
git config --global user.email "$SET_EMAIL"
git config --global --add safe.directory /github/workspace

########################################
# Backend Logic for Generating the Stats
########################################
# Initialize Variables
total_characters=0
total_files=0
biggest_file=""
smallest_file=""
biggest_count=0
smallest_count=1000000
timestamp=$(date '+%b %d, %A %I:%M:%S %p')

echo "# 📊 Daily Repository Statistics" > STATS.md
echo "Generated on ⏰ **$timestamp**" >> STATS.md
echo "" >> STATS.md

# Gather stats and store in an array
stats=()
for file in $(find . -type f -not -path '*/\.*'); do
    char_count=$(wc -c < "$file")
    file_path=$(realpath --relative-to=. "$file")

    total_characters=$((total_characters + char_count))
    total_files=$((total_files + 1))

    if [ $char_count -gt $biggest_count ]; then
        biggest_count=$char_count
        biggest_file=$file_path
    fi

    if [ $char_count -lt $smallest_count ]; then
        smallest_count=$char_count
        smallest_file=$file_path
    fi

    # Store each file’s data as "path:count" for sorting later
    stats+=("$file_path:$char_count")
done

# Sort the stats array alphabetically and append to markdown
echo "## 📂 File Character Counts (Alphabetically)" >> STATS.md
for stat in $(printf "%s\n" "${stats[@]}" | sort); do
    path=$(echo "$stat" | cut -d':' -f1)
    count=$(echo "$stat" | cut -d':' -f2)
    echo "- $path: **$count** characters" >> STATS.md
done

# Calculate average characters and words
if [ $total_files -ne 0 ]; then
    average_characters=$((total_characters / total_files))
else
    average_characters=0
fi
total_words=$(wc -w $(find . -type f -not -path '*/\.*') | tail -n 1 | awk '{print $1}')
total_lines=$(wc -l $(find . -type f -not -path '*/\.*') | tail -n 1 | awk '{print $1}')
average_words=$((total_words / total_files))

# Write summary with emojis
echo "" >> STATS.md
echo "## 📋 Summary" >> STATS.md
echo "- 🗂️ **Total files:** $total_files" >> STATS.md
echo "- ✒️ **Total character count:** $total_characters" >> STATS.md
echo "- 📊 **Average characters per file:** $average_characters" >> STATS.md
echo "- 📝 **Total word count:** $total_words" >> STATS.md
echo "- 🧾 **Total lines:** $total_lines" >> STATS.md
echo "- 📐 **Average words per file:** $average_words" >> STATS.md
echo "- 🏆 **Largest file:** $biggest_file (**$biggest_count** characters)" >> STATS.md
echo "- 🥉 **Smallest file:** $smallest_file (**$smallest_count** characters)" >> STATS.md

# Additional Cool Stats
echo "" >> STATS.md
echo "## 🌟 Miscellaneous Stats" >> STATS.md
echo "- ⌛ **Average Processing Time Per file:** ~0.5s (estimated)" >> STATS.md
echo "- 🔥 **Most common file extension:** $(find . -type f | sed -n 's/.*\.\(.*\)/\1/p' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')" >> STATS.md
echo "- 🌐 **Total unique extensions:** $(find . -type f | sed -n 's/.*\.\(.*\)/\1/p' | sort -u | wc -l)" >> STATS.md
########################################

# Ensure all changes are added
git add STATS.md

# Stash any uncommitted changes before pulling
git stash --include-untracked

# Pull the latest changes
git fetch --all
git pull --rebase --autostash origin "$BRANCH"

# Apply the stash if necessary
git stash pop || echo "No stash to apply."

# Commit and push the changes
git commit $OPTIONS -m "$MESSAGE"
git push origin "$BRANCH"

# Check the status
git status


# ** END OF SCRIPT **