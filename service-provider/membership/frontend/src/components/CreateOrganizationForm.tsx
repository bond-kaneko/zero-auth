import { useState } from 'react'

import { organizationsApi } from '~/api/organizations'
import { Alert } from '~/components/Alert'
import { Button } from '~/components/Button'

import type { JSX } from 'react'

interface CreateOrganizationFormProps {
  onSuccess: () => void
  onCancel: () => void
}

export function CreateOrganizationForm({
  onSuccess,
  onCancel,
}: CreateOrganizationFormProps): JSX.Element {
  const [name, setName] = useState('')
  const [slug, setSlug] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (e: React.FormEvent): Promise<void> => {
    e.preventDefault()
    setError(null)

    if (!name.trim() || !slug.trim()) {
      setError('Name and slug are required')
      return
    }

    try {
      setLoading(true)
      await organizationsApi.create({ name: name.trim(), slug: slug.trim() })
      onSuccess()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create organization')
      console.error('Failed to create organization:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form
      onSubmit={(e) => {
        void handleSubmit(e)
      }}
      className="space-y-4"
    >
      <div>
        <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
          Name
        </label>
        <input
          id="name"
          type="text"
          value={name}
          onChange={(e) => {
            setName(e.target.value)
          }}
          disabled={loading}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
          placeholder="Enter organization name"
        />
      </div>

      <div>
        <label htmlFor="slug" className="block text-sm font-medium text-gray-700 mb-1">
          Slug
        </label>
        <input
          id="slug"
          type="text"
          value={slug}
          onChange={(e) => {
            setSlug(e.target.value)
          }}
          disabled={loading}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100"
          placeholder="enter-slug-here"
        />
        <p className="mt-1 text-xs text-gray-500">
          URL-friendly identifier (lowercase, hyphens allowed)
        </p>
      </div>

      {error && <Alert variant="error">{error}</Alert>}

      <div className="flex gap-3 justify-end">
        <Button type="button" variant="secondary" onClick={onCancel} disabled={loading}>
          Cancel
        </Button>
        <Button type="submit" variant="primary" disabled={loading}>
          {loading ? 'Creating...' : 'Create Organization'}
        </Button>
      </div>
    </form>
  )
}
