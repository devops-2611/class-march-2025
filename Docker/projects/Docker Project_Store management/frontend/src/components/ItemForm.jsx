import React, { useState, useEffect } from 'react';
import { Button, FormGroup, Label, Input, TextArea } from '../styles';
import { toast } from 'react-toastify';
import { createItem, updateItem } from '../services/api';

const ItemForm = ({ editingItem, setEditingItem, refreshItems }) => {
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    price: '',
    quantity: '',
  });

  useEffect(() => {
    if (editingItem) {
      setFormData({
        name: editingItem.name,
        description: editingItem.description || '',
        price: editingItem.price.toString(),
        quantity: editingItem.quantity.toString(),
      });
    } else {
      setFormData({
        name: '',
        description: '',
        price: '',
        quantity: '',
      });
    }
  }, [editingItem]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const itemData = {
        ...formData,
        price: parseFloat(formData.price),
        quantity: parseInt(formData.quantity),
      };

      if (editingItem) {
        await updateItem(editingItem.id, itemData);
        toast.success('Item updated successfully');
      } else {
        await createItem(itemData);
        toast.success('Item created successfully');
      }

      setEditingItem(null);
      refreshItems();
    } catch (error) {
      toast.error(`Failed to ${editingItem ? 'update' : 'create'} item`);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <FormGroup>
        <Label>Name</Label>
        <Input
          type="text"
          name="name"
          value={formData.name}
          onChange={handleChange}
          required
        />
      </FormGroup>

      <FormGroup>
        <Label>Description</Label>
        <TextArea
          name="description"
          value={formData.description}
          onChange={handleChange}
        />
      </FormGroup>

      <FormGroup>
        <Label>Price</Label>
        <Input
          type="number"
          name="price"
          value={formData.price}
          onChange={handleChange}
          min="0"
          step="0.01"
          required
        />
      </FormGroup>

      <FormGroup>
        <Label>Quantity</Label>
        <Input
          type="number"
          name="quantity"
          value={formData.quantity}
          onChange={handleChange}
          min="0"
          required
        />
      </FormGroup>

      <Button type="submit" primary>
        {editingItem ? 'Update Item' : 'Add Item'}
      </Button>
      {editingItem && (
        <Button type="button" onClick={() => setEditingItem(null)}>
          Cancel
        </Button>
      )}
    </form>
  );
};

export default ItemForm;