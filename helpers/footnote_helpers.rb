module FootnoteHelpers
  def footnotes(&block)
    content_for(:footnotes, &block)
  end

  def footnote_reference(number=(self.footnotes_ref_count+=1))
    concat_content %{<a id="fn-#{number}-return" href="#fn-#{number}"><sup>#{number}</sup></a>}
  end
  alias :fnrf :footnote_reference

  def footnote_definition(number=(self.footnotes_def_count+=1), &block)
    footnote = capture_html(&block)

    concat_content %{<a id="fn-#{number}"><sup>#{number}.</sup></a> #{footnote} <a href="#fn-#{number}-return"><sup>⏎</sup></a>}
  end
  alias :fndf :footnote_definition

  def footnotes_ref_count
    @footnotes_ref_count ||= 0
  end
  attr_writer :footnotes_ref_count
  def footnotes_def_count
    @footnotes_def_count ||= 0
  end
  attr_writer :footnotes_def_count
end
