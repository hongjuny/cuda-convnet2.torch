local C = ccn2.C

local SpatialCrossResponseNormalization, parent = torch.class('ccn2.SpatialCrossResponseNormalization', 'nn.Module')

function SpatialCrossResponseNormalization:__init(size, addScale, powScale, minDiv)
  parent.__init(self)
  
  self.size = size
  self.addScale = addScale
  self.powScale = powScale
  self.minDiv = minDiv
  
  self.output = torch.Tensor()
  self.gradInput = torch.Tensor()
  
  self:cuda()
end


function SpatialCrossResponseNormalization:updateOutput(input)
  ccn2.typecheck(input)
  ccn2.inputcheck(input)
  local nBatch = input:size(4)
  local inputC = input:view(input:size(1) * input:size(2) * input:size(3), input:size(4))
  self.output:resize(inputC:size())
  
  C['convResponseNormCrossMap'](inputC:cdata(), self.output:cdata(), input:size(1), self.size, self.addScale, self.powScale, self.minDiv, true)
  
  self.output = self.output:view(input:size(1), input:size(2), input:size(3), input:size(4))
  return self.output
end


function SpatialCrossResponseNormalization:updateGradInput(input, gradOutput)
  ccn2.typecheck(input); ccn2.typecheck(gradOutput);
  ccn2.inputcheck(input); ccn2.inputcheck(gradOutput);
  local nBatch = input:size(4)
  local inputC = input:view(input:size(1) * input:size(2) * input:size(3), input:size(4))
  local gradOutputC = gradOutput:view(gradOutput:size(1) * gradOutput:size(2) * gradOutput:size(3), gradOutput:size(4))
  local outputC = self.output:view(gradOutput:size(1) * gradOutput:size(2) * gradOutput:size(3), gradOutput:size(4))
  
  self.gradInput:resize(inputC:size())
 
  C['convResponseNormCrossMapUndo'](gradOutputC:cdata(), inputC:cdata(), outputC:cdata(), self.gradInput:cdata(), input:size(1), self.size, self.addScale, self.powScale, self.minDiv, true, 0, 1)
  self.gradInput = self.gradInput:view(input:size(1), input:size(2), input:size(3), input:size(4))
  return self.gradInput
end
