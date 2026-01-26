# frozen_string_literal: true

# =============================================================================
# PUNDIT MATCHERS
# =============================================================================
#
# Custom RSpec matchers for testing Pundit policies.
# These make policy specs more readable.
#
# USAGE:
#   it { is_expected.to permit_action(:create) }
#   it { is_expected.not_to permit_action(:destroy) }
#
# =============================================================================

RSpec::Matchers.define :permit_action do |action|
  match do |policy|
    policy.public_send("#{action}?")
  end

  failure_message do |policy|
    "#{policy.class} does not permit #{action} on #{policy.record} for #{policy.user}"
  end

  failure_message_when_negated do |policy|
    "#{policy.class} does not forbid #{action} on #{policy.record} for #{policy.user}"
  end
end
