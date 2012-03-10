require 'aruba/cucumber'

require 'features/support/runs_tasks_api'

Before do
  @aruba_timeout_seconds = 5
  @test_gearman_servers = ['localhost:4730']
end

World(Gearup::RunsTasksApi)
