local GITHUB_REPOSITORY_URL_BASE = "https://raw.githubusercontent.com/Technikhighknee/cc-repo/refs/heads/main/"

local path = arg[1]
local file_name = arg[2] or string.match(path, "[^/]+$"); -- some_path/some_script.lua -> some_script.lua

if not file_name then
    print("Usage: download <path> [file_name]")
    return
end

os.execute("wget " .. GITHUB_REPOSITORY_URL_BASE .. path .. " " .. file_name)
