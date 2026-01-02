import type { JSX } from 'react'

interface CardProps {
  children: React.ReactNode
  className?: string
}

export function Card({ children, className = '' }: CardProps): JSX.Element {
  return (
    <div className={`bg-white shadow-lg rounded-lg overflow-hidden ${className}`}>{children}</div>
  )
}
