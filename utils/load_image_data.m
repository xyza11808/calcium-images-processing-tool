function [mean_images, max_images] = load_image_data(data_path)
	%read tif data and summarize to mean image stack
	if exist(fullfile(data_path, 'summarized\summarized.mat'), 'file')
		max_mean_image = load(fullfile(data_path, 'summarized\summarized.mat'));
		mean_images = max_mean_image.mean_images;
		max_images = max_mean_image.max_images;
	else
		d = dir(fullfile(data_path, '*.tif*'));
		mean_images = [];
		max_images = [];
		f = waitbar(0,sprintf('Processing data...%.2f%%', 0.0));
		for i = 1:size(d, 1)
			f = waitbar(i/size(d, 1), f, sprintf('Processing data...%.2f%%', (i/size(d, 1))*100));
			tiff_filename = fullfile(data_path, d(i).name);
			info = imfinfo(tiff_filename);
			numImages = length(info);
			tiff = Tiff(tiff_filename, 'r');
			mean_image_data = double(read(tiff));
			max_image_data = mean_image_data;
			for j = 2:numImages
				tiff.setDirectory(j);
				temp = double(read(tiff));
				mean_image_data = mean_image_data + temp;
				max_image_data = max(max_image_data, temp);
			end
			
			mean_image_data = mean_image_data - min(mean_image_data(:));
			mean_image_data = mean_image_data / max(mean_image_data(:));
			
			max_image_data = max_image_data - min(max_image_data(:));
			max_image_data = max_image_data / max(max_image_data(:));
			
			if i == 1
				mean_images = zeros(size(mean_image_data, 1), size(mean_image_data, 2), size(d, 1));
				max_images = zeros(size(max_image_data, 1), size(max_image_data, 2), size(d, 1));
			end
			mean_images(:, :, i) = mean_image_data;
			max_images(:, :, i) = max_image_data;
		end
		close(f);
		if exist(fullfile(data_path, 'summarized'), 'dir') == 0
			mkdir(fullfile(data_path, 'summarized'));
		end
		save(fullfile(data_path, 'summarized\summarized.mat'), 'mean_images', 'max_images');
	end
end