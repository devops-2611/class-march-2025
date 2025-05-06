import React, { useState, useEffect } from 'react';
import { 
  Button, 
  Table, 
  TableHead, 
  TableHeader, 
  TableRow, 
  TableCell,
  LoadingMessage,
  ErrorMessage
} from '../styles';
import { FaEye, FaEdit, FaTrash } from 'react-icons/fa';
import { toast } from 'react-toastify';
import { getItems, deleteItem } from '../services/api';

const ItemList = ({ setEditingItem }) => {
  const [showTable, setShowTable] = useState(false);
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const fetchItems = async () => {
    setLoading(true);
    setError(null);
    try {
      const { data } = await getItems();
      setItems(data);
    } catch (err) {
      console.error('Error fetching items:', err);
      setError('Failed to load items');
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
        fetchItems(); // Refresh the table
      } catch (err) {
        console.error('Error deleting item:', err);
        toast.error('Failed to delete item');
      }
    }
  };

  const toggleTable = async () => {
    if (!showTable) {
      await fetchItems();
    }
    setShowTable(!showTable);
  };

  // Format price safely
  const formatPrice = (price) => {
    if (typeof price !== 'number') {
      price = parseFloat(price) || 0;
    }
    return price.toFixed(2);
  };

  return (
    <div>
      <Button onClick={toggleTable} primary>
        <FaEye /> {showTable ? 'Hide Items' : 'View Items'}
      </Button>

      {showTable && (
        <div style={{ marginTop: '20px', overflowX: 'auto' }}>
          {loading ? (
            <LoadingMessage>Loading items...</LoadingMessage>
          ) : error ? (
            <ErrorMessage>{error}</ErrorMessage>
          ) : items.length === 0 ? (
            <LoadingMessage>No items found</LoadingMessage>
          ) : (
            <Table>
              <TableHead>
                <TableRow>
                  <TableHeader>ID</TableHeader>
                  <TableHeader>Name</TableHeader>
                  <TableHeader>Description</TableHeader>
                  <TableHeader align="right">Price (INR)</TableHeader>
                  <TableHeader align="right">Quantity</TableHeader>
                  <TableHeader align="center">Actions</TableHeader>
                </TableRow>
              </TableHead>
              <tbody>
                {items.map((item) => (
                  <TableRow key={item.id}>
                    <TableCell>{item.id}</TableCell>
                    <TableCell>{item.name}</TableCell>
                    <TableCell>{item.description || '-'}</TableCell>
                    <TableCell align="right">{formatPrice(item.price)}</TableCell>
                    <TableCell align="right">{item.quantity}</TableCell>
                    <TableCell align="center">
                      <Button 
                        onClick={() => setEditingItem(item)}
                        style={{ margin: '0 5px', padding: '5px 10px' }}
                      >
                        <FaEdit />
                      </Button>
                      <Button 
                        onClick={() => handleDelete(item.id)}
                        style={{ 
                          margin: '0 5px', 
                          padding: '5px 10px', 
                          backgroundColor: '#ff6b6b',
                          color: 'white'
                        }}
                      >
                        <FaTrash />
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </tbody>
            </Table>
          )}
        </div>
      )}
    </div>
  );
};

export default ItemList;