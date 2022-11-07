module ResourceHelpers
  def parts(for_page = current_page)
    folder = File.dirname(for_page.path)
    sitemap.resources(true).select(&:ignored?).select { |p| p.path.match? /\A#{folder}\/parts\/(\d+)\Z/ }.sort_by { |x| File.basename(x.path).to_i }
  end

  def slides(for_page = current_page, use_full_path: false)
    folder = use_full_path ? for_page.path : File.dirname(for_page.path)
    slides = sitemap.resources(true)
      .select(&:ignored?)
      .select { |p| p.path.match? /\A#{folder}\/slides\/(\d+)\Z/ }
      .sort_by { |x| File.basename(x.path).to_i }

    for_page.data[:in_reverse_order] ? slides.reverse : slides
  end

  def notes
    sitemap.resources
      .select { |p| p.destination_path.match? /\Anotes\/(?:[^\/]+)\/index.html/ }
      .sort_by { |x| x.data[:canonical_order] }
      .reverse
  end
end
