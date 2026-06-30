## Overview

**Amazon Sales Pulse** is an end-to-end data analytics project that turns raw Amazon-style transaction data into a business-ready intelligence layer. It walks through the full analytics lifecycle — raw ingestion, data cleaning, exploratory analysis, SQL-driven business questions, visualization, and a live, interactive dashboard — using a single, reproducible dataset of orders spanning multiple years, product categories, and customer regions.

The project is built for analysts, founders, and decision-makers who need to answer real commercial questions: *Which categories drive the most profit? Which regions are under-served? How do discounts affect margins? When does demand peak?* Every notebook, query, and chart is tied to a measurable business outcome — not just a technical exercise.

At its core, the project demonstrates how a small, well-structured analytics stack (Python + SQL + Streamlit) can replace expensive BI tooling for early-stage teams while remaining recruiter- and portfolio-friendly: clear folder structure, reproducible scripts, documented queries, and a one-command dashboard.

---

## Features

### Core Features
- ✅ Cleaned, enriched dataset of Amazon-style sales orders (50K+ rows)
- ✅ End-to-end pipeline: **Raw → Cleaned → EDA → Visualized → Dashboarded**
- ✅ Reproducible Jupyter notebooks for cleaning, EDA, and visualization
- ✅ 30+ business SQL queries answering real commercial questions
- ✅ Interactive Streamlit dashboard with KPIs, filters, and exports

### Analyst Features
- ✅ Auto-detection of date, category, region, revenue, and profit columns
- ✅ Sidebar filters: date range, category, region, payment method
- ✅ Revenue trend, category mix, correlation heatmap, top performers
- ✅ Geographic revenue distribution and discount-band impact analysis
- ✅ One-click CSV export of filtered data and generated insights

### Advanced Features
- ✅ Profit-margin and discount-band engineered features
- ✅ Time-based features: year, month, quarter, day-of-week
- ✅ Rating tiers (Poor / Average / Good / Excellent) for sentiment cuts
- ✅ Dataset-agnostic dashboard — upload any compatible CSV and explore

### Data Quality & Security Features
- ✅ Null-handling, type-coercion, and duplicate-removal pipeline
- ✅ Schema validation before queries run
- ✅ No personally identifiable customer data stored
- ✅ Read-only analytics layer — source files never mutated in place

---

## Tech Stack

### Frontend / Dashboard
- **Streamlit** — interactive UI for KPIs, filters, and downloads
- **Matplotlib** & **Seaborn** — statistical visualizations
- **HTML/CSS** (via Streamlit theming) for layout polish

### Backend / Processing
- **Python 3.10+**
- **Pandas**, **NumPy** — data wrangling and feature engineering
- **Jupyter Notebooks** — exploratory analysis

### Database
- **MySQL / PostgreSQL** — for running the business query suite
- **SQLite** — optional local mode for quick reproduction

### Data Analytics
- **Pandas profiling** for EDA
- **Seaborn** for statistical plots
- **Custom SQL** for business questions

### DevOps & Deployment
- **Streamlit Community Cloud** / **Render** / **Railway** for hosting
- **GitHub Actions** (optional) for lint + notebook execution checks
- **Docker** (optional) for reproducible runs

### Development Tools
- **VS Code**, **JupyterLab**
- **Git** & **GitHub**
- **Black** + **Ruff** for Python formatting and linting

---

## Architecture

```
                ┌────────────────────┐
                │   Raw_Data.csv     │
                └─────────┬──────────┘
                          │ ingest
                          ▼
              ┌────────────────────────┐
              │  Data_Cleaning.ipynb   │
              │  Data_Cleaning.sql     │
              └─────────┬──────────────┘
                        │ cleaned + enriched
                        ▼
              ┌────────────────────────┐
              │   Cleaned_Data.csv     │◄──────────┐
              └─────────┬──────────────┘           │
                        │                          │
        ┌───────────────┼──────────────────┐       │
        ▼               ▼                  ▼       │
   EDA.ipynb     Business_Queries.sql  Dashboard.py│
   (insights)    (SQL analytics)       (Streamlit) │
        │               │                  │       │
        └───────┬───────┴──────────────────┘       │
                ▼                                  │
        Reports · KPIs · Charts · CSV Export ──────┘
```

