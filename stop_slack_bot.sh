#!/bin/bash

echo "Stopping Slack LLM Bot..."

# Kill any existing instances of the bot
pkill -f "python.*slack_bot.py"

echo "All bot instances have been stopped."
