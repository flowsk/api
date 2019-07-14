require "../spec_helper"

class CustomEndpoint
  include Gateway::Endpoint

  def call(context, params, operation)
    ctx = {} of String => String
    res = operation.run(params)
    context.response.print "Custom Endpoint: #{res}"
    context
  end
end

class MockServer < Gateway::Handler
  def routes
    get "/", Root
    get "/params/:id/test/:test_id", ParamsShow
    post "/posts", PostCreate
    post "/type_checking", TypeChecking
  end

  def endpoint
    CustomEndpoint.new
  end
end

class Root
  include Gateway::Operation

  def run(params)
    "index"
  end
end

class ParamsShow
  include Gateway::Operation

  def run(params)
    "params:#{params["id"]}|test:#{params["test_id"]}"
  end
end

class PostCreate
  include Gateway::Operation

  def run(params)
    "post_created:#{params["title"]}"
  end
end

class TypeChecking
  include Gateway::Operation

  def run(params)
    "title:#{params["title"].class}|count:#{params["count"].class}"
  end
end

include CurlHelper(MockServer)
include HandlerTester(MockServer)

describe "Gateway::Handler" do
  it "matches the index" do
    response = get("/", headers)
    response.status_code.should eq(200)
    response.body.should eq("Custom Endpoint: index")
  end

  it "matches the right route" do
    response = get("/params/1/test/3")
    response.status_code.should eq(200)
    response.body.should eq("Custom Endpoint: params:1|test:3")
  end

  it "matches the POST route" do
    response = post("/posts", params: {title: "New Title"})
    response.status_code.should eq(200)
    response.body.should eq("Custom Endpoint: post_created:New Title")
  end

  it "returns not found" do
    response = get("/unknown_route")
    response.status_code.should eq(404)
    response.body.should eq("Not Found\n")
  end

  it "tests post params" do
    curl("POST", "/posts", json: {title: "Title"}.to_json).body.should eq("Custom Endpoint: post_created:Title")
  end

  it "parses different types" do
    curl("POST", "/type_checking", json: {title: "Title", count: 2}.to_json).body.should eq("Custom Endpoint: title:String|count:Int64")
  end
end
