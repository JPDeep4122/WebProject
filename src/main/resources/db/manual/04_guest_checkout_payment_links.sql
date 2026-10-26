-- Apply to the current application's English-named tables before deploying.
-- Existing orders and users are deliberately left unchanged.
BEGIN;

ALTER TABLE orders ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS recipient_email VARCHAR(100);
ALTER TABLE payments ADD COLUMN IF NOT EXISTS payment_url TEXT;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS payment_expires_at TIMESTAMPTZ;

COMMIT;
