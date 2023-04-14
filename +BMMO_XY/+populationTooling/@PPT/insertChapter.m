function insertChapter(obj, chapterTitle)
% Insert a new chapter including title in the ppt.
newslide(chapterTitle, 'chapter', 'phandle', obj.filehandle);

end