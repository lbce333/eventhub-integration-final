/*
  # Create Storage Buckets
  
  Creates buckets for:
  - event-images (event photos and decoration)
  - expense-receipts (receipt uploads)
*/

-- Create buckets
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('event-images', 'event-images', false),
  ('expense-receipts', 'expense-receipts', false)
ON CONFLICT (id) DO NOTHING;

-- Policies for event-images bucket
CREATE POLICY "Admin can upload event images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'event-images' AND
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role_id = 1)
);

CREATE POLICY "Admin can view event images"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'event-images' AND
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role_id = 1)
);

CREATE POLICY "Admin can delete event images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'event-images' AND
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role_id = 1)
);

-- Policies for expense-receipts bucket
CREATE POLICY "Authenticated can upload receipts"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'expense-receipts' AND
  auth.uid() IS NOT NULL
);

CREATE POLICY "Admin can view all receipts"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'expense-receipts' AND
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role_id = 1)
);

CREATE POLICY "Users can view own receipts"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'expense-receipts' AND
  owner = auth.uid()
);

CREATE POLICY "Admin can delete receipts"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'expense-receipts' AND
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role_id = 1)
);
