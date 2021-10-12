# Process ALMA XML

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
        

