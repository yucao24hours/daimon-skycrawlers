require "thor"
require "daimon_skycrawlers/generator/new"
require "daimon_skycrawlers/commands/enqueue"
require "daimon_skycrawlers/commands/runner"
require "daimon_skycrawlers/version"

module DaimonSkycrawlers
  class CLI < Thor
    register(Generator::New, "new", "new NAME", "Create new project")
    register(Commands::Runner, "exec", "exec [COMMAND]", "Execute crawler/processor")
    register(Commands::Enqueue, "enqueue", "enqueue [TYPE] URL [messages...]", "Enqueue URL")

    desc "version", "Show version"
    def version
      puts VERSION
    end
  end
end
