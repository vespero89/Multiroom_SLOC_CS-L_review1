function [x_out] = cepstrum_dereveb( x )

frame_size = 2048; % K nell'articolo
overlap = 0;
hop = frame_size-overlap;
alpha = 0.9985;
mu = 0.0001;

x_frames = buffer(x, frame_size, overlap, 'nodelay');
x_frames_out = zeros(size(x_frames));
x_out = zeros(frame_size*size(x_frames,2), 1);
win = alpha.^(0:frame_size-1)';

for m = 1:size(x_frames,2)
  x_frame = x_frames(:,m);
  x_frame_win = x_frames(:,m) .* win;
  [x_cep,nd] = cceps(x_frame_win);
  [~, x_mpc] = rceps(x_frame_win);
  if (m == 1)
    h_min = x_mpc; 
  else
    h_min = (1 - mu) .*h_min_prev + mu .* x_mpc;
  end
  h_min_prev = h_min;
  x_cep_est = x_cep - h_min;  
  x_frame_out = icceps(x_cep_est, nd)./win;
  x_frames_out(:,m) = x_frame_out;  
  x_out((m-1)*hop+1:(m-1)*hop+frame_size) = x_out((m-1)*hop+1:(m-1)*hop+frame_size)+x_frames_out(:,m);
end
x_out = x_out(1:length(x));

x_out = - 1 + 2.*(x_out - min(x_out))./(max(x_out) - min(x_out));

end