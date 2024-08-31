module FigureHelpers
  def audio_figure(src:, &block)
    concat_content %{<figure>
  <audio controls class="example-graphic" src="#{src}"></audio>
  <figcaption>#{markdown_render(capture_html(&block))}</figcaption>
</figure>
}
  end

  def img_figure(src:, url: nil, img_class: 'example-graphic', &block)
    img = %{<img class="#{img_class}" src="#{src}">}
    img = %{<a href="#{url}">#{img}</a>} unless url.nil?
    concat_content %{<figure>
  #{img}
  <figcaption>#{markdown_render(capture_html(&block))}</figcaption>
</figure>
}
  end

  def notes_inline_img(src:, alt:)
    # the 1.5 in the two `calc`s here is from $baseLineHeight in
    # _typebase.scss, and the 190 and 600s are from notes/main.css.scss
    # and if those change we'll need to replicate those changes here
    desktop_size = 190
    mobile_size = 600
    raw_src = Pathname.new(src)
    path = raw_src.dirname
    ext = raw_src.extname
    basename = raw_src.basename(ext)
    mime_type = "image/#{ext.tr('.', '')}"

    concat_content %{<a href="#{raw_src}"><img
srcset="#{path.join(basename.sub_ext(".#{desktop_size}-1x#{ext}"))} 190w,
        #{path.join(basename.sub_ext(".#{desktop_size}-2x#{ext}"))} 380w,
        #{path.join(basename.sub_ext(".#{mobile_size}-1x#{ext}"))} 600w,
        #{path.join(basename.sub_ext(".#{mobile_size}-2x#{ext}"))} 1200w"
sizes="(min-width: calc(600px + 2em + (1.5 * 1rem) + 1ch)) 190px,
       calc(100vw - (2em + (1.5 * 1rem) + 1ch))"
alt="#{alt}"
src="#{path.join(basename.sub_ext(".#{desktop_size}-1x#{ext}"))}" /></a>}
  end
end
