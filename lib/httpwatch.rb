require 'rubygems'
require 'webrick/httpproxy'

@proxy_port    = ARGV[0] || 9090
@search_body   = ARGV[1]

# Optional flags
@print_headers  = true
@print_body     = true
@pretty_colours = false

server = WEBrick::HTTPProxyServer.new(
    :Port => @proxy_port,
    :AccessLog => [], # suppress standard messages

    :ProxyContentHandler => Proc.new do |req,res|
        puts "-"*75
        puts ">>> #{req.request_line.chomp}\n"
        req.header.keys.each do |k|
            puts "#{k.capitalize}: #{req.header[k]}" if @print_headers
        end

        puts "<<<" if @print_headers
        puts res.status_line if @print_headers
        res.header.keys.each do |k|
            puts "#{k.capitalize}: #{res.header[k]}" if @print_headers
        end
        unless res.body.nil? or !@print_body then
            body = res.body.split("\n")
            line_no = 1
            body.each do |line|
              if line.to_s =~ /#{@search_body}/ then
                puts "\n<<< #{line_no} #{line.gsub(/#{@search_body}/,
                  "\e[32m#{@search_body}\e[0m")}" if   @pretty_colours
                puts "\n<<< #{line_no} #{line}" unless @pretty_colours
              end
              line_no += 1
            end
        end
    end
)
trap("INT") { server.shutdown }
server.start