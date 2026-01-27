// =============================================================================
// BOOKING FORM
// =============================================================================

"use client";

import { useState } from "react";
import { useMutation } from "@apollo/client/react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { CREATE_BOOKING } from "@/graphql/mutations/bookings";
import { WorkshopEquipment, CreateBookingResponse } from "@/types";

interface BookingFormProps {
  workspaceId: string;
  isWorkshop: boolean;
  equipment?: WorkshopEquipment[];
  isAuthenticated: boolean;
}

function SuccessIcon() {
  return (
    <svg
      className="w-12 h-12 text-green-500 mx-auto mb-3"
      fill="none"
      stroke="currentColor"
      viewBox="0 0 24 24"
    >
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={2}
        d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
      />
    </svg>
  );
}

export function BookingForm({ workspaceId, isWorkshop, equipment, isAuthenticated }: BookingFormProps) {
  const router = useRouter();

  const [date, setDate] = useState("");
  const [startTime, setStartTime] = useState("09:00");
  const [endTime, setEndTime] = useState("10:00");
  const [selectedEquipment, setSelectedEquipment] = useState<string[]>([]);
  const [bookingError, setBookingError] = useState("");
  const [bookingSuccess, setBookingSuccess] = useState(false);

  const [createBooking, { loading: bookingLoading }] = useMutation<CreateBookingResponse>(CREATE_BOOKING, {
    onCompleted: (data) => {
      if (data?.createBooking.errors.length > 0) {
        setBookingError(data.createBooking.errors.join(", "));
      } else {
        setBookingSuccess(true);
        setTimeout(() => {
          router.push("/bookings");
        }, 2000);
      }
    },
    onError: (err) => {
      setBookingError(err.message);
    },
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setBookingError("");

    if (!isAuthenticated) {
      router.push("/login");
      return;
    }

    await createBooking({
      variables: {
        workspaceId,
        date,
        startTime,
        endTime,
        equipmentIds: selectedEquipment.length > 0 ? selectedEquipment : undefined,
      },
    });
  };

  const toggleEquipment = (equipmentId: string) => {
    setSelectedEquipment((prev) =>
      prev.includes(equipmentId)
        ? prev.filter((id) => id !== equipmentId)
        : [...prev, equipmentId]
    );
  };

  if (bookingSuccess) {
    return (
      <div className="bg-green-50 border border-green-200 rounded-lg p-4 text-center">
        <SuccessIcon />
        <p className="text-green-700 font-medium">Booking Confirmed!</p>
        <p className="text-green-600 text-sm mt-1">
          Redirecting to your bookings...
        </p>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {/* Date */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Date
        </label>
        <input
          type="date"
          value={date}
          onChange={(e) => setDate(e.target.value)}
          min={new Date().toISOString().split("T")[0]}
          required
          className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
        />
      </div>

      {/* Time Range */}
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Start Time
          </label>
          <input
            type="time"
            value={startTime}
            onChange={(e) => setStartTime(e.target.value)}
            required
            className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            End Time
          </label>
          <input
            type="time"
            value={endTime}
            onChange={(e) => setEndTime(e.target.value)}
            required
            className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
          />
        </div>
      </div>

      {/* Equipment Selection (for workshops) */}
      {isWorkshop && equipment && equipment.length > 0 && (
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Equipment Needed
          </label>
          <div className="space-y-2 max-h-40 overflow-y-auto">
            {equipment.map((eq) => (
              <label
                key={eq.id}
                className="flex items-center gap-2 cursor-pointer"
              >
                <input
                  type="checkbox"
                  checked={selectedEquipment.includes(eq.id)}
                  onChange={() => toggleEquipment(eq.id)}
                  className="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                />
                <span className="text-sm text-gray-700">{eq.name}</span>
              </label>
            ))}
          </div>
        </div>
      )}

      {/* Error Message */}
      {bookingError && (
        <div className="bg-red-50 border border-red-200 rounded-md p-3">
          <p className="text-sm text-red-700">{bookingError}</p>
        </div>
      )}

      {/* Submit Button */}
      <button
        type="submit"
        disabled={bookingLoading}
        className="w-full py-3 px-4 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {bookingLoading ? "Booking..." : isAuthenticated ? "Book Now" : "Login to Book"}
      </button>

      {!isAuthenticated && (
        <p className="text-sm text-gray-500 text-center">
          <Link href="/login" className="text-indigo-600 hover:text-indigo-700">
            Login
          </Link>{" "}
          or{" "}
          <Link href="/signup" className="text-indigo-600 hover:text-indigo-700">
            Sign up
          </Link>{" "}
          to make a booking
        </p>
      )}
    </form>
  );
}
