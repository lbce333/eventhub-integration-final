import { supabase } from '@/lib/supabaseClient';

export interface Vegetable {
  id: string;
  name: string;
  unit: string;
  suggested_price_per_kg: number;
  created_at: string;
}

export interface Chili {
  id: string;
  name: string;
  unit: string;
  suggested_price_per_kg: number;
  is_spicy: boolean;
  created_at: string;
}

export interface EventIngredient {
  id: number;
  event_id: number;
  ingredient_name: string;
  quantity: number;
  unit: string;
  unit_cost: number;
  total_cost: number;
  registered_by?: string;
  registered_by_name: string;
  registered_at: string;
  notes?: string;
  created_at: string;
}

export interface CreateEventIngredient {
  event_id: number;
  ingredient_name: string;
  quantity: number;
  unit: string;
  unit_cost: number;
  total_cost: number;
  notes?: string;
}

export const ingredientsService = {
  async getVegetablesCatalog(): Promise<Vegetable[]> {
    const { data, error } = await supabase
      .from('vegetables_catalog')
      .select('*')
      .order('name');

    if (error) throw error;
    return data || [];
  },

  async getChilisCatalog(): Promise<Chili[]> {
    const { data, error } = await supabase
      .from('chilis_catalog')
      .select('*')
      .order('name');

    if (error) throw error;
    return data || [];
  },

  async getEventIngredients(eventId: number): Promise<EventIngredient[]> {
    const { data, error } = await supabase
      .from('event_ingredients')
      .select('*')
      .eq('event_id', eventId)
      .order('registered_at', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  async addEventIngredient(ingredient: CreateEventIngredient): Promise<EventIngredient> {
    const { data, error } = await supabase
      .from('event_ingredients')
      .insert(ingredient)
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async updateEventIngredient(
    id: number,
    updates: Partial<EventIngredient>
  ): Promise<EventIngredient> {
    const { data, error } = await supabase
      .from('event_ingredients')
      .update(updates)
      .eq('id', id)
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async deleteEventIngredient(id: number): Promise<void> {
    const { error } = await supabase
      .from('event_ingredients')
      .delete()
      .eq('id', id);

    if (error) throw error;
  },

  async calculateTotalIngredientsCost(eventId: number): Promise<number> {
    const { data, error } = await supabase
      .from('event_ingredients')
      .select('total_cost')
      .eq('event_id', eventId);

    if (error) throw error;
    return (data || []).reduce((sum, item) => sum + (item.total_cost || 0), 0);
  },
};
