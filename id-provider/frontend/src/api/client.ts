// Base API client using fetch
const API_BASE_URL = '/api'

export class ApiError extends Error {
  status: number
  statusText: string

  constructor(status: number, statusText: string, message?: string) {
    super(message ?? `API Error: ${String(status)} ${statusText}`)
    this.name = 'ApiError'
    this.status = status
    this.statusText = statusText
  }
}

interface RequestOptions extends RequestInit {
  params?: Record<string, string | number | boolean>
}

async function request<T>(endpoint: string, options: RequestOptions = {}): Promise<T> {
  const { params, ...fetchOptions } = options

  // Build URL with query parameters
  let url = `${API_BASE_URL}${endpoint}`
  if (params) {
    const searchParams = new URLSearchParams()
    Object.entries(params).forEach(([key, value]) => {
      searchParams.append(key, String(value))
    })
    url += `?${searchParams.toString()}`
  }

  // Set default headers
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...(fetchOptions.headers as Record<string, string>),
  }

  try {
    const response = await fetch(url, {
      ...fetchOptions,
      headers,
    })

    if (!response.ok) {
      throw new ApiError(response.status, response.statusText)
    }

    // Handle empty responses (204 No Content, etc.)
    if (response.status === 204 || response.headers.get('content-length') === '0') {
      return null as T
    }

    const data: unknown = await response.json()
    return data as T
  } catch (error) {
    if (error instanceof ApiError) {
      throw error
    }
    const errorMessage = error instanceof Error ? error.message : String(error)
    throw new Error(`Network error: ${errorMessage}`)
  }
}

export const apiClient = {
  get: <T>(endpoint: string, options?: RequestOptions) =>
    request<T>(endpoint, { ...options, method: 'GET' }),

  post: <T>(endpoint: string, data?: unknown, options?: RequestOptions) =>
    request<T>(endpoint, {
      ...options,
      method: 'POST',
      body: JSON.stringify(data),
    }),

  put: <T>(endpoint: string, data?: unknown, options?: RequestOptions) =>
    request<T>(endpoint, {
      ...options,
      method: 'PUT',
      body: JSON.stringify(data),
    }),

  patch: <T>(endpoint: string, data?: unknown, options?: RequestOptions) =>
    request<T>(endpoint, {
      ...options,
      method: 'PATCH',
      body: JSON.stringify(data),
    }),

  delete: <T>(endpoint: string, options?: RequestOptions) =>
    request<T>(endpoint, { ...options, method: 'DELETE' }),
}
