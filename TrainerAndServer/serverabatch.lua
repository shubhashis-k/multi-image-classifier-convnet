local app = require('waffle').CmdLine()

require 'graphicsmagick'
require 'image'
require 'nn'

TopCount = 1

print("model loading")
model = torch.load("model.net")
print("model loaded")

app.get('/path/(%w+)(.*)', function(req, res)
	local path = req.params[1]
	ex = req.params[2]

	mean_u = -4.3065506356254
	std_u = 13.66321370424
	mean_v = 2.3578541481531
	std_v = 17.067521638107	
	

	imageDirectory = path
	imageDirectory = imageDirectory ..".".. string.gsub(ex, "%A", "")
	
	--print(imageDirectory)

	img = image.load(imageDirectory)
	--experimental
	img = image.scale(img, 32, 32)
	img = img:mul(255)

	testData = torch.Tensor(2,3,32,32)

	testData[1] = img
	testData[2] = img
	

	--print(#testData)

	normalization = nn.SpatialContrastiveNormalization(1, image.gaussian1D(7))
	for i = 1,2 do
	     -- rgb -> yuv
	     local rgb = testData[i]
	     local yuv = image.rgb2yuv(rgb)
	     -- normalize y locally:
	     yuv[{1}] = normalization(yuv[{{1}}])
	     testData[i] = yuv
	  end

	  -- normalize u globally:
	  testData:select(2,2):add(-mean_u)
	  testData:select(2,2):div(std_u)
	  -- normalize v globally:
	  testData:select(2,3):add(-mean_v)
	  testData:select(2,3):div(std_v)


	result = model:forward(testData)
	result = result:exp()	
	sum = torch.sum(result[1])


	cls = {'airplane', 'automobile', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse', 'ship', 'truck'}

	sortedResult = torch.sort(result[1], true)

        response = ""

	for i = 1,TopCount,1 do
	    labelNumber =result[1]:eq(sortedResult[i]):nonzero()
	    response = response .. cls[labelNumber[1][1]] .. " " .. sortedResult[i]/sum .. " "
	end
	
	--print(response)

	res.send(string.format('%s', response))
end)








function classify(imagename)

    	mean_u = -4.3065506356254
	std_u = 13.66321370424
	mean_v = 2.3578541481531
	std_v = 17.067521638107	
	

	imageDirectory = imagename

	img = image.load(imageDirectory)
	--experimental
	img = image.scale(img, 32, 32)
	img = img:mul(255)

	testData = torch.Tensor(2,3,32,32)

	testData[1] = img
	testData[2] = img
	

	--print(#testData)

	normalization = nn.SpatialContrastiveNormalization(1, image.gaussian1D(7))
	for i = 1,2 do
	     -- rgb -> yuv
	     local rgb = testData[i]
	     local yuv = image.rgb2yuv(rgb)
	     -- normalize y locally:
	     yuv[{1}] = normalization(yuv[{{1}}])
	     testData[i] = yuv
	  end

	  -- normalize u globally:
	  testData:select(2,2):add(-mean_u)
	  testData:select(2,2):div(std_u)
	  -- normalize v globally:
	  testData:select(2,3):add(-mean_v)
	  testData:select(2,3):div(std_v)


	result = model:forward(testData)

	result = result:exp()
	sum = torch.sum(result[1])
    result[1] = result[1]/sum

	return result[1]
    
end


































app.get('/multi/(%w+)', function(req, res)

	folder = req.params[1]
	
	handle = io.popen("ls ./" ..folder.. " | grep -E '.png|.jpg'")
	result = handle:read("*a")

	handle:close()

	TotalResult = {0,0,0,0,0,0,0,0,0,0}
	
	for i in string.gmatch(result, "%S+") do
	  list = classify("./" .. folder .. "/" ..i)

	  for j = 1,10,1 do 
		for j = 1,10,1 do TotalResult[j] = TotalResult[j] + list[j] end 
	  end
	end
	
	print("Accumulated result")
	print(TotalResult)

	cls = {'airplane', 'automobile', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse', 'ship', 'truck'}

	Labels = ""
	
	printingLabel = 4

	print("Selecting")
	for i = 1,printingLabel,1 
	    do
		max = 0
		index = 0
		for j = 1,#TotalResult,1 
		    do 
		        if(TotalResult[j] > max) then max = TotalResult[j] index = j end
		    end
		print(index)

		if(index ~= 0) then
			Labels = Labels .. cls[index] .. " "
		end

		TotalResult[index] = 0
	    end

	response = Labels

	res.send(string.format('%s', response))
end)


















app.get('/batch/', function(req, res)

	folder = {"1", "2", "3"}
	
	response = ""

	for i = 1,#folder,1 do

		handle = io.popen("ls ./" ..folder[i].. " | grep -E '.png|.jpg'")
		result = handle:read("*a")

		handle:close()

		TotalResult = {0,0,0,0,0,0,0,0,0,0}
		
		for i in string.gmatch(result, "%S+") do
		  list = classify("./" .. folder .. "/" ..i)

		  for j = 1,10,1 do 
			for j = 1,10,1 do TotalResult[j] = TotalResult[j] + list[j] end 
		  end
		end
		
		print("Accumulated result")
		print(TotalResult)

		cls = {'airplane', 'automobile', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse', 'ship', 'truck'}

		Labels = ""
		
		printingLabel = 4

		print("Selecting")
		for i = 1,printingLabel,1 
		    do
			max = 0
			index = 0
			for j = 1,#TotalResult,1 
			    do 
			        if(TotalResult[j] > max) then max = TotalResult[j] index = j end
			    end
			print(index)

			if(index ~= 0) then
				Labels = Labels .. cls[index] .. " "
			end

			TotalResult[index] = 0
		    end

		response = response .. "folder " .. folder[i].. " " .. Labels .. "\n"
	

	end


	res.send(string.format('%s', response))
end)












app.listen()
