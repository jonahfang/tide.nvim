local M = {}

M.get_data_path = function()
  return vim.fn.stdpath("data") .. "/tide"
end

-- Finds the root directory of a project by looking for common project indicators
M.find_project_root = function()
  -- List of common project markers
  local markers = { ".git", "Makefile", "package.json", ".hg", ".svn", "Cargo.toml", "pyproject.toml", "go.mod" }

  -- Use vim's findfile to look for one of these markers in the current directory and upwards
  for _, marker in ipairs(markers) do
    local project_dir = vim.fn.findfile(marker, ".;")
    if project_dir == "" then
      project_dir = vim.fn.finddir(marker, ".;")
    end

    -- If a marker is found, return the absolute path to the parent directory (project root)
    if project_dir ~= "" then
      return vim.fn.fnamemodify(project_dir, ":p:h:h")
    end
  end

  -- If no markers are found, return nil
  return nil
end

M.make_safe_filename = function(project_root)
  if not project_root then
    return nil
  end

  local safe_path = project_root:gsub("[^%w%s]", "_") -- Replace special characters with underscores
  safe_path = safe_path:gsub("%s", "_") -- Replace spaces with underscores
  return safe_path
end

M.get_icon = function(filename)
  local ext = string.match(filename, "%.(%a+)$")
  local icon, _ = require("nvim-web-devicons").get_icon_color(filename, ext)
  return icon
end

-- Utility function to generate unique names based on file paths
M.generate_unique_names = function(file_paths)
  local name_map = {}
  local result = {}

  -- Step 1: Extract filenames and populate the map
  for _, path in ipairs(file_paths) do
    local filename = vim.fn.fnamemodify(path, ":t") -- Get the filename (tail part)
    if not name_map[filename] then
      name_map[filename] = { count = 1, paths = { path } }
    else
      name_map[filename].count = name_map[filename].count + 1
      table.insert(name_map[filename].paths, path)
    end
  end

  -- Step 2
  for filename, data in pairs(name_map) do
      for _, path in ipairs(data.paths) do
        local parent = vim.fn.fnamemodify(path, ":h:t") -- Get the parent directory (tail part)
        result[path] = parent .. "/" .. filename
      end
  end

  return result
end

return M
