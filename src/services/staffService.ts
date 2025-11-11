import { supabase } from '@/lib/supabaseClient';

export interface StaffRole {
  id: string;
  name: string;
  default_rate: number;
  rate_type: 'hourly' | 'per_plate' | 'fixed';
  has_system_access: boolean;
  description?: string;
  created_at: string;
}

export interface EventStaff {
  id: number;
  event_id: number;
  user_id?: string;
  name: string;
  role: string;
  hours?: number;
  hourly_rate?: number;
  plates_served?: number;
  plate_rate?: number;
  fixed_payment?: number;
  registered_by?: string;
  registered_by_name: string;
  created_at: string;
}

export interface CreateEventStaff {
  event_id: number;
  user_id?: string;
  name: string;
  role: string;
  hours?: number;
  hourly_rate?: number;
  plates_served?: number;
  plate_rate?: number;
  fixed_payment?: number;
}

export const staffService = {
  async getStaffRolesCatalog(): Promise<StaffRole[]> {
    const { data, error } = await supabase
      .from('staff_roles_catalog')
      .select('*')
      .order('name');

    if (error) throw error;
    return data || [];
  },

  async getEventStaff(eventId: number): Promise<EventStaff[]> {
    const { data, error } = await supabase
      .from('event_staff')
      .select('*')
      .eq('event_id', eventId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  async addEventStaff(staff: CreateEventStaff): Promise<EventStaff> {
    const { data, error } = await supabase
      .from('event_staff')
      .insert(staff)
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async updateEventStaff(
    id: number,
    updates: Partial<EventStaff>
  ): Promise<EventStaff> {
    const { data, error } = await supabase
      .from('event_staff')
      .update(updates)
      .eq('id', id)
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async deleteEventStaff(id: number): Promise<void> {
    const { error } = await supabase
      .from('event_staff')
      .delete()
      .eq('id', id);

    if (error) throw error;
  },

  async calculateTotalStaffCost(eventId: number): Promise<number> {
    const staff = await this.getEventStaff(eventId);

    return staff.reduce((total, member) => {
      if (member.fixed_payment) {
        return total + member.fixed_payment;
      } else if (member.hourly_rate && member.hours) {
        return total + (member.hourly_rate * member.hours);
      } else if (member.plate_rate && member.plates_served) {
        return total + (member.plate_rate * member.plates_served);
      }
      return total;
    }, 0);
  },
};
