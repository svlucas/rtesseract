# RTesseract
class RTesseract
  # Class to return formatted text from image
  class BoxText < Box

    def to_plain_text
      create_page_plain_text
    end

    def to_column_text
      create_page_columns
    end

    private

    def sort_words_top_left
      words.sort { |w, w2| y_end_first(w,w2) < 0 ? y_end_first(w,w2) :
                                   y_start_after(w,w2) > 0 ? y_start_after(w,w2) :
                                   x_end_first(w,w2) < 0 ? x_end_first(w,w2) :
                                   x_start_after(w,w2) }
    end

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



    def create_page_plain_text
      ordened_words = sort_words_top_left
      previous_word = ordened_words.first
      text = ''
      ordened_words.each do |word|
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



    def create_page_columns(words)
      ordened_words = sort_words_top_left
      previous_word = ordened_words.first
      text = ''
      ordened_words.each do |word|
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
end
