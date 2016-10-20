require "yaml"

class Config
  @config_path = "conf/config.yml"
  def self.load(config_path = nil)
    @config_path = config_path ? config_path : @config_path
    YAML.load_file(@config_path)
  end
end
