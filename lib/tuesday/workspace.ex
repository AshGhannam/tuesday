defmodule Tuesday.Workspace do
  use Ash.Domain,
    otp_app: :tuesday

  resources do
    resource Tuesday.Workspace.Organization do
      define :create_org_with_owner
      define :update_org
      define :change_org_plan
    end

    resource Tuesday.Workspace.OrganizationMember do
      define :invite_org_member
      define :update_org_member
      define :deactivate_org_member
    end
  end
end
