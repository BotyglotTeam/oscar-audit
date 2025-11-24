namespace :oscar_activities do
  namespace :install do
    desc "Copy migrations from oscar-activities engine"
    task :migrations do
      Rake::Task["railties:install:migrations"].invoke("oscar_activities")
    end
  end
end
