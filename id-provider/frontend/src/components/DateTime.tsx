import type { JSX } from 'react'

interface DateTimeProps {
  value: string
}

function formatDateTime(dateString: string): string {
  const date = new Date(dateString)
  const year = String(date.getFullYear())
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  const seconds = String(date.getSeconds()).padStart(2, '0')

  return `${year}/${month}/${day} ${hours}:${minutes}:${seconds}`
}

export function DateTime({ value }: DateTimeProps): JSX.Element {
  return <span>{formatDateTime(value)}</span>
}
