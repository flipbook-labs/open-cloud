-- The workspace releases every member at one version, kept in the root
-- manifest.
local root = require("../../pkg")

return {
	package = {
		name = "luau-execution",
		version = root.version,
		files = {
			"/init.luau",
			"/types.luau",
			"/README.md",
		},
		dependencies = {
			["openapi-runtime"] = {
				rev = "v0.1.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/openapi-luau",
				target = "workspace/openapi-runtime",
			},
		},
	},
}
