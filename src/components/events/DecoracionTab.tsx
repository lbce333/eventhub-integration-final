import { useState } from 'react';
import { Package, Upload, Image as ImageIcon } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { useDecoration } from '@/hooks/useServiceData';
import { useRoleGuards } from '@/hooks/useRoleGuards';
import { storageService } from '@/services/storageService';
import { toast } from 'sonner';

interface DecoracionTabProps {
  eventId: number;
  readOnly?: boolean;
}

export function DecoracionTab({ eventId, readOnly }: DecoracionTabProps) {
  const { data: decorations = [], isLoading } = useDecoration();
  const { hasFullAccess } = useRoleGuards();
  const [uploading, setUploading] = useState(false);
  const [images, setImages] = useState<any[]>([]);

  const canUpload = hasFullAccess() && !readOnly;

  const loadImages = async () => {
    try {
      const eventImages = await storageService.getEventImages(eventId);
      setImages(eventImages);
    } catch (error) {
      console.error('Error loading images:', error);
    }
  };

  useState(() => {
    loadImages();
  });

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploading(true);
    try {
      await storageService.uploadEventImage(eventId, file);
      toast.success('Imagen subida exitosamente');
      await loadImages();
    } catch (error) {
      toast.error('Error al subir imagen');
      console.error(error);
    } finally {
      setUploading(false);
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold">Decoración</h2>
          <p className="text-muted-foreground">Catálogo de decoraciones e imágenes del evento</p>
        </div>
        {canUpload && (
          <div>
            <Input
              type="file"
              accept="image/*"
              onChange={handleImageUpload}
              className="hidden"
              id="image-upload"
              disabled={uploading}
            />
            <Button asChild disabled={uploading}>
              <label htmlFor="image-upload" className="cursor-pointer">
                <Upload className="mr-2 h-4 w-4" />
                {uploading ? 'Subiendo...' : 'Subir Imagen'}
              </label>
            </Button>
          </div>
        )}
      </div>

      {images.length > 0 && (
        <div>
          <h3 className="text-lg font-semibold mb-2">Imágenes del Evento</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {images.map((img) => (
              <Card key={img.id}>
                <CardContent className="p-2">
                  <img src={img.url} alt={img.name} className="w-full h-32 object-cover rounded" />
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      )}

      {isLoading ? (
        <Card>
          <CardContent className="p-6">
            <p className="text-center text-muted-foreground">Cargando decoraciones...</p>
          </CardContent>
        </Card>
      ) : decorations.length === 0 ? (
        <Card>
          <CardContent className="p-6">
            <div className="text-center">
              <Package className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No hay decoraciones disponibles</p>
            </div>
          </CardContent>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {decorations.map((decoration) => (
            <Card key={decoration.id}>
              <CardContent className="p-4">
                <h3 className="font-medium">{decoration.name}</h3>
                <p className="text-sm text-muted-foreground mt-1">{decoration.description}</p>
                <p className="text-lg font-semibold mt-2">S/ {decoration.price?.toFixed(2) || '0.00'}</p>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
