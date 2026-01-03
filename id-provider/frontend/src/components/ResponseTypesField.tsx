import { TextAreaField } from './TextAreaField'

import type { JSX } from 'react'
import type { ClientType } from '~/types/client'

interface ResponseTypesFieldProps {
  value: string
  onChange: (value: string) => void
  clientType: ClientType
}

export function ResponseTypesField({
  value,
  onChange,
  clientType,
}: ResponseTypesFieldProps): JSX.Element | null {
  // Only show for authorization_code clients
  if (clientType !== 'authorization_code') {
    return null
  }

  return (
    <TextAreaField
      id="response-types"
      label="Response Types"
      value={value}
      onChange={onChange}
      placeholder="code"
      rows={2}
      helpText="Enter one response type per line or separate with commas"
    />
  )
}
