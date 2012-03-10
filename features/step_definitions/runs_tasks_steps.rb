When /^I run the ([\w.:-_]+) task with "([^"]*)"$/ do |task_name, data|
  establish_current_task(task_name, data)
end

Then /^the task should complete with "([^"]*)"$/ do |data|
  captured_on_complete.should == data
end
