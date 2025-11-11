import { supabase } from '@/lib/supabaseClient';

export interface Event {
  id: string;
  client_id: string;
  assigned_to?: string;
  event_name: string;
  event_type: 'quince_años' | 'boda' | 'cumpleaños' | 'corporativo' | 'otro';
  status: 'draft' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
  is_reservation: boolean;
  event_date: string;
  event_time?: string;
  location?: string;
  num_guests?: number;
  service_type: 'con_comida' | 'solo_alquiler';
  notes?: string;
  special_requirements?: string;
  created_at?: string;
  updated_at?: string;
  created_by?: string;
  updated_by?: string;

  client?: {
    name: string;
    last_name?: string;
    email?: string;
    phone: string;
  };

  contract?: {
    precio_total: number;
    pago_adelantado: number;
    saldo_pendiente: number;
    presupuesto_asignado: number;
  };

  food_details?: {
    tipo_de_plato: string;
    cantidad_de_platos: number;
    precio_por_plato: number;
  };
}

export interface CreateEventDTO {
  client_id: string;
  assigned_to?: string;
  event_name: string;
  event_type: 'quince_años' | 'boda' | 'cumpleaños' | 'corporativo' | 'otro';
  status?: 'draft' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
  is_reservation?: boolean;
  event_date: string;
  event_time?: string;
  location?: string;
  num_guests?: number;
  service_type: 'con_comida' | 'solo_alquiler';
  notes?: string;
  special_requirements?: string;
}

export const eventsService = {
  async listEvents(): Promise<Event[]> {
    const { data, error } = await supabase
      .from('events')
      .select(`
        *,
        client:clients(*),
        contract:event_contracts(*),
        food_details:event_food_details(*)
      `)
      .order('event_date', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  async getEventById(id: string): Promise<Event | null> {
    const { data, error } = await supabase
      .from('events')
      .select(`
        *,
        client:clients(*),
        contract:event_contracts(*),
        food_details:event_food_details(*),
        beverages:event_beverages(*),
        decoration:event_decoration(*),
        staff:event_staff(*),
        expenses:event_expenses(*),
        incomes:event_incomes(*)
      `)
      .eq('id', id)
      .maybeSingle();

    if (error) throw error;
    return data;
  },

  async createEvent(event: CreateEventDTO): Promise<Event> {
    const { data, error } = await supabase
      .from('events')
      .insert(event)
      .select(`
        *,
        client:clients(*),
        contract:event_contracts(*),
        food_details:event_food_details(*)
      `)
      .single();

    if (error) throw error;
    return data;
  },

  async updateEvent(id: string, updates: Partial<Event>): Promise<Event> {
    const { data, error } = await supabase
      .from('events')
      .update(updates)
      .eq('id', id)
      .select(`
        *,
        client:clients(*),
        contract:event_contracts(*),
        food_details:event_food_details(*)
      `)
      .single();

    if (error) throw error;
    return data;
  },

  async deleteEvent(id: string): Promise<void> {
    const { error } = await supabase
      .from('events')
      .delete()
      .eq('id', id);

    if (error) throw error;
  },

  async getUpcomingEvents(): Promise<Event[]> {
    const today = new Date().toISOString().split('T')[0];
    const { data, error } = await supabase
      .from('events')
      .select(`
        *,
        client:clients(*),
        contract:event_contracts(*),
        food_details:event_food_details(*)
      `)
      .gte('event_date', today)
      .order('event_date', { ascending: true })
      .limit(10);

    if (error) throw error;
    return data || [];
  },
};
