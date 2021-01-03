require 'imgkit'
require 'optparse'
require 'rouge'
require 'tempfile'
require 'rexml/document'

class SetOption

    def initialize
        @options = {}
        OptionParser.new do |opt|
            opt.on('-n','--name ITEM','Specify the file name') {|v|@options[:name] = v}
            opt.on('-l','--language ITEM','Specify the language') {|v|@options[:lang] = v}
            opt.on('-h','--help','show this help') {|v|puts opt;exit}
            opt.parse!(ARGV)
        end
    end

        def has?(name)
            @options.include?(name)
        end

        def get(name)
            @options[name]
        end

        def getARGV
            ARGV
        end
end


opt = SetOption.new
filename = if opt.has?(:name)
    opt.get(:name)
else
    "code.png"
end


if ARGV.length > 0
    source = File.read(ARGV[0])
    formatter = Rouge::Formatters::HTML.new
    lexer = if opt.has?(:lang)
        Rouge::Lexer.find(opt.get(:lang))
    else
        Rouge::Lexer.find_fancy('guess', source)
    end

    html = formatter.format(lexer.lex(source))
    css = Rouge::Themes::ThankfulEyes.render(scope: '.highlight')
    template = <<EOS
    <!DOCTYPE html>
    <html lang="ja">
    <head>
    <style type="text/css">
    body {
        margin: 0 0 0 0;
      }
      pre {
        margin: 0 0 0 0;
      }
#{css}
    </style>
    </head>
    <body>
    <pre class="highlight">
#{html}
    </pre>\n\n</body>\n</html>
EOS
    
    File.open('code.html','w'){|f|f.write(template)}
    img = IMGKit.new(File.open('code.html','r'), quality: 20)
    File.open(filename,mode = "wb") do |file|
        file.write(img.to_png)
    end
    File.delete("code.html")
else
    puts "c2apture.rb [OPTIONS] <program file>"
end

