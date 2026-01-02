import { useState, useEffect, useCallback } from 'react'
import { Link, useParams, useNavigate } from 'react-router-dom'

import { clientsApi } from '~/api/clients'
import { ArrayFieldEditor } from '~/components/ArrayFieldEditor'

import type { JSX } from 'react'
import type { Client } from '~/types/client'

export default function ClientDetailPage(): JSX.Element {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const [client, setClient] = useState<Client | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [showSecret, setShowSecret] = useState(false)
  const [revoking, setRevoking] = useState(false)
  const [saving, setSaving] = useState(false)
  const [formData, setFormData] = useState({
    name: '',
    redirect_uris: [] as string[],
    grant_types: [] as string[],
    response_types: [] as string[],
    scopes: [] as string[],
  })

  const loadClient = useCallback(async (): Promise<void> => {
    if (!id) return

    try {
      setLoading(true)
      setError(null)
      const data = await clientsApi.get(id)
      setClient(data)
      setFormData({
        name: data.name,
        redirect_uris: data.redirect_uris,
        grant_types: data.grant_types ?? [],
        response_types: data.response_types ?? [],
        scopes: data.scopes ?? [],
      })
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load client')
      console.error('Failed to load client:', err)
    } finally {
      setLoading(false)
    }
  }, [id])

  useEffect(() => {
    void loadClient()
  }, [loadClient])

  const handleRevokeSecret = async (): Promise<void> => {
    if (
      !id ||
      !confirm(
        'Are you sure you want to revoke and regenerate the client secret? The old secret will no longer work.'
      )
    ) {
      return
    }

    try {
      setRevoking(true)
      const data = await clientsApi.revokeSecret(id)
      setClient(data)
      setShowSecret(true)
      alert('Client secret has been regenerated successfully. Please save the new secret.')
    } catch (err) {
      alert(err instanceof Error ? err.message : 'Failed to revoke secret')
      console.error('Failed to revoke secret:', err)
    } finally {
      setRevoking(false)
    }
  }

  const handleDelete = async (): Promise<void> => {
    if (
      !id ||
      !confirm('Are you sure you want to delete this client? This action cannot be undone.')
    ) {
      return
    }

    try {
      await clientsApi.delete(id)
      void navigate('/clients')
    } catch (err) {
      alert(err instanceof Error ? err.message : 'Failed to delete client')
      console.error('Failed to delete client:', err)
    }
  }

  const handleSave = async (): Promise<void> => {
    if (!id) return

    // Validation
    if (!formData.name.trim()) {
      alert('Client name is required')
      return
    }
    if (formData.redirect_uris.length === 0) {
      alert('At least one redirect URI is required')
      return
    }
    if (formData.grant_types.length === 0) {
      alert('At least one grant type is required')
      return
    }
    if (formData.response_types.length === 0) {
      alert('At least one response type is required')
      return
    }

    try {
      setSaving(true)
      const updatedClient = await clientsApi.update(id, formData)
      setClient(updatedClient)
      setFormData({
        name: updatedClient.name,
        redirect_uris: updatedClient.redirect_uris,
        grant_types: updatedClient.grant_types ?? [],
        response_types: updatedClient.response_types ?? [],
        scopes: updatedClient.scopes ?? [],
      })
      alert('Client updated successfully')
    } catch (err) {
      alert(err instanceof Error ? err.message : 'Failed to update client')
      console.error('Failed to update client:', err)
    } finally {
      setSaving(false)
    }
  }

  const updateArrayField = (field: keyof typeof formData, value: string[]): void => {
    setFormData((prev) => ({ ...prev, [field]: value }))
  }

  const updateTextField = (field: 'name', value: string): void => {
    setFormData((prev) => ({ ...prev, [field]: value }))
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <p className="text-gray-600">Loading...</p>
      </div>
    )
  }

  if (error || !client) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <Link to="/clients" className="text-blue-600 hover:text-blue-800 mb-4 inline-block">
            ← Back to Clients
          </Link>
          <div className="bg-red-50 border border-red-200 rounded-lg p-4">
            <p className="text-red-800">{error ?? 'Client not found'}</p>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <Link to="/clients" className="text-blue-600 hover:text-blue-800 mb-4 inline-block">
            ← Back to Clients
          </Link>
          <h1 className="text-3xl font-bold text-gray-900">Client Details</h1>
        </div>

        <div className="bg-white shadow-lg rounded-lg overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
            <h2 className="text-xl font-semibold text-gray-900">{client.name}</h2>
          </div>

          <div className="px-6 py-6 space-y-6">
            {/* Client Name */}
            <div>
              <label htmlFor="client-name" className="block text-sm font-medium text-gray-700 mb-2">
                Client Name
              </label>
              <input
                id="client-name"
                type="text"
                value={formData.name}
                onChange={(e) => {
                  updateTextField('name', e.target.value)
                }}
                className="w-full border border-gray-300 rounded px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            {/* Client ID */}
            <div>
              <div className="block text-sm font-medium text-gray-700 mb-2">Client ID</div>
              <div className="flex items-center space-x-2">
                <code className="flex-1 bg-gray-50 border border-gray-200 rounded px-4 py-2 text-sm font-mono">
                  {client.client_id}
                </code>
                <button
                  onClick={() => {
                    void navigator.clipboard.writeText(client.client_id)
                  }}
                  className="px-3 py-2 bg-gray-100 text-gray-700 rounded hover:bg-gray-200 transition-colors text-sm"
                >
                  Copy
                </button>
              </div>
            </div>

            {/* Client Secret */}
            <div>
              <div className="block text-sm font-medium text-gray-700 mb-2">Client Secret</div>
              <div className="flex items-center space-x-2">
                <div className="flex-1 bg-gray-50 border border-gray-200 rounded px-4 py-2">
                  {showSecret ? (
                    <code className="text-sm font-mono break-all">
                      {client.client_secret || '••••••••••••••••••••••••••••••••'}
                    </code>
                  ) : (
                    <span className="text-sm text-gray-500">••••••••••••••••••••••••••••••••</span>
                  )}
                </div>
                <button
                  onClick={() => {
                    setShowSecret(!showSecret)
                  }}
                  className="px-3 py-2 bg-gray-100 text-gray-700 rounded hover:bg-gray-200 transition-colors text-sm"
                >
                  {showSecret ? 'Hide' : 'Show'}
                </button>
                {showSecret && client.client_secret && (
                  <button
                    onClick={() => {
                      void navigator.clipboard.writeText(client.client_secret)
                    }}
                    className="px-3 py-2 bg-gray-100 text-gray-700 rounded hover:bg-gray-200 transition-colors text-sm"
                  >
                    Copy
                  </button>
                )}
              </div>
              <p className="mt-2 text-sm text-gray-500">
                Keep this secret secure. Never share it publicly.
              </p>
            </div>

            {/* Redirect URIs */}
            <ArrayFieldEditor
              label="Redirect URIs"
              values={formData.redirect_uris}
              onChange={(values) => {
                updateArrayField('redirect_uris', values)
              }}
              placeholder="https://example.com/callback"
            />

            {/* Grant Types */}
            <ArrayFieldEditor
              label="Grant Types"
              values={formData.grant_types}
              onChange={(values) => {
                updateArrayField('grant_types', values)
              }}
              placeholder="authorization_code"
            />

            {/* Response Types */}
            <ArrayFieldEditor
              label="Response Types"
              values={formData.response_types}
              onChange={(values) => {
                updateArrayField('response_types', values)
              }}
              placeholder="code"
            />

            {/* Scopes */}
            <ArrayFieldEditor
              label="Scopes"
              values={formData.scopes}
              onChange={(values) => {
                updateArrayField('scopes', values)
              }}
              placeholder="openid profile email"
            />

            {/* Metadata */}
            <div className="grid grid-cols-2 gap-4 pt-4 border-t border-gray-200">
              <div>
                <div className="block text-sm font-medium text-gray-700 mb-1">Created At</div>
                <p className="text-sm text-gray-900">
                  {new Date(client.created_at).toLocaleString()}
                </p>
              </div>
              <div>
                <div className="block text-sm font-medium text-gray-700 mb-1">Updated At</div>
                <p className="text-sm text-gray-900">
                  {new Date(client.updated_at).toLocaleString()}
                </p>
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="px-6 py-4 bg-gray-50 border-t border-gray-200 flex justify-between">
            <div className="flex space-x-2">
              <button
                onClick={() => {
                  void handleSave()
                }}
                disabled={saving}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {saving ? 'Saving...' : 'Save Changes'}
              </button>
              <button
                onClick={() => {
                  void handleRevokeSecret()
                }}
                disabled={revoking}
                className="px-4 py-2 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {revoking ? 'Regenerating...' : 'Regenerate Secret'}
              </button>
            </div>
            <button
              onClick={() => {
                void handleDelete()
              }}
              className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >
              Delete Client
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
