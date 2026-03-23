#!/bin/bash

# Define the expected path to powershell.exe and keep_awake.ps1
# Using the full path avoids PATH issues in non-interactive SSH sessions.
POWERSHELL_PATH="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
KEEP_ALIVE_COMMAND="$POWERSHELL_PATH -NoProfile -ExecutionPolicy Bypass -File /home/paul/winsomnia-nopython/keep_awake.ps1"

cleanup() {
  if [ -n "$KEEP_ALIVE_PID" ]; then
    kill "$KEEP_ALIVE_PID" 2>/dev/null
  fi
}
trap cleanup EXIT

# Check if this is an SSH session
if [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ]; then
  echo "Not an SSH session, winsomnia-ssh functionality not needed."
else
  # It is an SSH session, construct the message and run keep_windows_awake in the background
  message="SSH session detected,"
  if [ -n "$SSH_CLIENT" ]; then
    message+=" SSH_CLIENT='$SSH_CLIENT'."
  fi
  if [ -n "$SSH_TTY" ]; then
    message+=" SSH_TTY='$SSH_TTY'."
  fi
  echo "$message"

  # Check if powershell.exe exists and is executable at the specific path
  if [ ! -x "$POWERSHELL_PATH" ]; then
    echo "Error: PowerShell not found or not executable at $POWERSHELL_PATH. Cannot keep Windows awake." >&2
  else
    $KEEP_ALIVE_COMMAND &> /dev/stdout &
    KEEP_ALIVE_PID=$!
    echo "Keeping Windows awake with PID $KEEP_ALIVE_PID"
  fi
fi
