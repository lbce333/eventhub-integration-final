import { Calendar, CheckCircle2, Clock, DollarSign } from "lucide-react";
import { Sidebar } from "@/components/dashboard/Sidebar";
import { Header } from "@/components/dashboard/Header";
import { MetricCard } from "@/components/dashboard/MetricCard";
import { useAuth } from "@/contexts/AuthContext";
import { useEvents } from "@/hooks/useServiceData";
import { useRoleGuards } from "@/hooks/useRoleGuards";
import { useEffect, useMemo } from "react";
import { useNavigate } from "react-router-dom";

export default function Dashboard() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const { canViewOnly } = useRoleGuards();
  const { data: events = [], isLoading } = useEvents();

  useEffect(() => {
    if (canViewOnly()) {
      navigate('/eventos');
    }
  }, [canViewOnly, navigate]);

  const metrics = useMemo(() => {
    const now = new Date();
    const currentMonth = now.getMonth();
    const currentYear = now.getFullYear();

    const eventosEsteMes = events.filter(event => {
      const eventDate = new Date(event.event_date);
      return eventDate.getMonth() === currentMonth && eventDate.getFullYear() === currentYear;
    }).length;

    const eventosRealizados = events.filter(event => event.status === 'completed').length;

    const eventosPorRealizar = events.filter(event =>
      event.status === 'confirmed' || event.status === 'in_progress' || event.status === 'draft'
    ).length;

    const ingresosTotalesMes = events
      .filter(event => {
        const eventDate = new Date(event.event_date);
        return eventDate.getMonth() === currentMonth && eventDate.getFullYear() === currentYear;
      })
      .reduce((sum, event) => {
        const total = event.contract?.precio_total || 0;
        return sum + total;
      }, 0);

    return {
      eventosEsteMes,
      eventosRealizados,
      eventosPorRealizar,
      ingresosTotalesMes,
    };
  }, [events]);

  if (canViewOnly()) {
    return null;
  }

  return (
    <div className="min-h-screen bg-background flex">
      <Sidebar />

      <div className="flex-1 flex flex-col">
        <Header />

        <main className="flex-1 p-8 overflow-auto">
          <div className="max-w-7xl mx-auto space-y-8">
            <div className="animate-fade-in">
              <h1 className="text-3xl font-bold text-foreground mb-2">
                Bienvenido al Panel de Control
              </h1>
              <p className="text-muted-foreground">
                Gestiona tus eventos y visualiza el rendimiento de tu local
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <MetricCard
                title="Eventos Este Mes"
                value={isLoading ? "..." : metrics.eventosEsteMes.toString()}
                icon={Calendar}
                trend={{ value: 0, isPositive: true }}
              />
              <MetricCard
                title="Eventos Realizados"
                value={isLoading ? "..." : metrics.eventosRealizados.toString()}
                icon={CheckCircle2}
                trend={{ value: 0, isPositive: true }}
              />
              <MetricCard
                title="Por Realizar"
                value={isLoading ? "..." : metrics.eventosPorRealizar.toString()}
                icon={Clock}
                trend={{ value: 0, isPositive: true }}
              />
              <MetricCard
                title="Ingresos del Mes"
                value={isLoading ? "..." : `S/ ${metrics.ingresosTotalesMes.toFixed(2)}`}
                icon={DollarSign}
                trend={{ value: 0, isPositive: true }}
              />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              <div className="lg:col-span-2">
                <div className="bg-card rounded-lg shadow p-6">
                  <h2 className="text-xl font-semibold mb-4">Próximos Eventos</h2>
                  {isLoading ? (
                    <p className="text-muted-foreground">Cargando eventos...</p>
                  ) : events.length === 0 ? (
                    <p className="text-muted-foreground">No hay eventos registrados</p>
                  ) : (
                    <div className="space-y-4">
                      {events.slice(0, 5).map((event) => {
                        const totalAmount = event.contract?.precio_total || 0;
                        return (
                          <div key={event.id} className="flex items-center justify-between p-4 bg-background rounded-lg">
                            <div>
                              <h3 className="font-medium">{event.event_name}</h3>
                              <p className="text-sm text-muted-foreground">
                                {event.event_type} - {new Date(event.event_date).toLocaleDateString()}
                              </p>
                            </div>
                            <div className="text-right">
                              <p className="font-medium">S/ {totalAmount.toFixed(2)}</p>
                              <p className="text-sm text-muted-foreground">{event.num_guests || 0} invitados</p>
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}
