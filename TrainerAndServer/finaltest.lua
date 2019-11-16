require 'nn'
require 'image'

cmd = torch.CmdLine()
cmd:option('path','pathlocation')

params = cmd:parse(arg)

topCount = 3

mean_u = -4.3065506356254
std_u = 13.66321370424
mean_v = 2.3578541481531
std_v = 17.067521638107	

imageDirectory = params['path']

img = image.load(imageDirectory)
--experimental
img = image.scale(img, 32, 32)

img = img:mul(255)

testData = torch.Tensor(2,3,32,32)

testData[1] = car
testData[2] = car

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


result = vgg:forward(test)

cls = {'airplane', 'automobile', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse', 'ship', 'truck'}

sortedResult = torch.sort(result[1], true)

for i = 1,topCount,1 do
    labelNumber =result[1]:eq(sortedResult[i]):nonzero()
    print(cls[labelNumber[1][1]])
end

