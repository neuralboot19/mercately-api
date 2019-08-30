module RegularExpressionsHelper
  def extract_upper_case_letters(word)
    word.scan(/\p{Upper}/)
  end

  def two_upper_case_letters(word)
    extract_upper_case_letters(word)[0..1].join('')
  end
end
