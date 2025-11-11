import { supabase } from '@/lib/supabaseClient';

export interface DecorationProvider {
  id: string;
  name: string;
  contact_phone?: string;
  email?: string;
  notes?: string;
  created_at: string;
}

export interface DecorationPackage {
  id: string;
  name: string;
  provider_id: string;
  provider_cost: number;
  client_cost: number;
  description?: string;
  created_at: string;
}

export interface EventDecoration {
  id: number;
  event_id: number;
  item: string;
  quantity: number;
  unit_price: number;
  registered_by?: string;
  registered_by_name: string;
  created_at: string;
}

export interface CreateEventDecoration {
  event_id: number;
  item: string;
  quantity: number;
  unit_price: number;
}

export const decorationService = {
  async getDecorationProviders(): Promise<DecorationProvider[]> {
    const { data, error } = await supabase
      .from('decoration_providers')
      .select('*')
      .order('name');

    if (error) throw error;
    return data || [];
  },

  async getDecorationPackages(): Promise<DecorationPackage[]> {
    const { data, error } = await supabase
      .from('decoration_packages')
      .select('*')
      .order('name');

    if (error) throw error;
    return data || [];
  },

  async getPackagesByProvider(providerId: string): Promise<DecorationPackage[]> {
    const { data, error } = await supabase
      .from('decoration_packages')
      .select('*')
      .eq('provider_id', providerId)
      .order('name');

    if (error) throw error;
    return data || [];
  },

  async getEventDecoration(eventId: number): Promise<EventDecoration[]> {
    const { data, error } = await supabase
      .from('event_decoration')
      .select('*')
      .eq('event_id', eventId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  async addEventDecoration(decoration: CreateEventDecoration): Promise<EventDecoration> {
    const { data, error } = await supabase
      .from('event_decoration')
      .insert(decoration)
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async updateEventDecoration(
    id: number,
    updates: Partial<EventDecoration>
  ): Promise<EventDecoration> {
    const { data, error } = await supabase
      .from('event_decoration')
      .update(updates)
      .eq('id', id)
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async deleteEventDecoration(id: number): Promise<void> {
    const { error } = await supabase
      .from('event_decoration')
      .delete()
      .eq('id', id);

    if (error) throw error;
  },
};
