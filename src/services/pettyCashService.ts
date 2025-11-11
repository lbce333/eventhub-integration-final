import { supabase } from '@/lib/supabaseClient';

export interface PettyCashStatus {
  event_id: number;
  budget: number;
  spent: number;
  refunds: number;
  remaining: number;
  total_movements: number;
  last_movement_at: string | null;
}

export interface PettyCashMovement {
  id: number;
  event_id: number;
  movement_type: 'budget_assignment' | 'expense' | 'adjustment' | 'refund';
  amount: number;
  description?: string;
  category?: string;
  receipt_url?: string;
  registered_by?: string;
  registered_by_name: string;
  registered_at: string;
  created_at: string;
}

export interface CreatePettyCashMovement {
  event_id: number;
  movement_type: 'budget_assignment' | 'expense' | 'adjustment' | 'refund';
  amount: number;
  description?: string;
  category?: string;
  receipt_url?: string;
}

export const pettyCashService = {
  async getPettyCashStatus(eventId: number): Promise<PettyCashStatus | null> {
    const { data, error } = await supabase
      .from('petty_cash_status')
      .select('*')
      .eq('event_id', eventId)
      .maybeSingle();

    if (error) throw error;
    return data;
  },

  async getMovements(eventId: number): Promise<PettyCashMovement[]> {
    const { data, error } = await supabase
      .from('petty_cash_movements')
      .select('*')
      .eq('event_id', eventId)
      .order('registered_at', { ascending: false });

    if (error) throw error;
    return data || [];
  },

  async assignBudget(
    eventId: number,
    amount: number,
    description: string
  ): Promise<PettyCashMovement> {
    const { data, error } = await supabase
      .from('petty_cash_movements')
      .insert({
        event_id: eventId,
        movement_type: 'budget_assignment',
        amount,
        description,
      })
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async recordExpense(
    eventId: number,
    amount: number,
    description: string,
    category?: string,
    receiptUrl?: string
  ): Promise<PettyCashMovement> {
    const { data, error } = await supabase
      .from('petty_cash_movements')
      .insert({
        event_id: eventId,
        movement_type: 'expense',
        amount,
        description,
        category,
        receipt_url: receiptUrl,
      })
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async recordAdjustment(
    eventId: number,
    amount: number,
    description: string
  ): Promise<PettyCashMovement> {
    const { data, error } = await supabase
      .from('petty_cash_movements')
      .insert({
        event_id: eventId,
        movement_type: 'adjustment',
        amount,
        description,
      })
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async recordRefund(
    eventId: number,
    amount: number,
    description: string
  ): Promise<PettyCashMovement> {
    const { data, error } = await supabase
      .from('petty_cash_movements')
      .insert({
        event_id: eventId,
        movement_type: 'refund',
        amount,
        description,
      })
      .select('*')
      .single();

    if (error) throw error;
    return data;
  },

  async deleteMovement(movementId: number): Promise<void> {
    const { error } = await supabase
      .from('petty_cash_movements')
      .delete()
      .eq('id', movementId);

    if (error) throw error;
  },
};
