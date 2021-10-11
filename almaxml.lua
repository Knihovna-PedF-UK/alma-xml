local domobject = require "luaxml-domobject"

local M = {}

local function get_colummn_names(dom)
  -- get column names from XML schema which is included in ALMA XML
  local mapping = {} 
  local function find_xsd(root)
    for i, child in ipairs(root:get_children()) do
      -- xsd should be near the beginning
      if i > 10 then return nil end
      if child:is_element() then
        if child:get_element_name() == "xsd:schema" then return child end
        local xsd = find_xsd(child)
        if xsd then return xsd end
      end
    end
  end
  local xsd = find_xsd(dom:root_node())
  if not xsd then return nil, "Cannot find xsd" end
  for _, el in ipairs(xsd:query_selector("xsd|element")) do
    local column = el:get_attribute("name")
    local name = el:get_attribute("saw-sql:columnheading")
    mapping[column] = name
  end
  return mapping
end

local function load(xmltext)
  -- parse XML string to  DOM object
  return domobject.parse(xmltext)
end




M.load = load
M.get_colummn_names = get_colummn_names

return M
