import { supabase } from '@/lib/supabaseClient';

export interface EventAssignment {
  id: number;
  event_id: number;
  user_id: string;
  assigned_at: string;
  assigned_by: string;
}

export const eventAssignmentsService = {
  async addStaffToEvent(eventId: number, userId: string): Promise<EventAssignment> {
    const { data, error } = await supabase
      .from('event_assignments')
      .insert({ event_id: eventId, user_id: userId })
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async listEventStaff(eventId: number): Promise<EventAssignment[]> {
    const { data, error } = await supabase
      .from('event_assignments')
      .select('*')
      .eq('event_id', eventId)
      .order('assigned_at', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  async removeStaffFromEvent(eventId: number, userId: string): Promise<void> {
    const { error } = await supabase
      .from('event_assignments')
      .delete()
      .eq('event_id', eventId)
      .eq('user_id', userId);

    if (error) throw error;
  },
};
