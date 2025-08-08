-- הרחבות
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS citext;

-- ENUM-ים
CREATE TYPE role_type          AS ENUM ('owner','gabbai','helper','viewer');
CREATE TYPE seat_type          AS ENUM ('chair','bench','blocked','standing');
CREATE TYPE seat_status        AS ENUM ('free','locked','assigned','requested');
CREATE TYPE object_type        AS ENUM ('aron_kodesh','bima','entrance','column','custom');
CREATE TYPE request_status     AS ENUM ('pending','approved','rejected','cancelled');
CREATE TYPE snapshot_scope     AS ENUM ('map','rules','full');

------------------------------------------------------------------
-- טבלאות ליבה
------------------------------------------------------------------
CREATE TABLE users(
  id              UUID  PRIMARY KEY DEFAULT uuid_generate_v4(),
  email           CITEXT UNIQUE,
  phone           TEXT,
  display_name    TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE synagogues(
  id              UUID  PRIMARY KEY DEFAULT uuid_generate_v4(),
  name            TEXT  NOT NULL,
  nusach          TEXT,             -- אשכנז / ספרד / ...
  address         TEXT,
  nedarim_plus_url TEXT,
  created_by      UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE roles(
  user_id         UUID REFERENCES users(id)        ON DELETE CASCADE,
  synagogue_id    UUID REFERENCES synagogues(id)   ON DELETE CASCADE,
  role            role_type NOT NULL,
  PRIMARY KEY (user_id,synagogue_id)
);

------------------------------------------------------------------
-- מפת המקום
------------------------------------------------------------------
CREATE TABLE sections(
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  synagogue_id UUID NOT NULL REFERENCES synagogues(id) ON DELETE CASCADE,
  name         TEXT NOT NULL,          -- עזרת גברים / נשים / יציע
  polygon      JSONB,                  -- GeoJSON או array נקודות
  z_index      INT DEFAULT 0,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE seats(
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  section_id   UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
  row_idx      INT  NOT NULL,
  col_idx      INT  NOT NULL,
  x            NUMERIC NOT NULL,
  y            NUMERIC NOT NULL,
  w            NUMERIC DEFAULT 1,
  h            NUMERIC DEFAULT 1,
  type         seat_type   NOT NULL DEFAULT 'chair',
  status       seat_status NOT NULL DEFAULT 'free',
  tags         JSONB,
  score_cached INT,                    -- מפת חום live
  locked_bool  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(section_id,row_idx,col_idx)
);

CREATE TABLE objects(
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  section_id   UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
  type         object_type NOT NULL,
  geometry     JSONB NOT NULL,         -- point/polygon
  label        TEXT,
  meta         JSONB,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

------------------------------------------------------------------
-- חוקים, מתפללים, בקשות, שיבוצים
------------------------------------------------------------------
CREATE TABLE rules(
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  synagogue_id UUID NOT NULL REFERENCES synagogues(id) ON DELETE CASCADE,
  name         TEXT NOT NULL,
  dsl          JSONB NOT NULL,      -- DSL מובנה
  enabled_bool BOOLEAN NOT NULL DEFAULT TRUE,
  scope        TEXT   DEFAULT 'seat', -- seat | member | constraint
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE members(
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  synagogue_id UUID NOT NULL REFERENCES synagogues(id) ON DELETE CASCADE,
  full_name    TEXT NOT NULL,
  email        CITEXT,
  phone        TEXT,
  gender       TEXT,
  age          INT,
  tags         JSONB,               -- {vaad:\"A\", donor:true}
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE requests(
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  synagogue_id UUID NOT NULL REFERENCES synagogues(id) ON DELETE CASCADE,
  member_id    UUID REFERENCES members(id) ON DELETE SET NULL,
  payload      JSONB,              -- העדפות
  status       request_status NOT NULL DEFAULT 'pending',
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE assignments(
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  run_id       UUID NOT NULL,      -- מזהה ריצת שיבוץ
  synagogue_id UUID NOT NULL REFERENCES synagogues(id) ON DELETE CASCADE,
  member_id    UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  seat_id      UUID NOT NULL REFERENCES seats(id)    ON DELETE CASCADE,
  lock_bool    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(run_id,member_id),
  UNIQUE(run_id,seat_id)
);

------------------------------------------------------------------
-- Snapshots & Audit
------------------------------------------------------------------
CREATE TABLE snapshots(
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  synagogue_id UUID NOT NULL REFERENCES synagogues(id) ON DELETE CASCADE,
  scope        snapshot_scope NOT NULL, -- map / rules / full
  data         BYTEA,                  -- gzip-ed json
  label        TEXT,
  created_by   UUID REFERENCES users(id),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE audit_logs(
  id           BIGSERIAL PRIMARY KEY,
  synagogue_id UUID,
  user_id      UUID,
  action       TEXT,
  meta         JSONB,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
