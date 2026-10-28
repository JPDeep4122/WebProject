-- Additive PostgreSQL indexes for the customer-facing catalog, cart, and order history.
-- Run manually on the application database after reviewing the current schema.
-- These indexes complement 02_indexes.sql; they do not partition or rewrite data.

-- Customer catalog queries always constrain active=true and commonly sort by newest.
CREATE INDEX IF NOT EXISTS ix_products_active_created_id
    ON products (created_at DESC, id DESC)
    WHERE active = TRUE;

CREATE INDEX IF NOT EXISTS ix_products_category_active_created_id
    ON products (category_id, created_at DESC, id DESC)
    WHERE active = TRUE;

CREATE INDEX IF NOT EXISTS ix_products_brand_active_created_id
    ON products (brand_id, created_at DESC, id DESC)
    WHERE active = TRUE;

-- ProductSpecification uses COALESCE(discount_price, price, original_price)
-- as the effective price for price filtering and sorting.
CREATE INDEX IF NOT EXISTS ix_products_active_selling_price_id
    ON products ((COALESCE(discount_price, price, original_price)), id)
    WHERE active = TRUE;

-- Supports the customer-facing favorites sort. Formula-based soldQuantity/rating
-- cannot be indexed on products; optimize those only after measuring query plans.
CREATE INDEX IF NOT EXISTS ix_products_active_favorite_count_id
    ON products (favorite_count DESC, id DESC)
    WHERE active = TRUE;

-- ProductSpecification's stock EXISTS checks product, branch, and positive availability.
CREATE INDEX IF NOT EXISTS ix_branch_inventory_available_product_branch
    ON branch_inventory (product_id, branch_id)
    WHERE available_quantity > 0;

-- Cart lookup by a specific product within a cart; the existing cart_id index
-- remains useful for loading every cart item.
CREATE INDEX IF NOT EXISTS ix_cart_items_cart_product
    ON cart_items (cart_id, product_id);

-- Customer order history can filter by status while showing newest first.
CREATE INDEX IF NOT EXISTS ix_orders_user_status_created
    ON orders (user_id, status, created_at DESC, id DESC);
