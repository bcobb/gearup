require 'aruba/cucumber'

require 'features/support/runs_tasks_api'

Before do
  @aruba_timeout_seconds = 10
  @test_gearman_servers = ['localhost:4730']
end

After do
  in_current_dir do
    pid_file = ::File.expand_path('gearup.pid')

    if ::File.exist?(pid_file)
      pid = ::File.read(pid_file).to_i

      ::Process.kill('INT', pid)
    end
  end
end

World(Gearup::RunsTasksApi)
