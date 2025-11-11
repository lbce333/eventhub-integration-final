import { useState } from 'react';
import { seedDatabase } from '../tools/seedFromMockData';

export default function AdminSeed() {
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<{
    success: boolean;
    message: string;
    details: Record<string, number>;
  } | null>(null);

  const handleSeed = async () => {
    setLoading(true);
    setResult(null);

    try {
      const response = await seedDatabase();
      setResult(response);
    } catch (error: any) {
      setResult({
        success: false,
        message: error.message || 'Unexpected error',
        details: {},
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg shadow-lg p-8 max-w-2xl w-full">
        <h1 className="text-3xl font-bold text-gray-900 mb-6">
          Admin Seed Tool
        </h1>

        <div className="bg-yellow-50 border-l-4 border-yellow-400 p-4 mb-6">
          <div className="flex">
            <div className="flex-shrink-0">
              <svg
                className="h-5 w-5 text-yellow-400"
                viewBox="0 0 20 20"
                fill="currentColor"
              >
                <path
                  fillRule="evenodd"
                  d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
                  clipRule="evenodd"
                />
              </svg>
            </div>
            <div className="ml-3">
              <p className="text-sm text-yellow-700">
                <strong>Warning:</strong> This tool seeds catalog data from
                Emergent mock arrays. Use only in development/staging. This
                page should be excluded from production builds.
              </p>
            </div>
          </div>
        </div>

        <div className="space-y-4">
          <div>
            <h2 className="text-lg font-semibold text-gray-700 mb-2">
              Catalog Data to Seed:
            </h2>
            <ul className="list-disc list-inside text-gray-600 space-y-1">
              <li>Vegetables Catalog (~15 items)</li>
              <li>Chilis Catalog (~5 items)</li>
              <li>Decoration Providers (4 providers)</li>
              <li>Decoration Packages (4 packages)</li>
              <li>Staff Roles Catalog (5 roles)</li>
              <li>Menu Items (8 dishes)</li>
            </ul>
          </div>

          <button
            onClick={handleSeed}
            disabled={loading}
            className={`w-full py-3 px-4 rounded-lg font-semibold text-white transition-colors ${
              loading
                ? 'bg-gray-400 cursor-not-allowed'
                : 'bg-blue-600 hover:bg-blue-700'
            }`}
          >
            {loading ? 'Seeding Database...' : 'Run Seed'}
          </button>

          {result && (
            <div
              className={`p-4 rounded-lg ${
                result.success
                  ? 'bg-green-50 border border-green-200'
                  : 'bg-red-50 border border-red-200'
              }`}
            >
              <h3
                className={`font-semibold mb-2 ${
                  result.success ? 'text-green-800' : 'text-red-800'
                }`}
              >
                {result.success ? 'Success!' : 'Error'}
              </h3>
              <p
                className={`text-sm mb-3 ${
                  result.success ? 'text-green-700' : 'text-red-700'
                }`}
              >
                {result.message}
              </p>

              {Object.keys(result.details).length > 0 && (
                <div className="bg-white p-3 rounded border border-gray-200">
                  <h4 className="text-sm font-semibold text-gray-700 mb-2">
                    Details:
                  </h4>
                  <dl className="space-y-1">
                    {Object.entries(result.details).map(([key, value]) => (
                      <div
                        key={key}
                        className="flex justify-between text-sm text-gray-600"
                      >
                        <dt className="font-medium">{key}:</dt>
                        <dd>{value} records</dd>
                      </div>
                    ))}
                  </dl>
                </div>
              )}
            </div>
          )}
        </div>

        <div className="mt-6 pt-6 border-t border-gray-200">
          <p className="text-xs text-gray-500 text-center">
            This page will be removed from production builds. Seeds use upsert
            (ON CONFLICT) to avoid duplicates.
          </p>
        </div>
      </div>
    </div>
  );
}
