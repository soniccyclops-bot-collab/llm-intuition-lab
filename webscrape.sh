#!/bin/bash
# Human-like web scraping tool with proper rate limiting
# Usage: ./webscrape.sh "search terms" or ./webscrape.sh "direct-url"

search_term="$1"

# Human-like delays (2-8 seconds between requests)
human_delay() {
    sleep_time=$((2 + RANDOM % 6))
    echo "[Pausing ${sleep_time}s to look human...]"
    sleep $sleep_time
}

# Rotate user agents to look more human
get_user_agent() {
    agents=(
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/121.0"
    )
    echo "${agents[$((RANDOM % ${#agents[@]}))]}"
}

if [[ "$search_term" =~ ^https?:// ]]; then
    # Direct URL provided
    echo "Fetching: $search_term"
    human_delay
    curl -s -A "$(get_user_agent)" \
         -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
         -H "Accept-Language: en-US,en;q=0.5" \
         -H "Accept-Encoding: gzip, deflate" \
         -H "Connection: keep-alive" \
         -H "Upgrade-Insecure-Requests: 1" \
         "$search_term" | \
        grep -oP '(?<=<title>).*?(?=</title>)|(?<=<h[1-6][^>]*>).*?(?=</h[1-6]>)|(?<=<p[^>]*>).*?(?=</p>)' | \
        head -20
else
    # Search via DuckDuckGo (no API needed)
    echo "Searching for: $search_term"
    search_url="https://duckduckgo.com/html/?q=$(echo "$search_term" | sed 's/ /+/g')"
    
    echo "[Making initial search request...]"
    human_delay
    
    curl -s -A "$(get_user_agent)" \
         -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
         -H "Accept-Language: en-US,en;q=0.5" \
         -H "Accept-Encoding: gzip, deflate" \
         -H "Connection: keep-alive" \
         -H "Upgrade-Insecure-Requests: 1" \
         "$search_url" | \
        grep -oP '(?<=<a rel="nofollow" href=")[^"]*' | \
        head -3 | \
        while read url; do
            echo "Found: $url"
            human_delay  # Wait before each follow-up request
            curl -s -A "$(get_user_agent)" \
                 -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
                 -H "Accept-Language: en-US,en;q=0.5" \
                 -H "Referer: https://duckduckgo.com/" \
                 "$url" | \
                grep -oP '(?<=<title>).*?(?=</title>)' | head -1
            echo "---"
        done
fi