import { useState } from 'react'
import { useNavigate } from 'react-router-dom'

import { clientsApi } from '~/api/clients'
import { Alert } from '~/components/Alert'
import { Button } from '~/components/Button'
import { Card } from '~/components/Card'
import { PageHeader } from '~/components/PageHeader'
import { TextAreaField } from '~/components/TextAreaField'
import { TextField } from '~/components/TextField'

import type { JSX } from 'react'

export default function CreateClientPage(): JSX.Element {
  const navigate = useNavigate()
  const [creating, setCreating] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [formData, setFormData] = useState({
    name: '',
    redirect_uris: '',
    grant_types: 'authorization_code',
    response_types: 'code',
    scopes: '',
  })

  const handleCreate = async (): Promise<void> => {
    // 文字列を配列に変換（改行またはカンマ区切り）
    const parseToArray = (value: string): string[] => {
      return value
        .split(/[\n,]/)
        .map((item) => item.trim())
        .filter((item) => item.length > 0)
    }

    const redirect_uris = parseToArray(formData.redirect_uris)
    const grant_types = parseToArray(formData.grant_types)
    const response_types = parseToArray(formData.response_types)
    const scopes = parseToArray(formData.scopes)

    // バリデーション
    if (!formData.name.trim()) {
      setError('Client name is required')
      return
    }
    if (redirect_uris.length === 0) {
      setError('At least one redirect URI is required')
      return
    }
    if (grant_types.length === 0) {
      setError('At least one grant type is required')
      return
    }
    if (response_types.length === 0) {
      setError('At least one response type is required')
      return
    }

    try {
      setCreating(true)
      setError(null)

      const requestData = {
        name: formData.name,
        redirect_uris,
        grant_types,
        response_types,
        scopes: scopes.length > 0 ? scopes : undefined,
      }

      const client = await clientsApi.create(requestData)

      // 作成成功 → 詳細画面へリダイレクト
      void navigate(`/clients/${client.id}`)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create client')
      console.error('Failed to create client:', err)
    } finally {
      setCreating(false)
    }
  }

  const updateField = (
    field: 'name' | 'redirect_uris' | 'grant_types' | 'response_types' | 'scopes',
    value: string
  ): void => {
    setFormData((prev) => ({ ...prev, [field]: value }))
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <PageHeader title="Create New Client" backTo="/clients" backText="← Back to Clients" />

        {error && <Alert variant="error">{error}</Alert>}

        <Card>
          <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
            <h2 className="text-xl font-semibold text-gray-900">Client Information</h2>
          </div>

          <div className="px-6 py-6 space-y-6">
            {/* Client Name */}
            <TextField
              id="client-name"
              label="Client Name"
              value={formData.name}
              onChange={(value) => {
                updateField('name', value)
              }}
              placeholder="My Application"
            />

            {/* Redirect URIs */}
            <TextAreaField
              id="redirect-uris"
              label="Redirect URIs"
              value={formData.redirect_uris}
              onChange={(value) => {
                updateField('redirect_uris', value)
              }}
              placeholder="https://example.com/callback"
              rows={3}
              helpText="Enter one URI per line or separate with commas"
            />

            {/* Grant Types */}
            <TextAreaField
              id="grant-types"
              label="Grant Types"
              value={formData.grant_types}
              onChange={(value) => {
                updateField('grant_types', value)
              }}
              placeholder="authorization_code"
              rows={2}
              helpText="Enter one grant type per line or separate with commas"
            />

            {/* Response Types */}
            <TextAreaField
              id="response-types"
              label="Response Types"
              value={formData.response_types}
              onChange={(value) => {
                updateField('response_types', value)
              }}
              placeholder="code"
              rows={2}
              helpText="Enter one response type per line or separate with commas"
            />

            {/* Scopes (Optional) */}
            <TextAreaField
              id="scopes"
              label="Scopes (Optional)"
              value={formData.scopes}
              onChange={(value) => {
                updateField('scopes', value)
              }}
              placeholder="openid, profile, email"
              rows={2}
              helpText="Enter one scope per line or separate with commas"
            />
          </div>

          {/* Actions */}
          <div className="px-6 py-4 bg-gray-50 border-t border-gray-200 flex justify-between">
            <Button
              variant="primary"
              onClick={() => {
                void handleCreate()
              }}
              disabled={creating}
            >
              {creating ? 'Creating...' : 'Create Client'}
            </Button>
            <Button
              variant="secondary"
              onClick={() => {
                void navigate('/clients')
              }}
              disabled={creating}
            >
              Cancel
            </Button>
          </div>
        </Card>
      </div>
    </div>
  )
}
