def replace_header(head, header_name)
  head.sub!(/(\.#{header_name}\s*= ').*'/) { "#{$1}#{send(header_name)}'"}
end

def normalize_bullets(markdown)
  markdown.gsub(/\s{2}\*{1}/, "-")
end

def linkify_prs(markdown)
  markdown.gsub(/#(\d+)/) do |word|
    "[#{word}]({{ site.repository }}/issues/#{word.delete("#")})"
  end
end

def linkify_users(markdown)
  markdown.gsub(/(@\w+)/) do |username|
    "[#{username}](https://github.com/#{username.delete("@")})"
  end
end

def linkify(markdown)
  linkify_users(linkify_prs(markdown))
end

def liquid_escape(markdown)
  markdown.gsub(/(`{[{%].+[}%]}`)/, "{% raw %}\\1{% endraw %}")
end

def remove_head_from_history(markdown)
  index = markdown =~ /^##\s+\d+\.\d+\.\d+/
  markdown[index..-1]
end

def converted_history(markdown)
  remove_head_from_history(liquid_escape(linkify(normalize_bullets(markdown))))
end

# File activesupport/lib/active_support/inflector/transliterate.rb, line 80
def parameterize(string, sep = '-')
  # replace accented chars with their ascii
  # simplified from original to remove dependency
  parameterized_string = string.dup.force_encoding('US-ASCII')
  # Turn unwanted chars into the separator
  # changed from original: allow A-Z
  parameterized_string.gsub!(/[^a-zA-Z0-9\-_]+/, sep)
  unless sep.nil? || sep.empty?
    re_sep = Regexp.escape(sep)
    # No more than one of the separator in a row.
    parameterized_string.gsub!(/#{re_sep}{2,}/, sep)
    # Remove leading/trailing separator.
    parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/, '')
  end
  parameterized_string.downcase
end

# def check_destination
#   unless Dir.exist? CONFIG["destination"]
#     sh "git clone https://#{ENV['GIT_NAME']}:#{ENV['GH_TOKEN']}@github.com/#{USERNAME}/#{REPO}.git #{CONFIG["destination"]}"
#   end
# end
