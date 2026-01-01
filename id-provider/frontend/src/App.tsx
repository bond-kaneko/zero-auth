import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import HomePage from '~/pages/HomePage';
import ClientsPage from '~/pages/ClientsPage';
import ClientDetailPage from '~/pages/ClientDetailPage';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/clients" element={<ClientsPage />} />
        <Route path="/clients/:id" element={<ClientDetailPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
