# frozen_string_literal: true

ActiveAdmin.register Booking do
  # Eager loading to prevent N+1 queries
  includes :user, :workspace

  # Permissions
  permit_params :workspace_id, :user_id, :date, :start_time, :end_time, :status, equipment_used: []

  # Menu configuration
  menu priority: 3, label: 'Bookings'

  # Filters
  filter :user
  filter :workspace
  filter :date
  filter :status, as: :select, collection: Booking.statuses.keys
  filter :created_at

  # Scopes
  scope :all, default: true
  scope :active
  scope :today
  scope :upcoming
  scope :past
  scope(:pending) { |scope| scope.status_pending }
  scope(:confirmed) { |scope| scope.status_confirmed }
  scope(:cancelled) { |scope| scope.status_cancelled }
  scope(:completed) { |scope| scope.status_completed }

  # Index page
  index do
    selectable_column
    id_column
    column :user
    column :workspace
    column :date
    column :start_time do |booking|
      booking.start_time.strftime('%H:%M')
    end
    column :end_time do |booking|
      booking.end_time.strftime('%H:%M')
    end
    column :status do |booking|
      case booking.status
      when 'pending'
        status_tag booking.status, class: 'warning'
      when 'confirmed'
        status_tag booking.status, class: 'yes'
      when 'cancelled'
        status_tag booking.status, class: 'no'
      when 'completed'
        status_tag booking.status, class: 'ok'
      else
        status_tag booking.status
      end
    end
    column :calculated_price do |booking|
      number_to_currency booking.calculated_price
    end
    actions
  end

  # Show page
  show do
    attributes_table do
      row :id
      row :user
      row :workspace
      row :date
      row :start_time do |booking|
        booking.start_time.strftime('%H:%M')
      end
      row :end_time do |booking|
        booking.end_time.strftime('%H:%M')
      end
      row :duration do |booking|
        "#{booking.duration_minutes} minutes"
      end
      row :status do |booking|
        status_tag booking.status
      end
      row :calculated_price do |booking|
        number_to_currency booking.calculated_price
      end
      row :equipment_used do |booking|
        if booking.equipment_used.present?
          equipment = WorkshopEquipment.where(id: booking.equipment_used)
          equipment.map(&:name).join(', ')
        else
          'None'
        end
      end
      row :cancellable? do |booking|
        status_tag booking.cancellable? ? 'Yes' : 'No'
      end
      row :created_at
      row :updated_at
    end

    panel 'Actions' do
      if resource.status_pending?
        para link_to 'Confirm Booking', confirm_admin_booking_path(resource),
                     method: :put, class: 'button'
      end
      if resource.cancellable?
        para link_to 'Cancel Booking', cancel_admin_booking_path(resource),
                     method: :put, class: 'button', data: { confirm: 'Are you sure?' }
      end
    end
  end

  # Form
  form do |f|
    f.inputs 'Booking Details' do
      f.input :user
      f.input :workspace
      f.input :date, as: :datepicker
      f.input :start_time, as: :time_picker
      f.input :end_time, as: :time_picker
      f.input :status, as: :select, collection: Booking.statuses.keys
    end
    f.actions
  end

  # Custom actions
  member_action :confirm, method: :put do
    if resource.confirm!
      redirect_to admin_booking_path(resource), notice: 'Booking confirmed!'
    else
      redirect_to admin_booking_path(resource), alert: 'Could not confirm booking.'
    end
  end

  member_action :cancel, method: :put do
    if resource.cancel!
      redirect_to admin_booking_path(resource), notice: 'Booking cancelled!'
    else
      redirect_to admin_booking_path(resource), alert: 'Could not cancel booking.'
    end
  end
end
