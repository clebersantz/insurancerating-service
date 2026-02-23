# insurancerating-service

A minimal HTTP service that wraps the [`insurancerating`](https://github.com/MHaringa/insurancerating) R package using [`plumber`](https://www.rplumber.io/). It uses the package's built-in MTPL sample datasets so no extra data is required.

## Requirements

- [Docker](https://docs.docker.com/get-docker/)

## Quick start

```bash
# Build and start the service
docker compose up --build

# The API is now available at http://localhost:8080
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check – returns `{"status":"ok"}` |
| GET | `/univariate` | Univariate analysis on `MTPL2` segmented by area (frequency, severity, risk premium, loss ratio, average premium) |
| GET | `/fit_gam` | GAM-predicted claim frequency with 95% CI by policyholder age (`MTPL`) |
| POST | `/process_score` | Individual process score (predicted claim frequency) based on policyholder inputs |

### Example requests

```bash
curl http://localhost:8080/health
curl http://localhost:8080/univariate
curl http://localhost:8080/fit_gam
curl -X POST http://localhost:8080/process_score \
  -H "Content-Type: application/json" \
  -d '{"age_policyholder": 45, "power": 6, "bm": 10, "zip": 1, "exposure": 1}'
```
