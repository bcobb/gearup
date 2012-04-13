When /^I run the ([\w.:-_]+) task with "([^"]*)"$/ do |task_name, data|
  establish_current_task(task_name, data)
end

Then /^the task should complete with "([^"]*)"$/ do |data|
  captured_on_complete.should == data
end

Given /^the following worker is running:$/ do |worker_file_contents|
  file = 'worker.rb'

  step(%{a file named "#{file}" with:}, worker_file_contents)
  step("I successfully run `gearup -l ../../log/test.log -v #{file}`")
end
