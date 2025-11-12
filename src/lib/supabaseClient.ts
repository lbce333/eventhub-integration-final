import { createClient } from '@supabase/supabase-js';

let _supabase: any = (globalThis as any).__sb;
if (!_supabase) {
  _supabase = createClient(
    import.meta.env.VITE_SUPABASE_URL!,
    import.meta.env.VITE_SUPABASE_ANON_KEY!,
    {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
        storageKey: 'sb-gtisgcqqyfvuueocsstz-auth-token',
        storage: typeof window !== 'undefined' ? window.localStorage : undefined,
      },
    }
  );
  (globalThis as any).__sb = _supabase;
}
export const supabase = _supabase;
