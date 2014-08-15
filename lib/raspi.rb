#!/usr/bin/env ruby
require "rubygems"
require "bunny"
require "thread"

#conn	= Bunny.new(:host => "54.191.172.249",
#				   :port => "5672",
#				   :user => "guest",
#				   :password => "guest",
#				   :automatically_recover => false)
#conn.start

#ch		= conn.create_channel
class Raspi
	attr_reader		:reply_queue
	attr_accessor	:response, :call_id, :file
	attr_reader		:lock, :condition

	def initialize(ch, server_queue)
		@ch				= ch
		@x				= ch.default_exchange

		@server_queue	= server_queue
		@reply_queue	= ch.queue("", :exclusive => true)

		@lock			= Mutex.new
		@condition		= ConditionVariable.new
		that			= self

		@reply_queue.subscribe do |delivery_info, properties, payload|
			if properties[:correlation_id] == that.call_id
				that.response = payload
				filename = properties[:headers].to_s
				puts "cF:: "+filename
				self.file = filename
				that.lock.synchronize(that.condition.signal)
			end			
		end 
	end

	def call(n)
		self.call_id = self.generate_uuid

		@x.publish(n.to_s,
				   :routing_key		=> @server_queue,
				   :correlation_id	=> call_id,
				   :reply_to		=> @reply_queue.name)

		lock.synchronize{condition.wait(lock)}
		response
	end

	protected

	def generate_uuid
		# very native but good enough for code examples
		"#{rand}#{rand}#{rand}"		
	end
end