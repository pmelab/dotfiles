#!/bin/bash

# Claude Code macOS Notification Hook
# Sends desktop notifications when Claude Code requires user attention

set -e

# Function to output JSON response
output_json() {
    local success="$1"
    local message="$2"
    local output="$3"
    
    cat << EOF
{
    "success": $success,
    "message": "$message",
    "output": "$output"
}
EOF
}

# Function to send macOS notification
send_notification() {
    local title="$1"
    local subtitle="$2"
    local message="$3"
    
    # Use terminal-notifier for more reliable notifications
    local cmd="terminal-notifier -title \"$title\" -message \"$message\""
    
    # Add subtitle if provided
    if [[ -n "$subtitle" ]]; then
        cmd="$cmd -subtitle \"$subtitle\""
    fi
    
    # Add sound to make it more noticeable
    cmd="$cmd -sound Ping"
    
    # Execute the notification and capture any errors
    local output
    output=$(eval "$cmd" 2>&1)
    local exit_code=$?
    
    # Return the exit code for error handling
    return $exit_code
}

# Get the notification context from Claude Code
# This will be passed via environment variables or command line arguments
NOTIFICATION_TYPE="${CLAUDE_NOTIFICATION_TYPE:-attention}"
NOTIFICATION_MESSAGE="${CLAUDE_NOTIFICATION_MESSAGE:-Claude Code requires your attention}"

# Check for Zellij session
ZELLIJ_SESSION=""
if [[ -n "$ZELLIJ_SESSION_NAME" ]]; then
    ZELLIJ_SESSION="Session: $ZELLIJ_SESSION_NAME"
fi

# Set notification content based on type
case "$NOTIFICATION_TYPE" in
    "permission")
        TITLE="Claude Code - Permission Required"
        MESSAGE="Claude Code is requesting permission to continue"
        ;;
    "idle")
        TITLE="Claude Code - Waiting"
        MESSAGE="Claude Code is waiting for your response"
        ;;
    "attention")
        TITLE="Claude Code"
        MESSAGE="$NOTIFICATION_MESSAGE"
        ;;
    *)
        TITLE="Claude Code"
        MESSAGE="$NOTIFICATION_MESSAGE"
        ;;
esac

# Send the notification
if send_notification "$TITLE" "$ZELLIJ_SESSION" "$MESSAGE"; then
    output_json true "Notification sent successfully" "macOS notification displayed"
else
    output_json false "Failed to send notification" "osascript command failed"
    exit 1
fi