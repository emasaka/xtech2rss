#!/usr/bin/env ruby

require 'nokogiri'
require 'rss'
require 'open-uri'
require 'time'

def xtech2rss(url)
  open(url) do |f|
    RSS::Maker.make('atom') do |maker|
      doc = Nokogiri::HTML(f)

      maker.channel.link = url
      maker.channel.about = URI.join(url, 'atom.xml').to_s
      maker.channel.title = doc.css('title').text
      maker.channel.description = doc.xpath('/html/head/meta[@name="description"]/@content')
      maker.channel.author = 'xtech2rss'
      maker.channel.updated = Time.now.to_s

      doc.css('li.FREE div.text').each do |node|
        maker.items.new_item do |item|
          headding = node.css('h3 a')[0]
          item.link = URI.join(url, headding[:href]).to_s
          item.title = headding.text
          item.date = Time.strptime(node.css('time').text, '（%Y/%m/%d）')
          item.summary do |summary|
            summary.type = 'html'
            summary.content = node.css('p').to_s
          end
        end
      end
    end.to_s
  end
end

if __FILE__ == $0
  puts xtech2rss(ARGV[0])
end
