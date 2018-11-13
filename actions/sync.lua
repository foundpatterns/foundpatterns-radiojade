event: ["sync_requested"]
priority: 50
input_parameters: ["request"]

local last_sync_date
local last_sync_id

local model_name = request.query.sync or "message"
-- Find the date of the most recent sync
content.walk_documents("home", function (file_uuid, fields, body)

  if fields.model == "sync" then
    local sync_date = time.new(fields.creation_time)

    if not last_sync_date
    or sync_date > last_sync_date
    then
      last_sync_date = sync_date
      last_sync_id = file_uuid
    end
  end
end)

local uuids = {}

-- Finds all messages more recent than the most recent sync
content.walk_documents(nil, function (file_uuid, fields, body)

  if fields.model == model_name then
    if not fields.creation_time then return end
    local msg_date = time.new(fields.creation_time)
    if not last_sync_date
    or msg_date >= last_sync_date
    then
      table.insert(uuids, file_uuid)
    end
  end
end)

-- TODO: Send the documents to foundpatterns

local data = { model = "sync", documents = uuids }
if last_sync_id then
  data.previous_sync = last_sync_id
end

local sync_id = uuid.v4()
content.write_file("home", sync_id, data)

data.uuid = sync_id

return {
  headers = {
    ["content-type"] = "application/json",
  },
  body = json.from_table(data)
}