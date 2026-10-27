-- Tao toi da 2 shipper demo cho moi branch active; khong tao don/giao dich mau.
-- Mat khau cua tai khoan moi: xem private/06_shipper_accounts.txt.
-- Chay toan bo file tren dung database website dang dung.
-- Email da co giu nguyen password, role, trang thai va branch.
BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.branches WHERE active = TRUE) THEN
        RAISE EXCEPTION 'Chưa có chi nhánh active. Hãy tạo chi nhánh trước.';
    END IF;
END;
$$;

INSERT INTO public.roles (name)
VALUES ('ROLE_SHIPPER')
ON CONFLICT (name) DO NOTHING;

WITH targets AS (
    SELECT
        'shipper.b' || b.id || '.' || slot.n || '@example.test' AS email,
        LEFT('Shipper demo ' || b.name || ' #' || slot.n, 100) AS full_name,
        '0906' || LPAD((ROW_NUMBER() OVER (ORDER BY b.id, slot.n))::TEXT, 6, '0') AS phone,
        b.id AS branch_id
    FROM public.branches b
    CROSS JOIN generate_series(1, 2) AS slot(n)
    WHERE b.active = TRUE
), new_users AS (
    INSERT INTO public.users
        (email, password, full_name, phone_number, is_active,
         is_blocked, branch_id, created_at, updated_at)
    SELECT
        t.email,
        '$2a$10$Ac25iM06CLVE3kK6d6BPX.0W3ZEetpm9Hp2iWAma6W8lMVhcukdvu',
        t.full_name, t.phone, TRUE, FALSE, t.branch_id,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    FROM targets t
    WHERE NOT EXISTS (
        SELECT 1 FROM public.users u WHERE LOWER(u.email) = t.email
    )
    ON CONFLICT (email) DO NOTHING
    RETURNING id
)
INSERT INTO public.user_roles (user_id, role_id)
SELECT u.id, r.id
FROM new_users u
CROSS JOIN public.roles r
WHERE r.name = 'ROLE_SHIPPER'
ON CONFLICT (user_id, role_id) DO NOTHING;

-- Xem email va branch thuc te de dang nhap/phan cong.
SELECT
    u.email, u.full_name, actual_branch.name AS branch,
    u.is_active, u.is_blocked,
    EXISTS (
        SELECT 1
        FROM public.user_roles ur
        JOIN public.roles r ON r.id = ur.role_id
        WHERE ur.user_id = u.id AND r.name = 'ROLE_SHIPPER'
    ) AS has_shipper_role
FROM public.branches b
CROSS JOIN generate_series(1, 2) AS slot(n)
JOIN public.users u
    ON LOWER(u.email) = 'shipper.b' || b.id || '.' || slot.n || '@example.test'
LEFT JOIN public.branches actual_branch ON actual_branch.id = u.branch_id
WHERE b.active = TRUE
ORDER BY b.id, slot.n;

COMMIT;
