defmodule Contour.Security.Maintenance do
  use Ash.Resource,
    domain: Contour.Security,
    extensions: [AshOban],
    authorizers: [Ash.Policy.Authorizer]

  actions do
    action :cleanup do
      run Contour.Security.Cleanup
    end
  end

  oban do
    scheduled_actions do
      schedule :cleanup, "* * * * *" do
        queue :maintenance
        worker_module_name Contour.Security.Maintenance.Worker
      end
    end
  end

  policies do
    bypass AshOban.Checks.AshObanInteraction do
      authorize_if always()
    end

    policy always() do
      authorize_if actor_attribute_equals(:system, true)
    end
  end
end
