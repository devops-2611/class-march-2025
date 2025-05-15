import styled, { createGlobalStyle } from 'styled-components';

export const GlobalStyle = createGlobalStyle`
  * {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  }

  body {
    background-color: #f5f5f5;
    color: #333;
  }
`;

export const Container = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
`;

export const Header = styled.header`
  background: linear-gradient(135deg, #6e8efb, #a777e3);
  color: white;
  padding: 20px 0;
  margin-bottom: 30px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
`;

export const Title = styled.h1`
  text-align: center;
  font-size: 2.5rem;
`;

export const Button = styled.button`
  background: ${props => props.primary ? '#6e8efb' : '#f5f5f5'};
  color: ${props => props.primary ? 'white' : '#333'};
  border: none;
  padding: 10px 20px;
  margin: 5px;
  border-radius: 5px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;

  &:hover {
    background: ${props => props.primary ? '#5a7df4' : '#e0e0e0'};
    transform: translateY(-2px);
  }

  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
`;

export const Card = styled.div`
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  padding: 20px;
  margin-bottom: 20px;
`;

export const FormGroup = styled.div`
  margin-bottom: 15px;
`;

export const Label = styled.label`
  display: block;
  margin-bottom: 5px;
  font-weight: 600;
`;

export const Input = styled.input`
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 16px;
`;

export const TextArea = styled.textarea`
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 16px;
  min-height: 100px;
`;

export const Table = styled.table`
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
  box-shadow: 0 0 10px rgba(0,0,0,0.1);
  background: white;
`;

export const TableHead = styled.thead`
  background-color: #6e8efb;
  color: white;
`;

export const TableHeader = styled.th`
  padding: 12px 15px;
  text-align: ${props => props.align || 'left'};
  font-weight: 600;
`;

export const TableRow = styled.tr`
  border-bottom: 1px solid #ddd;
  &:nth-child(even) {
    background-color: #f9f9f9;
  }
  &:hover {
    background-color: #f1f1f1;
  }
`;

export const TableCell = styled.td`
  padding: 12px 15px;
  text-align: ${props => props.align || 'left'};
`;

export const LoadingMessage = styled.div`
  padding: 20px;
  text-align: center;
  font-style: italic;
  color: #666;
`;

export const ErrorMessage = styled.div`
  padding: 20px;
  text-align: center;
  color: #ff6b6b;
  font-weight: 600;
`;