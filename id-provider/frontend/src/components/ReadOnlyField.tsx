import { Button } from './Button'

import type { JSX } from 'react'

interface ReadOnlyFieldProps {
  label: string
  value: string
  showCopyButton?: boolean
}

export function ReadOnlyField({
  label,
  value,
  showCopyButton = true,
}: ReadOnlyFieldProps): JSX.Element {
  return (
    <div>
      <div className="block text-sm font-medium text-gray-700 mb-2">{label}</div>
      <div className="flex items-center space-x-2">
        <code className="flex-1 bg-gray-50 border border-gray-200 rounded px-4 py-2 text-sm font-mono">
          {value}
        </code>
        {showCopyButton && (
          <Button
            variant="secondary"
            onClick={() => {
              void navigator.clipboard.writeText(value)
            }}
          >
            Copy
          </Button>
        )}
      </div>
    </div>
  )
}
