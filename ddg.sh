#!/bin/bash

API_KEY="YOUR_API_KEY_HERE"
HISTORY_PATH="$HOME/.local/share/ddg"
LOG_FILE="$HISTORY_PATH/aliases_history.txt"

# Ensure the history directory exists
mkdir -p "$HISTORY_PATH"

generate_alias() {
    RESPONSE=$(curl -s -X POST \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d '{}' \
        https://quack.duckduckgo.com/api/email/addresses)

    ALIAS=$(echo "$RESPONSE" | grep -oP '(?<="address":")[^"]*')
    if [ -n "$ALIAS" ]; then
        FULL_ALIAS="$ALIAS@duck.com"
        TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$TIMESTAMP - $FULL_ALIAS" >> "$LOG_FILE"
        echo "Email alias generated: $FULL_ALIAS"
    else
        echo "Failed to generate alias. Response: $RESPONSE"
    fi
}

show_history() {
    if [ -f "$LOG_FILE" ]; then
        sed -n '/Generated 30 Aliases:/p; s/.* - //p; /^$/p' "$LOG_FILE"
    else
        echo "No aliases history found."
    fi
}

show_verbose_history() {
    if [ -f "$LOG_FILE" ]; then
        cat "$LOG_FILE"
    else
        echo "No aliases history found."
    fi
}

generate_all_aliases() {
    trap 'echo "" >> "$LOG_FILE"' INT
    echo -e "\nGenerated 30 Aliases:" >> "$LOG_FILE"
    for (( i=0; i < 30; i++ )); do
        generate_alias
    done
    echo "" >> "$LOG_FILE"
}

show_menu() {
    echo "Please choose an option:"
    echo "1 - Generate email alias"
    echo "2 - Show aliases history"
    echo "3 - Show verbose aliases history"
    echo "4 - Generate all aliases"

    read -p "Enter your choice (1 - 4): " choice
    case $choice in
        1)
            generate_alias
            ;;
        2)
            show_history
            ;;
        3)
            show_verbose_history
            ;;
        4)
            generate_all_aliases
            ;;
        *)
            echo "Invalid choice. Please run the script again and select a valid option."
            ;;
    esac
}

if [ -n "$1" ]; then
    case $1 in
        generate|1)
            generate_alias
            ;;
        history|2)
            show_history
            ;;
        verbose_history|3)
            show_verbose_history
            ;;
        generate_all|4)
            generate_all_aliases
            ;;
        *)
            echo "Usage: $0 [generate|history|verbose_history|generate_all]"
            ;;
    esac
else
    show_menu
fi
