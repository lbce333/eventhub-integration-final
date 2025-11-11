import { supabase } from '@/lib/supabaseClient';

export interface MenuItem {
  id: string;
  name: string;
  category: string;
  base_price: number;
  portions_per_recipe?: number;
  description?: string;
  created_at: string;
}

export interface DishIngredient {
  id: number;
  dish_id: string;
  ingredient_name: string;
  base_quantity: number;
  unit: string;
  is_vegetable: boolean;
  created_at: string;
}

export const menuItemsService = {
  async getMenuItems(): Promise<MenuItem[]> {
    const { data, error } = await supabase
      .from('menu_dishes')
      .select('*')
      .order('name');

    if (error) throw error;
    return data || [];
  },

  async getMenuItemById(id: string): Promise<MenuItem | null> {
    const { data, error } = await supabase
      .from('menu_dishes')
      .select('*')
      .eq('id', id)
      .maybeSingle();

    if (error) throw error;
    return data;
  },

  async getMenuItemsByCategory(category: string): Promise<MenuItem[]> {
    const { data, error } = await supabase
      .from('menu_dishes')
      .select('*')
      .eq('category', category)
      .order('name');

    if (error) throw error;
    return data || [];
  },

  async getDishIngredients(dishId: string): Promise<DishIngredient[]> {
    const { data, error } = await supabase
      .from('dish_ingredients')
      .select('*')
      .eq('dish_id', dishId)
      .order('ingredient_name');

    if (error) throw error;
    return data || [];
  },

  async createMenuItem(item: Omit<MenuItem, 'created_at'>): Promise<MenuItem> {
    const { data, error } = await supabase
      .from('menu_dishes')
      .insert(item)
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async updateMenuItem(id: string, updates: Partial<MenuItem>): Promise<MenuItem> {
    const { data, error } = await supabase
      .from('menu_dishes')
      .update(updates)
      .eq('id', id)
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async deleteMenuItem(id: string): Promise<void> {
    const { error } = await supabase
      .from('menu_dishes')
      .delete()
      .eq('id', id);

    if (error) throw error;
  },
};
