local net = require("@std/net")
local process = require("@std/process")

-- GitHub's API rejects requests without a User-Agent.
local HEADERS = {
	["User-Agent"] = "flipbook-labs-open-cloud",
	Accept = "application/vnd.github+json",
}

-- Fetches `url` and returns its body, exiting the script on any status but
-- 200 so a failed download never writes a partial file.
local function fetch(url: string): string
	local response = net.request(url, { headers = HEADERS })
	if response.status ~= 200 then
		print(`[err] {response.status} from {url}`)
		process.exit(1)
	end
	return response.body
end

return fetch
