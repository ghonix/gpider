require 'active_record'

pwd  = File.dirname(File.expand_path(__FILE__))

config_path = pwd + "/../config/database.yml"

db_config = YAML::load_file(config_path);

# establishing database connection
begin
   ActiveRecord::Base.establish_connection(db_config["production"])
rescue Exception => e
   puts e
   exit 1;
end

