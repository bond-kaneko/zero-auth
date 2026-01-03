import { TextAreaField } from './TextAreaField'

import type { JSX } from 'react'
import type { ClientType } from '~/types/client'

interface GrantTypesFieldProps {
  value: string
  onChange: (value: string) => void
  clientType: ClientType
}

export function GrantTypesField({
  value,
  onChange,
  clientType,
}: GrantTypesFieldProps): JSX.Element {
  return (
    <TextAreaField
      id="grant-types"
      label="Grant Types"
      value={value}
      onChange={onChange}
      placeholder={
        clientType === 'authorization_code' ? 'authorization_code' : 'client_credentials'
      }
      rows={2}
      helpText="Enter one grant type per line or separate with commas"
    />
  )
}
