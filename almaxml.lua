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
  -- loop over xsd elements and get column name and it's title
  for _, el in ipairs(xsd:query_selector("xsd|element")) do
    local column = el:get_attribute("name")
    local name = el:get_attribute("saw-sql:columnheading")
    mapping[column] = name
  end
  return mapping
end

local function get_remap_table(mapping, remap)
  -- map is C1 -> Alma name 
  -- remap is Alma name -> newname
  if not remap then return nil end
  local newmap = {}
  for column, name in pairs(mapping) do
    local newname = remap[name]
    if newname then
      newmap[column] = newname
    end
  end
end

--- Process DOM and get table with records
-- mapping: mapping between XML record numbers and field names (from get_column_names function)
-- remap: table with field names that should be saved in the resulting table. Optional.
local function process(dom, mapping, remap)
  local records = {}
  local remap_map = get_remap_table(mapping, remap)
  for _, el in ipairs(dom:query_selector("R")) do
    local rec = {}
    for _, child in ipairs(el:get_children()) do
      if child:is_element() then
        local name = child:get_element_name()
        if remap_map then 
          local newname = remap_map[name]
          if newname then
            rec[newname] = child:get_text()
          end
        else
          local newname = mapping[name]
          rec[newname] = child:get_text()
        end
      end
    end
    records[#records+1] = rec
  end
  return records
end

local function load(xmltext)
  -- parse XML string to  DOM object
  return domobject.parse(xmltext)
end




M.load = load
M.get_colummn_names = get_colummn_names
M.get_remap_table = get_remap_table
M.process = process

return M
