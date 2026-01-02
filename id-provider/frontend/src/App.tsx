import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'

import ClientDetailPage from '~/pages/ClientDetailPage'
import ClientsPage from '~/pages/ClientsPage'
import HomePage from '~/pages/HomePage'

import type { JSX } from 'react'

function App(): JSX.Element {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/clients" element={<ClientsPage />} />
        <Route path="/clients/:id" element={<ClientDetailPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
