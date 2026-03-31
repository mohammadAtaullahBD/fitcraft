---
name: fastapi-backend
description: "Use this skill whenever FitCraft's Python FastAPI backend is being built, modified, or deployed. Triggers: any mention of backend, FastAPI, Railway.app, API endpoints, /scan, /try-on, or Python server code. Covers endpoint contracts, deployment, and CORS setup."
---

# FitCraft — FastAPI Backend

## What the Backend Does

The Flutter app calls the FastAPI backend for:

| Endpoint | Purpose |
|----------|---------|
| `POST /scan` | Receive photo, run ML Kit equivalent (or SMPL), return measurements |
| `POST /try-on` | Proxy to Replicate OOTDiffusion — keeps API key server-side |
| `GET /designs` | Fetch designs from Supabase |
| `POST /designs` | Upload new design (designer only) |
| `POST /orders` | Create an order |
| `GET /orders/{id}` | Get order status |
| `GET /designers/{id}/earnings` | Designer earnings summary |

> **Phase 1 shortcut:** The Flutter app calls Replicate directly via `ReplicateService`. Move this to the backend in Phase 2 to protect the API key.

---

## Project Structure

```
backend/
├── main.py
├── routers/
│   ├── scan.py
│   ├── tryon.py
│   ├── designs.py
│   ├── orders.py
│   └── designers.py
├── services/
│   ├── replicate_service.py
│   ├── supabase_service.py
│   └── measurement_service.py
├── models/
│   ├── request_models.py
│   └── response_models.py
├── core/
│   ├── config.py
│   └── auth.py
├── requirements.txt
└── Procfile               ← for Railway.app deployment
```

---

## main.py

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import scan, tryon, designs, orders, designers
from core.config import settings

app = FastAPI(
    title="FitCraft API",
    version="1.0.0",
    docs_url="/docs",        # Swagger UI at /docs
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],     # Restrict to app domains in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(scan.router,      prefix="/scan",      tags=["Scan"])
app.include_router(tryon.router,     prefix="/try-on",    tags=["Try-On"])
app.include_router(designs.router,   prefix="/designs",   tags=["Designs"])
app.include_router(orders.router,    prefix="/orders",    tags=["Orders"])
app.include_router(designers.router, prefix="/designers", tags=["Designers"])

@app.get("/health")
async def health():
    return {"status": "ok", "version": "1.0.0"}
```

---

## core/config.py

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    replicate_key: str
    supabase_url: str
    supabase_key: str
    firebase_project_id: str
    designer_commission_pct: float = 0.20   # 20% to designer

    class Config:
        env_file = ".env"

settings = Settings()
```

---

## Request/Response Models

```python
# models/request_models.py
from pydantic import BaseModel
from typing import Optional

class TryOnRequest(BaseModel):
    person_image_base64: str    # base64 encoded JPEG
    garment_image_base64: str
    category: str = "upper_body"  # 'upper_body' | 'lower_body' | 'dresses'

class CreateOrderRequest(BaseModel):
    customer_id: str
    design_id: str
    measurements: dict          # BodyMeasurements as JSON
    total_bdt: int

class UploadDesignRequest(BaseModel):
    designer_id: str
    name: str
    image_url: str              # Firebase Storage URL
    price_bdt: int
    category: str
    tags: list[str] = []

# models/response_models.py
class TryOnResponse(BaseModel):
    result_image_url: str
    prediction_id: str

class MeasurementsResponse(BaseModel):
    shoulder_width_cm: float
    hip_width_cm: float
    torso_length_cm: float
    estimated_height_cm: float
```

---

## Try-On Router (Proxies Replicate)

