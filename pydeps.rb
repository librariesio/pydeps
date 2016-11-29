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
      cmd = command(mirror)
      _stdin, stdout, stderr = Open3.popen3(cmd)
      {
        err: stderr.read,
        res: stdout.read
      }
    end

    def find_dependencies
      with_mirror = run_command

      if !with_mirror[:err].empty?
        without_mirror = run_command(false)
        if !without_mirror[:err].empty?
          puts without_mirror[:err]
        else
          parse(with_mirror[:res])
        end
      else
        parse(with_mirror[:res])
      end
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
