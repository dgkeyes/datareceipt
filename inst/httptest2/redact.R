# Applied to every response httptest2 records, so the fixtures never carry a
# real share token (the 40 character string in a request's share URL).
function(resp) {
  httptest2::gsub_response(resp, "/r/[A-Za-z0-9]{40}", "/r/SHARETOKENREDACTED")
}
