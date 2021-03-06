require "thor"

module DaimonSkycrawlers
  module Generator
    class Processor < Thor::Group
      include Thor::Actions

      argument :name

      def self.source_root
        File.join(__dir__, "templates")
      end

      def create_files
        config = {
          class_name: name.classify,
        }
        template("processor.rb.erb", "app/processors/#{name.underscore}.rb", config)
      end

      def display_post_message
        puts <<MESSAGE

You can register your processor in `app/processor.rb` to run your processor.
Following code snippet is useful:

    processor = #{name.classify}.new
    DaimonSkycrawlers.register_processor(processor)

MESSAGE
      end
    end
  end
end
