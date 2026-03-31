# Transaction Risk

Personal version of a real-time fraud scoring project built around a PyTorch model, a FastAPI service, and a PostgreSQL-backed feature pipeline.

## Quick Start

### Prerequisites
- Docker Desktop running
- Around 4 GB RAM available
- Around 5 GB free disk space
- Internet access to download the dataset

### 1. Clone the repo
```bash
git clone <your-repo-url>
cd Transaction-risk
```

### 2. Add the dataset
Download the Sparkov credit card fraud dataset:
- [Kaggle dataset](https://www.kaggle.com/datasets/kartik2112/fraud-detection)

Then place the CSV files in `sparkov_data/`:
```bash
mkdir -p sparkov_data
# copy the Sparkov CSV files here
```

### 3. Start the stack
```bash
./scripts/deploy_docker.sh
```

This will:
- build the Docker images
- start PostgreSQL and the API
- load the transaction dataset
- create database indexes

### 4. Train the model
```bash
docker-compose exec api python model/train.py
```

This creates:
- `models/fraud_model_v1.pt`
- `models/scaler.pkl`
- `models/thresholds.json`

### 5. Test the API
```bash
python tests/pretty_test.py
```

Or send a raw request:
```bash
curl -X POST http://localhost:8000/score \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "merchant_id": 1, "amount": 100.00}'
```

## Project Layout

```text
Transaction-risk/
├── db/
├── model/
├── models/
├── service/
├── tests/
├── worker/
├── docker-compose.yml
└── README.md
```

## Not Stored In Git

- trained model artifacts in `models/`
- downloaded CSV datasets
- local `.env` values

## Expected Results

After training, the project is intended to deliver:
- around 50% recall at 1% false positive rate
- around 30% precision at 1% review rate
- API latency around 50 to 100 ms
- throughput around 100 requests per second

## Troubleshooting

If model files are missing:
```bash
docker-compose exec api python model/train.py
```

If the database fails to come up cleanly:
```bash
docker-compose down
docker-compose up -d
```

If the API is not responding:
```bash
docker-compose logs api
```

## Docs

- `DOCKER_README.md` for Docker-first setup
- `models/README.md` for generated model files
