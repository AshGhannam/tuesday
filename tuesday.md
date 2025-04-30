Tuesday.Auth
    User
        :register_user
        :update_user

Tuesday.Workspace
    Organization
        :create_org_with_owner
        :update_org
        :change_org_plan
    OrganizationMember
        :invite_org_member
        :update_org_member
            vaidation: allow updation of username, role 
            policy: role cannot be changed by the user unless the actor is admin or owner. username can be changed by any member for their own member record. 
        :deactivate_org_member
            input validation: none 
            policy: only admin/owner can deactivate any user but they cannot deactivate themselves

        :activate_org_member
            input validation: none 
            policy: only admin/owner can activate any user
            
Tuesday.Projects
    Project
        :create_project
            input validation: 
            policy: :name, :description, :start_date, :end_date, :organization_id
        :update_project
        :archive_project
        :add_member
        :update_member
        :remove_member
    ProjectMembers
    Task
        :create_task
        :update_task
        :add_sub_task
        :add_parent_task 
    TaskAssignee
    Comment
        :create_comment
        :update_comment

Tuesday.Playground
    Post
        :list_posts
        :create_post
        :update_post

Tuesday.Audit
    ActivityLog 
        :insert_log
        :list_logs


Add default source and destination fields to all relationships with a comment on what is the default value.