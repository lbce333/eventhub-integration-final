import { supabase } from '@/lib/supabaseClient';

// Seed data extracted from Emergent mock arrays
const VEGETABLES_CATALOG = [
  { id: 'tomate', name: 'Tomate', suggested_price_per_kg: 3.50, unit: 'kg' },
  { id: 'cebolla', name: 'Cebolla', suggested_price_per_kg: 2.80, unit: 'kg' },
  { id: 'zanahoria', name: 'Zanahoria', suggested_price_per_kg: 2.00, unit: 'kg' },
  { id: 'papa', name: 'Papa', suggested_price_per_kg: 2.50, unit: 'kg' },
  { id: 'lechuga', name: 'Lechuga', suggested_price_per_kg: 2.00, unit: 'unidad' },
  { id: 'brocoli', name: 'Brócoli', suggested_price_per_kg: 4.50, unit: 'kg' },
  { id: 'coliflor', name: 'Coliflor', suggested_price_per_kg: 4.00, unit: 'kg' },
  { id: 'espinaca', name: 'Espinaca', suggested_price_per_kg: 5.00, unit: 'kg' },
  { id: 'calabaza', name: 'Calabaza', suggested_price_per_kg: 3.00, unit: 'kg' },
  { id: 'pimiento', name: 'Pimiento', suggested_price_per_kg: 4.50, unit: 'kg' },
  { id: 'ajo', name: 'Ajo', suggested_price_per_kg: 12.00, unit: 'kg' },
  { id: 'perejil', name: 'Perejil', suggested_price_per_kg: 3.00, unit: 'atado' },
  { id: 'culantro', name: 'Culantro', suggested_price_per_kg: 2.50, unit: 'atado' },
  { id: 'apio', name: 'Apio', suggested_price_per_kg: 3.50, unit: 'kg' },
  { id: 'choclo', name: 'Choclo', suggested_price_per_kg: 2.00, unit: 'unidad' },
];

const CHILIS_CATALOG = [
  { id: 'aji-amarillo', name: 'Ají Amarillo', suggested_price_per_kg: 8.00, unit: 'kg', is_spicy: true },
  { id: 'aji-panca', name: 'Ají Panca', suggested_price_per_kg: 7.50, unit: 'kg', is_spicy: true },
  { id: 'rocoto', name: 'Rocoto', suggested_price_per_kg: 6.00, unit: 'kg', is_spicy: true },
  { id: 'aji-limo', name: 'Ají Limo', suggested_price_per_kg: 10.00, unit: 'kg', is_spicy: true },
  { id: 'aji-verde', name: 'Ají Verde', suggested_price_per_kg: 5.50, unit: 'kg', is_spicy: true },
];

const DECORATION_PROVIDERS = [
  { id: 'jimmy', name: 'Jimmy' },
  { id: 'juan', name: 'Juan' },
  { id: 'maria', name: 'María Decoraciones' },
  { id: 'eventos-premium', name: 'Eventos Premium' },
];

const DECORATION_PACKAGES = [
  {
    id: 'cumple-completo-jimmy',
    name: 'Decoración Completa de Cumpleaños',
    provider_id: 'jimmy',
    provider_cost: 500,
    client_cost: 800,
    description: 'Paquete completo para cumpleaños con globos, mesa de dulces y decoración temática',
  },
  {
    id: 'flores-especial-maria',
    name: 'Decoración Especial con Flores',
    provider_id: 'maria',
    provider_cost: 700,
    client_cost: 1100,
    description: 'Arreglos florales premium y centros de mesa elegantes',
  },
  {
    id: 'boda-elegante-premium',
    name: 'Decoración de Boda Elegante',
    provider_id: 'eventos-premium',
    provider_cost: 1500,
    client_cost: 2500,
    description: 'Decoración completa para boda: arco, sillas, centros de mesa, iluminación',
  },
  {
    id: 'infantil-tematico-juan',
    name: 'Decoración Temática Infantil',
    provider_id: 'juan',
    provider_cost: 400,
    client_cost: 650,
    description: 'Decoración temática para fiestas infantiles (superhéroes, princesas, etc.)',
  },
];

