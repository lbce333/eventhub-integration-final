import { useAuth } from '../contexts/AuthContext';

export type UserRole = 'admin' | 'socio' | 'coordinador' | 'encargado_compras' | 'servicio';

export const useRoleGuards = () => {
  const { user } = useAuth();
  const userRole = user?.role as UserRole | undefined;

  const canManageEvents = () => {
    return userRole === 'admin' || userRole === 'socio';
  };

  const canManageStaffAssignments = () => {
    return userRole === 'admin' || userRole === 'socio' || userRole === 'coordinador';
  };

  const canManageExpenses = () => {
    return userRole === 'admin' || userRole === 'socio' || userRole === 'encargado_compras';
  };

  const canViewOnly = () => {
    return userRole === 'servicio';
  };

  const hasFullAccess = () => {
    return userRole === 'admin' || userRole === 'socio';
  };

  return {
    userRole,
    canManageEvents,
    canManageStaffAssignments,
    canManageExpenses,
    canViewOnly,
    hasFullAccess,
  };
};
