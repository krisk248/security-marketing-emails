#!/usr/bin/env ruby

require 'bundler/setup'
require 'net/imap'
require 'digest'

imap = Net::IMAP.new('imap.gmail.com', port: 993, ssl: true)
imap.authenticate('PLAIN', ENV['EMAIL'], ENV['PASSWORD'])
imap.examine('[Gmail]/Spam')

uids = imap.fetch(1..-1, 'UID').map do |fetch_data|
  fetch_data.attr['UID']
end

emails = imap.uid_fetch(uids, %w{ENVELOPE RFC822.HEADER RFC822.TEXT})

emails.map do |email|
  envelope = email.attr['ENVELOPE']
  raise StandardError, "More than 1 from: #{enveloper.from}" if envelope.from.length > 1

  from = envelope.from.first
  headers = email.attr['RFC822.HEADER']
  body = email.attr['RFC822.TEXT']
  date = Date.parse(envelope.date).strftime('%Y-%m')

  filename = "data/#{date}/#{from.mailbox}@#{from.host} (#{from.name}) - #{envelope.subject.gsub('/', '_')} - #{Digest::MD5.hexdigest(body)}.eml"
  raise StandardError, "File '#{filename}' already exists" if File.exists?(filename)

  Dir.mkdir("data/#{date}") rescue Errno::EEXIST

  IO.write(filename, "#{headers}\n#{body}")
end
