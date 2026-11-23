local test = require("@std/test")

local OpenApiRuntime = require("@lpm/openapi-runtime@v0.1.0")

local LuauExecution = require("../workspace/luau-execution")
local Places = require("../workspace/places")

type HttpRequest = OpenApiRuntime.HttpRequest

--[[
	Builds a client whose transport records each request and answers with
	`body`. JSON goes through stand-ins that only handle what these tests send
	and receive, so the specs check the generated request shapes rather than a
	platform's JSON encoder.
]]
local function createRecordingClient(body: string): (OpenApiRuntime.Client, { HttpRequest })
	local requests: { HttpRequest } = {}
	local client = OpenApiRuntime.createClient({
		baseUrl = "https://apis.roblox.com",
		headers = {
			["x-api-key"] = "test-key",
		},
		transport = {
			request = function(request)
				table.insert(requests, request)
				return {
					status = 200,
					headers = {},
					body = body,
				}
			end,
			encodeJson = function(value)
				local task = value :: { script: string }
				return `\{"script":"{task.script}"}`
			end,
			decodeJson = function(text)
				return {
					path = text:match('"path":"([^"]+)"'),
				}
			end,
		},
	})
	return client, requests
end

test.suite("generated clients", function(suite)
	suite:case("luau-execution creates a task under a universe and place", function(assert)
		local client, requests =
			createRecordingClient('{"path":"universes/1/places/2/luau-execution-sessions/x/tasks/y"}')

		local task = LuauExecution.createLuauExecutionSessionTaskUsingUniverses(client, {
			universe_id = "1",
			place_id = "2",
			body = {
				script = "return 1",
			},
		})

		assert.eq(requests[1].method, "POST")
		assert.eq(requests[1].url, "https://apis.roblox.com/cloud/v2/universes/1/places/2/luau-execution-session-tasks")
		assert.eq(requests[1].headers["x-api-key"], "test-key")
		assert.eq(requests[1].body, '{"script":"return 1"}')
		assert.eq(task.path, "universes/1/places/2/luau-execution-sessions/x/tasks/y")
	end)

	suite:case("places reads a place by its universe and place IDs", function(assert)
		local client, requests = createRecordingClient('{"path":"universes/1/places/2"}')

		local place = Places.getPlace(client, {
			universeId = "1",
			placeId = "2",
		})

		assert.eq(requests[1].method, "GET")
		assert.eq(requests[1].url, "https://apis.roblox.com/cloud/v2/universes/1/places/2")
		assert.eq(place.path, "universes/1/places/2")
	end)
end)
