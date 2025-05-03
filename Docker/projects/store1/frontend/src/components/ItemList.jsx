import React, { useState } from 'react';
import { Button, Card } from '../styles';
import { FaEdit, FaTrash, FaEye } from 'react-icons/fa';
import { toast } from 'react-toastify';
import { getItems, deleteItem } from '../services/api';

const ItemList = ({ setEditingItem }) => {
  const [showItems, setShowItems] = useState(false);
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(false);

  const fetchItems = async () => {
    setLoading(true);
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

  const toggleItemsView = () => {
    if (!showItems) {
      fetchItems();
    }
    setShowItems(!showItems);
  };

  return (
    <div>
      <Button onClick={toggleItemsView} primary>
        <FaEye /> {showItems ? 'Hide Items' : 'View Items'}
      </Button>

      {showItems && (
        <div style={{ marginTop: '20px' }}>
          {loading ? (
            <div>Loading items...</div>
          ) : (
            items.map((item) => (
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
            ))
          )}
        </div>
      )}
    </div>
  );
};

export default ItemList;