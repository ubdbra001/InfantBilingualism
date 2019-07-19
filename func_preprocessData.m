function data_out = func_preprocessData(data_in)

LXRX_LYRY = data_in(:,[9, 22, 10, 23]);            % Extract data for individual eyes from epoch

LXRX_LYRY(LXRX_LYRY < -0.05 | LXRX_LYRY > 1.05) = NaN;   % Remove samples where participant was not looking at the screen

data_out = [data_in(:,1) (data_in(:,1)-data_in(1,1))/1e6 LXRX_LYRY]; % Append sample times to data