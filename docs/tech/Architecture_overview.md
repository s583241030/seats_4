# Architecture Overview

```mermaid
graph LR
  subgraph Front-End
    A[React + React-Konva] -->|REST/WebSocket| B(API)
  end
  subgraph Back-End (NestJS)
    B --> C(PostgreSQL)
    B --> D{Edge Functions\n-- Rules & Scoring}
    D -->|OpenAI API| E[(LLM)]
  end
  C -.->|PGAdmin| F[(DB Admin)]
  B --> G[Auth (JWT)]

שכבות
Frontend – React + Vite, Canvas לעריכת מפה.

API – NestJS REST + WebSocket.

DB – PostgreSQL + Prisma.

Edge Functions – ניקוד כיסאות, שיבוץ, קריאות AI.

DevOps – Docker Compose להרמה מקומית.