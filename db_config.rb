require 'data_mapper'

module Database
  def self.set env
    database env
    load_models
    DataMapper.finalize

    if env == :test
      DataMapper.auto_migrate!
    else
      DataMapper.auto_upgrade!
    end

    if env == :development
      DataMapper::Logger.new($stdout, :debug)
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
