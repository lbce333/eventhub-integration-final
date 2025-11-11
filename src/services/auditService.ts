import { supabase } from '@/lib/supabaseClient';

export interface AuditLog {
  id: number;
  user_id?: string;
  event_id?: number;
  action: string;
  section: string;
  description?: string;
  created_at: string;
}

export interface LogActionParams {
  eventId?: number;
  action: string;
  section: string;
  description: string;
}

export const auditService = {
  async logAction(params: LogActionParams): Promise<void> {
    const { data: session } = await supabase.auth.getSession();

    const { error } = await supabase
      .from('audit_logs')
      .insert({
        user_id: session?.session?.user?.id,
        event_id: params.eventId,
        action: params.action,
        section: params.section,
        description: params.description,
      });

    if (error) {
      console.error('Failed to log audit action:', error);
      // Don't throw - audit logging shouldn't break app flow
    }
  },

  async getAuditLogs(eventId?: number): Promise<AuditLog[]> {
    let query = supabase
      .from('audit_logs')
      .select('*')
      .order('created_at', { ascending: false });

    if (eventId !== undefined) {
      query = query.eq('event_id', eventId);
    }

    const { data, error } = await query.limit(100);

    if (error) throw error;
    return data || [];
  },

  async getRecentLogs(limit: number = 50): Promise<AuditLog[]> {
    const { data, error } = await supabase
      .from('audit_logs')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data || [];
  },

  async getLogsByUser(userId: string): Promise<AuditLog[]> {
    const { data, error } = await supabase
      .from('audit_logs')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(100);

    if (error) throw error;
    return data || [];
  },
};
