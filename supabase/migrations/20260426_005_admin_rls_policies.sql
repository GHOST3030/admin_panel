-- ============================================================
-- Migration: Admin RLS Policies
-- Enforces: only users with role='admin' can INSERT/UPDATE/DELETE
-- on categories, products, product_variants, orders, notifications.
-- ============================================================

-- Helper function used by all admin policies
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN LANGUAGE sql STABLE AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  )
$$;

-- ─── categories ───────────────────────────────────────────────
DROP POLICY IF EXISTS "categories_insert_admin" ON public.categories;
DROP POLICY IF EXISTS "categories_update_admin" ON public.categories;
DROP POLICY IF EXISTS "categories_delete_admin" ON public.categories;

CREATE POLICY "categories_insert_admin" ON public.categories
  FOR INSERT TO authenticated WITH CHECK (public.is_admin());
CREATE POLICY "categories_update_admin" ON public.categories
  FOR UPDATE TO authenticated USING (public.is_admin());
CREATE POLICY "categories_delete_admin" ON public.categories
  FOR DELETE TO authenticated USING (public.is_admin());

-- ─── products ─────────────────────────────────────────────────
DROP POLICY IF EXISTS "products_insert_admin" ON public.products;
DROP POLICY IF EXISTS "products_update_admin" ON public.products;
DROP POLICY IF EXISTS "products_delete_admin" ON public.products;

CREATE POLICY "products_insert_admin" ON public.products
  FOR INSERT TO authenticated WITH CHECK (public.is_admin());
CREATE POLICY "products_update_admin" ON public.products
  FOR UPDATE TO authenticated USING (public.is_admin());
CREATE POLICY "products_delete_admin" ON public.products
  FOR DELETE TO authenticated USING (public.is_admin());

-- ─── product_variants ─────────────────────────────────────────
DROP POLICY IF EXISTS "variants_insert_admin" ON public.product_variants;
DROP POLICY IF EXISTS "variants_update_admin" ON public.product_variants;
DROP POLICY IF EXISTS "variants_delete_admin" ON public.product_variants;

CREATE POLICY "variants_insert_admin" ON public.product_variants
  FOR INSERT TO authenticated WITH CHECK (public.is_admin());
CREATE POLICY "variants_update_admin" ON public.product_variants
  FOR UPDATE TO authenticated USING (public.is_admin());
CREATE POLICY "variants_delete_admin" ON public.product_variants
  FOR DELETE TO authenticated USING (public.is_admin());

-- ─── orders (status updates only) ────────────────────────────
DROP POLICY IF EXISTS "orders_update_admin" ON public.orders;

CREATE POLICY "orders_update_admin" ON public.orders
  FOR UPDATE TO authenticated USING (public.is_admin());

-- ─── notifications ────────────────────────────────────────────
DROP POLICY IF EXISTS "notifications_insert_admin" ON public.notifications;

CREATE POLICY "notifications_insert_admin" ON public.notifications
  FOR INSERT TO authenticated WITH CHECK (public.is_admin());
