import { useState } from 'react';
import { Plus, Trash2, Users as UsersIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { Input } from '@/components/ui/input';
import { useEventAssignments, useAddStaffAssignmentMutation, useRemoveStaffAssignmentMutation } from '@/hooks/useServiceData';
import { useRoleGuards } from '@/hooks/useRoleGuards';
import { toast } from 'sonner';

interface StaffTabProps {
  eventId: number;
  readOnly?: boolean;
}

export function StaffTab({ eventId, readOnly }: StaffTabProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [userId, setUserId] = useState('');
  const { data: assignments = [], isLoading } = useEventAssignments(eventId);
  const addMutation = useAddStaffAssignmentMutation();
  const removeMutation = useRemoveStaffAssignmentMutation();
  const { canManageStaffAssignments } = useRoleGuards();

  const canEdit = canManageStaffAssignments() && !readOnly;

  const handleAdd = async () => {
    if (!userId.trim()) {
      toast.error('Ingrese un ID de usuario válido');
      return;
    }

    try {
      await addMutation.mutateAsync({ eventId, userId: userId.trim() });
      toast.success('Staff asignado');
      setUserId('');
      setIsOpen(false);
    } catch (error) {
      toast.error('Error al asignar staff');
      console.error(error);
    }
  };

  const handleRemove = async (assignUserId: string) => {
    try {
      await removeMutation.mutateAsync({ eventId, userId: assignUserId });
      toast.success('Staff removido');
    } catch (error) {
      toast.error('Error al remover staff');
      console.error(error);
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold">Staff Asignado</h2>
          <p className="text-muted-foreground">Total: {assignments.length} miembros</p>
        </div>
        {canEdit && (
          <Dialog open={isOpen} onOpenChange={setIsOpen}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="mr-2 h-4 w-4" />
                Asignar Staff
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Asignar Staff al Evento</DialogTitle>
              </DialogHeader>
              <div className="space-y-4">
                <div>
                  <Label htmlFor="userId">User ID</Label>
                  <Input
                    id="userId"
                    value={userId}
                    onChange={(e) => setUserId(e.target.value)}
                    placeholder="UUID del usuario"
                  />
                </div>
                <Button onClick={handleAdd} className="w-full" disabled={addMutation.isPending}>
                  {addMutation.isPending ? 'Asignando...' : 'Asignar'}
                </Button>
              </div>
            </DialogContent>
          </Dialog>
        )}
      </div>

      {isLoading ? (
        <Card>
          <CardContent className="p-6">
            <p className="text-center text-muted-foreground">Cargando staff...</p>
          </CardContent>
        </Card>
      ) : assignments.length === 0 ? (
        <Card>
          <CardContent className="p-6">
            <div className="text-center">
              <UsersIcon className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No hay staff asignado</p>
            </div>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-2">
          {assignments.map((assignment) => (
            <Card key={assignment.id}>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-medium">Usuario: {assignment.user_id}</h3>
                    <p className="text-sm text-muted-foreground">
                      Asignado: {new Date(assignment.assigned_at).toLocaleDateString('es-ES')}
                    </p>
                  </div>
                  {canEdit && (
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => handleRemove(assignment.user_id)}
                      disabled={removeMutation.isPending}
                    >
                      <Trash2 className="h-4 w-4 text-destructive" />
                    </Button>
                  )}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
