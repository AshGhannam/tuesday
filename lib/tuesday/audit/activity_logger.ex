defmodule Tuesday.Audit.ActivityLogger do
  use Ash.Notifier
  require Logger

  def notify(
        %Ash.Notifier.Notification{
          resource: resource,
          action: %{type: action},
          data: data,
          actor: actor
        } = _notification
      ) do
    resource_name = Ash.Resource.Info.short_name(resource)

    params = %{
      action: action,
      target: "#{resource_name}:#{data.id}",
      status: :success,
      metadata: %{}
    }

    Tuesday.Audit.insert_log(params, actor: actor)
    :ok
  end

  def notify(_), do: :ok
end
