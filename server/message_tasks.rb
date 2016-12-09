module MessageTasks
  def gen_datetime
    Time.now.gmtime.strftime("%a, %d %b %Y %T GMT")
  end

  def header_fields
    "Date:#{gen_datetime}\r\nServer:Simple-Server\r\nConnection: Close\r\n"
  end

  def create_html_ul_array_from_hash(data)
    ul_ele = ["<ul>"]

    data.each do |key, val|
      if val.is_a? Hash
        ul_ele << "<li>#{key}:-</li>"
        ul_ele += create_html_ul_array_from_hash(val)
      else
        ul_ele << "<li>#{key}: #{val}</li>"
      end
    end

    ul_ele << "</ul>"

    ul_ele
  end

  def create_html_ul_string_from_array(list)
    lvl = 4

    list.each_with_index do |item, index|
      lvl -= 2 if item == "</ul>"
      list[index] = "#{" "*lvl}#{item}"
      lvl += 2 if item == "<ul>"
    end

    list[0].strip! #Because the first will already be indented

    list.join("\n")
  end
end
