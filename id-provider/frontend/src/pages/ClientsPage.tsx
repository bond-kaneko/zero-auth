import { Link } from 'react-router-dom';

export default function ClientsPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <Link
            to="/"
            className="text-blue-600 hover:text-blue-800 mb-4 inline-block"
          >
            ← Back to Home
          </Link>
          <h1 className="text-3xl font-bold text-gray-900">
            Client Management
          </h1>
        </div>

        <div className="bg-white shadow-lg rounded-lg p-6">
          <div className="mb-6 flex justify-between items-center">
            <h2 className="text-xl font-semibold text-gray-900">Clients</h2>
            <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
              Add Client
            </button>
          </div>

          <div className="text-gray-600">
            <p>No clients yet. Click "Add Client" to create one.</p>
          </div>
        </div>
      </div>
    </div>
  );
}
