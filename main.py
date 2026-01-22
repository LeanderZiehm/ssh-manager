# ssh_key_registry.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, constr
from typing import List
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker
from datetime import datetime

DATABASE_URL = "sqlite:///ssh_keys.db"

# SQLAlchemy setup
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(bind=engine, autoflush=False)
Base = declarative_base()

# DB model
class SSHKeyRequest(Base):
    __tablename__ = "ssh_key_requests"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String, nullable=False)
    public_key = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

Base.metadata.create_all(bind=engine)

# Pydantic models
class SSHKeyCreate(BaseModel):
    name: constr(min_length=1)
    description: constr(min_length=1)
    public_key: constr(min_length=50)  # naive minimum length check

class SSHKeyOut(BaseModel):
    id: int
    name: str
    description: str
    public_key: str
    created_at: datetime

app = FastAPI(title="SSH Key Registration")

@app.post("/register", response_model=SSHKeyOut)
def register_key(key_data: SSHKeyCreate):
    """
    Register a new SSH key. Human must approve later.
    """
    db = SessionLocal()
    # Optional: check for duplicates
    existing = db.query(SSHKeyRequest).filter(SSHKeyRequest.public_key == key_data.public_key).first()
    if existing:
        db.close()
        raise HTTPException(status_code=400, detail="Key already registered")
    
    new_key = SSHKeyRequest(
        name=key_data.name,
        description=key_data.description,
        public_key=key_data.public_key
    )
    db.add(new_key)
    db.commit()
    db.refresh(new_key)
    db.close()
    return new_key

@app.get("/keys", response_model=List[SSHKeyOut])
def list_keys():
    """
    List all registered SSH keys.
    """
    db = SessionLocal()
    keys = db.query(SSHKeyRequest).order_by(SSHKeyRequest.created_at.desc()).all()
    db.close()
    return keys

@app.get("/keys/{key_id}", response_model=SSHKeyOut)
def get_key(key_id: int):
    """
    Retrieve a single key by ID.
    """
    db = SessionLocal()
    key = db.query(SSHKeyRequest).filter(SSHKeyRequest.id == key_id).first()
    db.close()
    if not key:
        raise HTTPException(status_code=404, detail="Key not found")
    return key

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("ssh_key_registry:app", host="0.0.0.0", port=8000, reload=True)
