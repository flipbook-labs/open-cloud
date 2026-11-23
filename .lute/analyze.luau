local run = require("./lib/run")

run({
	"luau-lsp",
	"analyze",
	"--settings=./.vscode/settings.json",
	".lute",
	"tests",
	"workspace",
	"spec/source.luau",
})
