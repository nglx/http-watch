require 'rubygems'
require 'webrick/httpproxy'

@proxy_port    = ARGV[0] || 9090
@search_body   = ARGV[1]

# Optional flags

def upstream_proxy
  if prx = ENV["http_proxy"]
    URI.parse(prx)
  end
end

server = WEBrick::HTTPProxyServer.new(
    :Port => @proxy_port,
    :AccessLog => [], # suppress standard messages
    :ProxyURI => upstream_proxy,
    :ProxyContentHandler => Proc.new do |req,res|

        if not res.content_type.nil? and res.content_type.start_with? 'text/html'
          puts ">>> #{req.request_line.chomp}"
        #else
        #  puts "Ignoring content type #{res.inspect}" rescue nil
        end

    end
)
trap("INT") { server.shutdown }
server.start