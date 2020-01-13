module RegularExpressionsHelper
  def extract_upper_case_letters(word)
    word.scan(/\p{Upper}/)
  end

  def two_upper_case_letters(word)
    up_chars = extract_upper_case_letters(word)[0..1].join('')
    return up_chars if up_chars.present?

    word[0..1].upcase
  end
end
