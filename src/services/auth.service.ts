import { supabase } from '@/lib/supabaseClient';
import { User, LoginCredentials, RegisterData } from '../types/auth.types';

export const authService = {
  async login(credentials: LoginCredentials): Promise<void> {
    const { data, error } = await supabase.auth.signInWithPassword({
      email: credentials.email,
      password: credentials.password,
    });

    if (error) throw error;
    if (data.session) {
      localStorage.setItem('access_token', data.session.access_token);
    }
  },

  async register(registerData: RegisterData): Promise<void> {
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: registerData.email,
      password: registerData.password,
    });

    if (authError) throw authError;
    if (!authData.user) throw new Error('User not created');

    const { error: profileError } = await supabase
      .from('users')
      .insert({
        id: authData.user.id,
        email: registerData.email,
        name: registerData.name,
        last_name: registerData.lastName || '',
        role_id: 3,
        auth_user_id: authData.user.id,
      });

    if (profileError) throw profileError;

    if (authData.session) {
      localStorage.setItem('access_token', authData.session.access_token);
    }
  },

  async logout(): Promise<void> {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
    localStorage.removeItem('access_token');
  },

  async getCurrentUser(): Promise<User | null> {
    const { data: { user }, error } = await supabase.auth.getUser();
    if (error || !user) return null;

    const { data: profile, error: profileError } = await supabase
      .from('users')
      .select(`
        *,
        role:roles(name)
      `)
      .eq('auth_user_id', user.id)
      .maybeSingle();

    if (profileError || !profile) return null;

    return {
      id: profile.id,
      email: profile.email,
      name: profile.name,
      lastName: profile.last_name,
      role: profile.role?.name || 'servicio',
    };
  },

  isAuthenticated(): boolean {
    return !!localStorage.getItem('access_token');
  },
};
