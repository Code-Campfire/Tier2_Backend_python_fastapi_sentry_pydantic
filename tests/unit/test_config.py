import os
import pytest
from app.core.config import Settings

def test_settings_default_values():
    """Test that settings have proper default values"""
    # Clear environment variables that might affect the test
    if "PROJECT_NAME" in os.environ:
        del os.environ["PROJECT_NAME"]
    if "API_VERSION" in os.environ:
        del os.environ["API_VERSION"]
    if "DEBUG" in os.environ:
        del os.environ["DEBUG"]
        
    settings = Settings()
    assert settings.PROJECT_NAME == "FastAPI Sentry Pydantic"
    assert settings.VERSION == "0.1.0"
    assert settings.API_VERSION == "v1"
    assert settings.DEBUG is False
    assert "localhost" in settings.ALLOWED_HOSTS
    assert "127.0.0.1" in settings.ALLOWED_HOSTS
    assert settings.SENTRY_TRACES_SAMPLE_RATE == 1.0

def test_settings_env_override():
    """Test that environment variables override default settings"""
    os.environ["PROJECT_NAME"] = "Test Project"
    os.environ["DEBUG"] = "true"
    os.environ["ALLOWED_HOSTS"] = "test.com,api.test.com"
    
    settings = Settings()
    assert settings.PROJECT_NAME == "Test Project"
    assert settings.DEBUG is True
    assert settings.ALLOWED_HOSTS == ["test.com", "api.test.com"]
    
    # Clean up environment variables
    del os.environ["PROJECT_NAME"]
    del os.environ["DEBUG"]
    del os.environ["ALLOWED_HOSTS"]

def test_secret_key_generation():
    """Test that SECRET_KEY is auto-generated if empty"""
    # Test with empty secret key
    os.environ["SECRET_KEY"] = ""
    settings1 = Settings()
    assert settings1.SECRET_KEY is not None
    assert len(settings1.SECRET_KEY) > 30
    
    # Test with provided secret key
    os.environ["SECRET_KEY"] = "test-secret-key"
    settings2 = Settings()
    assert settings2.SECRET_KEY == "test-secret-key"
    
    # Clean up
    del os.environ["SECRET_KEY"]
    
def test_list_field_parsing():
    """Test that comma-separated strings are converted to lists"""
    os.environ["ALLOWED_HOSTS"] = "test1.com,test2.com,test3.com"
    os.environ["CORS_ORIGINS"] = "http://test1.com,http://test2.com"
    
    settings = Settings()
    assert settings.ALLOWED_HOSTS == ["test1.com", "test2.com", "test3.com"]
    assert settings.CORS_ORIGINS == ["http://test1.com", "http://test2.com"]
    
    # Clean up
    del os.environ["ALLOWED_HOSTS"]
    del os.environ["CORS_ORIGINS"] 