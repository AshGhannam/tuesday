defmodule Tuesday.Auth do
  use Ash.Domain,
    otp_app: :tuesday

  resources do
    resource Tuesday.Auth.User do
      define :register_user
      define :update_user
    end
  end
end
