#!/usr/bin/env ruby

class Solution
  def initialize(words)
    @words = words
  end

  def solutions
    @words
  end

  def select_matches(re)
    Solution.new(@words.select{|w| w =~ /#{re}/})
  end

  def reject_includes(rejectedLetters)
    Solution.new(@words.reject do |w|
      rejectedLetters.any? do |l|
        w.include?(l)
      end
    end)
  end

  def select_includes(matchLetters)
    Solution.new(@words.select do |w|
      matchLetters.all? do |l|
        w.include?(l)
      end
    end)
  end

  def sort_by_frequency(frequencies)
    @words.sort_by{|w| w.split("").uniq.map{|l| frequencies[l] }.reduce(&:+) }.reverse
  end
end

class WordleSolver
  def initialize(words, wordLen = 5)
    @words = Solution.new(words)
    @frequencies = get_frequencies(words)
    @maybeLetters = []
    @rejectedLetters = []
    @guessedLetters = []
    @candidates = Array.new(wordLen, "abcdefghijklmnopqrstuvwxyz".split(""))
  end

  def guess(word, correctness)
    @guessedLetters += word.split("")

    word.split("").each.with_index do |l, i|
      if correctness[i] == "y" # yes, green
        @candidates[i] = [l]
      elsif correctness[i] == "n" # no, grey
        @rejectedLetters += [l]
      elsif correctness[i] == "m" # maybe, yellow
        @maybeLetters += [l]
        @candidates[i] -= [l]
      end
    end

    @candidates = @candidates.map do |candidate|
      candidate - @rejectedLetters
    end

    @candidateReStr = @candidates.map{|c| "[#{c.join}]"}.join
  end

  def best_information
    @words.reject_includes(@guessedLetters).
      # reject_includes(@maybeLetters).
      # reject_includes(@rejectedLetters).
      sort_by_frequency(@frequencies)
  end

  def best_guess
    @words.select_matches(@candidateReStr).
      select_includes(@maybeLetters).
      sort_by_frequency(@frequencies)
  end

  private

  def get_frequencies(words)
    letters = words.join
    letters.
      split("").
      group_by(&:to_s).
      map do |a|
        [a[0], a[1].count.to_f/letters.length.to_f]
      end.sort_by do |a|
        a[1]
      end.reverse.to_h
  end
end

words = File.read("words.txt").split("\r\n")
solver = WordleSolver.new(words)

while true
  puts "Best guess for information: #{solver.best_information.first(5)}"
  puts "Input guess and correctness"
  guess = gets.chomp
  if guess == "exit"
    puts "Goodbye!"
    break
  elsif guess == "new"
    solver = WordleSolver.new(words)
    puts "Starting a new game"
    next
  end

  correctness = gets.chomp

  solver.guess(guess, correctness)
  newGuesses = solver.best_guess

  puts "All possibilities: #{newGuesses}"
  puts "Best guesses for the word: #{newGuesses.first(5)}"
end
