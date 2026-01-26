// =============================================================================
// EQUIPMENT LIST
// =============================================================================

import { WorkshopEquipment } from "@/types";

interface EquipmentListProps {
  equipment: WorkshopEquipment[];
}

export function EquipmentList({ equipment }: EquipmentListProps) {
  if (!equipment || equipment.length === 0) {
    return null;
  }

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <h2 className="text-lg font-semibold text-gray-900 mb-3">
        Available Equipment
      </h2>
      <div className="grid sm:grid-cols-2 gap-4">
        {equipment.map((eq) => (
          <div
            key={eq.id}
            className="border border-gray-200 rounded-lg p-4"
          >
            <div className="flex justify-between items-start">
              <div>
                <h3 className="font-medium text-gray-900">{eq.name}</h3>
                {eq.description && (
                  <p className="text-sm text-gray-500 mt-1">
                    {eq.description}
                  </p>
                )}
              </div>
              <span className="text-sm text-gray-500">
                {eq.quantityAvailable} available
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