- **System Architecture:** Layered — Storage (CSV/SQL) → Processing (Python/SQL) → Presentation (Streamlit).
- **Application Flow:** User opens dashboard → filters applied → Pandas re-aggregates → charts re-render → optional CSV export.
- **Client–Server Communication:** Streamlit runs a Python server; the browser receives server-rendered components over WebSocket.
- **Database Relationships:** Single fact table (`orders`) with derived dimension views (category, region, time, discount band).

---

## Project Structure

```
amazon-sales-pulse/
│
├── Data-Analytics-Project/
│   ├── Dataset/
│   │   ├── Raw_Data.csv             # Original Amazon-style transactions
│   │   └── Cleaned_Data.csv         # Cleaned + feature-engineered dataset
│   │
│   ├── Python/
│   │   ├── Data_Cleaning.ipynb      # Null handling, typing, dedup
│   │   ├── EDA.ipynb                # Exploratory data analysis
│   │   ├── Data_Visualization.ipynb # Static visual storytelling
│   │   └── Dashboard.py             # Streamlit interactive dashboard
│   │
│   └── SQL/
│       ├── Data_Cleaning.sql        # SQL-side cleanup mirror
│       ├── EDA.sql                  # Quick profiling queries
│       └── Business_Queries.sql     # 30+ commercial questions answered in SQL
│
├── docs/
│   └── screenshots/                 # Dashboard screenshots used in README
│
├── requirements.txt                 # Python dependencies
├── .env.example                     # Sample environment variables
├── LICENSE
└── README.md
```

**Folder guide**
- `Dataset/` — versioned source of truth (raw + cleaned).
- `Python/` — all notebooks and the Streamlit app.
- `SQL/` — portable, database-agnostic analytics queries.
- `docs/` — supporting assets (screenshots, diagrams).

---

## Installation

### Prerequisites
- **Python 3.10+**
- **pip** (or `uv` / `poetry`)
- **MySQL** or **PostgreSQL** (optional — only if you want to run SQL files)
- **Git**

### 1. Clone the Repository
```bash
git clone https://github.com/haribabux7/amazon-sales-pulse.git
cd amazon-sales-pulse
```

### 2. Create a Virtual Environment
```bash
python -m venv .venv
source .venv/bin/activate          # macOS / Linux
.venv\Scripts\activate             # Windows
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Configure Environment Variables
```bash
cp .env.example .env
# then edit .env with your values
```

### 5. Start the Dashboard
```bash
cd Data-Analytics-Project/Python
streamlit run Dashboard.py
```

Open <http://localhost:8501> in your browser.

---

## Environment Variables

Create a `.env` file at the project root:

```env
# Server
PORT=8501

# Database (optional — only if running SQL files against a live DB)
DATABASE_URL=postgresql://user:password@localhost:5432/amazon_sales
MONGO_URI=

# Auth / API (reserved for future API layer)
JWT_SECRET=replace-with-a-long-random-string
API_KEY=

