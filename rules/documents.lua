priority: 50
input_parameter: "request"
events_table: ["documents_requested"]

request.method == "GET"
and #request.path_segments == 0
and request.query.documents
