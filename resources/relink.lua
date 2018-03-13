function fix_local_links(link)
  if not string.find("://",link.target) then
    link.target = string.gsub(link.target,"%.md$",".html")
    link.target = string.gsub(link.target,"%.md#(.*)$",".html#%1")
  end
  return link
end

local first_header = true
local my_title = nil

function find_title(header)
  if first_header == true then
    if header.level == 1 then
      my_title = header.content
    end
    first_header = false
  end
  return header
end

function do_metadata(m)
  if m['title'] == nil and m['pagetitle'] == nil then
    m['pagetitle'] = my_title
  end
  return m
end

return {{Link = fix_local_links, Header = find_title},
        {Meta = do_metadata}}
