file = ARGV[0]
lines = File.readlines(file).map(&:strip).reject(&:empty?)
memory = {}
last_say = nil
last_var = nil
i = 0

def line_content(lines, ref)
  idx = ref.split.last.to_i - 1
  content = lines[idx]
  return "" unless content
  if content.start_with?("say ")
    content[4..].delete('"')
  elsif content.start_with?("imvar ")
    content[6..].delete('"')
  else
    content
  end
end

while i < lines.size
  line = lines[i]

  if line.start_with?("say ")
    last_say = line[4..].delete('"')

  elsif line.start_with?("imvar ")
    last_var = line[6..].delete('"')

  elsif line.start_with?("if ")
    cond = line.split(" ", 2).last
    next_line = lines[i + 1]&.strip

    if cond.start_with?("say line")
      puts line_content(lines, cond)
    elsif cond.start_with?("imvar line")
      puts line_content(lines, cond)
    elsif cond == "print"
      if next_line&.start_with?("func say line")
        puts line_content(lines, next_line.split(" ", 3).last)
      elsif next_line&.start_with?("func imvar line")
        puts line_content(lines, next_line.split(" ", 3).last)
      elsif next_line&.start_with?("func loop")
        i = -1
      elsif next_line&.start_with?("func stop")
        Process.exit!(0)
      elsif next_line&.start_with?("func in")
        delay_expr = next_line[7..].gsub("second","").strip
        sleep(eval(delay_expr))
      end
    elsif cond.start_with?("in ")
      if next_line&.start_with?("func loop")
        delay_expr = cond.gsub("in","").gsub("second","").strip
        sleep(eval(delay_expr))
        i = -1
      elsif next_line&.start_with?("func stop")
        delay_expr = cond.gsub("in","").gsub("second","").strip
        sleep(eval(delay_expr))
        Process.exit!(0)
      end
    end
  end

  i += 1
end
