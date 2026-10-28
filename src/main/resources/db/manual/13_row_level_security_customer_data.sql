-- Transaction-scoped RLS for customer-owned addresses and notifications.
-- Run this manually against the target PostgreSQL database after deploying the
-- application version that sets app.user_id/app.roles on every JPA transaction.
-- The application DB role must not have BYPASSRLS; FORCE makes policies apply
-- even when it owns these tables.

BEGIN;

CREATE OR REPLACE FUNCTION public.app_rls_user_id()
RETURNS BIGINT
LANGUAGE SQL
STABLE
AS $$
    SELECT NULLIF(current_setting('app.user_id', true), '')::BIGINT
$$;

CREATE OR REPLACE FUNCTION public.app_rls_has_role(required_role TEXT)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
AS $$
    SELECT required_role = ANY(string_to_array(COALESCE(current_setting('app.roles', true), ''), ','))
$$;

ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS addresses_owner_or_admin ON public.addresses;
CREATE POLICY addresses_owner_or_admin ON public.addresses
    USING (user_id = public.app_rls_user_id() OR public.app_rls_has_role('ROLE_ADMIN'))
    WITH CHECK (user_id = public.app_rls_user_id() OR public.app_rls_has_role('ROLE_ADMIN'));

ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notifications FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS notifications_owner_or_admin_read ON public.user_notifications;
CREATE POLICY notifications_owner_or_admin_read ON public.user_notifications
    FOR SELECT
    USING (user_id = public.app_rls_user_id() OR public.app_rls_has_role('ROLE_ADMIN'));

DROP POLICY IF EXISTS notifications_owner_or_internal_insert ON public.user_notifications;
CREATE POLICY notifications_owner_or_internal_insert ON public.user_notifications
    FOR INSERT
    WITH CHECK (
        user_id = public.app_rls_user_id()
        OR public.app_rls_has_role('ROLE_ADMIN')
        OR public.app_rls_has_role('ROLE_BRANCH_MANAGER')
        OR public.app_rls_has_role('ROLE_STAFF')
        OR public.app_rls_has_role('ROLE_SHIPPER')
    );

DROP POLICY IF EXISTS notifications_owner_or_admin_update ON public.user_notifications;
CREATE POLICY notifications_owner_or_admin_update ON public.user_notifications
    FOR UPDATE
    USING (user_id = public.app_rls_user_id() OR public.app_rls_has_role('ROLE_ADMIN'))
    WITH CHECK (user_id = public.app_rls_user_id() OR public.app_rls_has_role('ROLE_ADMIN'));

DROP POLICY IF EXISTS notifications_owner_or_admin_delete ON public.user_notifications;
CREATE POLICY notifications_owner_or_admin_delete ON public.user_notifications
    FOR DELETE
    USING (user_id = public.app_rls_user_id() OR public.app_rls_has_role('ROLE_ADMIN'));

COMMIT;
