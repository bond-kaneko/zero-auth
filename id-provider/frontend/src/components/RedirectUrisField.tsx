import { TextAreaField } from './TextAreaField'

import type { JSX } from 'react'
import type { ClientType } from '~/types/client'

interface RedirectUrisFieldProps {
  value: string
  onChange: (value: string) => void
  clientType: ClientType
}

export function RedirectUrisField({
  value,
  onChange,
  clientType,
}: RedirectUrisFieldProps): JSX.Element | null {
  // Only show for authorization_code clients
  if (clientType !== 'authorization_code') {
    return null
  }

  return (
    <TextAreaField
      id="redirect-uris"
      label="Redirect URIs"
      value={value}
      onChange={onChange}
      placeholder="https://example.com/callback"
      rows={3}
      helpText="Enter one URI per line or separate with commas"
    />
  )
}
