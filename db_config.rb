require 'data_mapper'
require 'dm-constraints'

module Database
  def self.set env
    if env == :development
      DataMapper::Logger.new($stdout, :debug)
      DataMapper::Model.raise_on_save_failure = true
    end

    database env
    load_models
    DataMapper.finalize

    if env == :test
      DataMapper.auto_migrate!
    else
      DataMapper.auto_upgrade!
    end
  end

  private

  def self.load_models
    Dir['models/*'].each do |model|
      require_relative model
    end
  end

  def self.database name
    db = case name
         when :test, :development
           "sqlite3://#{Dir.pwd}/#{name}.db"
         when :production
           ENV['DATABASE_URL']
         end
    DataMapper.setup :default, db
  end
end
