require "rubygems"
require "bunny"
require "thread"
#require './lib/photos/raspicam_client.rb'

class PhotosController < ApplicationController
	before_action :signed_in_user, only: [:create, :destroy]
	before_action :correct_user,   only: :destroy

	def create
		puts "--PhotosController.create--"

		conn    = Bunny.new(:host => "54.191.172.249", 
							:port => "5672", 
							:user => "guest",
							:password => "guest",
							:automatically_recover => false)
		conn.start

		ch      = conn.create_channel

		client = Raspi.new(ch, "rpc_queue")

		command = "raspistill -w 1024 -h 768 -rot 90 -o "
		puts " [x] Requesting #{command}"
		response = client.call(command)
		puts " c_step 0"

		if !response.empty?
			
			fileN = client.file
			puts " cF::: #{fileN}"
			puts " c_step 1"

			#savePath      = "../assets/images/"
			savePath      = "/home/ubuntu/rails_projects/raspicam_app/app/assets/images/#{current_user.id}/"

			#path      = "./"
			path      = "#{current_user.id}/"
			if !Dir.exist?(savePath)
			puts "-------savePath: #{savePath}"
				Dir.mkdir(savePath)
			end

			title = Time.new.strftime("%Y%m%d_%H%M%S")
			suffix = ".jpeg"
			filename = title+suffix
			cam_id    = "raspicam_01"

			puts "-------path: #{path}"
			puts "-------filename: #{filename}"
			puts "-------cam_id: #{cam_id}"

			#file = File.new("#{path}#{filename}", "wb")
			file = File.new("#{savePath}#{filename}", "wb")
			puts "c_step 2: file opened"
			file.write(response)
			puts "c_step 3: file wrote"
			file.close
			puts "c_step 4: file closed"
			ch.close
			conn.close

			#@photo = current_user.photos.build(photos_params)
			if current_user.photos.create(path: path, filename: filename, cam_id: cam_id)
			#if @photo.save
				flash[:success] = "A photo created!"
				redirect_to root_url
			else
				#@feed_items = []
				render 'static_pages/home'
			end
		end
	end

	def destroy
		@photo.destroy
		redirect_to root_url
	end


	private

		def photos_params
			params.require(:photo).permit(path: self.path, filename: self.filename, cam_id: self.cam_id, user_id: current_user)
		end

		def correct_user
			@photo = current_user.photos.find_by(id: params[:id])
			redirect_to root_url if @photo.nil?
		end
end