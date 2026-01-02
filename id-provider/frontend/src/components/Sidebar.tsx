import { Link, useLocation } from 'react-router-dom'

import type { JSX } from 'react'

export function Sidebar(): JSX.Element {
  const location = useLocation()

  const isActive = (path: string): boolean => {
    return location.pathname === path || location.pathname.startsWith(`${path}/`)
  }

  return (
    <div className="w-64 bg-gray-900 text-white min-h-screen flex flex-col">
      {/* Header */}
      <div className="p-6 border-b border-gray-700">
        <Link to="/" className="text-xl font-bold hover:text-gray-300 transition-colors">
          ID Provider
        </Link>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4">
        <Link
          to="/clients"
          className={`block px-4 py-3 rounded-lg mb-2 transition-colors ${
            isActive('/clients')
              ? 'bg-blue-600 text-white'
              : 'text-gray-300 hover:bg-gray-800 hover:text-white'
          }`}
        >
          <div className="flex items-center space-x-3">
            <svg
              className="w-5 h-5"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"
              />
            </svg>
            <span>Clients</span>
          </div>
        </Link>
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-gray-700">
        <p className="text-xs text-gray-500">© 2026 ID Provider</p>
      </div>
    </div>
  )
}
