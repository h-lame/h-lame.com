require 'nokogiri'
require 'yaml'
require 'fileutils'

def write_slide(item, slide_number, path)
  frontmatter = item[:frontmatter].transform_keys(&:to_s).to_yaml
  file_name = "#{slide_number}.md"
  file_name << '.erb' if item[:config][:erb_used]
  File.open(File.join(path, file_name), 'w') do |f|
    f.puts(frontmatter)
    f.puts('---')
    f.puts item[:body]
    if item[:config][:abbrevs].any?
      f.puts
      f.puts item[:config][:abbrevs].map { |abbrev, definition| "*[#{abbrev}]: #{definition}" }.join("\n")
    end
  end
end

def extract_slide_content_from_doc(item, doc)
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

def convert_html_to_markdown_line_pass_1(line, config)
  line
    .gsub('<p>', '')
    .gsub('</p>',"\n\n")
    .gsub(/<a href="([^"]+)">(.+?)<\/a>/, '[\2](\1)')
    .gsub(/<a id="fn-(\d+)-return" href="#fn-\1"><sup>\1<\/sup><\/a>/) do
     reference = Regexp.last_match[1]
     config[:erb_used] = true
     "<% footnote_reference #{reference} %>"
    end
    .gsub(/<code>(.+?)<\/code>/, '`\1`')
    .gsub(/<(em|i)>(.+?)<\/\1>/, '*\2*')
    .gsub(/<(strong|b)>(.+?)<\/\1>/, '**\2**')
    .gsub(/<abbr title="([^"]+)">(.+?)<\/abbr>s?/) do
      abbrev = Regexp.last_match[2]
      plural_abbrev = "#{abbrev}s"
      definition = Regexp.last_match[1]
      if config[:abbrevs].key? abbrev && config[:abbrevs][abbrev] != definition
        puts "Uh oh, already defined #{abbrev} as #{abbrevs[abbrev]} not as #{definition}"
      else
        config[:abbrevs][plural_abbrev] = definition
        config[:abbrevs][abbrev] = definition
      end
      Regexp.last_match[0].end_with?('s') ? plural_abbrev : abbrev
    end
end

def convert_html_to_markdown_line_pass_2(line, _config)
  line
    .gsub(/<ol>(.+?)<\/ol>/) { Regexp.last_match[1].gsub(/<li>(.+?)<\/li>/, "1. \\1\n") + "\n" }
    .gsub(/<ul>(.+?)<\/ul>/) { Regexp.last_match[1].gsub(/<li>(.+?)<\/li>/, "* \\1\n") + "\n" }
end

def convert_content_to_markdown(item)
  body = item.delete(:body)
  config = {
    abbrevs: {},
    erb_used: false
  }
  body = body.lines
    .map(&:strip)
    .map { |l| convert_html_to_markdown_line_pass_1(l, config) }
    .join "\n"
    .strip
  body = body.lines
    .map { |l| convert_html_to_markdown_line_pass_2(l, config) }
    .join "\n"
    .strip
  {body: body, config: config, frontmatter: item}
end

def extract_slides(links, path, doc)
  path = File.join(path, 'slides')
  FileUtils.mkdir_p path
  links
    .select { |item| item.attribute('href').value.match?(/\A\#slide/) }
    .map { |item| extract_slide(item, doc) }
    .each.with_index { |item, idx| write_slide(item, idx+1, path) }
end

def extract_slide(link, doc)
  convert_content_to_markdown(
    extract_slide_content_from_doc(
      {title: link.text.gsub(/\A\d+\:\s+/, ''), id: link.attribute('href').value.tr('#','') },
      doc
    )
  )
end


puts ARGV[0]

talk_index = File.read(File.join(ARGV[0], 'index.html'))

doc = Nokogiri::HTML(talk_index)

toc = doc.css('#menu ul li [href]')
extract_slides(toc, ARGV[0], doc)
