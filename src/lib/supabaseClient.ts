// src/lib/supabaseClient.ts
import { createClient } from '@supabase/supabase-js';

let _client: ReturnType<typeof createClient> | null = null;

export const supabaseClient = (() => {
  if (_client) return _client;
  const url = import.meta.env.VITE_SUPABASE_URL!;
  const anon = import.meta.env.VITE_SUPABASE_ANON_KEY!;
  _client = createClient(url, anon, {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      storageKey: `sb-${new URL(url).hostname.split('.')[0]}-auth-token`
    }
  });
  return _client;
})();
