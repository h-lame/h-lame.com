set :css_dir, 'styles'
set :js_dir, 'scripts'
set :images_dir, 'images'
set :build_dir, 'public'

# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false
page '/.htaccess', layout: false
page '/*.ico', layout: false

page "/talks/*", :layout => "talks"

ignore "/talks/slides/*.md*"
ignore "/talks/**/slides/*.md*"
# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

helpers do
  def page_title(for_page = current_page)
    yield_content(:title) || for_page.data.title
  end

  def page_meta_description(for_page = current_page)
    for_page.data[:description]
  end

  def toc_name(for_page = current_page)
    for_page.data[:toc_name] || 'Table of contents'
  end

  def slides(for_page = current_page)
    folder = File.dirname(for_page.path)
    sitemap.resources(true).select(&:ignored?).select { |p| p.path.match? /\A#{folder}\/slides\/(\d+)\Z/ }.sort_by { |x| File.basename(x.path).to_i }
  end

  def footnote_reference(number)
    concat_content %{<a id="fn-#{number}-return" href="#fn-#{number}"><sup>#{number}</sup></a>}
  end

  def footnote_definition(number, &block)
    footnote = capture_html(&block)

    concat_content %{<a id="fn-#{number}"><sup>#{number}.</sup></a> #{footnote} <a href="#fn-#{number}-return"><sup>⏎</sup></a>}
  end

  def markdown(inline: false, strip_tags: false, &block)
    raise ArgumentError, "Missing block" unless block_given?
    content = capture_html(&block)
    rendered = Tilt['markdown'].new(context: @app) { content }.render
    rendered = rendered.gsub('<p>', '').gsub("</p>", '').gsub("\n", '') if inline
    rendered = strip_tags(rendered) if strip_tags
    concat rendered
  end
end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

# configure :build do
#   activate :minify_css
#   activate :minify_javascript
# end
