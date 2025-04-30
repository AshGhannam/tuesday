defmodule Tuesday.Playground do
  use Ash.Domain,
    otp_app: :tuesday

  resources do
    resource Tuesday.Playground.MatchDefault
    resource Tuesday.Playground.Timestamp

    resource Tuesday.Playground.Post do
      define :list_posts, action: :read
      define :create_post, action: :create
      define :update_post, action: :update
    end
  end

  authorization do
    require_actor? true
  end
end
