require 'nokogiri'
require 'yaml'

puts ARGV[0]

talk_index = File.read(File.join(ARGV[0], 'index.html'))

doc = Nokogiri::HTML(talk_index)

toc = doc.css('#menu ul li [href]')
toc.select { |item| item.attribute('href').value.match?(/\A\#slide/) }
   .map { |item| {title: item.text.gsub(/\A\d+\:\s+/, ''), id: item.attribute('href').value.tr('#','') } }
   .map do |item|
     slide_content = doc.css("##{item[:id]}")
     image = slide_content.css('figure.slides img')
     item[:slide] = {
       image_url: image.attribute('src').value,
       image_alt: image.attribute('alt').value,
       image_title: image.attribute('title').value
     }
     item[:body] = slide_content.css('.transcript').children.to_html
     item
   end
   .each.with_index do |item, idx|
     body = item.delete(:body)
     abbrevs = {}
     erb_used = false
     body = body.lines
       .map(&:strip)
       .map do |l|
         l.gsub('<p>', '')
          .gsub('</p>',"\n\n")
          .gsub(/<a href="([^"]+)">(.+?)<\/a>/, '[\2](\1)')
          .gsub(/<a id="fn-(\d+)-return" href="#fn-\1"><sup>\1<\/sup><\/a>/) do
            reference = Regexp.last_match[1]
            erb_used = true
            "<% footnote_reference #{reference} %>"
          end
          .gsub(/<code>(.+?)<\/code>/, '`\1`')
          .gsub(/<abbr title="([^"]+)">(.+?)<\/abbr>/) do
            abbrev = Regexp.last_match[2]
            definition = Regexp.last_match[1]
            if abbrevs.key? abbrev && abbrevs[abbrev] != definition
              puts "Uh oh, already defined #{abbrev} as #{abbrevs[abbrev]} not as #{definition}"
            else
              abbrevs[abbrev] = definition
            end
            abbrev
          end
       end
       .join "\n"
       .strip
     body = body.lines.map do |l|
         l.gsub(/<ol>(.+?)<\/ol>/) { Regexp.last_match[1].gsub(/<li>(.+?)<\/li>/, "1. \\1\n") + "\n" }
          .gsub(/<ul>(.+?)<\/ul>/) { Regexp.last_match[1].gsub(/<li>(.+?)<\/li>/, "* \\1\n") + "\n" }
       end
       .join "\n"
       .strip
     frontmatter = item.transform_keys(&:to_s).to_yaml
     file_name = "#{idx+1}.md"
     file_name << '.erb' if erb_used
     File.open(File.join(ARGV[0], 'slides', file_name), 'w') do |f|
       f.puts(frontmatter)
       f.puts('---')
       f.puts body
       if abbrevs.any?
         f.puts
         f.puts abbrevs.map { |abbrev, definition| "*[#{abbrev}]: #{definition}"}.join("\n")
       end
     end
   end
