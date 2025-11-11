import { menuItemsService } from './menuItemsService';

export const menuService = {
  async getMenuItems() {
    return await menuItemsService.listMenuItems();
  },

  async getMenuItemById(id: string) {
    const items = await menuItemsService.listMenuItems();
    return items.find(item => item.id === id);
  },
};
