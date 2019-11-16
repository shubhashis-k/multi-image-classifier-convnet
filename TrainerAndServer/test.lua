require 'nn'
require 'image'

trsize = 50000
tesize = 10000

mean_u = 122.95039414062	
std_u  = 62.088708246722	
mean_v = 113.86538318359	
std_v  = 66.704900292063	


car = image.load("car.jpg")
testData = torch.Tensor(2,3,32,32)
normalization = nn.SpatialContrastiveNormalization(1, image.gaussian1D(7))

testData[1] = car
testData[2] = car

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
