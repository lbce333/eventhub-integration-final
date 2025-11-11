# EventHub - Event Management System

Complete event management system built with React, TypeScript, and Supabase.

## Features

- Event creation and management
- Client management
- Financial tracking (incomes, expenses)
- Inventory/warehouse management
- Staff assignments
- Role-based access control (Admin, Coordinador, Encargado Compras)
- Audit logging

## Tech Stack

- **Frontend:** React 18, TypeScript, Vite
- **UI:** TailwindCSS, shadcn/ui components
- **Backend:** Supabase (PostgreSQL + Auth + Storage)
- **State Management:** React Query
- **Routing:** React Router v7

## Prerequisites

- Node.js 18+ and npm
- Supabase account and project

## Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd eventhub-integration-final
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
```bash
cp .env.example .env
```

Edit `.env` with your Supabase credentials:
```env
VITE_SUPABASE_URL=https://tvpaanmxhjhwljjfsuvd.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
VITE_PUBLIC_SITE_URL=http://localhost:5173
VITE_ENABLE_SEED=false
```

4. Apply database migrations:
   - Go to your Supabase project dashboard
   - Navigate to SQL Editor
   - Run migrations in `supabase/migrations/` directory in order

5. Start development server:
```bash
npm run dev
```

## Database Schema

The system uses 13 tables:
- `roles` - User role definitions
- `users` - System users
- `clients` - Event clients
- `events` - Main events table
- `event_contracts` - Financial contracts
- `event_food_details` - Food service details
- `event_beverages` - Beverage tracking
- `event_decoration` - Decoration items
- `event_staff` - Staff assignments
- `event_expenses` - Expense tracking
- `event_incomes` - Income tracking
- `warehouse_movements` - Inventory movements
- `audit_log` - System audit trail

## User Roles

- **Admin (role_id=1):** Full system access
- **Coordinador (role_id=2):** Manage assigned events, add expenses (otros), add incomes (kiosco, horas_extras)
- **Encargado Compras (role_id=3):** View assigned events, add food expenses

## Storage Buckets

- `event-images` - Event photos and gallery
- `expense-receipts` - Expense receipt uploads

## Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint
- `npm run typecheck` - Run TypeScript type checking

## Documentation

- `docs/INTEGRATION_STATUS.md` - Integration status report
- `docs/SCHEMA_CORRECTED.md` - Complete database schema reference
- `docs/SUPABASE_SETUP.md` - Supabase configuration guide
- `docs/DEPLOY_VERCEL.md` - Deployment instructions
- `docs/ROLE_GUARDS_MATRIX.md` - RLS policy reference

## Production Deployment

See `docs/DEPLOY_VERCEL.md` for detailed deployment instructions.

## License

Proprietary - All rights reserved
