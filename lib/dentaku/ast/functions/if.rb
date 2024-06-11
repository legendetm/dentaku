require_relative '../function'

module Dentaku
  module AST
    class If < Function
      attr_reader :predicate, :left, :right

      def self.min_param_count
        3
      end

      def self.max_param_count
        3
      end

      def initialize(predicate, left, right)
        @predicate = predicate
        @left      = left
        @right     = right
      end

      def args
        [predicate, left, right]
      end

      def value(context = {})
        predicate.value(context) ? left.value(context) : right.value(context)
      end

      def node_type
        :condition
      end

      def type
        left.type
      end

      def dependencies(context = {})
        deps = predicate.dependencies(context)

        if deps.empty?
          begin
            value = predicate.value(context)
            evaluated = true
          rescue Dentaku::Error, Dentaku::ArgumentError, Dentaku::ZeroDivisionError
            evaluated = false
          end
          return value ? left.dependencies(context) : right.dependencies(context) if evaluated
        end

        (deps + left.dependencies(context) + right.dependencies(context)).uniq
      end
    end
  end
end

Dentaku::AST::Function.register_class(:if, Dentaku::AST::If)
