local CodeQuality = require("@lpm/code-quality@v0.8.0")
local process = require("@std/process")

local run = require("./lib/run")

-- Generated clients are left out of `CodeQuality.lint`, since their field
-- names and enums come from Roblox's spec. StyLua still checks them, because
-- `lute run generate` formats them before they're committed.
local LINTED_PATHS = {
	".lute",
	"tests",
	"pkg.luau",
	"workspace/assets/pkg.luau",
	"workspace/luau-execution/pkg.luau",
	"workspace/places/pkg.luau",
}

CodeQuality.lint(LINTED_PATHS)
run({
	"stylua",
	"--check",
	".lute",
	"tests",
	"pkg.luau",
	"workspace",
	"spec/source.luau",
})

-- Luau files use the `.luau` extension. Asking git covers every tracked and
-- untracked file while skipping what `.gitignore` excludes, like `.lpm/`.
local result = process.run({
	"git",
	"ls-files",
	"--cached",
	"--others",
	"--exclude-standard",
	"*.lua",
})
if not result.ok then
	print(`[err] git ls-files failed: {result.stderr}`)
	process.exit(1)
end

if result.stdout ~= "" then
	print("[err] rename these files from '.lua' to '.luau':")
	print(result.stdout)
	process.exit(1)
end
