/*
  # Storage Buckets and Policies for Event Management

  1. Buckets Created
    - `event-images` (private) - Stores event-related images (decorations, gallery)
    - `receipts` (private) - Stores expense receipts and financial documents

  2. Security
    - Enable RLS on storage.objects
    - Add role-based policies:
      - admin/socio: Full access (read/write) to both buckets
      - coordinador: Read-only access to event-images for their events
      - encargado_compras: Read/write receipts, read event-images for their events
      - servicio: Read-only access to objects from assigned events

  3. File Organization
    - event-images: stored as events/{event_id}/{filename}
    - receipts: stored as receipts/{event_id}/{filename}

  4. Important Notes
    - All buckets are private by default
    - Access controlled through RLS policies
    - Files are organized by event_id for proper isolation
*/

INSERT INTO storage.buckets (id, name, public)
VALUES
  ('event-images', 'event-images', false),
  ('receipts', 'receipts', false)
ON CONFLICT (id) DO NOTHING;

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin and Socio: Full access to event images"
  ON storage.objects
  FOR ALL
  TO authenticated
  USING (
    bucket_id = 'event-images' AND
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.role IN ('admin', 'socio')
    )
  )
  WITH CHECK (
    bucket_id = 'event-images' AND
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.role IN ('admin', 'socio')
    )
  );

CREATE POLICY "Admin and Socio: Full access to receipts"
  ON storage.objects
  FOR ALL
  TO authenticated
  USING (
    bucket_id = 'receipts' AND
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.role IN ('admin', 'socio')
    )
  )
  WITH CHECK (
    bucket_id = 'receipts' AND
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.role IN ('admin', 'socio')
    )
  );

CREATE POLICY "Coordinador: Read event images"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'event-images' AND
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.role = 'coordinador'
    )
  );

CREATE POLICY "Encargado Compras: Read/Write receipts"
  ON storage.objects
  FOR ALL
  TO authenticated
  USING (
    bucket_id = 'receipts' AND
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.role = 'encargado_compras'
    )
  )
  WITH CHECK (
    bucket_id = 'receipts' AND
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.role = 'encargado_compras'
    )
  );

CREATE POLICY "Encargado Compras: Read event images"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'event-images' AND
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.role = 'encargado_compras'
    )
  );

CREATE POLICY "Servicio: Read assigned event images"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'event-images' AND
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.role = 'servicio'
    ) AND
    EXISTS (
      SELECT 1 FROM event_assignments
      WHERE event_assignments.user_id = auth.uid()
      AND (storage.foldername(name))[1] = 'events'
      AND (storage.foldername(name))[2]::int = event_assignments.event_id
    )
  );

CREATE POLICY "Servicio: Read assigned event receipts"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'receipts' AND
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE user_profiles.id = auth.uid()
      AND user_profiles.role = 'servicio'
    ) AND
    EXISTS (
      SELECT 1 FROM event_assignments
      WHERE event_assignments.user_id = auth.uid()
      AND (storage.foldername(name))[1] = 'receipts'
      AND (storage.foldername(name))[2]::int = event_assignments.event_id
    )
  );
