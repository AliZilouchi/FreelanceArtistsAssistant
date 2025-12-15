-- Enable extensions commonly available on Supabase
CREATE EXTENSION IF NOT EXISTS "pgcrypto"; -- for gen_random_uuid()

/*
  ENUM types
*/
CREATE TYPE artifact_status AS ENUM (
  'draft',
  'in_progress',
  'ready',
  'sent_to_gallery',
  'sold',
  'archived'
);

CREATE TYPE gallery_movement_type AS ENUM (
  'sent',
  'returned'
);

/*
  USERS (ARTISTS)
*/
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  password_hash text NOT NULL, -- store hashed password
  name text,
  profile_image text,
  currency text DEFAULT 'IRR',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

/*
  ARTIFACTS (inventory items, works-in-progress, preorders)
*/
CREATE TABLE IF NOT EXISTS artifacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status artifact_status NOT NULL DEFAULT 'draft',
  title text,
  description text,
  is_preorder boolean DEFAULT false,
  estimated_price numeric(14,2),  -- nullable for draft/WIP
  final_price numeric(14,2),      -- final price when finished or sold
  material text,
  dimensions jsonb,               -- e.g. {"width":40,"height":60,"depth":5,"unit":"cm"}
  main_image text,
  notes text,
  location text,                   -- free-text location: "studio", "Gallery X", "buyer name"
  created_date date,               -- the date artist considers "creation date"
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- index to speed up common queries per user and status
CREATE INDEX IF NOT EXISTS idx_artifacts_user_status ON artifacts (user_id, status);

/*
  ARTIFACT IMAGES (multiple images per artifact)
*/
CREATE TABLE IF NOT EXISTS artifact_images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  artifact_id uuid NOT NULL REFERENCES artifacts(id) ON DELETE CASCADE,
  url text NOT NULL,
  caption text,
  ordering integer DEFAULT 0, -- allows an order among images
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_artifact_images_artifact ON artifact_images (artifact_id);

/*
  SALES
  Each sale is attached to an artifact and logged.
*/
CREATE TABLE IF NOT EXISTS sales (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  artifact_id uuid NOT NULL REFERENCES artifacts(id) ON DELETE RESTRICT,
  buyer_name text,
  amount numeric(14,2) NOT NULL,
  currency text DEFAULT 'IRR',
  payment_method text,    -- e.g. "card-to-card", "cash", "bank transfer"
  sale_date date NOT NULL DEFAULT current_date,
  notes text,
  created_at timestamptz DEFAULT now()
);

-- after a sale the artifact status generally should be 'sold' and location becomes buyer.
-- We'll keep status updates in business logic; a trigger could be added later.

/*
  GALLERY MOVEMENTS
  Tracks when an artifact is sent to / returned from a gallery.
  Optionally linked to a sale (if gallery sold the piece).
*/
CREATE TABLE IF NOT EXISTS gallery_movements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  artifact_id uuid NOT NULL REFERENCES artifacts(id) ON DELETE RESTRICT,
  gallery_name text NOT NULL,
  movement_type gallery_movement_type NOT NULL,
  movement_date date NOT NULL DEFAULT current_date,
  sale_id uuid REFERENCES sales(id) ON DELETE SET NULL, -- if gallery sold it, link the sale
  notes text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_gallery_movements_artifact ON gallery_movements (artifact_id);

/*
  EXPENSES
  Simple artist expense tracking (materials, shipping, tools, etc).
*/
CREATE TABLE IF NOT EXISTS expenses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  artifact_id uuid REFERENCES artifacts(id) ON DELETE SET NULL, -- optional link
  category text,           -- e.g. "materials", "shipping", "tools"
  amount numeric(14,2) NOT NULL,
  currency text DEFAULT 'IRR',
  expense_date date NOT NULL DEFAULT current_date,
  notes text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_expenses_user ON expenses (user_id);

/*
  OPTIONAL: A lightweight activity log (audit trail) to show recent changes on dashboard.
*/
CREATE TABLE IF NOT EXISTS activity_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  artifact_id uuid REFERENCES artifacts(id) ON DELETE CASCADE,
  action text NOT NULL,        -- e.g. 'created_artifact', 'recorded_sale', 'sent_to_gallery'
  payload jsonb,               -- optional extra data
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_activity_log_user ON activity_log (user_id);

/*
  Helpful trigger: update updated_at on row change
*/
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- attach trigger to tables having updated_at
DROP TRIGGER IF EXISTS trg_set_updated_at_artifacts ON artifacts;
CREATE TRIGGER trg_set_updated_at_artifacts
  BEFORE UPDATE ON artifacts
  FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

DROP TRIGGER IF EXISTS trg_set_updated_at_users ON users;
CREATE TRIGGER trg_set_updated_at_users
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

-- END of DDL
