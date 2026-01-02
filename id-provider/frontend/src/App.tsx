import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'

import { Layout } from '~/components/Layout'
import ClientDetailPage from '~/pages/ClientDetailPage'
import ClientsPage from '~/pages/ClientsPage'
import CreateClientPage from '~/pages/CreateClientPage'
import HomePage from '~/pages/HomePage'

import type { JSX } from 'react'

function App(): JSX.Element {
  return (
    <BrowserRouter>
      <Layout>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/clients" element={<ClientsPage />} />
          <Route path="/clients/new" element={<CreateClientPage />} />
          <Route path="/clients/:id" element={<ClientDetailPage />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Layout>
    </BrowserRouter>
  )
}

export default App
