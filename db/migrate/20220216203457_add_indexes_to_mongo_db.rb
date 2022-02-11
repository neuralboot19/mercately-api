class AddIndexesToMongoDb < ActiveRecord::Migration[5.2]
  def change
    Rake::Task['db:mongoid:create_indexes'].invoke
  end
end
