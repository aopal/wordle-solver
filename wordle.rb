#!/usr/bin/env ruby

words = File.read("words.txt").split("\r\n")
frequencies = {"E"=>12.02, "T"=>9.10, "A"=>8.12, "O"=>7.68, "I"=>7.31, "N"=>6.95, "S"=>6.28, "R"=>6.02, "H"=>5.92, "D"=>4.32, "L"=>3.98, "U"=>2.88, "C"=>2.71, "M"=>2.61, "F"=>2.30, "Y"=>2.11, "W"=>2.09, "G"=>2.03, "P"=>1.82, "B"=>1.49, "V"=>1.11, "K"=>0.69, "X"=>0.17, "Q"=>0.11, "J"=>0.10, "Z"=>0.07}

letters = "abcdefghijklmnopqrstuvwxyz".split("")
candidates = [letters, letters, letters, letters, letters]
maybeLetters = []
rejectedLetters = []

while true
  puts "Input guess and correctness"
  guess = gets.chomp
  correctness = gets.chomp

  guess.split("").each.with_index do |l, i|
    if correctness[i] == "y" # yes, green
      candidates[i] = [l]
    elsif correctness[i] == "n" # no, grey
      rejectedLetters += [l]
    elsif correctness[i] == "m" # maybe, yellow
      maybeLetters += [l]
      candidates[i] -= [l]
    end
  end

  candidates = candidates.map do |candidate|
    candidate - rejectedLetters
  end

  candidateReStr = candidates.map{|c| "[#{c.join}]"}.join

  guesses = words.
    select{|w| w =~ /#{candidateReStr}/}.
    select{|w| maybeLetters.all?{|l| w.include?(l)}}.
    sort_by{|w| w.split("").uniq.map{|l| frequencies[l.upcase] }.reduce(&:+) }.reverse

  puts "candidates: #{guesses}"
  puts "best guesses: #{guesses.first(5)}"
end
