import { useState } from 'react';
import { Plus, Trash2, Receipt } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { usePettyCash, useCreatePettyCashMutation, useDeletePettyCashMutation } from '@/hooks/useServiceData';
import { useRoleGuards } from '@/hooks/useRoleGuards';
import { toast } from 'sonner';

interface GastosTabProps {
  eventId: number;
  readOnly?: boolean;
}

export function GastosTab({ eventId, readOnly }: GastosTabProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [description, setDescription] = useState('');
  const [amount, setAmount] = useState('');
  const [receiptFile, setReceiptFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);
  const { data: expenses = [], isLoading } = usePettyCash(eventId);
  const createMutation = useCreatePettyCashMutation();
  const deleteMutation = useDeletePettyCashMutation();
  const { canManageExpenses } = useRoleGuards();

  const canEdit = canManageExpenses() && !readOnly;

  const handleCreate = async () => {
    if (!description.trim() || !amount || parseFloat(amount) <= 0) {
      toast.error('Ingrese descripción y monto válido');
      return;
    }

    setUploading(true);
    try {
      let receiptUrl = null;
      if (receiptFile) {
        const storageService = await import('@/services/storageService');
        receiptUrl = await storageService.storageService.uploadReceipt(eventId, receiptFile);
      }

      await createMutation.mutateAsync({
        event_id: eventId,
        description: description.trim(),
        amount: parseFloat(amount),
        expense_type: 'general',
        receipt_url: receiptUrl,
      });
      toast.success('Gasto agregado');
      setDescription('');
      setAmount('');
      setReceiptFile(null);
      setIsOpen(false);
    } catch (error) {
      toast.error('Error al agregar gasto');
      console.error(error);
    } finally {
      setUploading(false);
    }
  };

  const handleDelete = async (id: number) => {
    try {
      await deleteMutation.mutateAsync({ id, eventId });
      toast.success('Gasto eliminado');
    } catch (error) {
      toast.error('Error al eliminar gasto');
      console.error(error);
    }
  };

  const totalExpenses = expenses.reduce((sum, exp) => sum + (exp.amount || 0), 0);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold">Gastos del Evento</h2>
          <p className="text-muted-foreground">Total: S/ {totalExpenses.toFixed(2)}</p>
        </div>
        {canEdit && (
          <Dialog open={isOpen} onOpenChange={setIsOpen}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="mr-2 h-4 w-4" />
                Agregar Gasto
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Nuevo Gasto</DialogTitle>
              </DialogHeader>
              <div className="space-y-4">
                <div>
                  <Label htmlFor="description">Descripción</Label>
                  <Input
                    id="description"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    placeholder="Ej: Compra de ingredientes"
                  />
                </div>
                <div>
                  <Label htmlFor="amount">Monto (S/)</Label>
                  <Input
                    id="amount"
                    type="number"
                    step="0.01"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                    placeholder="0.00"
                  />
                </div>
                <div>
                  <Label htmlFor="receipt">Recibo (Opcional)</Label>
                  <Input
                    id="receipt"
                    type="file"
                    accept="image/*,.pdf"
                    onChange={(e) => setReceiptFile(e.target.files?.[0] || null)}
                  />
                </div>
                <Button onClick={handleCreate} className="w-full" disabled={uploading || createMutation.isPending}>
                  {uploading || createMutation.isPending ? 'Guardando...' : 'Guardar Gasto'}
                </Button>
              </div>
            </DialogContent>
          </Dialog>
        )}
      </div>

      {isLoading ? (
        <Card>
          <CardContent className="p-6">
            <p className="text-center text-muted-foreground">Cargando gastos...</p>
          </CardContent>
        </Card>
      ) : expenses.length === 0 ? (
        <Card>
          <CardContent className="p-6">
            <div className="text-center">
              <Receipt className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No hay gastos registrados</p>
            </div>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-2">
          {expenses.map((expense) => (
            <Card key={expense.id}>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-medium">{expense.description}</h3>
                    <p className="text-sm text-muted-foreground">
                      {new Date(expense.created_at).toLocaleDateString('es-ES')}
                    </p>
                  </div>
                  <div className="flex items-center space-x-4">
                    <p className="text-lg font-semibold">S/ {expense.amount.toFixed(2)}</p>
                    {canEdit && (
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => handleDelete(expense.id)}
                        disabled={deleteMutation.isPending}
                      >
                        <Trash2 className="h-4 w-4 text-destructive" />
                      </Button>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
