# Process ALMA XML

## SAX method

Example:

    kpse.set_program_name "luatex"
    
    local readalma = require "almaxml-sax"
    
    local filename = arg[1]
    
    local mapping = {
      C1 = "signatura",
      C2 = "ck",
      C9 = "sysno",
      C10 = "autor",
      C11 = "nazev",
      C0 = "umisteni",
      C13 = "proces"
    }
    
    cbe = {}
    others = {}
    
    local function table_copy(t)
      local new = {}
      for k,v in pairs(t) do new[k] = v end
      return new
    end
    
    function callback(record)
      local signatura = record.signatura or ""
      local prefix = signatura:match("^([0-9]?[a-zA-Z%-]+)")
      if prefix:match("C%-") then
        table.insert(cbe, table_copy(record))
      else
        local sysno = record.sysno
        local r = others[sysno] or {cel=0, ret=0}
        if record.umisteni == "Celetná - study room" then
          r.cel = r.cel + 1
        else
          r.ret = r.ret + 1
        end
        others[sysno] = r
      end
    end
    
    local records = readalma.load(filename, callback, mapping)


## DOM method (more memory intensive)

Example: 

    local input_text = io.read("*all")
    local dom = almaxml.load(input_text)
    local column_names = almaxml.get_colummn_names(dom)
    
    -- we can remap Alma field names to desired names in the output table
    -- this is optional 
    local remap = {
      Author = "autor", 
      Title = "nazev", 
      Publisher = "vydavatel", 
      ["Publication Date"] = "rok", 
      ["Item Call Number"] = "signatura",
      Barcode = "ck"
    }
    
    -- remap is optional. pass nil to keep original column names from Alma
    local records = almaxml.process(dom, column_names, remap)
        

