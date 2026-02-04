# frozen_string_literal: true

ActiveAdmin.register Workspace do
  # Eager loading to prevent N+1 queries
  includes :workshop_equipments

  # Permissions
  permit_params :name, :description, :workspace_type, :capacity, :hourly_rate, :amenity_tier

  # Menu configuration
  menu priority: 2, label: 'Workspaces'

  # Filters
  filter :name
  filter :workspace_type, as: :select, collection: Workspace.workspace_types.keys
  filter :amenity_tier, as: :select, collection: Workspace.amenity_tiers.keys
  filter :capacity
  filter :hourly_rate

  # Scopes
  scope :all, default: true
  scope(:desks) { |scope| scope.workspace_type_desk }
  scope(:private_offices) { |scope| scope.workspace_type_private_office }
  scope(:meeting_rooms) { |scope| scope.workspace_type_meeting_room }
  scope(:workshops) { |scope| scope.workspace_type_workshop }

  # Index page
  index do
    selectable_column
    id_column
    column :name
    column :workspace_type do |workspace|
      status_tag workspace.workspace_type
    end
    column :capacity
    column :hourly_rate do |workspace|
      number_to_currency workspace.hourly_rate
    end
    column :amenity_tier do |workspace|
      status_tag workspace.amenity_tier, class: workspace.amenity_tier_premium? ? 'yes' : 'no'
    end
    column :equipment_count do |workspace|
      workspace.workshop_equipments.size
    end
    actions
  end

  # Show page
  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :workspace_type do |workspace|
        status_tag workspace.workspace_type
      end
      row :capacity
      row :hourly_rate do |workspace|
        number_to_currency workspace.hourly_rate
      end
      row :amenity_tier do |workspace|
        status_tag workspace.amenity_tier
      end
      row :recent_bookings_count do |workspace|
        workspace.recent_bookings_count(days: 30)
      end
      row :created_at
      row :updated_at
    end

    if resource.workspace_type_workshop?
      panel 'Workshop Equipment' do
        table_for resource.workshop_equipments do
          column :id do |equipment|
            link_to equipment.id, admin_workshop_equipment_path(equipment)
          end
          column :name
          column :description
          column :quantity_available
        end
      end
    end

    panel 'Recent Bookings' do
      table_for resource.bookings.includes(:user).order(date: :desc).limit(10) do
        column :id do |booking|
          link_to booking.id, admin_booking_path(booking)
        end
        column :user
        column :date
        column :start_time
        column :end_time
        column :status do |booking|
          status_tag booking.status
        end
      end
    end
  end

  # Form
  form do |f|
    f.inputs 'Workspace Details' do
      f.input :name
      f.input :description, as: :text
      f.input :workspace_type, as: :select, collection: Workspace.workspace_types.keys
      f.input :capacity, as: :number, min: 1
      f.input :hourly_rate, as: :number, step: 0.01, min: 0
      f.input :amenity_tier, as: :select, collection: Workspace.amenity_tiers.keys
    end
    f.actions
  end
end
