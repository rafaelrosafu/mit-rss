require 'nokogiri'
require 'open-uri'
require 'erb'

class Feed
  attr_accessor :rss_url, :title, :url, :language, :title, :subtitle,
                :author, :summary, :author, :email, :image_url, :category,
                :original_xml_url, :template_file, :output_file
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
    @length_in_secs = param.to_f
  end

  def short_description
    self.description[0..249]
  end

  def date
    Time.at(self.mtime).xmlschema
  end

  def mp3_duration
    minutes = (self.length_in_secs / 60).truncate
    seconds = ((self.length_in_secs / 60).modulo(1) * 60).truncate
    duration = "%.2d:%.2d" % [minutes, seconds]
  end
end

class Renderer
  attr_reader :erb, :feed, :episodes

  def initialize(erb_template_file, feed_info, episode_info)
    @erb = ERB.new(File.open(erb_template_file).read)
    @feed = feed_info
    @episodes = episode_info
  end
 
  def result
    @erb.result binding
  end
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

def generate_rss_feed(feed_info, episode_data)
  renderer = Renderer.new(feed_info.template_file, feed_info, episode_data)
  File.open(feed_info.output_file, 'w+') do |file|
    file.write renderer.result
  end
  feed_info.output_file
end

def convert_mit_xml_to_rss_feed(feed_info)
  episode_data = parse_xml(feed_info.original_xml_url)
  generate_rss_feed(feed_info, episode_data)
end

def generate_rss_for_MITCMS_608JS14
  feed_info = Feed.new
  feed_info.original_xml_url  = 'http://ia902606.us.archive.org/10/items/MITCMS.608JS14/MITCMS.608JS14_files.xml'
  feed_info.template_file     = './feed.xml.erb'
  feed_info.output_file       = 'MITCMS_608JS14_rss.xml'
  feed_info.rss_url           = "http://geekout.fm/mit/#{feed_info.output_file}"
  feed_info.title             = 'MIT OpenCourseWare - Game Design - Philip B. Tan, Richard Eberhardt - CMS.608 - Spring 2014'
  feed_info.url               = 'http://ocw.mit.edu/courses/comparative-media-studies-writing/cms-608-game-design-spring-2014/index.htm'
  feed_info.language          = 'en-US'
  feed_info.subtitle          = 'MIT OpenCourseWare - Game Design - CMS.608 - Spring 2014'
  feed_info.author            = 'Philip B. Tan, Richard Eberhardt, students'
  feed_info.summary           = "This course is built around practical instruction in the design and analysis of non-­digital games. It provides students the texts, tools, references, and historical context to analyze and compare game designs across a variety of genres. In teams, students design, develop, and thoroughly test their original games to better understand the interaction and evolution of game rules. Covers various genres and types of games, including sports, game shows, games of chance, card games, schoolyard games, board games, and role-­playing games."[0..249]
  feed_info.email             = ''
  feed_info.image_url         = 'http://ocw.mit.edu/courses/comparative-media-studies-writing/cms-608-game-design-spring-2014/cms-608s14.jpg'
  feed_info.category          = 'Games &amp; Hobbies'

  convert_mit_xml_to_rss_feed feed_info
end
