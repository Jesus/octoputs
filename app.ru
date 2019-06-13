app = lambda do |env|
  # A standard web application could run in about 200ms, the following line
  # adds a delay so the runtime looks more realistic.
  sleep 0.2

  [
    200,
    { 'Content-Type' => 'text/plain' },
    "This is a cool Rack application\n"
  ]
end

run app
