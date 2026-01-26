// =============================================================================
// ACCOUNT INFO
// =============================================================================
// Shows user account information on the dashboard.

interface AccountInfoProps {
  email: string;
  role: string;
}

export function AccountInfo({ email, role }: AccountInfoProps) {
  return (
    <div className="mt-8 bg-gray-50 rounded-xl p-6">
      <h2 className="text-lg font-semibold text-gray-900 mb-4">Account Info</h2>
      <div className="grid sm:grid-cols-2 gap-4">
        <div>
          <p className="text-sm text-gray-500">Email</p>
          <p className="font-medium text-gray-900">{email}</p>
        </div>
        <div>
          <p className="text-sm text-gray-500">Role</p>
          <p className="font-medium text-gray-900 capitalize">{role?.toLowerCase()}</p>
        </div>
      </div>
    </div>
  );
}
