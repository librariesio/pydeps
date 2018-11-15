require "open3"
require "fileutils"

module Pydeps
  class Resolver
    attr_accessor :name
    attr_accessor :version

    def initialize(name, version)
      @name = name
      @version = version
    end

    def find_dependencies
      memcached_client.fetch(cache_key) do
        output = run_fetch
        output ? parse(output) : "err"
      end
    end

    def to_json
      find_dependencies.map do |dep|
        match = dep.gsub(' ', '').match(/^([a-z0-9]+[a-z0-9\-_\.]+)([><=\d\.,]+)?/i)
        name = match[1]
        requirements = match[2]
        {
          name: name,
          requirements: requirements
        }
      end.to_json
    end

    private

    def memcached_client
      Dalli::Client.new((ENV["MEMCACHIER_SERVERS"] || "localhost:11211").split(","),
        {
          username: ENV["MEMCACHIER_USERNAME"],
          password: ENV["MEMCACHIER_PASSWORD"],
          failover: true,
          socket_timeout: 1.5,
          socket_failure_delay: 0.2
        })
    end

    def cache_key
      [name, version].join('-')
    end

    def parse(output)
      output.split("\n")
    end

    def command(tmpdir)
      "pip download #{name}==#{version} -d #{tmpdir} --no-cache-dir --no-binary all | grep 'from #{name}' | cut -d' ' -f2"
    end

    def run_fetch
      begin
        tmpdir = Dir.mktmpdir
        _stdin, stdout, stderr = Open3.popen3(command(tmpdir))
        result = { err: stderr.read, res: stdout.read }
        return result[:res] if result[:err].empty?
      ensure
        FileUtils.rm_rf(tmpdir)
      end
    end
  end
end
