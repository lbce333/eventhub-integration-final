// src/services/auth.service.ts
import { supabaseClient } from '@/lib/supabaseClient';
import type { User as SupabaseUser, Session } from '@supabase/supabase-js';

export type LoginCredentials = { email: string; password: string };
export type RegisterData = { email: string; password: string };

export async function login({ email, password }: LoginCredentials) {
  const { data, error } = await supabaseClient.auth.signInWithPassword({ email, password });
  if (error) throw error;
  return data; // { user, session }
}

export async function register({ email, password }: RegisterData) {
  const { data, error } = await supabaseClient.auth.signUp({ email, password });
  if (error) throw error;
  return data; // { user }
}

export async function signOut() {
  const { error } = await supabaseClient.auth.signOut();
  if (error) throw error;
  return true;
}

export async function getSession(): Promise<Session | null> {
  const { data, error } = await supabaseClient.auth.getSession();
  if (error) throw error;
  return data.session ?? null;
}

export async function getCurrentUser(): Promise<SupabaseUser | null> {
  const { data, error } = await supabaseClient.auth.getUser();
  if (error) throw error;
  return data.user ?? null;
}

/**
 * Perfil de negocio (tabla public.users) enlazado al auth_user_id
 */
export async function getUserProfile() {
  const { data: auth } = await supabaseClient.auth.getUser();
  const uid = auth.user?.id;
  if (!uid) return null;

  const { data, error } = await supabaseClient
    .from('users')
    .select('*')
    .eq('auth_user_id', uid)
    .single();

  if (error) throw error;
  return data; // { id, auth_user_id, email, role_id, ... }
}
