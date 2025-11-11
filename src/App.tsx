import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'sonner';
import { AuthProvider } from './contexts/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';
import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';
import Eventos from './pages/Eventos';
import EventoDetalle from './pages/EventoDetalle';
import Almacen from './pages/Almacen';
import Finanzas from './pages/Finanzas';
import Clientes from './pages/Clientes';
import Configuracion from './pages/Configuracion';
import AdminSeed from './pages/AdminSeed';
import Health from './pages/Health';

const ENABLE_SEED = import.meta.env.VITE_ENABLE_SEED === 'true';

function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/health" element={<Health />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />

          <Route element={<ProtectedRoute />}>
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/eventos" element={<Eventos />} />
            <Route path="/eventos/:id" element={<EventoDetalle />} />
            <Route path="/almacen" element={<Almacen />} />
            <Route path="/finanzas" element={<Finanzas />} />
            <Route path="/clientes" element={<Clientes />} />
            <Route path="/configuracion" element={<Configuracion />} />
            {ENABLE_SEED && <Route path="/admin/seed" element={<AdminSeed />} />}
          </Route>

          <Route path="/" element={<Navigate to="/dashboard" replace />} />
        </Routes>
        <Toaster position="top-right" />
      </AuthProvider>
    </BrowserRouter>
  );
}

export default App;