# Email (reserved — for scheduled report delivery)
EMAIL_HOST=smtp.gmail.com
EMAIL_USER=you@example.com
EMAIL_PASSWORD=app-specific-password
```

| Variable | Purpose |
|---|---|
| `PORT` | Streamlit server port (default `8501`). |
| `DATABASE_URL` | SQL connection string for running `Business_Queries.sql`. |
| `MONGO_URI` | Optional — for future NoSQL extension. |
| `JWT_SECRET` | Reserved for future authenticated API. |
| `API_KEY` | Reserved for third-party data enrichment. |
| `EMAIL_*` | Reserved for scheduled email reports. |

---

## Usage

1. **Launch** the dashboard with `streamlit run Dashboard.py`.
2. **Upload** any compatible sales CSV, or use the bundled Amazon dataset.
3. **Filter** by date range, product category, region, or payment method in the sidebar.
4. **Read** the auto-generated KPIs, trend charts, and correlation heatmap.
5. **Export** the filtered dataset and insights as a single CSV.

**Example scenarios**
- A category manager checks which discount band maximizes profit.
- A regional lead compares North America vs. Asia revenue quarter-over-quarter.
- A founder reviews top 10 products by margin before a campaign launch.

---

## API Documentation

> The current release ships as a notebook + dashboard suite. The table below describes the **planned REST layer** for v2.0.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | `/api/kpis`              | Returns total revenue, profit, AOV, orders for current filters. |
| GET    | `/api/trend?by=month`    | Monthly / quarterly revenue trend series. |
| GET    | `/api/category`          | Revenue & profit grouped by product category. |
| GET    | `/api/region`            | Revenue & profit grouped by customer region. |
| POST   | `/api/upload`            | Upload a new sales CSV for analysis. |
| DELETE | `/api/dataset/:id`       | Remove a previously uploaded dataset. |

**Example response — `GET /api/kpis`**
```json
{
  "total_revenue": 18452310.55,
  "total_profit": 6213447.18,
  "average_order_value": 412.77,
  "total_orders": 44721
}
```

---

## Database Schema

The cleaned dataset is modelled as a single wide fact table (`orders`) — ideal for analytics, easy to denormalize later into a star schema.

| Column | Type | Description |
|---|---|---|
| `order_id` | INT (PK) | Unique order identifier |
| `order_date` | DATE | Date of purchase |
| `product_id` | INT | Product identifier |
| `product_category` | VARCHAR | Books, Fashion, Electronics, … |
| `price` | DECIMAL | List price per unit |
| `discount_percent` | INT | Discount applied (%) |
| `quantity_sold` | INT | Units sold in the order |
| `customer_region` | VARCHAR | Geographic region |
| `payment_method` | VARCHAR | UPI, Credit Card, Debit Card, etc. |
| `rating` | DECIMAL | Product rating (1.0 – 5.0) |
| `review_count` | INT | Number of reviews |
| `discounted_price` | DECIMAL | `price * (1 - discount_percent/100)` |
| `total_revenue` | DECIMAL | `discounted_price * quantity_sold` |
| `profit_margin` | DECIMAL | Margin applied to the order |
| `profit` | DECIMAL | Absolute profit value |
| `cost` | DECIMAL | Implied cost (`revenue − profit`) |
| `year`, `month`, `quarter`, `day_of_week` | — | Time features |
| `discount_band` | VARCHAR | Low / Medium / High / Flash |
| `rating_tier` | VARCHAR | Poor / Average / Good / Excellent |

**Data flow:** `Raw_Data.csv` → cleaning notebook → `Cleaned_Data.csv` → consumed by SQL queries, notebooks, and the dashboard.

---

## Testing

### Unit Testing
```bash
pytest tests/unit
```

### Integration Testing
```bash
pytest tests/integration
```

### End-to-End Testing
- Notebook execution checks via `nbmake`:
  ```bash
  pytest --nbmake Data-Analytics-Project/Python
  ```
- Dashboard smoke test via Streamlit's `--server.headless true` + Playwright.

**Tools used:** `pytest`, `nbmake`, `pandas.testing`, `playwright`.

---

## Performance Optimizations

- **Caching** — `@st.cache_data` on every expensive dataframe transform.
- **Lazy Loading** — charts only render for the active tab.
- **Pagination** — top-N tables instead of full dumps.
- **Query Optimization** — indexed `order_date`, `product_category`, `customer_region`.
- **Vectorization** — all aggregations done with Pandas/NumPy (no Python loops).
- **Code Splitting** — UI, data, and chart layers separated for readability.
- **Compression** — exported CSVs gzip-encoded when > 5 MB.

---

## Security Features

- 🔐 **Authentication** — reserved hooks for token-gated dashboard access.
- 🔐 **Authorization** — role-based view filtering (analyst vs. viewer).
- 🔐 **Password Encryption** — bcrypt-ready user table schema.
- 🔐 **JWT Security** — short-lived tokens for the planned API layer.
- 🔐 **Input Validation** — strict CSV schema check before ingestion.
- 🔐 **Rate Limiting** — request throttling on the upload endpoint.
- 🔐 **CSRF Protection** — same-site cookies and origin checks.
- 🔐 **Secure API Practices** — `.env`-driven secrets, never hard-coded.

---

## Deployment

### Streamlit Community Cloud
1. Push the repo to GitHub.
2. Connect the repo at <https://streamlit.io/cloud>.
3. Set the entry point to `Data-Analytics-Project/Python/Dashboard.py`.

### Render / Railway
- Create a new **Web Service** → Python environment.
- Build command: `pip install -r requirements.txt`
- Start command: `streamlit run Data-Analytics-Project/Python/Dashboard.py --server.port $PORT --server.address 0.0.0.0`

### Vercel / Netlify
- Use the planned **API layer (v2)** for serverless deployment.

### AWS / Azure
- Containerize with the provided `Dockerfile`.
- Deploy to **AWS App Runner**, **ECS Fargate**, or **Azure Container Apps**.

### CI/CD Overview
- **GitHub Actions** workflow: lint (`ruff`) → format check (`black`) → notebook execution (`nbmake`) → deploy on `main`.

---

## Challenges & Solutions

- **Inconsistent raw data** — mixed casing in regions, stray nulls in `discount_percent`. **Solved** with a deterministic cleaning notebook + SQL mirror, so either path produces identical output.
- **Slow dashboard with full dataset** — rebuilding aggregations on every filter froze the UI. **Solved** by aggressive `@st.cache_data` decorators and pushing groupbys down to Pandas-level vector ops.
- **Query portability** — analysts use both MySQL and PostgreSQL. **Solved** by sticking to ANSI SQL and avoiding vendor-specific window-function tricks.
- **Discount vs. profit paradox** — high discounts sometimes correlated with *higher* absolute profit. **Solved** by adding a discount-band feature so users can separate volume effects from margin effects.
- **Reproducibility** — notebooks executed top-to-bottom in CI to prevent the classic "works on my machine" drift.

---

## Future Improvements

1. Add a FastAPI service exposing all metrics as REST endpoints.
2. Migrate the dashboard to **Streamlit Multi-Page** with role-based pages.
3. Add **forecasting** (Prophet / ARIMA) for revenue prediction.
4. Add a **cohort analysis** module by region and category.
5. Add **anomaly detection** on daily revenue using rolling z-scores.
6. Plug into a real **PostgreSQL warehouse** with dbt models.
7. Add **scheduled email reports** with weekly KPI digests.
8. Add **user authentication** with Auth0 / Clerk.
9. Add **A/B testing analytics** for promotion experiments.
10. Add **LLM-powered insights** — natural-language Q&A on the dataset.
11. Add a **mobile-first redesign** using a custom Streamlit theme.
12. Add **multi-tenant dataset isolation** for client work.

---

## Contributing

1. **Fork** the repository.
2. **Create** a feature branch: `git checkout -b feature/your-feature`.
3. **Commit** your changes: `git commit -m "feat: add your feature"`.
4. **Push** the branch: `git push origin feature/your-feature`.
5. **Open** a Pull Request with a clear description and screenshots.

**Coding standards**
- Black-formatted Python, 100-char line limit.
- Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`, …).
- Notebooks must execute top-to-bottom without errors.
- Every new SQL query must include a one-line business question as a comment.

