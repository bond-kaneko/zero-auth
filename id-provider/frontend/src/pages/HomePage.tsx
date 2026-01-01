import { Link } from 'react-router-dom';

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="max-w-md w-full bg-white shadow-lg rounded-lg p-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-6">
          ID Provider
        </h1>
        <p className="text-gray-600 mb-8">
          Welcome to the ID Provider management interface
        </p>
        <div className="space-y-4">
          <Link
            to="/clients"
            className="block w-full bg-blue-600 text-white text-center py-3 px-4 rounded-lg hover:bg-blue-700 transition-colors"
          >
            Manage Clients
          </Link>
        </div>
      </div>
    </div>
  );
}
