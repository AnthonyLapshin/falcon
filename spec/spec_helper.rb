
require "bundler/setup"
Bundler.require(:test)

require "falcon"

require "async/rspec"
require "async/http/url_endpoint"

RSpec.shared_context Falcon::Server do
	include_context Async::RSpec::Reactor
	
	let(:protocol) {Async::HTTP::Protocol::HTTP1}
	let(:endpoint) {Async::HTTP::URLEndpoint.parse('http://127.0.0.1:9294', reuse_port: true)}
	let!(:client) {Async::HTTP::Client.new(endpoint, protocol)}
	
	let!(:server_task) do
		server_task = reactor.async do
			server.run
		end
	end
	
	after(:each) do
		server_task.stop
		client.close
	end
	
	let(:app) do
		lambda do |env|
			[200, {}, []]
		end
	end
	
	let(:server) do
		Falcon::Server.new(
			Falcon::Adapters::Rewindable.new(
				Falcon::Adapters::Rack.new(app)
			),
			endpoint, protocol
		)
	end
end

RSpec.configure do |config|
	# Enable flags like --only-failures and --next-failure
	config.example_status_persistence_file_path = ".rspec_status"

	# Disable RSpec exposing methods globally on `Module` and `main`
	config.disable_monkey_patching!

	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end
