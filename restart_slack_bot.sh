#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Restarting Slack LLM Bot..."

# Kill any existing instances 
echo "Stopping existing bot instances..."
pkill -f "python.*slack_bot.py" || echo "No existing instances found."

# Wait briefly to ensure processes are terminated
sleep 2

# Check if any instances are still running
if pgrep -f "python.*slack_bot.py" > /dev/null; then
  echo "Warning: Some bot instances are still running!"
  ps aux | grep "python.*slack_bot.py" | grep -v grep
  echo "You may want to kill them manually before proceeding."
  read -p "Continue anyway? (y/n): " choice
  if [[ ! $choice =~ ^[Yy]$ ]]; then
    echo "Restart aborted."
    exit 1
  fi
fi

# Make sure environment variables are set
if [ -z "$SLACK_BOT_TOKEN" ] || [ -z "$SLACK_APP_TOKEN" ]; then
  echo "Error: Slack tokens not set"
  echo "Please set the following environment variables:"
  echo "  export SLACK_BOT_TOKEN=xoxb-your-token"
  echo "  export SLACK_APP_TOKEN=xapp-your-token"
  exit 1
fi

# Create logs directory if it doesn't exist
mkdir -p logs

# Clear the logs
echo "Clearing log files..."
> logs/slack_bot.log
> logs/slack_message_handler.log
> logs/slack_agent.log

# Activate virtual environment if it exists
if [ -d venv/bin ]; then
  echo "Activating virtual environment..."
  source venv/bin/activate
fi

# Start the Slack bot in the background
echo "Starting new bot instance..."
nohup python3 "$SCRIPT_DIR/slack_bot.py" > "$SCRIPT_DIR/logs/startup.log" 2>&1 &

# Give some feedback
echo "Bot started with PID: $!"
echo "To monitor logs: tail -f logs/slack_bot.log"
echo "Done!"