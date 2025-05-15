import React, { useState } from 'react';
import { GlobalStyle, Container, Header, Title } from './styles';
import ItemList from './components/ItemList';
import ItemForm from './components/ItemForm';

const App = () => {
  const [editingItem, setEditingItem] = useState(null);
  const [refreshKey, setRefreshKey] = useState(0);

  const refreshItems = () => {
    setRefreshKey(prevKey => prevKey + 1);
  };

  return (
    <>
      <GlobalStyle />
      <Header>
        <Title>Store Management System</Title>
      </Header>
      <Container>
        <ItemForm 
          editingItem={editingItem} 
          setEditingItem={setEditingItem} 
          refreshItems={refreshItems} 
        />
        <ItemList 
          key={refreshKey} 
          setEditingItem={setEditingItem} 
        />
      </Container>
    </>
  );
};

export default App;