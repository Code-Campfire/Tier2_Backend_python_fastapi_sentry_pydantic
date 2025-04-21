import logging
from fastapi import APIRouter, HTTPException, Depends, status
from typing import List
from datetime import datetime, UTC
from app.models.user import User

router = APIRouter()
logger = logging.getLogger(__name__)

# Current time for sample data
now = datetime.now(UTC)

# Sample users for demonstration
sample_users = [
    User(id=1, email="admin@example.com", full_name="Admin User", 
         is_active=True, is_superuser=True, created_at=now),
    User(id=2, email="user@example.com", full_name="Regular User", 
         is_active=True, is_superuser=False, created_at=now),
]

@router.get("/", response_model=List[User])
async def get_users():
    """
    Get all users.
    """
    logger.info("Retrieving all users")
    return sample_users

@router.get("/{user_id}", response_model=User)
async def get_user(user_id: int):
    """
    Get a specific user by ID.
    """
    logger.info(f"Retrieving user with ID: {user_id}")
    for user in sample_users:
        if user.id == user_id:
            return user
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail=f"User with ID {user_id} not found"
    ) 