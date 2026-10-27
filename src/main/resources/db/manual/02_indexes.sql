-- Query/join indexes for the current Spring Boot JPA schema from 01_schema.sql.
-- Unique keys already declared in 01_schema.sql are intentionally not repeated here.

CREATE INDEX IF NOT EXISTS ix_users_branch ON users(branch_id);
CREATE INDEX IF NOT EXISTS ix_users_active_blocked ON users(is_active, is_blocked);
CREATE INDEX IF NOT EXISTS ix_otp_codes_email_type_created ON otp_codes(email, type, created_at DESC);
CREATE INDEX IF NOT EXISTS ix_addresses_user ON addresses(user_id);
CREATE INDEX IF NOT EXISTS ix_categories_parent ON categories(parent_id);
CREATE INDEX IF NOT EXISTS ix_products_category_active ON products(category_id, active);
CREATE INDEX IF NOT EXISTS ix_products_brand ON products(brand_id);
CREATE INDEX IF NOT EXISTS ix_products_created_at ON products(created_at DESC);
CREATE INDEX IF NOT EXISTS ix_product_imagines_product ON product_imagines(product_id);
CREATE INDEX IF NOT EXISTS ix_branch_inventory_product ON branch_inventory(product_id);
CREATE INDEX IF NOT EXISTS ix_branch_products_branch_product ON branch_products(branch_id, product_id);
CREATE INDEX IF NOT EXISTS ix_inventory_adjustments_inventory_created ON inventory_adjustments(inventory_id, created_at DESC);
CREATE INDEX IF NOT EXISTS ix_inventory_adjustments_actor_created ON inventory_adjustments(adjusted_by, created_at DESC);
CREATE INDEX IF NOT EXISTS ix_carts_session ON carts(session_id);
CREATE INDEX IF NOT EXISTS ix_cart_items_cart ON cart_items(cart_id);
CREATE INDEX IF NOT EXISTS ix_cart_items_product ON cart_items(product_id);
CREATE INDEX IF NOT EXISTS ix_orders_user_created ON orders(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS ix_orders_branch_status_created ON orders(branch_id, status, created_at DESC);
CREATE INDEX IF NOT EXISTS ix_orders_status_created ON orders(status, created_at DESC);
CREATE INDEX IF NOT EXISTS ix_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS ix_order_items_product ON order_items(product_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_payments_transaction_no ON payments(transaction_no) WHERE transaction_no IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_delivery_assignments_shipper_status ON delivery_assignments(shipper_id, status);
CREATE INDEX IF NOT EXISTS ix_order_return_requests_order ON order_return_requests(order_id, requested_at DESC);
CREATE INDEX IF NOT EXISTS ix_order_return_requests_status ON order_return_requests(status, requested_at DESC);
CREATE INDEX IF NOT EXISTS ix_reviews_product_active_created ON reviews(product_id, active, created_at DESC);
CREATE INDEX IF NOT EXISTS ix_reviews_user ON reviews(user_id);
CREATE INDEX IF NOT EXISTS ix_review_media_review ON review_media(review_id);
CREATE INDEX IF NOT EXISTS ix_promotions_active_window ON promotions(active, starts_at, ends_at);
CREATE INDEX IF NOT EXISTS ix_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS ix_audit_logs_created_at ON audit_logs(created_at DESC);
