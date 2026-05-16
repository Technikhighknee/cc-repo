if not arg[1] then
    print("Usage: download <source> [destination]")
    return
end

local GITHUB_REPOSITORY_URL_BASE = "https://raw.githubusercontent.com/Technikhighknee/cc-repo/refs/heads/main/"
local source = arg[1]
local destination = arg[2] or string.match(source, "[^/]+$"); -- some_path/some_script.lua -> some_script.lua
local url = GITHUB_REPOSITORY_URL_BASE .. source

shell.execute("wget", url, destination)
