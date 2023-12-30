module FootnoteHelpers
  def footnotes(&block)
    content_for(:footnotes, &block)
  end

  def footnote_reference(number=(self.footnotes_ref_count+=1), multi_ref=nil)
    return_id = "fn-#{number}-return"
    return_id << "-#{multi_ref}" unless multi_ref.nil?
    concat_content %{<a id="#{return_id}" href="#fn-#{number}"><sup>#{number}</sup></a>}
  end
  alias :fnrf :footnote_reference

  def footnote_definition(number=(self.footnotes_def_count+=1), multi_refs=nil, &block)
    footnote = capture_html(&block)

    return_links =
      if multi_refs.nil?
        %{<a href="#fn-#{number}-return"><sup>⏎</sup></a>}
      else
        1.upto(multi_refs).map do |ref|
          %{<a href="#fn-#{number}-return-#{ref}"><sup>⏎ #{ref}</sup></a>}
        end.join(' ')
      end

    concat_content %{<a id="fn-#{number}"><sup>#{number}.</sup></a> #{footnote} #{return_links}}
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
