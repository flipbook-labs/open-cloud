local fs = require("@std/fs")
local json = require("@std/json")

local fetch = require("./lib/fetch")
local spec = require("./lib/spec")

--[[
	Pins the clients to the newest Open Cloud spec by writing the creator-docs
	commit that last changed it into `spec/source.luau`. `lute run generate`
	downloads the spec at that commit, so the pin is all the repository keeps.
]]
local commits = json.deserialize(
	fetch(`https://api.github.com/repos/{spec.repository}/commits?path={spec.path}&per_page=1`)
) :: { { sha: string } }
local commit = commits[1].sha

fs.writeStringToFile(
	"spec/source.luau",
	table.concat({
		"-- Written by `lute run update-spec`. The clients are generated from Roblox's",
		`-- Open Cloud spec at this commit of {spec.repository}.`,
		"return {",
		`\tcommit = "{commit}",`,
		"}",
		"",
	}, "\n")
)
print(`Pinned the spec to {spec.repository}@{commit}`)
