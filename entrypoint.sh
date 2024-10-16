#!/bin/bash

# Get inputs from the action.yml file (via environment variables)
SET_NAME="${NAME}"
SET_EMAIL="${EMAIL}"
MESSAGE="${COMMIT_MESSAGE}"
BRANCH="${BRANCH:-master}"
GITHUB_TOKEN="${GITHUB_TOKEN}"
OPTIONS="${OPTIONS}"

# Initialize variables
total_characters=0
total_files=0
biggest_file=""
smallest_file=""
biggest_count=0
smallest_count=1000000
timestamp=$(date '+%b %d, %A %I:%M:%S %p')

# Create the STATS.md file
echo "# Daily Repository Statistics" > STATS.md
echo "Generated on $timestamp" >> STATS.md
echo "" >> STATS.md

# Iterate through all files (excluding hidden files and directories)
while IFS= read -r -d '' file; do
    char_count=$(wc -c < "$file")
    file_name=$(basename "$file")

    # Update totals
    total_characters=$((total_characters + char_count))
    total_files=$((total_files + 1))

    # Check for biggest and smallest files
    if (( char_count > biggest_count )); then
        biggest_count=$char_count
        biggest_file=$file_name
    fi

    if (( char_count < smallest_count )); then
        smallest_count=$char_count
        smallest_file=$file_name
    fi

    echo "$file_name: $char_count characters" >> STATS.md
done < <(find . -type f -not -path '*/\.*' -print0)

# Calculate average characters per file
average_characters=$(( total_files > 0 ? total_characters / total_files : 0 ))

# Count total words across all files
total_words=$(find . -type f -not -path '*/\.*' -exec cat {} + | wc -w)

# Ensure the GITHUB_TOKEN is available
export GITHUB_TOKEN="$GITHUB_TOKEN"

# Write summary to STATS.md
{
    echo ""
    echo "## Summary ⛽"
    echo "- Total files: $total_files"
    echo "- Total character count: $total_characters"
    echo "- Average characters per file: $average_characters"
    echo "- Largest file: $biggest_file ($biggest_count characters)"
    echo "- Smallest file: $smallest_file ($smallest_count characters)"
    echo "- Total word count: $total_words"
    echo "---"
    echo -e "# ✨✨✨"
} >> STATS.md

# Git configuration and commit changes
git config --local user.name "$SET_NAME"
git config --local user.email "$SET_EMAIL"

# Stage changes and commit if there are any
git add STATS.md
git fetch --all
git pull --rebase || exit 1  # Exit if pull fails

if git diff-index --quiet HEAD --; then
    echo "No changes to commit."
else
    git commit $OPTIONS -m "$MESSAGE"
    git push origin "$BRANCH"
fi

# Display Git status
git status
