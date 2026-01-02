import { useState } from 'react'

import { Button } from './Button'

import type { JSX } from 'react'

interface ArrayFieldEditorProps {
  label: string
  values: string[]
  onChange: (values: string[]) => void
  placeholder?: string
}

export function ArrayFieldEditor({
  label,
  values,
  onChange,
  placeholder = 'Enter value and press Enter',
}: ArrayFieldEditorProps): JSX.Element {
  const [inputValue, setInputValue] = useState('')

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>): void => {
    if (e.key === 'Enter' && inputValue.trim()) {
      e.preventDefault()
      if (!values.includes(inputValue.trim())) {
        onChange([...values, inputValue.trim()])
      }
      setInputValue('')
    }
  }

  const handleRemove = (index: number): void => {
    onChange(values.filter((_, i) => i !== index))
  }

  return (
    <div>
      <label className="block text-sm font-medium text-gray-700 mb-2">{label}</label>

      {/* Existing values */}
      <div className="space-y-2 mb-2">
        {values.map((value, index) => (
          <div key={index} className="flex items-center space-x-2">
            <code className="flex-1 bg-gray-50 border border-gray-200 rounded px-4 py-2 text-sm font-mono">
              {value}
            </code>
            <Button
              type="button"
              variant="danger-light"
              onClick={() => {
                handleRemove(index)
              }}
            >
              Remove
            </Button>
          </div>
        ))}
      </div>

      {/* New input */}
      <input
        type="text"
        value={inputValue}
        onChange={(e) => {
          setInputValue(e.target.value)
        }}
        onKeyDown={handleKeyDown}
        placeholder={placeholder}
        className="w-full border border-gray-300 rounded px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
      <p className="mt-1 text-xs text-gray-500">Press Enter to add</p>
    </div>
  )
}
