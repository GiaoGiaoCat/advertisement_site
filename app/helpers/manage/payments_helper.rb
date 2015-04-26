module Manage::PaymentsHelper
  def show_payment_state(state_code)
    Payment::STATES[state_code][0]
  end
end
