import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Calendar, Users, DollarSign } from 'lucide-react';
import { Sidebar } from '@/components/dashboard/Sidebar';
import { Header } from '@/components/dashboard/Header';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { useEvent } from '@/hooks/useServiceData';
import { useRoleGuards } from '@/hooks/useRoleGuards';
import { GastosTab } from '@/components/events/GastosTab';
import { StaffTab } from '@/components/events/StaffTab';
import { DecoracionTab } from '@/components/events/DecoracionTab';

export default function EventoDetalle() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const eventId = id;
  const { data: event, isLoading } = useEvent(eventId);
  const { canViewOnly } = useRoleGuards();

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background flex">
        <Sidebar />
        <div className="flex-1 flex flex-col">
          <Header />
          <main className="flex-1 p-8 flex items-center justify-center">
            <p className="text-muted-foreground">Cargando evento...</p>
          </main>
        </div>
      </div>
    );
  }

  if (!event) {
    return (
      <div className="min-h-screen bg-background flex">
        <Sidebar />
        <div className="flex-1 flex flex-col">
          <Header />
          <main className="flex-1 p-8 flex items-center justify-center">
            <div className="text-center">
              <p className="text-muted-foreground mb-4">Evento no encontrado</p>
              <Button onClick={() => navigate('/eventos')}>
                <ArrowLeft className="mr-2 h-4 w-4" />
                Volver a Eventos
              </Button>
            </div>
          </main>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background flex">
      <Sidebar />

      <div className="flex-1 flex flex-col">
        <Header />

        <main className="flex-1 p-8 overflow-auto">
          <div className="max-w-7xl mx-auto space-y-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-4">
                <Button variant="ghost" size="icon" onClick={() => navigate('/eventos')}>
                  <ArrowLeft className="h-5 w-5" />
                </Button>
                <div>
                  <h1 className="text-3xl font-bold text-foreground">{event.event_name}</h1>
                  <p className="text-muted-foreground">{event.event_type}</p>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Fecha</CardTitle>
                  <Calendar className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">
                    {new Date(event.event_date).toLocaleDateString('es-ES', {
                      day: 'numeric',
                      month: 'long',
                      year: 'numeric'
                    })}
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Invitados</CardTitle>
                  <Users className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{event.num_guests || 0}</div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Total</CardTitle>
                  <DollarSign className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">S/ {((event.food_cantidad_platos || 0) * (event.food_precio_por_plato || 0)).toFixed(2)}</div>
                </CardContent>
              </Card>
            </div>

            <Tabs defaultValue="gastos" className="space-y-4">
              <TabsList>
                <TabsTrigger value="gastos">Gastos</TabsTrigger>
                <TabsTrigger value="staff">Staff</TabsTrigger>
                <TabsTrigger value="decoracion">Decoración</TabsTrigger>
              </TabsList>

              <TabsContent value="gastos" className="space-y-4">
                <GastosTab eventId={eventId!} readOnly={canViewOnly()} />
              </TabsContent>

              <TabsContent value="staff" className="space-y-4">
                <StaffTab eventId={eventId!} readOnly={canViewOnly()} />
              </TabsContent>

              <TabsContent value="decoracion" className="space-y-4">
                <DecoracionTab eventId={eventId!} readOnly={canViewOnly()} />
              </TabsContent>
            </Tabs>
          </div>
        </main>
      </div>
    </div>
  );
}
