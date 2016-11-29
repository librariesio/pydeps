require "open3"

module Pydeps
  class Resolver
    attr_accessor :name
    attr_accessor :version

    def initialize(name, version)
      @name = name
      @version = version
    end

    def run_command(mirror = true)
      _stdin, stdout, stderr = Open3.popen3(command(mirror))
      { err: stderr.read, res: stdout.read }
    end

    def run_with_fallback
      with_mirror = run_command
      return with_mirror[:res] if with_mirror[:err].empty?
      without_mirror = run_command(false)
      return with_mirror[:res] if without_mirror[:err].empty?
    end

    def find_dependencies
      output = run_with_fallback
      parse(output) if output
    end

    def parse(output)
      output.split("\n")
    end

    def command(mirror = true)
      mirror_flags = mirror ? "-i http://pypi.libraries.io/simple --no-binary :all: --trusted-host pypi.libraries.io" : ""
      "pip download #{name}==#{version} -d /tmp #{mirror_flags} | grep 'from #{name}' | cut -d' ' -f2"
    end
  end
end
