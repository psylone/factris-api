RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:active_record].clean_with(:truncation)
  end

  config.before(:all) do
    DatabaseCleaner[:active_record].start
  end

  config.around(:each) do |example|
    DatabaseCleaner[:active_record].cleaning { example.run }
  end

  config.after(:all) do
    DatabaseCleaner[:active_record].clean
  end
end
