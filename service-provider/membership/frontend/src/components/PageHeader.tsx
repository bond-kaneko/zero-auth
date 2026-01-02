import { Link } from 'react-router-dom'

import type { JSX } from 'react'

interface PageHeaderProps {
  title: string
  backTo?: string
  backText?: string
}

export function PageHeader({ title, backTo, backText = '← Back' }: PageHeaderProps): JSX.Element {
  return (
    <div className="mb-8">
      {backTo && (
        <Link to={backTo} className="text-blue-600 hover:text-blue-800 mb-4 inline-block">
          {backText}
        </Link>
      )}
      <h1 className="text-3xl font-bold text-gray-900">{title}</h1>
    </div>
  )
}
