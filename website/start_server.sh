#!/bin/bash

# ============================================================================
# EPPS Website - Simple HTTP Server Launcher
# ============================================================================

echo "======================================"
echo "  EPPS Analysis Report Website"
echo "  PT. Nirmala Satya Development"
echo "======================================"
echo ""

PORT=8000

# Check if port is already in use
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "⚠️  Port $PORT is already in use!"
    echo "Please close the other application or choose a different port."
    exit 1
fi

echo "🚀 Starting local web server..."
echo ""
echo "📍 Server will be available at:"
echo "   ➡️  http://localhost:$PORT"
echo "   ➡️  http://127.0.0.1:$PORT"
echo ""
echo "💡 Press Ctrl+C to stop the server"
echo ""
echo "======================================"
echo ""

# Try Python 3 first, then Python 2, then fallback
if command -v python3 &> /dev/null; then
    echo "✅ Using Python 3..."
    python3 -m http.server $PORT
elif command -v python &> /dev/null; then
    echo "✅ Using Python..."
    python -m SimpleHTTPServer $PORT
else
    echo "❌ Python not found!"
    echo ""
    echo "Please install Python or use one of these alternatives:"
    echo ""
    echo "1. Node.js http-server:"
    echo "   npm install -g http-server"
    echo "   http-server -p $PORT"
    echo ""
    echo "2. PHP built-in server:"
    echo "   php -S localhost:$PORT"
    echo ""
    echo "3. Open index.html directly in your browser"
    exit 1
fi
