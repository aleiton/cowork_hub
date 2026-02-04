# frozen_string_literal: true

ActiveAdmin.register User do
  # Eager loading to prevent N+1 queries
  includes :memberships

  # Permissions
  permit_params :email, :password, :password_confirmation, :role

  # Menu configuration
  menu priority: 1, label: 'Users'

  # Filters
  filter :email
  filter :role, as: :select, collection: User.roles.keys
  filter :created_at

  # Index page
  index do
    selectable_column
    id_column
    column :email
    column :role do |user|
      status_tag user.role, class: user.role_admin? ? 'yes' : 'no'
    end
    column :active_membership? do |user|
      status_tag user.active_membership? ? 'Yes' : 'No'
    end
    column :created_at
    actions
  end

  # Show page
  show do
    attributes_table do
      row :id
      row :email
      row :role do |user|
        status_tag user.role
      end
      row :active_membership? do |user|
        status_tag user.active_membership? ? 'Yes' : 'No'
      end
      row :current_membership do |user|
        if user.current_membership
          link_to "#{user.current_membership.membership_type} (#{user.current_membership.amenity_tier})",
                  admin_membership_path(user.current_membership)
        else
          'None'
        end
      end
      row :has_meal_credits? do |user|
        status_tag user.has_meal_credits? ? 'Yes' : 'No'
      end
      row :failed_attempts
      row :locked_at
      row :created_at
      row :updated_at
    end

    panel 'Bookings' do
      table_for resource.bookings.includes(:workspace).order(date: :desc).limit(10) do
        column :id do |booking|
          link_to booking.id, admin_booking_path(booking)
        end
        column :workspace
        column :date
        column :start_time
        column :end_time
        column :status do |booking|
          status_tag booking.status
        end
      end
    end

    panel 'Memberships' do
      table_for resource.memberships.order(starts_at: :desc).limit(5) do
        column :id do |membership|
          link_to membership.id, admin_membership_path(membership)
        end
        column :membership_type
        column :amenity_tier
        column :starts_at
        column :ends_at
        column :active? do |membership|
          status_tag membership.active? ? 'Active' : 'Inactive'
        end
      end
    end
  end

  # Form
  form do |f|
    f.inputs 'User Details' do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :role, as: :select, collection: User.roles.keys
    end
    f.actions
  end
end
