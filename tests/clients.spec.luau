local test = require("@std/test")

local OpenApiRuntime = require("@lpm/openapi-runtime@v0.1.0")

local Assets = require("../workspace/assets")
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
				local fields = value :: { script: string?, displayName: string? }
				if fields.displayName then
					return `\{"displayName":"{fields.displayName}"}`
				end
				return `\{"script":"{fields.script}"}`
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

	suite:case("assets uploads a file and its attributes as multipart fields", function(assert)
		local client, requests = createRecordingClient('{"path":"operations/1"}')

		local operation = Assets.createAsset(client, {
			body = {
				fileContent = {
					filename = "sword.rbxm",
					contentType = "model/x-rbxm",
					content = "BINARY",
				},
				request = {
					displayName = "Sword",
				},
			},
		})

		local request = requests[1]
		assert.eq(request.method, "POST")
		assert.eq(request.url, "https://apis.roblox.com/assets/v1/assets")
		local boundary = request.headers["Content-Type"]:match("^multipart/form%-data; boundary=(.+)$")
		assert.neq(boundary, nil)
		local body = request.body :: string
		assert.neq(
			body:find('name="fileContent"; filename="sword.rbxm"\r\nContent-Type: model/x-rbxm\r\n\r\nBINARY', 1, true),
			nil
		)
		assert.neq(
			body:find('name="request"\r\nContent-Type: application/json\r\n\r\n{"displayName":"Sword"}', 1, true),
			nil
		)
		assert.eq(body:find('name="additionalParameters"', 1, true), nil)
		assert.eq(operation.path, "operations/1")
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
