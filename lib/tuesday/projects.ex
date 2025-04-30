defmodule Tuesday.Projects do
  use Ash.Domain,
    otp_app: :tuesday

  resources do
    resource Tuesday.Projects.Project do
      define :list_projects
      define :create_project
      define :update_project
      define :archive_project
      define :add_members
      define :update_member
      define :remove_member
    end

    resource Tuesday.Projects.Task do
      define :create_task
      define :update_task
      define :add_sub_task
      define :add_parent_task
    end

    resource Tuesday.Projects.Comment do
      define :create_comment
      define :update_comment
    end

    resource Tuesday.Projects.ProjectMember
    resource Tuesday.Projects.TaskAssignee
  end
end
