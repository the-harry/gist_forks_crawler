require 'nokogiri'
require 'open-uri'

class ForksCrawler
  attr_reader :uri

  def initialize(uri)
    @uri = uri
  end

  def build_list!
    File.write('lista_curada_pelo_monstro.txt', forks_diff.join("\n"))
  end

  private

  def filter(list)
    list.delete!('{}[]"')
    list.tr(',', "\n")
    list.tr(': true', '')
    list
  end

  def raw_url(user_repo)
    "https://gist.githubusercontent.com/#{user_repo}/raw"
  end

  def good_forks
    forks = []

    Nokogiri::HTML.parse(open(uri)).css('.user-list li').map do |li|
      span = li.css('.actions')
      next if span.css('.status-modified').empty?

      forks << span.css('a').last['href']
    end

    forks
  end

  def forks_diff
    lists = []
    forks = good_forks

    forks.each_with_index do |fork, index|
      p "fork #{index+1}/#{forks.count}"
      sleep(3)

      list = open(raw_url(fork)).read
      lists << filter(list).split("\n")
    end

    lists.flatten.uniq.reject(&:empty?)
  end
end

ForksCrawler.new('https://gist.github.com/tbrianjones/5992856/forks').build_list!
