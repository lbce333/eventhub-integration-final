import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Search, Calendar, Users, DollarSign } from 'lucide-react';
import { Sidebar } from '@/components/dashboard/Sidebar';
import { Header } from '@/components/dashboard/Header';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { useEvents } from '@/hooks/useServiceData';
import { useRoleGuards } from '@/hooks/useRoleGuards';

export default function Eventos() {
  const navigate = useNavigate();
  const [searchTerm, setSearchTerm] = useState('');
  const { data: events = [], isLoading } = useEvents();
  const { canManageEvents } = useRoleGuards();

  const filteredEvents = events.filter(event =>
    event.event_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    event.event_type.toLowerCase().includes(searchTerm.toLowerCase()) ||
    (event.client?.name || '').toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getStatusBadge = (status?: string) => {
    const statusMap = {
      confirmed: { label: 'Confirmado', variant: 'default' as const },
      in_progress: { label: 'En Progreso', variant: 'secondary' as const },
      completed: { label: 'Completado', variant: 'default' as const },
      cancelled: { label: 'Cancelado', variant: 'destructive' as const },
    };
    return statusMap[status as keyof typeof statusMap] || { label: status || 'Pendiente', variant: 'secondary' as const };
  };

  return (
    <div className="min-h-screen bg-background flex">
      <Sidebar />

      <div className="flex-1 flex flex-col">
        <Header />

        <main className="flex-1 p-8 overflow-auto">
          <div className="max-w-7xl mx-auto space-y-6">
            <div className="flex items-center justify-between">
              <div>
                <h1 className="text-3xl font-bold text-foreground">Eventos</h1>
                <p className="text-muted-foreground">Gestiona todos tus eventos</p>
              </div>
              {canManageEvents() && (
                <Button onClick={() => navigate('/eventos/nuevo')}>
                  <Plus className="mr-2 h-4 w-4" />
                  Nuevo Evento
                </Button>
              )}
            </div>

            <div className="flex items-center space-x-4">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                <Input
                  placeholder="Buscar eventos por cliente o tipo..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>

            {isLoading ? (
              <div className="text-center py-12">
                <p className="text-muted-foreground">Cargando eventos...</p>
              </div>
            ) : filteredEvents.length === 0 ? (
              <div className="text-center py-12">
                <Calendar className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
                <p className="text-muted-foreground">
                  {searchTerm ? 'No se encontraron eventos' : 'No hay eventos registrados'}
                </p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {filteredEvents.map((event) => {
                  const statusInfo = getStatusBadge(event.status);
                  return (
                    <div
                      key={event.id}
                      onClick={() => navigate(`/eventos/${event.id}`)}
                      className="bg-card rounded-lg shadow p-6 cursor-pointer hover:shadow-lg transition-shadow"
                    >
                      <div className="flex items-start justify-between mb-4">
                        <div>
                          <h3 className="font-semibold text-lg">{event.event_name}</h3>
                          <p className="text-sm text-muted-foreground">{event.event_type}</p>
                        </div>
                        <Badge variant={statusInfo.variant}>{statusInfo.label}</Badge>
                      </div>

                      <div className="space-y-2">
                        <div className="flex items-center text-sm text-muted-foreground">
                          <Calendar className="mr-2 h-4 w-4" />
                          {new Date(event.event_date).toLocaleDateString('es-ES', {
                            day: 'numeric',
                            month: 'long',
                            year: 'numeric'
                          })}
                        </div>
                        <div className="flex items-center text-sm text-muted-foreground">
                          <Users className="mr-2 h-4 w-4" />
                          {event.num_guests || 0} invitados
                        </div>
                        <div className="flex items-center text-sm font-medium">
                          <DollarSign className="mr-2 h-4 w-4" />
                          S/ {(event.contract?.precio_total || 0).toFixed(2)}
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </main>
      </div>
    </div>
  );
}
