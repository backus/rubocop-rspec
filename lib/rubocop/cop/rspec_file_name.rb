# encoding: utf-8

module RuboCop
  module Cop
    # Checks the path of the spec file and enforces that it reflects the
    # described class/module and its optionally called out method.
    #
    # @example
    #   my_class/method_spec.rb  # describe MyClass, '#method'
    #   my_class_spec.rb         # describe MyClass
    class RSpecFileName < Cop
      include RSpec::TopLevelDescribe

      MESSAGE = 'Spec path should end with `%s`'
      METHOD_STRING_MATCHER = /^[\#\.].+/

      def on_top_level_describe(node, args)
        return unless single_top_level_describe?
        object = const_name(args.first)
        return unless object

        path_matcher = matcher(object, args[1])
        return if source_filename =~ regexp_from_glob(path_matcher)

        add_offense(node, :expression, format(MESSAGE, path_matcher))
      end

      private

      def matcher(object, method)
        path = File.join(object.split('::').map { |p| camel_to_underscore(p) })
        path += '*' + method.children.first.gsub(/\W+/, '') if method

        "#{path}*_spec.rb"
      end

      def source_filename
        processed_source.buffer.name
      end

      def camel_to_underscore(string)
        string.dup.tap do |result|
          result.gsub!(/([^A-Z])([A-Z]+)/,          '\\1_\\2')
          result.gsub!(/([A-Z]{2,})([A-Z][^A-Z]+)/, '\\1_\\2')
          result.downcase!
        end
      end

      def regexp_from_glob(glob)
        Regexp.new(glob.gsub('.', '\\.').gsub('*', '.*') + '$')
      end
    end
  end
end
