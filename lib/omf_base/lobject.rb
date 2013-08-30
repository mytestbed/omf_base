#-------------------------------------------------------------------------------
# Copyright (c) 2006-2013 National ICT Australia (NICTA), Australia
# Copyright (c) 2004-2009 WINLAB, Rutgers University, USA
# This software may be used and distributed solely under the terms of the MIT license (License).
# You should find a copy of the License in LICENSE.TXT or at http://opensource.org/licenses/MIT.
# By downloading or using this software you accept the terms and the liability disclaimer in the License.
#-------------------------------------------------------------------------------

require 'rubygems'
require 'date'
require 'log4r'
require 'log4r/configurator'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'


require 'omf_base'
require 'omf_base/log4r/file_outputter'

#
# An extended object class with support for logging
#
module OMF::Base
  module Loggable
    @@logger = nil
    @@rootLoggerName = nil

    #
    # Initialize the logger. The 'appName' is used to build some of the defaults.
    # The 'environment' is the name of the root
    # logger. 'AppInstance' and 'appName' are available as parameters
    # in the log configuration file. The 'opts' hash can optionally
    # contain information on how to find a configuration file. The
    # following keys are used:
    #
    #  * :environment - Name used for root logger name ['development']
    #  * :env - Name of environment variable holding dominant config file
    #  * :fileName - Name of config file [#{appName}_log.xml]
    #  * :searchPath - Array of directories to look for 'fileName'
    #
    def self.init_log(appName, opts = {})

      #@@logger = ::Log4r::Logger.new(appName)
      set_environment(opts[:environment] || 'development')
      @@logger = ::Log4r::Logger.new(@@rootLoggerName)

      configFile = opts[:configFile]
      if (configFile == nil && logEnv = opts[:env])
          configFile = ENV[logEnv]
      end
      if (configFile != nil)
        # Make sure log exists ...
        configFile = File.exists?(configFile) ? configFile : nil
      else
        name = opts[:fileName] || "#{appName}_log4r.yaml"
        if ((searchPath = opts[:searchPath]) != nil)
          searchPath = searchPath.is_a?(Enumerable) ? searchPath : [searchPath]
          logDir = searchPath.find {|dir|
            File.exists?("#{dir}/#{name}")
          }
          #puts "logDir '#{logDir}:#{logDir.class}'"
          configFile = "#{logDir}/#{name}" if logDir != nil
        end
      end
      #puts "config file '#{configFile}'"
      if !(configFile || '').empty?
        ::Log4r::Configurator['appName'] = appName
        begin
          ycfg = YAML.load_file(configFile)
          ::Log4r::YamlConfigurator.decode_yaml(ycfg['log4r'])
          #::Log4r::Configurator.load_xml_file(configFile)
        # rescue ::Log4r::ConfigError => ex
          # @@logger.outputters = ::Log4r::Outputter.stdout
          # # TODO: FIX ME
          # puts("ERROR: Log::Config: #{ex}")
        end
      else
        # set default behavior
        ::Log4r::Logger.global.level = ::Log4r::ALL
        formatter = ::Log4r::PatternFormatter.new(:pattern => "%l %c: %m")
        ::Log4r::StdoutOutputter.new('console', :formatter => formatter)
        @@logger.add 'console'
        #@@logger.outputters = ::Log4r::StdoutOutputter.new('console') #Outputter.stdout
        ##@@logger.outputters = ::Log4r::Outputter.stdout
      end
    end

    def self.set_environment(root_logger_name)
      if root_logger_name.nil? || root_logger_name.empty?
        # TODO: FIX ME
        puts("ERROR: LObject: Ignoring empty root logger")
        return
      end
      @@rootLoggerName = root_logger_name
    end

    def self.logger(category)
      raise "Logger not initialized" unless @@logger

      name = "#{@@rootLoggerName}::#{category}"
      logger = Log4r::Logger[name]
      if logger == nil
        logger = Log4r::Logger.new(name)
      end
      return logger
    end

    def debug(*message)
      logger = _logger()
      logger.debug(message.join('')) if logger.debug?
    end

    def info(*message)
      logger = _logger()
      logger.info(message.join('')) if logger.info?
    end

    def warn(*message)
      logger = _logger()
      logger.warn(message.join('')) if logger.warn?
    end

    def error(*message)
      logger = _logger()
      logger.error(message.join('')) if logger.error?
    end

    def fatal(*message)
      logger = _logger()
      logger.fatal(message.join('')) if logger.fatal?
    end

    def _logger(category = nil)
      unless @logger #&& category.nil?
        cat = self.is_a?(Class) ? self.to_s + 'Class' : self.class.to_s
        if category
          cat = "#{cat}-#{category}"
        end
        @logger = OMF::Base::Loggable.logger(cat)
      end
      return @logger
    end

  end

  class LObject
    include Loggable
    extend Loggable

    def initialize(logCategory = nil)
      _logger(logCategory)
    end
  end

end

if $0 == __FILE__
  OMF::Base::Loggable.init_log 'foo'
  #puts OMF::Base::Loggable.logger('test').inspect
  o = OMF::Base::LObject.new
  #puts (o.methods - Object.new.methods).sort
  o.debug 'Something happened'

  o2 = OMF::Base::LObject.new('fancy')
  o2.debug 'Something happened'

end

