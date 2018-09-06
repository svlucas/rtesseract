# RTesseract
class RTesseract
  # Class to return formatted text from image
  class BoxText < Box

    def plain_text
      @plain_text ||= read_text(plain_texter)
    end


    def column_text
      @column_text ||= read_text(column_texter)
    end

    private

    def sorter
      @sorter ||= Sorter.new
    end

    def plain_texter
      @plain_texter ||= PlainText.new
    end

    def column_texter
      @column_texter ||= ColumnText.new
    end


    def read_text(words, texter)
      texter.read_words(sorter.sort_words_top_left(words))
    end


  end
  # Class to sort words by orientation
  class Sorter

    def sort_words_top_left
      words.sort { |w, w2| y_end_first(w,w2) < 0 ? y_end_first(w,w2) :
                                   y_start_after(w,w2) > 0 ? y_start_after(w,w2) :
                                   x_end_first(w,w2) < 0 ? x_end_first(w,w2) :
                                   x_start_after(w,w2) }
    end

    private

    def y_end_first(w,w2)
      return has_values(w,w2) unless has_values(w,w2) > 1
      w[:y_end] <=> w2[:y_start]
    end

    def y_start_after(w,w2)
      return has_values(w,w2) unless has_values(w,w2) > 1
      w[:y_start] <=> w2[:y_end]
    end

    def x_end_first(w,w2)
      return has_values(w,w2) unless has_values(w,w2) > 1
      w[:x_end] <=> w2[:x_start]
    end

    def x_start_after(w,w2)
      return has_values(w,w2) unless has_values(w,w2) > 1
      w[:x_start] <=> w2[:x_end]
    end

    def has_values(w,w2)
      return -1 if (w.nil?)
      return 1 if(w2.nil?)
      2
    end

  end
  # Base class to create text
  class BaseText

    private

    def spaces_fit(word, previous_word)
      (distance_between_words(word, previous_word).to_f / space_size(word).to_f)
    end

    def distance_between_words(word, previous_word)
      word[:x_start] - previous_word[:x_end]
    end

    def space_size(word)
      (word[:x_end] - word[:x_start]) / word[:word].length
    end

  end
  # Class to create plain text
  class PlainText < BaseText

    def read_words(words)
      create_plain_text(words)
    end

    private

    def create_plain_text(words)
      previous_word = words.first
      text = ''
      words.each do |word|
        text << add_to_plain_text(word, previous_word)
        previous_word = word
      end
      text
    end

    def add_to_plain_text(word, previous_word)
      "#{add_plain_text_separator(word, previous_word)}#{word[:word]}"
    end

    def add_plain_text_separator(word, previous_word)
      if(word[:x_start] < previous_word[:x_end])
        "\n"
      else 
        plain_text_space(word, previous_word)
      end
    end

    def plain_text_space(word, previous_word)
      spaces_fit = spaces_fit(word, previous_word)
      space = ""
      if(spaces_fit > 0.3)
        (spaces_fit.to_i + 1).times{space << "\s"}
      end
      space
    end

  end
  # Class to create text with column
  class ColumnText < BaseText

    def read_words(words)
      create_columns(words)
    end

    private

    def create_columns(words)
      previous_word = words.first
      text = ''
      words.each do |word|
        text << add_to_columns(word, previous_word)
        previous_word = word
      end
      text
    end

    def add_to_columns(word, previous_word)
      "#{add_columns_separator(word, previous_word)}#{word[:word]}"
    end

    def add_columns_separator(word, previous_word)
      if(word[:x_start] < previous_word[:x_end])
        "\n"
      else 
        column_or_space(word, previous_word)
      end
    end

    def column_or_space(word, previous_word)
      spaces_fit = spaces_fit(word, previous_word)
      if(spaces_fit > 1.5)
        "\t"
      elsif(spaces_fit < 0.3)
        ""
      else
        "\s"
      end
    end

  end

end
