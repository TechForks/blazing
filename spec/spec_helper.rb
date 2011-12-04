require 'rspec'
require 'blazing'

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

#
# Stuff borrowed from carlhuda/bundler
#
RSpec.configure do |config|

  # config.color_enabled = true
  # config.filter_run :focus => true
  # config.run_all_when_everything_filtered = true

  #
  # Reset Logger
  #
  Logging.appenders.reset
  Logging.appenders.string_io(
    'string_io',
    :layout => Logging.layouts.pattern(
      :pattern => ' ------> [blazing] %-5l: %m\n',
      :color_scheme => 'bright'
    )
  )

  Logging.logger.root.appenders = 'string_io'

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def setup_sandbox
    @blazing_root = Dir.pwd
    @sandbox_directory = File.join('/tmp/blazing_sandbox')

    # Sometimes, when specs failed, the sandbox would stick around
    FileUtils.rm_rf(@sandbox_directory) if File.exists?(@sandbox_directory)

    # Setup Sandbox and cd into it
    Dir.mkdir(@sandbox_directory)
    Dir.chdir(@sandbox_directory)
    `git init .`
  end

  def teardown_sandbox
    # Teardown Sandbox
    Dir.chdir(@blazing_root)
    FileUtils.rm_rf(@sandbox_directory)
  end

  def destination_root
    File.join(File.dirname(__FILE__), 'sandbox')
  end
end
