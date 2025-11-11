import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { authService } from '@/services/auth.service';
import { User, LoginCredentials, RegisterData } from '@/types/auth.types';
import { supabase } from '@/lib/supabaseClient';
import { toast } from 'sonner';

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (credentials: LoginCredentials) => Promise<void>;
  register: (data: RegisterData) => Promise<void>;
  logout: () => Promise<void>;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    const initAuth = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession();

        if (session) {
          try {
            const currentUser = await authService.getCurrentUser();
            setUser(currentUser);
            if (location.pathname === '/login') {
              navigate('/dashboard', { replace: true });
            }
          } catch (profileError) {
            console.error('Error loading user profile:', profileError);
            setUser(null);
          }
        }
      } catch (error) {
        console.error('Error loading session:', error);
        setUser(null);
      } finally {
        setLoading(false);
      }
    };

    initAuth();

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (event === 'SIGNED_IN' && session) {
          try {
            const currentUser = await authService.getCurrentUser();
            setUser(currentUser);
            navigate('/dashboard', { replace: true });
          } catch (error) {
            console.error('Error loading user profile on sign in:', error);
            setUser(null);
          }
        } else if (event === 'SIGNED_OUT') {
          setUser(null);
          navigate('/login', { replace: true });
        }
      }
    );

    return () => {
      subscription.unsubscribe();
    };
  }, [navigate, location.pathname]);

  const login = async (credentials: LoginCredentials) => {
    try {
      await authService.login(credentials);
      
      // Load user data after successful login
      const currentUser = await authService.getCurrentUser();
      setUser(currentUser);
      
      toast.success('¡Bienvenido de vuelta!');
    } catch (error: unknown) {
      const message = (error as { response?: { data?: { message?: string } } })?.response?.data?.message || 'Error al iniciar sesión';
      toast.error(message);
      throw error;
    }
  };

  const register = async (data: RegisterData) => {
    try {
      await authService.register(data);
      
      // Load user data after successful registration
      const currentUser = await authService.getCurrentUser();
      setUser(currentUser);
      
      toast.success('¡Cuenta creada exitosamente!');
    } catch (error: unknown) {
      const message = (error as { response?: { data?: { message?: string } } })?.response?.data?.message || 'Error al registrarse';
      toast.error(message);
      throw error;
    }
  };

  const logout = async () => {
    try {
      await authService.logout();
      setUser(null);
      toast.success('Sesión cerrada correctamente');
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        loading,
        login,
        register,
        logout,
        isAuthenticated: !!user,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}