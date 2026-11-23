return {
	categories = { "Features", "Changes", "Fixes", "Dependencies", "Internal" },
	collapsed = { "Dependencies", "Internal" },
	version = {
		current = "0.1.0",
		mirror = {
			{ file = "pkg.luau" },
			{ file = "README.md", pattern = 'target = "workspace/luau%-execution",%s+rev = "v([%d%.]+)"' },
			{ file = "README.md", pattern = 'require%("@lpm/luau%-execution@v([%d%.]+)"%)' },
		},
	},
}
