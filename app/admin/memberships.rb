# frozen_string_literal: true

ActiveAdmin.register Membership do
  # Eager loading to prevent N+1 queries
  includes :user

  # Permissions
  permit_params :user_id, :membership_type, :amenity_tier, :starts_at, :ends_at

  # Menu configuration
  menu priority: 4, label: 'Memberships'

  # Filters
  filter :user
  filter :membership_type, as: :select, collection: Membership.membership_types.keys
  filter :amenity_tier, as: :select, collection: Membership.amenity_tiers.keys
  filter :starts_at
  filter :ends_at

  # Scopes
  scope :all, default: true
  scope :active
  scope :expired
  scope :future
  scope(:expiring_soon) { |scope| scope.expiring_soon(7) }
  scope(:day_passes) { |scope| scope.membership_type_day_pass }
  scope(:weekly) { |scope| scope.membership_type_weekly }
  scope(:monthly) { |scope| scope.membership_type_monthly }

  # Index page
  index do
    selectable_column
    id_column
    column :user
    column :membership_type do |membership|
      status_tag membership.membership_type
    end
    column :amenity_tier do |membership|
      status_tag membership.amenity_tier, class: membership.amenity_tier_premium? ? 'yes' : 'no'
    end
    column :starts_at
    column :ends_at
    column :status do |membership|
      if membership.active?
        status_tag 'Active', class: 'yes'
      elsif membership.future?
        status_tag 'Future', class: 'warning'
      else
        status_tag 'Expired', class: 'no'
      end
    end
    column :remaining_days
    actions
  end

  # Show page
  show do
    attributes_table do
      row :id
      row :user
      row :membership_type do |membership|
        status_tag membership.membership_type
      end
      row :amenity_tier do |membership|
        status_tag membership.amenity_tier
      end
      row :starts_at
      row :ends_at
      row :status do |membership|
        if membership.active?
          status_tag 'Active', class: 'yes'
        elsif membership.future?
          status_tag 'Future', class: 'warning'
        else
          status_tag 'Expired', class: 'no'
        end
      end
      row :duration_days
      row :remaining_days
      row :expiring_soon? do |membership|
        status_tag membership.expiring_soon? ? 'Yes' : 'No'
      end
      row :price do |membership|
        number_to_currency membership.price
      end
      row :created_at
      row :updated_at
    end

    if resource.active?
      panel 'Actions' do
        para link_to 'Extend Membership', extend_duration_admin_membership_path(resource),
                     method: :put, class: 'button',
                     data: { confirm: 'Are you sure you want to extend this membership?' }
      end
    end
  end

  # Form
  form do |f|
    f.inputs 'Membership Details' do
      f.input :user
      f.input :membership_type, as: :select, collection: Membership.membership_types.keys
      f.input :amenity_tier, as: :select, collection: Membership.amenity_tiers.keys
      f.input :starts_at, as: :datetime_picker
      f.input :ends_at, as: :datetime_picker
    end
    f.actions
  end

  # Custom actions
  # Named extend_duration to avoid conflict with Ruby's extend method
  member_action :extend_duration, method: :put do
    if resource.extend!
      redirect_to admin_membership_path(resource), notice: 'Membership extended!'
    else
      redirect_to admin_membership_path(resource), alert: 'Could not extend membership.'
    end
  end
end
