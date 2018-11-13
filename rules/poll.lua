priority: 50
input_parameter: "request"
events_table: ["poll_requested"]

request.method == "GET"
and #request.path_segments == 0
and request.query.poll
