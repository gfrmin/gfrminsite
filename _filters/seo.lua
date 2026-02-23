-- SEO Lua filter for Quarto
-- Injects server-side JSON-LD structured data and canonical links

local site_url = "https://gfrm.in"

function Meta(meta)
  -- Determine page URL from quarto.doc.output_file
  local page_url = site_url .. "/"
  if quarto and quarto.doc and quarto.doc.output_file then
    local output_file = quarto.doc.output_file
    -- Strip the project output directory prefix to get the relative path
    local rel_path = output_file:match("/public/(.+)$")
    if rel_path then
      page_url = site_url .. "/" .. rel_path
    end
  end

  -- Extract metadata
  local title = ""
  if meta.title then
    title = pandoc.utils.stringify(meta.title)
  end

  local description = ""
  if meta.description then
    description = pandoc.utils.stringify(meta.description)
  end

  local date_published = ""
  if meta.date then
    date_published = pandoc.utils.stringify(meta.date)
  end

  local date_modified = date_published
  if meta["date-modified"] then
    date_modified = pandoc.utils.stringify(meta["date-modified"])
  end

  local image = ""
  if meta.image then
    image = pandoc.utils.stringify(meta.image)
  end

  if not meta["header-includes"] then
    meta["header-includes"] = pandoc.MetaList({})
  end

  -- Canonical link (all pages)
  local canonical_tag = pandoc.RawBlock('html',
    '<link rel="canonical" href="' .. page_url .. '">')
  meta["header-includes"]:insert(pandoc.MetaBlocks({canonical_tag}))

  -- Determine if this is a blog post (has date and categories)
  local is_post = meta.date ~= nil and meta.categories ~= nil

  if is_post and title ~= "" then
    -- Build image URL
    local image_url = ""
    if image ~= "" then
      if not image:match("^https?://") then
        local dir = page_url:match("(.*/)")
        if dir then
          image_url = dir .. image
        end
      else
        image_url = image
      end
    end

    -- BlogPosting JSON-LD
    local schema = '{\n'
    schema = schema .. '  "@context": "https://schema.org",\n'
    schema = schema .. '  "@type": "BlogPosting",\n'
    schema = schema .. '  "headline": ' .. json_encode(title) .. ',\n'
    schema = schema .. '  "description": ' .. json_encode(description) .. ',\n'
    schema = schema .. '  "url": ' .. json_encode(page_url) .. ',\n'
    schema = schema .. '  "datePublished": ' .. json_encode(date_published) .. ',\n'
    schema = schema .. '  "dateModified": ' .. json_encode(date_modified) .. ',\n'
    schema = schema .. '  "inLanguage": "en",\n'
    if image_url ~= "" then
      schema = schema .. '  "image": ' .. json_encode(image_url) .. ',\n'
    end
    schema = schema .. '  "author": {\n'
    schema = schema .. '    "@type": "Person",\n'
    schema = schema .. '    "name": "Guy Freeman",\n'
    schema = schema .. '    "url": "https://www.gfrm.in",\n'
    schema = schema .. '    "jobTitle": "Data Systems Architect",\n'
    schema = schema .. '    "sameAs": [\n'
    schema = schema .. '      "https://github.com/gfrmin",\n'
    schema = schema .. '      "https://linkedin.com/in/guyfreemanstat",\n'
    schema = schema .. '      "https://twitter.com/gfrm_in",\n'
    schema = schema .. '      "https://defcon.social/@gfrmin",\n'
    schema = schema .. '      "https://scholar.google.com/citations?user=H422hdkAAAAJ"\n'
    schema = schema .. '    ]\n'
    schema = schema .. '  },\n'
    schema = schema .. '  "publisher": {\n'
    schema = schema .. '    "@type": "Person",\n'
    schema = schema .. '    "name": "Guy Freeman",\n'
    schema = schema .. '    "url": "https://www.gfrm.in"\n'
    schema = schema .. '  },\n'
    schema = schema .. '  "mainEntityOfPage": {\n'
    schema = schema .. '    "@type": "WebPage",\n'
    schema = schema .. '    "@id": ' .. json_encode(page_url) .. '\n'
    schema = schema .. '  }\n'
    schema = schema .. '}'

    local jsonld_block = pandoc.RawBlock('html',
      '<script type="application/ld+json">\n' .. schema .. '\n</script>')
    meta["header-includes"]:insert(pandoc.MetaBlocks({jsonld_block}))
  end

  return meta
end

-- Simple JSON string encoding
function json_encode(s)
  if s == nil or s == "" then return '""' end
  s = s:gsub('\\', '\\\\')
  s = s:gsub('"', '\\"')
  s = s:gsub('\n', '\\n')
  s = s:gsub('\r', '\\r')
  s = s:gsub('\t', '\\t')
  return '"' .. s .. '"'
end
