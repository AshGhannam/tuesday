defmodule Tuesday.Audit do
  use Ash.Domain,
    otp_app: :tuesday

  resources do
    resource Tuesday.Audit.ActivityLog do
      define :insert_log
      define :list_logs
    end
  end
end
