# frozen_string_literal: true

ActiveAdmin.register CantinaSubscription do
  # Eager loading to prevent N+1 queries
  includes :user

  # Permissions
  permit_params :user_id, :plan_type, :meals_remaining, :renews_at

  # Menu configuration
  menu priority: 5, label: 'Cantina Subscriptions'

  # Filters
  filter :user
  filter :plan_type, as: :select, collection: CantinaSubscription.plan_types.keys
  filter :meals_remaining
  filter :renews_at

  # Scopes
  scope :all, default: true
  scope :active
  scope :depleted
  scope :due_for_renewal
  scope(:renewing_soon) { |scope| scope.renewing_soon(7) }
  scope(:five_meals) { |scope| scope.plan_type_five_meals }
  scope(:ten_meals) { |scope| scope.plan_type_ten_meals }
  scope(:twenty_meals) { |scope| scope.plan_type_twenty_meals }

  # Index page
  index do
    selectable_column
    id_column
    column :user
    column :plan_type do |subscription|
      status_tag subscription.plan_type
    end
    column :meals_remaining do |subscription|
      "#{subscription.meals_remaining} / #{subscription.meal_limit}"
    end
    column :meals_remaining_percentage do |subscription|
      "#{subscription.meals_remaining_percentage}%"
    end
    column :renews_at
    column :status do |subscription|
      if subscription.active?
        status_tag 'Active', class: 'yes'
      elsif subscription.depleted?
        status_tag 'Depleted', class: 'warning'
      else
        status_tag 'Expired', class: 'no'
      end
    end
    actions
  end

  # Show page
  show do
    attributes_table do
      row :id
      row :user
      row :plan_type do |subscription|
        status_tag subscription.plan_type
      end
      row :meal_limit
      row :meals_remaining
      row :meals_used
      row :meals_remaining_percentage do |subscription|
        "#{subscription.meals_remaining_percentage}%"
      end
      row :renews_at
      row :days_until_renewal
      row :status do |subscription|
        if subscription.active?
          status_tag 'Active', class: 'yes'
        elsif subscription.depleted?
          status_tag 'Depleted', class: 'warning'
        else
          status_tag 'Expired', class: 'no'
        end
      end
      row :price do |subscription|
        number_to_currency subscription.price
      end
      row :created_at
      row :updated_at
    end

    panel 'Actions' do
      if resource.due_for_renewal?
        para link_to 'Renew Subscription', renew_admin_cantina_subscription_path(resource),
                     method: :put, class: 'button',
                     data: { confirm: 'Are you sure you want to renew this subscription?' }
      end
      if resource.can_use_meal?
        para link_to 'Use Meal Credit', use_meal_admin_cantina_subscription_path(resource),
                     method: :put, class: 'button',
                     data: { confirm: 'Deduct one meal credit?' }
      end
    end
  end

  # Form
  form do |f|
    f.inputs 'Cantina Subscription Details' do
      f.input :user
      f.input :plan_type, as: :select, collection: CantinaSubscription.plan_types.keys
      f.input :meals_remaining, as: :number, min: 0
      f.input :renews_at, as: :datetime_picker
    end
    f.actions
  end

  # Custom actions
  member_action :renew, method: :put do
    if resource.renew!
      redirect_to admin_cantina_subscription_path(resource), notice: 'Subscription renewed!'
    else
      redirect_to admin_cantina_subscription_path(resource), alert: 'Could not renew subscription.'
    end
  end

  member_action :use_meal, method: :put do
    if resource.use_meal!
      redirect_to admin_cantina_subscription_path(resource), notice: 'Meal credit used!'
    else
      redirect_to admin_cantina_subscription_path(resource), alert: 'Could not use meal credit.'
    end
  end
end
