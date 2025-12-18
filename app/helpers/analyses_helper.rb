module AnalysesHelper
  # Format the markdown-style recommendations with better HTML structure
  def format_recommendations(text)
    return "" if text.blank?
    
    # Ensure text is a string
    text = text.to_s
    
    # Split into lines and process
    lines = text.split("\n")
    html_parts = []
    i = 0
    
    while i < lines.length
      line = lines[i]
      next if line.nil?
      
      stripped_line = line.strip
      
      # Headers
      if (match = stripped_line.match(/^####\s+(.+)$/))
        html_parts << "<h4 class=\"text-xl font-bold text-gray-900 mt-8 mb-4\">#{match[1]}</h4>"
      elsif (match = stripped_line.match(/^###\s+(.+)$/))
        html_parts << "<h3 class=\"text-2xl font-bold text-gray-900 mt-10 mb-6 border-b border-gray-200 pb-2\">#{match[1]}</h3>"
      elsif (match = stripped_line.match(/^##\s+(.+)$/))
        html_parts << "<h2 class=\"text-3xl font-bold text-gray-900 mt-12 mb-8\">#{match[1]}</h2>"
      # Numbered lists
      elsif (match = stripped_line.match(/^(\d+)\.\s+(.+)$/))
        num = match[1]
        content = (match[2] || "").strip
        # Continue reading until next list item or blank line
        while i + 1 < lines.length && lines[i + 1] && !lines[i + 1].strip.match?(/^\d+\.\s/) && lines[i + 1].strip.present?
          i += 1
          next_line = lines[i]&.strip || ""
          content += " " + next_line if next_line.present?
        end
        if content.present?
          html_parts << "<div class=\"flex items-start space-x-3 my-3\"><span class=\"flex-shrink-0 w-8 h-8 bg-green-100 text-green-700 rounded-full flex items-center justify-center font-semibold text-sm\">#{num}</span><div class=\"flex-1 text-gray-700 leading-relaxed\">#{format_inline_content(content)}</div></div>"
        end
      # Bullet lists
      elsif (match = stripped_line.match(/^[-*]\s+(.+)$/))
        content = (match[1] || "").strip
        # Continue reading until next list item or blank line
        while i + 1 < lines.length && lines[i + 1] && !lines[i + 1].strip.match?(/^[-*]\s/) && lines[i + 1].strip.present?
          i += 1
          next_line = lines[i]&.strip || ""
          content += " " + next_line if next_line.present?
        end
        if content.present?
          html_parts << "<div class=\"flex items-start space-x-3 my-2\"><span class=\"text-green-600 mt-1\">•</span><span class=\"flex-1 text-gray-700\">#{format_inline_content(content)}</span></div>"
        end
      # Regular paragraphs (not empty, not headers, not lists)
      elsif stripped_line.present?
        html_parts << "<p class=\"text-gray-700 leading-relaxed mb-4\">#{format_inline_content(stripped_line)}</p>"
      end
      
      i += 1
    end
    
    html_parts.join("\n")
  end
  
  private
  
  def format_inline_content(content)
    return "" if content.blank?
    
    content.to_s.gsub(/\*\*(.+?)\*\*/, '<strong class="font-semibold text-gray-900">\1</strong>')
           .gsub(/\*(.+?)\*/, '<em class="italic">\1</em>')
           .gsub(/`(.+?)`/, '<code class="bg-gray-100 px-1.5 py-0.5 rounded text-sm font-mono">\1</code>')
  end
  
  # Format AI answers to be simpler and more readable
  def format_answer(text)
    return "" if text.blank?
    
    text = text.to_s
    
    # Split into paragraphs
    paragraphs = text.split(/\n\n+/)
    
    html_parts = []
    
    paragraphs.each do |para|
      para = para.strip
      next if para.blank?
      
      # Check for conclusion section
      if para.match?(/^###?\s*Conclusion/i)
        html_parts << '<div class="mt-4 p-4 bg-green-100 rounded-lg border-l-4 border-green-500">'
        html_parts << '<p class="font-semibold text-green-900 mb-2">💡 Answer:</p>'
        content = para.sub(/^###?\s*Conclusion:?\s*/i, '').strip
        html_parts << "<p class='text-gray-800 font-medium'>#{format_inline_content(content)}</p>"
        html_parts << '</div>'
        next
      end
      
      # Check for insights/actionable insights section
      if para.match?(/^###?\s*Actionable Insights/i) || para.match?(/^###?\s*Insights/i)
        html_parts << '<div class="mt-4 p-4 bg-blue-50 rounded-lg border-l-4 border-blue-400">'
        html_parts << '<p class="font-semibold text-blue-900 mb-3">💡 Key Insights:</p>'
        content = para.sub(/^###?\s*(Actionable )?Insights:?\s*/i, '').strip
        html_parts << format_simple_text(content)
        html_parts << '</div>'
        next
      end
      
      # Skip detailed calculation sections
      next if para.match?(/^###?\s*(Total Revenue Calculation|Average Revenue Per Service Calculation)/i)
      
      # Format headers
      if para.match?(/^###\s+(.+)$/)
        html_parts << "<p class='font-semibold text-gray-900 mt-4 mb-2 text-lg'>#{$1}</p>"
        next
      end
      
      if para.match?(/^##\s+(.+)$/)
        html_parts << "<p class='font-bold text-gray-900 mt-5 mb-3 text-xl'>#{$1}</p>"
        next
      end
      
      # Format lists
      if para.match?(/^[-*]\s+/)
        lines = para.split("\n")
        list_items = lines.select { |l| l.match?(/^[-*]\s+/) }
        if list_items.any?
          html_parts << '<ul class="space-y-2 my-3">'
          list_items.each do |item|
            content = item.sub(/^[-*]\s+/, '').strip
            html_parts << "<li class='flex items-start'><span class='text-green-600 mr-2 mt-1'>•</span><span class='text-gray-700'>#{format_inline_content(content)}</span></li>"
          end
          html_parts << '</ul>'
          next
        end
      end
      
      # Format numbered lists
      if para.match?(/^\d+\.\s+/)
        lines = para.split("\n")
        list_items = lines.select { |l| l.match?(/^\d+\.\s+/) }
        if list_items.any?
          html_parts << '<ol class="space-y-2 my-3 list-decimal list-inside">'
          list_items.each do |item|
            content = item.sub(/^\d+\.\s+/, '').strip
            html_parts << "<li class='text-gray-700'>#{format_inline_content(content)}</li>"
          end
          html_parts << '</ol>'
          next
        end
      end
      
      # Regular paragraph
      formatted = format_inline_content(para)
      # Highlight dollar amounts and percentages
      formatted = formatted.gsub(/\$[\d,]+\.?\d*/) do |amount|
        "<span class='font-semibold text-green-700 bg-green-100 px-2 py-0.5 rounded inline-block'>#{amount}</span>"
      end
      formatted = formatted.gsub(/\d+\.?\d*%/) do |percent|
        "<span class='font-semibold text-blue-700 bg-blue-100 px-2 py-0.5 rounded inline-block'>#{percent}</span>"
      end
      html_parts << "<p class='text-gray-700 leading-relaxed mb-3'>#{formatted}</p>"
    end
    
    html_parts.join("\n")
  end
  
  def format_simple_text(text)
    # Convert lines to paragraphs or lists
    lines = text.split("\n")
    html_parts = []
    
    lines.each do |line|
      line = line.strip
      next if line.blank?
      
      if line.match?(/^[-*]\s+/)
        content = line.sub(/^[-*]\s+/, '')
        html_parts << "<div class='flex items-start my-2'><span class='text-green-600 mr-2 mt-1'>•</span><span class='text-gray-700'>#{format_inline_content(content)}</span></div>"
      elsif line.match?(/^\d+\.\s+/)
        content = line.sub(/^\d+\.\s+/, '')
        html_parts << "<div class='my-2 text-gray-700'><span class='font-semibold text-gray-900'>#{content.split(':').first}:</span> #{format_inline_content(content.split(':', 2).last)}</div>"
      else
        html_parts << "<p class='text-gray-700 mb-2'>#{format_inline_content(line)}</p>"
      end
    end
    
    html_parts.join("\n")
  end
end
