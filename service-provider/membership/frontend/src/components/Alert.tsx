import type { JSX } from 'react'

interface AlertProps {
  children: React.ReactNode
  variant?: 'error' | 'success' | 'warning' | 'info'
}

const variantStyles = {
  error: 'bg-red-50 border-red-200 text-red-800',
  success: 'bg-green-50 border-green-200 text-green-800',
  warning: 'bg-yellow-50 border-yellow-200 text-yellow-800',
  info: 'bg-blue-50 border-blue-200 text-blue-800',
}

export function Alert({ children, variant = 'info' }: AlertProps): JSX.Element {
  return (
    <div className={`border rounded-lg p-4 ${variantStyles[variant]}`}>
      <p>{children}</p>
    </div>
  )
}
