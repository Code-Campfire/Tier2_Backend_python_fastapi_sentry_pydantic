# Tier 2 Backend - FastAPI with Sentry and Pydantic

This is a starter template for a FastAPI backend with Sentry for error tracking, Pydantic for data validation, and Poetry for dependency management.

## Technologies Used

- [FastAPI](https://fastapi.tiangolo.com/) - Modern, high-performance web framework
- [Pydantic](https://docs.pydantic.dev/) - Data validation and settings management
- [Sentry](https://sentry.io/) - Error tracking and performance monitoring
- [Poetry](https://python-poetry.org/) - Dependency management
- [Pytest](https://docs.pytest.org/) - Testing framework
- [Python-dotenv](https://github.com/theskumar/python-dotenv) - Environment variable management

## Getting Started

### Prerequisites

- Python 3.9 or higher (fully compatible with Python 3.13+)
- Poetry (will be installed by the setup script if not present)

### Installation

1. Clone the repository

2. Run the appropriate setup script from the project root:

   **For Mac/Linux:**
   ```
   # Run from the project root
   sh scripts/setup-mac.sh
   ```

   **For Windows:**
   ```
   # Run from the project root
   scripts\setup-windows.bat
   ```

   This will:
   - Check if you have Python 3.9+ installed (and provide download link if needed)
   - Check if Poetry is installed and install it if needed
   - Create a virtual environment
   - Install all dependencies
   - Create a .env file from the template
   - Run tests
   - Start and stop the app to verify it works

3. Alternatively, you can set up the project manually with Poetry:

   ```
   # Make sure you're in the project root directory
   
   # Install dependencies with Poetry
   poetry install

   # Create .env file
   cp .env_sample.txt .env
   ```

### Development

Run the development server:

```
poetry run uvicorn app.main:app --reload
```

The API will be available at http://localhost:8000/api/v1/
The API documentation will be available at http://localhost:8000/docs/

### Running Tests

```
poetry run pytest
```

To run tests with coverage:

```
poetry run pytest --cov=.
```

## Project Structure

```
/
├── app/                    # Main application package
│   ├── api/                # API endpoints
│   │   └── v1/             # API version 1
│   │       └── endpoints/  # API endpoint modules
│   ├── core/               # Core application code
│   │   └── config.py       # Application settings
│   ├── models/             # Pydantic models
│   └── main.py             # Application entry point
├── scripts/                # Setup scripts
├── tests/                  # Test files
│   ├── api/                # API tests
│   └── unit/               # Unit tests
├── .env                    # Environment variables (created from .env_sample.txt)
├── .env_sample.txt         # Sample environment variables
├── pyproject.toml          # Poetry configuration
└── README.md               # Project documentation
```

## API Endpoints

### Health Check

- `/api/health` - Health check endpoint (GET, no authentication required)

### User Management

- `/api/v1/users/` - List all users (GET)
- `/api/v1/users/{user_id}` - Retrieve a specific user (GET)

## Environment Variables

Copy `.env_sample.txt` to `.env` and adjust the values:

```
DEBUG=True
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1
API_VERSION=v1
SENTRY_DSN=your-sentry-dsn-here
SENTRY_TRACES_SAMPLE_RATE=1.0
CORS_ORIGINS=http://localhost:3000,http://localhost:8000
```

## Running in Production

1. Set `DEBUG=False` in `.env`
2. Generate a new secure `SECRET_KEY`
3. Update `ALLOWED_HOSTS` with your domain
4. Set a valid `SENTRY_DSN` for error tracking
5. Configure a web server like Nginx and use Gunicorn or Uvicorn workers for production

## Logging

Logs are written to the console and to `app.log` in the project root. The logging configuration can be adjusted in `app/main.py`. 