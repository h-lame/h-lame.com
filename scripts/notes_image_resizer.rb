#require 'rszr'
require 'vips'
require 'image_processing'
require 'pathname'

desktop_size = 190
mobile_size = 600
raw_src = Pathname.new(ARGV[0])
path = raw_src.dirname
ext = raw_src.extname
basename = raw_src.basename(ext)

[desktop_size, mobile_size].each do |image_size|
  [1, 2].each do |scale|
    new_file = path.join(basename.sub_ext(".#{image_size}-#{scale}x#{ext}"))
    image_width = image_size * scale
    ImageProcessing::Vips
      .source(raw_src)
      .resize_to_limit(image_width, nil)
      .saver(quality: 95)
      .custom do |vi|
        vi.get_fields.each do |vif|
          vi.remove vif unless vif == 'icc-profile-data'
        end
        vi
      end
      .call(destination: new_file.to_path)
  end
end
