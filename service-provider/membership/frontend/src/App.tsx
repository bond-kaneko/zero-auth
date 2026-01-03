import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'

import { Layout } from '~/components/Layout'
import HomePage from '~/pages/HomePage'
import OrganizationsPage from '~/pages/OrganizationsPage'
import UsersPage from '~/pages/UsersPage'

import type { JSX } from 'react'

function App(): JSX.Element {
  return (
    <BrowserRouter>
      <Layout>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/organizations" element={<OrganizationsPage />} />
          <Route path="/users" element={<UsersPage />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Layout>
    </BrowserRouter>
  )
}

export default App
