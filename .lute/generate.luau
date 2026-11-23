local run = require("./lib/run")

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

--[[
	Regenerates every member's `init.luau` and `types.luau` from the spec
	snapshot in `spec/openapi.json`. The generator only writes those two
	files, so each member's `pkg.luau` and README stay as they are.
]]
for _, member in MEMBERS do
	run({
		"openapi-luau",
		"spec/openapi.json",
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
