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
     frontmatter = item.transform_keys(&:to_s).to_yaml
     File.open(File.join(ARGV[0], 'slides', "#{idx+1}.md"), 'w') do |f|
       f.puts(frontmatter)
       f.puts('---')
       f.puts body
     end
   end