const STAFF_ROLES_CATALOG = [
  {
    id: 'coordinador',
    name: 'Coordinador',
    default_rate: 15,
    rate_type: 'hourly' as const,
    has_system_access: true,
    description: 'Coordinador general del evento',
  },
  {
    id: 'encargado_compras',
    name: 'Encargado de Compras',
    default_rate: 10,
    rate_type: 'hourly' as const,
    has_system_access: true,
    description: 'Encargado de compras y gastos',
  },
  {
    id: 'mesero',
    name: 'Mesero',
    default_rate: 10,
    rate_type: 'hourly' as const,
    has_system_access: false,
    description: 'Mesero / Servicio de mesa',
  },
  {
    id: 'limpieza',
    name: 'Servicio de Limpieza',
    default_rate: 15,
    rate_type: 'hourly' as const,
    has_system_access: false,
    description: 'Personal de limpieza',
  },
  {
    id: 'servido',
    name: 'Servicio de Servido',
    default_rate: 5,
    rate_type: 'per_plate' as const,
    has_system_access: false,
    description: 'Personal de servido (tarifa por plato)',
  },
];

const MENU_ITEMS = [
  { id: 'pollo-parrilla', name: 'Pollo a la Parrilla', base_price: 50, category: 'principal', portions_per_recipe: 1 },
  { id: 'carne-asada', name: 'Carne Asada', base_price: 60, category: 'principal', portions_per_recipe: 1 },
  { id: 'pescado-frito', name: 'Pescado Frito', base_price: 55, category: 'principal', portions_per_recipe: 1 },
  { id: 'lomo-saltado', name: 'Lomo Saltado', base_price: 65, category: 'principal', portions_per_recipe: 1 },
  { id: 'arroz-pollo', name: 'Arroz con Pollo', base_price: 45, category: 'principal', portions_per_recipe: 1 },
  { id: 'tallarines-rojos', name: 'Tallarines Rojos', base_price: 40, category: 'principal', portions_per_recipe: 1 },
  { id: 'ceviche', name: 'Ceviche', base_price: 70, category: 'principal', portions_per_recipe: 1 },
  { id: 'parrillada-mixta', name: 'Parrillada Mixta', base_price: 80, category: 'principal', portions_per_recipe: 1 },
];

export async function seedDatabase(): Promise<{
  success: boolean;
  message: string;
  details: Record<string, number>;
}> {
  const details: Record<string, number> = {};

  try {
    // Seed vegetables
    const { data: vegetables, error: vegError } = await supabase
      .from('vegetables_catalog')
      .upsert(VEGETABLES_CATALOG, { onConflict: 'id' });
    if (vegError) throw vegError;
    details.vegetables = VEGETABLES_CATALOG.length;

    // Seed chilis
    const { data: chilis, error: chiliError } = await supabase
      .from('chilis_catalog')
      .upsert(CHILIS_CATALOG, { onConflict: 'id' });
    if (chiliError) throw chiliError;
    details.chilis = CHILIS_CATALOG.length;

    // Seed decoration providers
    const { data: providers, error: provError } = await supabase
      .from('decoration_providers')
      .upsert(DECORATION_PROVIDERS, { onConflict: 'id' });
    if (provError) throw provError;
    details.decoration_providers = DECORATION_PROVIDERS.length;

    // Seed decoration packages
    const { data: packages, error: packError } = await supabase
      .from('decoration_packages')
      .upsert(DECORATION_PACKAGES, { onConflict: 'id' });
    if (packError) throw packError;
    details.decoration_packages = DECORATION_PACKAGES.length;

    // Seed staff roles
    const { data: staffRoles, error: staffError } = await supabase
      .from('staff_roles_catalog')
      .upsert(STAFF_ROLES_CATALOG, { onConflict: 'id' });
    if (staffError) throw staffError;
    details.staff_roles = STAFF_ROLES_CATALOG.length;

    // Seed menu items
    const { data: menuItems, error: menuError } = await supabase
      .from('menu_dishes')
      .upsert(MENU_ITEMS, { onConflict: 'id' });
    if (menuError) throw menuError;
    details.menu_items = MENU_ITEMS.length;

    return {
      success: true,
      message: 'Database seeded successfully',
      details,
    };
  } catch (error: any) {
    console.error('Seed error:', error);
    return {
      success: false,
      message: error.message || 'Unknown error',
      details,
    };
  }
}
