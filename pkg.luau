--[[
	This repository is a Lute package workspace. The manifest's `package` has no
	name or version, so Lute treats it as the workspace's virtual root, which
	only groups packages and can't be installed itself. Each path dependency is
	a member: one Open Cloud service's generated client in its own
	`workspace/<name>` folder, named after the service's slug in Roblox's docs.
	`lute run install` vendors every member's dependencies into this folder's
	`.lpm/`, so the `.lute` scripts can require them too.

	The members release together at one version, the top-level `version` below.
	Each member's manifest requires this file and reads it from there, and
	Changewrite moves it forward at each release. It sits outside `package`
	because Lute only accepts a version there alongside a name.
]]
return {
	version = "0.2.0",
	package = {
		dependencies = {
			assets = {
				sourceKind = "path",
				source = "./workspace/assets",
			},
			["luau-execution"] = {
				sourceKind = "path",
				source = "./workspace/luau-execution",
			},
			places = {
				sourceKind = "path",
				source = "./workspace/places",
			},
		},
		dev_dependencies = {
			["agent-skills"] = {
				rev = "v0.9.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/agent-skills",
			},
			["code-quality"] = {
				rev = "v0.8.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/code-quality",
			},
		},
	},
}
