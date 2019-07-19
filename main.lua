
--render test class images for a given head file
function render_head(head_img)
	local genders = {
		"Male",
		"Female",
	}
	local classes = {
		"Builder",
		"Knight",
		"Archer",
	}
	
	--frame parameters
	local cfw, cfh, fc = 32, 32, 3
	local hfw, hfh = 16, 16

	--frame setup
	--head_frame, fx, fy, hx, hy, ox, oy
	local frames = {
		Builder = {
			{1, 0, 0, 17, 16, 0, 0},
			{2, 6, 2, 17, 16, 0, 0},
			{3, 6, 1, 21, 24, -2, -8},
		},
		Knight = {
			{1, 0, 0, 16, 15, 0, 0},
			{2, 5, 4, 14, 14, 0, 0},
			{3, 3, 6, 26, 26, -6, -8},
		},
		Archer = {
			{1, 0, 0, 16, 16, 0, 0},
			{3, 4, 1, 20, 23, 0, -8},
		},
	}

	local result_img = love.graphics.newCanvas(#classes * #genders * cfw, fc * cfh)
	love.graphics.setCanvas(result_img)

	local head_q = love.graphics.newQuad(0, 0, hfw, hfh, head_img:getDimensions())

	for gi, gender in ipairs(genders) do
		for ci, class in ipairs(classes) do
			local class_filename = table.concat{"class_images/", class, gender, ".png"}
			local class_img = love.graphics.newImage(class_filename)
			local body_q = love.graphics.newQuad(0, 0, cfw, cfh, class_img:getDimensions())
			
			for frame, frame_def in ipairs(frames[class]) do
				--generate in frame space
				local x, y = (ci - 1) * 2 + (gi - 1), frame - 1
				--to pixel space
				x, y = x * cfw, y * cfh
				--definition for this render
				local head_frame, fx, fy, hox, hoy, oox, ooy = unpack(frame_def)

				--modify head offset
				hox = hox - 8
				hoy = hoy - 8 - 2

				--apply overall offset
				x = x + oox
				y = y + ooy

				--setup quads
				body_q:setViewport(fx * cfw, fy * cfh, cfw, cfh)
				head_q:setViewport((head_frame - 1) * hfw, 0, hfw, hfh)
				--render
				love.graphics.draw(
					class_img, body_q,
					x, y
				)
				love.graphics.draw(
					head_img, head_q,
					x + hox, y + hoy
				)
			end
		end
	end

	love.graphics.setCanvas()
	return result_img
end

function love.load(args)
	if args then
		local filename, outfile = unpack(args)
		local head_img = love.graphics.newImage(filename)
		if not head_img then
			error("couldn't load image from "..tostring(filename))
		end
		local result_img = render_head(head_img)
		if type(outfile) == "string" then
			--get render result
			local id = result_img:newImageData()
			--encode to png
			local fd = id:encode("png")
			--release render result
			id:release()
			--todo: write to out filename
			local outfile = io.open(outfile, "wb")
			if outfile then
				outfile:write(fd:getString())
				outfile:close()
			end

			--exit (batch job)
			love.event.quit()
		end

		global_result = result_img
	end

	--love.event.quit()
end

function love.draw()
	global_result:setFilter("nearest", "nearest")
	love.graphics.origin()
	love.graphics.draw(
		global_result,
		love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5,
		0,
		2, 2,
		global_result:getWidth() * 0.5, global_result:getHeight() * 0.5
	)
end

function love.filedropped(file)
	--todo: pcall to protect against load failure?
	--load
	local file_contents = love.filesystem.newFileData(file:read(), "dropped_file")
	local as_image = love.image.newImageData(file_contents)
	local head_img = love.graphics.newImage(as_image)
	--render
	global_result = render_head(head_img)
	--clean up
	head_img:release()
	as_image:release()
	file_contents:release()
end

function love.keypressed(k)
	if k == "r" then
		love.event.quit("restart")
	end

	if k == "q" or k == "escape" then
		love.event.quit()
	end	
end
