function model = multvargplvmCreate(varargin)

model = svargplvmModelCreate(varargin{:});

model.type = 'multvargplvm';