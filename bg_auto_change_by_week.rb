#!/usr/bin/env ruby

require 'rest-client'
require 'nokogiri'

RETRY_TIMES = 3
BASE_PATH = '/Users/limbo.d/Pictures/wallpaper/'
BASE_URL = 'https://magdeleine.co/?s='
KEYWORD = []
KEYWORD << 'cat'
KEYWORD << 'dragon'
KEYWORD << 'tiger'
KEYWORD << 'rabbit'
KEYWORD << 'dog'
KEYWORD << 'cat'
KEYWORD << 'horse'
KEYWORD << 'apple'

def start_daily_engine
  topic = select_topic_by_wday
  request_url = BASE_URL + topic
  resp = rest_get(request_url)
  pic_url_repo = parse_pic_address_from_resp(resp)
  pic_url_repo ||= search_with_google_engine(topic)
  clear_base_dir
  download_selected_pic(pic_url_repo)
end

def search_with_google_engine(topic)
  request_url = 'https://www.google.com/search?newwindow=1&biw=1309&bih=441&tbs=isz%3Al&tbm=isch&sa=1&q=#{topic}&oq=#{topic}&gs_l=psy-ab.3...630000.634862.0.635194.25.15.1.0.0.0.805.805.6-1.1.0....0...1.1j4.64.psy-ab..23.2.811.0..0.p36iWOAcEG8#imgrc=yLTLCIxZTqjATM:'
  resp = rest_get(request_url)
  parsed_data = Nokogiri::HTML.parse(resp)
end

def parse_pic_address_from_resp(resp)
  parsed_data = Nokogiri::HTML.parse(resp)
  anchor_tags = parsed_data.xpath('//img[@src]')
  if anchor_tags.nil?
    puts 'can not find content!'
    return nil
  end
  pic_url_repo = []
  anchor_tags.each do |tags|
    src = tags[:src]
    tag = src.split('//')[1]
    next unless tag =~ /^cdn.magdeleine.co*/
    target_address = remove_px_number(src)
    pic_url_repo << target_address
  end
  pic_url_repo.uniq!
end

def download_selected_pic(target_addresses)
  target_addresses.each do |address|
    file_byte = rest_get(address)
    file_name = address.split('/').last
    file_path = BASE_PATH + file_name
    f = File.new(file_path,'w+')
    f.write(file_byte)
    if f.size < 100 * 1024
      File.delete(f)
    else
      puts "file #{file_name} save complete"
    end
    f.close
  end
end

def remove_px_number(src_address)
  suffix = src_address.split('-').last.split('.')
  px_number = suffix.first
  ready_to_delete_str = '-' + px_number
  src_address.sub(ready_to_delete_str, '')
end

def clear_base_dir
  Dir.foreach(BASE_PATH) do |file_name|
    invalid_note = ['.', '..']
    next if invalid_note.include?(file_name)
    file_path = BASE_PATH + file_name
    File.delete(file_path)
  end
end

def rest_get(request_url)
  retries ||= 0
  RestClient.proxy = 'http://duotai:5R9WZLVz8@conrad.h.xduotai.com:15157'
  RestClient.get(request_url)
rescue
  retry if (retries += 1) < RETRY_TIMES
end

def select_topic_by_wday
  KEYWORD[Time.now.wday - 1]
end

start_daily_engine
