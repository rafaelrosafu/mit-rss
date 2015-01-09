require 'nokogiri'
require 'open-uri'

class Feed
  attr_accessor :rss_url, :title, :url, :language, :title, :subtitle
                :author, :summary, :author, :email, :image_url, :category
end

class Episode
  attr_accessor :title, :description, :mp3_url,
                :mp3_length, :mp3_duration, :tags
  attr_reader   :mtime, :length_in_secs

  def mtime=(param)
    @mtime = param.to_i
  end

  def size=(param)
    @size = param.to_i
  end

  def length_in_secs=(param)
    @length = param.to_f
  end

  def short_description
    self.description[0..249]
  end

  def date
    Time.at(self.mtime).xmlschema
  end

  def duration
    minutes = (self.length_in_secs / 60).truncate
    seconds = ((self.length_in_secs / 60).modulo(1) * 60).truncate
    duration = "%.2d:%.2d" % [minutes, seconds]
  end
end

def convert_mit_xml_to_rss_feed(mit_xml_url, feed_info, template_file)
  episode_data = parse_xml(mit_xml_url)
  generate_rss_feed(feed_info, episode_data, template_file)
end

def parse_xml(mit_xml_url)
  uri = URI.parse(mit_xml_url)
  file = "./#{uri.path.split("/").last}"

  xml = Nokogiri::XML(open(mit_xml_url))

  remote_files = xml.xpath('//file')

  result = []

  remote_files.each do |remote_file|
    extension = File.extname(remote_file['name'])
    next unless extension == ".mp3"

    remote_file_path = uri.path.split('/')[0..-2].concat([remote_file['name']]).join('/')
    uri.path = remote_file_path

    episode = Episode.new
    episode.title = remote_file.children.at('title').text
    episode.description = remote_file.children.at('title').text
    episode.mp3_url = uri.to_s
    episode.mp3_length = remote_file.children.at('size').text
    episode.length_in_secs = remote_file.children.at('length').text
    episode.mtime = remote_file.children.at('mtime').text
    episode.tags = []

    result << episode
  end

  result
end

def generate_rss_feed(feed_info, episode_data, template_file)

end

def run
  feed_info = Feed.new
  feed_info.rss_url = 'http://rafaelrosafu.info/MITCMS.608JS14_rss.xml'
  feed_info.title = 'MIT OpenCourseware - Game Design - Philip B. Tan, Richard Eberhardt - '
  feed_info.url
  feed_info.language
  feed_info.title
  feed_info.subtitle
  feed_info.author
  feed_info.summary
  feed_info.author
  feed_info.email
  feed_info.image_url
  feed_info.category


  convert_mit_xml_to_rss_feed 'http://ia902606.us.archive.org/10/items/MITCMS.608JS14/MITCMS.608JS14_files.xml',
                              {}, './feed.xml.erb'
end