```python
# routers/tryon.py
import httpx
import asyncio
from fastapi import APIRouter, HTTPException
from models.request_models import TryOnRequest
from models.response_models import TryOnResponse
from core.config import settings

router = APIRouter()
REPLICATE_BASE = "https://api.replicate.com/v1"
MODEL = "levihsu/ootdiffusion"

@router.post("/", response_model=TryOnResponse)
async def try_on(request: TryOnRequest):
    headers = {
        "Authorization": f"Token {settings.replicate_key}",
        "Content-Type": "application/json",
    }
    payload = {
        "input": {
            "vton_img": f"data:image/jpeg;base64,{request.person_image_base64}",
            "garm_img": f"data:image/jpeg;base64,{request.garment_image_base64}",
            "category": request.category,
            "n_samples": 1,
            "n_steps": 20,
            "image_scale": 2.0,
            "seed": -1,
        }
    }

    async with httpx.AsyncClient(timeout=120.0) as client:
        # Create prediction
        create_resp = await client.post(
            f"{REPLICATE_BASE}/models/{MODEL}/predictions",
            headers=headers, json=payload
        )
        if create_resp.status_code != 201:
            raise HTTPException(500, f"Replicate error: {create_resp.text}")

        prediction_id = create_resp.json()["id"]

        # Poll until complete
        for _ in range(30):
            await asyncio.sleep(3)
            poll_resp = await client.get(
                f"{REPLICATE_BASE}/predictions/{prediction_id}",
                headers=headers
            )
            data = poll_resp.json()
            status = data["status"]

            if status == "succeeded":
                output = data["output"]
                url = output[0] if isinstance(output, list) else output
                return TryOnResponse(result_image_url=url, prediction_id=prediction_id)
            elif status in ("failed", "canceled"):
                raise HTTPException(500, f"Prediction {status}: {data.get('error')}")

    raise HTTPException(504, "Replicate timed out after 90 seconds")
```

---

## Designs Router

```python
# routers/designs.py
from fastapi import APIRouter, Query
from typing import Optional
from supabase import create_client
from core.config import settings

router = APIRouter()

def get_supabase():
    return create_client(settings.supabase_url, settings.supabase_key)

@router.get("/")
async def list_designs(category: Optional[str] = Query(None)):
    sb = get_supabase()
    query = sb.table("designs").select("*, users!designer_id(name)") \
              .eq("is_active", True).order("created_at", desc=True)
    if category and category != "all":
        query = query.eq("category", category)
    return query.execute().data

@router.post("/")
async def create_design(request: UploadDesignRequest):
    sb = get_supabase()
    result = sb.table("designs").insert({
        "designer_id": request.designer_id,
        "name": request.name,
        "image_url": request.image_url,
        "price_bdt": request.price_bdt,
        "category": request.category,
        "tags": request.tags,
    }).execute()
    return result.data[0]
```

---

## requirements.txt

```
fastapi==0.111.0
uvicorn==0.30.1
pydantic==2.7.1
pydantic-settings==2.3.0
httpx==0.27.0
supabase==2.4.6
python-multipart==0.0.9
python-dotenv==1.0.1
```

---

## Deployment: Railway.app

### Procfile
```
web: uvicorn main:app --host 0.0.0.0 --port $PORT
```

### Deploy Steps
1. Push backend folder to GitHub
2. Go to Railway.app → New Project → Deploy from GitHub
3. Select backend folder as root directory
4. Add environment variables in Railway dashboard (copy from `.env`)
5. Railway auto-detects Python and uses Procfile
6. Copy the Railway URL → update `AppConstants.apiBaseUrl` in Flutter

### Free Tier Limits (Railway Starter)
- 500 hours/month execution time
- Sleeps after 5 min inactivity (first request after sleep takes ~10s)
- 512MB RAM — sufficient for Phase 1
- Upgrade when traffic grows

### Alternative: Render.com
Same setup — `render.yaml` instead of `Procfile`:
```yaml
services:
  - type: web
    name: fitcraft-api
    env: python
    buildCommand: pip install -r requirements.txt
    startCommand: uvicorn main:app --host 0.0.0.0 --port $PORT
```

---

## Firebase Auth Verification (Backend Guard)

To protect designer-only endpoints:

```python
# core/auth.py
import firebase_admin
from firebase_admin import credentials, auth
from fastapi import HTTPException, Header

firebase_admin.initialize_app()  # uses GOOGLE_APPLICATION_CREDENTIALS env var

async def verify_firebase_token(authorization: str = Header(...)):
    try:
        token = authorization.replace("Bearer ", "")
        decoded = auth.verify_id_token(token)
        return decoded
    except Exception:
        raise HTTPException(401, "Invalid or expired Firebase token")
```

Use in routes: `user = Depends(verify_firebase_token)`

---

## API Base URL in Flutter

```dart
// core/utils/app_constants.dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',  // Android emulator → localhost
);
// For real device testing: use your machine's local IP (e.g. http://192.168.1.x:8000)
// For production: Railway URL (e.g. https://fitcraft-api.up.railway.app)
```
