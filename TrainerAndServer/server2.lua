local app = require('waffle').CmdLine()

require 'graphicsmagick'
require 'image'
require 'nn'

topCount = 2

vgg = nn.Sequential()
-- building block
local function ConvBNReLU(nInputPlane, nOutputPlane)
  vgg:add(nn.SpatialConvolution(nInputPlane, nOutputPlane, 3,3, 1,1, 1,1))
  vgg:add(nn.SpatialBatchNormalization(nOutputPlane,1e-3))
  vgg:add(nn.ReLU(true))
  return vgg
end

-- Will use "ceil" MaxPooling because we want to save as much
-- space as we can
local MaxPooling = nn.SpatialMaxPooling

ConvBNReLU(3,64):add(nn.Dropout(0.3))
ConvBNReLU(64,64)
vgg:add(MaxPooling(2,2,2,2):ceil())

ConvBNReLU(64,128):add(nn.Dropout(0.4))
ConvBNReLU(128,128)
vgg:add(MaxPooling(2,2,2,2):ceil())

ConvBNReLU(128,256):add(nn.Dropout(0.4))
ConvBNReLU(256,256):add(nn.Dropout(0.4))
ConvBNReLU(256,256)
vgg:add(MaxPooling(2,2,2,2):ceil())

ConvBNReLU(256,512):add(nn.Dropout(0.4))
ConvBNReLU(512,512):add(nn.Dropout(0.4))
ConvBNReLU(512,512)
vgg:add(MaxPooling(2,2,2,2):ceil())

ConvBNReLU(512,512):add(nn.Dropout(0.4))
ConvBNReLU(512,512):add(nn.Dropout(0.4))
ConvBNReLU(512,512)
vgg:add(MaxPooling(2,2,2,2):ceil())
vgg:add(nn.View(512))

classifier = nn.Sequential()
classifier:add(nn.Dropout(0.5))
classifier:add(nn.Linear(512,512))
classifier:add(nn.BatchNormalization(512))
classifier:add(nn.ReLU(true))
classifier:add(nn.Dropout(0.5))
classifier:add(nn.Linear(512,10))
vgg:add(classifier)


app.get('/path/(%a+)(.*)', function(req, res)
	local path = req.params[1]
	ex = req.params[2]

	mean_u = -4.3065506356254
	std_u = 13.66321370424
	mean_v = 2.3578541481531
	std_v = 17.067521638107	
	

	imageDirectory = path
	imageDirectory = imageDirectory ..".".. string.gsub(ex, "%A", "")
	
	print(imageDirectory)

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


	result = vgg:forward(testData)
	result = result:exp()	
	sum = torch.sum(result[1])


	cls = {'airplane', 'automobile', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse', 'ship', 'truck'}

	sortedResult = torch.sort(result[1], true)

        response = ""

	for i = 1,topCount,1 do
	    labelNumber =result[1]:eq(sortedResult[i]):nonzero()
	    response = response .. cls[labelNumber[1][1]] .. "\n" .. sortedResult[i]/sum .. "\n"
	end
	
	--print(response)

	res.send(string.format('%s', response))
end)

app.listen()
