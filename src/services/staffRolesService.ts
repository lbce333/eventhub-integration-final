import { supabase } from '@/lib/supabaseClient';

export interface StaffRoleCatalog {
  id: string;
  name: string;
  default_rate: number;
  rate_type: 'hourly' | 'per_plate' | 'fixed';
  has_system_access: boolean;
  description?: string;
  created_at: string;
}

export const staffRolesService = {
  async getStaffRoles(): Promise<StaffRoleCatalog[]> {
    const { data, error } = await supabase
      .from('staff_roles_catalog')
      .select('*')
      .order('name');

    if (error) throw error;
    return data || [];
  },

  async getStaffRoleById(id: string): Promise<StaffRoleCatalog | null> {
    const { data, error } = await supabase
      .from('staff_roles_catalog')
      .select('*')
      .eq('id', id)
      .maybeSingle();

    if (error) throw error;
    return data;
  },

  async getStaffRolesByAccessLevel(hasAccess: boolean): Promise<StaffRoleCatalog[]> {
    const { data, error } = await supabase
      .from('staff_roles_catalog')
      .select('*')
      .eq('has_system_access', hasAccess)
      .order('name');

    if (error) throw error;
    return data || [];
  },

  async createStaffRole(role: Omit<StaffRoleCatalog, 'created_at'>): Promise<StaffRoleCatalog> {
    const { data, error } = await supabase
      .from('staff_roles_catalog')
      .insert(role)
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async updateStaffRole(id: string, updates: Partial<StaffRoleCatalog>): Promise<StaffRoleCatalog> {
    const { data, error } = await supabase
      .from('staff_roles_catalog')
      .update(updates)
      .eq('id', id)
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async deleteStaffRole(id: string): Promise<void> {
    const { error } = await supabase
      .from('staff_roles_catalog')
      .delete()
      .eq('id', id);

    if (error) throw error;
  },
};
