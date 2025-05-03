import React, { useState, useEffect } from 'react';
import { Button, Card } from '../styles';
import { FaEdit, FaTrash } from 'react-icons/fa';
import { toast } from 'react-toastify';
import { getItems, deleteItem } from '../services/api';

const ItemList = ({ setEditingItem }) => {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchItems();
  }, []);

  const fetchItems = async () => {
    try {
      const { data } = await getItems();
      setItems(data);
    } catch (error) {
      toast.error('Failed to load items');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this item?')) {
      try {
        await deleteItem(id);
        toast.success('Item deleted successfully');
        fetchItems();
      } catch (error) {
        toast.error('Failed to delete item');
      }
    }
  };

  if (loading) return <div>Loading...</div>;

  return (
    <div>
      {items.map((item) => (
        <Card key={item.id}>
          <h3>{item.name}</h3>
          <p>{item.description}</p>
          <p>Price: ${item.price}</p>
          <p>Quantity: {item.quantity}</p>
          <div>
            <Button onClick={() => setEditingItem(item)}>
              <FaEdit /> Edit
            </Button>
            <Button onClick={() => handleDelete(item.id)}>
              <FaTrash /> Delete
            </Button>
          </div>
        </Card>
      ))}
    </div>
  );
};

export default ItemList;