namespace :oscar_audit do
  namespace :install do
    desc "Copy migrations from oscar-audit engine"
    task :migrations do
      Rake::Task["railties:install:migrations"].invoke("oscar_audit")
    end
  end
end
