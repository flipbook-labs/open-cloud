local fs = require("@std/fs")

local source = require("@repo/spec/source")

local fetch = require("./lib/fetch")
local run = require("./lib/run")
local spec = require("./lib/spec")

-- The members this repository publishes. Each maps a workspace folder, named
-- after the service's slug in Roblox's docs, to the tag Roblox's spec groups
-- that service's operations under.
local MEMBERS = {
	{ folder = "assets", tag = "Assets" },
	{ folder = "luau-execution", tag = "Luau Execution" },
	{ folder = "places", tag = "Places" },
}

-- Generated clients require openapi-runtime by the folder `lute run install`
-- vendors it into. Each member's `pkg.luau` pins the same version.
local RUNTIME_REQUIRE = "@lpm/openapi-runtime@v0.1.0"

-- The spec is downloaded here rather than committed. `/build/` is gitignored.
local SPEC_FILE = "build/openapi.json"

--[[
	Regenerates every member's `init.luau` and `types.luau` from Roblox's spec
	at the commit `spec/source.luau` pins. The download comes from that exact
	commit, so the same pin always generates the same clients. The generator
	only writes those two files, so each member's `pkg.luau` stays as it is.
]]
fs.createDirectory("build", { makeParents = true })
fs.writeStringToFile(
	SPEC_FILE,
	fetch(`https://raw.githubusercontent.com/{spec.repository}/{source.commit}/{spec.path}`)
)

for _, member in MEMBERS do
	run({
		"openapi-luau",
		SPEC_FILE,
		"--tag",
		member.tag,
		"--out",
		`workspace/{member.folder}`,
		"--runtime",
		RUNTIME_REQUIRE,
	})
end

-- StyLua formats the output so a regeneration's diff only shows what the spec
-- changed.
run({ "stylua", "workspace" })
