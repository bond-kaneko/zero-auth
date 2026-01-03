import { Link } from 'react-router-dom'

import { Card } from '~/components/Card'

import type { JSX } from 'react'

export default function HomePage(): JSX.Element {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <h1 className="text-4xl font-bold text-gray-900 mb-8">Membership Service</h1>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <Link to="/organizations" className="block hover:opacity-80 transition-opacity">
            <Card className="p-6">
              <div className="flex items-center space-x-4">
                <div className="bg-blue-100 p-3 rounded-lg">
                  <svg
                    className="w-8 h-8 text-blue-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"
                    />
                  </svg>
                </div>
                <div>
                  <h2 className="text-xl font-semibold text-gray-900">Organizations</h2>
                  <p className="text-gray-600 mt-1">Manage organizations and their settings</p>
                </div>
              </div>
            </Card>
          </Link>

          <Link to="/users" className="block hover:opacity-80 transition-opacity">
            <Card className="p-6">
              <div className="flex items-center space-x-4">
                <div className="bg-green-100 p-3 rounded-lg">
                  <svg
                    className="w-8 h-8 text-green-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"
                    />
                  </svg>
                </div>
                <div>
                  <h2 className="text-xl font-semibold text-gray-900">Users</h2>
                  <p className="text-gray-600 mt-1">Manage users and sync from ID Provider</p>
                </div>
              </div>
            </Card>
          </Link>
        </div>
      </div>
    </div>
  )
}
