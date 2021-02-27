module PagePartHelpers
  def page_title(for_page = current_page)
    yield_content(:title) || for_page.data.title
  end

  def page_description(for_page = current_page)
    markdown_render(for_page.data.fetch(:description, ''), inline: true)
  end

  def page_meta_description(for_page = current_page)
    markdown_render(for_page.data.fetch(:description, ''), inline: true, strip_tags: true)
  end

  def toc_name(for_page = current_page)
    for_page.data[:toc_name] || 'Table of contents'
  end
end
