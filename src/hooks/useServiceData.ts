import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { ingredientsService } from '../services/ingredientsService';
import { menuItemsService } from '../services/menuItemsService';
import { decorationService } from '../services/decorationService';
import { staffRolesService } from '../services/staffRolesService';
import { pettyCashService } from '../services/pettyCashService';
import { auditService } from '../services/auditService';
import { eventsService } from '../services/eventsService';
import { eventAssignmentsService } from '../services/eventAssignmentsService';
import { staffService } from '../services/staffService';

export const useEvents = () => {
  return useQuery({
    queryKey: ['events'],
    queryFn: () => eventsService.listEvents(),
  });
};

export const useEvent = (id?: string) => {
  return useQuery({
    queryKey: ['events', id],
    queryFn: () => id ? eventsService.getEventById(id) : Promise.resolve(null),
    enabled: !!id,
  });
};

export const useCreateEventMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: any) => eventsService.createEvent(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['events'] });
    },
  });
};

export const useUpdateEventMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) =>
      eventsService.updateEvent(id, data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['events'] });
      queryClient.invalidateQueries({ queryKey: ['events', variables.id] });
    },
  });
};

export const useEventStaff = (eventId?: number) => {
  return useQuery({
    queryKey: ['eventStaff', eventId],
    queryFn: () => eventId ? staffService.getEventStaff(eventId) : Promise.resolve([]),
    enabled: !!eventId,
  });
};

export const useEventAssignments = (eventId?: number) => {
  return useQuery({
    queryKey: ['eventAssignments', eventId],
    queryFn: () => eventId ? eventAssignmentsService.listEventStaff(eventId) : Promise.resolve([]),
    enabled: !!eventId,
  });
};

export const useAddStaffAssignmentMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ eventId, userId }: { eventId: number; userId: string }) =>
      eventAssignmentsService.addStaffToEvent(eventId, userId),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['eventAssignments', variables.eventId] });
    },
  });
};

export const useRemoveStaffAssignmentMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ eventId, userId }: { eventId: number; userId: string }) =>
      eventAssignmentsService.removeStaffFromEvent(eventId, userId),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['eventAssignments', variables.eventId] });
    },
  });
};

export const useIngredients = () => {
  return useQuery({
    queryKey: ['ingredients'],
    queryFn: () => ingredientsService.listIngredients(),
  });
};

export const useMenuItems = () => {
  return useQuery({
    queryKey: ['menuItems'],
    queryFn: () => menuItemsService.listMenuItems(),
  });
};

export const useDecoration = () => {
  return useQuery({
    queryKey: ['decoration'],
    queryFn: () => decorationService.listDecorations(),
  });
};

export const useStaffRoles = () => {
  return useQuery({
    queryKey: ['staffRoles'],
    queryFn: () => staffRolesService.listStaffRoles(),
  });
};

export const usePettyCash = (eventId?: number) => {
  return useQuery({
    queryKey: ['pettyCash', eventId],
    queryFn: () => eventId ? pettyCashService.listByEvent(eventId) : Promise.resolve([]),
    enabled: !!eventId,
  });
};

export const useCreatePettyCashMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: any) => pettyCashService.create(data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['pettyCash', variables.event_id] });
      auditService.log('petty_cash', 'create', variables.event_id.toString(),
        `Created petty cash: ${variables.description}`);
    },
  });
};

export const useUpdatePettyCashMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) =>
      pettyCashService.update(id, data),
    onSuccess: (result) => {
      queryClient.invalidateQueries({ queryKey: ['pettyCash', result.event_id] });
      auditService.log('petty_cash', 'update', result.id.toString(),
        `Updated petty cash: ${result.description}`);
    },
  });
};

export const useDeletePettyCashMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, eventId }: { id: number; eventId: number }) =>
      pettyCashService.delete(id),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['pettyCash', variables.eventId] });
      auditService.log('petty_cash', 'delete', variables.id.toString(),
        'Deleted petty cash entry');
    },
  });
};
