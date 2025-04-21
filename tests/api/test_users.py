from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_get_users():
    response = client.get("/api/v1/users")
    assert response.status_code == 200
    users = response.json()
    assert len(users) >= 2
    assert users[0]["email"] == "admin@example.com"
    assert users[1]["email"] == "user@example.com"

def test_get_user_exists():
    response = client.get("/api/v1/users/1")
    assert response.status_code == 200
    user = response.json()
    assert user["id"] == 1
    assert user["email"] == "admin@example.com"

def test_get_user_not_exists():
    response = client.get("/api/v1/users/999")
    assert response.status_code == 404
    assert response.json()["detail"] == "User with ID 999 not found"

def test_health_check():
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"} 