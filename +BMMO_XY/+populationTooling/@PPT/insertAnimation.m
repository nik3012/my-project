function insertAnimation(obj, slideTitle, slideSubtitle, animationFile)
% Function to properly insert an animation on a new slide with a given title and
% subtitle.


% Determine the dimensions of the animation
try
    [x, y, ~] = size(imread(animationFile));
catch
    error('file cannot be processed by matlab, check the filename or add to PPT manually');
end

% Insert a new slide with the given title and subtitle
newslide(slideTitle, slideSubtitle, 'nohide', 'phandle', obj.filehandle);

% Insert the animation in the new slide
imageppt(obj.filehandle, animationFile, [0 0 y x]);

end


function imageppt(phandle, file, fileDimensions)

% Select the slide to add the image to
slide = phandle.Slides.Item(phandle.Slides.Count);
slide.Select;

% Calculate the position of the image on the PowerPoint slide
slideHeight  = double(phandle.PageSetup.SlideHeight);
slideWidth   = double(phandle.PageSetup.SlideWidth);
holderHeight = slideHeight * 0.794;
holderWidth  = slideWidth * 0.98;
holderTop    = slideHeight * 0.180;
holderLeft   = slideWidth * 0.01;

% Insert the image into the slide as a "Picture"
graph = slide.Shapes.AddPicture(file, 'msoFalse', 'msoTrue', 100, 100, 400, 400);

% Set the dimensions of the picture to be the same as the dimensions of the file
graph.LockAspectRatio = 'msoFalse';
graph.Width           = fileDimensions(3);
graph.Height          = fileDimensions(4);
graph.Left            = fileDimensions(1);
graph.Top             = fileDimensions(2);
graph.LockAspectRatio = 'msoTrue';

% Scale the picture to fit the slide
figureRatio = fileDimensions(3) / fileDimensions(4);
if figureRatio < holderWidth / holderHeight
    graph.Width  = holderHeight * figureRatio;
    graph.Height = holderHeight;
    graph.Top    = holderTop;
    graph.Left   = holderLeft + 0.5 * (holderWidth - holderHeight * figureRatio);
else
    graph.Width  = holderWidth;
    graph.Height = holderWidth / figureRatio;
    graph.Top    = holderTop + 0.5 * (holderHeight - holderWidth / figureRatio);
    graph.Left   = holderLeft;
end

end