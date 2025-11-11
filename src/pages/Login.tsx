import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Calendar, Lock, Mail } from 'lucide-react';
import { toast } from 'sonner';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const { login, user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (user) {
      navigate('/dashboard', { replace: true });
    }
  }, [user, navigate]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      await login({ email, password });
      toast.success('¡Bienvenido al Sistema!');
      navigate('/dashboard', { replace: true });
    } catch (error) {
      toast.error('Credenciales incorrectas');
    } finally {
      setIsLoading(false);
    }
  };


  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-4">
      <div className="w-full max-w-6xl grid md:grid-cols-2 gap-8 items-center">
        {/* Left side - Branding */}
        <div className="space-y-6 animate-fade-in">
          <div className="flex items-center gap-3">
            <div className="w-16 h-16 rounded-2xl bg-gradient-primary flex items-center justify-center shadow-glow">
              <Calendar className="w-10 h-10 text-white" />
            </div>
            <div>
              <h1 className="text-4xl font-bold text-foreground">Sistema de Control de Eventos</h1>
              <p className="text-muted-foreground">Gestión Profesional de Eventos</p>
            </div>
          </div>
          
          <div className="space-y-4 mt-8">
            <h2 className="text-2xl font-semibold text-foreground">
              Gestiona tus eventos de forma profesional
            </h2>
            <p className="text-muted-foreground">
              Control total sobre eventos, clientes, finanzas y más. Todo en un solo lugar.
            </p>
          </div>

        </div>

        {/* Right side - Login Form */}
        <Card className="bg-gradient-card border-border animate-fade-in-up">
          <CardHeader>
            <CardTitle className="text-2xl">Iniciar Sesión</CardTitle>
            <CardDescription>
              Ingresa tus credenciales para acceder al sistema
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleLogin} className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium text-foreground">Email</label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                  <Input
                    type="email"
                    placeholder="tu@email.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="pl-10"
                    required
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium text-foreground">Contraseña</label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                  <Input
                    type="password"
                    placeholder="••••••••"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="pl-10"
                    required
                  />
                </div>
              </div>

              <Button 
                type="submit" 
                className="w-full bg-gradient-primary hover:opacity-90 transition-opacity"
                disabled={isLoading}
              >
                {isLoading ? 'Iniciando sesión...' : 'Iniciar Sesión'}
              </Button>
            </form>

            <div className="mt-6 p-4 bg-muted/30 rounded-lg border border-border">
              <p className="text-xs text-muted-foreground text-center">
                <strong>Modo Demo:</strong> Haz clic en cualquier tarjeta de usuario arriba para acceder directamente
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}