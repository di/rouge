module Rouge
  module Guessers
    class Source < Guesser
      attr_reader :source
      def initialize(source)
        @source = source
      end

      def filter(lexers)
        # don't bother reading the input if
        # we've already filtered to 1
        return lexers if lexers.size == 1

        # If we're filtering against *all* lexers, we only use confident return
        # values from analyze_text.  But if we've filtered down already, we can trust
        # the analysis more.
        threshold = lexers.size < 10 ? 0 : 0.5

        source_text = case @source
        when String
          @source
        when ->(s){ s.respond_to? :read }
          @source.read
        else
          raise 'invalid source'
        end

        Lexer.assert_utf8!(source_text)

        source_text = TextAnalyzer.new(source_text)

        best_result = threshold
        best_match = nil
        lexers.each do |lexer|
          result = lexer.analyze_text(source_text) || 0
          return [lexer] if result == 1

          if result > best_result
            best_match = lexer
            best_result = result
          end
        end

        [best_match]
      end
    end
  end
end
