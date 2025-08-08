# Mekom Kavua – Synagogue Seating Platform

מערכת ניהול הושבה לבתי-כנסת וישיבות, מונעת AI.  
תיעוד מלא נמצא בתיקייה **/docs**.

## Quick Start (Development)
```bash
git clone <repo-url>
cd <repo>
docker compose up    # יקים Postgres + PGAdmin
npm install -g @nestjs/cli
cd backend && npm i && nest start --watch
cd ../frontend && npm i && npm run dev
אחרי עלייה:

Front-end – http://localhost:5173

API – http://localhost:3000/api