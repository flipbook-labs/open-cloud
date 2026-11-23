local fs = require("@std/fs")
local json = require("@std/json")
local net = require("@std/net")
local process = require("@std/process")

local REPOSITORY = "Roblox/creator-docs"
local SPEC_PATH = "content/en-us/reference/cloud/openapi.json"

-- GitHub's API rejects requests without a User-Agent.
local HEADERS = {
	["User-Agent"] = "flipbook-labs-open-cloud",
	Accept = "application/vnd.github+json",
}

local function fetch(url: string): string
	local response = net.request(url, { headers = HEADERS })
	if response.status ~= 200 then
		print(`[err] {response.status} from {url}`)
		process.exit(1)
	end
	return response.body
end

--[[
	Copies the newest Open Cloud spec from Roblox's creator-docs repository into
	`spec/openapi.json`, and records the commit it came from in
	`spec/source.luau`. Both are pinned to that commit, so running this twice
	against the same upstream state writes the same files, and a later
	`lute run generate` works from the snapshot without the network.
]]
local commits =
	json.deserialize(fetch(`https://api.github.com/repos/{REPOSITORY}/commits?path={SPEC_PATH}&per_page=1`)) :: { { sha: string } }
local commit = commits[1].sha

fs.writeStringToFile("spec/openapi.json", fetch(`https://raw.githubusercontent.com/{REPOSITORY}/{commit}/{SPEC_PATH}`))
fs.writeStringToFile(
	"spec/source.luau",
	table.concat({
		"-- Written by `lute run update-spec`. `openapi.json` is a copy of Roblox's",
		`-- Open Cloud spec from this commit of {REPOSITORY}.`,
		"return {",
		`\tcommit = "{commit}",`,
		"}",
		"",
	}, "\n")
)
print(`Copied the spec from {REPOSITORY}@{commit}`)
