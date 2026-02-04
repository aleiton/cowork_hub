# frozen_string_literal: true

ActiveAdmin.register WorkshopEquipment do
  # Eager loading to prevent N+1 queries
  includes :workspace

  # Permissions
  permit_params :workspace_id, :name, :description, :quantity_available

  # Menu configuration
  menu priority: 6, label: 'Workshop Equipment'

  # Filters
  filter :workspace, collection: -> { Workspace.workspace_type_workshop }
  filter :name
  filter :quantity_available

  # Scopes
  scope :all, default: true
  scope :available
  scope :alphabetical

  # Index page
  index do
    selectable_column
    id_column
    column :name
    column :workspace
    column :description do |equipment|
      truncate(equipment.description, length: 50) if equipment.description
    end
    column :quantity_available
    column :available? do |equipment|
      status_tag equipment.available? ? 'Yes' : 'No'
    end
    actions
  end

  # Show page
  show do
    attributes_table do
      row :id
      row :name
      row :workspace
      row :description
      row :quantity_available
      row :available? do |equipment|
        status_tag equipment.available? ? 'Yes' : 'No'
      end
      row :created_at
      row :updated_at
    end
  end

  # Form
  form do |f|
    f.inputs 'Equipment Details' do
      f.input :workspace, collection: Workspace.workspace_type_workshop
      f.input :name
      f.input :description, as: :text
      f.input :quantity_available, as: :number, min: 1
    end
    f.actions
  end
end