---

## FAQ

**Q: Do I need a database to run this project?**
No. The dashboard and notebooks work directly off the bundled CSV. The SQL folder is optional and runs against any MySQL/PostgreSQL instance.

**Q: Can I plug in my own sales data?**
Yes — the dashboard auto-detects common column names (date, category, region, revenue, profit). Upload your CSV from the sidebar.

**Q: Is this dataset real Amazon data?**
No. It's a realistic, synthetic Amazon-style dataset built specifically for analytics practice and portfolio demonstration.

**Q: Why Streamlit instead of Power BI / Tableau?**
Streamlit is free, code-first, version-controllable, and runs anywhere Python runs — perfect for engineers and analysts who want reproducibility.

**Q: Can I use this commercially?**
Yes — under the MIT License. Attribution is appreciated but not required.

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](./LICENSE) file for details.

```
MIT License © 2025 Hari Babu C H
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 👤 Author

**HARI BABU C H**

Frontend Developer | Data Analyst | Chennai, India

- 🌐 Portfolio: [https://www.haribabu.me](https://www.haribabu.me)
- 💼 LinkedIn: [https://www.linkedin.com/in/haribabux8](https://www.linkedin.com/in/haribabux8)
- 🐙 GitHub: [https://github.com/haribabux8](https://github.com/haribabux8)
- 📧 Email: [haribabuc458@gmail.com](mailto:haribabuc458@gmail.com)

---
---

## Acknowledgements

- **Open Source Libraries** — Pandas, NumPy, Matplotlib, Seaborn, Streamlit, Jupyter.
- **Inspiration** — the global Kaggle and r/dataisbeautiful communities for raising the bar on accessible analytics.
- **Learning Resources** — *Python for Data Analysis* (Wes McKinney), *Storytelling with Data* (Cole Nussbaumer Knaflic), official Streamlit docs.
- **Contributors** — thanks to every analyst, mentor, and reviewer who shaped this project.

---
