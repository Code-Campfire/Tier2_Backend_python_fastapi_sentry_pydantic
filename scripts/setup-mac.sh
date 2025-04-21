#!/bin/bash

# Codefire FastAPI Setup Script for Mac/Linux
# Define color codes for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== Starting Codefire FastAPI Setup for Mac/Linux =====${NC}"

# Navigate to project root (regardless of where the script is run from)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"
echo -e "${BLUE}Working directory: $(pwd)${NC}"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python 3 is not installed. Please install Python 3 before proceeding.${NC}"
    echo -e "${YELLOW}Visit https://www.python.org/downloads/ to download and install Python 3.${NC}"
    
    # Try to open the download page if possible
    if command -v open &> /dev/null; then
        echo "Opening the Python download page in your browser..."
        open "https://www.python.org/downloads/"
    elif command -v xdg-open &> /dev/null; then
        echo "Opening the Python download page in your browser..."
        xdg-open "https://www.python.org/downloads/"
    fi
    
    exit 1
fi

# Check Python version
echo "✅ Checking Python version..."
python_version=$(python3 -c 'import sys; print("{}.{}.{}".format(sys.version_info.major, sys.version_info.minor, sys.version_info.micro))')
python_version_major=$(echo $python_version | cut -d. -f1)
python_version_minor=$(echo $python_version | cut -d. -f2)

if [ "$python_version_major" -lt 3 ] || ([ "$python_version_major" -eq 3 ] && [ "$python_version_minor" -lt 9 ]); then
    echo "❌ Python 3.9 or higher is required. You have Python $python_version."
    echo "Please install Python 3.9 or higher from https://www.python.org/downloads/"
    echo "Recommended: Install Python 3.13+ for best compatibility with all features."
    exit 1
else
    echo "✅ Python $python_version is installed. Continuing setup..."
fi

# Check if Poetry is installed
if ! command -v poetry &> /dev/null; then
    echo -e "${YELLOW}Poetry is not installed. Installing poetry...${NC}"
    curl -sSL https://install.python-poetry.org | python3 -
    
    # Add Poetry to PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    # Check if installation was successful
    if ! command -v poetry &> /dev/null; then
        echo -e "${RED}Failed to install Poetry. Please install it manually: https://python-poetry.org/docs/#installation${NC}"
        echo -e "${YELLOW}Alternatively, you can proceed with pip installation.${NC}"
        read -p "Continue with pip instead of Poetry? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        USE_PIP=true
    else
        echo -e "${GREEN}Poetry installed successfully!${NC}"
        USE_PIP=false
    fi
else
    echo -e "${GREEN}Poetry is already installed.${NC}"
    USE_PIP=false
fi

echo -e "${BLUE}===== Installing dependencies =====${NC}"
if [ "$USE_PIP" = true ]; then
    # Create a virtual environment with pip
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
else
    # Use Poetry for dependency management
    poetry install
fi

echo -e "${BLUE}===== Creating environment file =====${NC}"
if [ ! -f .env ]; then
    cp .env_sample.txt .env
    echo -e "${GREEN}.env file created from template${NC}"
else
    echo -e "${GREEN}.env file already exists, keeping it as is${NC}"
fi

echo -e "${BLUE}===== Running tests =====${NC}"
if [ "$USE_PIP" = true ]; then
    python -m pytest
    TEST_RESULT=$?
else
    poetry run pytest
    TEST_RESULT=$?
fi

if [ $TEST_RESULT -ne 0 ]; then
    echo -e "${RED}Tests failed. Please check the output above.${NC}"
    exit 1
else
    echo -e "${GREEN}Tests passed successfully!${NC}"
fi

echo -e "${BLUE}===== Testing the application setup =====${NC}"
echo "Attempting to start the app to test the setup..."

# Function to run a command with a timeout
run_with_timeout() {
    # Start the command in the background
    "$@" &
    PID=$!
    
    # Wait for the server to start (maximum 10 seconds)
    MAX_WAIT=10
    WAITED=0
    SERVER_RUNNING=false
    
    while [ $WAITED -lt $MAX_WAIT ]; do
        sleep 1
        WAITED=$((WAITED+1))
        
        # Check if the server is responding
        if curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
            SERVER_RUNNING=true
            break
        fi
    done
    
    # Check server status
    if [ "$SERVER_RUNNING" = true ]; then
        echo -e "${GREEN}Server started successfully!${NC}"
    else
        echo -e "${RED}Server failed to start properly within $MAX_WAIT seconds.${NC}"
    fi
    
    # Kill the process
    if kill -0 $PID 2>/dev/null; then
        echo -e "${BLUE}Stopping test server...${NC}"
        kill $PID 2>/dev/null || kill -9 $PID 2>/dev/null
        return 0
    fi
}

# Run server with our custom timeout function
if [ "$USE_PIP" = true ]; then
    run_with_timeout python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
else
    run_with_timeout poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000
fi

echo ""
echo -e "${GREEN}===== Setup Complete! =====${NC}"
if [ "$USE_PIP" = true ]; then
    echo -e "${YELLOW}To activate the virtual environment, use:${NC}"
    echo -e "  ${BLUE}source \"$(pwd)/venv/bin/activate\"${NC}  # On Mac/Linux"
    echo ""
    echo -e "${YELLOW}To run the development server, use:${NC}"
    echo -e "  ${BLUE}python -m uvicorn app.main:app --reload${NC}"
else
    echo -e "${YELLOW}To run the development server, use:${NC}"
    echo -e "  ${BLUE}poetry run uvicorn app.main:app --reload${NC}"
fi
echo -e "${YELLOW}This will start the development server at${NC} http://localhost:8000/"
echo ""
echo -e "${YELLOW}API will be available at${NC} http://localhost:8000/api/"
echo ""
echo -e "${YELLOW}API docs will be available at${NC} http://localhost:8000/docs/" 