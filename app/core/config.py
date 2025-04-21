import os
import secrets
from typing import List, Optional
from dotenv import load_dotenv

# Load .env file
load_dotenv()

class Settings:
    """Application settings"""
    
    def __init__(self):
        """Initialize settings from environment variables"""
        # Project settings
        self.PROJECT_NAME = self._get_str("PROJECT_NAME", "FastAPI Sentry Pydantic")
        self.VERSION = self._get_str("VERSION", "0.1.0")
        self.API_VERSION = self._get_str("API_VERSION", "v1")
        
        # Security settings
        self.SECRET_KEY = self._get_str("SECRET_KEY")
        if not self.SECRET_KEY:
            self.SECRET_KEY = secrets.token_urlsafe(32)
        
        self.DEBUG = self._get_bool("DEBUG", False)
        self.ALLOWED_HOSTS = self._get_list("ALLOWED_HOSTS", ["localhost", "127.0.0.1"])
        
        # Sentry settings
        self.SENTRY_DSN = self._get_str("SENTRY_DSN")
        self.SENTRY_TRACES_SAMPLE_RATE = self._get_float("SENTRY_TRACES_SAMPLE_RATE", 1.0)
        
        # CORS settings
        self.CORS_ORIGINS = self._get_list("CORS_ORIGINS", ["http://localhost:3000", "http://localhost:8000"])
    
    def _get_str(self, key: str, default: str = "") -> str:
        """Get a string from environment variables"""
        return os.environ.get(key, default)

    def _get_bool(self, key: str, default: bool = False) -> bool:
        """Get a boolean from environment variables"""
        value = os.environ.get(key, str(default)).lower()
        return value in ("1", "true", "t", "yes", "y", "on")

    def _get_list(self, key: str, default: List[str] = None) -> List[str]:
        """Get a list from comma-separated environment variables"""
        if default is None:
            default = []
        value = os.environ.get(key)
        if not value:
            return default
        return [item.strip() for item in value.split(",")]

    def _get_float(self, key: str, default: float = 0.0) -> float:
        """Get a float from environment variables"""
        value = os.environ.get(key, str(default))
        try:
            return float(value)
        except ValueError:
            return default

# Create settings instance
settings = Settings() 