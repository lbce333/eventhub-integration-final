import { supabase } from '@/lib/supabaseClient';

export interface StorageFile {
  name: string;
  id: string;
  created_at: string;
  updated_at: string;
  url: string;
}

export const storageService = {
  async uploadEventImage(eventId: number, file: File): Promise<string> {
    const fileExt = file.name.split('.').pop();
    const fileName = `${Date.now()}.${fileExt}`;
    const filePath = `events/${eventId}/${fileName}`;

    const { error } = await supabase.storage
      .from('event-images')
      .upload(filePath, file);

    if (error) throw error;

    const { data: urlData } = supabase.storage
      .from('event-images')
      .getPublicUrl(filePath);

    return urlData.publicUrl;
  },

  async getEventImages(eventId: number): Promise<StorageFile[]> {
    const { data, error } = await supabase.storage
      .from('event-images')
      .list(`events/${eventId}`);

    if (error) throw error;

    return (data || []).map(file => ({
      ...file,
      url: supabase.storage
        .from('event-images')
        .getPublicUrl(`events/${eventId}/${file.name}`).data.publicUrl,
    }));
  },

  async deleteEventImage(eventId: number, fileName: string): Promise<void> {
    const { error } = await supabase.storage
      .from('event-images')
      .remove([`events/${eventId}/${fileName}`]);

    if (error) throw error;
  },

  async uploadReceipt(eventId: number, file: File): Promise<string> {
    const fileExt = file.name.split('.').pop();
    const fileName = `${Date.now()}.${fileExt}`;
    const filePath = `receipts/${eventId}/${fileName}`;

    const { error } = await supabase.storage
      .from('expense-receipts')
      .upload(filePath, file);

    if (error) throw error;

    const { data: urlData } = supabase.storage
      .from('expense-receipts')
      .getPublicUrl(filePath);

    return urlData.publicUrl;
  },

  async getReceipts(eventId: number): Promise<StorageFile[]> {
    const { data, error } = await supabase.storage
      .from('expense-receipts')
      .list(`receipts/${eventId}`);

    if (error) throw error;

    return (data || []).map(file => ({
      ...file,
      url: supabase.storage
        .from('expense-receipts')
        .getPublicUrl(`receipts/${eventId}/${file.name}`).data.publicUrl,
    }));
  },

  async deleteReceipt(eventId: number, fileName: string): Promise<void> {
    const { error } = await supabase.storage
      .from('expense-receipts')
      .remove([`receipts/${eventId}/${fileName}`]);

    if (error) throw error;
  },
};
