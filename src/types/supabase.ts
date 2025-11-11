export type EventType = 'quince_años' | 'boda' | 'cumpleaños' | 'corporativo' | 'conference' | 'concert' | 'otro';
export type EventStatus = 'draft' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
export type ServiceType = 'con_comida' | 'solo_alquiler';

export interface SupabaseEvent {
  id: number;
  name: string;
  description?: string;
  type: EventType;
  status: EventStatus;
  date: string;
  end_date?: string;
  location: string;
  venue: string;
  attendees: number;
  max_attendees: number;
  service_type: ServiceType;
  food_tipo_plato?: string;
  food_cantidad_platos?: number;
  food_precio_por_plato?: number;
  food_incluye_cerveza?: boolean;
  food_tipo_pago?: 'cover' | 'compra_local';
  rental_cantidad_mesas?: number;
  rental_cantidad_vasos?: number;
  rental_incluye_decoracion?: boolean;
  rental_incluye_vigilancia?: boolean;
  client_id?: number;
  created_by?: string;
  image_url?: string;
  tags?: string[];
  notes?: string;
  created_at?: string;
  updated_at?: string;
}

export interface CreateEventInput {
  name: string;
  description?: string;
  type: EventType;
  status?: EventStatus;
  date: string;
  end_date?: string;
  location: string;
  venue: string;
  attendees?: number;
  max_attendees: number;
  service_type: ServiceType;
  food_tipo_plato?: string;
  food_cantidad_platos?: number;
  food_precio_por_plato?: number;
  food_incluye_cerveza?: boolean;
  food_tipo_pago?: 'cover' | 'compra_local';
  rental_cantidad_mesas?: number;
  rental_cantidad_vasos?: number;
  rental_incluye_decoracion?: boolean;
  rental_incluye_vigilancia?: boolean;
  client_id?: number;
  image_url?: string;
  tags?: string[];
  notes?: string;
}
